# OOOOO Calendar - Reference Documentation

This folder contains detailed technical specifications and reference materials for building and maintaining the OOOOO Calendar solution.

---

## 📚 Documentation Index

### Data Model & Architecture

- **[dataverse-tables-schema.json](dataverse-tables-schema.json)** - Complete Dataverse table specifications
  - All 4 tables with column definitions
  - Data types, constraints, and default values
  - Security roles and permissions
  - Relationships and lookups
  - **Use for**: Manual table creation, understanding data model

- **[dataverse-architecture.md](dataverse-architecture.md)** - High-level architecture overview
  - Solution components
  - Data flow diagrams
  - Integration points
  - **Use for**: Understanding system design

---

### Power Apps

- **[power-apps/app-structure.md](power-apps/app-structure.md)** - Canvas app architecture
  - Screen structure
  - Component breakdown
  - Navigation flow
  - **Use for**: Understanding app organization

- **[power-apps-formulas-dataverse.md](power-apps-formulas-dataverse.md)** - Power Fx formulas reference
  - Common formulas used in the app
  - Dataverse query patterns
  - Data manipulation examples
  - **Use for**: Building and troubleshooting canvas app

**For step-by-step app building**: See [`/docs/CANVAS-APP-BUILDING-GUIDE.md`](../docs/CANVAS-APP-BUILDING-GUIDE.md)

---

### Power Automate Flows

All three flows needed for the complete solution:

#### Required Flows

1. **[power-automate/ooo-approval-flow-design.md](power-automate/ooo-approval-flow-design.md)** - OOO Approval Workflow
   - Handles time-off request approvals via Teams
   - Trigger: Status changes to "OOO-Pending"
   - ~480 lines of detailed specifications
   - Flow diagrams, step-by-step actions, error handling
   - **Status**: Required

2. **[power-automate/calendar-sync-flow-design.md](power-automate/calendar-sync-flow-design.md)** - Calendar Sync Flow
   - Syncs approved requests to Outlook calendar
   - Trigger: Status changes to "OOO-Approved"
   - Includes event creation, error handling, optimization tips
   - **Status**: Required

#### Optional Flows

3. **[power-automate/daily-reminder-flow-design.md](power-automate/daily-reminder-flow-design.md)** - Daily Reminder Flow
   - Sends daily reminders to update status
   - Trigger: Recurrence (Daily at 8:00 AM)
   - Includes adaptive cards, scheduling, customization options
   - **Status**: Optional (recommended for engagement)

---

## 🎯 Quick Reference by Task

### I want to... manually create tables

