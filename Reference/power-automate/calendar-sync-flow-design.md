# Calendar Sync Flow - Design Specification

## Flow Overview

**Flow Name**: OOOOO - Calendar Sync
**Trigger**: When a row is modified (Dataverse)
**Purpose**: Automatically sync approved time-off requests to Outlook calendar
**License Required**: Power Automate (included with M365)

---

## Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TRIGGER                                  │
│  When a row is modified (Dataverse)                        │
│  Table: Staff Schedule                                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│           CONDITION: Check Status Change                    │
│  Status changed to "OOO-Approved"?                         │
└────────┬────────────────────────────┬───────────────────────┘
         │ YES                        │ NO
         ▼                            ▼
  ┌──────────────┐            ┌──────────────┐
  │  Continue    │            │  Terminate   │
  │  Flow        │            │  Flow        │
  └──────┬───────┘            └──────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│         CONDITION: Event Not Already Created                │
│  Calendar Event ID is blank?                               │
└────────┬────────────────────────────┬───────────────────────┘
         │ YES                        │ NO
         ▼                            ▼
  ┌──────────────┐            ┌──────────────┐
  │  Continue    │            │  Update      │
  │  Flow        │            │  Existing    │
  └──────┬───────┘            └──────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│         Get System Settings                                 │
│  Check if SyncToOutlookCalendar is enabled                 │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│           CONDITION: Sync Enabled?                          │
│  SyncToOutlookCalendar = "true"?                           │
└────────┬────────────────────────────┬───────────────────────┘
         │ YES                        │ NO
         ▼                            ▼
  ┌──────────────┐            ┌──────────────┐
  │  Continue    │            │  Terminate   │
  │  Flow        │            │  Flow        │
  └──────┬───────┘            └──────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│         Create Calendar Event (Outlook)                     │
│  Create all-day event with details                         │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│         Update Staff Schedule Record                        │
│  Store Calendar Event ID for future reference              │
└─────────────────────────────────────────────────────────────┘
```

---

## Detailed Flow Steps

### 1. Trigger: When a row is modified

**Connector**: Microsoft Dataverse
**Action**: When a row is added, modified or deleted
**Configuration**:
- **Change type**: Modified
- **Table name**: Staff Schedules
- **Scope**: Organization

**Filter Rows** (Advanced):
```
Microsoft.Dynamics.CRM.In(PropertyName='ooooo_status',PropertyValues=['4'])
```
(This filters for status value 4 = "OOO-Approved")

---

### 2. Condition: Check Status is OOO-Approved

**Action**: Condition
**Formula**:
```
@equals(triggerOutputs()?['body/ooooo_status'], 4)
```

**If No**: Terminate flow

**If Yes**: Continue to next step

---

### 3. Condition: Check Calendar Event ID is blank

**Action**: Condition
**Purpose**: Prevent duplicate calendar entries
**Formula**:
```
@empty(triggerOutputs()?['body/ooooo_calendareventid'])
```

**If No**:
- Optional: Update existing event (advanced scenario)
- Or: Terminate flow (simpler approach)

**If Yes**: Continue to next step

---

### 4. Get System Settings for Calendar Sync

**Connector**: Microsoft Dataverse
**Action**: List rows
**Configuration**:
- **Table name**: System Settings
- **Filter rows**: `ooooo_settingname eq 'SyncToOutlookCalendar'`
- **Row count**: 1

**Output**: Store in variable `varSyncEnabled`

---

### 5. Condition: Check if Sync is Enabled

**Action**: Condition
**Formula**:
```
@equals(first(outputs('Get_System_Settings')?['body/value'])?['ooooo_settingvalue'], 'true')
```

**If No**: Terminate flow (sync is disabled)

**If Yes**: Continue to create calendar event

---

### 6. Initialize Variables (Setup)

**Action**: Initialize variable
Create these variables:

**Variable 1: varEmployeeEmail**
- **Type**: String
- **Value**: `@triggerOutputs()?['body/ooooo_employeeemail']`

**Variable 2: varSubject**
- **Type**: String
- **Value**: `OOO - @{triggerOutputs()?['body/ooooo_requesttype@OData.Community.Display.V1.FormattedValue']}`

**Variable 3: varStartDate**
- **Type**: String
- **Value**: `@triggerOutputs()?['body/ooooo_startdate']`

**Variable 4: varEndDate**
- **Type**: String
- **Value**:
```
@if(
  empty(triggerOutputs()?['body/ooooo_enddate']),
  triggerOutputs()?['body/ooooo_startdate'],
  triggerOutputs()?['body/ooooo_enddate']
)
```

**Variable 5: varBody**
- **Type**: String
- **Value**:
```
Request Type: @{triggerOutputs()?['body/ooooo_requesttype@OData.Community.Display.V1.FormattedValue']}
Duration: @{triggerOutputs()?['body/ooooo_numberofdays']} day(s)
Comments: @{triggerOutputs()?['body/ooooo_comments']}

