# OOOOO Calendar - Manual Table Creation Guide

This guide provides step-by-step instructions for manually creating the Dataverse tables when you cannot import the solution package (e.g., restricted environments, custom deployments).

**Estimated Time**: 2-3 hours

---

## Prerequisites

- Access to Power Apps in Teams or Power Apps portal
- Permissions to create tables in your Dataverse environment
- Microsoft Teams license with Dataverse for Teams

---

## Overview

You will create 4 custom tables:
1. **Staff Schedule** - Main schedule and time-off request data
2. **Approval History** - Audit trail of approval actions
3. **User Profile** - Extended user profile and manager relationships
4. **System Setting** - Application configuration

---

## Table 1: Staff Schedule (ooooo_staffschedule)

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
- **Description**: `Link to employee user record`

#### Employee Email
- **Display name**: `Employee Email`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required
- **Description**: `Employee email address`

#### Schedule Date
- **Display name**: `Schedule Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: ✓ Business required
- **Description**: `Date for the schedule entry`

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
- **Description**: `Current status of the schedule entry`

#### Request Type
- **Display name**: `Request Type`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `Regular Schedule` = 1
  - `Vacation` = 2
  - `Sick Leave` = 3
  - `Personal Day` = 4
  - `Other` = 5
- **Default choice**: `Regular Schedule`
- **Description**: `Type of request or schedule entry`

#### Start Date
- **Display name**: `Start Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: No
- **Description**: `Start date for multi-day OOO requests`

#### End Date
- **Display name**: `End Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: No
- **Description**: `End date for multi-day OOO requests`

#### Number of Days
- **Display name**: `Number of Days`
- **Data type**: `Whole Number`
- **Min value**: `0`
- **Max value**: `365`
- **Required**: No
- **Description**: `Calculated number of days in request`

#### Comments
- **Display name**: `Comments`
- **Data type**: `Multiline text`
- **Max length**: `2000`
- **Required**: No
- **Description**: `Optional comments from employee`

#### Submission Date/Time
- **Display name**: `Submission Date/Time`
- **Data type**: `Date and Time`
- **Format**: `Date and time`
- **Required**: ✓ Business required
- **Description**: `When the request was submitted`

#### Approved By
- **Display name**: `Approved By`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: No
- **Description**: `Manager who approved/rejected`

#### Approval Date/Time
- **Display name**: `Approval Date/Time`
- **Data type**: `Date and Time`
- **Format**: `Date and time`
- **Required**: No
- **Description**: `When approval/rejection occurred`

#### Manager Comments
- **Display name**: `Manager Comments`
- **Data type**: `Multiline text`
- **Max length**: `2000`
- **Required**: No
- **Description**: `Manager's comments on approval/rejection`

#### Approval Request ID
- **Display name**: `Approval Request ID`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: No
- **Description**: `Teams approval action request ID for tracking`

#### Calendar Event ID
- **Display name**: `Calendar Event ID`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: No
- **Description**: `Outlook calendar event ID for synchronization`

#### Is Active
- **Display name**: `Is Active`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: ✓ Business required
- **Description**: `Whether this entry is active (not cancelled)`

### Create Views

1. Click **Views** tab
2. Edit the **Active [Table Name]** view or create new views:

**View 1: Active Schedules**
- Add filter: `Is Active` equals `Yes`

**View 2: Pending Approvals**
- Add filter: `Status` equals `OOO-Pending` AND `Is Active` equals `Yes`

**View 3: My Requests**
- Add filter: `Owner` equals `Current User`

---

## Table 2: Approval History (ooooo_approvalhistory)

### Create the Table

1. Click **Tables** → **+ New table** → **Create new table**
2. Configure:
   - **Display name**: `Approval History`
   - **Plural display name**: `Approval History`
   - **Description**: `Complete audit trail of all approval actions`
   - **Primary column**: Rename to `History ID`
   - **Ownership**: `Organization` (in Advanced options)
3. Click **Save**

### Add Columns

#### History ID (Primary - Already Created)
- **Display name**: `History ID`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: ✓ Business required
- **Description**: `Unique identifier for this history record`

#### Related Request
- **Display name**: `Related Request`
- **Data type**: `Lookup`
- **Related table**: `Staff Schedule` (created above)
- **Required**: ✓ Business required
- **Description**: `Link to the original schedule request`

#### Employee
- **Display name**: `Employee`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required
- **Description**: `Employee who made the request`

