# OOOOO Calendar - Teams Staff Scheduling & Approval System

A Microsoft Teams Power App solution for managing staff work location schedules and time-off requests with integrated approval workflows.

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
├── README.md                          # This file
├── docs/                              # Detailed documentation
│   ├── architecture.md                # System architecture overview
│   ├── business-requirements.md       # Detailed business requirements
│   ├── deployment-guide.md            # Step-by-step deployment instructions
│   ├── user-guide-staff.md           # End-user documentation (staff)
│   ├── user-guide-manager.md         # End-user documentation (managers)
│   └── technical-specifications.md    # Technical implementation details
├── data-model/                        # Data structure definitions
│   ├── sharepoint-lists-schema.json   # SharePoint list definitions
│   ├── staff-schedule-list.md         # Staff Schedule list specification
│   ├── approval-history-list.md       # Approval History list specification
│   └── user-profiles-list.md          # User Profiles list specification
├── scripts/                           # Automation scripts
│   ├── setup-sharepoint-lists.ps1     # PowerShell script to create SharePoint lists
│   ├── configure-permissions.ps1      # Script to set up permissions
│   └── test-data-generator.ps1        # Generate sample test data
├── power-automate/                    # Power Automate flow definitions
│   ├── ooo-approval-flow.json         # Main OOO approval workflow
│   ├── calendar-sync-flow.json        # Outlook calendar synchronization
│   ├── notification-flow.json         # Teams notifications
│   └── flow-documentation.md          # Flow setup instructions
├── power-apps/                        # Power Apps specifications
│   ├── app-structure.md               # App screens and navigation
│   ├── formulas-reference.md          # Key formulas and expressions
│   ├── color-theme.json               # App color scheme and branding
│   ├── calendar-component.md          # Calendar visualization specs
│   └── screens/                       # Screen-by-screen specifications
│       ├── home-dashboard.md
│       ├── my-schedule.md
│       ├── team-calendar.md
│       ├── request-form.md
│       └── manager-approvals.md
└── deployment/                        # Deployment resources
    ├── checklist.md                   # Pre-deployment checklist
    ├── configuration-settings.md      # Required configuration
    └── troubleshooting.md             # Common issues and solutions
```

## Quick Start

### Prerequisites

- Microsoft 365 tenant with:
  - Microsoft Teams
  - SharePoint Online
  - Power Apps license
  - Power Automate license
- Admin access to create SharePoint lists and Power Apps
- Teams app deployment permissions

### Deployment Phases

#### Phase 1: Foundation (Data Setup)
1. Run PowerShell script to create SharePoint lists
2. Configure permissions and security
3. Test data structure

#### Phase 2: Core Features
1. Create Power App canvas app
2. Build basic forms and calendar interface
3. Implement Power Automate approval workflow
4. Connect app to SharePoint data

#### Phase 3: Manager Features
1. Build manager approval interface
2. Create team calendar view
3. Implement reporting capabilities

#### Phase 4: Polish & Integration
1. Outlook calendar integration
2. Teams notifications
3. Mobile optimization
4. User training and documentation

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

Detailed documentation is available in the `/docs` directory:

- **[Architecture Overview](docs/architecture.md)** - System design and components
- **[Deployment Guide](docs/deployment-guide.md)** - Step-by-step setup instructions
- **[User Guide - Staff](docs/user-guide-staff.md)** - End-user documentation
- **[User Guide - Manager](docs/user-guide-manager.md)** - Manager documentation
- **[Technical Specifications](docs/technical-specifications.md)** - Implementation details

## Getting Started

👉 **Begin with the [Deployment Guide](docs/deployment-guide.md)** for step-by-step implementation instructions.

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
**Version**: 1.0.0
**Status**: Initial Development
