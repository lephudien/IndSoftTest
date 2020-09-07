#Params
param($PackageVersion)

#$packageVersion = "1.0.0.10"
Write-Host "PackageVersion: " $PackageVersion

$PathProjectRoot = (get-item $PSScriptRoot).parent.FullName
$PathProjectBuildResources = $PathProjectRoot + "\BuildResources"


Copy-Item $($PathProjectRoot + "\src\MainAppCEPS\bin\Debug\CEPSModules1.dll") -Destination $($PathProjectBuildResources + "\Libraries\AppServer") -Force
Copy-Item $($PathProjectRoot + "\src\MainAppCEPS\bin\Debug\CEPSModules1.pdb") -Destination $($PathProjectBuildResources + "\Libraries\AppServer") -Force
Copy-Item $($PathProjectRoot + "\src\MainAppCEPS\bin\Debug\MainAppCEPSServer.exe") -Destination $($PathProjectBuildResources + "\Libraries\AppServer") -Force
Copy-Item $($PathProjectRoot + "\src\MainAppCEPS\bin\Debug\MainAppCEPSServer.pdb") -Destination $($PathProjectBuildResources + "\Libraries\AppServer") -Force
Copy-Item $($PathProjectRoot + "\src\AppClientCEPS\bin\Debug\CEPSModules1.dll") -Destination $($PathProjectBuildResources + "\Libraries\AppClient") -Force
Copy-Item $($PathProjectRoot + "\src\AppClientCEPS\bin\Debug\CEPSModules1.pdb") -Destination $($PathProjectBuildResources + "\Libraries\AppClient") -Force
Copy-Item $($PathProjectRoot + "\src\MainAppCEPS\bin\Debug\AppClientCEPS.exe") -Destination $($PathProjectBuildResources + "\Libraries\AppClient") -Force
Copy-Item $($PathProjectRoot + "\src\MainAppCEPS\bin\Debug\AppClientCEPS.pdb") -Destination $($PathProjectBuildResources + "\Libraries\AppClient") -Force


$PackageOutFolder = $("S:\TeamCity\output\builds\IndSoftCEPS_v" + $PackageVersion)
Write-Host "PackageOutFolder: " $PackageOutFolder
New-Item -ItemType Directory -Force -Path $PackageOutFolder

$ZipFile = $($PackageOutFolder + "\IndSoftCEPS_v" + $PackageVersion + ".zip")
Write-Host "ZipFile: " $ZipFile
# Create a zip file with the contents of C:\Stuff\
Compress-Archive -Path $PathProjectBuildResources -DestinationPath $ZipFile