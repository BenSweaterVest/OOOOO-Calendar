# OOOOO Calendar - Teams Staff Scheduling & Approval System

A Microsoft Teams Power App solution for managing staff work location schedules and time-off requests with integrated approval workflows.

## 🎯 Two Deployment Options Available!

This solution is available in **two architectures** - choose the one that best fits your needs:

### Option 1: **Dataverse Solution** (⭐ Recommended - Like Microsoft Boards)
- ✅ **Quick deployment**: 30-60 minutes
- ✅ **Packaged solution**: Import ZIP and go
- ✅ **No premium licenses** required (uses Dataverse for Teams)
- ✅ **Better performance**: 500k+ row delegation
- ✅ **Professional ALM**: Easy export/import for updates
- 📁 See `/dataverse-model` folder

### Option 2: **SharePoint Lists Solution** (Original)
- ✅ **Full customization**: Build from detailed specs
- ✅ **Standard M365 licenses**: SharePoint Online included
- ✅ **Familiar to admins**: SharePoint-based data
- ✅ **Government-ready**: Traditional SharePoint security
- 📁 See `/data-model` and `/scripts` folders

**👉 New users: Start with Dataverse solution!**
**👉 Already using SharePoint?: Continue with your version or migrate to Dataverse**

## Project Overview

This system enables staff to:
- Report daily work location (onsite/offsite)
- Submit time-off requests (vacation/sick leave)
- View personal schedule and team availability
- Track approval status and history

Managers can:
- Approve/reject time-off requests via Teams
- View comprehensive team calendar
- Monitor team availability and absence patterns
- Access approval history and reports

## Status Types

- **Onsite**: Employee working at office location
- **Offsite**: Employee working remotely/from home
- **OOO-Pending**: Time off request awaiting manager approval
- **OOO-Approved**: Time off request approved by manager

## Repository Structure

```
OOOOO-Calendar/
├── README.md                               # This file
│
├── 📦 DATAVERSE SOLUTION (Recommended - Boards-style)
├── dataverse-model/                        # Dataverse architecture
│   ├── dataverse-tables-schema.json        # Complete Dataverse table definitions
│   ├── dataverse-architecture.md           # Architecture documentation
│   ├── dataverse-deployment-guide.md       # 30-minute deployment guide
│   ├── power-apps-formulas-dataverse.md    # Dataverse-specific formulas
│   └── OOOOOCalendar_1_0_0_0.zip          # [To be created] Importable solution package
│
├── 📋 SHAREPOINT SOLUTION (Original)
├── data-model/                             # SharePoint data structures
│   └── sharepoint-lists-schema.json        # SharePoint list definitions
├── scripts/                                # PowerShell automation
│   └── setup-sharepoint-lists.ps1          # Create SharePoint lists
│
├── 📱 POWER APPS (Both versions)
├── power-apps/                             # Power Apps specifications
│   ├── app-structure.md                    # App screens and navigation
│   └── formulas-reference.md               # SharePoint version formulas
│
├── ⚡ POWER AUTOMATE (Both versions)
├── power-automate/                         # Flow designs
│   └── ooo-approval-flow-design.md         # Approval workflow specs
│
└── 📚 DOCUMENTATION (Both versions)
    └── docs/                               # User guides and documentation
        ├── deployment-guide.md             # SharePoint deployment (detailed)
        ├── user-guide-staff.md             # End-user documentation
        └── user-guide-manager.md           # Manager documentation
```

## Quick Start

### 🚀 Dataverse Solution (Recommended - 30-60 minutes)

**Prerequisites:**
- Microsoft Teams license (Dataverse for Teams included!)
- Team ownership or membership
- NO premium licenses required

**Deployment Steps:**
1. Open Power Apps in Microsoft Teams
2. Import `OOOOOCalendar_1_0_0_0.zip` solution
3. Configure security roles (5 min)
4. Populate user profiles (15 min)
5. Enable Power Automate flows (5 min)
6. Add app to Teams channel (5 min)

**👉 Follow**: [Dataverse Deployment Guide](dataverse-model/dataverse-deployment-guide.md)

---

### 🔧 SharePoint Solution (Custom Build - 2-4 weeks)

**Prerequisites:**
- Microsoft 365 tenant (SharePoint Online, Teams, Power Apps, Power Automate)
- Admin access to create SharePoint lists
- Power Apps and Power Automate knowledge

**Deployment Phases:**

