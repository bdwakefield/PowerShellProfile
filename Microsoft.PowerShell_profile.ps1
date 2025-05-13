$profilePath = "$($env:USERPROFILE)"
$initialSetup = "$profilePath\Documents\PowerShell\.profileSetup.txt"
$ohmyposhconf = "$profilePath\OhMyPosh_Profile.json"
$currentDate = (Get-Date)

# https://github.com/chubin/wttr.in
$weather_outputFormat = '+%c+%C+%t+%f+%w+%p'
$weather_uri = "https://wttr.in/KCLE?uA&format=$weather_outputFormat"

$localWeatherFile = "$($env:USERPROFILE)\.currentWeather"
$computerInfoPath = "$($env:USERPROFILE)\.systeminfo"

#Computer Info => Days
$computer_info_age = 10
#Weather Age => Minutes
$weather_age = 60

# Default for age of info if file does not exist, assume info needs refreshed
$olddays = (-1 * ($computer_info_age * 2 ))
$lastWeatherUpdate = ($currentDate).AddDays($olddays)
$lastInfoUpdate = ($currentDate).AddDays($olddays)

$TermColor = @{
    Reset              = "`e[0m"
    Bold               = "`e[1m"
    Underline          = "`e[4m"
    Invert             = "`e[7m"
    UnderlineOff       = "`e[24m"
    InvertOff          = "`e[27m"
    Black              = "`e[30m"
    Red                = "`e[31m"
    Green              = "`e[32m"
    Yellow             = "`e[33m"
    Blue               = "`e[34m"
    Magenta            = "`e[35m"
    Cyan               = "`e[36m"
    LightGray          = "`e[37m"
    DarkGrey           = "`e[90m"
    White              = "`e[97m"
    RedBackground      = "`e[41m"
    GreenBackground    = "`e[42m"
    YellowBackground   = "`e[43m"
    BlueBackground     = "`e[44m"
    MagentaBackground  = "`e[45m"
    CyanBackground     = "`e[46m"
    LRedBackground     = "`e[101m"
    LGreenBackground   = "`e[102m"
    LYellowBackground  = "`e[103m"
    LBlueBackground    = "`e[104m"
    LMagentaBackground = "`e[105m"
    LCyanBackground    = "`e[106m"
    LWhiteBackground   = "`e[107m"
}

function lsclone { Get-ChildItem $args -Exclude .*  | Format-Wide Name -AutoSize }

function CheckInstallModule {
    param (
        [string] $moduleName
    )

    if (Get-Module -ListAvailable -Name $moduleName) {
    } 
    else {
        Install-Module -Name $moduleName -Scope CurrentUser
    }
}

function wget {
    param (
        [string] $uri,
        [string] $OutFile = "",
        [switch] $Async
    )

    if ([String]::IsNullOrWhiteSpace($outFile)) {
        $OutFile = $uri.split("/")[-1]
    }

    $OutFile = [IO.Path]::Combine($pwd, $OutFile)

    if ($Async) {
    (new-object System.Net.WebClient).DownloadFileAsync($uri, $OutFile)
    }
    else {
    (new-object System.Net.WebClient).DownloadFile($uri, $OutFile)
    }
}

function grep {
    param (
        [string] $pattern,
        [string] $data,
        [string] $path
    )

    if ([String]::IsNullOrWhiteSpace($path)) {
        Select-String -Pattern $pattern -Path $path
    }
}

function Find-File {
    param (
        [string]$Path = '.',
        [string]$FileName = 'readme.txt',
        [bool]$Bare = $false
    )

    if ($Bare -eq $true) {
        Get-ChildItem -Path $Path -Filter "*$FileName*" -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object { $_.FullName }
    }
    else {
        Get-ChildItem -Path $Path -Filter "*$FileName*" -Recurse -ErrorAction SilentlyContinue -Force
    }
}

function Get-ComputerDetail {
    param (
        [string] $outFile = 'systeminfo.txt',
        [string] $delimiter = ' -- '
    )

    $info = Get-ComputerInfo | Select-Object OSName, OSBuildNumber, CsModel, CsName, BiosSerialNumber, BiosName
    $data = "$($info.OsName) [Build $($info.OsBuildNumber)]$($delimiter)$($info.CsModel) $($info.CsName)$($delimiter)Bios Rev $($info.BiosName)"

    Set-Content -Path $outFile -Value $data
}

