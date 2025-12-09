# PowerShell script to create modular directory structure for WayTree

Write-Host "Creating modular directory structure..." -ForegroundColor Green

# Core directories
$coreDirs = @(
    "lib\core\config",
    "lib\core\theme",
    "lib\core\utils",
    "lib\core\widgets"
)

# Module directories
$moduleDirs = @(
    # Authentication
    "lib\modules\authentication\models",
    "lib\modules\authentication\screens",
    "lib\modules\authentication\services",
    
    # AI Assistant
    "lib\modules\ai_assistant\models",
    "lib\modules\ai_assistant\screens",
    "lib\modules\ai_assistant\services",
    "lib\modules\ai_assistant\widgets",
    
    # Events
    "lib\modules\events\models",
    "lib\modules\events\screens",
    "lib\modules\events\services",
    
    # Networking
    "lib\modules\networking\models",
    "lib\modules\networking\screens",
    "lib\modules\networking\widgets",
    
    # Profile
    "lib\modules\profile\models",
    "lib\modules\profile\screens",
    "lib\modules\profile\services",
    "lib\modules\profile\widgets",
    
    # Goals
    "lib\modules\goals\models",
    "lib\modules\goals\screens",
    "lib\modules\goals\services",
    "lib\modules\goals\widgets",
    
    # Connections
    "lib\modules\connections\models",
    "lib\modules\connections\screens",
    "lib\modules\connections\widgets"
)

# Shared directories
$sharedDirs = @(
    "lib\shared\models",
    "lib\shared\services",
    "lib\shared\widgets"
)

# Create all directories
$allDirs = $coreDirs + $moduleDirs + $sharedDirs

foreach ($dir in $allDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Cyan
    } else {
        Write-Host "Exists: $dir" -ForegroundColor Yellow
    }
}

Write-Host "`nDirectory structure created successfully!" -ForegroundColor Green
Write-Host "Total directories created: $($allDirs.Count)" -ForegroundColor Green
