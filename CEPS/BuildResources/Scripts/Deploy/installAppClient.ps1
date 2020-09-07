Try {

# Error handling and logging settings
	$ErrorActionPreference = "stop"
	$ScriptName = $MyInvocation.MyCommand.Path
	$CurrentDir = Split-Path $ScriptName
	$global:logfile = "$CurrentDir\installDenebClient.log"

# Load Scripts
	. $CurrentDir\Scripts\Common\_common.ps1
	. $CurrentDir\Scripts\Common\_updateConfigs.ps1

# Prepare installation 1
	$app = "DenebClient"
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
	$EnvTargetConfigDir = "$CurrentDir\Libraries\DenebClient\Config"
	$InstallPath        = $appSettings['DenebClientInstallPath']
	Write-StepFinished "Naètení konfigurace instalace (InstallPath = '$InstallPath')"

# Update Config Files with Environment Specific Params
	Update-DenebClient-ApplicationConfig
	Update-DenebClient-Machine_Setting

# Prepare installation 2 (files) 
	Write-EmptyLine
	Write-SectionDelimiter
	Write-SectionHeader "PØÍPRAVA INSTALACE"
	
	Write-SectionHeader "INSTALACE"

# Install New Version
	Write-StepStarted "Instalace nových a upravených souborù / knihoven"
    $InstallCommand = "robocopy " + "$CurrentDir\Libraries\DenebClient\Libraries\ " +  "$InstallPath\ /E /COPY:DT /R:0 /W:5 /tee /log+:$CurrentDir\installDenebClient.log"
    Invoke-Expression -Command:$InstallCommand
	$InstallCommand = "robocopy " + "$CurrentDir\Libraries\DenebClient\Config\ " +  "$InstallPath\Config /E /COPY:DT /R:0 /W:5 /tee /log+:$CurrentDir\installDenebClient.log"
	Invoke-Expression -Command:$InstallCommand
   Write-StepFinished "Instalace nových a upravených souborù / knihoven"

	# List Changes Between the New and the Previous Version
	#Write-EmptyLine
	#Write-SectionDelimiter
	#Write-SectionHeader "PØEHLED ZMÌN"
	#List-Changes

# Done
	Write-MainFooter
}
Catch {
	Resolve-Error
}


