Try {
#Directory structure settings
	$ErrorActionPreference = "stop"
	$ScriptName = $MyInvocation.MyCommand.Path
	$CurrentDir = Split-Path $MyInvocation.MyCommand.Path
	$global:logfile = "$CurrentDir\installDatabase.log"

# Load Scripts
	. $CurrentDir\Scripts\Common\_common.ps1

	$PackageVersion     = Get-Content -Path "$CurrentDir\Configuration\version.info"
	Write-MainHeader "Lancelot Trading Predikce (PRE); (Database)" $PackageVersion

# Load Environment Configuration
	$EnvConfigFile = "$CurrentDir\config.xml"
	$global:appSettings = @{}
	. $CurrentDir\Scripts\Common\_loadConfig.ps1 $EnvConfigFile

	Write-SectionHeader "INSTALACE"

# Install Database Changes
	cd "$CurrentDir\Database"
	$SqlPlusConnectionString = $appSettings['SqlPlusConnectionString']

	Write-StepStarted "Instalace zmìnových skriptù (Databáze - $SqlPlusConnectionString)"

	. .\Common\Install.ps1 "$SqlPlusConnectionString"
	cd $CurrentDir

	Write-StepFinished "Instalace zmìnových skriptù (Databáze - $SqlPlusConnectionString)"
	Write-EmptyLine
	
	Write-SectionDelimiter
	Write-SectionHeader "VÝSLEDEK INSTALACE"
	$errCount = Get-OraDeploymentSummary "$CurrentDir\Database"

# Done
	Write-MainFooter
	Exit $errCount
}
Catch {
	Resolve-Error
}

