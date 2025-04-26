# PowerShell script to sync .env files to env-storage repository

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDirectory
)

$EnvStorageDir = "C:\Code\utilities\env-storage"

# Check if source directory exists
if (-not (Test-Path $SourceDirectory)) {
    Write-Error "Error: Source directory $SourceDirectory does not exist"
    exit 1
}

# Check if env-storage directory exists
if (-not (Test-Path $EnvStorageDir)) {
    Write-Error "Error: env-storage directory $EnvStorageDir does not exist"
    exit 1
}

# Function to clean folder name for file naming
function Clean-FolderName {
    param([string]$folderPath)
    return $folderPath.Replace('\', '-').Replace(' ', '_')
}

# Create a temporary directory
$TempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "env-sync-$(Get-Random)") -Force

try {
    # Find all .env files
    $envFiles = Get-ChildItem -Path $SourceDirectory -Filter ".env" -Recurse -File

    if ($envFiles.Count -eq 0) {
        Write-Warning "No .env files found in $SourceDirectory"
        exit 1
    }

    # Process each .env file
    foreach ($file in $envFiles) {
        # Get relative path from source directory
        $relativePath = $file.FullName.Substring($SourceDirectory.Length + 1)
        $dirPath = [System.IO.Path]::GetDirectoryName($relativePath)
        $cleanDir = Clean-FolderName $dirPath
        
        # Create new file name with directory prefix
        $newFileName = if ($cleanDir) { "${cleanDir}.env" } else { "root.env" }
        $destPath = Join-Path $TempDir $newFileName

        # Copy the file
        Copy-Item -Path $file.FullName -Destination $destPath
        Write-Host "Copied: $($file.FullName) -> $newFileName"
    }

    # Move to env-storage directory
    Push-Location $EnvStorageDir

    try {
        # Check for existing files and notify about overwrites
        Get-ChildItem -Path "$TempDir\*" | ForEach-Object {
            $targetFile = Join-Path $EnvStorageDir $_.Name
            if (Test-Path $targetFile) {
                Write-Host "Overwriting existing file: $($_.Name)" -ForegroundColor Yellow
            }
        }

        # Move the new files to env-storage
        Copy-Item -Path "$TempDir\*" -Destination $EnvStorageDir -Force

        # Git operations
        git add .
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        git commit -m "Update environment variables $timestamp"
        git push

        Write-Host "Environment variables successfully synced to env-storage repository"
    }
    finally {
        # Return to original directory
        Pop-Location
    }
}
finally {
    # Cleanup temporary directory
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
}

Write-Host "`nUsage example:"
Write-Host ".\sync-env.ps1 -SourceDirectory 'C:\Code\telegram-bots'" 
