# Flow: Create Contract

## Metadata
- **Feature**: Create Contract (New Submission)
- **URL**: https://dev.apex.pinnacleunderwriting.com
- **Auth Required**: Yes (MSAL/Azure AD B2C via storageState)
- **Prerequisites**: Authenticated session with submission creation permissions
- **Discovered**: 2026-05-03T13:40:00.000Z
- **Status**: verified

## Steps

### Step 1: Navigate to Dashboard
- **URL**: https://dev.apex.pinnacleunderwriting.com/home/dashboard
- **Action**: navigate
- **Input**: `https://dev.apex.pinnacleunderwriting.com/home/dashboard`
- **Expected**: Dashboard loaded
- **Screenshot**: screenshots/step-1.png

### Step 2: Navigate to Submissions page
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions
- **Action**: navigate
- **Input**: `https://dev.apex.pinnacleunderwriting.com/submissions`
- **Expected**: Submissions list page loads
- **Screenshot**: screenshots/step-2.png

### Step 3: Click "Create New Submission"
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions/new-submission
- **Action**: click
- **Selector**: `text="Create New Submission"`
- **Expected**: Submission creation form appears
- **Screenshot**: screenshots/step-3.png

### Step 4: Fill Transaction Type
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions/new-submission
- **Action**: fill
- **Selector**: `#transactionType`
- **Input**: `New Business`
- **Expected**: Transaction Type populated
- **Screenshot**: screenshots/step-4.png

### Step 5: Fill Placement Type
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions/new-submission
- **Action**: fill
- **Selector**: `#placingType`
- **Input**: `New Business`
- **Expected**: Placement Type populated
- **Screenshot**: screenshots/step-5.png

### Step 6: Fill Expiry Date
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions/new-submission
- **Action**: fill
- **Selector**: `#expiryDate`
- **Input**: `01/06/2027`
- **Expected**: Expiry Date populated
- **Screenshot**: screenshots/step-6.png

### Step 7: Fill Insured
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions/new-submission
- **Action**: fill
- **Selector**: `#insuredId`
- **Input**: `Test Insured Corp`
- **Expected**: Insured populated
- **Screenshot**: screenshots/step-7.png

### Step 8: Click "Create New Record"
- **URL**: https://dev.apex.pinnacleunderwriting.com/submissions/new-submission
- **Action**: click
- **Selector**: `text="Create New Record"`
- **Expected**: Submission created successfully
- **Screenshot**: screenshots/result.png

## Form Fields Discovered

| Field | Type | Selector | Required | Notes |
|-------|------|----------|----------|-------|
| Status | search/dropdown | `#status` | No | Auto-set to "Pending" |
| Policy Type | search/dropdown | `#policyType` | No | Default "Reinsurance" |
| Transaction Type | search/dropdown | `#transactionType` | No | e.g. "New Business" |
| Placement Type | search/dropdown | `#placingType` | No | |
| Line of Business | search/dropdown | `#lineOfBusiness` | No | |
| Sub-Class | search/dropdown | `#subClass` | No | |
| Assigned Handler | search/dropdown | `#assignedHandlerId` | No | |
| Named Underwriter | search/dropdown | `#namedUnderwriterId` | No | |
| Inception Date | text/date | `#inceptionDate` | No | |
| Expiry Date | text/date | `#expiryDate` | No | |
| Insured | search | `#insuredId` | No | Search/select from list |
| Principal Occupation | search | `#principalOccupation` | No | |
| Currency | search/dropdown | `#originalCurrency` | No | |
| Main Region & Risk Territory | search/dropdown | `#mainRegionAndRiskTerritory` | No | |
| Primary Risk Location | text | `#keyRiskLocation` | No | |
| Comments | textarea | `#comment` | No | |
| File Upload | file | `[name="file"]` | No | Drag & drop or choose file |

## API Calls

| Step | Method | URL | Status |
|------|--------|-----|--------|
| 1 | GET | /home/dashboard | 200 |
| 2 | GET | /submissions | 200 |
| 3 | GET | /submissions/new-submission | 200 |

## Notes

- Most fields are **search/dropdown** type (react-select or similar) — need `click` then `type` then `press Enter` pattern, not `fill` directly
- Status auto-sets to "Pending", Policy Type defaults to "Reinsurance"
- Form is at `/submissions/new-submission` — a dedicated page, not a modal
- Submit button text is "Create New Record"
- The app sidebar shows: Home, Policy Management, Opportunity, Submissions, Create New Submission, Clone Submission, Renewals, Premium Receipting, Claims, Bordereaux Reports, Portfolio Analysis, Reference Data, Tools and Utilities, Settings
