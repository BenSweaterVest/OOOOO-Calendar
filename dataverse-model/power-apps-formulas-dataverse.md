# Power Apps Formulas for Dataverse - OOOOO Calendar

This document contains Power Apps formulas specifically for the **Dataverse version** of OOOOO Calendar.

## Key Differences from SharePoint Version

### Table Names
- **SharePoint**: `StaffSchedule`, `ApprovalHistory`
- **Dataverse**: `StaffSchedules`, `'Approval Histories'` (pluralized, may have spaces)

### Column References
- **SharePoint**: `Status.Value`, `EmployeeName.Email`
- **Dataverse**: `'Status (ooooo_status)'`, `'Employee (ooooo_employee)'.'Primary Email'`

### Choice Fields
- **SharePoint**: Returns `{Value: "Onsite"}`
- **Dataverse**: Returns enum value (e.g., `'Status (ooooo_status)'.Onsite`)

---

## App OnStart

```excel
// Load current user information
Set(varCurrentUser, User());

// Get user profile from Dataverse
Set(varUserProfile,
    LookUp(
        'User Profiles',
        'User (ooooo_user)'.'Primary Email' = varCurrentUser.Email
    )
);

// Set manager flag
Set(varIsManager,
    If(
        IsBlank(varUserProfile),
        false,
        'Is Manager (ooooo_ismanager)'
    )
);

// Load system settings into collection
ClearCollect(colSystemSettings, 'System Settings');

// Parse and set individual settings
Set(varMinAdvanceNoticeDays,
    Value(
        LookUp(
            colSystemSettings,
            'Setting Name (ooooo_settingname)' = "MinimumAdvanceNoticeDays"
        ).'Setting Value (ooooo_settingvalue)'
    )
);

Set(varMaxOOODaysPerRequest,
    Value(
        LookUp(
            colSystemSettings,
            'Setting Name (ooooo_settingname)' = "MaxOOODaysPerRequest"
        ).'Setting Value (ooooo_settingvalue)'
    )
);

Set(varEnableDailyReminders,
    If(
        LookUp(
            colSystemSettings,
            'Setting Name (ooooo_settingname)' = "EnableDailyReminders"
        ).'Setting Value (ooooo_settingvalue)' = "true",
        true,
        false
    )
);

// Set color scheme - Dataverse Choices have built-in colors
Set(varColorOnsite, RGBA(76, 175, 80, 1));      // Green
Set(varColorOffsite, RGBA(33, 150, 243, 1));    // Blue
Set(varColorPending, RGBA(255, 193, 7, 1));     // Amber
Set(varColorApproved, RGBA(156, 39, 176, 1));   // Purple
Set(varColorRejected, RGBA(244, 67, 54, 1));    // Red

// Set primary theme colors
Set(varColorPrimary, RGBA(0, 120, 212, 1));
Set(varColorSuccess, RGBA(76, 175, 80, 1));
Set(varColorWarning, RGBA(255, 152, 0, 1));
Set(varColorError, RGBA(244, 67, 54, 1));

// Initialize navigation
Set(varCurrentScreen, "Home");

// Set default calendar view
Set(varCalendarViewMode, "Weekly");
Set(varCalendarStartDate,
    Today() - Mod(Weekday(Today()) - 2, 7)
);
Set(varCalendarEndDate,
    varCalendarStartDate + 6
);

// Show welcome screen if first time user
If(
    varUserProfile.'First Time User (ooooo_firsttimeuser)',
    Set(varShowWelcome, true),
    Set(varShowWelcome, false)
);
```

---

## Data Loading

### Load Today's Schedule

```excel
Set(varTodaySchedule,
    LookUp(
        'Staff Schedules',
        'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
        'Schedule Date (ooooo_scheduledate)' = Today() &&
        'Is Active (ooooo_isactive)' = true
    )
);

// Get today's status (with default)
If(
    IsBlank(varTodaySchedule),
    'Status (ooooo_status)'.Onsite,  // Default if no entry (Dataverse enum)
    varTodaySchedule.'Status (ooooo_status)'
)
```

### Load Upcoming Schedule

```excel
ClearCollect(colUpcomingSchedule,
    Filter(
        'Staff Schedules',
        'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
        'Schedule Date (ooooo_scheduledate)' >= Today() &&
        'Schedule Date (ooooo_scheduledate)' <= Today() + 7 &&
        'Is Active (ooooo_isactive)' = true
    )
);
```

