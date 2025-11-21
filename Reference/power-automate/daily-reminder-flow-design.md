# Daily Reminder Flow - Design Specification

## Flow Overview

**Flow Name**: OOOOO - Daily Reminder
**Trigger**: Recurrence (Daily)
**Purpose**: Send daily morning reminders to staff to update their work location status
**License Required**: Power Automate (included with M365)
**Status**: Optional (but recommended for engagement)

---

## Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TRIGGER                                  │
│  Recurrence: Daily at configured time                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│         Get System Settings                                 │
│  Check EnableDailyReminders and ReminderTime               │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│           CONDITION: Reminders Enabled?                     │
│  EnableDailyReminders = "true"?                            │
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
│           CONDITION: Is Weekday?                            │
│  Today is Monday-Friday?                                   │
└────────┬────────────────────────────┬───────────────────────┘
         │ YES                        │ NO
         ▼                            ▼
  ┌──────────────┐            ┌──────────────┐
  │  Continue    │            │  Terminate   │
  │  Flow        │            │  (Weekend)   │
  └──────┬───────┘            └──────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│         Get Active Users                                    │
│  Query User Profiles where IsActive = true                 │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│         Apply to Each User                                  │
│  Loop through each active user                             │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
       ┌─────────────────────────┐
       │  Check User's Status    │
       │  for Today              │
       └─────────┬───────────────┘
                 │
                 ▼
       ┌─────────────────────────┐
       │  Post Adaptive Card     │
       │  to Teams (User)        │
       └─────────────────────────┘
