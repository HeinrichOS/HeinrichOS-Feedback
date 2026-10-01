[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [Parameter(Mandatory=$true)][string]$PackageRoot,
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Exit = @{
    PASS            = 0
    ALREADY_CURRENT = 10
    MANIFEST_FAIL   = 20
    TARGET_FAIL     = 21
    PROTECTION_FAIL = 22
    UNKNOWN_STATE   = 23
    PACKAGE_FAIL    = 24
    ROLLBACK_PASS   = 31
    ROLLBACK_FAIL   = 32
    INTERNAL_ERROR  = 99
}

function Safe-Rel([string]$Rel) {
    if ([string]::IsNullOrWhiteSpace($Rel)) { throw 'Leerer relativer Pfad.' }
    if ([IO.Path]::IsPathRooted($Rel) -or $Rel.Contains(':') -or (($Rel -split '[\\/]') -contains '..')) {
        throw ('Unsicherer relativer Pfad: ' + $Rel)
    }
}

function Full-Rel([string]$Base,[string]$Rel) {
    Safe-Rel $Rel
    return (Join-Path $Base ($Rel -replace '/', [IO.Path]::DirectorySeparatorChar))
}

function Sha([string]$Path) {
    return ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant())
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) { exit $Exit.TARGET_FAIL }
if (-not (Test-Path -LiteralPath $PackageRoot -PathType Container)) { exit $Exit.PACKAGE_FAIL }

$TargetPath = (Resolve-Path -LiteralPath $TargetPath).Path
$PackageRoot = (Resolve-Path -LiteralPath $PackageRoot).Path
$UcRoot = Join-Path $TargetPath 'HOS_SYSTEM\UPDATE_CENTER'
$History = Join-Path $UcRoot 'HISTORY'
$Work = Join-Path $UcRoot 'WORK'
$BackupBase = Join-Path $UcRoot 'BACKUP'
Ensure-Dir $History
Ensure-Dir $Work
Ensure-Dir $BackupBase

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$log = Join-Path $History ('update_' + $stamp + '.log')
$resultPath = Join-Path $Work 'last_result.json'

function Log([string]$Level,[string]$Message) {
    $line = ('{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'),$Level,$Message)
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
}

function Result([int]$Code,[string]$Status,[string]$Message,[bool]$RollbackConfirmed=$false) {
    $obj = [ordered]@{
        timestamp = [DateTime]::UtcNow.ToString('o')
        code = $Code
        status = $Status
        message = $Message
        rollback_confirmed = $RollbackConfirmed
        log = $log
    }
    ($obj | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $resultPath -Encoding UTF8
}

function Stop-Safe([int]$Code,[string]$Status,[string]$Message) {
    Log $Status $Message
    Result $Code $Status $Message $false
    exit $Code
}

$manifestPath = Join-Path $PackageRoot 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    Stop-Safe $Exit.MANIFEST_FAIL 'MANIFEST_FAIL' 'Manifest fehlt.'
}

try { $m = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json }
catch { Stop-Safe $Exit.MANIFEST_FAIL 'MANIFEST_FAIL' 'Manifest ist unlesbar.' }

if ([string]$m.schema -ne 'heinrichos-update-1' -or -not [bool]$m.installable) {
    Stop-Safe $Exit.MANIFEST_FAIL 'MANIFEST_FAIL' 'Manifest-Schema oder Installationsfreigabe ungueltig.'
}

$notesPath = Join-Path $PackageRoot 'release_notes.txt'
if (-not (Test-Path -LiteralPath $notesPath -PathType Leaf)) {
    Stop-Safe $Exit.PACKAGE_FAIL 'PACKAGE_FAIL' 'Release Notes fehlen.'
}
if ((Sha $notesPath) -ne ([string]$m.release_notes_sha256).ToUpperInvariant()) {
    Stop-Safe $Exit.PACKAGE_FAIL 'PACKAGE_FAIL' 'Release Notes Hashpruefung fehlgeschlagen.'
}

foreach ($p in @($m.protection)) {
    $full = Full-Rel $TargetPath ([string]$p.path)
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        Stop-Safe $Exit.PROTECTION_FAIL 'PROTECTION_FAIL' ('Geschuetzte Datei fehlt: ' + [string]$p.path)
    }
    if ((Sha $full) -ne ([string]$p.sha256).ToUpperInvariant()) {
        Stop-Safe $Exit.PROTECTION_FAIL 'PROTECTION_FAIL' ('Schutzpruefung fehlgeschlagen: ' + [string]$p.path)
    }
}
Log 'PASS' 'Protection precheck bestanden.'

