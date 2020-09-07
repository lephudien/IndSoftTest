######################################################################################
#     C O R E
######################################################################################
function Update-ConfigParam {
param (
	[xml] $xmlDoc,
	[string] $parameter,
	[parameter(Mandatory=$false,ValueFromRemainingArguments=$true)]
    [String[]] $args
)  
  Write-Host $parameter
	$xpathParameter = "XPath$parameter"
	$xpath = $appSettings[$xpathParameter]
	$value = $appSettings[$parameter]
	$value = $value.Replace(">","&gt;")
	$value = $value.Replace("<","&lt;")
	if ($args -and $args.count -gt 0) { $value = $($value -f $args) }
	Edit-XmlNodes $xmlDoc $xpath $value
	Write-SubStepMessage "          [$parameter]: $value"
}

######################################################################################
#     W P F   C L I E N T
######################################################################################

function Update-DenebClient-Machine_Setting {  
	Write-StepStarted "Úprava souboru 'Config\Machine_setting.xml'"
	$encoding = [System.Text.Encoding]::GetEncoding($encodingCode)
	[string] $xmlStr = [System.IO.File]::ReadAllText("$EnvTargetConfigDir\Machine_setting.xml", $encoding)
	[xml] $xmlDoc = New-Object System.XML.XMLDocument
	$xmlDoc.PreserveWhitespace = $true
	$xmlDoc.LoadXml($xmlStr)

	# Install Version
	$xpath = $appSettings['XPathKlientMachineMachineSettingSegGuiInstallNumber']
	Edit-XmlNodes $xmlDoc $xpath $PackageVersion
	# Install Number
	$xpath = $appSettings['XPathKlientMachineMachineSettingSegGuiInstallVersion']
	Edit-XmlNodes $xmlDoc $xpath ""

	Update-ConfigParam $xmlDoc "KlientMachineMachineSettingDeneb2ClientServerAdress"

	[System.IO.File]::WriteAllLines("$EnvTargetConfigDir\Machine_setting.xml", $xmlDoc.OuterXml, $encoding)
	Write-StepFinished "Úprava souboru 'Config\Machine_setting.xml'"
}

function Update-DenebClient-ApplicationConfig {  
	Write-StepStarted "Úprava souboru 'Config\ApplicationConfig.xml'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\ApplicationConfig.xml"

    Update-ConfigParam $xmlDoc "KlientApplicationConfigLogFolder"

	$xmlDoc.Save("$InstallMainTempDir\ApplicationConfig.xml")
	gc -en utf8 "$InstallMainTempDir\ApplicationConfig.xml" | sc -en utf8 "$EnvTargetConfigDir\ApplicationConfig.xml"
	Remove-Item "$InstallMainTempDir\ApplicationConfig.xml" -recurse -force | out-null
	Write-StepFinished "Úprava souboru 'Config\ApplicationConfig.xml'"
}

