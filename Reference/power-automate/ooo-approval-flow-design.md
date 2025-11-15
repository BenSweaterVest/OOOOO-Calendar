# OOO Approval Flow - Design Specification

## Flow Overview

**Flow Name**: OOOOO-ApprovalWorkflow
**Trigger**: When an item is created or modified in StaffSchedule list
**Purpose**: Handle time-off request approvals via Microsoft Teams
**License Required**: Power Automate (included with M365)

---

## Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TRIGGER                                  │
│  When item created/modified in StaffSchedule               │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│               CONDITION: Check Status                       │
│  Is Status = "OOO-Pending"?                                │
└────────────┬────────────────────┬───────────────────────────┘
             │ YES                │ NO
             ▼                    ▼
      ┌──────────────┐    ┌──────────────┐
      │  Continue    │    │  Terminate   │
      │  Flow        │    │  Flow        │
      └──────┬───────┘    └──────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│         Get Employee's Manager Info                         │
│  Lookup manager from UserProfiles list                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│         Create Approval History Record                      │
│  Action: "Submitted"                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│    Start and wait for approval (Teams)                      │
│  Send approval request to manager                           │
│  Wait for manager response                                  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│           CONDITION: Approval Outcome                       │
│  Was request approved or rejected?                          │
└────────┬────────────────────────────┬───────────────────────┘
         │ APPROVED                   │ REJECTED
         ▼                            ▼
┌────────────────────┐       ┌────────────────────┐
│  Update Status to  │       │  Update Status to  │
│  "OOO-Approved"    │       │  "OOO-Rejected"    │
└────────┬───────────┘       └────────┬───────────┘
         │                            │
         ▼                            ▼
┌────────────────────┐       ┌────────────────────┐
│  Create Calendar   │       │  Send Rejection    │
│  Event (Outlook)   │       │  Notification      │
└────────┬───────────┘       └────────┬───────────┘
         │                            │
         ▼                            ▼
┌────────────────────┐       ┌────────────────────┐
│  Send Approval     │       │  Create Approval   │
│  Notification      │       │  History (Reject)  │
└────────┬───────────┘       └────────────────────┘
         │
         ▼
┌────────────────────┐
│  Create Approval   │
│  History (Approve) │
└────────────────────┘
```

---

## Detailed Flow Steps

### 1. Trigger: When an item is created or modified

**Action**: SharePoint trigger
**Configuration**:
- Site Address: `[Your SharePoint Site URL]`
- List Name: `StaffSchedule`

### 2. Condition: Check if Status is OOO-Pending

**Action**: Condition
**Formula**:
```
@equals(triggerOutputs()?['body/Status/Value'], 'OOO-Pending')
```

**If NO**: Terminate flow
**If YES**: Continue to next step

### 3. Get Manager Information

**Action**: Get items (SharePoint)
**Configuration**:
- Site Address: `[Your SharePoint Site URL]`
- List Name: `UserProfiles`
- Filter Query:
  ```
  Title eq '@{triggerOutputs()?['body/EmployeeEmail']}'
  ```

**Output**: `ManagerEmail`, `ManagerName`

### 4. Initialize Variables

**Variables to Create**:

```
varEmployeeName     = @{triggerOutputs()?['body/EmployeeName/DisplayName']}
varEmployeeEmail    = @{triggerOutputs()?['body/EmployeeEmail']}
varStartDate        = @{triggerOutputs()?['body/StartDate']}
varEndDate          = @{triggerOutputs()?['body/EndDate']}
varRequestType      = @{triggerOutputs()?['body/RequestType/Value']}
varComments         = @{triggerOutputs()?['body/Comments']}
varRequestID        = @{triggerOutputs()?['body/Title']}
varItemID           = @{triggerOutputs()?['body/ID']}
varManagerEmail     = @{body('Get_Manager_Info')?['value'][0]['ManagerEmail']}
varManagerName      = @{body('Get_Manager_Info')?['value'][0]['Manager/DisplayName']}
varSubmissionDate   = @{triggerOutputs()?['body/SubmissionDateTime']}
```

### 5. Calculate Number of Days

**Action**: Compose
**Expression**:
```
div(
    sub(
        ticks(variables('varEndDate')),
        ticks(variables('varStartDate'))
    ),
    864000000000
)
add(1)
```
**Output**: `varNumberOfDays`

### 6. Create Approval History - Submitted

**Action**: Create item (SharePoint)
**List**: `ApprovalHistory`
**Fields**:
```json
{
  "Title": "HIST-@{utcNow('yyyyMMdd-HHmmss')}",
  "RequestID": "@{variables('varRequestID')}",
  "EmployeeName": "@{variables('varEmployeeName')}",
  "RequestStartDate": "@{variables('varStartDate')}",
  "RequestEndDate": "@{variables('varEndDate')}",
  "RequestType": "@{variables('varRequestType')}",
  "Action": "Submitted",
  "ActionDateTime": "@{utcNow()}",
  "ActorName": "@{variables('varEmployeeName')}",
  "ActorComments": "Request submitted for approval",
  "OriginalRequestDetails": "@{triggerOutputs()?['body']}"
}
```

### 7. Start and wait for an approval (Teams)

**Action**: Start and wait for an approval (V2)
**Approval type**: Approve/Reject - First to respond
**Configuration**:

**Title**:
```
Time Off Request from @{variables('varEmployeeName')}
```

**Assigned to**:
```
@{variables('varManagerEmail')}
```

**Details**:
```markdown
## Time Off Request

