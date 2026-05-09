/**
 * Artifact Store
 *
 * Exports skill outputs (specs, plans, reviews, brainstorm) as Markdown files
 * to the current working directory for tracking and auditing.
 *
 * Toggle: Set EM_TEAM_ARTIFACT_EXPORT="true" in settings.local.json env block.
 *
 * Directory mapping (all relative to cwd):
 *   brainstorming        → brainstorm/
 *   spec-driven-dev      → specs/
 *   writing-plans        → plans/
 *   code-review          → reviews/
 *   architecture-zoom-out → architecture/
 *   security-audit       → security/
 *   all others           → artifacts/
 *
 * @version 1.0.0
 * @license MIT
 */

import * as fs from 'fs';
import * as path from 'path';

// ============================================
// Type Definitions
// ============================================

export interface ArtifactMeta {
  skill: string;
  date: string;
  session?: string;
  category: string;
  relatedFiles?: string[];
  decisions?: string[];
}

export interface ArtifactEntry {
  path: string;
  meta: ArtifactMeta;
  createdAt: string;
}

// ============================================
// Category Mapping
// ============================================

const SKILL_CATEGORIES: Record<string, string> = {
  brainstorming: 'brainstorm',
  'spec-driven-development': 'specs',
  'spec-driven': 'specs',
  'writing-plans': 'plans',
  'code-review': 'reviews',
  'code-review-9axis': 'reviews',
  'architecture-zoom-out': 'architecture',
  'architecture-improvement': 'architecture',
  'security-audit': 'security',
  'security-review': 'security',
  'e2e-testing': 'tests',
  'performance-optimization': 'performance',
  'ux-audit': 'ux',
  'prd-generator': 'specs',
  'domain-modeling': 'specs',
  'issue-generator': 'plans',
};

function getCategory(skillName: string): string {
  return SKILL_CATEGORIES[skillName] || 'artifacts';
}

function timestampPrefix(): string {
  const now = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}-${pad(now.getHours())}${pad(now.getMinutes())}`;
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40);
}

// ============================================
// ArtifactStore Class
// ============================================

export class ArtifactStore {
  private cwd: string;

  constructor(cwd?: string) {
    this.cwd = cwd || process.cwd();
  }

  isEnabled(): boolean {
    return (process.env.EM_TEAM_ARTIFACT_EXPORT || '').toLowerCase() === 'true';
  }

  private ensureCategoryDir(category: string): string {
    const dir = path.join(this.cwd, category);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    return dir;
  }

  export(
    skillName: string,
    title: string,
    content: string,
    meta?: Partial<ArtifactMeta>
  ): string | null {
    if (!this.isEnabled()) return null;

    const category = getCategory(skillName);
    const dir = this.ensureCategoryDir(category);
    const filename = `${timestampPrefix()}-${slugify(title)}.md`;
    const filePath = path.join(dir, filename);

    const now = new Date().toISOString();
    const frontmatter = [
      '---',
      `skill: ${skillName}`,
      `title: ${title}`,
      `date: ${now}`,
      `category: ${category}`,
      meta?.session ? `session: ${meta.session}` : '',
      meta?.relatedFiles?.length ? `related_files:\n${meta.relatedFiles.map(f => `  - ${f}`).join('\n')}` : '',
      meta?.decisions?.length ? `decisions:\n${meta.decisions.map(d => `  - ${d}`).join('\n')}` : '',
      '---',
    ].filter(Boolean).join('\n');

    const fullContent = `${frontmatter}\n\n${content}\n`;

    fs.writeFileSync(filePath, fullContent, 'utf-8');
    return filePath;
  }

  list(category?: string): ArtifactEntry[] {
    const categories = category
      ? [category]
      : Object.values(SKILL_CATEGORIES).concat('artifacts');
    const seen = new Set<string>();
    const entries: ArtifactEntry[] = [];

    for (const cat of categories) {
      if (seen.has(cat)) continue;
      seen.add(cat);

      const dir = path.join(this.cwd, cat);
      if (!fs.existsSync(dir)) continue;

      const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
      for (const file of files) {
        const filePath = path.join(dir, file);
        const content = fs.readFileSync(filePath, 'utf-8');
        const meta = this.parseFrontmatter(content);
        entries.push({
          path: filePath,
          meta: meta || { skill: 'unknown', date: '', category: cat },
          createdAt: meta?.date || fs.statSync(filePath).mtime.toISOString(),
        });
      }
    }

    return entries.sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  }

  findBySkill(skillName: string): ArtifactEntry[] {
    return this.list().filter(e => e.meta.skill === skillName);
  }

  findRecent(days: number = 7): ArtifactEntry[] {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - days);
    return this.list().filter(e => new Date(e.createdAt) >= cutoff);
  }

  private parseFrontmatter(content: string): ArtifactMeta | null {
    if (!content.startsWith('---')) return null;
    const end = content.indexOf('---', 3);
    if (end === -1) return null;

    const yaml = content.slice(3, end).trim();
    const meta: Record<string, unknown> = {};
    for (const line of yaml.split('\n')) {
      const match = line.match(/^(\w+):\s*(.*)$/);
      if (match) meta[match[1]] = match[2];
    }

    return {
      skill: (meta.skill as string) || 'unknown',
      date: (meta.date as string) || '',
      category: (meta.category as string) || '',
      session: meta.session as string | undefined,
    };
  }

  getStats(): { total: number; byCategory: Record<string, number>; bySkill: Record<string, number> } {
    const entries = this.list();
    return {
      total: entries.length,
      byCategory: entries.reduce((acc, e) => {
        acc[e.meta.category] = (acc[e.meta.category] || 0) + 1;
        return acc;
      }, {} as Record<string, number>),
      bySkill: entries.reduce((acc, e) => {
        acc[e.meta.skill] = (acc[e.meta.skill] || 0) + 1;
        return acc;
      }, {} as Record<string, number>),
    };
  }

  clean(daysToKeep: number = 90): number {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - daysToKeep);
    let removed = 0;

    const entries = this.list();
    for (const entry of entries) {
      if (new Date(entry.createdAt) < cutoff) {
        fs.unlinkSync(entry.path);
        removed++;
      }
    }

    return removed;
  }
}

// ============================================
// Utility Functions
// ============================================

export function getDefaultArtifactStore(): ArtifactStore {
  return new ArtifactStore(process.cwd());
}

module.exports = { ArtifactStore, getDefaultArtifactStore };
