# Update Keil Project File - Replace main.c with main.cpp
# This script is called by post_generate.bat
# Usage: powershell -ExecutionPolicy Bypass -File update_keil_project.ps1 <project_file_path>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectFile
)

# Verify file exists
if (-not (Test-Path $ProjectFile)) {
    Write-Host "[ERROR] File not found: $ProjectFile"
    exit 1
}

Write-Host "Processing: $ProjectFile"

try {
    # Read the file content
    $content = Get-Content $ProjectFile -Raw -Encoding UTF8
    
    # Replace main.c with main.cpp in XML elements
    # Pattern 1: <FileName>main.c</FileName> -> <FileName>main.cpp</FileName>
    $content = $content -replace '(<FileName>)main\.c(</FileName>)', '$1main.cpp$2'
    
    # Pattern 2: Path separators followed by main.c -> same with main.cpp
    # Handles both forward slash (/) and backslash (\) in paths
    $content = $content -replace '([\\/])main\.c', '$1main.cpp'
    
    # Write the updated content back to the file
    $content | Set-Content $ProjectFile -Encoding UTF8
    
    Write-Host "[SUCCESS] Updated $ProjectFile"
    exit 0
}
catch {
    Write-Host "[ERROR] Failed to update file: $_"
    exit 1
}
