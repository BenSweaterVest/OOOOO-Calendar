# Power Apps Structure - OOOOO Calendar

## App Overview

**App Type**: Canvas App
**Primary Platform**: Microsoft Teams
**Design**: Responsive (Mobile & Desktop)
**Authentication**: Azure AD (Single Sign-On)

## Navigation Structure

```
OOOOO Calendar App
│
├── 📱 Home Dashboard (Default Screen)
│   ├── Quick Status Selector
│   ├── Today's Status Card
│   ├── Upcoming Schedule Preview
│   ├── Pending Approvals Badge
│   └── Quick Action Buttons
│
├── 📅 My Schedule
│   ├── Personal Calendar View
│   ├── Request History List
│   ├── Edit/Cancel Actions
│   └── New OOO Request Button
│
├── 📊 Team Calendar
│   ├── Monthly/Weekly Grid View
│   ├── Team Member Roster
│   ├── Filters & Search
│   ├── Status Legend
│   └── Export Options
│
├── ➕ Request Form (Modal/Screen)
│   ├── Date Picker (Range)
│   ├── Request Type Selector
│   ├── Comments Field
│   ├── Validation Messages
│   └── Submit/Cancel Buttons
│
├── ✅ Manager Approvals (Managers Only)
│   ├── Pending Requests List
│   ├── Request Details Panel
│   ├── Approve/Reject Actions
│   ├── Manager Comments Field
│   └── Approval History
│
└── ⚙️ Settings (Optional)
    ├── Notification Preferences
    ├── Display Settings
    └── About/Help
```

## Screen Definitions

### 1. Home Dashboard Screen

**Screen Name**: `scrHome`

#### Components:

**Header Section**
- App title: "OOOOO Calendar"
- User greeting: "Hello, [FirstName]!"
- Current date display
- Notification bell icon with badge

**Today's Status Card**
```
┌─────────────────────────────────────┐
│ Today's Status                      │
│ [Status Icon] Currently: Onsite     │
│                                     │
│ [Update Status Button]              │
└─────────────────────────────────────┘
```

**Quick Status Selector**
- Radio button group or button set:
  - 🏢 Onsite
  - 🏠 Offsite
  - 🌴 Request Time Off
- OnSelect logic updates today's schedule or opens request form

**Upcoming Schedule Preview (Next 7 Days)**
```
Gallery Component showing:
┌──────────────────────────────────────────┐
│ Monday, Nov 18    | Onsite     | [Edit] │
│ Tuesday, Nov 19   | Offsite    | [Edit] │
│ Wednesday, Nov 20 | OOO-Pending| [View] │
│ ...                                      │
└──────────────────────────────────────────┘
```

**Pending Approvals Section** (Managers Only)
```
┌─────────────────────────────────────┐
│ Pending Approvals: 3                │
│ [View All Approvals →]              │
└─────────────────────────────────────┘
```

**Quick Action Buttons**
- "Request Time Off" (Primary button)
- "View My Schedule" (Secondary button)
- "View Team Calendar" (Secondary button)

#### Key Formulas:

```excel
// OnVisible - Load user context
Set(varCurrentUser, User());
Set(varUserProfile,
    LookUp(UserProfiles,
           UserAccount.Email = varCurrentUser.Email)
);
Set(varIsManager, varUserProfile.IsManager);

// Load today's schedule
Set(varTodaySchedule,
    LookUp(StaffSchedule,
           EmployeeEmail = varCurrentUser.Email &&
           ScheduleDate = Today())
);

// Load upcoming schedule (next 7 days)
ClearCollect(colUpcomingSchedule,
    Filter(StaffSchedule,
           EmployeeEmail = varCurrentUser.Email &&
           ScheduleDate >= Today() &&
           ScheduleDate <= Today() + 7 &&
           IsActive = true
    )
);

// Load pending approvals count (managers)
If(varIsManager,
    Set(varPendingApprovalsCount,
        CountRows(
            Filter(StaffSchedule,
                   Status = "OOO-Pending" &&
                   ApprovedBy.Email = varCurrentUser.Email
            )
        )
    )
);
```

---

### 2. My Schedule Screen

**Screen Name**: `scrMySchedule`

#### Components:

**Calendar Component**
- Monthly calendar view (custom component or gallery)
- Color-coded by status
- Click to view/edit entry

**Request History Gallery**
```
┌────────────────────────────────────────────────────────┐
│ Date Range     | Type      | Status        | Actions   │
├────────────────────────────────────────────────────────┤
│ Dec 24-26      | Vacation  | OOO-Approved  | [View]    │
│ Nov 21         | Sick      | OOO-Rejected  | [Details] │
│ Nov 15-16      | Personal  | OOO-Pending   | [Cancel]  │
└────────────────────────────────────────────────────────┘
```

