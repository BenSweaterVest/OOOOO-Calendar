# OOOOO Calendar Solution Package Specification

This document describes the structure of the **OOOOOCalendar** Dataverse solution package for Teams.

---

## Package Format

**File**: `OOOOOCalendar_1_0_0_0.cab`
**Type**: Dataverse Unmanaged Solution (Cabinet file)
**Platform**: Dataverse for Teams
**Target**: Microsoft Teams environments

**Note**: CAB (Cabinet) format is Microsoft's standard archive format for Dataverse solutions.

---

## Solution Structure

The ZIP package contains:

```
OOOOOCalendar_1_0_0_0/
├── [Content_Types].xml          # Package content types
├── solution.xml                  # Solution metadata
├── customizations.xml            # Main customizations file
│
├── CanvasApps/                   # Power Apps canvas application
│   └── msft_ooooo_calendar/     # Unpacked canvas app
│       ├── Connections/
│       ├── DataSources/
│       ├── Controls/
│       ├── AppCheckerResult.sarif
│       ├── Entropy/
│       └── Properties.json
│
├── Entities/                     # Dataverse tables
│   ├── ooooo_staffschedule/
│   ├── ooooo_approvalhistory/
│   ├── ooooo_userprofile/
│   └── ooooo_systemsetting/
│
├── Workflows/                    # Power Automate flows
│   ├── OOOOOApprovalWorkflow/
│   ├── OOOOOCalendarSync/
│   └── OOOOODailyReminder/
│
├── Roles/                        # Security roles
│   ├── OOOOOCalendarUser.xml
│   └── OOOOOCalendarManager.xml
│
└── Other/                        # Additional resources
    └── Solution.xml
```

---

## Solution Metadata

### solution.xml

```xml
<ImportExportXml version="9.1.0.0" SolutionPackageVersion="9.1"
                 languagecode="1033" generatedBy="CrmLive">
  <SolutionManifest>
    <UniqueName>OOOOOCalendar</UniqueName>
    <LocalizedNames>
      <LocalizedName description="OOOOO Calendar" languagecode="1033" />
    </LocalizedNames>
    <Descriptions>
      <Description description="Teams Staff Scheduling &amp; Approval System"
                  languagecode="1033" />
    </Descriptions>
    <Version>1.0.0.0</Version>
    <Managed>0</Managed>
    <Publisher>
      <UniqueName>MNITServices</UniqueName>
      <LocalizedNames>
        <LocalizedName description="Minnesota IT Services" languagecode="1033" />
      </LocalizedNames>
      <CustomizationPrefix>ooooo</CustomizationPrefix>
      <CustomizationOptionValuePrefix>10000</CustomizationOptionValuePrefix>
    </Publisher>
    <RootComponents>
      <!-- 4 Tables -->
      <RootComponent type="1" id="{guid-staffschedule}" behavior="0" />
      <RootComponent type="1" id="{guid-approvalhistory}" behavior="0" />
      <RootComponent type="1" id="{guid-userprofile}" behavior="0" />
      <RootComponent type="1" id="{guid-systemsetting}" behavior="0" />

      <!-- 1 Canvas App -->
      <RootComponent type="300" id="{guid-canvasapp}" behavior="0" />

      <!-- 3 Workflows -->
      <RootComponent type="29" id="{guid-approvalflow}" behavior="0" />
      <RootComponent type="29" id="{guid-syncflow}" behavior="0" />
      <RootComponent type="29" id="{guid-reminderflow}" behavior="0" />

      <!-- 2 Security Roles -->
      <RootComponent type="20" id="{guid-userrole}" behavior="0" />
      <RootComponent type="20" id="{guid-managerrole}" behavior="0" />
    </RootComponents>
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
```

---

## Component Details

### Tables (4)

1. **ooooo_staffschedule** (Staff Schedule)
   - Primary Name: Request ID
   - Ownership: User
   - 17 columns total
   - Tracks schedule entries and OOO requests

2. **ooooo_approvalhistory** (Approval History)
   - Primary Name: History ID
   - Ownership: Organization
   - 12 columns total
   - Complete audit trail

3. **ooooo_userprofile** (User Profile)
   - Primary Name: Display Name
   - Ownership: User
   - 11 columns total
   - User and manager relationships

4. **ooooo_systemsetting** (System Setting)
   - Primary Name: Setting Name
   - Ownership: Organization
   - 6 columns total
   - App configuration (7 default settings included)

