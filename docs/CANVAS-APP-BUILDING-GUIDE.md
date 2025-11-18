# Building the OOOOO Calendar Canvas App
**Step-by-Step Guide for Power Apps Studio**

## Overview

This guide provides **click-by-click instructions** for building the OOOOO Calendar canvas app in Microsoft Power Apps Studio. Based on learnings from building similar Teams apps, **Power Apps Studio is the recommended and practical approach** for creating canvas apps.

**Estimated Time**: 3-4 hours
**Difficulty**: Intermediate
**Prerequisites**: OOOOO Calendar Dataverse solution imported (4 tables created)

---

## Why Build in Power Apps Studio?

After extensive experimentation with manually creating .msapp files, we've learned:

✅ **Power Apps Studio is the practical approach** because:
- Generates all complex JSON structure automatically
- Validates formulas and relationships in real-time
- Handles checksums and metadata correctly
- Provides visual drag-and-drop design
- Offers IntelliSense for Power Fx formulas
- Prevents breaking undocumented internal structure

❌ **Manual .msapp creation is impractical** because:
- 300+ controls even for simple apps
- Complex parent-child relationships
- Undocumented internal fields
- Checksum calculation difficulties
- High risk of creating non-importable files

---

## Part 1: Setup (15 minutes)

### Step 1.1: Open Power Apps in Teams

1. Open **Microsoft Teams**
2. Click **Apps** in the left sidebar
3. Search for **Power Apps**
4. Click **Add** (if not already added)
5. Click **Power Apps** in the left sidebar to open it

###Step 1.2: Create New Canvas App

1. In Power Apps, click the **Build** tab
2. Select your **team** where you imported the OOOOO Calendar solution
3. Click **See all**
4. Click **+ New** → **App**
5. Choose **Canvas app from blank**
6. In the dialog:
   - **App name**: `OOOOO Calendar`
   - **Format**: Select **Tablet** (16:9 landscape)
   - Click **Create**

Power Apps Studio will open with a blank canvas.

### Step 1.3: Connect to Dataverse Tables

1. In Power Apps Studio, click **Data** in the left sidebar (database icon)
2. Click **Add data**
3. Search for and add these 4 tables:
   - **Staff Schedules** (ooooo_staffschedule)
   - **User Profiles** (ooooo_userprofile)
   - **Approval History** (ooooo_approvalhistory)
   - **System Settings** (ooooo_systemsetting)

You should now see all 4 tables listed in the Data pane.

### Step 1.4: Set App Properties

1. Click **App** in the tree view (left sidebar, top item)
2. In the properties pane (right side), set:
   - **Name**: OOOOO Calendar
   - **Background color**: White or Teams theme color
   - **Orientation**: Landscape
   - **Screen size**: Desktop

---

## Part 2: Build Screen Structure (30 minutes)

We'll create 6 screens total. Let's add them first, then build each one.

### Step 2.1: Create All Screens

1. Click **+ New screen** (top toolbar)
2. Choose **Blank** layout
3. Rename the screen (click the three dots → Rename):
   - Rename **Screen1** → `scrHome`

4. Repeat to create 5 more blank screens:
   - `scrMySchedule`
   - `scrTeamCalendar`
   - `scrRequestTimeOff`
   - `scrApprovals` (for managers)
   - `scrSettings`

You should now have 6 screens in your tree view.

### Step 2.2: Add Navigation Menu to All Screens

We'll create a consistent left navigation menu on each screen.

**On scrHome screen:**

1. Click **Insert** → **Icon** → **Hamburger menu** icon
2. Position it in the top-left corner (X: 20, Y: 20)
3. Resize to 40x40
4. Rename to `icoMenu`

5. Click **Insert** → **Gallery** → **Blank vertical**
6. Position below the menu icon (X: 0, Y: 70, Width: 200, Height: 600)
7. Rename to `galNavigation`

