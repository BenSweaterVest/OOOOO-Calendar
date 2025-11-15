# OOOOO Calendar - Power Automate Flows Builder

Complete step-by-step instructions for creating all 3 Power Automate cloud flows.

**Time Required**: 90 minutes
**Difficulty**: Intermediate

---

## Overview

You will create:
1. **OOO Approval Workflow** - Main approval flow (40 min)
2. **Calendar Sync Flow** - Outlook integration (25 min)
3. **Daily Reminder Flow** - Morning reminders (25 min)

---

## Prerequisites

- Dataverse tables created
- Canvas app created
- Solution "OOOOO Calendar" exists

---

## Flow 1: OOO Approval Workflow (40 minutes)

### Purpose
Handles time-off request approvals via Microsoft Teams.

### Step 1.1: Create Flow

1. Navigate to **Solutions** → **OOOOO Calendar**
2. Click **+ New** → **Automation** → **Cloud flow** → **Automated**
3. Name: `OOOOO - OOO Approval Workflow`
4. Trigger: Search "Dataverse"
5. Select: **When a row is added, modified or deleted**
6. Click **Create**

### Step 1.2: Configure Trigger

**When a row is added, modified or deleted**:
- Change type: `Modified`
- Table name: `Staff Schedules`
- Scope: `Organization`
- Select columns: `ooooo_status` (Status field)
- Click **Show advanced options**
- Filter rows: Leave blank

### Step 1.3: Add Condition - Check Status

1. **+ New step** → **Condition**
2. Name condition: `Check if Status is OOO-Pending`
3. Condition:
   - Choose value: `Status` (from trigger)
   - Operator: `is equal to`
   - Value: `OOO-Pending` (from dropdown - value 3)

### Step 1.4: If Yes - Get Manager Info

1. In **Yes** branch, click **Add an action**
2. Search: **Dataverse**
3. Action: **Get a row by ID**
4. Configure:
   - Table name: `User Profiles`
   - Row ID: Click **Add dynamic content** →
     ```
     Search: Employee Email
     Insert: Employee Email
     ```
   - Expand **Show all**
   - Row ID: We need to use List rows instead

**Actually, let's use List rows**:
1. Delete "Get a row"
2. Add action: **List rows**
3. Configure:
   - Table name: `User Profiles`
   - Filter rows:
     ```
     ooooo_email eq '@{triggerOutputs()?['body/ooooo_employeeemail']}'
     ```
   - Fetch only top: `1`

### Step 1.5: Initialize Variables

**+ New step** → **Initialize variable**

Create these variables (add multiple "Initialize variable" actions):

**1. varEmployeeName**
```
Name: varEmployeeName
Type: String
Value: (dynamic) Employee -> Full Name
```

**2. varEmployeeEmail**
```
Name: varEmployeeEmail
Type: String
Value: (dynamic) Employee Email
```

**3. varStartDate**
```
Name: varStartDate
Type: String
Value: (dynamic) Start Date
```

**4. varEndDate**
```
Name: varEndDate
Type: String
Value: (dynamic) End Date
```

**5. varRequestType**
```
Name: varRequestType
Type: String
Value: (dynamic) Request Type
```

**6. varComments**
```
Name: varComments
Type: String
Value: (dynamic) Comments
```

**7. varManagerEmail**
```
Name: varManagerEmail
Type: String
Value: (from List rows) Manager Email
Expression: outputs('List_rows')?['body/value'][0]['ooooo_manageremail']
```

**8. varRequestID**
```
Name: varRequestID
Type: String
Value: (dynamic) Request ID
```

### Step 1.6: Create Approval History - Submitted

**+ New step** → **Add a new row** (Dataverse)

Configure:
- Table name: `Approval Histories`
- Fields:
  - History ID: `HIST-@{utcNow('yyyyMMddHHmmss')}-SUBMITTED`
  - Employee: (dynamic) Employee
  - Request Start Date: (variable) varStartDate
  - Request End Date: (variable) varEndDate
  - Request Type: (dynamic) Request Type
  - Action: `Submitted`
  - Action Date/Time: (expression) `utcNow()`
  - Actor: (dynamic) Employee
  - Actor Comments: `Request submitted for approval`

### Step 1.7: Start and Wait for Approval

**+ New step** → Search: **Approvals**

Action: **Start and wait for an approval (V2)**

Configure:
- Approval type: `Approve/Reject - First to respond`
- Title:
  ```
  Time Off Request from @{variables('varEmployeeName')}
  ```
