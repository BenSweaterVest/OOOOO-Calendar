# OOOOO Calendar - Dataverse Solution Builder Guide

This guide walks you through **building the complete Dataverse solution** from scratch, so you can export it as `OOOOOCalendar_1_0_0_0.zip` for deployment.

**Time Required**: 4-6 hours (first time)
**Skill Level**: Intermediate Power Platform

---

## Overview

You will build:
- ✅ 4 Dataverse tables
- ✅ 2 Security roles
- ✅ 1 Canvas app
- ✅ 3 Power Automate flows
- ✅ 1 Exportable solution package

---

## Prerequisites

### Required Access
- Microsoft Teams license
- Power Apps environment maker permissions
- Ability to create Dataverse for Teams environment

### Tools Needed
- Microsoft Teams (desktop or web)
- Modern web browser
- Text editor (for copying formulas)

---

## Phase 1: Environment Setup (15 minutes)

### Step 1.1: Create Dataverse for Teams Environment

1. **Open Microsoft Teams**
2. Click **Power Apps** in the left sidebar
   - If not visible: Apps → Search "Power Apps" → Add
3. Click **Build** tab
4. Select a team for development (or create new "OOOOO Dev Team")
5. Wait for environment creation (~2-3 minutes)

✅ **Checkpoint**: You see "Create your first app" screen

### Step 1.2: Create Solution

1. Click **See all** (opens Power Apps in browser)
2. Click **Solutions** (left menu)
3. Click **+ New solution**
4. Fill in details:
   - **Display name**: `OOOOO Calendar`
   - **Name**: `OOOOOCalendar` (no spaces)
   - **Publisher**: Click **+ New publisher**
     - Display name: `Minnesota IT Services`
     - Name: `MNITServices`
     - Prefix: `ooooo`
     - Choice value prefix: `10000`
     - Click **Save**
   - **Version**: `1.0.0.0`
   - **Description**: `Teams Staff Scheduling & Approval System`
5. Click **Create**

✅ **Checkpoint**: Solution "OOOOO Calendar" appears in list

---

## Phase 2: Create Dataverse Tables (90 minutes)

### Table 1: Staff Schedule (ooooo_staffschedule)

**Purpose**: Main schedule and time-off request data

1. Open your solution: **OOOOO Calendar**
2. Click **+ New** → **Table** → **Table**
3. Configure table:
   - **Display name**: `Staff Schedule`
   - **Plural name**: `Staff Schedules`
   - **Description**: `Main schedule and time-off request data`
   - **Enable attachments**: ☐ Unchecked
4. Click **Save**

#### Primary Column
The system creates "Name" column by default. Edit it:
1. Click **Name** column
2. Change:
   - **Display name**: `Request ID`
   - **Description**: `Unique identifier (e.g., REQ-20250115-001)`
   - **Max length**: `100`
3. Click **Save**

#### Add Additional Columns

For each column below, click **+ New** → **Column**:

**1. Employee** (Lookup to User)
```
Display name: Employee
Data type: Lookup
Related table: User
Required: Business required
Description: Link to employee user record
```

**2. Employee Email** (Text)
```
Display name: Employee Email
Data type: Single line of text
Max length: 200
Required: Business required
Description: Employee email address
```

**3. Schedule Date** (Date Only)
```
Display name: Schedule Date
Data type: Date and Time
Format: Date only
Required: Business required
Description: Date for the schedule entry
```

**4. Status** (Choice)
```
Display name: Status
Data type: Choice
Required: Business required
Choices:
  - Label: Onsite, Value: 1, External Value: Onsite, Color: #4CAF50
  - Label: Offsite, Value: 2, External Value: Offsite, Color: #2196F3
  - Label: OOO-Pending, Value: 3, External Value: OOO-Pending, Color: #FFC107
  - Label: OOO-Approved, Value: 4, External Value: OOO-Approved, Color: #9C27B0
  - Label: OOO-Rejected, Value: 5, External Value: OOO-Rejected, Color: #F44336
Default choice: Onsite (1)
Description: Current status of the schedule entry
```

**5. Request Type** (Choice)
```
Display name: Request Type
Data type: Choice
Required: Business required
Choices:
  - Label: Regular Schedule, Value: 1
  - Label: Vacation, Value: 2
  - Label: Sick Leave, Value: 3
  - Label: Personal Day, Value: 4
  - Label: Other, Value: 5
Default choice: Regular Schedule (1)
Description: Type of request or schedule entry
```

**6. Start Date** (Date Only)
```
Display name: Start Date
Data type: Date and Time
Format: Date only
Required: Optional
Description: Start date for multi-day OOO requests
```

