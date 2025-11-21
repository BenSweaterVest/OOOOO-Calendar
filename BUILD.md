# Building the OOOOO Calendar Solution Package

> **📖 Updated Guide Available**
>
> This build guide has been integrated into the comprehensive [Installation & Build Guide](INSTALLATION.md).
>
> Please refer to **[INSTALLATION.md - Method 2: Build from Source](INSTALLATION.md#method-2-build-from-source)** for the latest build instructions, which now includes:
> - Build from source steps
> - Import pre-built solutions
> - Manual table creation for restricted environments
> - All in one comprehensive guide
>
> This file is kept for reference only.

---

This guide explains how to build the `OOOOOCalendar_1_0_0_0.zip` solution package from source files using the **Power Platform CLI**.

---

## Prerequisites

### 1. Power Platform CLI (PAC CLI)

You need the Power Platform CLI installed on your system. Choose one of these methods:

#### Option A: Install via .NET SDK (Recommended)

```powershell
# Install .NET SDK first from https://dotnet.microsoft.com/download

# Then install PAC CLI globally
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac --version
```

#### Option B: Standalone Installer

Download and install from: https://aka.ms/PowerAppsCLI

### 2. Windows PowerShell

The build scripts require Windows PowerShell 5.1 or later.

---

## Quick Start - Build the Package

### Method 1: Using the Build Script (Easiest)

```powershell
# Navigate to repository root
cd /path/to/OOOOO-Calendar

# Unblock the script file (required on Windows)
Unblock-File -Path .\scripts\pack-solution.ps1

# Run the pack script
.\scripts\pack-solution.ps1
```

**Important**: The `Unblock-File` command is required on Windows systems to allow execution of downloaded PowerShell scripts. This is a Windows security feature that prevents untrusted scripts from running automatically.

The script will:
- ✅ Verify PAC CLI is installed
- ✅ Check all required solution files exist
- ✅ Pack the solution into `OOOOOCalendar_1_0_0_0.zip`
- ✅ Display file size and next steps

### Method 2: Manual PAC CLI Command

```powershell
# From repository root
pac solution pack `
    --zipfile OOOOOCalendar_1_0_0_0.zip `
    --folder ./solution `
    --packagetype Unmanaged `
    --errorlevel Verbose
```

---

## Solution Structure

The `solution/` folder contains all the source files that get packed:

```
solution/
├── Other/
│   ├── Solution.xml            # Solution metadata (name, version, publisher)
│   └── Customizations.xml      # Customizations manifest
│
└── Entities/                   # Dataverse tables
    ├── ooooo_staffschedule/
    │   └── Entity.xml          # Staff Schedule table definition
    ├── ooooo_approvalhistory/
    │   └── Entity.xml          # Approval History table definition
    ├── ooooo_userprofile/
    │   └── Entity.xml          # User Profile table definition
    └── ooooo_systemsetting/
        └── Entity.xml          # System Setting table definition
```

**Note**: The XML files contain minimal table metadata. Full table definitions (columns, relationships, etc.) are specified in `Reference/dataverse-tables-schema.json` and should be created in the Power Apps maker portal before exporting a complete solution.

---

## Understanding the Build Process

### What the Build Creates

The `pack-solution.ps1` script creates:
- **File**: `OOOOOCalendar_1_0_0_0.zip`
- **Type**: Dataverse Unmanaged Solution
- **Size**: ~10-50 KB (minimal structure)
- **Format**: ZIP (can be renamed to .cab)

### What's Included

The current solution package includes:
- ✅ Solution metadata (name, version, publisher)
- ✅ 4 Dataverse table definitions
- ✅ Table metadata (names, descriptions)
- ⚠️ **Note**: Full table schemas must be built in Power Apps maker portal

### What's NOT Included (Yet)

These components must be created in Power Apps and exported:
- ❌ Canvas app with screens and formulas
- ❌ Power Automate flows (3 workflows)
- ❌ Security roles and permissions
- ❌ Full table columns and relationships
- ❌ Views, forms, and business rules

---

## Creating a Complete Solution Package

To create a **fully functional** solution package, follow these steps:

### Phase 1: Build Initial Structure (This Repo)

```powershell
# Create minimal solution package
.\scripts\pack-solution.ps1
```

### Phase 2: Import and Build in Power Apps

1. **Import the base solution** into Power Apps for Teams
2. **Create the 4 tables** using `Reference/dataverse-tables-schema.json`
3. **Build the canvas app** following `Reference/power-apps/app-structure.md`
4. **Create Power Automate flows** using `Reference/power-automate/ooo-approval-flow-design.md`
5. **Configure security roles** as specified in the schema

### Phase 3: Export Complete Solution

1. In Power Apps, select **Solutions**
2. Select **OOOOO Calendar** solution
3. Click **Export**
4. Choose **Unmanaged** package type
5. Download as `OOOOOCalendar_1_0_0_0.zip`

### Phase 4: Unpack for Version Control (Optional)

```powershell
# Unpack the exported solution
.\scripts\unpack-solution.ps1

# Commit to version control
git add solution/
git commit -m "Add complete solution with app and flows"
```

---

## Build Script Reference

### pack-solution.ps1

**Purpose**: Packs the solution source files into a distributable ZIP package

**Usage**:
```powershell
.\scripts\pack-solution.ps1
```

**Options**: None (configured for OOOOO Calendar)

**Output**: `OOOOOCalendar_1_0_0_0.zip` in repository root

**Exit Codes**:
- `0` - Success
- `1` - Error (PAC CLI not found, missing files, pack failed)

---

### unpack-solution.ps1

**Purpose**: Unpacks a solution ZIP/CAB into source files for editing

**Usage**:
```powershell
.\scripts\unpack-solution.ps1
```

**Options**: None (configured for OOOOO Calendar)

**Input**: Looks for `OOOOOCalendar_1_0_0_0.zip` or `OOOOOCalendar_1_0_0_0.cab`

**Output**: Extracts to `solution/` folder

**Exit Codes**:
- `0` - Success
- `1` - Error (PAC CLI not found, package not found, unpack failed)

---

## Troubleshooting

### Error: "File cannot be loaded because running scripts is disabled"

**Cause**: Windows security blocks downloaded PowerShell scripts

**Solution**: Unblock the script file

```powershell
# Unblock the specific script
Unblock-File -Path .\scripts\pack-solution.ps1

# Or unblock all scripts in the folder
Get-ChildItem -Path .\scripts\*.ps1 | Unblock-File
```

**Alternative**: Change PowerShell execution policy (admin required)

```powershell
# Allow local scripts (requires admin)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### Error: "PAC CLI not found"

**Solution**: Install Power Platform CLI

```powershell
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

Or download from: https://aka.ms/PowerAppsCLI

---

### Error: "Missing required solution files"

**Solution**: Ensure you're in the repository root and all files exist

```powershell
# Check if files exist
dir solution\Other\Solution.xml
dir solution\Entities\ooooo_staffschedule\Entity.xml
```

---

### Error: "XML parsing error"

**Solution**: Validate XML files are well-formed

```powershell
# Check specific XML file
Get-Content solution\Other\Solution.xml | Select-String "<" | Select-Object -First 5
```

---

### Package builds but is very small (~10 KB)

**This is expected!** The current solution contains only table metadata. To create a full solution:

1. Import this package into Power Apps
2. Build the tables, app, and flows
3. Export from Power Apps
4. The exported package will be 5-10 MB

---

## Development Workflow

### Recommended Git Workflow

```powershell
# 0. First-time setup: Unblock scripts (Windows only)
Unblock-File -Path .\scripts\pack-solution.ps1
Unblock-File -Path .\scripts\unpack-solution.ps1

# 1. Build base package
.\scripts\pack-solution.ps1

# 2. Import into Power Apps and build components

# 3. Export complete solution from Power Apps

# 4. Unpack for version control
.\scripts\unpack-solution.ps1

# 5. Commit changes
git add solution/
git commit -m "Update solution with new features"

# 6. Rebuild package
.\scripts\pack-solution.ps1
```

---

## Additional Resources

### Power Platform CLI Documentation

- **Official Docs**: https://learn.microsoft.com/power-platform/developer/cli/introduction
- **Solution Commands**: https://learn.microsoft.com/power-platform/developer/cli/reference/solution
- **Download PAC CLI**: https://aka.ms/PowerAppsCLI

### Dataverse Solution Packaging

- **Solution Concepts**: https://learn.microsoft.com/power-apps/maker/data-platform/solutions-overview
- **Export Solutions**: https://learn.microsoft.com/power-apps/maker/data-platform/export-solutions
- **Import Solutions**: https://learn.microsoft.com/power-apps/maker/data-platform/import-update-export-solutions

---

## FAQ

**Q: Can I build this on Mac or Linux?**

A: The PowerShell scripts are Windows-only, but you can use the manual PAC CLI commands on any platform. PAC CLI is cross-platform.

**Q: Do I need a Dataverse environment to build the package?**

A: No! You can build the package from source files without any environment. However, to create a **complete** solution with apps and flows, you'll need to import into Power Apps.

**Q: What's the difference between .zip and .cab formats?**

A: Both work identically for Dataverse solutions. You can rename the file extension between .zip and .cab - they're the same archive format.

**Q: Can I edit the solution in Power Apps and maintain version control?**

A: Yes! This is the recommended workflow:
1. Edit in Power Apps maker portal
2. Export the solution
3. Run `unpack-solution.ps1`
4. Commit to Git
5. Run `pack-solution.ps1` to rebuild

---

**Ready to build?** Run `.\scripts\pack-solution.ps1` to create your first package!
