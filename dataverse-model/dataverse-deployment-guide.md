# OOOOO Calendar - Dataverse Deployment Guide

## Overview

This guide walks you through deploying the OOOOO Calendar **Dataverse solution** to Microsoft Teams. This is the **Boards-style packaged solution** that can be imported in 30-60 minutes.

**Total Deployment Time**: 30-60 minutes
**Difficulty**: Beginner to Intermediate

---

## Prerequisites

### Required Access
- ✅ Microsoft Teams license
- ✅ Power Apps license (included with M365)
- ✅ Ability to create apps in Teams
- ✅ Team ownership or admin permissions

### Technical Requirements
- ✅ Microsoft Teams (desktop or web)
- ✅ Modern web browser
- ✅ Administrator or member role in target team

###No Premium Licenses Required!
- ❌ NO Dataverse premium license needed
- ❌ NO Power Apps per-app plan needed
- ❌ NO additional connector fees

**Dataverse for Teams is included with your Teams license!**

---

## Deployment Overview

```
Step 1: Prepare Environment (5 min)
    ↓
Step 2: Import Solution (10 min)
    ↓
Step 3: Configure Security (10 min)
    ↓
Step 4: Populate User Data (15 min)
    ↓
Step 5: Enable Flows (5 min)
    ↓
Step 6: Add to Teams (5 min)
    ↓
Step 7: Test & Validate (10 min)
```

---

## Step 1: Prepare Environment

### 1.1 Create Dataverse for Teams Environment

1. **Open Microsoft Teams**
2. Click **Power Apps** app in the left sidebar
   - If not visible, click **Apps** → Search "Power Apps" → **Add**
3. Click **Build** tab
4. Select your team from the list
   - If this is your first time, you'll see "Create your first app"
5. Click **See all** to open the environment

✅ **Checkpoint**: You can see the Power Apps environment for your team

### 1.2 Verify Environment Creation

1. In Power Apps, click **Tables** (left menu)
2. You should see built-in tables like "Users"
3. Note your environment name (usually matches team name)

✅ **Checkpoint**: Dataverse environment is ready

---

## Step 2: Import Solution

### 2.1 Download Solution Package

1. Navigate to the `dataverse-solution` folder in this repository
2. Download `OOOOOCalendar_1_0_0_0.zip`
   - **Note**: If solution file doesn't exist yet, see "Building the Solution" section at end of this guide

### 2.2 Import into Power Apps

1. In Power Apps (in Teams), click **See all**
2. Click **Solutions** (left menu)
3. Click **Import solution** (top ribbon)
4. Click **Browse**
5. Select `OOOOOCalendar_1_0_0_0.zip`
6. Click **Next**

### 2.3 Import Connections

If prompted to create connections:

1. **Microsoft Dataverse** - Click **Select a connection** → **+ New connection** → **Create**
2. **Office 365 Users** - Click **Select a connection** → **+ New connection** → **Create**
3. **Office 365 Outlook** - Click **Select a connection** → **+ New connection** → **Create**
4. **Approvals** - Click **Select a connection** → **+ New connection** → **Create**

All connections should show green checkmarks.

### 2.4 Complete Import

1. Click **Import**
2. Wait for import to complete (2-5 minutes)
3. You'll see "Solution imported successfully"

✅ **Checkpoint**: Solution appears in Solutions list

---

## Step 3: Configure Security

### 3.1 View Security Roles

1. In **Solutions**, click **OOOOO Calendar**
2. Click **Security roles** (left filter)
3. You should see:
   - OOOOO Calendar User
   - OOOOO Calendar Manager

### 3.2 Assign User Role to All Team Members

**Option A: Assign to Everyone**

1. Go to https://admin.powerplatform.microsoft.com
2. Click **Environments**
3. Find your Teams environment
4. Click **Settings** → **Users + permissions** → **Security roles**
5. Find **OOOOO Calendar User**
6. Click **+ Add people**
7. Search for team members
8. Select all staff members
9. Click **Add**

**Option B: Make Default Role** (Easier)