**7. End Date** (Date Only)
```
Display name: End Date
Data type: Date and Time
Format: Date only
Required: Optional
Description: End date for multi-day OOO requests
```

**8. Number of Days** (Whole Number)
```
Display name: Number of Days
Data type: Whole Number
Min value: 0
Max value: 365
Required: Optional
Description: Calculated number of days in request
```

**9. Comments** (Multi-line Text)
```
Display name: Comments
Data type: Multiple lines of text
Max length: 2000
Required: Optional
Description: Optional comments from employee
```

**10. Submission Date/Time** (Date and Time)
```
Display name: Submission Date/Time
Data type: Date and Time
Format: Date and time
Required: Business required
Description: When the request was submitted
```

**11. Approver** (Lookup to User)
```
Display name: Approver
Data type: Lookup
Related table: User
Required: Optional
Description: Manager who approved/rejected
```

**12. Approval Date/Time** (Date and Time)
```
Display name: Approval Date/Time
Data type: Date and Time
Format: Date and time
Required: Optional
Description: When approval/rejection occurred
```

**13. Manager Comments** (Multi-line Text)
```
Display name: Manager Comments
Data type: Multiple lines of text
Max length: 2000
Required: Optional
Description: Manager's comments on approval/rejection
```

**14. Approval Request ID** (Text)
```
Display name: Approval Request ID
Data type: Single line of text
Max length: 100
Required: Optional
Description: Teams approval action request ID for tracking
```

**15. Calendar Event ID** (Text)
```
Display name: Calendar Event ID
Data type: Single line of text
Max length: 200
Required: Optional
Description: Outlook calendar event ID for synchronization
```

**16. Is Active** (Yes/No)
```
Display name: Is Active
Data type: Yes/No
Default: Yes
Required: Business required
Description: Whether this entry is active (not cancelled)
```

✅ **Checkpoint**: Staff Schedule table has 17 columns total (including system columns)

---

### Table 2: Approval History (ooooo_approvalhistory)

**Purpose**: Complete audit trail

1. In solution, click **+ New** → **Table** → **Table**
2. Configure:
   - **Display name**: `Approval History`
   - **Plural name**: `Approval Histories`
   - **Ownership**: Organization-owned
   - **Description**: `Complete audit trail of all approval actions`
3. Click **Save**

#### Primary Column
Edit "Name" column:
```
Display name: History ID
Max length: 100
Description: Unique identifier for this history record
```

#### Add Columns

**1. Related Request** (Lookup to Staff Schedule)
```
Display name: Related Request
Data type: Lookup
Related table: Staff Schedule
Required: Business required
Description: Link to the original schedule request
```

**2. Employee** (Lookup to User)
```
Display name: Employee
Data type: Lookup
Related table: User
Required: Business required
Description: Employee who made the request
```

**3. Request Start Date** (Date Only)
```
Display name: Request Start Date
Data type: Date and Time
Format: Date only
Required: Business required
Description: Start date of the request
```

**4. Request End Date** (Date Only)
```
Display name: Request End Date
Data type: Date and Time
Format: Date only
Required: Optional
Description: End date of the request
```

**5. Request Type** (Choice)
```
Display name: Request Type
Data type: Choice
Required: Business required
Choices:
  - Label: Vacation, Value: 2
  - Label: Sick Leave, Value: 3
  - Label: Personal Day, Value: 4
  - Label: Other, Value: 5
Description: Type of time-off request
```

**6. Action** (Choice)
```
Display name: Action
Data type: Choice
Required: Business required
Choices:
  - Label: Submitted, Value: 1
  - Label: Approved, Value: 2
  - Label: Rejected, Value: 3
  - Label: Cancelled, Value: 4
  - Label: Modified, Value: 5
Description: Action taken on the request
```

**7. Action Date/Time** (Date and Time)
```
Display name: Action Date/Time
Data type: Date and Time
Format: Date and time
Required: Business required
Description: When the action occurred
```

**8. Actor** (Lookup to User)
```
Display name: Actor
Data type: Lookup
Related table: User
Required: Business required
Description: Person who performed the action
```

**9. Actor Comments** (Multi-line Text)
```
Display name: Actor Comments
Data type: Multiple lines of text
Max length: 2000
Required: Optional
Description: Comments from the person performing the action
```

**10. Original Request Details** (Multi-line Text)
```
Display name: Original Request Details
Data type: Multiple lines of text
Max length: 4000
Required: Optional
Description: JSON snapshot of original request data
```

**11. Approval Duration (hours)** (Decimal Number)
```
Display name: Approval Duration (hours)
Data type: Decimal number
Decimal places: 2
Min value: 0
Max value: 10000
Required: Optional
Description: Time from submission to approval/rejection
```

✅ **Checkpoint**: Approval History table created

---