#### Request Start Date
- **Display name**: `Request Start Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: ✓ Business required
- **Description**: `Start date of the request`

#### Request End Date
- **Display name**: `Request End Date`
- **Data type**: `Date and Time`
- **Format**: `Date only`
- **Required**: No
- **Description**: `End date of the request`

#### Request Type
- **Display name**: `Request Type`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `Vacation` = 2
  - `Sick Leave` = 3
  - `Personal Day` = 4
  - `Other` = 5
- **Description**: `Type of time-off request`

#### Action
- **Display name**: `Action`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `Submitted` = 1
  - `Approved` = 2
  - `Rejected` = 3
  - `Cancelled` = 4
  - `Modified` = 5
- **Description**: `Action taken on the request`

#### Action Date/Time
- **Display name**: `Action Date/Time`
- **Data type**: `Date and Time`
- **Format**: `Date and time`
- **Required**: ✓ Business required
- **Description**: `When the action occurred`

#### Actor
- **Display name**: `Actor`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required
- **Description**: `Person who performed the action`

#### Comments
- **Display name**: `Comments`
- **Data type**: `Multiline text`
- **Max length**: `2000`
- **Required**: No
- **Description**: `Comments from the person performing the action`

#### Original Request Details
- **Display name**: `Original Request Details`
- **Data type**: `Multiline text`
- **Max length**: `4000`
- **Required**: No
- **Description**: `JSON snapshot of original request data`

#### Approval Duration (hours)
- **Display name**: `Approval Duration (hours)`
- **Data type**: `Decimal Number`
- **Decimal places**: `2`
- **Min value**: `0`
- **Max value**: `10000`
- **Required**: No
- **Description**: `Time from submission to approval/rejection`

### Create Views

**View 1: All History**
- Show all records

**View 2: Recent Approvals**
- Add filter: `Action` equals `Approved`
- Sort by: `Action Date/Time` (newest first)

---

## Table 3: User Profile (ooooo_userprofile)

### Create the Table

1. Click **Tables** → **+ New table** → **Create new table**
2. Configure:
   - **Display name**: `User Profile`
   - **Plural display name**: `User Profiles`
   - **Description**: `Extended user profile information and manager relationships`
   - **Primary column**: Rename to `Display Name`
3. Click **Save**

### Add Columns

#### Display Name (Primary - Already Created)
- **Display name**: `Display Name`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required
- **Description**: `User's full name`

#### User
- **Display name**: `User`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required
- **Description**: `Link to system user account`

#### Email
- **Display name**: `Email`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required
- **Description**: `User's email address`

#### Manager
- **Display name**: `Manager`
- **Data type**: `Lookup`
- **Related table**: `User`
- **Required**: ✓ Business required
- **Description**: `User's direct manager`

#### Manager Email
- **Display name**: `Manager Email`
- **Data type**: `Text`
- **Max length**: `200`
- **Required**: ✓ Business required
- **Description**: `Manager's email address`

#### Department
- **Display name**: `Department`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: No
- **Description**: `Department or team`

#### Is Manager
- **Display name**: `Is Manager`
- **Data type**: `Yes/No`
- **Default value**: No
- **Required**: ✓ Business required
- **Description**: `Whether this user has manager privileges`

#### Is Active
- **Display name**: `Is Active`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: ✓ Business required
- **Description**: `Whether user is active in the system`

#### Notification Preferences
- **Display name**: `Notification Preferences`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `Teams Only` = 1
  - `Email Only` = 2
  - `Both` = 3
  - `None` = 4
- **Default choice**: `Both`
- **Description**: `User's notification preferences`

#### Time Zone
- **Display name**: `Time Zone`
- **Data type**: `Choice`
- **Required**: No
- **Sync with global choice?**: No
- **Choices**:
  - `Eastern` = 1
  - `Central` = 2
  - `Mountain` = 3
  - `Pacific` = 4
- **Default choice**: `Central`
- **Description**: `User's time zone`

#### First Time User
- **Display name**: `First Time User`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: No
- **Description**: `Whether to show welcome splash screen`

### Create Views

**View 1: Active Users**
- Add filter: `Is Active` equals `Yes`

**View 2: Managers**
- Add filter: `Is Manager` equals `Yes` AND `Is Active` equals `Yes`

---

## Table 4: System Setting (ooooo_systemsetting)

### Create the Table

1. Click **Tables** → **+ New table** → **Create new table**
2. Configure:
   - **Display name**: `System Setting`
   - **Plural display name**: `System Settings`
   - **Description**: `Application configuration and settings`
   - **Primary column**: Rename to `Setting Name`
   - **Ownership**: `Organization` (in Advanced options)
3. Click **Save**

### Add Columns

#### Setting Name (Primary - Already Created)
- **Display name**: `Setting Name`
- **Data type**: `Text`
- **Max length**: `100`
- **Required**: ✓ Business required
- **Description**: `Unique setting identifier`

#### Setting Value
- **Display name**: `Setting Value`
- **Data type**: `Text`
- **Max length**: `1000`
- **Required**: ✓ Business required
- **Description**: `Value of the setting`