1. In Power Apps, go to your environment
2. Click **Settings** (gear icon) → **Security**
3. Edit **OOOOO Calendar User** role
4. Under **Access**, ensure basic privileges are set

### 3.3 Assign Manager Role

1. Identify who are managers (people who approve requests)
2. In Security roles, find **OOOOO Calendar Manager**
3. Click **+ Add people**
4. Search for each manager
5. Add them to the role

✅ **Checkpoint**: Users and managers have appropriate security roles

---

## Step 4: Populate User Data

### 4.1 Open User Profiles Table

1. In Power Apps, click **Tables**
2. Find **User Profile** (or search "ooooo_userprofile")
3. Click to open
4. Click **+ New row** (or **Data** tab)

### 4.2 Create User Profile for Each Team Member

For each team member, create a row:

**Required Fields:**
- **Display Name**: Full name (e.g., "John Doe")
- **User**: Select from people picker
- **Email**: user@domain.com
- **Manager**: Select manager from people picker
- **Manager Email**: manager@domain.com
- **Is Manager**: ✓ if this person is a manager
- **Is Active**: ✓ (checked)
- **Notification Preferences**: Both (default)
- **Time Zone**: Central (or your region)

**Example Row:**
```
Display Name: John Doe
User: John Doe (john.doe@contoso.com)
Email: john.doe@contoso.com
Manager: Jane Smith
Manager Email: jane.smith@contoso.com
Department: IT Services
Is Manager: ☐
Is Active: ✓
Notification Preferences: Both
Time Zone: Central
First Time User: ✓
```

### 4.3 Bulk Import (Alternative Method)

**If you have many users:**

1. Download Excel template:
   - In **User Profile** table, click **Data** → **Export template**
2. Fill in Excel with all user data:
   - Use email addresses for User and Manager columns
   - Is Manager: TRUE/FALSE
   - Is Active: TRUE
3. Save Excel file
4. Import back:
   - Click **Data** → **Get data** → **Get data from Excel**
   - Upload your filled template
   - Map columns
   - Import

✅ **Checkpoint**: All 11+ team members have User Profile records

---

## Step 5: Enable Power Automate Flows

### 5.1 View Flows

1. In **Solutions**, click **OOOOO Calendar**
2. Click **Cloud flows** (left filter)
3. You should see:
   - OOOOO - OOO Approval Workflow
   - OOOOO - Calendar Sync
   - OOOOO - Daily Reminder (optional)

### 5.2 Turn On Flows

For each flow:

1. Click the flow name
2. If prompted to update connections, click **Edit**
3. For each connection:
   - Click on the connection
   - Select your connection or create new
   - Save
4. Click **Turn on** (top right)
5. Verify status shows "On"

### 5.3 Test Approval Flow

1. Manually create a test Staff Schedule record:
   - Go to **Tables** → **Staff Schedule**
   - Click **+ New row**
   - Fill in:
     - Request ID: TEST-001
     - Employee: You
     - Employee Email: your email
     - Schedule Date: Tomorrow
     - Start Date: Tomorrow
     - End Date: Tomorrow
     - Status: **OOO-Pending** (this triggers the flow!)
     - Request Type: Vacation
     - Submission Date/Time: Now
     - Is Active: Yes

2. Wait 1-2 minutes
3. Check Microsoft Teams for approval request
4. If you see the approval, the flow works! ✅

✅ **Checkpoint**: All flows are enabled and tested

---

## Step 6: Add App to Teams

### 6.1 Open the Canvas App

1. In **Solutions**, click **OOOOO Calendar**
2. Click **Apps** (left filter)
3. Click **OOOOO Calendar** (canvas app)
4. App opens in player mode

### 6.2 Add to Teams

**Method 1: From Power Apps**

1. In the app, click **...** (more options)
2. Click **Add to Teams**
3. Select **Add to a team**
4. Choose your team
5. Choose a channel (e.g., "General")
6. Click **Save**

**Method 2: From Teams Directly**

1. Open Microsoft Teams
2. Go to your team
3. Click **+** (Add a tab)
4. Search for "Power Apps"
5. Select **Power Apps**
6. Choose **OOOOO Calendar** from the list
7. Click **Save**