### Table 3: User Profile (ooooo_userprofile)

**Purpose**: Extended user information and manager relationships

1. In solution, click **+ New** → **Table** → **Table**
2. Configure:
   - **Display name**: `User Profile`
   - **Plural name**: `User Profiles`
   - **Ownership**: User-owned
   - **Description**: `Extended user profile information and manager relationships`
3. Click **Save**

#### Primary Column
Edit "Name" column:
```
Display name: Display Name
Max length: 200
Description: User's full name
```

#### Add Columns

**1. User** (Lookup to User)
```
Display name: User
Data type: Lookup
Related table: User
Required: Business required
Description: Link to system user account
```

**2. Email** (Text)
```
Display name: Email
Data type: Single line of text
Max length: 200
Required: Business required
Description: User's email address
```

**3. Manager** (Lookup to User)
```
Display name: Manager
Data type: Lookup
Related table: User
Required: Business required
Description: User's direct manager
```

**4. Manager Email** (Text)
```
Display name: Manager Email
Data type: Single line of text
Max length: 200
Required: Business required
Description: Manager's email address
```

**5. Department** (Text)
```
Display name: Department
Data type: Single line of text
Max length: 100
Required: Optional
Description: Department or team
```

**6. Is Manager** (Yes/No)
```
Display name: Is Manager
Data type: Yes/No
Default: No
Required: Business required
Description: Whether this user has manager privileges
```

**7. Is Active** (Yes/No)
```
Display name: Is Active
Data type: Yes/No
Default: Yes
Required: Business required
Description: Whether user is active in the system
```

**8. Notification Preferences** (Choice)
```
Display name: Notification Preferences
Data type: Choice
Required: Business required
Choices:
  - Label: Teams Only, Value: 1
  - Label: Email Only, Value: 2
  - Label: Both, Value: 3
  - Label: None, Value: 4
Default: Both (3)
Description: User's notification preferences
```

**9. Time Zone** (Choice)
```
Display name: Time Zone
Data type: Choice
Required: Optional
Choices:
  - Label: Eastern, Value: 1
  - Label: Central, Value: 2
  - Label: Mountain, Value: 3
  - Label: Pacific, Value: 4
Default: Central (2)
Description: User's time zone
```

**10. First Time User** (Yes/No)
```
Display name: First Time User
Data type: Yes/No
Default: Yes
Required: Optional
Description: Whether to show welcome splash screen
```

✅ **Checkpoint**: User Profile table created

---

### Table 4: System Setting (ooooo_systemsetting)

**Purpose**: Application configuration

1. In solution, click **+ New** → **Table** → **Table**
2. Configure:
   - **Display name**: `System Setting`
   - **Plural name**: `System Settings`
   - **Ownership**: Organization-owned
   - **Description**: `Application configuration and settings`
3. Click **Save**

#### Primary Column
Edit "Name" column:
```
Display name: Setting Name
Max length: 100
Description: Unique setting identifier
```

#### Add Columns

**1. Setting Value** (Text)
```
Display name: Setting Value
Data type: Single line of text
Max length: 1000
Required: Business required
Description: Value of the setting
```

**2. Setting Type** (Choice)
```
Display name: Setting Type
Data type: Choice
Required: Business required
Choices:
  - Label: Text, Value: 1
  - Label: Number, Value: 2
  - Label: Boolean, Value: 3
  - Label: JSON, Value: 4
Description: Data type of the setting
```

**3. Description** (Multi-line Text)
```
Display name: Description
Data type: Multiple lines of text
Max length: 1000
Required: Optional
Description: Description of what this setting controls
```

**4. Category** (Choice)
```
Display name: Category
Data type: Choice
Required: Business required
Choices:
  - Label: General, Value: 1
  - Label: Approval, Value: 2
  - Label: Notification, Value: 3
  - Label: Calendar, Value: 4
  - Label: Security, Value: 5
Description: Setting category
```

**5. Is Editable** (Yes/No)
```
Display name: Is Editable
Data type: Yes/No
Default: Yes
Required: Business required
Description: Whether this setting can be changed by admins
```

✅ **Checkpoint**: All 4 tables created!

---

## Phase 3: Add Default System Settings (10 minutes)

Now populate the System Settings table with default values:

1. Navigate to **Tables** → **System Setting** → **Data**
2. Click **+ New row** for each setting below:

### Setting 1: MinimumAdvanceNoticeDays
```
Setting Name: MinimumAdvanceNoticeDays
Setting Value: 3
Setting Type: Number
Description: Minimum days of advance notice required for OOO requests
Category: Approval
Is Editable: Yes
```