**Filters**
- Date range picker
- Status filter dropdown
- Request type filter

**Action Buttons**
- "New Time Off Request" (Primary)
- "Refresh" (Secondary)
- "Export My Schedule" (Optional)

#### Key Formulas:

```excel
// OnVisible - Load user's schedule
ClearCollect(colMySchedule,
    Filter(StaffSchedule,
           EmployeeEmail = varCurrentUser.Email &&
           IsActive = true
    )
);

// Filter by date range
ClearCollect(colFilteredSchedule,
    Filter(colMySchedule,
           ScheduleDate >= datePickerStart.SelectedDate &&
           ScheduleDate <= datePickerEnd.SelectedDate &&
           (dropdownStatusFilter.Selected.Value = "All" ||
            Status = dropdownStatusFilter.Selected.Value)
    )
);

// Cancel request logic
Patch(StaffSchedule,
      LookUp(StaffSchedule, ID = ThisItem.ID),
      {IsActive: false}
);
Notify("Request cancelled successfully", NotificationType.Success);
Refresh(StaffSchedule);
```

---

### 3. Team Calendar Screen

**Screen Name**: `scrTeamCalendar`

#### Components:

**Calendar Grid**
- Rows: Team members
- Columns: Dates (weekly or monthly view)
- Cells: Color-coded status blocks

**Team Member List (Left Panel)**
```
┌─────────────────────┐
│ John Doe           │
│ Jane Smith         │
│ Bob Johnson        │
│ ...                │
└─────────────────────┘
```

**Date Header (Top)**
```
┌──────────────────────────────────────┐
│ < Nov 2025 >                        │
│ Mon | Tue | Wed | Thu | Fri | Sat...│
└──────────────────────────────────────┘
```

**Status Legend**
```
■ Onsite     ■ Offsite     ■ OOO-Pending     ■ OOO-Approved
```

**Filters & Controls**
- View selector: Weekly / Monthly
- Date navigation: Previous / Next / Today
- Search: Filter by employee name
- Export: Export to Excel

#### Key Formulas:

```excel
// OnVisible - Load team schedule data
ClearCollect(colTeamSchedule,
    Filter(StaffSchedule,
           ScheduleDate >= varCalendarStartDate &&
           ScheduleDate <= varCalendarEndDate &&
           IsActive = true
    )
);

// Load team members
ClearCollect(colTeamMembers,
    Filter(UserProfiles,
           IsActive = true &&
           Manager.Email = varCurrentUser.Email ||
           !varIsManager  // Show all if not manager
    )
);

// Get status for specific employee and date
LookUp(colTeamSchedule,
       EmployeeEmail = ThisItem.Email &&
       ScheduleDate = ThisColumnDate,
       Status
);

// Color coding formula
Switch(
    LookUp(colTeamSchedule,
           EmployeeEmail = ThisItem.Email &&
           ScheduleDate = ThisDate,
           Status),
    "Onsite", RGBA(76, 175, 80, 1),      // Green
    "Offsite", RGBA(33, 150, 243, 1),    // Blue
    "OOO-Pending", RGBA(255, 193, 7, 1), // Yellow/Amber
    "OOO-Approved", RGBA(156, 39, 176, 1), // Purple
    RGBA(245, 245, 245, 1)                // Gray (no entry)
)
```

---

### 4. Request Form Screen/Modal

**Screen Name**: `scrRequestForm` or `ctnRequestFormModal`

#### Components:

**Form Header**
- Title: "Request Time Off"
- Close button (X)

**Form Fields**

**Date Selection**
```
┌─────────────────────────────────────┐
│ Request Type:                       │
│ ○ Single Day    ○ Date Range        │
│                                     │
│ Start Date: [Date Picker]           │
│ End Date:   [Date Picker]           │
│ (Enabled only for Date Range)       │
└─────────────────────────────────────┘
```

**Request Type Dropdown**
```
┌─────────────────────────────────────┐
│ Type of Time Off:                   │
│ [Vacation ▼]                        │
│  - Vacation                         │
│  - Sick Leave                       │
│  - Personal Day                     │
│  - Other                            │
└─────────────────────────────────────┘
```

**Comments Field**
```
┌─────────────────────────────────────┐
│ Comments (Optional):                │
│ [                                 ] │
│ [                                 ] │
│ [                                 ] │
└─────────────────────────────────────┘
```