### 6.3 Configure Tab

1. Name the tab: "OOOOO Calendar" or "Schedule Calendar"
2. ✓ Post to channel about this tab (optional)
3. Click **Save**

✅ **Checkpoint**: App is visible as a tab in your Teams channel

---

## Step 7: Test & Validate

### 7.1 Basic App Testing

**Test as Regular User:**

1. Open the app in Teams
2. Click through each screen:
   - ✅ Home dashboard loads
   - ✅ Can see today's status
   - ✅ "My Schedule" shows personal calendar
   - ✅ "Request Time Off" form opens
   - ✅ "Team Calendar" shows team members

**Test Daily Status Update:**

1. On home screen, click "Onsite" or "Offsite"
2. Verify status updates
3. Check in **Staff Schedule** table - new row created

**Test OOO Request:**

1. Click "Request Time Off"
2. Fill in form:
   - Start Date: 3 days from now
   - End Date: 5 days from now
   - Type: Vacation
   - Comments: "Test request"
3. Click **Submit**
4. Verify request appears in "My Schedule"

### 7.2 Test Approval Workflow

**As Employee:**

1. Submit OOO request (as above)
2. Note the request ID

**As Manager:**

1. Check Teams for approval request (within 5 minutes)
2. Open approval
3. Review details
4. Add comment: "Approved for testing"
5. Click **Approve**

**As Employee:**

1. Check Teams for approval notification
2. Open "My Schedule"
3. Verify status changed to "OOO-Approved"
4. Check Outlook calendar - event should be created

### 7.3 Test Team Calendar

1. Open "Team Calendar"
2. Verify all team members listed
3. Verify approved request shows as purple block
4. Click previous/next to navigate dates

✅ **Checkpoint**: All core features working

---

## Post-Deployment Configuration

### Adjust System Settings

1. Go to **Tables** → **System Setting**
2. Edit settings as needed:
   - **MinimumAdvanceNoticeDays**: Default 3, adjust as needed
   - **MaxOOODaysPerRequest**: Default 30
   - **EnableDailyReminders**: true/false
   - **SyncToOutlookCalendar**: true/false

### Customize App Branding

1. In Power Apps, edit the canvas app
2. Update colors in **App.OnStart**
3. Add organization logo
4. Publish changes

---

## User Training

### Send Welcome Email

**Template:**

```
Subject: New OOOOO Calendar System - Get Started!

Hi Team,

We've launched the OOOOO Calendar system in Microsoft Teams to manage work schedules and time-off requests.

🚀 Quick Start:
1. Open Microsoft Teams
2. Go to our team → "OOOOO Calendar" tab
3. Update your daily status (Onsite/Offsite)
4. Submit time-off requests when needed

📚 User Guide:
See attached guide or visit: [link to user guide]

💡 Key Benefits:
- Quick status updates (<30 seconds)
- Digital time-off approval via Teams
- See team availability at a glance
- Auto-sync to Outlook calendar

❓ Questions?
Contact: [your email/Teams]

Thanks!
[Your name]
```

### Training Session (Optional)

Hold a 30-minute Teams meeting:
- 10 min: Demo of submitting requests
- 10 min: Demo of team calendar
- 10 min: Q&A

---

## Troubleshooting

### Issue: "Solution import failed"

**Solution:**
- Ensure you're in a Dataverse for Teams environment (not Dataverse)
- Check you have permissions to import solutions
- Try creating a new environment and importing there

### Issue: "Flows not triggering"

**Solution:**
- Verify flows are turned ON
- Check flow run history for errors
- Ensure connections are valid
- Re-authenticate connections if needed

### Issue: "App shows 'No data'"

**Solution:**
- Ensure User Profiles table is populated
- Check user has security role assigned
- Verify table permissions in security role

### Issue: "Approval requests not appearing in Teams"

**Solution:**
- Check Approvals connector is connected
- Verify manager email in User Profiles is correct
- Check manager's Teams notification settings
- Look in Approvals app in Teams

### Issue: "Calendar events not creating in Outlook"

