$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$LockFile = Join-Path $ProjectRoot "pubspec.lock"
$OutputFile = Join-Path $ProjectRoot "THIRD_PARTY_LICENSES.md"
$PubCache = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev"

if (-not (Test-Path $LockFile)) {
    throw "pubspec.lock was not found."
}

if (-not (Test-Path $PubCache)) {
    throw "Pub cache was not found: $PubCache"
}

# Parse package information from pubspec.lock.
$lines = Get-Content $LockFile

$packages = @()
$currentPackage = $null
$currentDependency = $null
$currentSource = $null
$currentVersion = $null

foreach ($line in $lines) {

    if ($line -match '^  ([A-Za-z0-9_]+):$') {

        if ($null -ne $currentPackage -and $null -ne $currentVersion) {
            $packages += [PSCustomObject]@{
                Name       = $currentPackage
                Version    = $currentVersion
                Dependency = $currentDependency
                Source     = $currentSource
            }
        }

        $currentPackage = $Matches[1]
        $currentDependency = $null
        $currentSource = $null
        $currentVersion = $null
        continue
    }

    if ($null -ne $currentPackage) {

        if ($line -match '^    dependency: "?([^"]+)"?$') {
            $currentDependency = $Matches[1]
            continue
        }

        if ($line -match '^    source: ([A-Za-z0-9_]+)$') {
            $currentSource = $Matches[1]
            continue
        }

        if ($line -match '^    version: "([^"]+)"$') {
            $currentVersion = $Matches[1]
            continue
        }
    }
}

if ($null -ne $currentPackage -and $null -ne $currentVersion) {
    $packages += [PSCustomObject]@{
        Name       = $currentPackage
        Version    = $currentVersion
        Dependency = $currentDependency
        Source     = $currentSource
    }
}

# Only hosted packages have LICENSE files in the Pub Cache location used here.
$hostedPackages = $packages |
    Where-Object { $_.Source -eq "hosted" } |
    Sort-Object Name

$output = New-Object System.Collections.Generic.List[string]

$output.Add("# Third-Party Licenses")
$output.Add("")
$output.Add("This document lists third-party Dart and Flutter packages used by Memotype, based on pubspec.lock.")
$output.Add("")
$output.Add("この文書は、Memotype が使用する第三者製 Dart / Flutter パッケージについて、pubspec.lock を基準にライセンス情報を整理したものです。")
$output.Add("")
$output.Add("Generated automatically by generate_licenses.ps1.")
$output.Add("")
$output.Add("---")
$output.Add("")

foreach ($package in $hostedPackages) {

    $packageDirectory = Join-Path $PubCache "$($package.Name)-$($package.Version)"

    $output.Add("## $($package.Name) $($package.Version)")
    $output.Add("")
    $output.Add("- Dependency: $($package.Dependency)")
    $output.Add("- Source: pub.dev")
    $output.Add("")

    if (-not (Test-Path $packageDirectory)) {
        $output.Add("**License file not found because the package directory was not found in the local Pub Cache.**")
        $output.Add("")
        $output.Add("---")
        $output.Add("")
        continue
    }

    $licenseFile = Get-ChildItem `
        -Path $packageDirectory `
        -File `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^LICENSE($|\.)' } |
        Select-Object -First 1

    if ($null -eq $licenseFile) {
        $output.Add("**LICENSE file not found in the package directory. Manual review required.**")
        $output.Add("")
        $output.Add("---")
        $output.Add("")
        continue
    }

    $licenseText = Get-Content $licenseFile.FullName -Raw

    $output.Add("License file: $($licenseFile.Name)")
    $output.Add("")
    $output.Add('```text')
    $output.Add($licenseText.TrimEnd())
    $output.Add('```')
    $output.Add("")
    $output.Add("---")
    $output.Add("")
}

$output | Set-Content `
    -Path $OutputFile `
    -Encoding utf8

Write-Host ""
Write-Host "Generated:"
Write-Host $OutputFile
Write-Host ""
Write-Host "Packages processed: $($hostedPackages.Count)"
Write-Host ""

$missing = Select-String `
    -Path $OutputFile `
    -Pattern "Manual review required|package directory was not found"

if ($missing) {
    Write-Warning "Some packages require manual license review."
}
else {
    Write-Host "No missing LICENSE files were detected."
}