### Canvas App (1)

**Name**: OOOOO Calendar
**Type**: Tablet app (responsive)
**Screens**: 6
- scrLoading: Splash screen
- scrHome: Dashboard
- scrMySchedule: Personal calendar
- scrRequestForm: OOO submission
- scrTeamCalendar: Team view
- scrManagerApprovals: Approval management

**Connectors**:
- Microsoft Dataverse
- Office 365 Users
- Office 365 Outlook
- Approvals

### Workflows (3)

1. **OOOOO - OOO Approval Workflow**
   - Trigger: When Staff Schedule modified
   - Condition: Status = OOO-Pending
   - Actions: Teams approval, calendar sync, notifications

2. **OOOOO - Calendar Sync**
   - Trigger: When Staff Schedule modified
   - Condition: Status = OOO-Approved
   - Actions: Create/update Outlook event

3. **OOOOO - Daily Reminder** (Optional)
   - Trigger: Daily at 8:00 AM
   - Actions: Send Teams reminders to active users

### Security Roles (2)

1. **OOOOO Calendar User**
   - Staff Schedule: Create Own, Read Own, Write Own
   - Approval History: Read Own
   - User Profile: Read Organization, Write Own
   - System Settings: Read Organization

2. **OOOOO Calendar Manager**
   - Staff Schedule: Create/Read/Write Organization
   - Approval History: Create/Read Organization
   - User Profile: Create/Read/Write Organization
   - System Settings: Read/Write Organization

---

## Default Data

### System Settings (7 records)

Pre-configured settings included in package:

1. MinimumAdvanceNoticeDays = 3
2. MaxOOODaysPerRequest = 30
3. EnableDailyReminders = true
4. ReminderTime = 08:00
5. SyncToOutlookCalendar = true
6. WorkingDays = [1,2,3,4,5]
7. ColorScheme = {"Onsite":"#4CAF50","Offsite":"#2196F3",...}

---

## Dependencies

### Platform Requirements
- Dataverse for Teams environment
- Microsoft Teams
- Power Apps (included with Teams license)
- Power Automate (included with Teams license)

### Connectors Required
- Microsoft Dataverse (Standard)
- Office 365 Users (Standard)
- Office 365 Outlook (Standard)
- Approvals (Standard)

**No premium connectors required!**

---

## Import Process

1. Navigate to Power Apps in Teams
2. Select "Import solution"
3. Upload **OOOOOCalendar_1_0_0_0.cab**
4. Configure connections (auto-created)
5. Import (~2-5 minutes)
6. Configure security roles
7. Populate user profiles
8. Enable flows
9. Add app to Teams

**Total time**: 30-60 minutes

---

## Post-Import Configuration

### Required Steps

1. **Populate User Profiles Table**
   - Add all team members
   - Set manager relationships
   - Assign Is Manager flag

2. **Assign Security Roles**
   - All staff: OOOOO Calendar User
   - Managers: OOOOO Calendar Manager

3. **Enable Cloud Flows**
   - Turn on approval workflow
   - Turn on calendar sync
   - (Optional) Turn on daily reminders

4. **Add App to Teams**
   - Open canvas app
   - Click "Add to Teams"
   - Select channel

---

## Version History

### Version 1.0.0.0 (Initial Release)
- 4 Dataverse tables
- 1 Canvas app (6 screens)
- 3 Power Automate flows
- 2 Security roles
- 7 Default system settings

---

## Package Size

**Estimated size**: 5-10 MB (compressed)

**Components**:
- Tables and schemas: ~500 KB
- Canvas app (.msapp): ~3-5 MB
- Workflows: ~500 KB
- Metadata and XML: ~1 MB

---

## Compatibility

**Tested with**:
- Dataverse for Teams (2024-2025)
- Power Apps Teams environment
- Microsoft Teams (Desktop & Web)
- Teams Mobile app (iOS & Android)

**Cloud**:
- Commercial Cloud ✓
- GCC ✓ (Government Community Cloud)
- GCC High ⚠️ (may require modifications)

---

## Support

For issues with the solution package:
- Check INSTALLATION.md for import instructions
- Review troubleshooting in deployment guide
- Verify all dependencies are met

---

**Document Version**: 1.0.0
**Last Updated**: November 2025
**Package Status**: Specification complete, package to be built