### Load Team Schedule

```excel
// Get all active team members
ClearCollect(colTeamMembers,
    Filter(
        'User Profiles',
        'Is Active (ooooo_isactive)' = true &&
        (
            'Manager (ooooo_manager)'.'Primary Email' = varCurrentUser.Email ||
            !varIsManager
        )
    )
);

// Load schedule data for date range (Dataverse handles large datasets well)
ClearCollect(colTeamSchedule,
    Filter(
        'Staff Schedules',
        'Schedule Date (ooooo_scheduledate)' >= varCalendarStartDate &&
        'Schedule Date (ooooo_scheduledate)' <= varCalendarEndDate &&
        'Is Active (ooooo_isactive)' = true
    )
);
```

### Load Pending Approvals (Managers)

```excel
If(varIsManager,
    ClearCollect(colPendingApprovals,
        Filter(
            'Staff Schedules',
            'Status (ooooo_status)' = 'Status (ooooo_status)'.'OOO-Pending' &&
            LookUp(
                'User Profiles',
                'User (ooooo_user)'.'Primary Email' = 'Employee (ooooo_employee)'.'Primary Email'
            ).'Manager (ooooo_manager)'.'Primary Email' = varCurrentUser.Email
        )
    )
);
```

---

## Validation Logic

### Validate Minimum Advance Notice

```excel
Set(varIsValidAdvanceNotice,
    DateDiff(
        Today(),
        datePickerStart.SelectedDate,
        Days
    ) >= varMinAdvanceNoticeDays
);

// Error message
If(
    !varIsValidAdvanceNotice,
    "Please provide at least " &
    varMinAdvanceNoticeDays &
    " days advance notice for time-off requests.",
    ""
)
```

### Validate No Overlapping Requests

```excel
Set(varHasOverlappingRequests,
    CountRows(
        Filter(
            'Staff Schedules',
            'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
            'Is Active (ooooo_isactive)' = true &&
            (
                'Status (ooooo_status)' = 'Status (ooooo_status)'.'OOO-Pending' ||
                'Status (ooooo_status)' = 'Status (ooooo_status)'.'OOO-Approved'
            ) &&
            (
                ('Schedule Date (ooooo_scheduledate)' >= datePickerStart.SelectedDate &&
                 'Schedule Date (ooooo_scheduledate)' <= datePickerEnd.SelectedDate) ||
                ('Start Date (ooooo_startdate)' <= datePickerEnd.SelectedDate &&
                 'End Date (ooooo_enddate)' >= datePickerStart.SelectedDate)
            )
        )
    ) > 0
);
```

---

## Status Color Coding

### Get Color for Status (Dataverse Enum)

```excel
// Using Switch with Dataverse enum values
Switch(
    ThisItem.'Status (ooooo_status)',
    'Status (ooooo_status)'.Onsite, varColorOnsite,
    'Status (ooooo_status)'.Offsite, varColorOffsite,
    'Status (ooooo_status)'.'OOO-Pending', varColorPending,
    'Status (ooooo_status)'.'OOO-Approved', varColorApproved,
    'Status (ooooo_status)'.'OOO-Rejected', varColorRejected,
    RGBA(245, 245, 245, 1)  // Default gray
)
```

### Get Status for Team Calendar Cell

```excel
// For team calendar cells - returns enum or default
With(
    {
        scheduleItem: LookUp(
            colTeamSchedule,
            'Employee (ooooo_employee)'.'Primary Email' = ThisItem.'User (ooooo_user)'.'Primary Email' &&
            'Schedule Date (ooooo_scheduledate)' = ThisDate
        )
    },
    If(
        IsBlank(scheduleItem),
        'Status (ooooo_status)'.Onsite,  // Default to Onsite
        scheduleItem.'Status (ooooo_status)'
    )
)
```

### Get Color for Calendar Cell

