# Fresh PC Setup
function CreateIfNotExists {
	param ([string] $path)

	if (!(Test-Path -Path $path)) {
		New-Item -ItemType Directory -Path $path
	}
}

winget install --id=Git.Git -e --accept-package-agreements --accept-source-agreements

# Not sure if it gets added to the path without shell restart
$env:Path += ";C:\Program Files\Git\cmd"

$path = Read-Host -Prompt "Path to create cabinet?"
$cabinetPath = "$path\cabinet"
$sourcePath = "$path\cabinet\source"

CreateIfNotExists -path $cabinetPath
CreateIfNotExists -path $sourcePath

Set-Location $sourcePath

git clone https://github.com/bdwakefield/PowerShellProfile.git

Set-Location " $sourcePath\PowerShellProfile"

./Install-FromWinGet.ps1
./Update-Settings.ps1