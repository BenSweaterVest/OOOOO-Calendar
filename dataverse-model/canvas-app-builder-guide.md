# OOOOO Calendar - Canvas App Builder Guide

Complete step-by-step instructions for building the Power Apps canvas app.

**Time Required**: 2-3 hours
**Difficulty**: Intermediate

---

## Overview

You will build a canvas app with:
- 6 screens
- 30+ controls per screen
- Data connections to Dataverse
- Complete formulas (copy-paste ready)

---

## Prerequisites

- Dataverse tables created (see solution-builder-guide.md Phase 2)
- Solution "OOOOO Calendar" exists
- Power Apps maker permissions

---

## Part 1: Create Blank App (5 minutes)

### Step 1.1: Create Canvas App

1. Navigate to your solution: **OOOOO Calendar**
2. Click **+ New** → **App** → **Canvas app**
3. Name: `OOOOO Calendar`
4. Format: **Tablet** (16:9 ratio, works for desktop and mobile)
5. Click **Create**

Power Apps Studio opens.

### Step 1.2: Add Data Sources

1. Click **Data** (left panel)
2. Click **+ Add data**
3. Search and add:
   - `Staff Schedules` ✓
   - `Approval Histories` ✓
   - `User Profiles` ✓
   - `System Settings` ✓
   - `Users` (built-in table) ✓
4. Click **Add data** again
5. Search and add connectors:
   - `Office 365 Users` ✓
   - `Office 365 Outlook` (optional) ✓

✅ **Checkpoint**: 4 tables + 2 connectors added

---

## Part 2: App OnStart Formula (10 minutes)

### Step 2.1: Set App Properties

1. Click **App** in tree view (left panel)
2. In formula bar, select **OnStart** property
3. **Copy and paste** this formula:

```excel
// Load current user
Set(varCurrentUser, User());

// Get current user's system user record
Set(varCurrentSystemUser,
    LookUp(
        Users,
        'Primary Email' = varCurrentUser.Email
    )
);

// Get user profile
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
        varUserProfile.'Is Manager (ooooo_ismanager)'
    )
);

// Load system settings
ClearCollect(colSystemSettings, 'System Settings');

// Parse settings
Set(varMinAdvanceNoticeDays,
    Value(
        LookUp(
            colSystemSettings,
            'Setting Name' = "MinimumAdvanceNoticeDays"
        ).'Setting Value'
    )
);

Set(varMaxOOODaysPerRequest,
    Value(
        LookUp(
            colSystemSettings,
            'Setting Name' = "MaxOOODaysPerRequest"
        ).'Setting Value'
    )
);

// Set colors
Set(varColorOnsite, RGBA(76, 175, 80, 1));
Set(varColorOffsite, RGBA(33, 150, 243, 1));
Set(varColorPending, RGBA(255, 193, 7, 1));
Set(varColorApproved, RGBA(156, 39, 176, 1));
Set(varColorRejected, RGBA(244, 67, 54, 1));
Set(varColorPrimary, RGBA(0, 120, 212, 1));

// Initialize calendar
Set(varCalendarStartDate, Today() - Mod(Weekday(Today()) - 2, 7));
Set(varCalendarEndDate, varCalendarStartDate + 6);

// Show welcome if first time
Set(varShowWelcome,
    If(
        IsBlank(varUserProfile),
        true,
        varUserProfile.'First Time User (ooooo_firsttimeuser)'
    )
);
```

4. Press **Enter** to save
5. Click **Run OnStart** (ellipsis menu → Run OnStart)

✅ **Checkpoint**: Variables initialized, no errors

---

## Part 3: Build Screens

### Screen 1: scrLoading (Welcome/Splash Screen)

**Purpose**: Show while app loads

1. **Rename Screen1**:
   - Right-click **Screen1** → **Rename** → `scrLoading`

2. **Add Background Rectangle**:
   - Insert → Rectangle
   - Name: `rectBackground`
   - Properties:
     - X: `0`
     - Y: `0`
     - Width: `Parent.Width`
     - Height: `Parent.Height`
     - Fill: `varColorPrimary`

3. **Add App Title**:
   - Insert → Text label
   - Name: `lblAppTitle`
   - Properties:
     - Text: `"OOOOO Calendar"`
     - X: `(Parent.Width - Self.Width) / 2`
     - Y: `Parent.Height / 2 - 100`
     - Font size: `32`
     - Font weight: `Bold`
     - Color: `White`

4. **Add Loading Spinner**:
   - Insert → Loading spinner (classic)
   - Name: `loadingSpinner`
   - Properties:
     - X: `(Parent.Width - Self.Width) / 2`
     - Y: `Parent.Height / 2`