- Assigned to: `@{variables('varManagerEmail')}`
- Details:
  ```markdown
  ## Time Off Request

  **Employee**: @{variables('varEmployeeName')}
  **Request Type**: @{variables('varRequestType')}
  **Start Date**: @{formatDateTime(variables('varStartDate'), 'dddd, MMMM dd, yyyy')}
  **End Date**: @{formatDateTime(variables('varEndDate'), 'dddd, MMMM dd, yyyy')}
  **Submitted**: @{formatDateTime(triggerOutputs()?['body/ooooo_submissiondatetime'], 'g')}

  ### Employee Comments:
  @{if(empty(variables('varComments')), 'No comments provided', variables('varComments'))}

  ---
  Please review and approve or reject this request.
  ```
- Item link: Leave blank (or link to SharePoint if desired)
- Item link description: `View Request Details`

### Step 1.8: Condition - Check Outcome

**+ New step** → **Condition**

Name: `Check Approval Outcome`

Condition:
- Choose value: `Outcome` (from Start and wait for approval)
- Operator: `is equal to`
- Value: `Approve`

### Step 1.9: If Approved - Update Request

In **Yes** branch:

**Action**: **Update a row** (Dataverse)
- Table name: `Staff Schedules`
- Row ID: (dynamic) Staff Schedule (unique identifier from trigger)
- Fields:
  - Status: `OOO-Approved`
  - Approver: (dynamic) Responses Approver (from approval)
  - Approval Date/Time: (expression) `utcNow()`
  - Manager Comments: (dynamic) Responses Comments
  - Approval Request ID: (dynamic) Name (from approval action)

### Step 1.10: If Approved - Create Calendar Event

**+ Add an action** → Search: **Office 365 Outlook**

Action: **Create event (V4)**

Configure:
- Calendar id: `Calendar`
- Subject:
  ```
  OOO - @{variables('varEmployeeName')} (@{variables('varRequestType')})
  ```
- Start time: (variable) varStartDate
- End time:
  ```
  @{addDays(variables('varEndDate'), 1)}
  ```
- Time zone: `Central Standard Time`
- Show as: `Out of Office`
- Is all day event: `Yes`
- Required attendees: (variable) varEmployeeEmail
- Body:
  ```html
  <p><strong>Out of Office</strong></p>
  <p>Type: @{variables('varRequestType')}</p>
  <p>Approved by: @{outputs('Start_and_wait_for_an_approval_(V2)')?['body/responses'][0]['approverName']}</p>
  ```

### Step 1.11: If Approved - Send Notification

**+ Add an action** → Search: **Microsoft Teams**

Action: **Post message in a chat or channel**

Configure:
- Post as: `Flow bot`
- Post in: `Chat with Flow bot`
- Recipient: (variable) varEmployeeEmail
- Message:
  ```markdown
  ## ✅ Time Off Request Approved

  Your time off request has been **approved**.

  **Request Details:**
  - **Type**: @{variables('varRequestType')}
  - **Dates**: @{formatDateTime(variables('varStartDate'), 'MMM dd')} - @{formatDateTime(variables('varEndDate'), 'MMM dd, yyyy')}

  **Manager Comments:**
  @{if(empty(outputs('Start_and_wait_for_an_approval_(V2)')?['body/responses'][0]['comments']), 'No comments', outputs('Start_and_wait_for_an_approval_(V2)')?['body/responses'][0]['comments'])}

  Your time off has been added to your Outlook calendar.
  ```

### Step 1.12: If Approved - Create History Record

**+ Add an action** → **Add a new row** (Dataverse)

- Table name: `Approval Histories`
- Fields:
  - History ID: `HIST-@{utcNow('yyyyMMddHHmmss')}-APPROVED`
  - Employee: (dynamic) Employee from trigger
  - Request Start Date: (variable) varStartDate
  - Request End Date: (variable) varEndDate
  - Request Type: (dynamic) Request Type
  - Action: `Approved`
  - Action Date/Time: (expression) `utcNow()`
  - Actor: (dynamic) Approver from approval
  - Actor Comments: (dynamic) Comments from approval

### Step 1.13: If Rejected - Update Request

In **No** branch (rejected):

**Action**: **Update a row** (Dataverse)
- Table name: `Staff Schedules`
- Row ID: (dynamic) Staff Schedule unique identifier
- Fields:
  - Status: `OOO-Rejected`
  - Approver: (dynamic) Approver
  - Approval Date/Time: (expression) `utcNow()`
  - Manager Comments: (dynamic) Comments

### Step 1.14: If Rejected - Send Notification

**+ Add an action** → **Post message in a chat or channel** (Teams)

