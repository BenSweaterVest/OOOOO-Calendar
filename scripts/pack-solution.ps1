# OOOOO Calendar Solution - Pack Script (Windows)
# This script packs the Power Platform solution into a distributable CAB/ZIP file

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "OOOOO Calendar Solution Pack" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if PAC CLI is installed
Write-Host "Checking for Power Platform CLI..." -ForegroundColor Yellow
if (!(Get-Command "pac" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Power Platform CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install PAC CLI:" -ForegroundColor Yellow
    Write-Host "  1. Install .NET SDK: https://dotnet.microsoft.com/download" -ForegroundColor White
    Write-Host "  2. Run: dotnet tool install --global Microsoft.PowerApps.CLI.Tool" -ForegroundColor White
    Write-Host ""
    Write-Host "Or download standalone installer:" -ForegroundColor Yellow
    Write-Host "  https://aka.ms/PowerAppsCLI" -ForegroundColor White
    Write-Host ""
    exit 1
}

$pacVersion = pac --version 2>&1
Write-Host "Found PAC CLI: $pacVersion" -ForegroundColor Green
Write-Host ""

# Navigate to project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
Set-Location $projectRoot

Write-Host "Project root: $projectRoot" -ForegroundColor White
Write-Host ""

# Verify solution folder exists
if (!(Test-Path "solution")) {
    Write-Host "ERROR: 'solution' folder not found!" -ForegroundColor Red
    Write-Host "Expected path: $projectRoot\solution" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please ensure the solution source files exist in the 'solution' folder." -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Verifying solution structure..." -ForegroundColor Yellow
$requiredFiles = @(
    "solution\Other\Solution.xml",
    "solution\Other\Customizations.xml",
    "solution\Entities\ooooo_staffschedule\Entity.xml",
    "solution\Entities\ooooo_approvalhistory\Entity.xml",
    "solution\Entities\ooooo_userprofile\Entity.xml",
    "solution\Entities\ooooo_systemsetting\Entity.xml"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (!(Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "ERROR: Missing required solution files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
    Write-Host ""
    exit 1
}

Write-Host "All required files found!" -ForegroundColor Green
Write-Host ""

# Pack the solution
Write-Host "Packing solution..." -ForegroundColor Yellow
Write-Host ""

$outputFile = "OOOOOCalendar_1_0_0_0.zip"
$outputPath = Join-Path $projectRoot $outputFile

# Remove existing package if present
if (Test-Path $outputPath) {
    Write-Host "Removing existing package..." -ForegroundColor Yellow
    Remove-Item $outputPath -Force
}

# Execute pack command
Write-Host "Running: pac solution pack --zipfile $outputFile --folder ./solution --packagetype Unmanaged" -ForegroundColor Gray
Write-Host ""

pac solution pack `
    --zipfile $outputFile `
    --folder "./solution" `
    --packagetype Unmanaged `
    --errorlevel Verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "SUCCESS: Solution packed!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output file: $outputFile" -ForegroundColor White
    Write-Host "Location: $projectRoot" -ForegroundColor White
    Write-Host ""

    if (Test-Path $outputPath) {
        $fileInfo = Get-Item $outputPath
        Write-Host "File size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor White
        Write-Host ""
    }

    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Review the package" -ForegroundColor White
    Write-Host "  2. Import into Power Apps following INSTALLATION.md" -ForegroundColor White
    Write-Host "  3. Configure security roles and user profiles" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: The .zip file can also be renamed to .cab if needed" -ForegroundColor Cyan
    Write-Host "      Both formats work with Dataverse solution imports" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Red
    Write-Host "ERROR: Solution pack failed!" -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please review the error messages above and:" -ForegroundColor Yellow
    Write-Host "  - Check all XML files are well-formed" -ForegroundColor White
    Write-Host "  - Verify solution structure matches requirements" -ForegroundColor White
    Write-Host "  - Ensure all required files exist" -ForegroundColor White
    Write-Host "  - Review Reference/dataverse-tables-schema.json for specifications" -ForegroundColor White
    Write-Host ""
    Write-Host "For help:" -ForegroundColor Yellow
    Write-Host "  - Run: pac solution check --path ./solution" -ForegroundColor White
    Write-Host "  - See: https://learn.microsoft.com/power-platform/developer/cli/introduction" -ForegroundColor White
    Write-Host ""
    exit 1
}