Approved by: @{triggerOutputs()?['body/_ooooo_approver_value@OData.Community.Display.V1.FormattedValue']}
Request ID: @{triggerOutputs()?['body/ooooo_requestid']}
```

---

### 7. Create Calendar Event

**Connector**: Office 365 Outlook
**Action**: Create event (V4)
**Configuration**:

**Calendar id**: Calendar
**Subject**: `@{variables('varSubject')}`
**Start time**: `@{variables('varStartDate')}`
**End time**:
```
@{addDays(variables('varEndDate'), 1)}
```
(Add 1 day because end dates are exclusive)

**Time zone**: `UTC`
**Is all day event**: Yes
**Body**: `@{variables('varBody')}`
**Location**: (leave blank or "Out of Office")
**Required attendees**: `@{variables('varEmployeeEmail')}`
**Show as**: `Out of Office`
**Sensitivity**: `Normal`

**Advanced Options**:
- **Categories**: `Time Off, OOO`
- **Reminder**: `15 minutes before`

---

### 8. Update Staff Schedule with Event ID

**Connector**: Microsoft Dataverse
**Action**: Update a row
**Configuration**:

- **Table name**: Staff Schedules
- **Row ID**: `@triggerOutputs()?['body/ooooo_staffscheduleid']`
- **Calendar Event ID**: `@{outputs('Create_event_(V4)')?['body/id']}`

This stores the Outlook event ID so we can reference or update it later.

---

## Error Handling

### Add Try-Catch Scope

Wrap steps 6-8 in a **Scope** action for error handling:

**Scope Name**: `Try - Create Calendar Event`

**Configure run after**:
- Add parallel action: **Scope** named `Catch - Handle Error`
- Configure to run after "Try" scope: **has failed** or **has timed out**

**In Catch Scope**:

1. **Compose Error Details**:
```json
{
  "RequestID": "@{triggerOutputs()?['body/ooooo_requestid']}",
  "Employee": "@{triggerOutputs()?['body/ooooo_employeeemail']}",
  "Error": "@{result('Try_-_Create_Calendar_Event')}",
  "Timestamp": "@{utcNow()}"
}
```

2. **Send email to admin** (optional):
   - **To**: admin@yourdomain.com
   - **Subject**: `[OOOOO Calendar] Calendar Sync Failed`
   - **Body**: `@{outputs('Compose_Error_Details')}`

3. **Add note to Staff Schedule** (optional):
   - Update the Comments field with error notification

---

## Flow Settings

### General Settings

- **Display Name**: OOOOO - Calendar Sync
- **Description**: Automatically syncs approved OOO requests to employee's Outlook calendar
- **Environment**: Production

### Connections

Ensure these connections are configured:
- ✅ **Microsoft Dataverse** (System or User connection)
- ✅ **Office 365 Outlook** (User connection - uses employee's mailbox)

### Run Settings

- **Timeout**: 2 minutes
- **Retry Policy**: Default (exponential backoff, 4 retries)
- **Concurrency**: Single instance (to prevent duplicate events)

---

## Testing the Flow

### Test Scenario 1: New Approval

1. Navigate to Staff Schedule table in Dataverse
2. Find a record with Status = "OOO-Pending"
3. Change Status to "OOO-Approved"
4. Save the record
5. **Expected Result**:
   - Flow triggers within 1-2 minutes
   - Calendar event appears in employee's Outlook calendar
   - Staff Schedule record updated with Calendar Event ID

### Test Scenario 2: Sync Disabled

1. Update System Settings: `SyncToOutlookCalendar = false`
2. Approve a time-off request
3. **Expected Result**:
   - Flow triggers but terminates at sync check
   - No calendar event created

### Test Scenario 3: Duplicate Prevention

1. Manually add a Calendar Event ID to a Staff Schedule record
2. Change status to OOO-Approved
3. **Expected Result**:
   - Flow terminates (event already exists)
   - No duplicate calendar entry

---

## Troubleshooting

### Issue: Calendar event not created

**Possible Causes**:
1. **Outlook connection not authenticated**
   - Fix: Reconnect Office 365 Outlook in flow connections

2. **SyncToOutlookCalendar setting is false**
   - Fix: Update System Settings to enable sync

3. **Employee email is invalid**
   - Fix: Verify email addresses in User Profile table

4. **Calendar Event ID already populated**
   - Fix: This is by design to prevent duplicates

### Issue: Event created with wrong dates

**Possible Causes**:
1. **Time zone mismatch**
   - Fix: Ensure all dates use consistent time zone (UTC recommended)

2. **End date calculation off by one day**
   - Fix: Outlook all-day events use exclusive end dates, so add 1 day

### Issue: Flow runs but doesn't create event

**Debugging Steps**:
1. Check flow run history
2. Review "Create event" action outputs
3. Verify Outlook connector permissions
4. Check if employee has Outlook license

---

## Advanced Enhancements

### Enhancement 1: Update Existing Events

If calendar sync is updated after initial approval:

```
Condition: Calendar Event ID exists
  If Yes:
    - Office 365 Outlook: Update event (V3)
    - Use stored Calendar Event ID
    - Update only changed fields
