# check-env.ps1 - Environment Verification for Jacky
# Read-only inspection script. Installs nothing.

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   JACKY ENVIRONMENT CHECK REPORT       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Toolchain Versions
Write-Host "--- Toolchain & Version Checks ---" -ForegroundColor Yellow

# rustc
try {
    $rustcVer = & rustc --version 2>&1
    Write-Host "[x] rustc: $rustcVer" -ForegroundColor Green
} catch {
    Write-Host "[ ] rustc: NOT FOUND in PATH" -ForegroundColor Red
}

# cargo
try {
    $cargoVer = & cargo --version 2>&1
    Write-Host "[x] cargo: $cargoVer" -ForegroundColor Green
} catch {
    Write-Host "[ ] cargo: NOT FOUND in PATH" -ForegroundColor Red
}

# rustup target list
try {
    $defaultTarget = & rustup default 2>&1
    Write-Host "[x] rustup default: $defaultTarget" -ForegroundColor Green
} catch {
    Write-Host "[ ] rustup: NOT FOUND in PATH" -ForegroundColor Red
}

# git
try {
    $gitVer = & git --version 2>&1
    Write-Host "[x] git: $gitVer" -ForegroundColor Green
} catch {
    Write-Host "[ ] git: NOT FOUND in PATH" -ForegroundColor Red
}

# PowerShell version
Write-Host "[x] PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Green

# 2. MSVC Build Tools Presence
Write-Host "`n--- Visual Studio / MSVC Build Tools ---" -ForegroundColor Yellow
$vswherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswherePath) {
    $vsInstalls = & $vswherePath -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json | ConvertFrom-Json
    if ($vsInstalls) {
        foreach ($inst in $vsInstalls) {
            Write-Host "[x] Visual Studio / Build Tools found: $($inst.displayName) ($($inst.installationVersion))" -ForegroundColor Green
            Write-Host "    Path: $($inst.installationPath)" -ForegroundColor Gray
        }
    } else {
        Write-Host "[!] vswhere found, but Desktop C++ (VC.Tools.x86.x64) component was not detected." -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] vswhere.exe not found at standard installer location." -ForegroundColor Yellow
}

# 3. CPU and Hardware Info
Write-Host "`n--- Hardware & System Specs ---" -ForegroundColor Yellow
$cpu = Get-CimInstance Win32_Processor
Write-Host "CPU: $($cpu.Name.Trim())" -ForegroundColor White
Write-Host "Cores / Logical Processors: $($cpu.NumberOfCores) Cores / $($cpu.NumberOfLogicalProcessors) Threads" -ForegroundColor White

# RAM
$os = Get-CimInstance Win32_OperatingSystem
$totalRamGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
Write-Host "Total Visible RAM: $totalRamGB GB" -ForegroundColor White
Write-Host "Free Physical RAM: $freeRamGB GB" -ForegroundColor White

# 4. Storage Checks (Project Drive & APPDATA)
Write-Host "`n--- Storage & Drive Details ---" -ForegroundColor Yellow

$projectDrive = (Get-Item "d:\").PSDrive
$appdataDriveLetter = (Split-Path $env:APPDATA -Qualifier).TrimEnd(":")
$appdataDrive = Get-PSDrive $appdataDriveLetter

Write-Host "Project Drive ($($projectDrive.Name):):" -ForegroundColor White
Write-Host "  Free: $([math]::Round($projectDrive.Free / 1GB, 2)) GB" -ForegroundColor Gray

Write-Host "APPDATA Drive ($($appdataDrive.Name):):" -ForegroundColor White
Write-Host "  Free: $([math]::Round($appdataDrive.Free / 1GB, 2)) GB" -ForegroundColor Gray

# Disk Media Type (SSD vs HDD)
try {
    $disks = Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, BusType, Size
    foreach ($d in $disks) {
        $sizeGB = [math]::Round($d.Size / 1GB, 2)
        Write-Host "Disk $($d.DeviceId) ($($d.FriendlyName)): MediaType=$($d.MediaType), Bus=$($d.BusType), Size=$sizeGB GB" -ForegroundColor White
    }
} catch {
    Write-Host "[!] Could not query PhysicalDisk (might require admin permissions)." -ForegroundColor Yellow
}

# 5. Power Plan
Write-Host "`n--- Power Plan ---" -ForegroundColor Yellow
try {
    $powerPlan = & powercfg /getactivescheme 2>&1
    Write-Host "Active Power Scheme: $powerPlan" -ForegroundColor White
} catch {
    Write-Host "[!] Could not query powercfg." -ForegroundColor Yellow
}

# 6. BitLocker / Device Encryption
Write-Host "`n--- BitLocker / Device Encryption ---" -ForegroundColor Yellow
try {
    $bl = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
    if ($bl) {
        Write-Host "C: Drive Protection Status: $($bl.ProtectionStatus), Encryption: $($bl.VolumeStatus)" -ForegroundColor White
    } else {
        # Check Device Encryption status via CIM
        $devEnc = Get-CimInstance -Namespace root\cimv2\Security\MicrosoftVolumeEncryption -ClassName Win32_EncryptableVolume -Filter "DriveLetter = 'C:'" -ErrorAction SilentlyContinue
        if ($devEnc) {
            Write-Host "C: Protection Status: $($devEnc.ProtectionStatus)" -ForegroundColor White
        } else {
            Write-Host "BitLocker status check requires elevation or not accessible via standard user." -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "BitLocker status check error / requires elevation." -ForegroundColor Gray
}

# 7. WebView2 Runtime
Write-Host "`n--- WebView2 Runtime ---" -ForegroundColor Yellow
$wv2Paths = @(
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-9E47-bb97-b921-1613EDC9422F}",
    "HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-9E47-bb97-b921-1613EDC9422F}"
)
$wv2Found = $false
foreach ($regPath in $wv2Paths) {
    if (Test-Path $regPath) {
        $ver = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).pv
        if ($ver) {
            Write-Host "[x] WebView2 Runtime detected (version: $ver)" -ForegroundColor Green
            $wv2Found = $true
            break
        }
    }
}
if (-not $wv2Found) {
    # Check installation folder
    $edgeWv2 = "${env:ProgramFiles(x86)}\Microsoft\EdgeWebView\Application"
    if (Test-Path $edgeWv2) {
        Write-Host "[x] WebView2 Runtime folder found at $edgeWv2" -ForegroundColor Green
    } else {
        Write-Host "[ ] WebView2 Runtime not detected in registry or default folder." -ForegroundColor Yellow
    }
}

# 8. AppData Jacky Folder
Write-Host "`n--- Jacky Directory Status ---" -ForegroundColor Yellow
$jackyAppData = Join-Path $env:APPDATA "Jacky"
if (Test-Path $jackyAppData) {
    Write-Host "[x] AppData directory exists: $jackyAppData" -ForegroundColor Green
} else {
    Write-Host "[ ] AppData directory does not exist yet: $jackyAppData" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   CHECK COMPLETE                       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