**Validation Messages**
- Display error messages for invalid dates
- Show warning for minimum advance notice
- Alert for overlapping requests

**Action Buttons**
- "Submit Request" (Primary, blue)
- "Cancel" (Secondary, gray)

#### Key Formulas:

```excel
// Validation - Minimum advance notice
Set(varMinAdvanceNoticeDays,
    Value(
        LookUp(SystemSettings,
               Title = "MinimumAdvanceNoticeDays",
               SettingValue)
    )
);

Set(varIsValidAdvanceNotice,
    datePickerStart.SelectedDate >= Today() + varMinAdvanceNoticeDays
);

// Validation - No overlapping requests
Set(varHasOverlappingRequests,
    CountRows(
        Filter(StaffSchedule,
               EmployeeEmail = varCurrentUser.Email &&
               IsActive = true &&
               (
                   (ScheduleDate >= datePickerStart.SelectedDate &&
                    ScheduleDate <= datePickerEnd.SelectedDate) ||
                   (StartDate <= datePickerEnd.SelectedDate &&
                    EndDate >= datePickerStart.SelectedDate)
               )
        )
    ) > 0
);

// Submit logic
If(
    varIsValidAdvanceNotice && !varHasOverlappingRequests,
    // Create request(s)
    ForAll(
        Sequence(
            DateDiff(datePickerStart.SelectedDate,
                    datePickerEnd.SelectedDate,
                    Days) + 1
        ),
        Patch(StaffSchedule,
              Defaults(StaffSchedule),
              {
                  Title: "REQ-" & Text(Now(), "yyyymmdd-hhmmss"),
                  EmployeeName: varCurrentUser,
                  EmployeeEmail: varCurrentUser.Email,
                  ScheduleDate: datePickerStart.SelectedDate + Value - 1,
                  StartDate: datePickerStart.SelectedDate,
                  EndDate: datePickerEnd.SelectedDate,
                  Status: "OOO-Pending",
                  RequestType: dropdownRequestType.Selected.Value,
                  Comments: textComments.Text,
                  SubmissionDateTime: Now(),
                  IsActive: true
              }
        )
    );
    Notify("Request submitted successfully", NotificationType.Success);
    Navigate(scrMySchedule),

    // Show validation error
    Notify(
        If(
            !varIsValidAdvanceNotice,
            "Please provide at least " & varMinAdvanceNoticeDays & " days advance notice",
            "You have an overlapping request for this date range"
        ),
        NotificationType.Error
    )
);
```

---

### 5. Manager Approvals Screen

**Screen Name**: `scrManagerApprovals` (Visible only if `varIsManager = true`)

#### Components:

**Pending Requests Gallery**
```
┌──────────────────────────────────────────────────────────────┐
│ Employee      | Dates       | Type      | Days | Submitted    │
├──────────────────────────────────────────────────────────────┤
│ John Doe      | Dec 24-26   | Vacation  | 3    | 11/15 10:30 │
│ Jane Smith    | Nov 22      | Sick      | 1    | 11/18 08:15 │
│ ...                                                           │
└──────────────────────────────────────────────────────────────┘
```

**Request Details Panel** (Shown when request selected)
```
┌─────────────────────────────────────┐
│ Request Details                     │
│                                     │
│ Employee: John Doe                  │
│ Type: Vacation                      │
│ Dates: December 24-26, 2025         │
│ Days: 3                             │
│ Submitted: Nov 15, 2025 10:30 AM    │
│                                     │
│ Employee Comments:                  │
│ "Family holiday plans..."           │
│                                     │
│ Manager Comments:                   │
│ [Text input field]                  │
│                                     │
│ [Approve] [Reject]                  │
└─────────────────────────────────────┘
```

**Tabs/Filters**
- Pending (default)
- Approved
- Rejected
- All

**Approval History Section**
- Searchable list of past approvals
- Filter by employee, date range, action

#### Key Formulas:

