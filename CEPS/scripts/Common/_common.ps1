$global:width = 120
$global:stdColor = 7
$global:infoColor = 15
$global:successColor = 10
$global:pendingColor = 11
$global:warningColor = 14
$global:errorColor = 12
$global:subStepColor = 3
$global:sectionDelimiter = "========================================================================================================================"
$global:itemDelimiter    = "  --------------------------------------------------------------------------------------------------------------------"

function CoreOutToFileLogOnly {
	[CmdletBinding()]
    param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[string] $message
    )
	IF([string]::IsNullOrEmpty($logfile)) {
		Log("FILELOG not specified (=> logging to host): $message")	
	} else {
		Add-Content $logfile $message
	}
}

function CoreOutToLog {
	[CmdletBinding()]
    param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[object] $msgObject,
		[bool] $noTimeStamp = $false
    )
	$message = ""
	$timestamp = "0"
	$msgObject | Foreach-Object -Process {
		$message = ("{0}{1}") -f $message, $_.Message
		Write-Host $_.Message -NoNewLine -foregroundcolor $_.Color
	}
	if ($noTimeStamp -eq $false) {
		$timestamp = ([System.DateTime]::Now).ToString('HH:mm:ss.fff')
		Write-Host " ($timestamp)" -NoNewLine -foregroundcolor $stdColor
	}
	Write-Host ""
	if ($timestamp -eq "0") {
		Add-Content $logfile "$message"
	} else {
		Add-Content $logfile "$message ($timestamp)"
	}
}

function Log([string] $message) {
    Write-Host $message
}

function LogToFile([string] $message) {
  if (-not [string]::IsNullOrEmpty($message)) { $message | CoreOutToFileLogOnly }
}

function Write-EmptyLine {
	,@([PSCustomObject]@{Message="";Color=$stdColor}) | CoreOutToLog -noTimeStamp $true 
}

function Write-SectionDelimiter {
	,@([PSCustomObject]@{Message=$sectionDelimiter;Color=$stdColor}) | CoreOutToLog -noTimeStamp $true 
}

function Write-ItemDelimiter {
	,@([PSCustomObject]@{Message=$itemDelimiter;Color=$stdColor}) | CoreOutToLog -noTimeStamp $true 
}

function Write-StandardMessage ([string] $message) {
	,@([PSCustomObject]@{Message=$message;Color=$stdColor}) | CoreOutToLog -noTimeStamp $true
}

function Write-InfoMessage ([string] $message) {
	,@([PSCustomObject]@{Message=$message;Color=$infoColor}) | CoreOutToLog -noTimeStamp $true
}

function Write-WarningMessage ([string] $message) {
	,@([PSCustomObject]@{Message=$message;Color=$warningColor}) | CoreOutToLog -noTimeStamp $true
}

function Write-ErrorMessage ([string] $message) {
	,@([PSCustomObject]@{Message=$message;Color=$errorColor}) | CoreOutToLog -noTimeStamp $true
}

function Write-SubStepMessage ([string] $message) {
	,@([PSCustomObject]@{Message=$message;Color=$subStepColor}) | CoreOutToLog -noTimeStamp $true
}

function Set-ConsolePosition ([int]$x) { 
	# Get current cursor position and store away 
	$position=$host.ui.rawui.cursorposition 
	# Store new X Co-ordinate away 
	$position.x=$x 
	# Place modified location back to $HOST 
	$host.ui.rawui.cursorposition=$position 
}

function Write-InstallationDescription {
  param (
	  [string] $app,
	  [string] $version
  )    
	$InstallationDescriptionMidTextFixedLength = $width - (2 + $app.length + $version.length + 2) 
	Write-InfoMessage $("  {0}{1,$InstallationDescriptionMidTextFixedLength}{2}  " -f $app, "Version: ", $version)
}

function Write-MainHeader {
  param (
	  [string] $app,
	  [string] $version
  )    

	Write-SectionDelimiter 
	Write-EmptyLine

	Write-InstallationDescription $app $version

	Write-EmptyLine 
	Write-SectionDelimiter
	Write-EmptyLine 

	Write-StandardMessage $("  Started at: {0}" -f ([System.DateTime]::Now).ToString("dd.MM.yyyy HH:mm:ss")) 
	Write-StandardMessage $("  Script: {0}" -f $ScriptName) 
	Write-StandardMessage $("  Executed from directory: {0}" -f $(Get-Location).Path) 

	Write-EmptyLine
	Write-SectionDelimiter
}