**Employee**: @{variables('varEmployeeName')}
**Request Type**: @{variables('varRequestType')}
**Start Date**: @{formatDateTime(variables('varStartDate'), 'dddd, MMMM dd, yyyy')}
**End Date**: @{formatDateTime(variables('varEndDate'), 'dddd, MMMM dd, yyyy')}
**Total Days**: @{variables('varNumberOfDays')}
**Submitted**: @{formatDateTime(variables('varSubmissionDate'), 'g')}

### Employee Comments:
@{if(empty(variables('varComments')), 'No comments provided', variables('varComments'))}

---
Please review and approve or reject this request.
```

**Item Link**:
```
[Your SharePoint Site]/Lists/StaffSchedule/DispForm.aspx?ID=@{variables('varItemID')}
```

**Item Link Description**: "View Request Details"

### 8. Condition: Check Approval Outcome

**Condition**:
```
@equals(body('Start_and_wait_for_an_approval')?['outcome'], 'Approve')
```

---

## Branch A: Request APPROVED

### A1. Update StaffSchedule Item - Approved

**Action**: Update item (SharePoint)
**List**: `StaffSchedule`
**ID**: `@{variables('varItemID')}`
**Fields**:
```json
{
  "Status": "OOO-Approved",
  "ApprovedBy": "@{variables('varManagerEmail')}",
  "ApprovalDateTime": "@{utcNow()}",
  "ManagerComments": "@{body('Start_and_wait_for_an_approval')?['responses'][0]['comments']}",
  "ApprovalRequestId": "@{body('Start_and_wait_for_an_approval')?['name']}"
}
```

### A2. Create Outlook Calendar Event

**Action**: Create event (V4) - Outlook
**Configuration**:

**Calendar id**: `Calendar`
**Subject**:
```
OOO - @{variables('varEmployeeName')} (@{variables('varRequestType')})
```

**Start time**:
```
@{variables('varStartDate')}
```

**End time**:
```
@{addDays(variables('varEndDate'), 1)}
```

**Time zone**: `Central Standard Time`
**Show as**: `Out of Office`
**Is all day event**: `Yes`
**Required attendees**:
```
@{variables('varEmployeeEmail')}
```

**Body**:
```html
<p><strong>Out of Office</strong></p>
<p>Type: @{variables('varRequestType')}</p>
<p>Approved by: @{variables('varManagerName')}</p>
<p>Comments: @{body('Start_and_wait_for_an_approval')?['responses'][0]['comments']}</p>
```

**Save Calendar Event ID**:
Store `body('Create_event')?['id']` back to StaffSchedule item in `CalendarEventId` field

### A3. Send Approval Notification (Teams)

**Action**: Post message in a chat or channel (Teams)
**Recipient**: `@{variables('varEmployeeEmail')}`
**Message**:
```markdown
## ✅ Time Off Request Approved

Your time off request has been **approved** by @{variables('varManagerName')}.

**Request Details:**
- **Type**: @{variables('varRequestType')}
- **Dates**: @{formatDateTime(variables('varStartDate'), 'MMM dd')} - @{formatDateTime(variables('varEndDate'), 'MMM dd, yyyy')}
- **Days**: @{variables('varNumberOfDays')}

**Manager Comments:**
@{if(empty(body('Start_and_wait_for_an_approval')?['responses'][0]['comments']), 'No comments', body('Start_and_wait_for_an_approval')?['responses'][0]['comments'])}

Your time off has been added to your Outlook calendar.
```

### A4. Create Approval History - Approved

**Action**: Create item (SharePoint)
**List**: `ApprovalHistory`
**Fields**:
```json
{
  "Title": "HIST-@{utcNow('yyyyMMdd-HHmmss')}-APPROVED",
  "RequestID": "@{variables('varRequestID')}",
  "EmployeeName": "@{variables('varEmployeeName')}",
  "RequestStartDate": "@{variables('varStartDate')}",
  "RequestEndDate": "@{variables('varEndDate')}",
  "RequestType": "@{variables('varRequestType')}",
  "Action": "Approved",
  "ActionDateTime": "@{utcNow()}",
  "ActorName": "@{variables('varManagerName')}",
  "ActorComments": "@{body('Start_and_wait_for_an_approval')?['responses'][0]['comments']}",
  "ApprovalDuration": "@{div(sub(ticks(utcNow()), ticks(variables('varSubmissionDate'))), 36000000000)}"
}
```

---

## Branch B: Request REJECTED

### B1. Update StaffSchedule Item - Rejected

**Action**: Update item (SharePoint)
**List**: `StaffSchedule`
**ID**: `@{variables('varItemID')}`
**Fields**:
```json
{
  "Status": "OOO-Rejected",
  "ApprovedBy": "@{variables('varManagerEmail')}",
  "ApprovalDateTime": "@{utcNow()}",
  "ManagerComments": "@{body('Start_and_wait_for_an_approval')?['responses'][0]['comments']}",
  "ApprovalRequestId": "@{body('Start_and_wait_for_an_approval')?['name']}"
}
```

### B2. Send Rejection Notification (Teams)

**Action**: Post message in a chat or channel (Teams)
**Recipient**: `@{variables('varEmployeeEmail')}`
**Message**:
```markdown
## ❌ Time Off Request Not Approved

