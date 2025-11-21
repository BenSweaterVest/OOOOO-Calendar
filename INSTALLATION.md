# OOOOO Calendar - Installation Guide

Welcome! This guide will help you install the OOOOO Calendar Teams app in 30-60 minutes.

---

## Prerequisites

- Microsoft Teams license (Dataverse for Teams included)
- Team ownership or member permissions
- **No premium licenses required!**

---

## Installation Options

### Option 1: Import via Power Apps in Teams (Recommended)

**Time**: 30-60 minutes

1. [Download the solution package](#step-1-download-solution)
2. [Import to your Teams environment](#step-2-import-solution)
3. [Configure security and users](#step-3-configure-security)
4. [Add app to Teams channel](#step-4-add-to-teams)

### Option 2: Manual Table Creation

**Time**: 2-4 hours

For environments that don't allow solution imports or require manual setup.

1. **See**: [MANUAL-TABLE-CREATION.md](MANUAL-TABLE-CREATION.md)
2. Create tables, columns, and relationships manually
3. Configure security roles
4. Build canvas app

**When to use this option**:
- Solution import is blocked by IT policy
- You need to customize table structure
- Environment restrictions prevent package imports
- You want to understand the full data model

### Option 3: Teams Admin Center Upload

For IT administrators who want to deploy organization-wide.

1. [Upload to Teams app catalog](#admin-deployment)
2. [Make available to users](#admin-deployment)

---

## Step-by-Step Installation

### Step 1: Download Solution

Download the solution package:
- **File**: `OOOOOCalendar_1_0_0_0.cab`
- **Size**: ~5-10 MB
- **Source**: [Download from releases](../../releases) or contact your IT administrator

---

### Step 2: Import Solution

#### 2.1 Open Power Apps in Teams

1. Open **Microsoft Teams**
2. Click **Power Apps** in the left sidebar
   - If not visible: Click **Apps** → Search "Power Apps" → **Add**
3. Click **Build** tab
4. Select your team from the list

#### 2.2 Import the Solution

1. Click **See all** (opens Power Apps)
2. Click **Solutions** (left menu)
3. Click **Import solution** (top toolbar)
4. Click **Browse**
5. Select `OOOOOCalendar_1_0_0_0.cab`
6. Click **Next**

#### 2.3 Configure Connections

The import will prompt you to create connections if they don't exist:

**Required Connections**:
- ✅ **Microsoft Dataverse** - Click **Select a connection** → **+ New connection** → **Create**
- ✅ **Office 365 Users** - Click **Select a connection** → **+ New connection** → **Create**
- ✅ **Office 365 Outlook** - Click **Select a connection** → **+ New connection** → **Create**
- ✅ **Approvals** - Click **Select a connection** → **+ New connection** → **Create**

All connections should show green checkmarks ✓

#### 2.4 Complete Import

1. Click **Import**
2. Wait for import to complete (2-5 minutes)
3. You'll see: **"Solution 'OOOOO Calendar' imported successfully"**

✅ **Success!** The solution is now installed in your environment.

---

### Step 3: Configure Security

#### 3.1 Populate User Profiles

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

**Tip**: For 11+ users, consider using Excel import:
- Export template
- Fill in spreadsheet
- Import data

#### 3.2 Assign Security Roles

**All Staff**:
1. Go to **Settings** → **Security** → **Teams**
2. Select your team
3. Assign **OOOOO Calendar User** role to all team members

**Managers**:
1. Same as above
2. Additionally assign **OOOOO Calendar Manager** role to managers

---

### Step 4: Enable Flows

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

### Step 5: Add to Teams

#### 5.1 Open the Canvas App

1. In Solutions, click **OOOOO Calendar**
2. Click **Apps** (filter)
3. Click **OOOOO Calendar** (canvas app)
4. App opens in play mode

#### 5.2 Add as Teams Tab

**Method 1: From Power Apps**
1. In the running app, click **...** (more options)
2. Click **Add to Teams**
3. Select **Add to a team**
4. Choose your team
5. Choose a channel (e.g., "General")
6. Tab name: "OOOOO Calendar" or "Schedule"
7. Click **Save**

**Method 2: From Teams**
1. Open Microsoft Teams
2. Go to your team → select a channel
3. Click **+** (Add a tab)
4. Search for "Power Apps"
5. Select **Power Apps**
6. Choose **OOOOO Calendar**
7. Click **Save**

✅ **Success!** The app is now available as a tab in your Teams channel.

---

### Step 6: Test the App

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

---

## Admin Deployment

For IT administrators deploying organization-wide:

### Upload to Teams App Catalog

1. Go to **Teams Admin Center**: https://admin.teams.microsoft.com
2. Navigate to **Teams apps** → **Manage apps**
3. Click **Upload new app**
4. Upload `OOOOOCalendar_1_0_0_0.cab`
5. Configure app settings:
   - **Status**: Allowed
   - **Availability**: Make available to specific users/teams
6. Click **Publish**

### Deploy to Users

1. Create app setup policy
2. Add OOOOO Calendar to policy
3. Assign policy to users/groups
4. Users will see app in Teams

---

## Post-Installation

### Train Your Users

Share the user guides with your team:
- **Staff**: See `docs/user-guide-staff.md`
- **Managers**: See `docs/user-guide-manager.md`

### Monitor Usage

**First Week**:
- Check flow run history for errors
- Verify approvals are being delivered
- Monitor Teams notifications

**First Month**:
- Review approval turnaround times
- Collect user feedback
- Address any issues

---

## Troubleshooting

### Import Fails

**Error**: "Solution import failed"
- **Fix**: Ensure you're in a Dataverse for Teams environment
- Verify you have permissions to import solutions
- Try creating a new team and importing there

### Flows Not Triggering

**Error**: Approval requests not being sent
- **Fix**: Verify flows are turned **On**
- Check manager email in User Profiles is correct
- Review flow run history for errors
- Re-authenticate connections

### App Shows "No Data"

**Error**: App loads but shows no schedule data
- **Fix**: Ensure User Profiles table is populated
- Verify user has security role assigned
- Check table permissions

### Approval Not Appearing in Teams

**Error**: Manager doesn't receive approval request
- **Fix**: Check Approvals connector is connected
- Verify manager's Teams notifications are enabled
- Look in **Approvals** app in Teams (may be in separate app)
- Check flow run history for delivery confirmation

### Calendar Event Not Creating

**Error**: Outlook event doesn't appear after approval
- **Fix**: Verify Outlook connector is connected
- Ensure user has Outlook license
- Check Calendar Sync flow is enabled
- Test flow manually

---

## Support

### Getting Help

- **User questions**: See user guides in `/docs` folder
- **Technical issues**: Contact your IT administrator
- **Bug reports**: Document issue with screenshots

### Resources

- **Architecture**: See `SOLUTION-PACKAGE-SPEC.md`
- **User Guides**: See `/docs` folder
- **Power Apps Community**: https://powerusers.microsoft.com

---

## Success Checklist

Installation is complete when:

- [x] Solution imported successfully
- [x] User Profiles populated for all team members
- [x] Security roles assigned
- [x] All 3 flows enabled and tested
- [x] App added to Teams channel
- [x] Test OOO request approved successfully
- [x] Calendar event created in Outlook
- [x] Team members can access app
- [x] User guides shared with team

---

## What's Next?

1. ✅ **Go Live**: Announce app availability to team
2. ✅ **Monitor**: Watch for issues in first week
3. ✅ **Gather Feedback**: Collect user suggestions
4. ✅ **Iterate**: Make improvements based on feedback

---

## Version Information

- **Solution Version**: 1.0.0.0
- **Installation Guide Version**: 1.0.0
- **Last Updated**: November 2025

---

**🎉 Congratulations!** Your OOOOO Calendar Teams app is now installed and ready to use.

For questions, refer to the user guides or contact your IT administrator.