function Write-MainFooter {
  param (
	  [string] $app,
	  [string] $version
  )    
	Write-EmptyLine 
	Write-SectionDelimiter
	Write-SectionHeader "INSTALLATION FINISHED" 

	Write-StandardMessage $("    Finished at: {0}" -f ([System.DateTime]::Now).ToString("dd.MM.yyyy HH:mm:ss")) 	
	Write-StandardMessage $("    Log: {0}" -f $logfile) 

	Write-EmptyLine
	Write-SectionDelimiter
}

function Write-SectionHeader {
  param (
	  [string] $name
  )    
	Write-EmptyLine 
	,@([PSCustomObject]@{Message="  $name";Color=$infoColor}) | CoreOutToLog -noTimeStamp $true 	
	Write-EmptyLine 
}

$global:waitCycle = 0
function Wait-Working {
  param (
	  [int] $position = 0,
	  [int] $sleep = 100
  )
	Set-ConsolePosition $position
	switch ($global:waitCycle) {
		0  { Write-Host "|" -NoNewLine; $global:waitCycle = 1; break; }
		1  { Write-Host "/" -NoNewLine; $global:waitCycle = 2; break; }
		2  { Write-Host "-" -NoNewLine; $global:waitCycle = 3; break; }
		3  { Write-Host "\" -NoNewLine; $global:waitCycle = 0; break; }
	}
	Start-Sleep -milliseconds $sleep
}

function Write-StepStarted ([string] $message) {
	Set-ConsolePosition 0
	,@([PSCustomObject]@{Message="    ... ";Color=$stdColor},[PSCustomObject]@{Message=$message;Color=$stdColor},[PSCustomObject]@{Message=" [";Color=$stdColor},[PSCustomObject]@{Message="STARTED";Color=$pendingColor},[PSCustomObject]@{Message="]";Color=$stdColor}) | CoreOutToLog
}

function Write-StepFinished ([string] $message) {
	Set-ConsolePosition 0
	,@([PSCustomObject]@{Message="    ... ";Color=$stdColor},[PSCustomObject]@{Message=$message;Color=$stdColor},[PSCustomObject]@{Message=" [";Color=$stdColor},[PSCustomObject]@{Message="FINISHED";Color=$successColor},[PSCustomObject]@{Message="]";Color=$stdColor}) | CoreOutToLog
	Write-EmptyLine
}

function IsNotDirectory {
  param (
      $path = $(throw "path is a required parameter")
  )
	return -not (Test-Path $path  -pathType container)
}

function Edit-XmlNodes {
  param (
    [xml] $doc = $(throw "doc is a required parameter"),
    [string] $xpath = $(throw "xpath is a required parameter"),
    [string] $value = $(throw "value is a required parameter"),
    [bool] $condition = $true
  )    
  
  if ($condition -eq $true) {
    $nodes = $doc.SelectNodes($xpath)
    if (!$nodes -or $nodes -eq "" -or $nodes.count -eq 0)  { throw "No element not found for XPATH: $xpath"}       
    foreach ($node in $nodes) {
      if ($node -ne $null) {
        if ($node.NodeType -eq "Element") {
          $node.InnerXml = $value 
        }
        else {
          $node.Value = $value
        }
      }
    }
  }
}

function Remove-XmlNodes {
  param (
      [xml] $doc = $(throw "doc is a required parameter"),
      [string] $xpath = $(throw "xpath is a required parameter")
  )    
    
	$doc | Select-Xml -XPath $xpath | 
		Foreach {$_.Node.ParentNode.RemoveChild($_.Node)} | Out-Null
}

function Get-ListOfDifferentFiles {
  param (
	  [string] $left = $(throw "left is a required parameter"),
	  [string] $right = $(throw "right is a required parameter")
  )

	$listOfMissingFiles = New-Object System.Collections.ArrayList
	$listOfChangedFiles = New-Object System.Collections.ArrayList
	$listsOfFiles = New-Object System.Collections.ArrayList
	$leftPath = $left.TrimEnd('\\');
	$fullLeftPath = (Get-Item -Path $leftPath).FullName 
	$rightPath = $right.TrimEnd('\\');
	$fullRightPath = (Get-Item -Path $rightPath).FullName
	$chitems =  Get-ChildItem -Path $fullLeftPath -Recurse | Where-object {IsNotDirectory($_)} | sort fullname
	$i = 0
	foreach ($item in $chitems) {		
		$i = $i + 1
    $fullFilePath = $($item.FullName)
		$cnt = $chitems.count
		Set-ConsolePosition $position
    $relFilePath = $fullFilePath.Substring($fullLeftPath.Length + 1, $fullFilePath.Length - $fullLeftPath.Length - 1)
		Write-Host "          $i/$cnt ($relFilePath)                                                             " -NoNewLine -foregroundcolor 3
		$tmpResult = . $CurrentDir\Scripts\Tools\FileCompare\EnifFileCompare.exe $fullFilePath $fullRightPath\$relFilePath
		if ($LASTEXITCODE -eq 1) {
			$tmp = $listOfChangedFiles.Add($relFilePath)
		}
		if ($LASTEXITCODE -eq 2) {
			$tmp = $listOfChangedFiles.Add($relFilePath)
			#$pdbFilePath = $relFilePath.replace(".dll",".pdb")
			#$tmp = $listOfChangedFiles.Add($pdbFilePath)
		}
		if ($LASTEXITCODE -eq -1) {
			$tmp = $listOfMissingFiles.Add($relFilePath)
		}
	}	
	Set-ConsolePosition 0
	$tmp = $listsOfFiles.Add($listOfChangedFiles)
	$tmp = $listsOfFiles.Add($listOfMissingFiles)
	$listsOfFiles
}

function List-Changes {
	$i = 0
	foreach ($file in $listsOfFiles[0][0]) {
		Write-SubStepMessage "          [Updated]: $file"
		$i++
	}
	if ($listsOfFiles[1]) {
		foreach ($file in $listsOfFiles[1][0]) {
			Write-SubStepMessage "          [Updated]: $file"
			$i++
		}
	}
	foreach ($file in $listsOfFiles[0][1]) {
		Write-SubStepMessage "          [New]: $file"
		$i++
	}
	if ($listsOfFiles[1]) {
		foreach ($file in $listsOfFiles[1][1]) {
			Write-SubStepMessage "          [New]: $file"
			$i++
		}
	}
	if ($i -eq 0) {Write-SubStepMessage "          no new or changed files"}
}

function Get-VersionDir {
  param (
	  [string] $str
  )
	$aStr = $str.Split('.')
	[long] $l1 = $aStr[0]
	[long] $l2 = $aStr[1]
	[long] $l3 = $aStr[2]
	[long] $l4 = $aStr[3]

	$versionDir = $l1.ToString("D2") + "." + $l2.ToString("D3") + "." + $l3.ToString("D4") + "." + $l4.ToString("D5");

	$versionDir
}

function Get-FilesToBackup {
  param (
    [string] $src, # source directory
    [string] $dst  # target directory
  )
  $files = New-Object System.Collections.ArrayList
  $args = Get-ArgumentListForRobocopy $src $dst
  $i=0
	$arguments = $args[0], $args[1], $args[2], $args[3], "/NP", "/NJH", "/NJS" , "/FP", "/NDL", "/L", "/XX", "/NS", "/NC", "/XL"
	. robocopy.exe $arguments | ForEach-Object { 
    if ($_.Trim() -ne "") { 
      $files.Add($_.Trim().Substring($src.Length+1)) | Out-Null
    }
  }
  $files
}

function BackUp-ChangedFiles {
  param (
    [string] $src, # source directory
    [string] $dst, # target directory
    [string] $bck,  # backup directory
    [string] $info # backup info
  )
  	$files = Get-FilesToBackup $src $dst
		foreach ($file in $files){      
			SimpleCopy-DirsAndFiles "$dst\$file" "$bck\$file" | Out-Null
		}
    Write-SubStepMessage "        ... $($files.Count) file(s) backed up $info"
}

function Deploy-FilesFromDirectory {
  param (
    [string] $src, # source directory
    [string] $dst # target directory
  )
		SimpleCopy-DirsAndFiles $src $dst
}



function Move-DirsAndFiles {
	param (
		[string] $from,   # source directory or source file (directory is allways copied recursively)
		[string] $to     # target directory or target file (target filename has to be the same as source)
	)
	Copy-DirsAndFiles "$from" "$to"
}

function Get-ArgumentListForRobocopy {
	param (
		[string] $from,       # source directory or source file (directory is allways copied recursively)
		[string] $to,         # destination directory (allways directory!!!)
		[string] $move = ""   # any value triggers move operation
	)
  $argumentList = ""

	$moveOption = ""
	if (-not ($move -eq "" -and $move -eq [String]::Empty)) { $moveOption = "/MOVE"	}

	$sourcePath = $from.TrimEnd('\\');
	$targetPath = $to.TrimEnd('\\');
	$fullFromPath = (Get-Item -Path $sourcePath).FullName 
	$fullToPath = $targetPath
	if (IsNotDirectory($fullFromPath)) {
		$pathElements = $fullFromPath.Split('\\')
		$fileName = $pathElements[$pathElements.Length - 1]
		$sourceDirectory = $fullFromPath.SubString(0,$fullFromPath.Length-$fileName.Length).TrimEnd('\\');
		if ($fullToPath -like "*$fileName") {
			$targetDirectory = $fullToPath.SubString(0,$fullToPath.Length-$fileName.Length).TrimEnd('\\');
		} else {
			$targetDirectory = $fullToPath.TrimEnd('\\');
		}
		$argumentList =  @($sourceDirectory,$targetDirectory,$fileName,"$moveOption",$logfile)

	} else {
		$argumentList =  @($fullFromPath,$targetPath,"/E",$moveOption,$logfile)
	}
  $argumentList
}

function SimpleCopy-DirsAndFiles {
	param (
		[string] $from,       # source directory or source file (directory is allways copied recursively)
		[string] $to,         # destination directory (allways directory!!!)
		[string] $move = ""   # any value triggers move operation
	)

	$argumentList = Get-ArgumentListForRobocopy $from $to $move

  $njs = ""; $njh = ""; $nc = "";
  if ($argumentList[2] -ne "/E") { 
    $njh = "/NJH"; $njs = "/NJS"; $nc = "/NC"; 
  }
  	if($global:logfile){
		$tee = "/tee"
		$log = "/log+:$global:logfile"
	}
	
	$arguments = $argumentList[0], $argumentList[1], $argumentList[2], $argumentList[3], "/COPY:DT", "/R:0", "/W:5", "/NP", "/FP", "/XX", "/NDL", "/NS", $nc, $njh, $njs, $tee, $log
	
	. robocopy.exe $arguments | findstr /r /v "^$"

}

function Copy-DirsAndFiles { # asynchronní
	param (
		[string] $from,       # source directory or source file (directory is allways copied recursively)
		[string] $to,         # destination directory (allways directory!!!)
		[string] $move = ""   # any value triggers move operation
	)
	
	$argumentList = Get-ArgumentListForRobocopy $from $to $move
	
	# Execute Robocopy
	#LogToFile "          robocopy.exe $($argumentList[0]) $($argumentList[1]) $($argumentList[2]) $($argumentList[3])"
	$rbJob = Start-Job -ArgumentList $argumentList -ScriptBlock  {	
		function CoreOutToFileLogOnly {
			[CmdletBinding()]
			param(
				[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
				[string] $message
			)
			IF([string]::IsNullOrEmpty($logfile)) {
				Log("FILELOG not specified (=> logging to host): $message")	
			} else {
				Add-Content $logfile $message
			}
		}
		function LogToFile([string] $message)
		{
			$message | CoreOutToFileLogOnly
		}
		$logfile = $args[4]
		$arguments = $args[0], $args[1], $args[2], "/IS", $args[3], "/NP", "/NJH", "/NJS" ,"/TS", "/FP", "/NDL"
		. robocopy.exe $arguments | ForEach-Object { LogToFile $_ }
	}
    Start-Sleep -Milliseconds 100;
    while ($rbJob.State -eq "Running") {
		Wait-Working -position 4
    }
}

function Get-OraDeploymentSummary {
	param (
		[string] $rootPath = $(throw "rootPath is a required parameter")
	)
	$count = -1
  $total = 0
	Get-ChildItem -path $rootPath -recurse -Include *.txtspool | ForEach-Object -Process {
		$lastLine = -1
		$count = 0
		$listOfErrors = Select-String -Path $_.FullName -Pattern '(ORA-|SP2-)' 
		$listOfErrors | ForEach-Object -Process {
			if ($lastLine + 1 -ne $_.LineNumber) {
				$count = $count + 1
			}
			$lastLine = $_.LineNumber
		}
		
    $total += $count
		if ($count -gt 0) {
			Write-WarningMessage "          $($_.Name) - [Errors: $count]"
			$listOfErrors | ForEach-Object -Process {
				Write-SubStepMessage "            $_"				
			}
			
		} else { 
			Write-StandardMessage "          $_.Name - [Errors: 0]"
		}
	}

	if ($count -eq -1) {
		Write-StandardMessage "        no scripts deployed"
	}

  $total 
}

function Resolve-Error ($ErrorRecord=$Error[0]) {
	Write-EmptyLine
	Write-ErrorMessage "ERROR:"
	Write-ErrorMessage "-------"

	# get error object
	$value = $ErrorRecord.InvocationInfo.MyCommand
	Write-ErrorMessage "Command: $value"
	Write-EmptyLine
	$value = $ErrorRecord.InvocationInfo.PositionMessage
	Write-ErrorMessage "Line: $value"
	Write-EmptyLine
	$value = $ErrorRecord.Exception
	Write-ErrorMessage "Exception: $value"
	
	$innerEx = @{}
	# get inner exception
	$Exception = $ErrorRecord.Exception
	for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
	{  
		Write-EmptyLine
		Write-ErrorMessage "INNER EXCEPTION #$i"
		Write-ErrorMessage "-------------------"
		$value = $Exception.Messagen
		Write-ErrorMessage "Message: $value"
		Write-EmptyLine
		$value = $Exception.HResult
		Write-ErrorMessage "HResult: $value"
		Write-EmptyLine
		$value = $Exception.StackTrace
		Write-ErrorMessage "StackTrace: $value"
	}
	Write-EmptyLine
  Exit -1
}

function RunAdditionalScripts([string] $Type){

  $flagForScript = $false
  $tempScriptArray = @()
  [array]$InstallScripts = Get-ChildItem -Path "$CurrentDir\Scripts\$Type\*.ps1"
  $testOfScriptPath = Test-Path "$InstallPath\deployed_scripts.info"
  if ($testOfScriptPath) {
    [array]$alreadyExecutedScripts = Get-Content -Path "$InstallPath\deployed_scripts.info" 
	for($i=0; $i -lt $InstallScripts.Length; $i++){
		for($j=0; $j -lt $alreadyExecutedScripts.Length; $j++){
			if($InstallScripts[$i].name -eq $alreadyExecutedScripts[$j]){
				$flagForScript = $true
				Break
			}
		}
		if( -not $flagForScript){
        $tempScriptArray +=  $InstallScripts[$i].name
		}
		else{
			$flagForScript=$false
		}
	}
  }
  else{
	for($i=0; $i -lt $InstallScripts.Length; $i++){
		$tempScriptArray += $InstallScripts[$i].name
	}
  }
  if($tempScriptArray.Length -ne 0){
	$erroractionpreference = 'stop'
	for($i=0; $i -lt $tempScriptArray.Length; $i++){
		$scriptName = $tempScriptArray[$i]
		$InstallPathTmp = $InstallPath
		Write-SubStepMessage "         [Running script]: $scriptName"
		try{
			. "$CurrentDir\Scripts\$Type\$scriptName" $InstallPath
		}catch{
			Write-SubStepMessage "An error occured during the script execution. However script was marked as executed."
		}
		$scriptName | Add-Content "$InstallPathTmp\deployed_scripts.info"
		$InstallPath = $InstallPathTmp
  		Write-SubStepMessage "         [Finished]: $scriptName"
	}
	$erroractionpreference = 'continue'
  }
  else{
	  Write-StandardMessage "        Nebyly nalezeny žádné $Type skripty k nasazení"
  }
}