**Phase 1**: Run PowerShell script to create SharePoint lists
**Phase 2**: Build Power App following specifications
**Phase 3**: Create Power Automate approval flows
**Phase 4**: Add to Teams and test

**👉 Follow**: [SharePoint Deployment Guide](docs/deployment-guide.md)

## Key Features

### Staff Capabilities
- 📅 Daily status updates (onsite/offsite)
- 🏖️ Time-off request submission
- 📊 Personal calendar view
- 👀 Team availability overview
- 📝 Request history tracking

### Manager Capabilities
- ✅ Approve/reject time-off requests
- 📆 Complete team calendar view
- 📈 Team availability reports
- 🔍 Approval history access
- ⚙️ Schedule override capabilities

### Automation Features
- 🔔 Teams approval notifications
- 📧 Email notifications
- 📅 Outlook calendar synchronization
- ⏰ Daily reminder flows (optional)
- 📊 Automated reporting

## Technical Stack

### Dataverse Version (Recommended)
- **Frontend**: Power Apps (Canvas App)
- **Data Storage**: Microsoft Dataverse for Teams
- **Workflow Engine**: Power Automate (Cloud Flows)
- **Approval Framework**: Microsoft Teams Approvals
- **Calendar Integration**: Microsoft Outlook/Exchange
- **Authentication**: Azure AD (SSO)
- **Mobile Support**: Teams Mobile App
- **Packaging**: Dataverse Solution (.zip)

### SharePoint Version
- **Frontend**: Power Apps (Canvas App)
- **Data Storage**: SharePoint Online Lists
- **Workflow Engine**: Power Automate (Cloud Flows)
- **Approval Framework**: Microsoft Teams Approvals
- **Calendar Integration**: Microsoft Outlook/Exchange
- **Authentication**: Azure AD (SSO)
- **Mobile Support**: Teams Mobile App

## Security & Compliance

- ✅ Role-based access control (RBAC)
- ✅ Azure AD authentication
- ✅ Audit logging for all approvals
- ✅ GDPR compliance
- ✅ Data retention policies
- ✅ Secure approval workflow

## Support Team

- **Target Users**: 11+ staff members
- **Organization**: Government/Public Sector (Minnesota IT Services)
- **Primary Manager**: Centralized approval authority

## Documentation

### Dataverse Solution
- **[Dataverse Architecture](dataverse-model/dataverse-architecture.md)** - System design
- **[Dataverse Deployment Guide](dataverse-model/dataverse-deployment-guide.md)** - 30-60 minute setup (⭐ START HERE)
- **[Dataverse Formulas](dataverse-model/power-apps-formulas-dataverse.md)** - Power Apps formulas

### SharePoint Solution
- **[SharePoint Deployment Guide](docs/deployment-guide.md)** - Detailed 6-phase deployment
- **[SharePoint Formulas](power-apps/formulas-reference.md)** - Power Apps formulas

### User Documentation (Both Versions)
- **[User Guide - Staff](docs/user-guide-staff.md)** - End-user documentation
- **[User Guide - Manager](docs/user-guide-manager.md)** - Manager documentation

### Technical Documentation (Both Versions)
- **[Power Apps Structure](power-apps/app-structure.md)** - App screens and navigation
- **[Power Automate Flows](power-automate/ooo-approval-flow-design.md)** - Workflow specifications

## Getting Started

### 👉 New Deployment?
**Start here**: [Dataverse Deployment Guide](dataverse-model/dataverse-deployment-guide.md) (30-60 minutes)

### 👉 Want Full Customization?
**Start here**: [SharePoint Deployment Guide](docs/deployment-guide.md) (2-4 weeks, detailed specs)

## Success Metrics

- ⚡ Staff can submit schedule updates in <1 minute
- 🚀 Approval requests delivered within 5 minutes
- ✅ 95% successful workflow completion rate
- 💨 Calendar loads in <3 seconds
- 🎯 Zero data loss or corruption
- 😊 Positive user feedback
- 📉 Reduced email communication about schedules

## License

This project is intended for use within Minnesota IT Services organization.

## Contributing

For questions or issues, please contact your IT administrator or project maintainer.

---

**Last Updated**: November 2025
**Version**: 2.0.0 (Dataverse + SharePoint)
**Status**: Production Ready - Two Deployment Options Available

**Architecture**:
- v2.0: Dataverse solution (packaged, Boards-style) ⭐ Recommended
- v1.0: SharePoint solution (customizable, detailed specs)