#### Setting Type
- **Display name**: `Setting Type`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `Text` = 1
  - `Number` = 2
  - `Boolean` = 3
  - `JSON` = 4
- **Description**: `Data type of the setting`

#### Description
- **Display name**: `Description`
- **Data type**: `Multiline text`
- **Max length**: `1000`
- **Required**: No
- **Description**: `Description of what this setting controls`

#### Category
- **Display name**: `Category`
- **Data type**: `Choice`
- **Required**: ✓ Business required
- **Sync with global choice?**: No
- **Choices**:
  - `General` = 1
  - `Approval` = 2
  - `Notification` = 3
  - `Calendar` = 4
  - `Security` = 5
- **Description**: `Setting category`

#### Is Editable
- **Display name**: `Is Editable`
- **Data type**: `Yes/No`
- **Default value**: Yes
- **Required**: ✓ Business required
- **Description**: `Whether this setting can be changed by admins`

### Add Default Data

After creating the table, add these default settings (click **+ New**):

1. **MinimumAdvanceNoticeDays**
   - Setting Value: `3`
   - Setting Type: `Number`
   - Description: `Minimum days of advance notice required for OOO requests`
   - Category: `Approval`
   - Is Editable: Yes

2. **MaxOOODaysPerRequest**
   - Setting Value: `30`
   - Setting Type: `Number`
   - Description: `Maximum consecutive days allowed in a single OOO request`
   - Category: `Approval`
   - Is Editable: Yes

3. **EnableDailyReminders**
   - Setting Value: `true`
   - Setting Type: `Boolean`
   - Description: `Enable daily morning reminders for status updates`
   - Category: `Notification`
   - Is Editable: Yes

4. **ReminderTime**
   - Setting Value: `08:00`
   - Setting Type: `Text`
   - Description: `Time to send daily reminders (HH:MM format)`
   - Category: `Notification`
   - Is Editable: Yes

5. **SyncToOutlookCalendar**
   - Setting Value: `true`
   - Setting Type: `Boolean`
   - Description: `Automatically sync approved OOO to Outlook calendar`
   - Category: `Calendar`
   - Is Editable: Yes

6. **WorkingDays**
   - Setting Value: `[1,2,3,4,5]`
   - Setting Type: `JSON`
   - Description: `Working days of the week (0=Sunday, 6=Saturday)`
   - Category: `General`
   - Is Editable: Yes

7. **ColorScheme**
   - Setting Value: `{"Onsite":"#4CAF50","Offsite":"#2196F3","OOO-Pending":"#FFC107","OOO-Approved":"#9C27B0"}`
   - Setting Type: `JSON`
   - Description: `Color codes for different status types`
   - Category: `General`
   - Is Editable: Yes

---

## Configure Security Roles

### Create Security Role: OOOOO Calendar User

1. Go to **Settings** → **Security** → **Security roles**
2. Click **+ New role**
3. Name: `OOOOO Calendar User`
4. Configure table permissions:

**Staff Schedule**:
- Create: User (Basic)
- Read: User (Basic)
- Write: User (Basic)
- Delete: None

**Approval History**:
- Create: None
- Read: User (Basic)
- Write: None
- Delete: None

**User Profile**:
- Create: None
- Read: Organization
- Write: User (Basic)
- Delete: None

**System Setting**:
- Create: None
- Read: Organization
- Write: None
- Delete: None

5. Click **Save and Close**

### Create Security Role: OOOOO Calendar Manager

1. Click **+ New role**
2. Name: `OOOOO Calendar Manager`
3. Configure table permissions:

**Staff Schedule**:
- Create: Organization
- Read: Organization
- Write: Organization
- Delete: None

**Approval History**:
- Create: Organization
- Read: Organization
- Write: None
- Delete: None

**User Profile**:
- Create: Organization
- Read: Organization
- Write: Organization
- Delete: None

**System Setting**:
- Create: None
- Read: Organization
- Write: Organization
- Delete: None

4. Click **Save and Close**

---

## Configure Relationships

Relationships should be created automatically when you add Lookup columns, but verify:

### Staff Schedule → Approval History

1. Open **Staff Schedule** table
2. Go to **Relationships** tab
3. Verify relationship exists:
   - **Type**: One-to-Many
   - **Related table**: Approval History
   - **Lookup column**: Related Request

If not, create:
1. Click **+ Add relationship** → **One-to-many**
2. Related table: `Approval History`
3. Lookup column name: `Related Request`
4. Save

---

## Assign Security Roles to Users

### For All Staff Members

1. Go to your Team in Power Apps
2. Click **Settings** → **Security** → **Teams**
3. Select your team
4. Click **Manage security roles**
5. Check ✓ **OOOOO Calendar User**
6. Click **Save**

### For Managers

