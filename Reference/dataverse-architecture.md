# OOOOO Calendar - Dataverse Architecture

## Overview

The OOOOO Calendar Dataverse solution is architected to match the Microsoft Teams Power Apps template pattern (like Boards), providing a fully packaged, importable solution that deploys to Dataverse for Teams environments.

---

## Architecture Comparison

### SharePoint Version (Original)
```
Power Apps → SharePoint Lists → Power Automate → Teams
```

### Dataverse Version (New - Boards-style)
```
Power Apps → Dataverse Tables → Power Automate → Teams
      ↓
Teams Environment (Built-in)
```

---

## Solution Components

### 1. Dataverse Tables (4 core tables)

#### **ooooo_staffschedule** - Staff Schedule
- **Purpose**: Main schedule and time-off request data
- **Ownership**: User-owned (employees own their records)
- **Key Columns**:
  - `ooooo_requestid` (Primary): Unique request identifier
  - `ooooo_employee` (Lookup): Link to systemuser
  - `ooooo_scheduledate` (DateTime): Date of schedule entry
  - `ooooo_status` (Choice): Onsite, Offsite, OOO-Pending, OOO-Approved, OOO-Rejected
  - `ooooo_requesttype` (Choice): Regular, Vacation, Sick, Personal, Other
  - `ooooo_startdate`, `ooooo_enddate`: For multi-day requests
  - `ooooo_approver` (Lookup): Manager who approved
  - `ooooo_calendareventid`: Sync with Outlook
  - `ooooo_isactive` (Boolean): Soft delete flag

#### **ooooo_approvalhistory** - Approval History
- **Purpose**: Complete audit trail
- **Ownership**: Organization-owned (visible to all managers)
- **Key Columns**:
  - `ooooo_historyid` (Primary): Unique history identifier
  - `ooooo_relatedrequest` (Lookup): Links to ooooo_staffschedule
  - `ooooo_employee` (Lookup): Employee who made request
  - `ooooo_action` (Choice): Submitted, Approved, Rejected, Cancelled, Modified
  - `ooooo_actor` (Lookup): Person who performed action
  - `ooooo_approvalduration` (Decimal): Hours from submission to decision
  - `ooooo_originalrequestdetails` (Text): JSON snapshot

#### **ooooo_userprofile** - User Profiles
- **Purpose**: Extended user info and manager relationships
- **Ownership**: User-owned
- **Key Columns**:
  - `ooooo_displayname` (Primary): User's full name
  - `ooooo_user` (Lookup): Link to systemuser
  - `ooooo_manager` (Lookup): Direct manager
  - `ooooo_ismanager` (Boolean): Manager flag
  - `ooooo_notificationpreferences` (Choice): Teams/Email/Both/None
  - `ooooo_firsttimeuser` (Boolean): Show welcome screen

#### **ooooo_systemsetting** - System Settings
- **Purpose**: Application configuration
- **Ownership**: Organization-owned
- **Key Columns**:
  - `ooooo_settingname` (Primary): Setting identifier
  - `ooooo_settingvalue` (Text): Value
  - `ooooo_settingtype` (Choice): Text/Number/Boolean/JSON
  - `ooooo_category` (Choice): General/Approval/Notification/Calendar/Security
  - `ooooo_iseditable` (Boolean): Can admins change it?

**Default Settings** (Auto-created):
- MinimumAdvanceNoticeDays: 3
- MaxOOODaysPerRequest: 30
- EnableDailyReminders: true
- ReminderTime: 08:00
- SyncToOutlookCalendar: true
- WorkingDays: [1,2,3,4,5]
- ColorScheme: JSON with status colors

---

### 2. Canvas App (Power Apps)

#### App Structure
```
OOOOO Calendar App
│
├── OnStart: Initialize app, load settings, detect user role
│
├── Screens:
│   ├── scrLoading: Splash screen with app logo
│   ├── scrHome: Dashboard with quick actions
│   ├── scrMySchedule: Personal calendar and history
│   ├── scrRequestForm: Submit OOO requests
│   ├── scrTeamCalendar: Team availability view
│   ├── scrManagerApprovals: Approval management (managers only)
│   ├── scrSettings: User preferences
│   └── scrAbout: App information and help
│
├── Components:
│   ├── cmpHeader: Reusable header with navigation
│   ├── cmpCalendarGrid: Calendar visualization
│   ├── cmpStatusCard: Status display component
│   └── cmpLoadingSpinner: Loading indicator
│
└── Collections & Variables:
    ├── colUserSchedule: User's schedule data
    ├── colTeamSchedule: Team calendar data
    ├── colPendingApprovals: Manager's pending approvals
    ├── colSystemSettings: App settings
    ├── varCurrentUser: Current user context
    ├── varUserProfile: User's profile record
    └── varIsManager: Manager role flag
```

