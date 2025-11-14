# OOOOO Calendar - Deployment Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Phase 1: SharePoint Setup](#phase-1-sharepoint-setup)
3. [Phase 2: Power Automate Flows](#phase-2-power-automate-flows)
4. [Phase 3: Power Apps Development](#phase-3-power-apps-development)
5. [Phase 4: Teams Integration](#phase-4-teams-integration)
6. [Phase 5: Testing & Validation](#phase-5-testing--validation)
7. [Phase 6: User Training & Rollout](#phase-6-user-training--rollout)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Licenses
- ✅ Microsoft 365 Business Standard or higher
- ✅ Power Apps license (included with M365)
- ✅ Power Automate license (included with M365)
- ✅ Microsoft Teams license
- ✅ SharePoint Online license

### Required Permissions
- ✅ SharePoint Site Collection Administrator
- ✅ Power Apps Environment Maker
- ✅ Power Automate Environment Maker
- ✅ Teams App Setup Policy (to add custom apps)

### Technical Requirements
- ✅ Windows PowerShell 5.1+ or PowerShell 7+
- ✅ PnP.PowerShell module
- ✅ Modern web browser (Edge, Chrome, Firefox)
- ✅ Microsoft Teams desktop or web client

### Team Information Needed
- ✅ List of all team members with email addresses
- ✅ Manager email addresses
- ✅ Department/team names (optional)
- ✅ Any existing schedule data to migrate

---

## Phase 1: SharePoint Setup

### Step 1.1: Create SharePoint Site

**Time Required**: 15 minutes

1. Navigate to **SharePoint Admin Center**: https://admin.microsoft.com/sharepoint
2. Click **Sites** → **Active sites** → **Create**
3. Choose **Team site**
4. Configure site:
   - **Site name**: `OOOOO Calendar`
   - **Site address**: `/sites/OOOOOCalendar` (or your preference)
   - **Primary administrator**: Your admin account
   - **Language**: English
   - **Time zone**: Central Time (US & Canada)
5. Click **Finish**
6. Wait for site creation to complete
7. Navigate to your new site and copy the URL

**Checkpoint**: ✓ SharePoint site created and accessible

---

### Step 1.2: Install PnP.PowerShell Module

**Time Required**: 5 minutes

Open PowerShell as Administrator and run:

```powershell
# Check if module is already installed
Get-Module -ListAvailable -Name PnP.PowerShell

# If not installed, install it
Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force

# Verify installation
Get-Module -ListAvailable -Name PnP.PowerShell
```

**Checkpoint**: ✓ PnP.PowerShell module installed

---

### Step 1.3: Run SharePoint List Creation Script

**Time Required**: 10 minutes

1. Clone or download this repository to your computer
2. Navigate to the `scripts` folder
3. Open PowerShell and run:

```powershell
cd "C:\path\to\OOOOO-Calendar\scripts"

# Run the setup script
.\setup-sharepoint-lists.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/OOOOOCalendar"
```

4. When prompted, authenticate with your admin credentials
5. The script will create all required lists and columns
6. Review the output for any errors

**Expected Output**:
```
========================================
OOOOO Calendar - SharePoint List Setup
========================================

Connecting to SharePoint site: https://...
✓ Connected successfully

Step 1: Creating SharePoint Lists
===================================
Creating list: StaffSchedule
  ✓ List 'StaffSchedule' created successfully
Creating list: ApprovalHistory
  ✓ List 'ApprovalHistory' created successfully
...
Setup Complete!
```

**Checkpoint**: ✓ All SharePoint lists created successfully

---

### Step 1.4: Populate UserProfiles List

**Time Required**: 20-30 minutes (depending on team size)

1. Navigate to your SharePoint site
2. Click **Site contents** → **UserProfiles**
3. Click **New** to add each team member
4. For each user, fill in:
   - **User Email**: user@domain.com
   - **User Account**: Select from people picker
   - **Display Name**: Full name
   - **Manager**: Select manager from people picker
   - **Manager Email**: manager@domain.com
   - **Department**: (Optional) Team or department name
   - **Is Manager**: Check if this person is a manager
   - **Is Active**: ✓ Checked
   - **Notification Preferences**: Both (default)
   - **Time Zone**: Central (default)
5. Click **Save**
6. Repeat for all team members

**Alternative**: Bulk import via PowerShell or Excel import

**Checkpoint**: ✓ All users added to UserProfiles list

---

### Step 1.5: Configure SharePoint Permissions

**Time Required**: 15 minutes

#### Option A: Use SharePoint Groups (Recommended)

1. Navigate to **Site settings** → **Site permissions**
2. Create custom permission level:
   - Click **Permission Levels** → **Add a Permission Level**
   - Name: `OOOOO Staff`
   - Permissions:
     - List: View Items, Add Items, Edit Items (own only)
     - Site: View Pages, Browse User Information
   - Save

3. Create SharePoint groups:
   - **OOOOO Staff Members**: All staff (read own, write own)
   - **OOOOO Managers**: Managers (read all, write all)

4. Add users to appropriate groups

5. Set list-specific permissions:
   - **StaffSchedule**: Staff can read/write own items, Managers can read/write all
   - **ApprovalHistory**: Staff can read own, Managers can read all
   - **UserProfiles**: Everyone can read, Managers can edit
   - **SystemSettings**: Everyone can read, Managers can edit

#### Option B: Use PowerShell Script

```powershell
.\configure-permissions.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/OOOOOCalendar"
```

**Checkpoint**: ✓ Permissions configured correctly

---

## Phase 2: Power Automate Flows

### Step 2.1: Create OOO Approval Flow

**Time Required**: 30-45 minutes

1. Navigate to **Power Automate**: https://make.powerautomate.com
2. Click **Create** → **Automated cloud flow**
3. Name: `OOOOO-ApprovalWorkflow`
4. Trigger: **When an item is created or modified** (SharePoint)
5. Configure trigger:
   - Site Address: Select your OOOOO Calendar site
   - List Name: `StaffSchedule`
6. Follow the flow design in `/power-automate/ooo-approval-flow-design.md`

**Key Steps to Add**:

1. **Condition**: Check if Status = "OOO-Pending"
2. **Get items**: Fetch manager info from UserProfiles
3. **Initialize variables**: Store employee and request details
4. **Create item**: Add to ApprovalHistory (Submitted)
5. **Start and wait for approval**: Teams approval
6. **Condition**: Check approval outcome
7. **Update item**: Set status to Approved/Rejected
8. **Create event** (if approved): Add to Outlook calendar
9. **Post message**: Send Teams notification
10. **Create item**: Add to ApprovalHistory (Approved/Rejected)

**Testing**:
1. Save the flow
2. Create a test OOO request in SharePoint
3. Verify approval request appears in Teams
4. Approve or reject the request
5. Verify status updates in SharePoint
6. Verify notification received in Teams

**Checkpoint**: ✓ Approval flow working correctly

---

### Step 2.2: Create Calendar Sync Flow (Optional)

**Time Required**: 20 minutes

This flow ensures Outlook calendar stays in sync with approved OOO requests.

1. Create new automated flow: `OOOOO-CalendarSync`
2. Trigger: When item is modified in StaffSchedule
3. Condition: Status changed to "OOO-Approved"
4. Create or update Outlook calendar event
5. Store calendar event ID in StaffSchedule

See `/power-automate/calendar-sync-flow-design.md` for details.

**Checkpoint**: ✓ Calendar sync flow created (optional)

---

### Step 2.3: Create Daily Reminder Flow (Optional)

**Time Required**: 15 minutes

This flow sends daily reminders to update status.

1. Create new scheduled flow: `OOOOO-DailyReminders`
2. Recurrence: Daily at 8:00 AM (Central Time)
3. Get all active users from UserProfiles
4. For each user, post Teams message reminder
5. Include quick action buttons (if possible)

See `/power-automate/notification-flow-design.md` for details.

**Checkpoint**: ✓ Reminder flow created (optional)

---

## Phase 3: Power Apps Development

### Step 3.1: Create New Canvas App

**Time Required**: 5 minutes

1. Navigate to **Power Apps**: https://make.powerapps.com
2. Click **Create** → **Canvas app from blank**
3. App name: `OOOOO Calendar`
4. Format: **Tablet** (works for both desktop and mobile)
5. Click **Create**

**Checkpoint**: ✓ Blank canvas app created

---

### Step 3.2: Connect to Data Sources

**Time Required**: 10 minutes

1. In Power Apps Studio, click **Data** (left panel)
2. Click **Add data** → **Connectors** → **SharePoint**
3. Connect to your SharePoint site
4. Add all four lists:
   - ✓ StaffSchedule
   - ✓ ApprovalHistory
   - ✓ UserProfiles
   - ✓ SystemSettings
5. Add **Office 365 Users** connector (for user info)
6. Add **Office 365 Outlook** connector (optional, for calendar)

**Checkpoint**: ✓ All data sources connected

---

### Step 3.3: Set App Properties

**Time Required**: 5 minutes

1. Click **App** in the tree view (left panel)
2. Set properties:
   - **OnStart** formula:
     ```excel
     // Load current user
     Set(varCurrentUser, User());

     // Load user profile
     Set(varUserProfile,
         LookUp(UserProfiles,
                UserAccount.Email = varCurrentUser.Email)
     );

     // Set manager flag
     Set(varIsManager, varUserProfile.IsManager);

     // Load system settings
     ClearCollect(colSystemSettings, SystemSettings);

     // Set color scheme
     Set(varColorOnsite, RGBA(76, 175, 80, 1));
     Set(varColorOffsite, RGBA(33, 150, 243, 1));
     Set(varColorPending, RGBA(255, 193, 7, 1));
     Set(varColorApproved, RGBA(156, 39, 176, 1));
     ```

**Checkpoint**: ✓ App initialization configured

---

### Step 3.4: Build Home Dashboard Screen

**Time Required**: 45-60 minutes

Follow the specifications in `/power-apps/screens/home-dashboard.md`

**Key Components to Add**:

1. **Header**:
   - Label: "OOOOO Calendar"
   - User greeting: "Hello, " & varCurrentUser.FullName
   - Date display

2. **Today's Status Card**:
   - Display current status
   - Quick update button

3. **Upcoming Schedule Gallery**:
   - Items: Next 7 days
   - Color-coded status
   - Edit buttons

4. **Navigation Buttons**:
   - "Request Time Off"
   - "My Schedule"
   - "Team Calendar"
   - "Approvals" (managers only)

See detailed component specs in `/power-apps/app-structure.md`

**Checkpoint**: ✓ Home screen functional

---

### Step 3.5: Build My Schedule Screen

**Time Required**: 45 minutes

1. Add new screen: `scrMySchedule`
2. Add header with back button
3. Add calendar component or gallery
4. Add request history gallery
5. Add "New Request" button
6. Implement OnVisible formula to load user's schedule

See `/power-apps/screens/my-schedule.md` for details.

**Checkpoint**: ✓ My Schedule screen functional

---

### Step 3.6: Build Request Form

**Time Required**: 60 minutes

1. Add new screen or container: `scrRequestForm`
2. Add form components:
   - Date pickers (start/end)
   - Request type dropdown
   - Comments text box
   - Submit/Cancel buttons
3. Implement validation logic:
   - Minimum advance notice
   - No overlapping requests
   - Valid date range
4. Implement submit logic to create SharePoint items

See `/power-apps/screens/request-form.md` for details.

**Checkpoint**: ✓ Request form working with validation

---

### Step 3.7: Build Team Calendar Screen

**Time Required**: 90-120 minutes (most complex)

This is the most complex screen with a grid calendar view.

1. Add new screen: `scrTeamCalendar`
2. Create calendar grid using galleries:
   - Outer gallery: Team members (rows)
   - Inner gallery: Dates (columns)
   - Cell formula: Lookup status for employee + date
3. Add date navigation (previous/next week, month)
4. Add status legend
5. Add filters (employee, status)

**Alternative**: Use calendar component from Power Apps component framework

See `/power-apps/screens/team-calendar.md` for detailed implementation.

**Checkpoint**: ✓ Team calendar displaying correctly

---

### Step 3.8: Build Manager Approvals Screen

**Time Required**: 60 minutes

1. Add new screen: `scrManagerApprovals`
2. Set Visible property: `varIsManager`
3. Add pending requests gallery
4. Add request details panel
5. Add approve/reject buttons with logic
6. Update SharePoint items on approval/rejection

See `/power-apps/screens/manager-approvals.md` for details.

**Note**: This screen duplicates some functionality of the Teams approval, but provides in-app management.

**Checkpoint**: ✓ Manager approvals screen functional

---

### Step 3.9: Apply Branding & Themes

**Time Required**: 30 minutes

1. Click **App** → **Color** property
2. Define color palette:
   ```excel
   {
       Primary: RGBA(0, 120, 212, 1),
       Secondary: RGBA(76, 175, 80, 1),
       Success: RGBA(76, 175, 80, 1),
       Warning: RGBA(255, 193, 7, 1),
       Error: RGBA(244, 67, 54, 1),
       Background: RGBA(250, 250, 250, 1),
       Surface: RGBA(255, 255, 255, 1)
   }
   ```
3. Apply consistent fonts (Segoe UI recommended)
4. Set consistent spacing and padding
5. Add your organization logo (optional)

See `/power-apps/color-theme.json` for full theme.

**Checkpoint**: ✓ App styling consistent and professional

---

### Step 3.10: Mobile Optimization

**Time Required**: 30 minutes

1. Add responsive formulas:
   ```excel
   If(App.Width < 768,
       /* Mobile layout */,
       /* Desktop layout */
   )
   ```
2. Test on different screen sizes
3. Adjust button sizes for touch (min 48x48px)
4. Use vertical stacking for mobile
5. Test in Teams mobile app

**Checkpoint**: ✓ App works on mobile devices

---

### Step 3.11: Save and Publish App

**Time Required**: 5 minutes

1. Click **File** → **Save**
2. Add version notes: "Initial release v1.0"
3. Click **Publish**
4. Click **Publish this version**
5. Share app with test users initially

**Checkpoint**: ✓ App published and accessible

---

## Phase 4: Teams Integration

### Step 4.1: Add App to Teams App Catalog

**Time Required**: 15 minutes

1. In Power Apps, click **File** → **Settings** → **Upcoming features**
2. Enable **Add to Teams** feature
3. Click **File** → **Add to Teams**
4. Or download the Teams manifest and upload manually

**Alternative - Manual Upload**:

1. Go to Teams Admin Center
2. Navigate to **Teams apps** → **Manage apps**
3. Click **Upload new app**
4. Upload Power Apps package
5. Configure app settings

**Checkpoint**: ✓ App available in Teams app catalog

---

### Step 4.2: Add App to Team Channel

**Time Required**: 5 minutes

1. Open Microsoft Teams
2. Navigate to your team
3. Click **+** to add a tab
4. Search for "OOOOO Calendar"
5. Click **Add**
6. Configure tab name: "Schedule Calendar"
7. Click **Save**

**Checkpoint**: ✓ App pinned as tab in Teams channel

---

### Step 4.3: Configure Personal App

**Time Required**: 5 minutes

1. Users can add app to personal Teams sidebar
2. In Teams, click **Apps**
3. Search "OOOOO Calendar"
4. Click **Add**
5. App appears in left sidebar for quick access

**Checkpoint**: ✓ Users can access app as personal app

---

## Phase 5: Testing & Validation

### Step 5.1: Create Test Data

**Time Required**: 15 minutes

1. Create sample schedule entries for test users
2. Create sample OOO requests (pending, approved, rejected)
3. Populate approval history
4. Run test data script (optional):
   ```powershell
   .\test-data-generator.ps1 -SiteUrl "https://..."
   ```

**Checkpoint**: ✓ Test data created

---

### Step 5.2: Functional Testing

**Time Required**: 60-90 minutes

**Test Cases**:

| Test Case | Steps | Expected Result | Status |
|-----------|-------|-----------------|--------|
| User Login | Open app in Teams | App loads, user recognized | [ ] |
| View Home | Navigate to home | Today's status shown | [ ] |
| Update Status | Change status to Offsite | Status updated in SharePoint | [ ] |
| Submit OOO Request | Fill form, submit | Request created, status = Pending | [ ] |
| Manager Approval | Manager receives Teams approval | Approval appears in Teams | [ ] |
| Approve Request | Manager approves | Status changes to Approved | [ ] |
| Calendar Sync | Check Outlook calendar | OOO event created | [ ] |
| Notification | Employee checks Teams | Approval notification received | [ ] |
| View Team Calendar | Open team calendar | All team schedules visible | [ ] |
| Reject Request | Manager rejects OOO | Status = Rejected, notification sent | [ ] |
| Cancel Request | User cancels pending request | IsActive = false | [ ] |
| View History | Check approval history | All actions recorded | [ ] |
| Mobile Access | Open app on Teams mobile | App works responsively | [ ] |

**Checkpoint**: ✓ All test cases passed

---

### Step 5.3: Performance Testing

**Time Required**: 30 minutes

1. **Load Time**: Home screen should load in <3 seconds
2. **Calendar Rendering**: Team calendar should render in <5 seconds
3. **Form Submission**: OOO request submission <2 seconds
4. **Flow Execution**: Approval request delivered within 5 minutes

**Checkpoint**: ✓ Performance meets requirements

---

### Step 5.4: User Acceptance Testing (UAT)

**Time Required**: 1-2 weeks

1. Select 3-5 pilot users (including at least one manager)
2. Provide access to app
3. Give brief training (15 minutes)
4. Ask them to use app for 1-2 weeks
5. Collect feedback via survey or interviews
6. Address any issues or concerns
7. Iterate based on feedback

**Checkpoint**: ✓ UAT completed with positive feedback

---

## Phase 6: User Training & Rollout

### Step 6.1: Create User Documentation

**Time Required**: 60 minutes

Documentation should cover:
- How to access the app
- How to update daily status
- How to submit OOO requests
- How to view team calendar
- How managers approve requests
- Troubleshooting common issues

See `/docs/user-guide-staff.md` and `/docs/user-guide-manager.md`

**Checkpoint**: ✓ User guides created

---

### Step 6.2: Create Video Tutorials (Optional)

**Time Required**: 2-3 hours

Create short (5-10 minute) videos:
1. Introduction to OOOOO Calendar
2. Submitting your first time-off request
3. Viewing the team calendar
4. Manager approval workflow
5. Tips and tricks

**Checkpoint**: ✓ Video tutorials created (optional)

---

### Step 6.3: Conduct Training Sessions

**Time Required**: 1-2 hours per session

**Recommended Approach**:

**Session 1: All Staff** (30 minutes)
- Overview of the system
- Demo: Daily status updates
- Demo: Submitting OOO requests
- Demo: Viewing schedules
- Q&A

**Session 2: Managers** (30 minutes)
- All staff features
- Demo: Approval workflow
- Demo: Team calendar management
- Demo: Reporting and history
- Q&A

**Alternative**: Record sessions and share as on-demand training

**Checkpoint**: ✓ Training sessions completed

---

### Step 6.4: Phased Rollout

**Time Required**: 2-4 weeks

**Week 1**: Pilot Group (3-5 users)
- Deploy to small group
- Monitor closely
- Fix any critical issues

**Week 2**: Managers and Early Adopters
- Add all managers
- Add enthusiastic staff members
- Gather feedback

**Week 3**: Remaining Staff
- Roll out to entire team
- Send announcement
- Provide support

**Week 4**: Monitor and Support
- Monitor usage
- Address issues
- Collect feedback for improvements

**Checkpoint**: ✓ Full rollout completed

---

### Step 6.5: Communications Plan

**Before Launch**:
- Email announcement (2 weeks before)
- Training session invitations
- Link to user guide

**At Launch**:
- Teams channel announcement
- Quick start guide
- Support contact info

**After Launch**:
- Weekly usage reminders (first month)
- Tips and tricks posts
- Success stories

**Checkpoint**: ✓ Communications sent

---

## Post-Deployment

### Monitoring & Support

**Daily** (First Week):
- Check flow run history for errors
- Monitor Teams approval delivery
- Respond to user questions quickly

**Weekly** (First Month):
- Review usage analytics
- Check for common issues
- Collect user feedback

**Monthly** (Ongoing):
- Review approval metrics
- Update documentation as needed
- Plan feature enhancements

### Key Metrics to Track

| Metric | Target | How to Measure |
|--------|--------|----------------|
| User Adoption Rate | >90% | Track logins in Power Apps analytics |
| Approval Turnaround Time | <24 hours | Average from ApprovalHistory |
| Flow Success Rate | >95% | Power Automate analytics |
| User Satisfaction | >4.0/5.0 | Quarterly survey |
| Support Tickets | <5/month | Track help requests |

---

## Troubleshooting

### Common Issues

**Issue**: "Users can't see the app in Teams"
- **Solution**: Check app is published and shared with users
- Check Teams app policy allows custom apps

**Issue**: "Approval requests not being sent"
- **Solution**: Check flow is enabled and not suspended
- Verify manager email in UserProfiles is correct
- Check flow run history for errors

**Issue**: "Calendar events not creating in Outlook"
- **Solution**: Verify Outlook connector has correct permissions
- Check calendar sync flow is running
- Verify user has Outlook license

**Issue**: "Users can only see their own data"
- **Solution**: Check SharePoint list permissions
- Managers need read access to all items in StaffSchedule

**Issue**: "App loads slowly"
- **Solution**: Reduce amount of data loaded OnVisible
- Use collections instead of direct SharePoint queries
- Implement pagination in galleries

**Issue**: "Mobile layout broken"
- **Solution**: Test App.Width responsive formulas
- Ensure components have responsive sizing
- Test on actual device, not just emulator

---

## Rollback Plan

If critical issues arise:

1. **Disable Power Automate Flows**: Prevents new approvals from processing
2. **Hide Power App**: Remove from Teams channel
3. **Communicate Issue**: Notify users via Teams/email
4. **Revert to Previous Process**: Use existing manual/email process temporarily
5. **Fix Issue**: Address root cause
6. **Re-test**: Validate fix with pilot group
7. **Re-deploy**: Roll out again when stable

---

## Success Criteria

✅ All 11+ team members have access to the app
✅ At least 10 OOO requests successfully approved via Teams
✅ Team calendar displays all team members accurately
✅ No critical bugs or data loss incidents
✅ User satisfaction score >4.0/5.0
✅ Manager reports time savings in approval process
✅ Reduced email traffic about schedules and time-off

---

## Next Steps

After successful deployment:

1. **Gather Enhancement Requests**: Collect ideas for v2.0
2. **Plan Advanced Features**:
   - Integration with HR systems
   - Advanced reporting dashboards
   - Mobile push notifications
   - Automated PTO balance tracking
   - Holiday calendar integration
3. **Optimize Performance**: Based on usage patterns
4. **Expand to Other Teams**: If successful, roll out organization-wide

---

## Support Contacts

- **Technical Issues**: [IT Support Email]
- **Business Questions**: [Manager Email]
- **Feature Requests**: [Product Owner Email]
- **Documentation**: See `/docs` folder in this repository

---

**Document Version**: 1.0.0
**Last Updated**: November 2025
**Maintained By**: OOOOO Calendar Project Team