1. Go to **Settings** → **Security** → **Users**
2. Select a manager
3. Click **Manage Roles**
4. Check ✓ **OOOOO Calendar User** AND **OOOOO Calendar Manager**
5. Click **Save**
6. Repeat for each manager

---

## Populate User Profiles

**IMPORTANT**: You must populate the User Profile table before users can use the app.

1. Open **User Profile** table
2. Click **+ New** for each team member
3. Fill in all required fields:
   - Display Name
   - User (select from people picker)
   - Email
   - Manager (select from people picker)
   - Manager Email
   - Is Manager (check if applicable)
   - Is Active (checked)
   - Notification Preferences (default: Both)

**Tip**: For 10+ users, export a template, fill in Excel, and import.

---

## Create Power Automate Flows

You will need to create 3 cloud flows. Detailed flow designs are in `/Reference/power-automate/`:

### Flow 1: OOOOO - OOO Approval Workflow
**Required**

**Trigger**: When a row is added or modified (Dataverse)
- Table: Staff Schedule
- Filter: Status changes to "OOO-Pending"

**Actions**:
1. Get User Profile to find manager
2. Start and wait for approval (Teams)
3. Update Staff Schedule with approval result
4. Create Approval History record
5. Send notification to employee

See detailed design: `/Reference/power-automate/ooo-approval-flow-design.md`

### Flow 2: OOOOO - Calendar Sync
**Required**

**Trigger**: When a row is modified (Dataverse)
- Table: Staff Schedule
- Filter: Status changes to "OOO-Approved"

**Actions**:
1. Get user's calendar
2. Create calendar event
3. Update Staff Schedule with event ID

### Flow 3: OOOOO - Daily Reminder
**Optional**

**Trigger**: Recurrence (Daily at 8:00 AM)

**Actions**:
1. Get active users
2. Post adaptive card to Teams
3. Prompt for status update

---

## Verification Checklist

Before using the app, verify:

- [ ] All 4 tables created
- [ ] All columns added to each table with correct data types
- [ ] All choice fields have correct options
- [ ] Lookup relationships configured
- [ ] Default data added to System Settings
- [ ] Security roles created
- [ ] Security roles assigned to users
- [ ] User Profiles populated for all team members
- [ ] Power Automate flows created and enabled
- [ ] Test OOO request processed successfully

---

## Next Steps

After manually creating tables:

1. **Create the Canvas App**: Follow `/docs/CANVAS-APP-BUILDING-GUIDE.md`
2. **Test the System**: Submit test OOO request
3. **Train Users**: Share user guides from `/docs`

---

## Tips for Success

### Use Table Prefix
Keep the `ooooo_` prefix for all table and column logical names to match the solution package structure.

### Test as You Go
Test each table after creation by adding sample data.

### Document Custom Changes
If you deviate from these specs, document your changes for future reference.

### Export Your Solution
After manual creation, export as a solution for backup and redeployment:
1. Create new solution
2. Add all tables
3. Export as unmanaged

---

## Troubleshooting

### Can't Create Organization-Owned Table
**Issue**: Approval History and System Settings need Organization ownership

**Solution**:
- In table creation, expand **Advanced options**
- Change **Ownership** from `User or team` to `Organization`
- If not available, create as User-owned and request admin to change

### Lookup Columns Not Showing Related Table
**Issue**: Newly created table not appearing in lookup dropdown

**Solution**:
- Save and close the current table
- Refresh the Power Apps page
- Return to create the lookup column

### Choice Field Values Not Saving
**Issue**: Choice options disappear after save

**Solution**:
- Ensure you click **Save** after adding each choice
- Don't select "Sync with global choice" unless intended

### Security Roles Not Applying
**Issue**: Users can't access tables despite role assignment

**Solution**:
- Verify the security role has correct privilege levels
- Ensure users are assigned to BOTH the team AND the security role
- Try signing out and back in

---

## Estimated Time Breakdown

- Table 1 (Staff Schedule): 45 minutes
- Table 2 (Approval History): 30 minutes
- Table 3 (User Profile): 30 minutes
- Table 4 (System Settings): 25 minutes (includes data entry)
- Security Roles: 20 minutes
- User Profile Population: 10-60 minutes (depends on team size)
- Flow Creation: 1-2 hours

**Total**: 2-4 hours depending on experience level

---

## Support

If you encounter issues during manual creation:

- **Schema Reference**: See `/Reference/dataverse-tables-schema.json`
- **Architecture**: See `/Reference/dataverse-architecture.md`
- **Power Apps Community**: https://powerusers.microsoft.com

---

**Version**: 1.0.0
**Last Updated**: November 2025

---

**Need Help?** If manual table creation is taking too long or proving difficult, consider:
1. Requesting environment permissions to import solutions
2. Creating a separate Dataverse for Teams environment where you have full control
3. Contacting your IT administrator for assistance
