# OOOOO Calendar - Complete Installation & Build Guide

Welcome! This comprehensive guide covers **all installation methods** for the OOOOO Calendar Teams app - from quick imports to manual builds.

**Choose your path**:
- 🚀 **[Method 1: Import Pre-Built Solution](#method-1-import-pre-built-solution)** - 30-60 minutes (Recommended)
- 🔧 **[Method 2: Build from Source](#method-2-build-from-source)** - 1-2 hours (For developers)
- 🛠️ **[Method 3: Manual Table Creation](#method-3-manual-table-creation)** - 2-4 hours (Restricted environments)

---

## Prerequisites

**All Methods Require**:
- Microsoft Teams license (Dataverse for Teams included)
- Team ownership or member permissions
- **No premium licenses required!**

**Method 2 Additionally Requires**:
- Power Platform CLI (PAC CLI)
- Windows PowerShell 5.1+ or cross-platform terminal

---

# Method 1: Import Pre-Built Solution

**Time**: 30-60 minutes
**Best for**: Quick deployment, standard installations
**You need**: Pre-built solution package `OOOOOCalendar_1_0_0_0.zip`

## Step 1: Download Solution Package

Download the pre-built solution:
- **File**: `OOOOOCalendar_1_0_0_0.cab` or `.zip`
- **Size**: ~5-10 MB
- **Source**: [Download from releases](../../releases) or contact your IT administrator

---

## Step 2: Import Solution to Power Apps

### 2.1 Open Power Apps in Teams

1. Open **Microsoft Teams**
2. Click **Power Apps** in the left sidebar
   - If not visible: Click **Apps** → Search "Power Apps" → **Add**
3. Click **Build** tab
4. Select your team from the list

### 2.2 Import the Solution

1. Click **See all** (opens Power Apps maker portal)
2. Click **Solutions** (left menu)
3. Click **Import solution** (top toolbar)
4. Click **Browse**
5. Select `OOOOOCalendar_1_0_0_0.cab` or `.zip`
6. Click **Next**

### 2.3 Configure Connections

The import will prompt you to create connections if they don't exist:

**Required Connections**:
- ✅ **Microsoft Dataverse** - Click **Select a connection** → **+ New connection** → **Create**
- ✅ **Office 365 Users** - Click **Select a connection** → **+ New connection** → **Create**
- ✅ **Office 365 Outlook** - Click **Select a connection** → **+ New connection** → **Create**
- ✅ **Approvals** - Click **Select a connection** → **+ New connection** → **Create**

All connections should show green checkmarks ✓

### 2.4 Complete Import

1. Click **Import**
2. Wait for import to complete (2-5 minutes)
3. You'll see: **"Solution 'OOOOO Calendar' imported successfully"**

✅ **Success!** The solution is now installed in your environment.

---

## Step 3: Configure Security

### 3.1 Populate User Profiles

**Important**: You must add team members to the User Profiles table before they can use the app.

1. In Power Apps, click **Tables**
2. Find and open **User Profile**
3. Click **+ New row** for each team member

**For each user, enter**:
- **Display Name**: Full name (e.g., "John Doe")
- **User**: Select from people picker
- **Email**: user@domain.com
- **Manager**: Select manager from people picker
- **Manager Email**: manager@domain.com
- **Department**: (Optional) Team name
- **Is Manager**: ✓ Check if this person approves requests
- **Is Active**: ✓ (checked)
- **Notification Preferences**: Both (default)
- **Time Zone**: Central (or your timezone)
- **First Time User**: ✓ (checked)

**Tip**: For 10+ users, consider using Excel import:
- Export template from table
- Fill in spreadsheet
- Import data back

### 3.2 Assign Security Roles

**All Staff**:
1. Go to **Settings** → **Security** → **Teams**
2. Select your team
3. Assign **OOOOO Calendar User** role to all team members

**Managers**:
1. Same as above
2. Additionally assign **OOOOO Calendar Manager** role to managers

---

## Step 4: Enable Power Automate Flows

Power Automate flows are imported but disabled by default.

1. In Solutions, click **OOOOO Calendar**
2. Click **Cloud flows** (filter on left)
3. For each flow, click the flow name:
   - **OOOOO - OOO Approval Workflow** ← Required
   - **OOOOO - Calendar Sync** ← Required
   - **OOOOO - Daily Reminder** ← Optional

4. For each flow:
   - If prompted to update connections, click **Edit**
   - Verify all connections are selected
   - Click **Turn on** (top right)
   - Verify status shows "On"

✅ **Test**: Create a test OOO request to verify approval workflow works

---

## Step 5: Add App to Teams

### 5.1 Open the Canvas App

1. In Solutions, click **OOOOO Calendar**
2. Click **Apps** (filter)
3. Click **OOOOO Calendar** (canvas app)
4. App opens in play mode

### 5.2 Add as Teams Tab

**Method A: From Power Apps**
1. In the running app, click **...** (more options)
2. Click **Add to Teams**
3. Select **Add to a team**
4. Choose your team
5. Choose a channel (e.g., "General")
6. Tab name: "OOOOO Calendar" or "Schedule"
7. Click **Save**

**Method B: From Teams**
1. Open Microsoft Teams
2. Go to your team → select a channel
3. Click **+** (Add a tab)
4. Search for "Power Apps"
5. Select **Power Apps**
6. Choose **OOOOO Calendar**
7. Click **Save**

✅ **Success!** The app is now available as a tab in your Teams channel.

---

## Step 6: Test the Installation

1. **Open the app tab** in Teams
2. **Verify it loads** without errors
3. **Check your status** on home screen
4. **Submit a test OOO request**:
   - Click "Request Time Off"
   - Enter dates 3+ days in future
   - Select "Vacation"
   - Add comment: "Testing the app"
   - Submit

5. **Manager checks Teams** for approval request
6. **Manager approves** the request
7. **Verify**:
   - Employee receives Teams notification
   - Status shows "OOO-Approved" in app
   - Outlook calendar event created
   - Request appears in "My Schedule"

✅ If all steps work, the app is ready for team use!

**Jump to**: [Post-Installation](#post-installation)

---

# Method 2: Build from Source

**Time**: 1-2 hours
**Best for**: Developers, custom deployments, version control
**You need**: Source code repository, Power Platform CLI

## Prerequisites for Building

### Install Power Platform CLI

**Option A: Via .NET SDK (Recommended)**

```powershell
# Install .NET SDK first from https://dotnet.microsoft.com/download

# Then install PAC CLI globally
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac --version
```

**Option B: Standalone Installer**

Download from: https://aka.ms/PowerAppsCLI

### Windows PowerShell Requirements

PowerShell 5.1 or later (or use PAC CLI directly on Mac/Linux)

---

## Build Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/OOOOO-Calendar.git
cd OOOOO-Calendar
```

---

## Build Step 2: Pack the Solution

### Option A: Using Build Script (Windows)

```powershell
# Unblock the script (Windows security requirement)
Unblock-File -Path .\scripts\pack-solution.ps1

# Run the pack script
.\scripts\pack-solution.ps1
```

The script will:
- ✅ Verify PAC CLI is installed
- ✅ Check all required solution files exist
- ✅ Pack the solution into `OOOOOCalendar_1_0_0_0.zip`
- ✅ Display file size and next steps

### Option B: Manual PAC CLI Command

```powershell
# From repository root
pac solution pack \
    --zipfile OOOOOCalendar_1_0_0_0.zip \
    --folder ./solution \
    --packagetype Unmanaged \
    --errorlevel Verbose
```

---

## Build Step 3: Import Built Solution

Now follow **[Method 1: Steps 2-6](#step-2-import-solution-to-power-apps)** to import your built package.

---

## Understanding What Gets Built

### Solution Structure

```
solution/
├── Other/
│   ├── Solution.xml            # Solution metadata
│   └── Customizations.xml      # Customizations manifest
│
├── Entities/                   # Dataverse tables
│   ├── ooooo_staffschedule/
│   │   └── Entity.xml          # Staff Schedule definition
│   ├── ooooo_approvalhistory/
│   │   └── Entity.xml          # Approval History definition
│   ├── ooooo_userprofile/
│   │   └── Entity.xml          # User Profile definition
│   └── ooooo_systemsetting/
│       └── Entity.xml          # System Settings definition
│
└── [Content_Types].xml         # Package manifest
```

### What's Included in Built Package

- ✅ Solution metadata (name, version, publisher)
- ✅ 4 Dataverse table definitions
- ✅ Table metadata (names, descriptions)
- ✅ Base table structures

### Creating a Complete Solution

For a **fully functional** solution with canvas app and flows:

1. **Build base package** (above steps)
2. **Import into Power Apps**
3. **Create table columns** using `Reference/dataverse-tables-schema.json`
4. **Build canvas app** following `docs/CANVAS-APP-BUILDING-GUIDE.md`
5. **Create flows** using `Reference/power-automate/ooo-approval-flow-design.md`
6. **Export solution** from Power Apps
7. **Unpack for version control** (optional):

```powershell
.\scripts\unpack-solution.ps1
git add solution/
git commit -m "Add complete solution"
```

---

## Build Troubleshooting

### Error: "File cannot be loaded because running scripts is disabled"

**Windows security blocks downloaded PowerShell scripts**

```powershell
# Solution 1: Unblock the script
Unblock-File -Path .\scripts\pack-solution.ps1

# Solution 2: Change execution policy (admin)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "PAC CLI not found"

```powershell
# Install PAC CLI
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Or download standalone: https://aka.ms/PowerAppsCLI
```

### Error: "Missing required solution files"

```powershell
# Verify you're in repository root
dir solution\Other\Solution.xml
dir solution\Entities\
```

### Package builds but is small (~10 KB)

**This is expected!** The base package contains only table metadata. To create a full 5-10 MB solution, follow the "Creating a Complete Solution" steps above.

**Jump to**: [Post-Installation](#post-installation)

---

# Method 3: Manual Table Creation

**Time**: 2-4 hours
**Best for**: Restricted environments, custom requirements, learning
**You need**: Power Apps access, table creation permissions

**When to use this method**:
- Solution import is blocked by IT policy
- You need to customize table structure before deployment
- Environment restrictions prevent package imports
- You want to understand the complete data model

---

## Manual Creation Overview

You will manually create 4 custom Dataverse tables:
1. **Staff Schedule** - Main schedule and time-off request data (17 columns)
2. **Approval History** - Audit trail of approval actions (11 columns)
3. **User Profile** - Extended user profile and manager relationships (11 columns)
4. **System Setting** - Application configuration (6 columns + default data)

---

## Table 1: Staff Schedule

### Create the Table

1. Open **Power Apps** (https://make.powerapps.com or Power Apps in Teams)
2. Select your environment
3. Click **Tables** → **+ New table** → **Create new table**
4. Configure:
   - **Display name**: `Staff Schedule`
   - **Plural display name**: `Staff Schedules`
   - **Description**: `Main schedule and time-off request data`
   - **Primary column**: Rename to `Request ID`
5. Click **Save**

### Add Columns

Click **+ New column** for each field below:

#### Request ID (Primary - Already Created)
- **Display name**: `Request ID`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: ✓ Business required
- **Description**: `Unique identifier (e.g., REQ-20250115-001)`

#### Employee
- **Display name**: `Employee`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required

#### Employee Email
- **Display name**: `Employee Email`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required

#### Schedule Date
- **Display name**: `Schedule Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: ✓ Business required

#### Status
- **Display name**: `Status`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `Onsite` = 1
  - `Offsite` = 2
  - `OOO-Pending` = 3
  - `OOO-Approved` = 4
  - `OOO-Rejected` = 5
- **Default choice**: `Onsite`

#### Request Type
- **Display name**: `Request Type`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Choices**:
  - `Regular Schedule` = 1
  - `Vacation` = 2
  - `Sick Leave` = 3
  - `Personal Day` = 4
  - `Other` = 5
- **Default choice**: `Regular Schedule`

#### Start Date
- **Display name**: `Start Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: No

#### End Date
- **Display name**: `End Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: No

#### Number of Days
- **Display name**: `Number of Days`
- **Data type**: `Whole Number`
- **Min value**: `0`
- **Max value**: `365`
- **Required**: No

#### Comments
- **Display name**: `Comments`
- **Data type**: `Multiline text`
- **Max length**: `2000`
- **Required**: No

#### Submission Date/Time
- **Display name**: `Submission Date/Time`
- **Data type**: `Date and Time`
- **Format**: `Date and time`
- **Required**: ✓ Business required

#### Approved By
- **Display name**: `Approved By`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: No

#### Approval Date/Time
- **Display name**: `Approval Date/Time`
- **Data type**: `Date and Time`
- **Format**: `Date and time`
- **Required**: No

#### Manager Comments
- **Display name**: `Manager Comments`
- **Data type**: `Multiline text`
- **Max length**: `2000`
- **Required**: No

#### Approval Request ID
- **Display name**: `Approval Request ID`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: No

#### Calendar Event ID
- **Display name**: `Calendar Event ID`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: No

#### Is Active
- **Display name**: `Is Active`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: ✓ Business required

### Create Views for Staff Schedule

1. Click **Views** tab
2. Edit default view or create new:

**View 1: Active Schedules** - Filter: `Is Active` equals `Yes`
**View 2: Pending Approvals** - Filter: `Status` equals `OOO-Pending` AND `Is Active` equals `Yes`
**View 3: My Requests** - Filter: `Owner` equals `Current User`

---

## Table 2: Approval History

### Create the Table

1. Click **Tables** → **+ New table**
2. Configure:
   - **Display name**: `Approval History`
   - **Plural display name**: `Approval History`
   - **Description**: `Complete audit trail of all approval actions`
   - **Primary column**: Rename to `History ID`
   - **Ownership**: `Organization` (in Advanced options)
3. Click **Save**

### Add Columns

#### History ID (Primary)
- **Display name**: `History ID`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: ✓ Business required

#### Related Request
- **Display name**: `Related Request`
- **Data type**: `Lookup`
- **Related table**: `Staff Schedule` (created above)
- **Required**: ✓ Business required

#### Employee
- **Display name**: `Employee`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required

#### Request Start Date
- **Display name**: `Request Start Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: ✓ Business required

#### Request End Date
- **Display name**: `Request End Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: No

#### Request Type
- **Display name**: `Request Type`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Choices**:
  - `Vacation` = 2
  - `Sick Leave` = 3
  - `Personal Day` = 4
  - `Other` = 5

#### Action
- **Display name**: `Action`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Choices**:
  - `Submitted` = 1
  - `Approved` = 2
  - `Rejected` = 3
  - `Cancelled` = 4
  - `Modified` = 5

#### Action Date/Time
- **Display name**: `Action Date/Time`
- **Data type**: `Date and Time`
- **Format**: `Date and time`
- **Required**: ✓ Business required

#### Actor
- **Display name**: `Actor`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required

#### Comments
- **Display name**: `Comments`
- **Data type**: `Multiline text`
- **Max length**: `2000`
- **Required**: No

#### Original Request Details
- **Display name**: `Original Request Details`
- **Data type**: `Multiline text`
- **Max length**: `4000`
- **Required**: No

#### Approval Duration (hours)
- **Display name**: `Approval Duration (hours)`
- **Data type**: `Decimal Number`
- **Decimal places**: `2`
- **Min value**: `0`
- **Max value**: `10000`
- **Required**: No

### Create Views for Approval History

**View 1: All History** - Show all records
**View 2: Recent Approvals** - Filter: `Action` equals `Approved`, Sort: `Action Date/Time` descending

---

## Table 3: User Profile

### Create the Table

1. Click **Tables** → **+ New table**
2. Configure:
   - **Display name**: `User Profile`
   - **Plural display name**: `User Profiles`
   - **Description**: `Extended user profile information and manager relationships`
   - **Primary column**: Rename to `Display Name`
3. Click **Save**

### Add Columns

#### Display Name (Primary)
- **Display name**: `Display Name`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required

#### User
- **Display name**: `User`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required

#### Email
- **Display name**: `Email`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required

#### Manager
- **Display name**: `Manager`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required

#### Manager Email
- **Display name**: `Manager Email`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required

#### Department
- **Display name**: `Department`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: No

#### Is Manager
- **Display name**: `Is Manager`
- **Data type**: `Yes/No`
- **Default value**: No
- **Required**: ✓ Business required

#### Is Active
- **Display name**: `Is Active`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: ✓ Business required

#### Notification Preferences
- **Display name**: `Notification Preferences`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Choices**:
  - `Teams Only` = 1
  - `Email Only` = 2
  - `Both` = 3
  - `None` = 4
- **Default choice**: `Both`

#### Time Zone
- **Display name**: `Time Zone`
- **Data type**: `Choice`
- **Required**: No
- **Choices**:
  - `Eastern` = 1
  - `Central` = 2
  - `Mountain` = 3
  - `Pacific` = 4
- **Default choice**: `Central`

#### First Time User
- **Display name**: `First Time User`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: No

### Create Views for User Profile

**View 1: Active Users** - Filter: `Is Active` equals `Yes`
**View 2: Managers** - Filter: `Is Manager` equals `Yes` AND `Is Active` equals `Yes`

---

## Table 4: System Setting

### Create the Table

1. Click **Tables** → **+ New table**
2. Configure:
   - **Display name**: `System Setting`
   - **Plural display name**: `System Settings`
   - **Description**: `Application configuration and settings`
   - **Primary column**: Rename to `Setting Name`
   - **Ownership**: `Organization` (in Advanced options)
3. Click **Save**

### Add Columns

#### Setting Name (Primary)
- **Display name**: `Setting Name`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: ✓ Business required

#### Setting Value
- **Display name**: `Setting Value`
- **Data type**: `Text`
- **Max length**: `1000`
- **Required**: ✓ Business required

#### Setting Type
- **Display name**: `Setting Type`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Choices**:
  - `Text` = 1
  - `Number` = 2
  - `Boolean` = 3
  - `JSON` = 4

#### Description
- **Display name**: `Description`
- **Data type**: `Multiline text`
- **Max length**: `1000`
- **Required**: No

#### Category
- **Display name**: `Category`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Choices**:
  - `General` = 1
  - `Approval` = 2
  - `Notification` = 3
  - `Calendar` = 4
  - `Security` = 5

#### Is Editable
- **Display name**: `Is Editable`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: ✓ Business required

### Add Default Data to System Settings

After creating the table, add these 7 default settings (click **+ New** for each):

1. **MinimumAdvanceNoticeDays**
   - Value: `3` | Type: Number | Category: Approval
   - Description: `Minimum days of advance notice required for OOO requests`

2. **MaxOOODaysPerRequest**
   - Value: `30` | Type: Number | Category: Approval
   - Description: `Maximum consecutive days allowed in a single OOO request`

3. **EnableDailyReminders**
   - Value: `true` | Type: Boolean | Category: Notification
   - Description: `Enable daily morning reminders for status updates`

4. **ReminderTime**
   - Value: `08:00` | Type: Text | Category: Notification
   - Description: `Time to send daily reminders (HH:MM format)`

5. **SyncToOutlookCalendar**
   - Value: `true` | Type: Boolean | Category: Calendar
   - Description: `Automatically sync approved OOO to Outlook calendar`

6. **WorkingDays**
   - Value: `[1,2,3,4,5]` | Type: JSON | Category: General
   - Description: `Working days of the week (0=Sunday, 6=Saturday)`

7. **ColorScheme**
   - Value: `{"Onsite":"#4CAF50","Offsite":"#2196F3","OOO-Pending":"#FFC107","OOO-Approved":"#9C27B0"}` | Type: JSON | Category: General
   - Description: `Color codes for different status types`

---

## Configure Security Roles

### Create Role: OOOOO Calendar User

1. Go to **Settings** → **Security** → **Security roles**
2. Click **+ New role**
3. Name: `OOOOO Calendar User`
4. Configure table permissions:

| Table | Create | Read | Write | Delete |
|-------|--------|------|-------|--------|
| Staff Schedule | User | User | User | None |
| Approval History | None | User | None | None |
| User Profile | None | Organization | User | None |
| System Setting | None | Organization | None | None |

5. Click **Save and Close**

### Create Role: OOOOO Calendar Manager

1. Click **+ New role**
2. Name: `OOOOO Calendar Manager`
3. Configure table permissions:

| Table | Create | Read | Write | Delete |
|-------|--------|------|-------|--------|
| Staff Schedule | Organization | Organization | Organization | None |
| Approval History | Organization | Organization | None | None |
| User Profile | Organization | Organization | Organization | None |
| System Setting | None | Organization | Organization | None |

4. Click **Save and Close**

---

## Assign Security Roles

### For All Staff

1. Go to your Team → **Settings** → **Security** → **Teams**
2. Select your team
3. Click **Manage security roles**
4. Check ✓ **OOOOO Calendar User**
5. Click **Save**

### For Managers

1. Go to **Settings** → **Security** → **Users**
2. Select a manager
3. Click **Manage Roles**
4. Check ✓ **OOOOO Calendar User** AND **OOOOO Calendar Manager**
5. Click **Save**

---

## Populate User Profiles

**CRITICAL**: Populate this table before users can access the app.

1. Open **User Profile** table
2. Click **+ New** for each team member
3. Fill required fields (Display Name, User, Email, Manager, Manager Email, Is Manager, Is Active)

**Tip**: For 10+ users, export template → fill Excel → import data

---

## Create Power Automate Flows

Create 3 cloud flows for the app to function:

### Flow 1: OOOOO - OOO Approval Workflow (Required)

**Trigger**: When a row is added or modified (Dataverse)
- Table: Staff Schedule
- Filter: `Status` changes to "OOO-Pending"

**Actions**:
1. Get User Profile to find manager
2. Start and wait for approval (Teams)
3. Update Staff Schedule with approval result
4. Create Approval History record
5. Send notification to employee

**Detailed design**: See `/Reference/power-automate/ooo-approval-flow-design.md`

### Flow 2: OOOOO - Calendar Sync (Required)

**Trigger**: When a row is modified (Dataverse)
- Table: Staff Schedule
- Filter: `Status` changes to "OOO-Approved"

**Actions**:
1. Get user's calendar
2. Create Outlook calendar event
3. Update Staff Schedule with event ID

**Detailed design**: See `/Reference/power-automate/calendar-sync-flow-design.md`

### Flow 3: OOOOO - Daily Reminder (Optional)

**Trigger**: Recurrence (Daily at 8:00 AM)

**Actions**:
1. Get active users from User Profile
2. Post adaptive card to Teams
3. Prompt for status update

**Detailed design**: See `/Reference/power-automate/daily-reminder-flow-design.md`

---

## Manual Creation Verification

Before building the canvas app, verify:

- [ ] All 4 tables created with correct names
- [ ] All columns added with correct data types
- [ ] All choice fields have correct options and values
- [ ] Lookup relationships configured (Staff Schedule ↔ Approval History)
- [ ] Default data added to System Settings (7 records)
- [ ] Security roles created (User & Manager)
- [ ] Security roles assigned to all users
- [ ] User Profiles populated for entire team
- [ ] Power Automate flows created and enabled
- [ ] Test OOO request processes successfully

---

## Build the Canvas App

After tables are created, build the canvas app following:

👉 **See**: `docs/CANVAS-APP-BUILDING-GUIDE.md`

Then continue with **[Step 5: Add App to Teams](#step-5-add-app-to-teams)**

---

## Manual Creation Troubleshooting

### Can't Create Organization-Owned Table

**Issue**: Approval History and System Settings need Organization ownership

**Solution**: Expand **Advanced options** during table creation → Change **Ownership** from `User or team` to `Organization`. If unavailable, create as User-owned and request admin to change.

### Lookup Columns Not Showing Related Table

**Issue**: Newly created table doesn't appear in lookup dropdown

**Solution**: Save and close current table → Refresh Power Apps → Return to create lookup column

### Choice Field Values Not Saving

**Issue**: Choice options disappear after save

**Solution**: Click **Save** after adding each choice. Don't select "Sync with global choice" unless intended.

### Security Roles Not Applying

**Issue**: Users can't access tables despite role assignment

**Solution**: Verify privilege levels are correct → Ensure users assigned to team AND security role → Sign out and back in

---

# Post-Installation

**These steps apply to ALL installation methods.**

---

## Train Your Users

Share documentation with your team:
- **Staff Guide**: `docs/user-guide-staff.md`
- **Manager Guide**: `docs/user-guide-manager.md`

---

## Monitor the System

### First Week
- Check Power Automate flow run history for errors
- Verify approvals are delivered to managers
- Monitor Teams notifications
- Ensure calendar sync works

### First Month
- Review approval turnaround times
- Collect user feedback
- Address any usability issues
- Adjust settings as needed

---

## Common Troubleshooting

### Import Fails

**Error**: "Solution import failed"

**Solutions**:
- Ensure you're in a Dataverse for Teams environment
- Verify you have import permissions
- Try creating new team and importing there
- Check file isn't corrupted (re-download)

### Flows Not Triggering

**Error**: Approval requests not being sent

**Solutions**:
- Verify flows are **On** (not draft)
- Check manager email in User Profiles is correct
- Review flow run history for errors
- Re-authenticate connections
- Verify trigger conditions match

### App Shows "No Data"

**Error**: App loads but shows no schedule

**Solutions**:
- Ensure User Profiles table is populated
- Verify user has security role assigned
- Check table permissions in security role
- Refresh app data source connections

### Approval Not Appearing

**Error**: Manager doesn't receive approval

**Solutions**:
- Check Approvals connector is connected
- Verify manager's Teams notifications enabled
- Look in **Approvals** app in Teams
- Check flow run history for delivery confirmation
- Ensure manager has correct email in User Profile

### Calendar Event Not Creating

**Error**: Outlook event doesn't appear after approval

**Solutions**:
- Verify Outlook connector is connected
- Ensure user has Outlook license
- Check Calendar Sync flow is enabled
- Test flow manually with sample data
- Verify user permissions for calendar access

---

## Admin Deployment (Organization-Wide)

For IT administrators deploying to entire organization:

### Upload to Teams App Catalog

1. Go to **Teams Admin Center**: https://admin.teams.microsoft.com
2. Navigate to **Teams apps** → **Manage apps**
3. Click **Upload new app**
4. Upload `OOOOOCalendar_1_0_0_0.cab`
5. Configure:
   - **Status**: Allowed
   - **Availability**: Specific users/teams or organization-wide
6. Click **Publish**

### Deploy via App Setup Policy

1. Create app setup policy in Teams Admin Center
2. Add OOOOO Calendar to policy
3. Assign policy to users/groups
4. Users will see app pinned in Teams

---

## Success Checklist

Installation is complete when ALL boxes are checked:

- [ ] Solution imported or tables created manually
- [ ] User Profiles populated for all team members
- [ ] Security roles assigned (Users + Managers)
- [ ] All 3 flows enabled and connection verified
- [ ] App added to Teams channel as tab
- [ ] Test OOO request submitted successfully
- [ ] Manager received and approved test request
- [ ] Calendar event created in Outlook
- [ ] All team members can access app
- [ ] User guides shared with team

---

## Next Steps

1. ✅ **Announce**: Let team know app is live
2. ✅ **Monitor**: Watch for issues first week
3. ✅ **Support**: Help users get started
4. ✅ **Feedback**: Collect improvement suggestions
5. ✅ **Iterate**: Make adjustments based on usage

---

## Additional Resources

### Documentation

- **Architecture**: `SOLUTION-PACKAGE-SPEC.md`
- **Data Model**: `Reference/dataverse-tables-schema.json`
- **Canvas App Design**: `docs/CANVAS-APP-BUILDING-GUIDE.md`
- **User Guides**: `docs/` folder

### Microsoft Resources

- **Power Platform CLI**: https://learn.microsoft.com/power-platform/developer/cli/introduction
- **Dataverse Solutions**: https://learn.microsoft.com/power-apps/maker/data-platform/solutions-overview
- **Power Automate**: https://learn.microsoft.com/power-automate
- **Power Apps Community**: https://powerusers.microsoft.com

---

## FAQ

**Q: Which installation method should I use?**

A: Use **Method 1 (Import)** if you have the package and standard permissions. Use **Method 2 (Build)** if you're a developer working from source. Use **Method 3 (Manual)** only if imports are blocked or you need deep customization.

**Q: Can I switch between methods?**

A: Yes! You can build from source (Method 2) and then import (Method 1). Or create tables manually (Method 3) then export as a solution.

**Q: How long does each method take?**

A: Method 1: 30-60 min | Method 2: 1-2 hours | Method 3: 2-4 hours

**Q: Do I need premium licenses?**

A: No! Everything runs on Microsoft Teams (Dataverse for Teams) included with standard Teams licenses.

**Q: Can I customize the tables?**

A: Yes! Use Method 3 to create tables with your modifications, or import via Method 1 then modify tables afterward.

**Q: What if solution import is disabled?**

A: Use **Method 3** to manually create all components.

**Q: Can I build on Mac/Linux?**

A: PowerShell scripts are Windows-only, but PAC CLI works cross-platform. Use manual PAC commands from Method 2.

**Q: How do I update the solution later?**

A: Export your modified solution from Power Apps → Unpack with `scripts/unpack-solution.ps1` → Commit to Git → Pack with `scripts/pack-solution.ps1` → Import updates

---

## Version Information

- **Solution Version**: 1.0.0.0
- **Guide Version**: 1.0.0
- **Last Updated**: November 2025

---

**🎉 Congratulations!** Your OOOOO Calendar Teams app is installed and ready.

**Need help?** Refer to troubleshooting sections or contact your IT administrator.
