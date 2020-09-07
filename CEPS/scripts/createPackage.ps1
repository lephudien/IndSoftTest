#Params
param($PackageVersion)

#$packageVersion = "1.0.0.10"
Write-Host "PackageVersion: " $PackageVersion

$PathProjectRoot = (get-item $PSScriptRoot).parent.FullName
$PathProjectBuildResources = $PathProjectRoot + "\BuildResources"

$PackageOutFolder = $("S:\TeamCity\output\builds\IndSoftCEPS_v" + $PackageVersion)
Write-Host "PackageOutFolder: " $PackageOutFolder
New-Item -ItemType Directory -Force -Path $PackageOutFolder

$ZipFile = $($PackageOutFolder + "\IndSoftCEPS_v" + $PackageVersion + ".zip")
Write-Host "ZipFile: " $ZipFile
# Create a zip file with the contents of C:\Stuff\
Compress-Archive -Path $PathProjectBuildResources -DestinationPath $ZipFile