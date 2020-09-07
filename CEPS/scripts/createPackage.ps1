#Params
param($PackageVersion)

#$packageVersion = "1.0.0.10"
Write-Host "PackageVersion: " $PackageVersion

$PackageOutFolder = $("S:\TeamCity\output\builds\IndSoftCEPS_v" + $PackageVersion)
Write-Host "PackageOutFolder: " $PackageOutFolder
New-Item -ItemType Directory -Force -Path $PackageOutFolder

$ZipFile = $($PackageOutFolder + "\IndSoftCEPS_v" + $PackageVersion + ".zip")
Write-Host "ZipFile: " $ZipFile
# Create a zip file with the contents of C:\Stuff\
Compress-Archive -Path 'c:\Program Files (x86)\BuildAgent\work\9a159fa32295444\CEPS\BuildResources' -DestinationPath $ZipFile