```excel
With(
    {
        currentStatus: LookUp(
            colTeamSchedule,
            'Employee (ooooo_employee)'.'Primary Email' = ThisItem.'User (ooooo_user)'.'Primary Email' &&
            'Schedule Date (ooooo_scheduledate)' = ThisDate,
            'Status (ooooo_status)'
        )
    },
    Switch(
        currentStatus,
        'Status (ooooo_status)'.Onsite, varColorOnsite,
        'Status (ooooo_status)'.Offsite, varColorOffsite,
        'Status (ooooo_status)'.'OOO-Pending', varColorPending,
        'Status (ooooo_status)'.'OOO-Approved', varColorApproved,
        RGBA(250, 250, 250, 1)  // Default light gray
    )
)
```

---

## Submission Formulas

### Submit OOO Request (Dataverse)

```excel
// Generate unique request ID
Set(varRequestID,
    "REQ-" &
    Text(Now(), "yyyymmdd-hhmmss") &
    "-" &
    Left(varCurrentUser.Email, 3)
);

// Calculate number of days
Set(varNumberOfDays,
    DateDiff(
        datePickerStart.SelectedDate,
        datePickerEnd.SelectedDate,
        Days
    ) + 1
);

// Get current user's systemuser record for lookup
Set(varCurrentSystemUser,
    LookUp(
        Users,
        'Primary Email' = varCurrentUser.Email
    )
);

// Create request for each day in range
ForAll(
    Sequence(varNumberOfDays),
    Patch(
        'Staff Schedules',
        Defaults('Staff Schedules'),
        {
            'Request ID (ooooo_requestid)': varRequestID,
            'Employee (ooooo_employee)': varCurrentSystemUser,
            'Employee Email (ooooo_employeeemail)': varCurrentUser.Email,
            'Schedule Date (ooooo_scheduledate)': datePickerStart.SelectedDate + Value - 1,
            'Start Date (ooooo_startdate)': datePickerStart.SelectedDate,
            'End Date (ooooo_enddate)': datePickerEnd.SelectedDate,
            'Number of Days (ooooo_numberofdays)': varNumberOfDays,
            'Status (ooooo_status)': 'Status (ooooo_status)'.'OOO-Pending',
            'Request Type (ooooo_requesttype)':
                Switch(
                    dropdownRequestType.Selected.Value,
                    "Vacation", 'Request Type (ooooo_requesttype)'.Vacation,
                    "Sick Leave", 'Request Type (ooooo_requesttype)'.'Sick Leave',
                    "Personal Day", 'Request Type (ooooo_requesttype)'.'Personal Day',
                    'Request Type (ooooo_requesttype)'.Other
                ),
            'Comments (ooooo_comments)': textComments.Text,
            'Submission Date/Time (ooooo_submissiondatetime)': Now(),
            'Is Active (ooooo_isactive)': true
        }
    )
);

// Show success notification
Notify(
    "Time-off request submitted successfully. Your manager will be notified.",
    NotificationType.Success,
    3000
);

// Refresh data (Dataverse updates instantly)
Refresh('Staff Schedules');

// Navigate back
Navigate(scrMySchedule, ScreenTransition.CoverRight);
```

### Update Daily Status (Onsite/Offsite)

```excel
// Convert status string to enum
Set(varSelectedStatusEnum,
    Switch(
        varSelectedStatus,
        "Onsite", 'Status (ooooo_status)'.Onsite,
        "Offsite", 'Status (ooooo_status)'.Offsite,
        'Status (ooooo_status)'.Onsite  // Default
    )
);

// Check if entry exists for today
If(
    IsBlank(
        LookUp(
            'Staff Schedules',
            'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
            'Schedule Date (ooooo_scheduledate)' = Today()
        )
    ),
    // Create new entry
    Patch(
        'Staff Schedules',
        Defaults('Staff Schedules'),
        {
            'Request ID (ooooo_requestid)': "STATUS-" & Text(Today(), "yyyymmdd") & "-" & Left(varCurrentUser.Email, 3),
            'Employee (ooooo_employee)': varCurrentSystemUser,
            'Employee Email (ooooo_employeeemail)': varCurrentUser.Email,
            'Schedule Date (ooooo_scheduledate)': Today(),
            'Status (ooooo_status)': varSelectedStatusEnum,
            'Request Type (ooooo_requesttype)': 'Request Type (ooooo_requesttype)'.'Regular Schedule',
            'Submission Date/Time (ooooo_submissiondatetime)': Now(),
            'Is Active (ooooo_isactive)': true
        }
    ),
    // Update existing entry
    Patch(
        'Staff Schedules',
        LookUp(
            'Staff Schedules',
            'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
            'Schedule Date (ooooo_scheduledate)' = Today()
        ),
        {
            'Status (ooooo_status)': varSelectedStatusEnum
        }
    )
);

// Notify user
Notify(
    "Status updated to " & varSelectedStatus,
    NotificationType.Success
);

// Refresh (Dataverse is fast!)
Refresh('Staff Schedules');
```

