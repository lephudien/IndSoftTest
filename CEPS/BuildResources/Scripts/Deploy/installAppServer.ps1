Try {

# Directory structure settings
	$ErrorActionPreference = "stop"
	$ScriptName = $MyInvocation.MyCommand.Path
	$CurrentDir = Split-Path $MyInvocation.MyCommand.Path
	$global:logfile = "$CurrentDir\installAppServer.log"

# Load Scripts
	. $CurrentDir\Scripts\Common\_common.ps1
	. $CurrentDir\Scripts\Common\_updateConfigs.ps1

# Prepare installation 1
	$app = "AppServer"
	$EnvConfigFile = "$CurrentDir\config.xml"
	$InstallMainTempDir = "$CurrentDir\_WorkingAndBackupDirectory"
	if(-not (Test-Path "$InstallMainTempDir")) { New-Item "$InstallMainTempDir" -type directory | out-null }
	$PackageVersion     = Get-Content -Path "$CurrentDir\Configuration\version.info"
	Write-MainHeader "Lancelot Trading Predikce (PRE); $app" $PackageVersion

	Write-SectionHeader "KONFIGURACE PRO DANÉ PROSTØEDÍ"

# Load Environment Configuration
	$global:appSettings = @{}
	. $CurrentDir\Scripts\Common\_loadConfig.ps1 $CurrentDir\Configuration\XPathSetting.config
	. $CurrentDir\Scripts\Common\_loadConfig.ps1 $EnvConfigFile

# Set Helper Variables
	$InstallTempDir     = "$CurrentDir\_WorkingAndBackupDirectory\NEW_VERSION\$app"
	$BackupTempDir      = "$CurrentDir\_WorkingAndBackupDirectory\PREVIOUS_VERSION\$app"
	$EnvTargetConfigDir = "$CurrentDir\Libraries\AppServer\Config"
	$InstallPath        = $appSettings['AppServerInstallPath']
	Write-StepFinished "Naètení konfigurace instalace (InstallPath = '$InstallPath')"

# Update Config Files with Environment Specific Params
	Update-AppServer-EnifConfig
	Update-AppServer-ApplicationConfig
	Update-AppServer-Deneb2ServiceExe
	Update-AppServer-WatchDogDeneb2
	Update-AppServer-TreeConfigDeneb2DataTree
	Update-AppServer-TreeConfigDeneb2ViewTree
	#Update-AppServer-TreeConfigPM
	#Update-AppServer-TreeConfigRoot
	#Update-WatchDog-CygSvcActionManConfig

# Prepare installation 2 (files) 
	Write-EmptyLine
	Write-SectionDelimiter
	Write-SectionHeader "PØÍPRAVA INSTALACE"

	$PrevInstallPath = $InstallPath
	#$listsOfFiles = Prepare-Installation-v2 $app $InstallPath

	Write-EmptyLine
	Write-SectionDelimiter
	Write-SectionHeader "INSTALACE"

# Install New Version
	Write-StepStarted "Instalace nových a upravených souborù / knihoven"
	Write-StepStarted "Instalace nových a upravených souborù / knihoven (node1)"
#	Copy-DirsAndFiles "$InstallTempDir" "$InstallPath\$PackageVersionDir" | Out-Null
  $InstallCommand = "robocopy " + "$CurrentDir\Libraries\AppServer\Libraries\ " +  "$InstallPath\SystemMain /E /COPY:DT /R:0 /W:5 /tee /log+:$CurrentDir\installAppServer.log"
  Invoke-Expression -Command:$InstallCommand
  $InstallCommand = "robocopy " + "$CurrentDir\Libraries\AppServer\Config\ " +  "$InstallPath\Config /E /COPY:DT /R:0 /W:5 /tee /log+:$CurrentDir\installAppServer.log"
  Invoke-Expression -Command:$InstallCommand
	Write-StepFinished "Instalace nových a upravených souborù / knihoven (node1)"

  if($appSettings['AppServerInstallPath2']){
	  Write-StepStarted "Instalace nových a upravených souborù / knihoven (node2)"
	  $InstallPath = $appSettings['AppServerInstallPath2']
      $InstallCommand = "robocopy " + "$CurrentDir\Libraries\AppServer\Libraries\ " +  "$InstallPath\SystemMain /E /COPY:DT /R:0 /W:5 /tee /log+:$CurrentDir\installAppServer.log"
      Invoke-Expression -Command:$InstallCommand
      $InstallCommand = "robocopy " + "$CurrentDir\Libraries\AppServer\Config\ " +  "$InstallPath\Config /E /COPY:DT /R:0 /W:5 /tee /log+:$CurrentDir\installAppServer.log"
      Invoke-Expression -Command:$InstallCommand
	  Write-StepFinished "Instalace nových a upravených souborù / knihoven (node2)"
  }

	Write-StepFinished "Instalace nových a upravených souborù / knihoven"

	#Write-EmptyLine
	#Write-SectionDelimiter
	#Write-SectionHeader "PØEHLED ZMÌN"
	#List-Changes

# Post-Installation Actions
	Write-EmptyLine
	Write-SectionDelimiter
	Write-SectionHeader "SPUŠTÌNÍ POST-INSTALAÈNÍCH SKRIPTÙ"
#  RunAdditionalScripts("PostInstall")
  
# Done
	Write-MainFooter
}
Catch {
	Resolve-Error
}