######################################################################################
#     A P P   S E R V E R
######################################################################################
function Update-AppServer-EnifConfig {  
	Write-StepStarted "Úprava souboru 'Config\EnifConfig.xml'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\EnifConfig.xml"

	# Lancelot Server IP Address
	Update-ConfigParam $xmlDoc "ServerEnifConfigListeningAddress"
	

	# Lancelot Server Caption 
	Update-ConfigParam $xmlDoc "ServerEnifConfigCopyAdapterConnectionSettingsAddress"
	
	# Connnections To DB
	if(($appSettings['ServerEnifConfigOmSumTddIntervalSec'] -eq "NO") -and ($appSettings['ServerEnifConfigOmSumTddStartAt'] -eq "NO")){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigDeleteOmSumTdd']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerEnifConfigOmSumTddIntervalSec"
		Update-ConfigParam $xmlDoc "ServerEnifConfigOmSumTddStartAt"
	}

	# Modules Configuration
	Update-ConfigParam $xmlDoc "ServerEnifConfigImportOMConsFrom"
	Update-ConfigParam $xmlDoc "ServerEnifConfigEntityCoreMainEnifConnectionString"

    Update-ConfigParam $xmlDoc "ServerEnifConfigEntityCoreMainEnifDefaultSchema"
    Update-ConfigParam $xmlDoc "ServerEnifConfigEntityCoreMainNPSConnectionString"
    Update-ConfigParam $xmlDoc "ServerEnifConfigEntityCoreMainNPSDefaultSchema"

	if($appSettings['ServerEnifConfigCANotifyFilterView'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigCANotifyFilterView']
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigCANotifyFilterData']
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigAddMYCopiesF35708']
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigAddMYCopiesF35445']
	}

	Update-ConfigParam $xmlDoc "ServerEnifConfigPRETTSSPODiagsInputPath"
	Update-ConfigParam $xmlDoc "ServerEnifConfigPRETTSSPOCacheSyncView"
	Update-ConfigParam $xmlDoc "ServerEnifConfigPRETTSR02"

	if($appSettings['ServerEnifConfigPRETTS2Delete'] -eq "Yes"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigPRETTS2Delete']
	}else{
		Update-ConfigParam $xmlDoc "ServerEnifConfigPRETTS2SPODiagsInputPath"
	}

	if($appSettings['ServerEnifConfigTTSTimerModule2Delete'] -eq "Yes"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigTTSTimerModule2Delete']
	}

	if($appSettings['ServerEnifConfigPRETTSPXTDataPumpOff'] -eq "Yes"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigPRETTSSyncDataPXT']
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigPRETTSCheckPXTCheckPXTPlan']
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerEnifConfigPRETTSCheckPXTPredictionPlan']
	}

	$xmlDoc.Save("$InstallMainTempDir\EnifConfig.xml")
	gc -en utf8 "$InstallMainTempDir\EnifConfig.xml" | sc -en utf8 "$EnvTargetConfigDir\EnifConfig.xml"
	Remove-Item "$InstallMainTempDir\EnifConfig.xml" -recurse -force | out-null
	Write-StepFinished "Úprava souboru 'Config\EnifConfig.xml'"
}

function Update-AppServer-Deneb2ServiceExe {  
	Write-StepStarted "Úprava souboru '\Libraries\deneb2service.exe.config'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\..\Libraries\deneb2service.exe.config"


    Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeDBName"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeDBLogin"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeLogFile"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeLogClients"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeHromAdmin"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeMaxAdminUsers"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeRootFolderCaption"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeMaxConnectionsPerUser"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeNotifyQueueSizeLimit"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeNotifyQueueLoadFileCount"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExePasswordPolicyEnabled"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeTreeBckgColor"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeTreeBckgColorAllUsers"
	Update-ConfigParam $xmlDoc "ServerDeneb2ServiceExeLogErrorsToDB"

	$xmlDoc.Save("$InstallMainTempDir\..\Libraries\deneb2service.exe.config")
	gc -en utf8 "$InstallMainTempDir\..\Libraries\deneb2service.exe.config" | sc -en utf8 "$EnvTargetConfigDir\..\Libraries\deneb2service.exe.config"
	Remove-Item "$InstallMainTempDir\..\Libraries\deneb2service.exe.config" -recurse -force | out-null
	Write-StepFinished "Úprava souboru '\Libraries\deneb2service.exe.config'"
}

function Update-AppServer-WatchDogDeneb2 {  
	Write-StepStarted "Úprava souboru '\Libraries\WatchDog_Deneb2.exe.config'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\..\Libraries\WatchDog_Deneb2.exe.config"

	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DenebServiceName"
    Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceCheckIgnore"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2MailSubject"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2SendLogMailSubject"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2StartCheckTimeOut"

	if($appSettings['ServerWatchDogDeneb2StartCheckFinalTimeOut'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerWatchDogDeneb2StartCheckFinalTimeOut']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2StartCheckFinalTimeOut"
	}

	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2StopCheckTimeOut"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2OutageBegin"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2OutageEnd"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceLimit_C"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceLimit_K"

	if($appSettings['ServerWatchDogDeneb2DiskSpaceLimit_P'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerWatchDogDeneb2DiskSpaceLimit_P']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceLimit_P"
	}

	
	if($appSettings['ServerWatchDogDeneb2DiskSpaceLimitDelta_P'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerWatchDogDeneb2DiskSpaceLimitDelta_P']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceLimitDelta_P"
	}

	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceMailSubject"
	Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2DiskSpaceMailTo"

	if($appSettings['ServerWatchDogDeneb2StartRetryCount'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerWatchDogDeneb2StartRetryCount']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerWatchDogDeneb2StartRetryCount"
	}

	$xmlDoc.Save("$InstallMainTempDir\..\Libraries\WatchDog_Deneb2.exe.config")
	gc -en utf8 "$InstallMainTempDir\..\Libraries\WatchDog_Deneb2.exe.config" | sc -en utf8 "$EnvTargetConfigDir\..\Libraries\WatchDog_Deneb2.exe.config"
	Remove-Item "$InstallMainTempDir\..\Libraries\WatchDog_Deneb2.exe.config" -recurse -force | out-null
	Write-StepFinished "Úprava souboru '\Libraries\WatchDog_Deneb2.exe.config'"
}


function Update-AppServer-ApplicationConfig {  
	Write-StepStarted "Úprava souboru 'Config\ApplicationConfig.xml'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\ApplicationConfig.xml"

    Update-ConfigParam $xmlDoc "ServerApplicationConfigCLogAllFolder"
    Update-ConfigParam $xmlDoc "ServerApplicationConfigCLogWarningFolder"

	if($appSettings['ServerApplicationConfigLogDisposingProxyAtSink'] -eq "false"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerApplicationConfigLogDisposingProxyAtSink']
	}
    

	# Resource Lock Mode

	$xmlDoc.Save("$InstallMainTempDir\ApplicationConfig.xml")
	gc -en utf8 "$InstallMainTempDir\ApplicationConfig.xml" | sc -en utf8 "$EnvTargetConfigDir\ApplicationConfig.xml"
	Remove-Item "$InstallMainTempDir\ApplicationConfig.xml" -recurse -force | out-null
	Write-StepFinished "Úprava souboru 'Config\ApplicationConfig.xml'"
}

function Update-AppServer-TreeConfigDeneb2DataTree {  
	Write-StepStarted "Úprava souboru 'Config\TreeConfigDeneb2DataTree.xml'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\TreeConfigDeneb2DataTree.xml"

    Update-ConfigParam $xmlDoc "ServerTreeConfigDeneb2DataTreeTTS1AId"

	if($appSettings['ServerTreeConfigDeneb2DataTreeTTS2AId'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerTreeConfigDeneb2DataTreeTTS2Delete']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerTreeConfigDeneb2DataTreeTTS2AId"
	}
    
	$xmlDoc.Save("$InstallMainTempDir\TreeConfigDeneb2DataTree.xml")
	gc -en utf8 "$InstallMainTempDir\TreeConfigDeneb2DataTree.xml" | sc -en utf8 "$EnvTargetConfigDir\TreeConfigDeneb2DataTree.xml"
	Remove-Item "$InstallMainTempDir\TreeConfigDeneb2DataTree.xml" -recurse -force | out-null
	Write-StepFinished "Úprava souboru 'Config\TreeConfigDeneb2DataTree.xml'"
}

function Update-AppServer-TreeConfigDeneb2ViewTree {  
	Write-StepStarted "Úprava souboru 'Config\TreeConfigDeneb2ViewTree.xml'"
	[xml] $xmlDoc = gc -en utf8 "$EnvTargetConfigDir\TreeConfigDeneb2ViewTree.xml"

    Update-ConfigParam $xmlDoc "ServerTreeConfigDeneb2ViewTreeTTS1AId"

	if($appSettings['ServerTreeConfigDeneb2ViewTreeTTS2AId'] -eq "NO"){
		Remove-XmlNodes $xmlDoc $appSettings['XPathServerTreeConfigDeneb2ViewTreeTTS2Delete']
	}
	else{
		Update-ConfigParam $xmlDoc "ServerTreeConfigDeneb2ViewTreeTTS2AId"
	}
    
	$xmlDoc.Save("$InstallMainTempDir\TreeConfigDeneb2ViewTree.xml")
	gc -en utf8 "$InstallMainTempDir\TreeConfigDeneb2ViewTree.xml" | sc -en utf8 "$EnvTargetConfigDir\TreeConfigDeneb2ViewTree.xml"
	Remove-Item "$InstallMainTempDir\TreeConfigDeneb2ViewTree.xml" -recurse -force | out-null
	Write-StepFinished "Úprava souboru 'Config\TreeConfigDeneb2ViewTree.xml'"
}