#### Key Differences from SharePoint Version

**Data Connector**:
- ❌ SharePoint connector
- ✅ Microsoft Dataverse connector

**Formulas**:
- ❌ `Filter(StaffSchedule, ...)`
- ✅ `Filter(StaffSchedules, ...)` (note plural table name)
- ❌ `Status.Value` (SharePoint choice)
- ✅ `'Status (ooooo_status)'` (Dataverse choice)

**Lookups**:
- ❌ `EmployeeName.Email`
- ✅ `'Employee (ooooo_employee)'.'Primary Email'`

**Better Delegation**:
- SharePoint: 2000 item limit (without premium)
- Dataverse: 500,000+ item delegation limit

---

### 3. Power Automate Flows (3 flows)

#### Flow 1: OOO Approval Workflow
- **Trigger**: When a row is added, modified or deleted
- **Table**: ooooo_staffschedule
- **Condition**: Status = OOO-Pending (3)
- **Actions**:
  1. Get employee's manager from ooooo_userprofile
  2. Create approval history record (Submitted)
  3. Start Teams approval
  4. Wait for response
  5. Update ooooo_staffschedule with decision
  6. Create Outlook calendar event (if approved)
  7. Send Teams notification to employee
  8. Create approval history record (Approved/Rejected)

#### Flow 2: Calendar Sync
- **Trigger**: When a row is modified
- **Table**: ooooo_staffschedule
- **Condition**: Status changed to OOO-Approved (4)
- **Actions**:
  1. Check if calendar event already exists
  2. Create or update Outlook event
  3. Store calendar event ID back to record

#### Flow 3: Daily Reminder (Optional)
- **Trigger**: Recurrence (Daily at 8:00 AM)
- **Actions**:
  1. Get all active users from ooooo_userprofile
  2. For each user, post Teams message reminder
  3. Include quick action buttons (if supported)

---

### 4. Security Roles (2 roles)

#### OOOOO Calendar User (Standard Role)
- **Staff Schedule**: Create Own, Read Own, Write Own
- **Approval History**: Read Own
- **User Profile**: Read Organization (to see team), Write Own
- **System Settings**: Read Organization

#### OOOOO Calendar Manager (Elevated Role)
- **Staff Schedule**: Create/Read/Write Organization
- **Approval History**: Create/Read Organization
- **User Profile**: Create/Read/Write Organization
- **System Settings**: Read/Write Organization

---

## Data Relationships

### Table Relationships

```
systemuser (Built-in)
    ↓ (1:N)
ooooo_userprofile
    ↓ (1:N via ooooo_manager lookup)
ooooo_staffschedule
    ↓ (1:N)
ooooo_approvalhistory
```

### Key Lookups

1. **Staff Schedule → User**
   - `ooooo_employee` → `systemuser`
   - `ooooo_approver` → `systemuser`

2. **Approval History → Staff Schedule**
   - `ooooo_relatedrequest` → `ooooo_staffschedule`

3. **User Profile → User**
   - `ooooo_user` → `systemuser`
   - `ooooo_manager` → `systemuser`

---

## Deployment Model

### Solution Package Structure

```
OOOOOCalendar_1_0_0_0.zip
│
├── [Content_Types].xml
├── customizations.xml
│
├── Tables/
│   ├── ooooo_staffschedule/
│   ├── ooooo_approvalhistory/
│   ├── ooooo_userprofile/
│   └── ooooo_systemsetting/
│
├── CanvasApps/
│   └── ooooo_calendar.msapp
│
├── Workflows/
│   ├── OOOOOApprovalWorkflow/
│   ├── OOOOOCalendarSync/
│   └── OOOOODailyReminder/
│
├── SecurityRoles/
│   ├── OOOOOCalendarUser.xml
│   └── OOOOOCalendarManager.xml
│
└── Data/
    └── ooooo_systemsetting_data.xml
```

### Installation Process

**Step 1: Import Solution**
1. Open Power Apps in Teams
2. Navigate to "Build" tab
3. Select your team
4. Click "See all" → "Import solution"
5. Upload `OOOOOCalendar_1_0_0_0.zip`
6. Click "Next" → "Import"
7. Wait for import to complete (~2-5 minutes)

