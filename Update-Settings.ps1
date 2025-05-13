$profilePath = "$($env:USERPROFILE)"
$ohmyposhconf = "$profilePath\OhMyPosh_Profile.json"
$psProfile = "$profilePath\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

Copy-Item -path ./OhMyPosh_Profile.json -Destination $ohmyposhconf
Copy-Item -Path ./Microsoft.PowerShell_profile.ps1 -Destination $psProfile