$allTarget = $true
foreach ($a in @($m.actions)) {
    $target = Full-Rel $TargetPath ([string]$a.path)
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { $allTarget = $false; break }
    if ((Sha $target) -ne ([string]$a.target_sha256).ToUpperInvariant()) { $allTarget = $false; break }
}
if ($allTarget) {
    Log 'ALREADY_CURRENT' ([string]$m.target_state)
    Result $Exit.ALREADY_CURRENT 'ALREADY_CURRENT' 'HeinrichOS ist bereits auf diesem Update-Stand.' $false
    exit $Exit.ALREADY_CURRENT
}

foreach ($a in @($m.actions)) {
    $act = ([string]$a.action).ToUpperInvariant()
    $target = Full-Rel $TargetPath ([string]$a.path)
    if ($act -eq 'ADD') {
        if (Test-Path -LiteralPath $target) {
            Stop-Safe $Exit.UNKNOWN_STATE 'UNKNOWN_STATE' ('ADD-Ziel ist nicht frei: ' + [string]$a.path)
        }
    }
    elseif ($act -eq 'REPLACE') {
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            Stop-Safe $Exit.UNKNOWN_STATE 'UNKNOWN_STATE' ('REPLACE-Quelle fehlt: ' + [string]$a.path)
        }
        if ((Sha $target) -ne ([string]$a.source_sha256).ToUpperInvariant()) {
            Stop-Safe $Exit.UNKNOWN_STATE 'UNKNOWN_STATE' ('REPLACE-Quelle hat unbekannten Stand: ' + [string]$a.path)
        }
    }
    else {
        Stop-Safe $Exit.MANIFEST_FAIL 'MANIFEST_FAIL' ('Unbekannte Aktion: ' + $act)
    }

    $payload = Full-Rel $PackageRoot ([string]$a.payload_path)
    if (-not (Test-Path -LiteralPath $payload -PathType Leaf)) {
        Stop-Safe $Exit.PACKAGE_FAIL 'PACKAGE_FAIL' ('Payload fehlt: ' + [string]$a.payload_path)
    }
    if ((Sha $payload) -ne ([string]$a.payload_sha256).ToUpperInvariant()) {
        Stop-Safe $Exit.PACKAGE_FAIL 'PACKAGE_FAIL' ('Payload Hashpruefung fehlgeschlagen: ' + [string]$a.payload_path)
    }
}
Log 'PASS' 'Source-State und Payload geprueft.'

if (-not $Apply) {
    Result $Exit.PASS 'UPDATE_AVAILABLE' ([string]$m.display_version) $false
    Log 'PASS' 'Check-only: Update verfuegbar; 0 Produktdateien geschrieben.'
    exit $Exit.PASS
}

$workspace = Join-Path $Work ('txn_' + $stamp)
$stage = Join-Path $workspace 'stage'
$backup = Join-Path $workspace 'backup'
Ensure-Dir $stage
Ensure-Dir $backup
$writeStarted = $false

