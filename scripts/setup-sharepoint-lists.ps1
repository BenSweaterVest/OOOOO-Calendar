<![CDATA[<#
.SYNOPSIS
    Creates SharePoint lists for the OOOOO Calendar system.

.DESCRIPTION
    This script creates all required SharePoint lists, columns, and views
    for the Teams Staff Scheduling & Approval System.

.PARAMETER SiteUrl
    The URL of the SharePoint site where lists will be created.
    Example: https://yourtenant.sharepoint.com/sites/OOOOOCalendar

.PARAMETER Credential
    Optional credentials for authentication. If not provided, will use
    current user context or prompt for credentials.

.EXAMPLE
    .\setup-sharepoint-lists.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/OOOOOCalendar"

.NOTES
    Requirements:
    - PnP.PowerShell module (Install-Module -Name PnP.PowerShell)
    - Site Owner or Site Collection Administrator permissions
    - PowerShell 5.1 or PowerShell 7+

    Author: OOOOO Calendar Project Team
    Version: 1.0.0
    Last Updated: November 2025
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credential
)

# Error handling
$ErrorActionPreference = "Stop"

# Check for PnP.PowerShell module
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Error "PnP.PowerShell module not found. Install it using: Install-Module -Name PnP.PowerShell -Scope CurrentUser"
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OOOOO Calendar - SharePoint List Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Connect to SharePoint
Write-Host "Connecting to SharePoint site: $SiteUrl" -ForegroundColor Yellow
try {
    if ($Credential) {
        Connect-PnPOnline -Url $SiteUrl -Credentials $Credential
    } else {
        Connect-PnPOnline -Url $SiteUrl -Interactive
    }
    Write-Host "✓ Connected successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to connect to SharePoint: $_"
    exit 1
}

Write-Host ""

# Function to create list if it doesn't exist
function New-OOOOOList {
    param(
        [string]$ListName,
        [string]$Description,
        [string]$Template = "GenericList"
    )

    Write-Host "Creating list: $ListName" -ForegroundColor Yellow

    try {
        $existingList = Get-PnPList -Identity $ListName -ErrorAction SilentlyContinue

        if ($existingList) {
            Write-Host "  ⚠ List '$ListName' already exists. Skipping creation." -ForegroundColor Yellow
            return $existingList
        }

        $list = New-PnPList -Title $ListName -Template $Template -EnableVersioning
        Set-PnPList -Identity $ListName -Description $Description

        Write-Host "  ✓ List '$ListName' created successfully" -ForegroundColor Green
        return $list

    } catch {
        Write-Error "Failed to create list '$ListName': $_"
        throw
    }
}

# Function to add field if it doesn't exist
function Add-OOOOOField {
    param(
        [string]$ListName,
        [string]$FieldName,
        [string]$DisplayName,
        [string]$FieldType,
        [hashtable]$AdditionalProperties = @{}
    )

    try {
        $existingField = Get-PnPField -List $ListName -Identity $FieldName -ErrorAction SilentlyContinue

        if ($existingField) {
            Write-Host "    - Field '$DisplayName' already exists" -ForegroundColor Gray
            return
        }

        $fieldXml = Build-FieldXml -FieldName $FieldName -DisplayName $DisplayName -FieldType $FieldType -Properties $AdditionalProperties
        Add-PnPFieldFromXml -List $ListName -FieldXml $fieldXml

        Write-Host "    ✓ Added field: $DisplayName" -ForegroundColor Green

    } catch {
        Write-Warning "Failed to add field '$DisplayName' to '$ListName': $_"
    }
}

# Function to build field XML
function Build-FieldXml {
    param(
        [string]$FieldName,
        [string]$DisplayName,
        [string]$FieldType,
        [hashtable]$Properties
    )

    $xml = "<Field Type='$FieldType' Name='$FieldName' DisplayName='$DisplayName'"

    foreach ($key in $Properties.Keys) {
        $value = $Properties[$key]
        if ($value -is [bool]) {
            $value = if ($value) { "TRUE" } else { "FALSE" }
        }
        $xml += " $key='$value'"
    }

    # Handle Choice fields
    if ($FieldType -eq "Choice" -and $Properties.ContainsKey("Choices")) {
        $xml += ">"
        $xml += "<CHOICES>"
        foreach ($choice in $Properties["Choices"]) {
            $xml += "<CHOICE>$choice</CHOICE>"
        }
        $xml += "</CHOICES>"
        $xml += "</Field>"
    } else {
        $xml += " />"
    }

    return $xml
}

#region Create Lists

Write-Host ""
Write-Host "Step 1: Creating SharePoint Lists" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# 1. StaffSchedule List
New-OOOOOList -ListName "StaffSchedule" -Description "Main schedule and time-off request data"

# 2. ApprovalHistory List
New-OOOOOList -ListName "ApprovalHistory" -Description "Complete audit trail of all approval actions"

# 3. UserProfiles List
New-OOOOOList -ListName "UserProfiles" -Description "Extended user profile information and manager relationships"

# 4. SystemSettings List
New-OOOOOList -ListName "SystemSettings" -Description "Application configuration and settings"

#endregion

#region Configure StaffSchedule Columns

Write-Host ""
Write-Host "Step 2: Configuring StaffSchedule Columns" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Update Title field
Set-PnPField -List "StaffSchedule" -Identity "Title" -Values @{Title="Request ID"}

# Employee fields
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="User" Name="EmployeeName" DisplayName="Employee Name" Required="TRUE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="Text" Name="EmployeeEmail" DisplayName="Employee Email" Required="TRUE" />'

# Date fields
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="DateTime" Name="ScheduleDate" DisplayName="Date" Format="DateOnly" Required="TRUE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="DateTime" Name="StartDate" DisplayName="Start Date" Format="DateOnly" Required="FALSE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="DateTime" Name="EndDate" DisplayName="End Date" Format="DateOnly" Required="FALSE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="DateTime" Name="SubmissionDateTime" DisplayName="Submission Date/Time" Format="DateTime" Required="TRUE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="DateTime" Name="ApprovalDateTime" DisplayName="Approval Date/Time" Format="DateTime" Required="FALSE" />'

# Choice fields
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml @"
<Field Type="Choice" Name="Status" DisplayName="Status" Required="TRUE">
    <CHOICES>
        <CHOICE>Onsite</CHOICE>
        <CHOICE>Offsite</CHOICE>
        <CHOICE>OOO-Pending</CHOICE>
        <CHOICE>OOO-Approved</CHOICE>
        <CHOICE>OOO-Rejected</CHOICE>
    </CHOICES>
    <Default>Onsite</Default>
</Field>
"@

Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml @"
<Field Type="Choice" Name="RequestType" DisplayName="Request Type" Required="TRUE">
    <CHOICES>
        <CHOICE>Regular Schedule</CHOICE>
        <CHOICE>Vacation</CHOICE>
        <CHOICE>Sick Leave</CHOICE>
        <CHOICE>Personal Day</CHOICE>
        <CHOICE>Other</CHOICE>
    </CHOICES>
    <Default>Regular Schedule</Default>
</Field>
"@

# Text and Note fields
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="Note" Name="Comments" DisplayName="Comments/Notes" Required="FALSE" RichText="FALSE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="Note" Name="ManagerComments" DisplayName="Manager Comments" Required="FALSE" RichText="FALSE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="Text" Name="ApprovalRequestId" DisplayName="Approval Request ID" Required="FALSE" />'
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="Text" Name="CalendarEventId" DisplayName="Calendar Event ID" Required="FALSE" />'

# Manager field
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="User" Name="ApprovedBy" DisplayName="Approved By" Required="FALSE" />'

# Boolean field
Add-PnPFieldFromXml -List "StaffSchedule" -FieldXml '<Field Type="Boolean" Name="IsActive" DisplayName="Is Active" Required="TRUE"><Default>1</Default></Field>'

Write-Host "  ✓ StaffSchedule columns configured" -ForegroundColor Green

#endregion

#region Configure ApprovalHistory Columns

Write-Host ""
Write-Host "Step 3: Configuring ApprovalHistory Columns" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Update Title field
Set-PnPField -List "ApprovalHistory" -Identity "Title" -Values @{Title="History ID"}

# Lookup to StaffSchedule
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="Lookup" Name="RequestID" DisplayName="Request ID" Required="TRUE" List="StaffSchedule" ShowField="Title" />'

# User fields
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="User" Name="EmployeeName" DisplayName="Employee Name" Required="TRUE" />'
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="User" Name="ActorName" DisplayName="Actor Name" Required="TRUE" />'

# Date fields
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="DateTime" Name="RequestStartDate" DisplayName="Request Start Date" Format="DateOnly" Required="TRUE" />'
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="DateTime" Name="RequestEndDate" DisplayName="Request End Date" Format="DateOnly" Required="FALSE" />'
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="DateTime" Name="ActionDateTime" DisplayName="Action Date/Time" Format="DateTime" Required="TRUE" />'

# Choice fields
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml @"
<Field Type="Choice" Name="RequestType" DisplayName="Request Type" Required="TRUE">
    <CHOICES>
        <CHOICE>Vacation</CHOICE>
        <CHOICE>Sick Leave</CHOICE>
        <CHOICE>Personal Day</CHOICE>
        <CHOICE>Other</CHOICE>
    </CHOICES>
</Field>
"@

Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml @"
<Field Type="Choice" Name="Action" DisplayName="Action" Required="TRUE">
    <CHOICES>
        <CHOICE>Submitted</CHOICE>
        <CHOICE>Approved</CHOICE>
        <CHOICE>Rejected</CHOICE>
        <CHOICE>Cancelled</CHOICE>
        <CHOICE>Modified</CHOICE>
    </CHOICES>
</Field>
"@

# Note and Number fields
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="Note" Name="ActorComments" DisplayName="Comments" Required="FALSE" RichText="FALSE" />'
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="Note" Name="OriginalRequestDetails" DisplayName="Original Request Details" Required="FALSE" RichText="FALSE" />'
Add-PnPFieldFromXml -List "ApprovalHistory" -FieldXml '<Field Type="Number" Name="ApprovalDuration" DisplayName="Approval Duration (hours)" Decimals="2" Required="FALSE" />'

Write-Host "  ✓ ApprovalHistory columns configured" -ForegroundColor Green

#endregion

#region Configure UserProfiles Columns

Write-Host ""
Write-Host "Step 4: Configuring UserProfiles Columns" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Update Title field
Set-PnPField -List "UserProfiles" -Identity "Title" -Values @{Title="User Email"}

# User fields
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="User" Name="UserAccount" DisplayName="User Account" Required="TRUE" />'
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="User" Name="Manager" DisplayName="Manager" Required="TRUE" />'

# Text fields
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="Text" Name="DisplayName" DisplayName="Display Name" Required="TRUE" />'
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="Text" Name="ManagerEmail" DisplayName="Manager Email" Required="TRUE" />'
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="Text" Name="Department" DisplayName="Department" Required="FALSE" />'

# Boolean fields
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="Boolean" Name="IsManager" DisplayName="Is Manager" Required="TRUE"><Default>0</Default></Field>'
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml '<Field Type="Boolean" Name="IsActive" DisplayName="Is Active" Required="TRUE"><Default>1</Default></Field>'

# Choice fields
Add-PnPFieldFromXml -List "UserProfiles" -FieldXml @"
<Field Type="Choice" Name="NotificationPreferences" DisplayName="Notification Preferences" Required="TRUE">
    <CHOICES>
        <CHOICE>Teams Only</CHOICE>
        <CHOICE>Email Only</CHOICE>
        <CHOICE>Both</CHOICE>
        <CHOICE>None</CHOICE>
    </CHOICES>
    <Default>Both</Default>
</Field>
"@

Add-PnPFieldFromXml -List "UserProfiles" -FieldXml @"
<Field Type="Choice" Name="TimeZone" DisplayName="Time Zone" Required="FALSE">
    <CHOICES>
        <CHOICE>Eastern</CHOICE>
        <CHOICE>Central</CHOICE>
        <CHOICE>Mountain</CHOICE>
        <CHOICE>Pacific</CHOICE>
    </CHOICES>
    <Default>Central</Default>
</Field>
"@

Write-Host "  ✓ UserProfiles columns configured" -ForegroundColor Green

#endregion

#region Configure SystemSettings Columns

Write-Host ""
Write-Host "Step 5: Configuring SystemSettings Columns" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Update Title field
Set-PnPField -List "SystemSettings" -Identity "Title" -Values @{Title="Setting Name"}

# Text and Note fields
Add-PnPFieldFromXml -List "SystemSettings" -FieldXml '<Field Type="Text" Name="SettingValue" DisplayName="Setting Value" Required="TRUE" />'
Add-PnPFieldFromXml -List "SystemSettings" -FieldXml '<Field Type="Note" Name="Description" DisplayName="Description" Required="FALSE" RichText="FALSE" />'

# Choice fields
Add-PnPFieldFromXml -List "SystemSettings" -FieldXml @"
<Field Type="Choice" Name="SettingType" DisplayName="Setting Type" Required="TRUE">
    <CHOICES>
        <CHOICE>Text</CHOICE>
        <CHOICE>Number</CHOICE>
        <CHOICE>Boolean</CHOICE>
        <CHOICE>JSON</CHOICE>
    </CHOICES>
</Field>
"@

Add-PnPFieldFromXml -List "SystemSettings" -FieldXml @"
<Field Type="Choice" Name="Category" DisplayName="Category" Required="TRUE">
    <CHOICES>
        <CHOICE>General</CHOICE>
        <CHOICE>Approval</CHOICE>
        <CHOICE>Notification</CHOICE>
        <CHOICE>Calendar</CHOICE>
        <CHOICE>Security</CHOICE>
    </CHOICES>
</Field>
"@

# Boolean field
Add-PnPFieldFromXml -List "SystemSettings" -FieldXml '<Field Type="Boolean" Name="IsEditable" DisplayName="Is Editable" Required="TRUE"><Default>1</Default></Field>'

Write-Host "  ✓ SystemSettings columns configured" -ForegroundColor Green

#endregion

#region Add Default System Settings

Write-Host ""
Write-Host "Step 6: Adding Default System Settings" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

$defaultSettings = @(
    @{Title="MinimumAdvanceNoticeDays"; SettingValue="3"; SettingType="Number"; Description="Minimum days of advance notice required for OOO requests"; Category="Approval"; IsEditable=$true},
    @{Title="MaxOOODaysPerRequest"; SettingValue="30"; SettingType="Number"; Description="Maximum consecutive days allowed in a single OOO request"; Category="Approval"; IsEditable=$true},
    @{Title="EnableDailyReminders"; SettingValue="true"; SettingType="Boolean"; Description="Enable daily morning reminders for status updates"; Category="Notification"; IsEditable=$true},
    @{Title="ReminderTime"; SettingValue="08:00"; SettingType="Text"; Description="Time to send daily reminders (HH:MM format)"; Category="Notification"; IsEditable=$true},
    @{Title="SyncToOutlookCalendar"; SettingValue="true"; SettingType="Boolean"; Description="Automatically sync approved OOO to Outlook calendar"; Category="Calendar"; IsEditable=$true},
    @{Title="WorkingDays"; SettingValue="[1,2,3,4,5]"; SettingType="JSON"; Description="Working days of the week (0=Sunday, 6=Saturday)"; Category="General"; IsEditable=$true},
    @{Title="ColorScheme"; SettingValue='{"Onsite":"#4CAF50","Offsite":"#2196F3","OOO-Pending":"#FFC107","OOO-Approved":"#9C27B0"}'; SettingType="JSON"; Description="Color codes for different status types"; Category="General"; IsEditable=$true}
)

foreach ($setting in $defaultSettings) {
    try {
        # Check if setting already exists
        $existing = Get-PnPListItem -List "SystemSettings" -Query "<View><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>$($setting.Title)</Value></Eq></Where></Query></View>"

        if ($existing) {
            Write-Host "  - Setting '$($setting.Title)' already exists" -ForegroundColor Gray
        } else {
            Add-PnPListItem -List "SystemSettings" -Values $setting | Out-Null
            Write-Host "  ✓ Added setting: $($setting.Title)" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Failed to add setting '$($setting.Title)': $_"
    }
}

#endregion

#region Summary

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Created SharePoint Lists:" -ForegroundColor Yellow
Write-Host "  ✓ StaffSchedule" -ForegroundColor Green
Write-Host "  ✓ ApprovalHistory" -ForegroundColor Green
Write-Host "  ✓ UserProfiles" -ForegroundColor Green
Write-Host "  ✓ SystemSettings" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Populate UserProfiles list with your team members" -ForegroundColor White
Write-Host "  2. Configure list permissions (run configure-permissions.ps1)" -ForegroundColor White
Write-Host "  3. Create Power Automate flows" -ForegroundColor White
Write-Host "  4. Build Power Apps canvas app" -ForegroundColor White
Write-Host ""
Write-Host "SharePoint Site: $SiteUrl" -ForegroundColor Cyan
Write-Host ""

#endregion

# Disconnect
Disconnect-PnPOnline
]]>