**Solution:**
- Verify Outlook connector is connected
- Check Calendar Sync flow is enabled
- Test flow manually with a sample request
- Ensure user has Outlook license

---

## Monitoring & Maintenance

### Weekly Checks (First Month)

- ✅ Review flow run history
- ✅ Check for failed approvals
- ✅ Monitor user adoption
- ✅ Collect feedback

### Monthly Maintenance

- ✅ Review approval turnaround times
- ✅ Check for inactive users (update User Profiles)
- ✅ Export solution as backup
- ✅ Update documentation with any changes

### Solution Backup

1. Go to **Solutions**
2. Select **OOOOO Calendar**
3. Click **Export**
4. Choose **Unmanaged**
5. Click **Export**
6. Save ZIP file to secure location
7. Repeat monthly

---

## Scaling Considerations

### Adding More Users

- User Profiles: Add new rows as team grows
- Security Roles: Auto-assign via default role
- No app changes needed!

### Multi-Team Deployment

**Option 1**: One solution per team
- Each team has own environment
- Data isolated by team

**Option 2**: Single solution, multiple teams
- Use Department field to filter
- Shared approval workflows
- Central management

### Data Growth

**Expected capacity (Dataverse for Teams):**
- 2 million rows total per environment
- 11 users × 365 days = ~4,000 rows/year
- Can easily support 100+ users for 5+ years

---

## Success Metrics

Track these KPIs:

| Metric | Target | How to Measure |
|--------|--------|----------------|
| User Adoption | >90% | Count active users in app analytics |
| Approval Time | <24 hours | Check Approval Duration in history |
| Flow Success Rate | >95% | Flow run history |
| User Satisfaction | >4.0/5.0 | Quarterly survey |

---

## Next Steps After Deployment

1. ✅ Monitor usage for first week
2. ✅ Collect user feedback
3. ✅ Schedule monthly review with stakeholders
4. ✅ Plan enhancements based on feedback
5. ✅ Consider expanding to other teams

---

## Getting Help

**Technical Issues:**
- Check Power Apps Community: https://powerusers.microsoft.com
- Microsoft Support: https://admin.microsoft.com/support

**Questions about this solution:**
- Review documentation in `/docs` folder
- Contact: [your IT support email]

---

## Building the Solution Package (For Developers)

If you need to create the solution package from scratch:

### Prerequisites
- Power Apps environment with Dataverse
- Power Platform CLI installed
- Solution created with all components

### Steps

1. **Create Solution in Power Apps:**
   ```bash
   pac solution init --publisher-name MNITServices --publisher-prefix ooooo
   ```

2. **Add Tables:**
   - Create tables as per dataverse-tables-schema.json
   - Add to solution

3. **Add Canvas App:**
   - Build app in Power Apps Studio
   - Add to solution

4. **Add Flows:**
   - Create flows as per flow designs
   - Add to solution

5. **Export Solution:**
   ```bash
   pac solution export --path OOOOOCalendar_1_0_0_0.zip --name OOOOOCalendar
   ```

6. **Test Import:**
   - Import to test environment
   - Validate all components

---

## Deployment Checklist

Use this checklist during deployment:

```
Pre-Deployment:
☐ Dataverse for Teams environment created
☐ Solution package downloaded
☐ Team members identified
☐ Manager list prepared

Deployment:
☐ Solution imported successfully
☐ Security roles configured
☐ User Profiles populated (all 11+ users)
☐ Flows enabled and tested
☐ App added to Teams channel

Testing:
☐ App loads for test user
☐ Daily status update works
☐ OOO request submission works
☐ Approval notification received
☐ Approval process completes
☐ Calendar event created
☐ Team calendar displays correctly

Go-Live:
☐ Users notified
☐ Training materials shared
☐ Support process established
☐ Monitoring configured

Post-Deployment:
☐ Usage monitored daily (first week)
☐ Feedback collected
☐ Issues resolved
☐ Success metrics tracked
```

---

**Deployment Guide Version**: 2.0.0 (Dataverse)
**Last Updated**: November 2025
**Estimated Time**: 30-60 minutes

Good luck with your deployment! 🚀