### Setting 2: MaxOOODaysPerRequest
```
Setting Name: MaxOOODaysPerRequest
Setting Value: 30
Setting Type: Number
Description: Maximum consecutive days allowed in a single OOO request
Category: Approval
Is Editable: Yes
```

### Setting 3: EnableDailyReminders
```
Setting Name: EnableDailyReminders
Setting Value: true
Setting Type: Boolean
Description: Enable daily morning reminders for status updates
Category: Notification
Is Editable: Yes
```

### Setting 4: ReminderTime
```
Setting Name: ReminderTime
Setting Value: 08:00
Setting Type: Text
Description: Time to send daily reminders (HH:MM format)
Category: Notification
Is Editable: Yes
```

### Setting 5: SyncToOutlookCalendar
```
Setting Name: SyncToOutlookCalendar
Setting Value: true
Setting Type: Boolean
Description: Automatically sync approved OOO to Outlook calendar
Category: Calendar
Is Editable: Yes
```

### Setting 6: WorkingDays
```
Setting Name: WorkingDays
Setting Value: [1,2,3,4,5]
Setting Type: JSON
Description: Working days of the week (0=Sunday, 6=Saturday)
Category: General
Is Editable: Yes
```

### Setting 7: ColorScheme
```
Setting Name: ColorScheme
Setting Value: {"Onsite":"#4CAF50","Offsite":"#2196F3","OOO-Pending":"#FFC107","OOO-Approved":"#9C27B0"}
Setting Type: JSON
Description: Color codes for different status types
Category: General
Is Editable: Yes
```

✅ **Checkpoint**: 7 default settings added

---

## Phase 4: Create Security Roles (30 minutes)

See separate document: `security-roles-setup.md`

---

## Phase 5: Build Canvas App (120 minutes)

See separate document: `canvas-app-builder-guide.md`

---

## Phase 6: Create Power Automate Flows (90 minutes)

See separate document: `power-automate-flows-builder.md`

---

## Phase 7: Export Solution (10 minutes)

### Step 7.1: Prepare for Export

1. Navigate to **Solutions**
2. Click **OOOOO Calendar**
3. Verify all components are present:
   - ☑ 4 Tables
   - ☑ 2 Security Roles
   - ☑ 1 Canvas App
   - ☑ 3 Cloud Flows

### Step 7.2: Run Solution Checker (Optional but Recommended)

1. Click **Solution checker** → **Run**
2. Wait for analysis (~2-5 minutes)
3. Review and fix any critical issues
4. Re-run until no critical issues

### Step 7.3: Export Solution

1. Click **Export solution**
2. Click **Publish** (publishes all customizations)
3. Wait for publish to complete
4. Click **Next**
5. Choose **Unmanaged**
6. Click **Export**
7. Wait for export (~1-2 minutes)
8. Download `OOOOOCalendar_1_0_0_0.zip`

✅ **Success**: You now have the importable solution package!

---

## Phase 8: Test Import (15 minutes)

### Test in Another Environment

1. Create new team or use different environment
2. Navigate to **Solutions** → **Import solution**
3. Upload `OOOOOCalendar_1_0_0_0.zip`
4. Configure connections
5. Click **Import**
6. Verify all components imported successfully

✅ **Checkpoint**: Solution imports successfully

---

## Building Timeline

| Phase | Task | Time |
|-------|------|------|
| 1 | Environment Setup | 15 min |
| 2 | Create Tables | 90 min |
| 3 | Add Default Data | 10 min |
| 4 | Security Roles | 30 min |
| 5 | Canvas App | 120 min |
| 6 | Power Automate Flows | 90 min |
| 7 | Export Solution | 10 min |
| 8 | Test Import | 15 min |
| **Total** | **First Build** | **~6 hours** |

**Subsequent exports**: ~5 minutes (just export)

---

## Next Steps

After building the solution:

1. ✅ Test thoroughly in dev environment
2. ✅ Import to production environment
3. ✅ Configure user profiles
4. ✅ Train users
5. ✅ Monitor and iterate

---

## Troubleshooting

### Issue: Can't create Dataverse environment
**Solution**: Ensure you have Teams license and environment maker permissions

### Issue: Tables not appearing in solution
**Solution**: Make sure you created them INSIDE the solution, not outside

### Issue: Export fails
**Solution**: Run solution checker, fix issues, try again

### Issue: Import fails in another environment
**Solution**: Ensure connections are created/configured before import

---

## Support Files

This builder guide references:
- `security-roles-setup.md` - Detailed security role configuration
- `canvas-app-builder-guide.md` - Complete app build instructions
- `power-automate-flows-builder.md` - Flow creation step-by-step

Continue to next document to build each component!

---

**Builder Guide Version**: 1.0.0
**Last Updated**: November 2025
**Estimated Build Time**: 4-6 hours (first time)
