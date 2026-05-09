/**
 * Session Audit Log
 *
 * Append-only JSONL audit log for tracking user-AI conversations.
 * Captures timestamps, message types, skill invocations, and session context.
 *
 * Toggle: Set EM_TEAM_SESSION_AUDIT="true" in settings.local.json env block.
 *
 * @version 1.0.0
 * @license MIT
 */

import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

// ============================================
// Type Definitions
// ============================================

export type AuditEventType = 'user' | 'assistant' | 'system' | 'skill_start' | 'skill_end' | 'artifact_export';

export interface AuditEntry {
  ts: string;
  type: AuditEventType;
  session: string;
  skill?: string;
  content: string;
  metadata?: Record<string, unknown>;
}

export interface AuditStats {
  total: number;
  byType: Record<AuditEventType, number>;
  bySkill: Record<string, number>;
  byDate: Record<string, number>;
  dateRange: { first: string; last: string } | null;
}

// ============================================
// SessionAudit Class
// ============================================

export class SessionAudit {
  private projectRoot: string;
  private logDir: string;
  private sessionId: string;

  constructor(projectRoot: string) {
    this.projectRoot = projectRoot;
    this.logDir = path.join(projectRoot, '.em-team', 'logs');
    this.sessionId = process.env.CLAUDE_SESSION_ID || crypto.randomUUID();
    this.ensureDir();
  }

  private ensureDir(): void {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true });
    }
  }

  private getLogPath(): string {
    const date = new Date().toISOString().split('T')[0];
    return path.join(this.logDir, `audit-${date}.jsonl`);
  }

  isEnabled(): boolean {
    return (process.env.EM_TEAM_SESSION_AUDIT || '').toLowerCase() === 'true';
  }

  append(type: AuditEventType, content: string, skill?: string, metadata?: Record<string, unknown>): string | null {
    if (!this.isEnabled()) return null;

    const entry: AuditEntry = {
      ts: new Date().toISOString(),
      type,
      session: this.sessionId,
      content: content.slice(0, 2000),
    };
    if (skill) entry.skill = skill;
    if (metadata) entry.metadata = metadata;

    const line = JSON.stringify(entry) + '\n';
    const logPath = this.getLogPath();
    fs.appendFileSync(logPath, line, 'utf-8');
    return logPath;
  }

  logUser(message: string): string | null {
    return this.append('user', message);
  }

  logAssistant(message: string, skill?: string): string | null {
    return this.append('assistant', message, skill);
  }

  logSkillStart(skillName: string, input?: string): string | null {
    return this.append('skill_start', `Skill started: ${skillName}`, skillName, { input: input?.slice(0, 500) });
  }

  logSkillEnd(skillName: string, output?: string): string | null {
    return this.append('skill_end', `Skill completed: ${skillName}`, skillName, { output: output?.slice(0, 500) });
  }

  logArtifactExport(artifactPath: string, skillName: string): string | null {
    return this.append('artifact_export', `Exported artifact: ${artifactPath}`, skillName);
  }

  logSystem(message: string): string | null {
    return this.append('system', message);
  }

  // ============================================
  // Query Functions
  // ============================================

  readLog(date?: string): AuditEntry[] {
    const logPath = date
      ? path.join(this.logDir, `audit-${date}.jsonl`)
      : this.getLogPath();

    if (!fs.existsSync(logPath)) return [];

    return fs.readFileSync(logPath, 'utf-8')
      .split('\n')
      .filter(line => line.trim())
      .map(line => {
        try { return JSON.parse(line) as AuditEntry; }
        catch { return null; }
      })
      .filter((e): e is AuditEntry => e !== null);
  }

  readRecent(days: number = 7): AuditEntry[] {
    const entries: AuditEntry[] = [];
    for (let i = 0; i < days; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      entries.push(...this.readLog(dateStr));
    }
    return entries.sort((a, b) => a.ts.localeCompare(b.ts));
  }

  findBySkill(skillName: string, days: number = 30): AuditEntry[] {
    return this.readRecent(days).filter(e => e.skill === skillName);
  }

  findBySession(sessionId: string): AuditEntry[] {
    const allEntries: AuditEntry[] = [];
    const files = fs.readdirSync(this.logDir).filter(f => f.endsWith('.jsonl'));
    for (const f of files) {
      const content = fs.readFileSync(path.join(this.logDir, f), 'utf-8');
      content.split('\n').filter(l => l.trim()).forEach(line => {
        try {
          const entry = JSON.parse(line) as AuditEntry;
          if (entry.session === sessionId) allEntries.push(entry);
        } catch { /* skip malformed */ }
      });
    }
    return allEntries.sort((a, b) => a.ts.localeCompare(b.ts));
  }

  getStats(days: number = 30): AuditStats {
    const entries = this.readRecent(days);
    const stats: AuditStats = {
      total: entries.length,
      byType: { user: 0, assistant: 0, system: 0, skill_start: 0, skill_end: 0, artifact_export: 0 },
      bySkill: {},
      byDate: {},
      dateRange: null,
    };

    if (entries.length > 0) {
      const dates = entries.map(e => e.ts.split('T')[0]).sort();
      stats.dateRange = { first: dates[0], last: dates[dates.length - 1] };
    }

    for (const entry of entries) {
      stats.byType[entry.type] = (stats.byType[entry.type] || 0) + 1;
      const date = entry.ts.split('T')[0];
      stats.byDate[date] = (stats.byDate[date] || 0) + 1;
      if (entry.skill) {
        stats.bySkill[entry.skill] = (stats.bySkill[entry.skill] || 0) + 1;
      }
    }

    return stats;
  }

  // ============================================
  // Rotation
  // ============================================

  rotate(daysToKeep: number = 30): number {
    const archiveDir = path.join(this.logDir, 'archive');
    if (!fs.existsSync(archiveDir)) {
      fs.mkdirSync(archiveDir, { recursive: true });
    }

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
    const cutoffStr = cutoffDate.toISOString().split('T')[0];

    let rotated = 0;
    const files = fs.readdirSync(this.logDir).filter(f => f.startsWith('audit-') && f.endsWith('.jsonl'));

    for (const file of files) {
      const datePart = file.replace('audit-', '').replace('.jsonl', '');
      if (datePart < cutoffStr) {
        const src = path.join(this.logDir, file);
        const dest = path.join(archiveDir, file + '.gz');
        const content = fs.readFileSync(src);
        // Simple rotation: move to archive (could add gzip compression)
        fs.renameSync(src, dest);
        rotated++;
      }
    }

    return rotated;
  }

  getSessionId(): string {
    return this.sessionId;
  }

  getLogDir(): string {
    return this.logDir;
  }
}

// ============================================
// Utility Functions
// ============================================

export function getDefaultSessionAudit(): SessionAudit {
  return new SessionAudit(process.cwd());
}

module.exports = { SessionAudit, getDefaultSessionAudit };
