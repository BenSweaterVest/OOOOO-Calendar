# OOOOO Calendar Solution - Unpack Script (Windows)
# This script unpacks a Dataverse solution package into source files for version control

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "OOOOO Calendar Solution Unpack" -ForegroundColor Cyan
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

# Find solution package
$packageFile = "OOOOOCalendar_1_0_0_0.zip"
if (!(Test-Path $packageFile)) {
    $packageFile = "OOOOOCalendar_1_0_0_0.cab"
    if (!(Test-Path $packageFile)) {
        Write-Host "ERROR: Solution package not found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Expected one of:" -ForegroundColor Yellow
        Write-Host "  - OOOOOCalendar_1_0_0_0.zip" -ForegroundColor White
        Write-Host "  - OOOOOCalendar_1_0_0_0.cab" -ForegroundColor White
        Write-Host ""
        Write-Host "Please download or build the solution package first." -ForegroundColor White
        Write-Host ""
        exit 1
    }
}

Write-Host "Found package: $packageFile" -ForegroundColor Green
Write-Host ""

# Check if solution folder already exists
if (Test-Path "solution") {
    Write-Host "WARNING: 'solution' folder already exists!" -ForegroundColor Yellow
    $response = Read-Host "Do you want to overwrite it? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Unpack cancelled." -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }
    Write-Host ""
    Write-Host "Removing existing solution folder..." -ForegroundColor Yellow
    Remove-Item -Path "solution" -Recurse -Force
}

# Unpack the solution
Write-Host "Unpacking solution..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Running: pac solution unpack --zipfile $packageFile --folder ./solution" -ForegroundColor Gray
Write-Host ""

pac solution unpack `
    --zipfile $packageFile `
    --folder "./solution" `
    --packagetype Both `
    --allowDelete True

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "SUCCESS: Solution unpacked!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output folder: solution/" -ForegroundColor White
    Write-Host "Location: $projectRoot\solution" -ForegroundColor White
    Write-Host ""

    # Count files
    $fileCount = (Get-ChildItem -Path "solution" -Recurse -File).Count
    Write-Host "Extracted $fileCount files" -ForegroundColor White
    Write-Host ""

    Write-Host "Solution structure:" -ForegroundColor Yellow
    Write-Host "  solution/" -ForegroundColor White
    Write-Host "  ├── Other/           (Solution metadata)" -ForegroundColor Gray
    Write-Host "  ├── Entities/        (Dataverse tables)" -ForegroundColor Gray
    Write-Host "  ├── CanvasApps/      (Power Apps canvas apps)" -ForegroundColor Gray
    Write-Host "  └── Workflows/       (Power Automate flows)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Modify solution files as needed" -ForegroundColor White
    Write-Host "  2. Run pack-solution.ps1 to repack" -ForegroundColor White
    Write-Host "  3. Commit changes to version control" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Red
    Write-Host "ERROR: Solution unpack failed!" -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please review the error messages above and:" -ForegroundColor Yellow
    Write-Host "  - Verify the package file is not corrupted" -ForegroundColor White
    Write-Host "  - Ensure you have write permissions" -ForegroundColor White
    Write-Host "  - Check disk space" -ForegroundColor White
    Write-Host ""
    Write-Host "For help:" -ForegroundColor Yellow
    Write-Host "  - See: https://learn.microsoft.com/power-platform/developer/cli/introduction" -ForegroundColor White
    Write-Host ""
    exit 1
}