---

## Approval Formulas

### Approve Request (Manager)

```excel
// Set selected request
Set(varSelectedRequest, galleryPendingRequests.Selected);

// Calculate approval duration
Set(varApprovalDuration,
    DateDiff(
        varSelectedRequest.'Submission Date/Time (ooooo_submissiondatetime)',
        Now(),
        Hours
    )
);

// Get manager's systemuser record
Set(varManagerSystemUser,
    LookUp(
        Users,
        'Primary Email' = varCurrentUser.Email
    )
);

// Update all related schedule items (multi-day requests share same Request ID)
ForAll(
    Filter(
        'Staff Schedules',
        'Request ID (ooooo_requestid)' = varSelectedRequest.'Request ID (ooooo_requestid)' &&
        'Is Active (ooooo_isactive)' = true
    ),
    Patch(
        'Staff Schedules',
        ThisRecord,
        {
            'Status (ooooo_status)': 'Status (ooooo_status)'.'OOO-Approved',
            'Approver (ooooo_approver)': varManagerSystemUser,
            'Approval Date/Time (ooooo_approvaldatetime)': Now(),
            'Manager Comments (ooooo_managercomments)': textManagerComments.Text
        }
    )
);

// Create approval history record
Patch(
    'Approval Histories',
    Defaults('Approval Histories'),
    {
        'History ID (ooooo_historyid)': "HIST-" & Text(Now(), "yyyymmdd-hhmmss"),
        'Related Request (ooooo_relatedrequest)': varSelectedRequest,
        'Employee (ooooo_employee)': varSelectedRequest.'Employee (ooooo_employee)',
        'Request Start Date (ooooo_requeststartdate)': varSelectedRequest.'Start Date (ooooo_startdate)',
        'Request End Date (ooooo_requestenddate)': varSelectedRequest.'End Date (ooooo_enddate)',
        'Request Type (ooooo_requesttype)': varSelectedRequest.'Request Type (ooooo_requesttype)',
        'Action (ooooo_action)': 'Action (ooooo_action)'.Approved,
        'Action Date/Time (ooooo_actiondatetime)': Now(),
        'Actor (ooooo_actor)': varManagerSystemUser,
        'Actor Comments (ooooo_actorcomments)': textManagerComments.Text,
        'Approval Duration (hours) (ooooo_approvalduration)': varApprovalDuration
    }
);

// Notify manager
Notify(
    "Request approved for " & varSelectedRequest.'Employee (ooooo_employee)'.'Full Name',
    NotificationType.Success
);

// Refresh data
Refresh('Staff Schedules');
Refresh('Approval Histories');

// Clear selection
Reset(textManagerComments);
```

### Reject Request (Manager)

```excel
// Similar to approve, but with OOO-Rejected status
ForAll(
    Filter(
        'Staff Schedules',
        'Request ID (ooooo_requestid)' = varSelectedRequest.'Request ID (ooooo_requestid)' &&
        'Is Active (ooooo_isactive)' = true
    ),
    Patch(
        'Staff Schedules',
        ThisRecord,
        {
            'Status (ooooo_status)': 'Status (ooooo_status)'.'OOO-Rejected',
            'Approver (ooooo_approver)': varManagerSystemUser,
            'Approval Date/Time (ooooo_approvaldatetime)': Now(),
            'Manager Comments (ooooo_managercomments)': textManagerComments.Text
        }
    )
);

// Create approval history
Patch(
    'Approval Histories',
    Defaults('Approval Histories'),
    {
        'History ID (ooooo_historyid)': "HIST-" & Text(Now(), "yyyymmdd-hhmmss"),
        'Related Request (ooooo_relatedrequest)': varSelectedRequest,
        'Employee (ooooo_employee)': varSelectedRequest.'Employee (ooooo_employee)',
        'Request Start Date (ooooo_requeststartdate)': varSelectedRequest.'Start Date (ooooo_startdate)',
        'Request End Date (ooooo_requestenddate)': varSelectedRequest.'End Date (ooooo_enddate)',
        'Request Type (ooooo_requesttype)': varSelectedRequest.'Request Type (ooooo_requesttype)',
        'Action (ooooo_action)': 'Action (ooooo_action)'.Rejected,
        'Action Date/Time (ooooo_actiondatetime)': Now(),
        'Actor (ooooo_actor)': varManagerSystemUser,
        'Actor Comments (ooooo_actorcomments)': textManagerComments.Text,
        'Approval Duration (hours) (ooooo_approvalduration)': varApprovalDuration
    }
);

Notify(
    "Request rejected. Employee will be notified.",
    NotificationType.Warning
);

Refresh('Staff Schedules');
Refresh('Approval Histories');
```