function Edit-HistoryFile {
    code $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
}
Set-Alias ehf Edit-HistoryFile

function Get-Weather {
    param (
        [string] $uri
    )

    try {
        (Invoke-WebRequest -Uri $uri).Content
    }
    catch {
    }
}

function Update-Weather {
    param (
        [string] $localWeatherFile = "$($env:USERPROFILE)\.currentWeather"
    )

    $currentWeather = Get-Weather -uri $weather_uri
    Set-Content -Path $localWeatherFile -Value $currentWeather
}

function Update-ComputerInfo {
    param (
        [string] $localInfoFile = "$($env:USERPROFILE)\.systeminfo"
    )

    $info = Get-ComputerInfo | Select-Object OSName, OSBuildNumber, CsModel, CsName, BiosSerialNumber, BiosName
    Set-Content -Path $localInfoFile -Value "$($info.OsName) [Build $($info.OsBuildNumber)] -- $($info.CsModel) $($info.CsName) -- Bios Rev $($info.BiosName)"
}

function Show-MOTD {
    $updateWeather = $false
    $updateComputerInfo = $false

    if (Test-Path $localWeatherFile) {
        $lastWeatherUpdate = (Get-Item $localWeatherFile).LastWriteTime
        $weatherDelta = (New-TimeSpan -Start $lastWeatherUpdate -End ($currentDate))

        if ($weatherDelta.TotalMinutes -gt $weather_age) {
            $updateWeather = $true
        }
    }
    else {
        $updateWeather = $true
    }

    if ($updateWeather) {
        Update-Weather
        $lastWeatherUpdate = (Get-Item $localWeatherFile).LastWriteTime
        $weatherDelta = (New-TimeSpan -Start $lastWeatherUpdate -End ($currentDate))
    }

    if (Test-Path $computerInfoPath) {
        $lastInfoUpdate = (Get-Item $computerInfoPath).LastWriteTime
        $computerInfoDelta = (New-TimeSpan -Start $lastInfoUpdate -End ($currentDate))

        if ($computerInfoDelta.TotalDays -gt $computer_info_age) {
            $updateComputerInfo = $true
        }
    }
    else {
        $updateComputerInfo = $true
    }

    if ($updateComputerInfo) {
        Update-ComputerInfo
        $lastInfoUpdate = (Get-Item $computerInfoPath).LastWriteTime
        $computerInfoDelta = (New-TimeSpan -Start $lastInfoUpdate -End ($currentDate))
    }

    $conditions = Get-Content -Path $localWeatherFile
    $weatherDeltaMinutes = [int]$($weatherDelta).TotalMinutes
    $machineInfo = (Get-Content -Path $computerInfoPath).Split(" -- ")
    $weatherInfoLine = $conditions + " (" + $TermColor.Yellow + "updated " + $weatherDeltaMinutes + "m ago" + $TermColor.Reset + ")"

    Write-Host "$($TermColor.Green)================================================================================$($TermColor.Reset)"
    Write-Host " $(Get-Date -Format "dddd yyyy-MM-dd HH:mm K")"
    Write-Host $weatherInfoLine
    Write-Host " $($TermColor.LightGray)$($machineInfo[0])$($TermColor.Reset)"
    Write-Host " $($TermColor.LightGray)$($machineInfo[1])$($TermColor.Reset)"
    Write-Host " $($TermColor.LightGray)$($machineInfo[2])$($TermColor.Reset)"
    Write-Host "$($TermColor.Green)================================================================================$($TermColor.Reset)"
}

if ($(Test-Path $initialSetup) -eq $false) {
    CheckInstallModule -moduleName "Terminal-Icons"
    Set-Content -Path $initialSetup -Value $currentDate
    & $profile
}
else {
    Import-Module -Name Terminal-Icons

    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows

    oh-my-posh --init --shell pwsh --config $ohmyposhconf | Invoke-Expression

    for ($i = 1; $i -le 5; $i++) {
        $u = "".PadLeft($i, "u")
        $unum = "u$i"
        $d = $u.Replace("u", "../")
        Invoke-Expression "function $u { push-location $d }"
        Invoke-Expression "function $unum { push-location $d }"
    }

    Set-Alias ls lsclone
    Set-Alias ll Get-ChildItem
    Set-Alias cat Get-Content
    Set-Alias unzip Expand-Archive

    Show-MOTD
}