```excel
// OnVisible - Load pending approvals
ClearCollect(colPendingApprovals,
    Filter(StaffSchedule,
           Status = "OOO-Pending" &&
           LookUp(UserProfiles,
                  UserAccount.Email = EmployeeEmail,
                  Manager.Email) = varCurrentUser.Email
    )
);

// Approve logic
Set(varSelectedRequest, galleryPendingRequests.Selected);

// Update StaffSchedule
Patch(StaffSchedule,
      varSelectedRequest,
      {
          Status: "OOO-Approved",
          ApprovedBy: varCurrentUser,
          ApprovalDateTime: Now(),
          ManagerComments: textManagerComments.Text
      }
);

// Create approval history record
Patch(ApprovalHistory,
      Defaults(ApprovalHistory),
      {
          Title: "HIST-" & Text(Now(), "yyyymmdd-hhmmss"),
          RequestID: varSelectedRequest,
          EmployeeName: varSelectedRequest.EmployeeName,
          RequestStartDate: varSelectedRequest.StartDate,
          RequestEndDate: varSelectedRequest.EndDate,
          RequestType: varSelectedRequest.RequestType,
          Action: "Approved",
          ActionDateTime: Now(),
          ActorName: varCurrentUser,
          ActorComments: textManagerComments.Text,
          ApprovalDuration: DateDiff(
              varSelectedRequest.SubmissionDateTime,
              Now(),
              Hours
          )
      }
);

// Trigger Power Automate flow for notification
// (Flow will be triggered automatically via SharePoint)

Notify("Request approved", NotificationType.Success);
Refresh(StaffSchedule);
Refresh(ApprovalHistory);

// Reject logic is similar but sets Status to "OOO-Rejected"
```

---

## Global Variables

```excel
// User context
varCurrentUser          // Current logged-in user (User())
varUserProfile          // User's profile from UserProfiles list
varIsManager            // Boolean: Is user a manager?

// UI state
varSelectedDate         // Currently selected date in calendars
varCalendarStartDate    // First date in calendar view
varCalendarEndDate      // Last date in calendar view
varViewMode             // "Weekly" or "Monthly"
varSelectedRequest      // Currently selected request item

// Data collections
colUpcomingSchedule     // User's upcoming schedule (7 days)
colMySchedule           // All user's schedule entries
colTeamSchedule         // Team calendar data
colTeamMembers          // List of team members
colPendingApprovals     // Pending approval requests (managers)
colApprovalHistory      // Historical approvals
colSystemSettings       // System configuration settings

// Settings
varMinAdvanceNoticeDays // Minimum days notice for OOO requests
varMaxOOODaysPerRequest // Max consecutive OOO days
varColorScheme          // JSON object with status colors
varWorkingDays          // Array of working days [1,2,3,4,5]

// Validation
varIsValidAdvanceNotice // Boolean: Meets minimum notice requirement
varHasOverlappingRequests // Boolean: Has overlapping request
```

---

## Color Scheme

```excel
// Primary Colors
Primary:         RGBA(0, 120, 212, 1)    // Microsoft Blue
PrimaryDark:     RGBA(0, 90, 158, 1)
PrimaryLight:    RGBA(204, 228, 247, 1)

// Status Colors (from SystemSettings)
OnsiteColor:     RGBA(76, 175, 80, 1)    // Green
OffsiteColor:    RGBA(33, 150, 243, 1)   // Blue
PendingColor:    RGBA(255, 193, 7, 1)    // Amber
ApprovedColor:   RGBA(156, 39, 176, 1)   // Purple
RejectedColor:   RGBA(244, 67, 54, 1)    // Red

// UI Colors
Background:      RGBA(250, 250, 250, 1)
Surface:         RGBA(255, 255, 255, 1)
Border:          RGBA(225, 225, 225, 1)
TextPrimary:     RGBA(50, 50, 50, 1)
TextSecondary:   RGBA(117, 117, 117, 1)
Success:         RGBA(76, 175, 80, 1)
Warning:         RGBA(255, 152, 0, 1)
Error:           RGBA(244, 67, 54, 1)
```

---

## Responsive Design

### Desktop (Teams Desktop / Web)
- Multi-column layouts
- Side-by-side panels
- Larger calendar grids
- Enhanced data tables

### Mobile (Teams Mobile)
- Single-column stacked layouts
- Bottom navigation bar
- Swipe gestures for calendar navigation
- Collapsible sections
- Touch-optimized buttons (minimum 48x48 px)

### Responsive Formula Example:
```excel
If(
    App.Width > 1024,
    /* Desktop layout */,
    /* Mobile layout */
)
```

---

## Performance Optimization

1. **Delegation**: Use delegable queries for large datasets
2. **Collections**: Load data into collections OnVisible, not OnSelect
3. **Lazy Loading**: Load only visible data in galleries
4. **Caching**: Store system settings in global variables
5. **Limit Gallery Items**: Use `FirstN()` for initial load, load more on demand

---

## Next Steps

1. **Create App in Power Apps Studio**
2. **Connect to SharePoint Data Sources**
3. **Build Screens Following This Structure**
4. **Test Formulas and Workflows**
5. **Deploy to Teams**

See individual screen documentation in `/power-apps/screens/` for detailed specifications.