5. **Add Version Label**:
   - Insert → Text label
   - Name: `lblVersion`
   - Properties:
     - Text: `"Version 1.0.0"`
     - X: `(Parent.Width - Self.Width) / 2`
     - Y: `Parent.Height - 100`
     - Color: `RGBA(255,255,255,0.7)`
     - Font size: `12`

6. **Set Screen OnVisible**:
   - Select `scrLoading`
   - OnVisible property:
   ```excel
   // Navigate to home after 1 second
   Set(varLoadingTimer, true);
   ```

7. **Add Timer**:
   - Insert → Timer
   - Name: `timerLoading`
   - Properties:
     - Duration: `1000`
     - AutoStart: `true`
     - OnTimerEnd:
     ```excel
     Navigate(scrHome, ScreenTransition.Fade)
     ```

✅ **Checkpoint**: Loading screen created

---

### Screen 2: scrHome (Dashboard)

**Purpose**: Main dashboard with quick actions

1. **Add New Screen**:
   - Home → New screen → Blank
   - Rename to `scrHome`

2. **Set Screen OnVisible**:
   ```excel
   // Load today's schedule
   Set(varTodaySchedule,
       LookUp(
           'Staff Schedules',
           'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
           'Schedule Date (ooooo_scheduledate)' = Today() &&
           'Is Active (ooooo_isactive)' = true
       )
   );

   // Load upcoming schedule
   ClearCollect(colUpcomingSchedule,
       Filter(
           'Staff Schedules',
           'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
           'Schedule Date (ooooo_scheduledate)' >= Today() &&
           'Schedule Date (ooooo_scheduledate)' <= Today() + 7 &&
           'Is Active (ooooo_isactive)' = true
       )
   );

   // Load pending approvals (if manager)
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

3. **Add Header Container**:
   - Insert → Container (horizontal)
   - Name: `ctnHeader`
   - Properties:
     - X: `0`
     - Y: `0`
     - Width: `Parent.Width`
     - Height: `80`
     - Fill: `varColorPrimary`

4. **Add Title in Header**:
   - Insert → Label (inside container)
   - Name: `lblHomeTitle`
   - Properties:
     - Text: `"OOOOO Calendar"`
     - Font size: `24`
     - Font weight: `Bold`
     - Color: `White`
     - X: `20`
     - Y: `20`

5. **Add User Greeting**:
   - Insert → Label (inside container)
   - Name: `lblGreeting`
   - Properties:
     - Text: `"Hello, " & First(Split(varCurrentUser.FullName, " ")).Value & "!"`
     - X: `Parent.Width - Self.Width - 20`
     - Y: `30`
     - Color: `White`

6. **Add Today's Status Card**:
   - Insert → Container (vertical)
   - Name: `ctnTodayStatus`
   - Properties:
     - X: `40`
     - Y: `120`
     - Width: `400`
     - Height: `200`
     - Border thickness: `1`
     - Border color: `LightGray`
     - Corner radius: `8`

7. **Add Status Card Title**:
   - Insert → Label (in container)
   - Name: `lblTodayStatusTitle`
   - Properties:
     - Text: `"Today's Status"`
     - Font size: `18`
     - Font weight: `SemiBold`
     - X: `20`
     - Y: `20`

8. **Add Current Status Display**:
   - Insert → Label (in container)
   - Name: `lblCurrentStatus`
   - Properties:
     - Text: ```excel
       If(
           IsBlank(varTodaySchedule),
           "No status set",
           Text(varTodaySchedule.'Status (ooooo_status)')
       )
       ```
     - Font size: `24`
     - Color: ```excel
       If(
           IsBlank(varTodaySchedule),
           Gray,
           Switch(
               varTodaySchedule.'Status (ooooo_status)',
               'Status (ooooo_status)'.Onsite, varColorOnsite,
               'Status (ooooo_status)'.Offsite, varColorOffsite,
               Gray
           )
       )
       ```

9. **Add Quick Status Buttons**:
   - Insert → Button
   - Name: `btnOnsite`
   - Properties:
     - Text: `"🏢 Onsite"`
     - X: `20`
     - Y: `120`
     - Width: `170`
     - Fill: `varColorOnsite`
     - OnSelect:
     ```excel
     If(
         IsBlank(
             LookUp(
                 'Staff Schedules',
                 'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
                 'Schedule Date (ooooo_scheduledate)' = Today()
             )
         ),
         Patch(
             'Staff Schedules',
             Defaults('Staff Schedules'),
             {
                 'Request ID': "STATUS-" & Text(Today(), "yyyymmdd") & "-" & Left(varCurrentUser.Email, 3),
                 'Employee (ooooo_employee)': varCurrentSystemUser,
                 'Employee Email (ooooo_employeeemail)': varCurrentUser.Email,
                 'Schedule Date (ooooo_scheduledate)': Today(),
                 'Status (ooooo_status)': 'Status (ooooo_status)'.Onsite,
                 'Request Type (ooooo_requesttype)': 'Request Type (ooooo_requesttype)'.'Regular Schedule',
                 'Submission Date/Time (ooooo_submissiondatetime)': Now(),
                 'Is Active (ooooo_isactive)': true
             }
         ),
         Patch(
             'Staff Schedules',
             LookUp(
                 'Staff Schedules',
                 'Employee (ooooo_employee)'.'Primary Email' = varCurrentUser.Email &&
                 'Schedule Date (ooooo_scheduledate)' = Today()
             ),
             {'Status (ooooo_status)': 'Status (ooooo_status)'.Onsite}
         )
     );
     Notify("Status updated to Onsite", NotificationType.Success);
     Refresh('Staff Schedules');
     ```

   - Duplicate button (Ctrl+C, Ctrl+V)
   - Name: `btnOffsite`
   - Properties:
     - Text: `"🏠 Offsite"`
     - X: `210`
     - Fill: `varColorOffsite`
     - OnSelect: (same as Onsite but change status to `Offsite`)

10. **Add Navigation Buttons**:
    - Insert → Button
    - Name: `btnMySchedule`
    - Properties:
      - Text: `"📅 My Schedule"`
      - X: `480`
      - Y: `120`
      - Width: `300`
      - Height: `80`
      - Fill: `White`
      - BorderColor: `varColorPrimary`
      - BorderThickness: `2`
      - Color: `varColorPrimary`
      - OnSelect: `Navigate(scrMySchedule, ScreenTransition.CoverRight)`

    - Duplicate for:
      - `btnRequestOff`: "🌴 Request Time Off" → Navigate to scrRequestForm
      - `btnTeamCalendar`: "📊 Team Calendar" → Navigate to scrTeamCalendar
      - `btnManagerApprovals`: "✅ Approvals" → Navigate to scrManagerApprovals (Visible: varIsManager)

11. **Add Upcoming Schedule Gallery**:
    - Insert → Vertical gallery
    - Name: `galUpcoming`
    - Properties:
      - Items: `colUpcomingSchedule`
      - X: `40`
      - Y: `360`
      - Width: `Parent.Width - 80`
      - Height: `300`
      - TemplateSize: `60`

    - Inside gallery template:
      - Label (Date): `Text(ThisItem.'Schedule Date (ooooo_scheduledate)', "ddd, mmm dd")`
      - Label (Status): `Text(ThisItem.'Status (ooooo_status)')`
      - Icon (Status color circle)

✅ **Checkpoint**: Home screen functional

---

## Part 4: Remaining Screens (Simplified)

Due to length, I'll provide formulas for key screens. Full details in separate files:

### Screen 3: scrMySchedule
- Filter user's own schedules
- Show calendar view
- Request history gallery
- Cancel request functionality

### Screen 4: scrRequestForm
- Date pickers (start/end)
- Request type dropdown
- Comments field
- Validation formulas
- Submit button with Patch formula

### Screen 5: scrTeamCalendar
- Team member list (gallery)
- Date range selector
- Grid view with colors
- Filter capabilities

### Screen 6: scrManagerApprovals
- Pending approvals gallery
- Approve/Reject buttons
- Manager comments field
- Approval history

---

## Part 5: Publish App (5 minutes)

1. Click **File** → **Save**
2. Enter version notes: "Initial version v1.0"
3. Click **Save**
4. Click **Publish**
5. Click **Publish this version**
6. Click **Close**

✅ **Success**: App published!

---

## Part 6: Add to Solution (5 minutes)

The app should already be in your solution since you created it there.

Verify:
1. Go to **Solutions** → **OOOOO Calendar**
2. Click **Apps**
3. See "OOOOO Calendar" canvas app

---

## Testing Checklist

- [ ] App loads without errors
- [ ] Today's status updates correctly
- [ ] Navigation works between screens
- [ ] Data loads from Dataverse
- [ ] Formulas execute correctly
- [ ] Mobile responsive (test in Teams mobile)

---

## Next Steps

1. Create Power Automate flows (see power-automate-flows-builder.md)
2. Test full workflow end-to-end
3. Export solution

---

**Note**: This guide provides the core structure. For complete screen-by-screen formulas with all controls, see the formula reference documents.

**Builder Guide Version**: 1.0.0
**Last Updated**: November 2025
