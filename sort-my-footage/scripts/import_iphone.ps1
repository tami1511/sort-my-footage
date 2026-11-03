<#
  Copies clips from an iPhone plugged in by cable into -Dest.
  The iPhone must be unlocked and must "Trust" this computer.
  Clips already brought in before are skipped (listed in -Dest\.imported.txt).
  Nothing on the phone is changed or deleted.
#>
param(
    [Parameter(Mandatory = $true)][string]$Dest,
    [int]$Days = 7,
    [ValidateSet("videos","photos","both")][string]$Kind = "videos"
)

$videoExt = @('.mov', '.mp4', '.m4v', '.hevc')
$photoExt = @('.jpg', '.jpeg', '.heic', '.png')
$wanted = switch ($Kind) { "photos" { $photoExt } "both" { $videoExt + $photoExt } default { $videoExt } }

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
$seenFile = Join-Path $Dest '.imported.txt'
$seen = @{}
if (Test-Path $seenFile) { Get-Content $seenFile | ForEach-Object { $seen[$_] = $true } }

$shell = New-Object -ComObject Shell.Application
$phone = $shell.NameSpace(17).Items() | Where-Object { $_.Name -match 'iPhone|Apple' } | Select-Object -First 1
if (-not $phone) {
    Write-Output "No iPhone found. Plug it in with the cable and unlock it."
    exit 2
}
Write-Output "Found the iPhone."

$storage = $phone.GetFolder.Items() | Select-Object -First 1
if (-not $storage) {
    Write-Output "The iPhone is locked or hasn't trusted this laptop yet. Unlock it, tap Trust, and try again."
    exit 3
}
$dcim = $storage.GetFolder.Items() | Where-Object { $_.Name -eq 'DCIM' } | Select-Object -First 1
if (-not $dcim) {
    Write-Output "Couldn't find the camera roll (DCIM) on the iPhone."
    exit 4
}

$since = if ($Days -gt 0) { (Get-Date).AddDays(-$Days) } else { [datetime]::MinValue }
$destNs = $shell.NameSpace((Resolve-Path $Dest).Path)
$copied = 0

foreach ($sub in $dcim.GetFolder.Items()) {
    if (-not $sub.IsFolder) { continue }
    # iPhone folders are named like 202610__ (year + month). Skip months that are too old.
    if ($Days -gt 0 -and $sub.Name -match '^(\d{4})(\d{2})') {
        $monthEnd = (Get-Date -Year $Matches[1] -Month $Matches[2] -Day 1).AddMonths(1)
        if ($monthEnd -lt $since) { continue }
    }
    foreach ($item in $sub.GetFolder.Items()) {
        if ($item.IsFolder) { continue }
        $name = $item.Name
        $ext = [IO.Path]::GetExtension($name).ToLower()
        if (-not $ext) {
            # Explorer can hide extensions; fall back to the type text
            if ($item.Type -match 'MOV|MP4|video') { $ext = '.mov' } elseif ($item.Type -match 'HEIC|JPEG|JPG|PNG|image') { $ext = '.heic' } else { continue }
        }
        if ($wanted -notcontains $ext) { continue }
        try { if ($item.ModifyDate -and $item.ModifyDate -lt $since) { continue } } catch {}
        $key = "$($sub.Name)/$name"
        if ($seen.ContainsKey($key)) { continue }

        Write-Output "Copying $name ..."
        $destNs.CopyHere($item, 4 + 16 + 1024)
        # Copying from a phone runs in the background; wait until the file has stopped growing.
        $target = Get-ChildItem -LiteralPath $Dest -Filter ([IO.Path]::GetFileNameWithoutExtension($name) + '*') -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $last = -1; $still = 0; $waited = 0
        while ($still -lt 3 -and $waited -lt 900) {
            Start-Sleep -Milliseconds 700; $waited++
            $target = Get-ChildItem -LiteralPath $Dest -Filter ([IO.Path]::GetFileNameWithoutExtension($name) + '*') -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $size = if ($target) { $target.Length } else { -1 }
            if ($size -gt 0 -and $size -eq $last) { $still++ } else { $still = 0 }
            $last = $size
        }
        Add-Content -LiteralPath $seenFile -Value $key
        $copied++
    }
}

Write-Output "Brought in $copied new clips. The originals are still on the iPhone."
exit 0