```

### Enhancement 2: Delete Events on Rejection/Cancellation

Add companion flow for cancellations:

**Trigger**: When Status changes to "OOO-Rejected" or "Cancelled"
**Action**:
- Check if Calendar Event ID exists
- Delete event from Outlook
- Clear Calendar Event ID field

### Enhancement 3: Recurring Events

For multi-day requests:
- Consider creating single all-day event spanning dates
- Or create individual daily events (increases complexity)

### Enhancement 4: Multiple Calendars

Allow users to choose calendar:
- Add Calendar Name column to User Profile
- Use dynamic calendar ID in Create Event action

---

## Integration with Other Flows

### Approval Workflow Integration

The **OOO Approval Workflow** sets status to "OOO-Approved", which triggers this flow automatically.

**Data Flow**:
```
User submits request
  → Approval Workflow runs
    → Manager approves
      → Status = "OOO-Approved"
        → Calendar Sync Flow triggers
          → Event created in Outlook
```

### Daily Reminder Integration

The **Daily Reminder** flow can check Calendar Event ID to verify sync status.

---

## Performance Considerations

### Optimization Tips

1. **Use Filter Rows on Trigger**
   - Filter for Status = 4 (OOO-Approved) at trigger level
   - Reduces unnecessary flow runs

2. **Minimize Dataverse Calls**
   - Get System Settings once, cache in variable
   - Batch updates where possible

3. **Set Appropriate Timeout**
   - Calendar creation typically completes in <10 seconds
   - 2-minute timeout is safe for reliability

### Expected Volume

For team of 11+ users:
- Estimated OOO requests: 2-5 per week
- Flow runs: ~10-25 per month
- Well within Power Automate free tier limits

---

## Security & Permissions

### Required Permissions

**Flow Owner**:
- Write access to Staff Schedule table
- Access to System Settings table
- Office 365 Outlook delegated permissions

**Impersonation**:
- Flow runs as flow owner
- Creates calendar events on behalf of employees
- Requires delegated calendar permissions or shared mailbox setup

### Best Practices

1. **Use Service Account** (recommended for production):
   - Create dedicated service account
   - Grant calendar delegate permissions for all users
   - Flow runs as service account

2. **Use User's Own Connection** (simpler for small teams):
   - Each user authenticates their own Outlook
   - Flow creates events in their own calendar
   - No delegation needed

---

## Monitoring & Maintenance

### What to Monitor

1. **Flow run success rate**
   - Target: >95% success
   - Check weekly in first month

2. **Calendar sync accuracy**
   - Spot-check random approvals
   - Verify events appear correctly

3. **Error notifications**
   - Review error emails (if configured)
   - Address permission issues promptly

### Maintenance Tasks

**Weekly** (first month):
- Review flow run history
- Check for failed runs
- Verify calendar entries

**Monthly** (ongoing):
- Review error patterns
- Update flow if Dataverse/Outlook APIs change
- Optimize based on usage patterns

---

## Version History

- **v1.0** - Initial calendar sync implementation
- **Future**: Event updates, cancellation handling, multiple calendars

---

## Related Documentation

- **Approval Workflow**: `ooo-approval-flow-design.md`
- **Daily Reminder**: `daily-reminder-flow-design.md`
- **Table Schema**: `../dataverse-tables-schema.json`
- **Installation Guide**: `../../INSTALLATION.md`

---

**Status**: Production Ready
**Last Updated**: November 2025
**Maintainer**: OOOOO Calendar Team