try {
    foreach ($a in @($m.actions)) {
        $target = Full-Rel $TargetPath ([string]$a.path)
        $payload = Full-Rel $PackageRoot ([string]$a.payload_path)
        $staged = Full-Rel $stage ([string]$a.path)
        Ensure-Dir (Split-Path -Parent $staged)
        Copy-Item -LiteralPath $payload -Destination $staged -Force
        if ((Sha $staged) -ne ([string]$a.payload_sha256).ToUpperInvariant()) {
            throw ('Staging Hashpruefung fehlgeschlagen: ' + [string]$a.path)
        }
        if (([string]$a.action).ToUpperInvariant() -eq 'REPLACE') {
            $bak = Full-Rel $backup ([string]$a.path)
            Ensure-Dir (Split-Path -Parent $bak)
            Copy-Item -LiteralPath $target -Destination $bak -Force
        }
    }

    foreach ($a in @($m.actions)) {
        $target = Full-Rel $TargetPath ([string]$a.path)
        $staged = Full-Rel $stage ([string]$a.path)
        Ensure-Dir (Split-Path -Parent $target)
        $writeStarted = $true
        Copy-Item -LiteralPath $staged -Destination $target -Force
        Log 'APPLY' ([string]$a.path)
    }

    foreach ($a in @($m.actions)) {
        $target = Full-Rel $TargetPath ([string]$a.path)
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw ('Postcheck: Datei fehlt: ' + [string]$a.path) }
        if ((Sha $target) -ne ([string]$a.target_sha256).ToUpperInvariant()) { throw ('Postcheck Hashfehler: ' + [string]$a.path) }
    }

    foreach ($p in @($m.protection)) {
        $full = Full-Rel $TargetPath ([string]$p.path)
        if ((Sha $full) -ne ([string]$p.sha256).ToUpperInvariant()) { throw ('Protection Postcheck fehlgeschlagen: ' + [string]$p.path) }
    }

    $backupFiles = @(Get-ChildItem -LiteralPath $backup -Recurse -File -ErrorAction SilentlyContinue)
    if ($backupFiles.Count -gt 0) {
        $finalBackup = Join-Path $BackupBase $stamp
        Move-Item -LiteralPath $backup -Destination $finalBackup
    }
    if (Test-Path -LiteralPath $workspace) { Remove-Item -LiteralPath $workspace -Recurse -Force }

    Log 'COMMIT_PASS' ([string]$m.target_state)
    Result $Exit.PASS 'COMMIT_PASS' 'Update erfolgreich installiert.' $false
    exit $Exit.PASS
}
catch {
    $reason = $_.Exception.Message
    Log 'ERROR' $reason

    if (-not $writeStarted) {
        if (Test-Path -LiteralPath $workspace) { Remove-Item -LiteralPath $workspace -Recurse -Force -ErrorAction SilentlyContinue }
        Result $Exit.INTERNAL_ERROR 'FAILED_BEFORE_WRITE' $reason $false
        exit $Exit.INTERNAL_ERROR
    }

    $rollbackOk = $true
    try {
        $actions = @($m.actions)
        for ($i=$actions.Count-1; $i -ge 0; $i--) {
            $a = $actions[$i]
            $target = Full-Rel $TargetPath ([string]$a.path)
            $act = ([string]$a.action).ToUpperInvariant()
            if ($act -eq 'ADD') {
                if (Test-Path -LiteralPath $target -PathType Leaf) { Remove-Item -LiteralPath $target -Force }
            }
            elseif ($act -eq 'REPLACE') {
                $bak = Full-Rel $backup ([string]$a.path)
                if (-not (Test-Path -LiteralPath $bak -PathType Leaf)) { throw ('Rollback-Backup fehlt: ' + [string]$a.path) }
                Ensure-Dir (Split-Path -Parent $target)
                Copy-Item -LiteralPath $bak -Destination $target -Force
            }
        }

        foreach ($a in @($m.actions)) {
            $target = Full-Rel $TargetPath ([string]$a.path)
            $act = ([string]$a.action).ToUpperInvariant()
            if ($act -eq 'ADD' -and (Test-Path -LiteralPath $target)) { throw ('Rollback ADD blieb bestehen: ' + [string]$a.path) }
            if ($act -eq 'REPLACE' -and (Sha $target) -ne ([string]$a.source_sha256).ToUpperInvariant()) { throw ('Rollback Hashfehler: ' + [string]$a.path) }
        }
        foreach ($p in @($m.protection)) {
            $full = Full-Rel $TargetPath ([string]$p.path)
            if ((Sha $full) -ne ([string]$p.sha256).ToUpperInvariant()) { throw ('Rollback Protection fehlgeschlagen: ' + [string]$p.path) }
        }
    }
    catch {
        $rollbackOk = $false
        Log 'ROLLBACK_FAIL' $_.Exception.Message
    }

    if (Test-Path -LiteralPath $workspace) { Remove-Item -LiteralPath $workspace -Recurse -Force -ErrorAction SilentlyContinue }

    if ($rollbackOk) {
        Log 'ROLLBACK_PASS' 'Vorheriger Stand vollstaendig wiederhergestellt.'
        Result $Exit.ROLLBACK_PASS 'ROLLBACK_PASS' $reason $true
        exit $Exit.ROLLBACK_PASS
    }
    Result $Exit.ROLLBACK_FAIL 'ROLLBACK_FAIL' $reason $false
    exit $Exit.ROLLBACK_FAIL
}