8. With galNavigation selected, set the **Items** property to:
```
Table(
    {Icon: Icon.Home, Label: "Home", Screen: scrHome},
    {Icon: Icon.CalendarBlank, Label: "My Schedule", Screen: scrMySchedule},
    {Icon: Icon.People, Label: "Team Calendar", Screen: scrTeamCalendar},
    {Icon: Icon.AddDocument, Label: "Request Time Off", Screen: scrRequestTimeOff},
    {Icon: Icon.Checkmark, Label: "Approvals", Screen: scrApprovals},
    {Icon: Icon.Settings, Label: "Settings", Screen: scrSettings}
)
```

9. **Inside the gallery template** (click the pencil icon to edit):
   - Add an **Icon** control
     - Icon property: `ThisItem.Icon`
     - X: 10, Y: 5, Size: 30x30

   - Add a **Label** control next to it
     - Text: `ThisItem.Label`
     - X: 50, Y: 10
     - Font size: 14
     - Color: Dark gray

10. Set gallery template height: **60**

11. Add an **OnSelect** action to the gallery:
```
Navigate(ThisItem.Screen, ScreenTransition.Fade)
```

**Copy navigation to other screens:**

1. Select the `galNavigation` gallery
2. Press **Ctrl+C** to copy
3. Click on `scrMySchedule`
4. Press **Ctrl+V** to paste
5. Repeat for all remaining screens

---

## Part 3: Build Home Screen (30 minutes)

### Step 3.1: Add Welcome Header

1. On `scrHome`, click **Insert** → **Label**
2. Properties:
   - **Text**: `"Welcome, " & User().FullName`
   - **X**: 220, **Y**: 20
   - **Font size**: 24
   - **Font weight**: Bold

### Step 3.2: Add Status Cards

Create 3 cards showing key metrics.

**Card 1: Today's Status**