```

---

## Detailed Flow Steps

### 1. Trigger: Recurrence

**Action**: Recurrence
**Configuration**:
- **Interval**: 1
- **Frequency**: Day
- **Time zone**: (UTC-06:00) Central Time (US & Canada)
- **At these hours**: 8 (8:00 AM)
- **At these minutes**: 0

**Advanced Options**:
- **On these days**: Monday, Tuesday, Wednesday, Thursday, Friday

---

### 2. Get System Settings

**Connector**: Microsoft Dataverse
**Action**: List rows (multiple actions)

**Action 2a: Get EnableDailyReminders**
- **Table name**: System Settings
- **Filter rows**: `ooooo_settingname eq 'EnableDailyReminders'`
- **Row count**: 1

**Action 2b: Get ReminderTime**
- **Table name**: System Settings
- **Filter rows**: `ooooo_settingname eq 'ReminderTime'`
- **Row count**: 1

**Action 2c: Get WorkingDays**
- **Table name**: System Settings
- **Filter rows**: `ooooo_settingname eq 'WorkingDays'`
- **Row count**: 1

**Store in variables**:
- `varRemindersEnabled`
- `varReminderTime`
- `varWorkingDays`

---

### 3. Initialize Variables

**Variable 1: varRemindersEnabled**
- **Type**: Boolean
- **Value**:
```
@equals(
  first(outputs('Get_EnableDailyReminders')?['body/value'])?['ooooo_settingvalue'],
  'true'
)
```

**Variable 2: varTodayDayOfWeek**
- **Type**: Integer
- **Value**: `@dayOfWeek(utcNow())`
- **Purpose**: Get today's day (0=Sunday, 1=Monday, ... 6=Saturday)

**Variable 3: varIsWorkingDay**
- **Type**: Boolean
- **Value**:
```
@contains(
  first(outputs('Get_WorkingDays')?['body/value'])?['ooooo_settingvalue'],
  string(variables('varTodayDayOfWeek'))
)
```

**Variable 4: varTodayDate**
- **Type**: String
- **Value**: `@formatDateTime(utcNow(), 'yyyy-MM-dd')`

---

### 4. Condition: Check Reminders Enabled

**Action**: Condition
**Formula**: `@equals(variables('varRemindersEnabled'), true)`

**If No**: Terminate flow (reminders disabled)
**If Yes**: Continue

---

### 5. Condition: Check Is Working Day

**Action**: Condition
**Formula**: `@equals(variables('varIsWorkingDay'), true)`

**If No**: Terminate flow (weekend/non-working day)
**If Yes**: Continue

---

### 6. Get Active Users

**Connector**: Microsoft Dataverse
**Action**: List rows
**Configuration**:
- **Table name**: User Profiles
- **Filter rows**: `ooooo_isactive eq true`
- **Order by**: `ooooo_displayname asc`

**Output**: Array of active user profiles

---

### 7. Apply to Each Active User

**Action**: Apply to each
**Input**: `@outputs('Get_Active_Users')?['body/value']`

**Inside the loop, for each user**:

---

### 8. Get Today's Status for User

**Connector**: Microsoft Dataverse
**Action**: List rows
**Configuration**:
- **Table name**: Staff Schedules
- **Filter rows**:
```
ooooo_employeeemail eq '@{items('Apply_to_each')?['ooooo_email']}'
and ooooo_scheduledate eq @{variables('varTodayDate')}
and ooooo_isactive eq true
```
- **Select columns**: `ooooo_status,ooooo_requesttype`
- **Row count**: 1

**Store in variable**: `varUserStatus`

---

### 9. Check User Notification Preferences

**Action**: Condition
**Formula**:
```
@or(
  equals(items('Apply_to_each')?['ooooo_notificationpreferences'], 1),
  equals(items('Apply_to_each')?['ooooo_notificationpreferences'], 3)
)
```
(1 = Teams Only, 3 = Both)

**If No**: Skip notification (user disabled Teams notifications)
**If Yes**: Continue to send notification

---

### 10. Post Adaptive Card to Teams

**Connector**: Microsoft Teams
**Action**: Post adaptive card in a chat or channel
**Configuration**:

**Post as**: Flow bot
**Post in**: Chat with Flow bot
**Recipient**: `@{items('Apply_to_each')?['ooooo_email']}`

**Adaptive Card**:

```json
{
  "type": "AdaptiveCard",
  "body": [
    {
      "type": "Container",
      "items": [
        {
          "type": "TextBlock",
          "text": "🗓️ OOOOO Calendar - Daily Status Update",
          "weight": "Bolder",
          "size": "Large",
          "color": "Accent"
        },
        {
          "type": "TextBlock",
          "text": "Good morning! Please update your work location status for today.",
          "wrap": true,
          "spacing": "Small"
        }
      ]
    },
    {
      "type": "Container",
      "items": [
        {
          "type": "TextBlock",
          "text": "**Current Status for @{formatDateTime(utcNow(), 'dddd, MMMM dd')}:**",
          "wrap": true,
          "weight": "Bolder",
          "spacing": "Medium"
        },
        {
          "type": "TextBlock",
          "text": "@{if(empty(outputs('Get_Todays_Status')?['body/value']), '❓ Not set', concat('✅ ', first(outputs('Get_Todays_Status')?['body/value'])?['ooooo_status@OData.Community.Display.V1.FormattedValue']))}",
          "wrap": true,
          "size": "Large",
          "color": "@{if(empty(outputs('Get_Todays_Status')?['body/value']), 'Warning', 'Good')}"
        }
      ],
      "style": "emphasis",
      "bleed": true
    },
    {
      "type": "Container",
      "items": [
        {
          "type": "TextBlock",
          "text": "What would you like to do?",
          "weight": "Bolder",
          "spacing": "Medium"
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.OpenUrl",
      "title": "📝 Update Status",
      "url": "@{concat('https://teams.microsoft.com/l/entity/', '<YOUR_APP_ID>', '/home')}"
    },
    {
      "type": "Action.OpenUrl",
      "title": "📅 View My Schedule",
      "url": "@{concat('https://teams.microsoft.com/l/entity/', '<YOUR_APP_ID>', '/schedule')}"
    },
    {
      "type": "Action.OpenUrl",
      "title": "🏖️ Request Time Off",
      "url": "@{concat('https://teams.microsoft.com/l/entity/', '<YOUR_APP_ID>', '/request')}"
    }
  ],
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "version": "1.4"
}
```

**Update message**: (Optional - for status changes)
```
Status updated to @{outputs('Update_Status_Choice')?['body/message']}
```

**Should update card**: Yes (if providing action buttons to update directly)

---

## Alternative: Simple Text Message

For simpler implementation without Adaptive Cards:

**Connector**: Microsoft Teams
**Action**: Post message in a chat or channel

**Post as**: Flow bot
**Post in**: Chat with Flow bot
**Recipient**: `@{items('Apply_to_each')?['ooooo_email']}`

**Message**:
```
🗓️ **OOOOO Calendar Reminder**

Good morning, @{items('Apply_to_each')?['ooooo_displayname']}!

**Today's Status:** @{if(empty(outputs('Get_Todays_Status')?['body/value']), '❓ Not set', concat('✅ ', first(outputs('Get_Todays_Status')?['body/value'])?['ooooo_status@OData.Community.Display.V1.FormattedValue']))}

Open the OOOOO Calendar app in Teams to update your work location.
```

---

## Enhanced Version: Interactive Status Update

### Option A: Buttons in Adaptive Card

Add input controls to Adaptive Card:

```json
{
  "type": "Input.ChoiceSet",
  "id": "statusChoice",
  "label": "Update your status:",
  "choices": [
    {
      "title": "🏢 Onsite",
      "value": "1"
    },
    {
      "title": "🏠 Offsite",
      "value": "2"
    }
  ],
  "style": "expanded"
}
```

**Action Button**:
```json
{
  "type": "Action.Submit",
  "title": "✅ Update Status",
  "data": {
    "action": "updateStatus",
    "date": "@{variables('varTodayDate')}",
    "email": "@{items('Apply_to_each')?['ooooo_email']}"
  }
}
```

### Option B: Wait for Response

**Connector**: Microsoft Teams
**Action**: Post adaptive card and wait for a response

**Timeout**: 8 hours (working day)

**After Response**:
1. Parse response data
2. Create or update Staff Schedule record
3. Send confirmation message

---

## Error Handling

### Handle Missing User Status

**Condition**: Check if today's status exists
**If No**:
- Indicate "Not set" in message
- Encourage user to set status

**If Yes**:
- Show current status
- Offer to change if needed

### Handle Notification Failures

**Scope**: Wrap Teams notification in Try-Catch

**On Error**:
1. Log error to variable or storage
2. Continue to next user (don't fail entire flow)
3. Optional: Send admin summary at end

---

## Flow Settings

### General Settings

- **Display Name**: OOOOO - Daily Reminder
- **Description**: Sends daily morning reminders to staff to update work location status
- **Environment**: Production

### Connections

- ✅ **Microsoft Dataverse** (System connection)
- ✅ **Microsoft Teams** (System connection for Flow bot)

### Run Settings

- **Timeout**: 30 minutes (to handle large user lists)
- **Concurrency**: Single instance
- **Retry Policy**: Default (4 retries)

---

## Scheduling Configuration

### Recommended Schedule

**For Central Time (US)**:
- **Time**: 8:00 AM CT
- **Days**: Monday - Friday
- **Time zone**: (UTC-06:00) Central Time

**For Multiple Time Zones**:
- Create separate flow for each time zone, OR
- Use user's time zone preference from User Profile
- Calculate appropriate send time per user

### Holiday Handling

**Option 1: Manual Disable**
- Turn off flow on holidays
- Re-enable after

**Option 2: Holiday Calendar**
- Create Holiday table in Dataverse
- Check if today is a holiday
- Skip sending if holiday

---

## Testing the Flow

### Test Scenario 1: Normal Weekday

1. **Setup**:
   - Set EnableDailyReminders = true
   - Ensure ReminderTime = 08:00
   - Current day = Monday-Friday

2. **Trigger**: Run flow manually or wait for schedule

3. **Expected Result**:
   - Flow processes all active users
   - Each user receives Teams notification
   - Messages show correct status

### Test Scenario 2: Weekend

1. **Setup**: Current day = Saturday or Sunday

2. **Trigger**: Run flow manually

3. **Expected Result**:
   - Flow terminates at "Is Working Day" check
   - No notifications sent

### Test Scenario 3: Reminders Disabled

1. **Setup**: Set EnableDailyReminders = false

2. **Trigger**: Run flow

3. **Expected Result**:
   - Flow terminates at "Reminders Enabled" check
   - No notifications sent

### Test Scenario 4: User Has Status Set

1. **Setup**: User has today's status already set to "Onsite"

2. **Expected Result**:
   - Notification shows: ✅ Onsite
   - User can still update if needed

---

## Performance Optimization

### For Large Teams (50+ users)

**Batch Processing**:
```
Instead of: Apply to each → Send notification
Use: Batch users into groups of 10
Send notifications in parallel batches
```

**Reduce Dataverse Calls**:
```
Instead of: Query status for each user individually
Use: Get all today's statuses once, filter in memory
```

**Example Optimized Query**:
```
Filter rows: ooooo_scheduledate eq @{variables('varTodayDate')}
             and ooooo_isactive eq true
Select columns: ooooo_employeeemail, ooooo_status
```

Then match statuses to users in memory using Compose/Filter actions.

---

## Monitoring & Analytics

### What to Track

1. **Delivery Success Rate**
   - How many notifications sent vs. failed
   - Target: >98% success

2. **Response Rate** (if using interactive cards)
   - How many users respond to reminders
   - Benchmark: 70-80% within 2 hours

3. **Status Update Timing**
   - When do users typically update status
   - Optimize reminder time based on patterns

### Analytics Implementation

**Add to end of flow**:

1. **Compose Summary**:
```json
{
  "Date": "@{utcNow()}",
  "TotalUsers": "@{length(outputs('Get_Active_Users')?['body/value'])}",
  "NotificationsSent": "@{variables('varNotificationCount')}",
  "Errors": "@{variables('varErrorCount')}"
}
```

2. **Create Analytics Record** (optional):
   - Create custom "Flow Runs" table
   - Store daily summary
   - Use for reporting

---

## User Experience Considerations

### Best Practices

1. **Timing**:
   - Send early enough for users to respond before daily standup
   - Not too early (before work hours)
   - Recommended: 8:00 AM local time

2. **Frequency**:
   - Daily is recommended for routine building
   - Allow users to opt-out via notification preferences

3. **Message Tone**:
   - Friendly, not demanding
   - Include emoji for approachability
   - Show current status to reduce clicks

4. **Actionability**:
   - Direct link to app
   - Or interactive buttons (if implementing response handling)
   - Clear next steps

---

## Customization Options

### Customization 1: Manager Summary

Add parallel branch to send managers a daily summary:

**After user reminders**:
1. Get all managers (User Profile where Is Manager = true)
2. For each manager:
   - Get their team's statuses
   - Compose summary adaptive card
   - Send to manager

### Customization 2: Reminder Escalation

Send follow-up if status not set by certain time:

**Trigger 2**: Recurrence at 10:00 AM
**Check**: Users with no status set for today
**Action**: Send follow-up reminder

### Customization 3: Custom Messages by Department

Use Department from User Profile to send department-specific messages or reminders.

---

## Troubleshooting

### Issue: Notifications not received

**Possible Causes**:
1. Teams app permissions
2. User disabled Flow bot
3. User email incorrect in User Profile

**Fix**:
- Verify Teams connector is authenticated
- Check user's Teams notification settings
- Validate email addresses

### Issue: Wrong time zone

**Cause**: Recurrence trigger uses UTC
**Fix**: Set explicit time zone in recurrence settings

### Issue: Duplicate notifications

**Cause**: Multiple flow instances running
**Fix**: Set concurrency to single instance

---

## Integration with Main App

### Deep Linking

Update app URLs in Adaptive Card to deep link to specific screens:

**Format**:
```
https://teams.microsoft.com/l/entity/{appId}/{entityId}?context={"subEntityId":"{screenName}"}
```

**Get App ID**:
1. In Teams, right-click OOOOO Calendar app
2. Copy link
3. Extract app ID from URL

### Context Passing

Pass date context in deep link so app opens to today's date:

```
subEntityId: {"screen":"home","date":"2025-01-15"}
```

---

## Advanced Features

### Feature 1: Weather-Based Reminders

Integrate with weather API:
- Check weather forecast
- If inclement weather, encourage remote work
- Adjust message: "Snowy day ahead! Consider working offsite."

### Feature 2: Meeting Integration

Check user's calendar:
- If they have early meetings, send reminder earlier
- If out-of-office calendar event exists, skip reminder

### Feature 3: Gamification

Track status update streak:
- "You've updated your status 10 days in a row! 🎉"
- Leaderboard of most consistent updaters

---

## Compliance & Privacy

### Data Handling

- **User Preferences**: Respect notification preferences
- **Quiet Hours**: Don't send outside work hours
- **Opt-Out**: Allow users to disable reminders

### Best Practices

1. **Transparency**: Inform users about reminder schedule
2. **Control**: Give users control over frequency
3. **Purpose**: Clearly communicate reminder purpose

---

## Cost & Licensing

### Power Automate Limits

**Standard M365 License**:
- 2,000 Power Automate runs per user per month
- This flow: ~22 runs per month (daily, weekdays only)
- **Well within limits**

**For 11 users**:
- 11 users × 22 runs = 242 total runs/month
- Plus 22 flow triggers = 264 total actions
- **No premium license needed**

---

## Deprecation & Alternatives

### If Reminders Become Excessive

**Alternative 1**: Weekly Summary
- Change to weekly instead of daily
- Send on Monday mornings

**Alternative 2**: Smart Reminders
- Only send if user hasn't updated status in 3+ days
- Adaptive frequency based on user engagement

**Alternative 3**: In-App Prompts
- Remove flow entirely
- Show prompt in app when user opens it

---

## Version History

- **v1.0** - Initial daily reminder implementation
- **Future**: Interactive responses, manager summaries, smart frequency

---

## Related Documentation

- **Approval Workflow**: `ooo-approval-flow-design.md`
- **Calendar Sync**: `calendar-sync-flow-design.md`
- **Table Schema**: `../dataverse-tables-schema.json`
- **Installation Guide**: `../../INSTALLATION.md`

---

**Status**: Optional (Recommended)
**Last Updated**: November 2025
**Maintainer**: OOOOO Calendar Team
