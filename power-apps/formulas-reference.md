# Power Apps Formulas Reference - OOOOO Calendar

This document contains key formulas used throughout the OOOOO Calendar Power App.

## Table of Contents

1. [App OnStart](#app-onstart)
2. [User Context & Authentication](#user-context--authentication)
3. [Data Loading](#data-loading)
4. [Calendar Calculations](#calendar-calculations)
5. [Validation Logic](#validation-logic)
6. [Status Color Coding](#status-color-coding)
7. [Submission Formulas](#submission-formulas)
8. [Approval Formulas](#approval-formulas)
9. [Filtering & Search](#filtering--search)
10. [Responsive Design](#responsive-design)

---

## App OnStart

### Initialize Application

```excel
// Load current user information
Set(varCurrentUser, User());

// Get user profile from UserProfiles list
Set(varUserProfile,
    LookUp(
        UserProfiles,
        UserAccount.Email = varCurrentUser.Email
    )
);

// Set manager flag
Set(varIsManager,
    If(
        IsBlank(varUserProfile),
        false,
        varUserProfile.IsManager
    )
);

// Load system settings into collection
ClearCollect(colSystemSettings, SystemSettings);

// Parse and set individual settings
Set(varMinAdvanceNoticeDays,
    Value(
        LookUp(
            colSystemSettings,
            Title = "MinimumAdvanceNoticeDays",
            SettingValue
        )
    )
);

Set(varMaxOOODaysPerRequest,
    Value(
        LookUp(
            colSystemSettings,
            Title = "MaxOOODaysPerRequest",
            SettingValue
        )
    )
);

Set(varEnableDailyReminders,
    If(
        LookUp(
            colSystemSettings,
            Title = "EnableDailyReminders",
            SettingValue
        ) = "true",
        true,
        false
    )
);

// Set color scheme from settings
Set(varColorOnsite, RGBA(76, 175, 80, 1));      // Green
Set(varColorOffsite, RGBA(33, 150, 243, 1));    // Blue
Set(varColorPending, RGBA(255, 193, 7, 1));     // Amber
Set(varColorApproved, RGBA(156, 39, 176, 1));   // Purple
Set(varColorRejected, RGBA(244, 67, 54, 1));    // Red

// Set primary theme colors
Set(varColorPrimary, RGBA(0, 120, 212, 1));     // Microsoft Blue
Set(varColorSuccess, RGBA(76, 175, 80, 1));     // Green
Set(varColorWarning, RGBA(255, 152, 0, 1));     // Orange
Set(varColorError, RGBA(244, 67, 54, 1));       // Red

// Initialize navigation
Set(varCurrentScreen, "Home");

// Set default calendar view
Set(varCalendarViewMode, "Weekly");
Set(varCalendarStartDate,
    Today() - Mod(Weekday(Today()) - 2, 7)  // Monday of current week
);
Set(varCalendarEndDate,
    varCalendarStartDate + 6  // Sunday
);
```

---

## User Context & Authentication

### Get Current User Information

```excel
// Current user object
User()

// User email
User().Email

// User full name
User().FullName

// User's first name
First(Split(User().FullName, " ")).Value
```

### Check if User is Manager

```excel
// Boolean check
varIsManager

// Or lookup directly
LookUp(
    UserProfiles,
    UserAccount.Email = User().Email,
    IsManager
)
```

### Get User's Manager

```excel
// Manager email
varUserProfile.ManagerEmail

// Manager display name
LookUp(
    UserProfiles,
    UserAccount.Email = varUserProfile.ManagerEmail,
    DisplayName
)
```

---

## Data Loading

### Load Today's Schedule

```excel
Set(varTodaySchedule,
    LookUp(
        StaffSchedule,
        EmployeeEmail = varCurrentUser.Email &&
        ScheduleDate = Today() &&
        IsActive = true
    )
);

// Get today's status (with default)
If(
    IsBlank(varTodaySchedule),
    "Onsite",  // Default if no entry
    varTodaySchedule.Status.Value
)
```

### Load Upcoming Schedule (Next 7 Days)

```excel
ClearCollect(colUpcomingSchedule,
    Filter(
        StaffSchedule,
        EmployeeEmail = varCurrentUser.Email &&
        ScheduleDate >= Today() &&
        ScheduleDate <= Today() + 7 &&
        IsActive = true
    )
);
```

### Load User's Full Schedule

```excel
ClearCollect(colMySchedule,
    Filter(
        StaffSchedule,
        EmployeeEmail = varCurrentUser.Email &&
        IsActive = true
    )
);
```

### Load Team Schedule

```excel
// Get all active team members
ClearCollect(colTeamMembers,
    Filter(
        UserProfiles,
        IsActive = true &&
        (
            Manager.Email = varCurrentUser.Email ||  // If manager, show direct reports
            !varIsManager  // If not manager, show all (for visibility)
        )
    )
);

// Load schedule data for date range
ClearCollect(colTeamSchedule,
    Filter(
        StaffSchedule,
        ScheduleDate >= varCalendarStartDate &&
        ScheduleDate <= varCalendarEndDate &&
        IsActive = true
    )
);
```

### Load Pending Approvals (Managers Only)

```excel
If(varIsManager,
    ClearCollect(colPendingApprovals,
        Filter(
            StaffSchedule,
            Status.Value = "OOO-Pending" &&
            LookUp(
                UserProfiles,
                UserAccount.Email = EmployeeEmail,
                Manager.Email
            ) = varCurrentUser.Email
        )
    )
);
```

---

## Calendar Calculations

### Get Start of Week (Monday)

```excel
// For any given date
Today() - Mod(Weekday(Today()) - 2, 7)

// For variable date
varSelectedDate - Mod(Weekday(varSelectedDate) - 2, 7)
```

### Get End of Week (Sunday)

```excel
// Start of week + 6 days
varCalendarStartDate + 6
```

### Get Start of Month

```excel
DateValue(
    Year(Today()) & "-" &
    Month(Today()) & "-01"
)
```

### Get End of Month

```excel
DateAdd(
    DateAdd(
        DateValue(
            Year(Today()) & "-" &
            Month(Today()) & "-01"
        ),
        1,
        Months
    ),
    -1,
    Days
)
```

### Calculate Number of Days Between Dates

```excel
DateDiff(
    datePickerStart.SelectedDate,
    datePickerEnd.SelectedDate,
    Days
) + 1  // +1 to include both start and end dates
```

### Calculate Number of Business Days

```excel
// Approximate (excludes weekends only, not holidays)
With(
    {
        totalDays: DateDiff(
            datePickerStart.SelectedDate,
            datePickerEnd.SelectedDate,
            Days
        ) + 1,
        fullWeeks: Int(
            DateDiff(
                datePickerStart.SelectedDate,
                datePickerEnd.SelectedDate,
                Days
            ) / 7
        )
    },
    totalDays - (fullWeeks * 2) -
    If(
        Weekday(datePickerStart.SelectedDate) = 1,  // Sunday
        1,
        0
    ) -
    If(
        Weekday(datePickerEnd.SelectedDate) = 7,  // Saturday
        1,
        0
    )
)
```

### Generate Date Range Collection

```excel
// Create collection of dates from start to end
ClearCollect(colDateRange,
    ForAll(
        Sequence(
            DateDiff(
                varCalendarStartDate,
                varCalendarEndDate,
                Days
            ) + 1
        ),
        {
            Date: varCalendarStartDate + Value - 1,
            DayName: Text(
                varCalendarStartDate + Value - 1,
                "ddd"
            ),
            DayNumber: Day(varCalendarStartDate + Value - 1)
        }
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
            StaffSchedule,
            EmployeeEmail = varCurrentUser.Email &&
            IsActive = true &&
            (Status.Value = "OOO-Pending" || Status.Value = "OOO-Approved") &&
            (
                // Check if any existing request overlaps with new request
                (ScheduleDate >= datePickerStart.SelectedDate &&
                 ScheduleDate <= datePickerEnd.SelectedDate) ||
                (StartDate <= datePickerEnd.SelectedDate &&
                 EndDate >= datePickerStart.SelectedDate)
            )
        )
    ) > 0
);

// Error message
If(
    varHasOverlappingRequests,
    "You have an overlapping request for this date range. Please cancel or modify the existing request first.",
    ""
)
```

### Validate Maximum OOO Days

```excel
Set(varRequestedDays,
    DateDiff(
        datePickerStart.SelectedDate,
        datePickerEnd.SelectedDate,
        Days
    ) + 1
);

Set(varExceedsMaxDays,
    varRequestedDays > varMaxOOODaysPerRequest
);

// Error message
If(
    varExceedsMaxDays,
    "Request exceeds maximum of " &
    varMaxOOODaysPerRequest &
    " consecutive days. Please split into multiple requests or contact your manager.",
    ""
)
```

### Validate Date Range

```excel
// End date must be >= start date
Set(varValidDateRange,
    datePickerEnd.SelectedDate >= datePickerStart.SelectedDate
);

// Cannot request past dates
Set(varNoPastDates,
    datePickerStart.SelectedDate >= Today()
);

// Combined validation
Set(varValidDates,
    varValidDateRange && varNoPastDates
);
```

### Combined Form Validation

```excel
// Master validation variable
Set(varFormIsValid,
    varIsValidAdvanceNotice &&
    !varHasOverlappingRequests &&
    !varExceedsMaxDays &&
    varValidDates
);

// Enable/disable submit button
btnSubmit.DisplayMode = If(
    varFormIsValid,
    DisplayMode.Edit,
    DisplayMode.Disabled
)
```

---

## Status Color Coding

### Get Color for Status

```excel
// Using Switch statement
Switch(
    ThisItem.Status.Value,
    "Onsite", varColorOnsite,
    "Offsite", varColorOffsite,
    "OOO-Pending", varColorPending,
    "OOO-Approved", varColorApproved,
    "OOO-Rejected", varColorRejected,
    RGBA(245, 245, 245, 1)  // Default gray
)
```

### Get Icon for Status

```excel
Switch(
    ThisItem.Status.Value,
    "Onsite", Icon.Building,
    "Offsite", Icon.Home,
    "OOO-Pending", Icon.Clock,
    "OOO-Approved", Icon.CheckBadge,
    "OOO-Rejected", Icon.CancelBadge,
    Icon.Help
)
```

### Get Status for Employee on Date

```excel
// For team calendar cells
LookUp(
    colTeamSchedule,
    EmployeeEmail = ThisItem.UserAccount.Email &&
    ScheduleDate = ThisDate,
    Status.Value
)

// With default value if no entry
If(
    IsBlank(
        LookUp(
            colTeamSchedule,
            EmployeeEmail = ThisItem.UserAccount.Email &&
            ScheduleDate = ThisDate
        )
    ),
    "Onsite",  // Default
    LookUp(
        colTeamSchedule,
        EmployeeEmail = ThisItem.UserAccount.Email &&
        ScheduleDate = ThisDate,
        Status.Value
    )
)
```

---

## Submission Formulas

### Submit OOO Request (Single or Multi-Day)

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

// Create request for each day in range
ForAll(
    Sequence(varNumberOfDays),
    Patch(
        StaffSchedule,
        Defaults(StaffSchedule),
        {
            Title: varRequestID,
            EmployeeName: varCurrentUser,
            EmployeeEmail: varCurrentUser.Email,
            ScheduleDate: datePickerStart.SelectedDate + Value - 1,
            StartDate: datePickerStart.SelectedDate,
            EndDate: datePickerEnd.SelectedDate,
            Status: {Value: "OOO-Pending"},
            RequestType: {Value: dropdownRequestType.Selected.Value},
            Comments: textComments.Text,
            SubmissionDateTime: Now(),
            IsActive: true
        }
    )
);

// Show success notification
Notify(
    "Time-off request submitted successfully. Your manager will be notified.",
    NotificationType.Success,
    3000
);

// Refresh data
Refresh(StaffSchedule);

// Navigate back to home or my schedule
Navigate(scrMySchedule);
```

### Update Daily Status (Onsite/Offsite)

```excel
// Check if entry exists for today
If(
    IsBlank(
        LookUp(
            StaffSchedule,
            EmployeeEmail = varCurrentUser.Email &&
            ScheduleDate = Today()
        )
    ),
    // Create new entry
    Patch(
        StaffSchedule,
        Defaults(StaffSchedule),
        {
            Title: "STATUS-" & Text(Today(), "yyyymmdd") & "-" & Left(varCurrentUser.Email, 3),
            EmployeeName: varCurrentUser,
            EmployeeEmail: varCurrentUser.Email,
            ScheduleDate: Today(),
            Status: {Value: varSelectedStatus},  // "Onsite" or "Offsite"
            RequestType: {Value: "Regular Schedule"},
            SubmissionDateTime: Now(),
            IsActive: true
        }
    ),
    // Update existing entry
    Patch(
        StaffSchedule,
        LookUp(
            StaffSchedule,
            EmployeeEmail = varCurrentUser.Email &&
            ScheduleDate = Today()
        ),
        {
            Status: {Value: varSelectedStatus}
        }
    )
);

// Notify user
Notify(
    "Status updated to " & varSelectedStatus,
    NotificationType.Success
);

// Refresh
Refresh(StaffSchedule);
```

---

## Approval Formulas

### Approve Request (Manager)

```excel
// Set selected request variable
Set(varSelectedRequest, galleryPendingRequests.Selected);

// Calculate approval duration
Set(varApprovalDuration,
    DateDiff(
        varSelectedRequest.SubmissionDateTime,
        Now(),
        Hours
    )
);

// Update all related schedule items (multi-day requests)
ForAll(
    Filter(
        StaffSchedule,
        Title = varSelectedRequest.Title &&
        IsActive = true
    ),
    Patch(
        StaffSchedule,
        ThisRecord,
        {
            Status: {Value: "OOO-Approved"},
            ApprovedBy: varCurrentUser,
            ApprovalDateTime: Now(),
            ManagerComments: textManagerComments.Text
        }
    )
);

// Create approval history record
Patch(
    ApprovalHistory,
    Defaults(ApprovalHistory),
    {
        Title: "HIST-" & Text(Now(), "yyyymmdd-hhmmss"),
        RequestID: varSelectedRequest.Title,
        EmployeeName: varSelectedRequest.EmployeeName,
        RequestStartDate: varSelectedRequest.StartDate,
        RequestEndDate: varSelectedRequest.EndDate,
        RequestType: {Value: varSelectedRequest.RequestType.Value},
        Action: {Value: "Approved"},
        ActionDateTime: Now(),
        ActorName: varCurrentUser,
        ActorComments: textManagerComments.Text,
        ApprovalDuration: varApprovalDuration
    }
);

// Notify manager
Notify(
    "Request approved for " & varSelectedRequest.EmployeeName.DisplayName,
    NotificationType.Success
);

// Refresh data
Refresh(StaffSchedule);
Refresh(ApprovalHistory);

// Clear selection
Reset(textManagerComments);
```

### Reject Request (Manager)

```excel
// Similar to approve, but set Status to "OOO-Rejected"
// and Action to "Rejected"

ForAll(
    Filter(
        StaffSchedule,
        Title = varSelectedRequest.Title &&
        IsActive = true
    ),
    Patch(
        StaffSchedule,
        ThisRecord,
        {
            Status: {Value: "OOO-Rejected"},
            ApprovedBy: varCurrentUser,
            ApprovalDateTime: Now(),
            ManagerComments: textManagerComments.Text
        }
    )
);

// Create approval history
Patch(
    ApprovalHistory,
    Defaults(ApprovalHistory),
    {
        Title: "HIST-" & Text(Now(), "yyyymmdd-hhmmss"),
        RequestID: varSelectedRequest.Title,
        EmployeeName: varSelectedRequest.EmployeeName,
        RequestStartDate: varSelectedRequest.StartDate,
        RequestEndDate: varSelectedRequest.EndDate,
        RequestType: {Value: varSelectedRequest.RequestType.Value},
        Action: {Value: "Rejected"},
        ActionDateTime: Now(),
        ActorName: varCurrentUser,
        ActorComments: textManagerComments.Text,
        ApprovalDuration: varApprovalDuration
    }
);

Notify(
    "Request rejected. Employee will be notified.",
    NotificationType.Warning
);

Refresh(StaffSchedule);
Refresh(ApprovalHistory);
```

---

## Filtering & Search

### Filter by Date Range

```excel
ClearCollect(colFilteredSchedule,
    Filter(
        colMySchedule,
        ScheduleDate >= datePickerFilterStart.SelectedDate &&
        ScheduleDate <= datePickerFilterEnd.SelectedDate
    )
);
```

### Filter by Status

```excel
If(
    dropdownStatusFilter.Selected.Value = "All",
    colMySchedule,
    Filter(
        colMySchedule,
        Status.Value = dropdownStatusFilter.Selected.Value
    )
)
```

### Search by Employee Name

```excel
If(
    IsBlank(textSearchEmployee.Text),
    colTeamMembers,
    Filter(
        colTeamMembers,
        textSearchEmployee.Text in DisplayName ||
        textSearchEmployee.Text in UserAccount.Email
    )
)
```

### Combined Filters

```excel
Filter(
    StaffSchedule,
    EmployeeEmail = varCurrentUser.Email &&
    ScheduleDate >= datePickerFilterStart.SelectedDate &&
    ScheduleDate <= datePickerFilterEnd.SelectedDate &&
    (
        dropdownStatusFilter.Selected.Value = "All" ||
        Status.Value = dropdownStatusFilter.Selected.Value
    ) &&
    (
        dropdownRequestTypeFilter.Selected.Value = "All" ||
        RequestType.Value = dropdownRequestTypeFilter.Selected.Value
    )
)
```

---

## Responsive Design

### Detect Screen Size

```excel
// Mobile vs Desktop
Set(varIsMobile, App.Width < 768);

// Specific breakpoints
Set(varDeviceType,
    If(
        App.Width < 768, "Mobile",
        If(
            App.Width < 1024, "Tablet",
            "Desktop"
        )
    )
);
```

### Responsive Width

```excel
// Full width on mobile, fixed width on desktop
If(
    varIsMobile,
    App.Width,
    Min(App.Width * 0.9, 1200)  // Max 1200px
)
```

### Responsive Layout

```excel
// Stack vertically on mobile, horizontal on desktop
containerMain.LayoutDirection = If(
    varIsMobile,
    LayoutDirection.Vertical,
    LayoutDirection.Horizontal
)
```

### Responsive Font Size

```excel
// Smaller fonts on mobile
If(
    varIsMobile,
    14,
    16
)
```

### Responsive Gallery Columns

```excel
// 1 column on mobile, 2 on tablet, 3 on desktop
If(
    App.Width < 768, 1,
    If(
        App.Width < 1024, 2,
        3
    )
)
```

---

## Utility Formulas

### Format Date for Display

```excel
// Short date: "Nov 15, 2025"
Text(ThisItem.ScheduleDate, "mmm dd, yyyy")

// Long date: "Monday, November 15, 2025"
Text(ThisItem.ScheduleDate, "dddd, mmmm dd, yyyy")

// ISO format: "2025-11-15"
Text(ThisItem.ScheduleDate, "yyyy-mm-dd")
```

### Format Date/Time for Display

```excel
// Full: "Nov 15, 2025 10:30 AM"
Text(ThisItem.SubmissionDateTime, "mmm dd, yyyy hh:mm AM/PM")

// Relative time
If(
    DateDiff(ThisItem.SubmissionDateTime, Now(), Days) = 0,
    "Today at " & Text(ThisItem.SubmissionDateTime, "hh:mm AM/PM"),
    If(
        DateDiff(ThisItem.SubmissionDateTime, Now(), Days) = 1,
        "Yesterday at " & Text(ThisItem.SubmissionDateTime, "hh:mm AM/PM"),
        Text(ThisItem.SubmissionDateTime, "mmm dd at hh:mm AM/PM")
    )
)
```

### Count Active Requests

```excel
CountRows(
    Filter(
        StaffSchedule,
        EmployeeEmail = varCurrentUser.Email &&
        IsActive = true &&
        Status.Value = "OOO-Pending"
    )
)
```

### Calculate Team Availability

```excel
// Number of people out on a specific date
CountRows(
    Filter(
        StaffSchedule,
        ScheduleDate = varSelectedDate &&
        (Status.Value = "OOO-Pending" || Status.Value = "OOO-Approved") &&
        IsActive = true
    )
)

// Percentage available
(CountRows(colTeamMembers) - CountRows(
    Filter(
        StaffSchedule,
        ScheduleDate = varSelectedDate &&
        (Status.Value = "OOO-Pending" || Status.Value = "OOO-Approved") &&
        IsActive = true
    )
)) / CountRows(colTeamMembers) * 100
```

---

## Performance Tips

### Use Delegation-Friendly Queries

✅ **Good** (Delegable):
```excel
Filter(StaffSchedule, EmployeeEmail = varCurrentUser.Email)
```

❌ **Bad** (Non-delegable, limited to 2000 items):
```excel
Filter(StaffSchedule, DateDiff(ScheduleDate, Today(), Days) < 7)
```

### Load Data OnVisible, Not OnSelect

✅ **Good**:
```excel
// Screen OnVisible
ClearCollect(colMySchedule, Filter(...));

// Gallery Items
colMySchedule
```

❌ **Bad**:
```excel
// Gallery Items (queries SharePoint every time)
Filter(StaffSchedule, ...)
```

### Use Collections for Repeated Access

```excel
// Load once
ClearCollect(colTeamSchedule, Filter(...));

// Use many times
Gallery1.Items = colTeamSchedule
Gallery2.Items = Filter(colTeamSchedule, ...)
Label1.Text = CountRows(colTeamSchedule)
```

---

This reference covers the most commonly used formulas in the OOOOO Calendar app. For more complex scenarios, consult the Power Apps documentation or contact the development team.

**Document Version**: 1.0.0
**Last Updated**: November 2025