1. Insert → **Rectangle**
   - Fill: Light blue (#E3F2FD)
   - X: 220, Y: 80, Width: 300, Height: 150
   - BorderRadius: 8

2. Insert → **Label** (inside rectangle)
   - Text: `"Today's Status"`
   - Font size: 18, Font weight: Bold

3. Insert → **Label** (below title)
   - Text formula:
```
With(
    {todaySchedule: LookUp('Staff Schedules',
        ooooo_employee = User().Email &&
        ooooo_scheduledate = Today()
    )},
    If(IsBlank(todaySchedule), "Not Set", todaySchedule.ooooo_status)
)
```
   - Font size: 32
   - Color: Based on status

**Card 2: Pending Requests**

1. Insert → **Rectangle**
   - Fill: Light yellow (#FFF9C4)
   - X: 540, Y: 80, Width: 300, Height: 150

2. Insert → **Label** (title)
   - Text: `"Pending Requests"`

3. Insert → **Label** (count)
   - Text formula:
```
CountRows(
    Filter('Staff Schedules',
        ooooo_employee = User().Email &&
        ooooo_status = 3
    )
)
```
   - Font size: 32

**Card 3: Upcoming Time Off**

1. Insert → **Rectangle**
   - Fill: Light green (#E8F5E9)
   - X: 860, Y: 80, Width: 300, Height: 150

2. Insert → **Label** (title)
   - Text: `"Upcoming Time Off"`

3. Insert → **Label** (next date)
   - Text formula:
```
With(
    {nextOOO: First(
        Sort(
            Filter('Staff Schedules',
                ooooo_employee = User().Email &&
                ooooo_status = 4 &&
                ooooo_startdate > Today()
            ),
            ooooo_startdate,
            Ascending
        )
    )},
    If(IsBlank(nextOOO),
        "None scheduled",
        Text(nextOOO.ooooo_startdate, "mmm dd")
    )
)
```

### Step 3.3: Add Quick Actions

1. Insert → **Button**
   - Text: `"Request Time Off"`
   - X: 220, Y: 250
   - OnSelect: `Navigate(scrRequestTimeOff, ScreenTransition.Fade)`

2. Insert → **Button**
   - Text: `"View My Schedule"`
   - X: 420, Y: 250
   - OnSelect: `Navigate(scrMySchedule, ScreenTransition.Fade)`

### Step 3.4: Add Recent Requests Gallery

1. Insert → **Gallery** → **Blank vertical**
2. Position: X: 220, Y: 320, Width: 900, Height: 300
3. Items property:
```
Sort(
    Filter('Staff Schedules',
        ooooo_employee = User().Email
    ),
    ooooo_submissiondatetime,
    Descending
)
```

4. Inside gallery template, add:
   - **Label** for Request ID: `ThisItem.ooooo_requestid`
   - **Label** for Date: `Text(ThisItem.ooooo_scheduledate, "mmm dd, yyyy")`
   - **Label** for Status: `ThisItem.ooooo_status` (with color coding)
   - **Label** for Type: `ThisItem.ooooo_requesttype`

---

## Part 4: Build My Schedule Screen (45 minutes)

### Step 4.1: Add Month/Year Selector

1. On `scrMySchedule`, add **Dropdown** for month
   - X: 220, Y: 20
   - Items:
```
Table(
    {Value: 1, Label: "January"},
    {Value: 2, Label: "February"},
    {Value: 3, Label: "March"},
    {Value: 4, Label: "April"},
    {Value: 5, Label: "May"},
    {Value: 6, Label: "June"},
    {Value: 7, Label: "July"},
    {Value: 8, Label: "August"},
    {Value: 9, Label: "September"},
    {Value: 10, Label: "October"},
    {Value: 11, Label: "November"},
    {Value: 12, Label: "December"}
)
```
   - Default: `Month(Today())`
   - Rename to `ddMonth`

2. Add **Dropdown** for year
   - X: 400, Y: 20
   - Items:
```
Table(
    {Value: Year(Today()) - 1},
    {Value: Year(Today())},
    {Value: Year(Today()) + 1}
)
```
   - Default: `Year(Today())`
   - Rename to `ddYear`

### Step 4.2: Create Calendar Grid

We'll use a gallery to show a month view.

1. Insert → **Gallery** → **Blank horizontal**
2. Rename to `galCalendar`
3. Items property (creates array of dates for the month):
```
With(
    {
        firstDay: Date(ddYear.Selected.Value, ddMonth.Selected.Value, 1),
        lastDay: DateAdd(Date(ddYear.Selected.Value, ddMonth.Selected.Value + 1, 1), -1)
    },
    ForAll(
        Sequence(Day(lastDay)),
        Date(ddYear.Selected.Value, ddMonth.Selected.Value, Value)
    )
)
```

4. Template size: Make each day cell 120x120 pixels

5. **Inside each gallery cell**, add:
   - **Rectangle** (background)
     - Fill: Based on status for that day
     - Fill formula:
```
With(
    {daySchedule: LookUp('Staff Schedules',
        ooooo_employee = User().Email &&
        ooooo_scheduledate = ThisItem.Value
    )},
    Switch(daySchedule.ooooo_status,
        1, RGBA(76, 175, 80, 0.3),    // Onsite - Green
        2, RGBA(33, 150, 243, 0.3),   // Offsite - Blue
        3, RGBA(255, 193, 7, 0.3),    // Pending - Yellow
        4, RGBA(156, 39, 176, 0.3),   // Approved - Purple
        5, RGBA(244, 67, 54, 0.3),    // Rejected - Red
        White                          // No status
    )
)
```

   - **Label** (day number)
     - Text: `Day(ThisItem.Value)`
     - Font size: 16, top-left corner

   - **Label** (status)
     - Text:
```
With(
    {daySchedule: LookUp('Staff Schedules',
        ooooo_employee = User().Email &&
        ooooo_scheduledate = ThisItem.Value
    )},
    If(IsBlank(daySchedule), "", daySchedule.ooooo_status)
)
```
     - Font size: 12, center

### Step 4.3: Add Legend

1. Add **Labels** showing what each color means:
   - Green = Onsite
   - Blue = Offsite
   - Yellow = Pending
   - Purple = Approved
   - Red = Rejected

---

## Part 5: Build Team Calendar Screen (30 minutes)

### Step 5.1: Add Team Member Filter

1. Insert → **Combobox**
2. Items property:
```
Distinct('Staff Schedules', ooooo_employeeemail)
```
3. Default: Show all
4. Rename to `cmbTeamFilter`

### Step 5.2: Create Team Schedule Gallery

1. Insert → **Gallery** → **Blank vertical**
2. Items property:
```
If(IsBlank(cmbTeamFilter.Selected.Value),
    'Staff Schedules',
    Filter('Staff Schedules', ooooo_employeeemail = cmbTeamFilter.Selected.Value)
)
```

3. **Inside gallery**, add:
   - Employee email label
   - Date label
   - Status badge (colored rectangle + text)
   - Request type

### Step 5.3: Add Date Range Filter

1. Add **Date Picker** for start date
2. Add **Date Picker** for end date
3. Update gallery Items to filter by date range:
```
Filter(
    'Staff Schedules',
    ooooo_scheduledate >= datStart.SelectedDate &&
    ooooo_scheduledate <= datEnd.SelectedDate
)
```

---

## Part 6: Build Request Time Off Screen (45 minutes)

### Step 6.1: Create Request Form

1. Insert → **Edit form** control
2. DataSource: `'Staff Schedules'`
3. Item: `Defaults('Staff Schedules')`
4. Columns: 1
5. Rename to `frmTimeOffRequest`

### Step 6.2: Configure Form Fields

1. **Edit fields** button (right pane)
2. Remove unnecessary fields, keep only:
   - Request ID (auto-generated)
   - Request Type (dropdown)
   - Start Date (date picker)
   - End Date (date picker)
   - Comments (text area)

3. For **Request ID** field:
   - Default value: `"REQ-" & Text(Now(), "yyyymmdd-hhmmss")`
   - DisplayMode: View (read-only)

4. For **Request Type**:
   - DisplayMode: Edit
   - Default: Vacation

5. Add hidden fields that auto-populate:
   - **Employee**: `User().Email`
   - **Employee Email**: `User().Email`
   - **Schedule Date**: `frmTimeOffRequest.Updates.ooooo_startdate`
   - **Status**: `3` (OOO-Pending)
   - **Submission DateTime**: `Now()`
   - **Is Active**: `true`
   - **Number of Days**:
```
DateDiff(
    frmTimeOffRequest.Updates.ooooo_startdate,
    frmTimeOffRequest.Updates.ooooo_enddate
) + 1
```

### Step 6.3: Add Submit Button

1. Insert → **Button**
2. Text: `"Submit Request"`
3. OnSelect:
```
SubmitForm(frmTimeOffRequest);
If(frmTimeOffRequest.Error = Blank(),
    Notify("Request submitted successfully!", NotificationType.Success);
    Navigate(scrHome, ScreenTransition.Fade),
    Notify("Error: " & frmTimeOffRequest.Error, NotificationType.Error)
)
```

### Step 6.4: Add Cancel Button

1. Insert → **Button**
2. Text: `"Cancel"`
3. OnSelect:
```
ResetForm(frmTimeOffRequest);
Navigate(scrHome, ScreenTransition.Fade)
```

---

## Part 7: Build Approvals Screen (Manager Only) (30 minutes)

### Step 7.1: Add Permission Check

1. On `scrApprovals`, set the **Visible** property of the entire screen to:
```
With(
    {userProfile: LookUp('User Profiles', ooooo_email = User().Email)},
    userProfile.ooooo_ismanager = true
)
```

If not a manager, show a message instead.

### Step 7.2: Create Pending Approvals Gallery

1. Insert → **Gallery** → **Blank vertical**
2. Items property:
```
Sort(
    Filter('Staff Schedules',
        ooooo_status = 3  // Pending
    ),
    ooooo_submissiondatetime,
    Ascending
)
```

3. **Inside gallery**, add:
   - Employee name/email
   - Request ID
   - Request type
   - Start date - End date
   - Number of days
   - Comments
   - **Approve button** (green)
   - **Reject button** (red)

### Step 7.3: Add Approve/Reject Buttons

**Approve Button** OnSelect:
```
Patch('Staff Schedules',
    ThisItem,
    {
        ooooo_status: 4,  // Approved
        ooooo_approver: User().Email,
        ooooo_approvaldatetime: Now(),
        ooooo_managercomments: txtManagerComments.Text
    }
);
Notify("Request approved", NotificationType.Success)
```

**Reject Button** OnSelect:
```
Patch('Staff Schedules',
    ThisItem,
    {
        ooooo_status: 5,  // Rejected
        ooooo_approver: User().Email,
        ooooo_approvaldatetime: Now(),
        ooooo_managercomments: txtManagerComments.Text
    }
);
Notify("Request rejected", NotificationType.Warning)
```

### Step 7.4: Add Manager Comments Field

1. Insert → **Text input** (multiline)
2. Hint text: `"Optional comments"`
3. Rename to `txtManagerComments`

---

## Part 8: Build Settings Screen (20 minutes)

### Step 8.1: Create User Preferences Form

1. Insert → **Edit form**
2. DataSource: `'User Profiles'`
3. Item: `LookUp('User Profiles', ooooo_email = User().Email)`
4. Fields to include:
   - Notification Preferences (dropdown)
   - Time Zone (dropdown)
   - Department (text)

### Step 8.2: Add Save Button

1. Insert → **Button**
2. Text: `"Save Preferences"`
3. OnSelect:
```
SubmitForm(frmSettings);
Notify("Settings saved", NotificationType.Success)
```

### Step 8.3: Add System Info (Read-Only)

Display system settings from the System Settings table:
- Minimum advance notice days
- Maximum OOO days per request
- Daily reminders enabled/disabled

---

## Part 9: Add App-Level Logic (30 minutes)

### Step 9.1: Initialize Global Variables

Click on **App** in the tree view, then set the **OnStart** property:

```
// Set loading state
Set(gblAppLoading, true);

// Get current user profile
Set(gblCurrentUser, User());

// Check if user profile exists
Set(gblUserProfile,
    LookUp('User Profiles', ooooo_email = gblCurrentUser.Email)
);

// If no profile, create one
If(IsBlank(gblUserProfile),
    Patch('User Profiles',
        Defaults('User Profiles'),
        {
            ooooo_displayname: gblCurrentUser.FullName,
            ooooo_email: gblCurrentUser.Email,
            ooooo_isactive: true,
            ooooo_firsttimeuser: true,
            ooooo_notificationpreferences: 3,  // Both
            ooooo_timezone: 2  // Central
        }
    )
);

// Load system settings into collection
ClearCollect(colSystemSettings, 'System Settings');

// Set theme colors
Set(gblColorOnsite, RGBA(76, 175, 80, 1));
Set(gblColorOffsite, RGBA(33, 150, 243, 1));
Set(gblColorPending, RGBA(255, 193, 7, 1));
Set(gblColorApproved, RGBA(156, 39, 176, 1));
Set(gblColorRejected, RGBA(244, 67, 54, 1));

// Mark app as loaded
Set(gblAppLoading, false);

// Show welcome message for first-time users
If(gblUserProfile.ooooo_firsttimeuser = true,
    Notify("Welcome to OOOOO Calendar! " & gblCurrentUser.FullName, NotificationType.Success)
)
```

### Step 9.2: Add Loading Screen

1. Create a new screen called `scrLoading`
2. Add a spinner/loading animation
3. Add label: "Loading OOOOO Calendar..."
4. Make this the first screen in the app
5. Set screen OnVisible:
```
If(!gblAppLoading, Navigate(scrHome, ScreenTransition.Fade))
```

---

## Part 10: Polish & Testing (30 minutes)

### Step 10.1: Add Consistent Styling

Create a theme using consistent colors:
- Primary: Teams purple (#6264A7)
- Success: Green (#4CAF50)
- Warning: Yellow (#FFC107)
- Error: Red (#F44336)

Apply to all buttons, headers, and status indicators.

### Step 10.2: Add Icons

Enhance the UI with icons:
- Calendar icons for dates
- User icons for people
- Status icons (checkmark, clock, x)

### Step 10.3: Test Core Flows

**Test as Staff Member:**
1. ✅ Submit a new time off request
2. ✅ View request in "My Schedule"
3. ✅ See pending status
4. ✅ Check it appears in "Recent Requests" on Home

**Test as Manager:**
1. ✅ Switch to a manager account
2. ✅ Open Approvals screen
3. ✅ See pending request
4. ✅ Approve or reject
5. ✅ Verify status updates

**Test Calendar:**
1. ✅ View approved time off in calendar
2. ✅ Check colors match status
3. ✅ Verify date calculations are correct

### Step 10.4: Add Error Handling

For each form and data operation, add error handling:
```
If(IsError(operation),
    Notify("Error: " & FirstError.Message, NotificationType.Error)
)
```

---

## Part 11: Save and Publish (15 minutes)

### Step 11.1: Save the App

1. Click **File** → **Save**
2. App name: `OOOOO Calendar`
3. Icon: Choose a calendar icon
4. Description: "Staff scheduling and time-off approval system"
5. Click **Save**

### Step 11.2: Publish the App

1. Click **File** → **Publish**
2. Click **Publish this version**
3. Wait for publish to complete

### Step 11.3: Add to Solution

1. Click **File** → **Save As**
2. Choose **The cloud**
3. Select your **OOOOOCalendar solution**
4. Click **Save**

### Step 11.4: Share with Team

1. Click **File** → **Share**
2. Enter team members or security groups
3. Grant appropriate permissions:
   - **User**: Can run the app
   - **Co-owner**: Can edit the app
4. Click **Share**

### Step 11.5: Add to Teams Channel

1. In Microsoft Teams, go to your team
2. Click **+** to add a tab
3. Search for **Power Apps**
4. Select **OOOOO Calendar**
5. Click **Save**

---

## Troubleshooting

### Common Issues

**Issue: "Delegation warning" on galleries**
- **Solution**: Ensure filters use delegable functions. Use `Filter()` instead of complex nested logic.

**Issue: Slow performance**
- **Solution**: Use collections to cache data. Load once in OnStart, refresh only when needed.

**Issue: Formula errors**
- **Solution**: Check that table and column names match exactly (case-sensitive). Use IntelliSense.

**Issue: Permission denied errors**
- **Solution**: Ensure users have proper Dataverse security roles assigned.

**Issue: Data not appearing**
- **Solution**: Check that Dataverse tables have data. Verify connection in Data pane.

---

## Next Steps

After building the canvas app:

1. ✅ Test thoroughly with multiple users
2. ✅ Create Power Automate flows (see `solution/Workflows/` folder)
3. ✅ Configure security roles in Dataverse
4. ✅ Add user profiles for all team members
5. ✅ Train users on how to use the app
6. ✅ Monitor usage and gather feedback

---

## Resources

- **Power Apps Documentation**: https://learn.microsoft.com/power-apps/
- **Power Fx Formula Reference**: https://learn.microsoft.com/power-platform/power-fx/formula-reference
- **Dataverse for Teams**: https://learn.microsoft.com/power-apps/teams/overview-data-platform
- **Teams Integration Guide**: https://learn.microsoft.com/power-apps/teams/embed-teams-app

---

## Summary

You've now built a complete canvas app with:
- ✅ 6 functional screens
- ✅ Navigation menu
- ✅ Data entry forms
- ✅ Calendar views
- ✅ Approval workflow
- ✅ User preferences
- ✅ Error handling
- ✅ Professional styling

The app is ready for deployment and use by your team!