1. Read [`dataverse-tables-schema.json`](dataverse-tables-schema.json) for complete specifications
2. Follow [`INSTALLATION.md` Method 3](../INSTALLATION.md#method-3-manual-table-creation)
3. Reference table schema for column definitions, data types, and defaults

### I want to... build the canvas app

1. Start with [`/docs/CANVAS-APP-BUILDING-GUIDE.md`](../docs/CANVAS-APP-BUILDING-GUIDE.md) (step-by-step)
2. Reference [`power-apps/app-structure.md`](power-apps/app-structure.md) for architecture
3. Use [`power-apps-formulas-dataverse.md`](power-apps-formulas-dataverse.md) for formulas

### I want to... create Power Automate flows

1. **Approval Workflow**: [`power-automate/ooo-approval-flow-design.md`](power-automate/ooo-approval-flow-design.md)
2. **Calendar Sync**: [`power-automate/calendar-sync-flow-design.md`](power-automate/calendar-sync-flow-design.md)
3. **Daily Reminder**: [`power-automate/daily-reminder-flow-design.md`](power-automate/daily-reminder-flow-design.md)

Each doc includes:
- Flow architecture diagrams
- Step-by-step action configurations
- Formulas and expressions
- Error handling
- Testing procedures
- Troubleshooting guides

### I want to... understand the data model

1. Start with [`dataverse-architecture.md`](dataverse-architecture.md)
2. Deep dive into [`dataverse-tables-schema.json`](dataverse-tables-schema.json)
3. See relationships in action in the flow designs

### I want to... customize the solution

1. Review [`dataverse-tables-schema.json`](dataverse-tables-schema.json) to understand what can be modified
2. Check flow designs for extension points
3. See [`power-apps-formulas-dataverse.md`](power-apps-formulas-dataverse.md) for formula patterns

---

## 📊 Documentation Coverage

### Tables & Data
- ✅ Complete table specifications (4 tables, 55 total columns)
- ✅ All column data types, constraints, defaults
- ✅ Security roles and permissions
- ✅ Relationships and lookups
- ✅ Default system settings data

### Canvas App
- ✅ Step-by-step building guide (826 lines)
- ✅ Architecture and structure
- ✅ Power Fx formulas reference
- ✅ Screen designs and navigation

### Power Automate
- ✅ OOO Approval Workflow (484 lines)
- ✅ Calendar Sync Flow (complete specification)
- ✅ Daily Reminder Flow (complete specification)
- ✅ Error handling for all flows
- ✅ Testing procedures

### User Documentation
- ✅ Staff user guide
- ✅ Manager user guide
- ✅ Installation guide (all 3 methods)

---

## 🔗 Related Documentation

**In Parent Directory**:
- [`README.md`](../README.md) - Project overview
- [`INSTALLATION.md`](../INSTALLATION.md) - Complete installation guide (all methods)
- [`BUILD.md`](../BUILD.md) - Building solution packages
- [`SOLUTION-PACKAGE-SPEC.md`](../SOLUTION-PACKAGE-SPEC.md) - Solution package specifications

**In `/docs` Folder**:
- [`CANVAS-APP-BUILDING-GUIDE.md`](../docs/CANVAS-APP-BUILDING-GUIDE.md) - Step-by-step app building
- [`user-guide-staff.md`](../docs/user-guide-staff.md) - For end users
- [`user-guide-manager.md`](../docs/user-guide-manager.md) - For managers

---

## 💡 Tips for Using This Documentation

### For Complete Manual Build
Follow this order:
1. Create tables using schema → [`INSTALLATION.md` Method 3](../INSTALLATION.md#method-3-manual-table-creation)
2. Build canvas app → [`/docs/CANVAS-APP-BUILDING-GUIDE.md`](../docs/CANVAS-APP-BUILDING-GUIDE.md)
3. Create flows → Use all 3 flow design docs above
4. Test and deploy → Follow installation guide post-install steps

### For Understanding the System
Read in this order:
1. [`dataverse-architecture.md`](dataverse-architecture.md) - Big picture
2. [`power-apps/app-structure.md`](power-apps/app-structure.md) - App overview
3. Flow designs - Understand automation
4. Schema JSON - Detailed data model

### For Troubleshooting
- Check relevant flow design doc for troubleshooting sections
- Review [`INSTALLATION.md`](../INSTALLATION.md) common issues
- Verify against schema JSON for correct configurations

---

## 📝 Documentation Standards

All reference documentation follows these standards:
- ✅ Complete specifications (no placeholders)
- ✅ Step-by-step instructions where applicable
- ✅ Code examples and formulas
- ✅ Troubleshooting sections
- ✅ Testing procedures
- ✅ Architecture diagrams
- ✅ Production-ready configurations

---

## 🤝 Contributing

When updating reference documentation:

1. **Keep synchronized**: Update all related docs when making changes
2. **Version properly**: Note changes in version history sections
3. **Test thoroughly**: Verify all steps work as documented
4. **Include examples**: Provide working code samples
5. **Document errors**: Add common issues to troubleshooting sections

---

## 📄 License & Ownership

- **Project**: OOOOO Calendar
- **Organization**: Minnesota IT Services
- **License**: See project README
- **Maintainer**: OOOOO Calendar Team

---

**Last Updated**: November 2025
**Documentation Version**: 1.0.0