---

## Working with Dataverse Lookups

### Get User from Office 365 Users Connector

```excel
// Load current user's systemuser record
Set(varCurrentSystemUser,
    LookUp(
        Users,  // Built-in Dataverse table
        'Primary Email' = User().Email
    )
);

// Or use Office 365 Users connector
Set(varCurrentO365User,
    Office365Users.UserProfileV2(User().Email)
);
```

### Get Manager Email

```excel
// From User Profile table
varUserProfile.'Manager (ooooo_manager)'.'Primary Email'

// Or directly from Office 365
Office365Users.ManagerV2(User().Email).Mail
```

---

## Filtering & Search (Dataverse Optimized)

### Delegable Filtering

```excel
// ✅ GOOD - Delegable query (works with 500k+ rows)
Filter(
    'Staff Schedules',
    'Employee Email (ooooo_employeeemail)' = varCurrentUser.Email &&
    'Schedule Date (ooooo_scheduledate)' >= Today() &&
    'Is Active (ooooo_isactive)' = true
)

// ❌ BAD - Non-delegable (limited to 2000 rows)
Filter(
    'Staff Schedules',
    DateDiff('Schedule Date (ooooo_scheduledate)', Today(), Days) < 7
)
```

### Search by Employee Name

```excel
// Delegable search using StartsWith
Search(
    'User Profiles',
    textSearch.Text,
    'Display Name (ooooo_displayname)'
)

// Or using Filter
Filter(
    'User Profiles',
    StartsWith('Display Name (ooooo_displayname)', textSearch.Text)
)
```

---

## Performance Tips for Dataverse

### 1. Use Lookups Efficiently

```excel
// ✅ GOOD - Lookup once, reuse
Set(varEmployee,
    LookUp(Users, 'Primary Email' = varCurrentUser.Email)
);

// ❌ BAD - Lookup multiple times
Patch('Staff Schedules', ..., {'Employee': LookUp(Users, ...)});
Patch('Approval Histories', ..., {'Employee': LookUp(Users, ...)});
```

### 2. Load Data OnVisible

```excel
// Screen OnVisible
ClearCollect(colMySchedule,
    Filter('Staff Schedules', ...)
);

// Gallery Items
colMySchedule  // From collection, not direct query
```

### 3. Use With() for Complex Formulas

```excel
With(
    {
        todaySchedule: LookUp(
            'Staff Schedules',
            'Schedule Date (ooooo_scheduledate)' = Today()
        ),
        settingsValue: LookUp(
            colSystemSettings,
            'Setting Name (ooooo_settingname)' = "MaxDays"
        )
    },
    If(
        IsBlank(todaySchedule),
        "No schedule",
        todaySchedule.'Status (ooooo_status)'
    )
)
```

---

## Dataverse-Specific Features

### Calculated Fields (Future Enhancement)

Dataverse supports calculated columns that SharePoint doesn't:

```
// Can be added to Dataverse table definition
Number of Days = End Date - Start Date + 1
Approval Duration = Approval DateTime - Submission DateTime
```

### Business Rules (No-Code Logic)

Create business rules in Dataverse that run without app code:
- Auto-populate Employee Email from Employee lookup
- Validate date ranges
- Set default values

### Rollup Fields

Aggregate data across related records:
- Total OOO days per employee
- Average approval time per manager

---

This reference covers all key formulas for the Dataverse version of OOOOO Calendar. The main differences from SharePoint are in how you reference columns and work with choice/lookup fields.

**Document Version**: 2.0.0 (Dataverse)
**Last Updated**: November 2025