**Step 2: Configure Security**
1. Go to solution → Security Roles
2. Assign "OOOOO Calendar User" to all staff
3. Assign "OOOOO Calendar Manager" to managers

**Step 3: Populate User Profiles**
1. Open "User Profiles" table
2. Create records for each team member
3. Set manager relationships

**Step 4: Enable Flows**
1. Go to solution → Cloud flows
2. Turn on each flow
3. Test with sample request

**Step 5: Add to Teams**
1. Open the canvas app
2. Click "Add to Teams"
3. Select channel
4. App appears as tab

**Total Time**: 30-60 minutes (vs 2-4 weeks for SharePoint version!)

---

## Dataverse for Teams vs Dataverse

### Dataverse for Teams (Recommended)
- ✅ **Included with Teams license** - No additional cost
- ✅ Environment created per team
- ✅ Up to 2 million rows per environment
- ✅ Perfect for team-specific apps
- ⚠️ Limited to 1 GB storage per environment
- ⚠️ Cannot be used outside Teams context

### Dataverse (Premium)
- ✅ Larger storage (GB to TB)
- ✅ Can be accessed outside Teams
- ✅ Advanced features (business rules, calculated fields)
- ❌ Requires premium license ($10-40/user/month)

**For OOOOO Calendar**: Dataverse for Teams is perfect! Your 11+ user team will easily fit within limits.

---

## Performance & Scalability

### Delegation Support
- **Dataverse**: Excellent delegation (500k+ rows)
- **SharePoint**: Limited (2000 rows without premium)

### Expected Data Growth (11 users)
- **Staff Schedule**: ~4,000 rows/year (11 users × 365 days)
- **Approval History**: ~400 rows/year (assuming 3 OOO requests/user/month)
- **User Profiles**: 11 rows (static)
- **System Settings**: 7 rows (static)

**Total**: ~4,500 rows/year (well within Dataverse for Teams 2M limit)

### Performance Targets
- ✅ Home screen load: <2 seconds
- ✅ Calendar rendering: <3 seconds
- ✅ Form submission: <1 second
- ✅ Approval delivery: <5 minutes

---

## Advantages Over SharePoint Version

### 1. **Faster Deployment**
- SharePoint: 2-4 weeks (build from scratch)
- Dataverse: 30-60 minutes (import solution)

### 2. **Better Performance**
- Dataverse delegation: 500k+ rows
- SharePoint delegation: 2000 rows

### 3. **Packaged Solution**
- Dataverse: Import ZIP, done
- SharePoint: Run scripts, build app, create flows manually

### 4. **Professional ALM**
- Dataverse: Export/import solutions easily
- SharePoint: Manual backup/restore

### 5. **Relational Database**
- Dataverse: True foreign keys, cascading deletes
- SharePoint: Lookup columns only

### 6. **Modern Platform**
- Dataverse: Microsoft's strategic direction
- SharePoint Lists: Legacy approach for this use case

---

## Migration from SharePoint Version

If you started with SharePoint version:

### Option 1: Fresh Start (Recommended)
1. Deploy Dataverse solution
2. Manually migrate active OOO requests
3. Retire SharePoint version

### Option 2: Data Migration
1. Deploy Dataverse solution
2. Export SharePoint data to Excel
3. Import into Dataverse tables
4. Verify and test
5. Retire SharePoint version

**Timeline**: 1-2 days for migration

---

## Licensing & Compliance

### Required Licenses
- ✅ Microsoft Teams (included with M365)
- ✅ Dataverse for Teams (included with Teams)
- ✅ Power Apps (included with M365)
- ✅ Power Automate (included with M365)

### No Premium Required!
- ❌ NO premium connectors
- ❌ NO Dataverse premium license
- ❌ NO additional per-user fees

### Data Residency
- Dataverse for Teams: Same region as Teams/M365 tenant
- GDPR compliant
- Audit logging built-in

---

## Maintenance & Updates

### Version Updates
1. Export modified solution
2. Increment version number
3. Import to other environments
4. Users see updates automatically

### Backup Strategy
- Dataverse: Built-in point-in-time restore
- Export solution regularly
- Export data to Excel monthly

---

## Next Steps

1. **Review**: Read the complete architecture
2. **Deploy**: Follow deployment guide
3. **Test**: Import solution to test environment first
4. **Train**: Use provided user guides
5. **Launch**: Deploy to production team

See `docs/dataverse-deployment-guide.md` for step-by-step instructions.

---

**Document Version**: 2.0.0 (Dataverse)
**Architecture**: Dataverse for Teams
**Deployment Model**: Packaged Solution (like Boards)
**Last Updated**: November 2025