Configure:
- Recipient: (variable) varEmployeeEmail
- Message:
  ```markdown
  ## ❌ Time Off Request Not Approved

  Your time off request was **not approved**.

  **Request Details:**
  - **Type**: @{variables('varRequestType')}
  - **Dates**: @{formatDateTime(variables('varStartDate'), 'MMM dd')} - @{formatDateTime(variables('varEndDate'), 'MMM dd, yyyy')}

  **Manager Comments:**
  @{outputs('Start_and_wait_for_an_approval_(V2)')?['body/responses'][0]['comments']}

  Please contact your manager if you have questions.
  ```

### Step 1.15: If Rejected - Create History

**+ Add an action** → **Add a new row** (Dataverse)

- Table name: `Approval Histories`
- Fields: (similar to approved, but Action = "Rejected")

### Step 1.16: Save Flow

1. Click **Save** (top right)
2. Wait for save
3. Click **Test** → **Manually**
4. Create test request in app
5. Verify flow runs successfully

✅ **Checkpoint**: Approval flow complete!

---

## Flow 2: Calendar Sync Flow (25 minutes)

### Purpose
Syncs approved OOO to Outlook calendar.

### Step 2.1: Create Flow

1. In solution, click **+ New** → **Cloud flow** → **Automated**
2. Name: `OOOOO - Calendar Sync`
3. Trigger: **When a row is added, modified or deleted** (Dataverse)
4. Configure trigger:
   - Change type: `Modified`
   - Table name: `Staff Schedules`
   - Scope: `Organization`
   - Select columns: `ooooo_status,ooooo_calendareventid`

### Step 2.2: Add Condition

**Condition**: Status changed to OOO-Approved AND no calendar event exists

```
@and(equals(triggerOutputs()?['body/ooooo_status'], 4), empty(triggerOutputs()?['body/ooooo_calendareventid']))
```

### Step 2.3: If Yes - Create Calendar Event

Use same Outlook action as Flow 1

Then:

**Update a row** (Dataverse):
- Table: Staff Schedules
- Row ID: (trigger) Unique identifier
- Calendar Event ID: (dynamic) Id from Create event

✅ **Checkpoint**: Calendar sync flow complete!

---

## Flow 3: Daily Reminder Flow (25 minutes)

### Purpose
Send daily reminders to update status (optional).

### Step 3.1: Create Flow

1. **+ New** → **Cloud flow** → **Scheduled**
2. Name: `OOOOO - Daily Reminder`
3. Configure recurrence:
   - Frequency: `Day`
   - Interval: `1`
   - At these hours: `8`
   - At these minutes: `0`
   - Time zone: `Central Standard Time`

### Step 3.2: Get Active Users

**+ New step** → **List rows** (Dataverse)

- Table name: `User Profiles`
- Filter rows: `ooooo_isactive eq true`

### Step 3.3: Loop Through Users

**+ New step** → **Apply to each**

- Select output: (dynamic) value (from List rows)

Inside loop:

**Post message in a chat or channel** (Teams):
- Recipient: `@{items('Apply_to_each')?['ooooo_email']}`
- Message:
  ```
  Good morning! 👋

  Don't forget to update your status in the OOOOO Calendar app:
  - Are you working Onsite or Offsite today?
  - Any upcoming time off to request?

  Open the app: [OOOOO Calendar in Teams]
  ```

### Step 3.4: Save and Test

1. **Save**
2. **Test** → **Manually**
3. Verify reminders sent

✅ **Checkpoint**: All 3 flows complete!

---

## Add Flows to Solution

Flows should already be in solution if created from within it.

Verify:
1. Navigate to **Solutions** → **OOOOO Calendar**
2. Click **Cloud flows**
3. See all 3 flows

---

## Testing All Flows

### Test 1: End-to-End Approval
1. Submit OOO request in app
2. Verify approval sent to manager (check Teams)
3. Approve request
4. Verify status updated
5. Verify calendar event created
6. Verify notification sent

### Test 2: Calendar Sync
1. Manually update status to OOO-Approved
2. Verify calendar event created
3. Check Outlook calendar

### Test 3: Daily Reminder
1. Manually run flow
2. Verify Teams messages sent

---

## Troubleshooting

### Flow not triggering
- Check trigger configuration
- Verify table name correct
- Check permissions

### Approval not sending
- Verify manager email correct in User Profiles
- Check Approvals connector connection
- Test with your own email first

### Calendar event not creating
- Verify Outlook connector connected
- Check user has Outlook license
- Test with your calendar first

---

## Next Steps

1. ✅ All 3 flows created and tested
2. ✅ Ready to export solution
3. See `solution-builder-guide.md` Phase 7 for export

---

**Flow Builder Version**: 1.0.0
**Last Updated**: November 2025
**Total Build Time**: ~90 minutes