Your time off request was **not approved** by @{variables('varManagerName')}.

**Request Details:**
- **Type**: @{variables('varRequestType')}
- **Dates**: @{formatDateTime(variables('varStartDate'), 'MMM dd')} - @{formatDateTime(variables('varEndDate'), 'MMM dd, yyyy')}
- **Days**: @{variables('varNumberOfDays')}

**Manager Comments:**
@{body('Start_and_wait_for_an_approval')?['responses'][0]['comments']}

Please contact your manager if you have questions about this decision.
```

### B3. Create Approval History - Rejected

**Action**: Create item (SharePoint)
**List**: `ApprovalHistory`
**Fields**:
```json
{
  "Title": "HIST-@{utcNow('yyyyMMdd-HHmmss')}-REJECTED",
  "RequestID": "@{variables('varRequestID')}",
  "EmployeeName": "@{variables('varEmployeeName')}",
  "RequestStartDate": "@{variables('varStartDate')}",
  "RequestEndDate": "@{variables('varEndDate')}",
  "RequestType": "@{variables('varRequestType')}",
  "Action": "Rejected",
  "ActionDateTime": "@{utcNow()}",
  "ActorName": "@{variables('varManagerName')}",
  "ActorComments": "@{body('Start_and_wait_for_an_approval')?['responses'][0]['comments']}",
  "ApprovalDuration": "@{div(sub(ticks(utcNow()), ticks(variables('varSubmissionDate'))), 36000000000)}"
}
```

---

## Error Handling

### Add Scope Actions

Wrap main flow logic in a **Scope** action named "Try"

### Configure Run After

Add a **Scope** action named "Catch" that runs after "Try" **has failed, is skipped, or has timed out**

### Error Notification

In "Catch" scope, send error notification:

**Action**: Send an email (V2)
**To**: Admin email or manager email
**Subject**: `Error in OOO Approval Flow - @{variables('varRequestID')}`
**Body**:
```html
<p><strong>An error occurred processing an OOO request</strong></p>
<p><strong>Request ID:</strong> @{variables('varRequestID')}</p>
<p><strong>Employee:</strong> @{variables('varEmployeeName')}</p>
<p><strong>Error:</strong></p>
<pre>@{body('Try')}</pre>
<p>Please check the flow run history for details.</p>
```

---

## Flow Settings

### General Settings
- **Flow Name**: OOOOO-ApprovalWorkflow
- **Description**: Handles time-off request approvals via Microsoft Teams
- **Run only users' context**: No (run as flow owner)

### Timeout Settings
- **Approval timeout**: 7 days
- **Timeout action**: Cancel approval and notify admin

### Concurrency Control
- **Concurrency Control**: On
- **Degree of Parallelism**: 25

---

## Testing Checklist

- [ ] Test with single-day OOO request
- [ ] Test with multi-day OOO request
- [ ] Test approval path (manager approves)
- [ ] Test rejection path (manager rejects)
- [ ] Verify Teams notification received
- [ ] Verify Outlook calendar event created (approved only)
- [ ] Verify SharePoint item updated correctly
- [ ] Verify approval history recorded
- [ ] Test error handling (invalid data)
- [ ] Test timeout scenario (no response after 7 days)
- [ ] Test with multiple concurrent requests

---

## Deployment Steps

1. **Create flow in Power Automate**
2. **Configure SharePoint connections**
3. **Configure Teams connections**
4. **Configure Outlook connections**
5. **Update site URL references**
6. **Test with sample data**
7. **Enable flow**
8. **Monitor first few approvals**
9. **Document any issues**

---

## Monitoring & Maintenance

### Key Metrics to Track
- Average approval time
- Approval success rate
- Flow failure rate
- Notification delivery rate

### Regular Maintenance
- Review error logs weekly
- Check for timeout approvals
- Verify calendar sync working
- Update flow as needed

---

## Additional Flows

See also:
- `calendar-sync-flow-design.md` - Outlook calendar synchronization
- `notification-flow-design.md` - Daily reminders and notifications
- `status-update-flow-design.md` - Regular schedule update handling

