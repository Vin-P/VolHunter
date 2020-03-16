<#
.HELP
Version # 1.4
List of Environment Variables declared in Function Set-VHEnvironment
$elasticIp = "192.168.35.133",
$elasticPort = 9200,
$targetList = ".\targetlist.txt",
$investigated = ".\inv.txt",
$maxThreads = 10,
$volPath = (Get-Location).Path,
$basePath = "C:\Windows\CCM\Perf\VolH",
$plugins = @("malfind","ssdt","cmdline","dlllist","ldrmodules","netscan","psxview","timers","pslist"),
$onList = ".\OnList.txt",
$offList = ".\OffList.txt",
$humanReadable = "Not Currently Used",
$artifacts = "Not Currently Used",
$dumpMemory = "Not Currently Used",
$credName
$bPath = "Base = $basePath"
$bTools = "Tool = $basePath\Tools\"
$bImage = "Image = $basePath\Image\"
$bOutput = "Output = $basePath\Output\"
$bLog = "Log = $basePath\VHLog"
$bProfile = "Profile = $basePath\VolProfile.txt"
$bDone = "Done = $basePath\VolDone.txt"
List of env Variables
$env:ElasticIP = $elasticIp
$env:ElasticPort = $elasticPort
$env:TargetList = $targetList
$env:Investigated = $investigated
$env:MaxThreads = $maxThreads
$env:Plugins = $plugins
$env:HumanReadable = $humanReadable
$env:Artifacts = $artifacts
$env:DumpMemory = $dumpMemory
$env:BDirList = "$bPath, $bTools, $bImage, $bOutput, $bLog, $bProfile, $bDone"
$env:VolPath = $volPath
$env:GLogPath = $env:VolPath + "GatheredLogs\"
$env:VolPath + "\VHLogs\"
$env:OnList = $onList
$env:OffList = $offList
$global:Credential = Get-Credential $credName
Not currently being used
$env:ShareLetter = Test-VHShareName
$env:ShareName = $env:ShareLetter + ":"
#>

Function Display-VHEnvironment {
#The goal of this function is give the user a way to display the current Environment set up
	$myEnvValues = [PSCustomObject] @{
		"Elastic IP"	= $env:ElasticIP
		"Elastic Port"	= $env:ElasticPort
		"Target List" 	= $env:TargetList
		"Investigated"	= $env:Investigated
        "Max Threads"	= $env:MaxThreads
        "Plugins" 	    = $env:Plugins
        "HumanReadable"	= $env:HumanReadable
        "Artifacts"	    = $env:Artifacts
        "Dump Memory"	= $env:DumpMemory
		"Base Path" 	= $env:BDirList
        "Vol Path"	    = $env:VolPath
		"Gather Log"	= $env:GLogPath
		"Vol Log Path"	= $env:logPath
        "Onlist locate"	= $env:OnList
		"Offlistlocate"	= $env:OffList
	}
	
	<#Not Currently being used. If these are being used add them to the pscustom object above
		"Share Letter"	= $env:ShareLetter
		"Share Name"	= $env:ShareName
		
		"Base VH Path"	= $env:BPath
		"Image Path"	= $env:BImage
		"Tools Path"	= $env:BTools
		"Output Path"	= $env:BOutput
		"VH Log Path"	= $env:BVHlog
		"VHProfile Path"= $env:BVHProfile
		"Vol Done Path"	= $env:VolDonePath
	#>
	return $myEnvValues
}#End Function Display-VHEnvironment

Function Set-VHEnvironment {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,Position=0)]
			[String]$elasticIp = "192.168.35.133",
		[Parameter(Mandatory=$False,Position=1)]
			[Int]$elasticPort = 9200,
		[Parameter(Mandatory=$False,Position=2)]
			[String]$targetList = ".\targetlist.txt",
		[Parameter(Mandatory=$False,Position=3)]
			[String]$investigated = ".\inv.txt",
		[Parameter(Mandatory=$False,Position=4)]
			[Int]$maxThreads = 10,
		[Parameter(Mandatory=$False,Position=5)]
			[String]$volPath = (Get-Location).Path,
		[Parameter(Mandatory=$False,Position=6)]
			[String]$basePath = "C:\Windows\CCM\Perf\VolH",
		[Parameter(Mandatory=$False,Position=7)]
			[System.Collections.ArrayList]$plugins = @("malfind","ssdt","cmdline","dlllist","ldrmodules","netscan","psxview","timers","pslist"),
		[Parameter(Mandatory=$False,Position=8)]
			[String]$onList = ".\OnList.txt",
		[Parameter(Mandatory=$False,Position=9)]
			[String]$offList = ".\OffList.txt",
		[Parameter(Mandatory=$False,Position=11)]
			[String]$humanReadable = "Not Currently Used",
		[Parameter(Mandatory=$False,Position=12)]
			[String]$artifacts = "Not Currently Used",
		[Parameter(Mandatory=$False,Position=13)]
			[String]$dumpMemory = "Not Currently Used",
		[Parameter(Mandatory=$True,Position=14)]
			[String]$credName
	)
	Process {
		try {
			$bPath = "Base = $basePath\"
			$bTools = "Tool = $basePath\Tools\"
			$bImage = "Image = $basePath\Image\"
			$bOutput = "Output = $basePath\Output\"
			$bLog = "Log = $basePath\VHLog"
			$bProfile = "Profile = $basePath\VolProfile.txt"
			$bDone = "Done = $basePath\VolDone.txt"
			
			$env:ElasticIP = $elasticIp
			$env:ElasticPort = $elasticPort
			$env:TargetList = $targetList
			$env:Investigated = $investigated
			$env:MaxThreads = $maxThreads
			$env:Plugins = $plugins
			$env:HumanReadable = $humanReadable
			$env:Artifacts = $artifacts
			$env:DumpMemory = $dumpMemory
			$env:BDirList = "$bPath, $bTools, $bImage, $bOutput, $bLog, $bProfile, $bDone"
			$env:VolPath = $volPath
			$env:GLogPath = $env:VolPath + "\GatheredLogs\"
			$env:logPath = $env:VolPath + "\VHLogs\"
			$env:OnList = $onList
			$env:OffList = $offList
			$global:Credential = Get-Credential $credName
						
			<# Not currently being used
			$env:ShareLetter = Test-VHShareName
			$env:ShareName = $env:ShareLetter + ":"
			
			$env:BPath = $basePath
			$env:BImage = $env:BPath + "Image\"
			$env:BTools = $env:BPath + "Tools\"
			$env:BOutput = $env:BPath + "Output\"
			$env:BVHlog = $env:BPath + "VHLog"
			$env:BVHProfile = $env:BPath + "VolProfile.txt"
			$env:BDonePath = $env:BPath + "VolDone.txt"
			#>
		} catch {
			Write-Error -Message "$_ Set-VHEnvironment failed"
		}
	}
}#End Function Set-VHEnvironment

Function Parse-BasePath {
	Process {	
		[hashtable]$table = @{}
		$pathLists = $env:BDirList.Split(",")
		foreach ($item in $pathLists) {
			$key,$path = ($item.split("=")).trim()
			if ($key -in $table.keys) {
				$table[$key] = $path
			
			} else {
				$table.add($key, $path)
				
			}
		}
		return $table
		
	}
}#End Function Parse-BasePath

Function Parse-Plugins {
	Process {
		$hPlugins = ($env:Plugins.split(" ")).Trim()
		return $hPlugins

	}
}#End Function Parse-Plugins

<#
Function Modify-Plugins { Currently not working as intended. Currently lower priority 
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,Position=0)]
			[System.Collections.ArrayList]$addPlugins = @(),
		[Parameter(Mandatory=$False,Position=2)]
			[System.Collections.ArrayList]$removePlugins = @(),
		[Parameter(Mandatory=$False,Position=3)]
			[Switch]$replacePlugins = $False
	)
	#The goal of this function is to modify the plugins list using command line inputs
	$basePlugins = Parse-Plugins
		
	if ($replacePlugins -and $addplugins) {
		$basePlugins = $addPlugins
	
	} elseif ($addPlugins) {
		$basePlugins.Add($addPlugins)
		
	} else {
		Write-Host "Replace plugins = $ReplacePlugins, and adding plugins: $Addplugins" -BackgroudColor DarkCyan

	}
	foreach ($pl in $removePlugins) {
		$basePlugins.Remove($pl)

	}
	$env:Plugins = $basePlugins
	
}#End Function Modify-Plugins
#>

Function Validate-Path{
    [CmdLetBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
            [String]$target,
        [Parameter(Mandatory=$True,Position=1)]
            [String]$path,
        [Parameter(Mandatory=$True,Position=2)]
            $creds
    )
    $valBlock = {
        Param (
            [Parameter(Mandatory=$True,Position=0)]
                [String]$path
        )
        
        Return (Test-Path $path)
        
    }
    
    $stat = invoke-command -computerName $target -Credential $creds -ScriptBlock  $valBlock -Argument $path
    
    Return $stat
    
}#End Function Validate-Path

Function Format-VHReport{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,Position=0)]
			[System.Collections.ArrayList]$basePlugins = @(),
		[Parameter(Mandatory=$False,Position=1)]
			[String]$rPath = $env:VolPath,
		[Parameter(Mandatory=$False,Position=2)]
			[String]$gLogPath = $env:GLogPath
	)
	if (($basePlugins -eq $env:Plugins) -or ($basePlugins.count -le 0)) {
		$basePlugins = Parse-Plugins
		
	}	
    $reportName = Read-Host -Prompt "Enter report name to run:"
    $fullPath = $rPath + "\$reportName.xlsx"
    $excelFile = $fullPath
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $wb = $excel.Workbooks.Open($excelFile)
    [int]$i = 2
    $bob = ($wb.Sheets.Item("Sheet1").Cells.Item($i,1).Text)
    function GenReport {
		[CmdletBinding()]
        Param(
			[String]$gLogPath = $env:GLogPath,
			[String]$plugin,
	        [String]$hostname,
	        $workbook,
	        $row,
	        $column 
		)
		
		
        if ((test-path $gLogPath + "$plugin-$hostname.txt") -and ((get-item $gLogPath + "$plugin-$hostname.txt").length -gt 0)) {
          	$workbook.worksheets.Item(1).Cells.Item($row,$column).Interior.ColorIndex = 4

		} elseif ((test-path $gLogPath + "$plugin-$hostname.txt") -and ((get-item $gLogPath + "$plugin-$hostname.txt").length -eq 0)) {
			$workbook.worksheets.Item(1).Cells.Item($row,$column).Interior.ColorIndex = 6

		} else {
			$workbook.worksheets.Item(1).Cells.Items($row,$column).Interior.ColorIndex = 3

		}
	}#End Function GenReport
	
	try {
        while ($bob -notlike $null) {
			[int]$col = 2
			foreach ($pl in $basePlugins) {
				GenReport -path $gLogPath -plugin $pl -hostname $bob -workbook $wb -row $i -column $col
				$col++

			}
			bob
			$i++
			$bob = ($wb.Sheets.Item("Sheet1").Cells.Item(($i),1).Text)

        }
		$wb.SaveAs("$fullPath")
		$wb.Close()
		$Excel.Quit()

	} catch {
		Write-Error -Message "$_ Format-VHReport failed"

	}
}#End Function Format-VHReport

###Not to be exposed by module
Function Copy-File {
	param([string]$from,
	      [string]$to)
	$ffile = [io.file]::OpenRead($from)
	$tofile = [io.file]::OpenWrite($to)
	#the ` backtick causes the interpreter to read the current and the next line as if they were on the same line.
	Write-Progress `
	-Activity "Copying file" `
	-status ($from.Split("\")|select -last 1) `
	-PercentComplete 0
	try {
		$sw = [System.Diagnostics.Stopwatch]::StartNew()
		[byte[]]$buff = new-object byte[] (4096*1024)
		[long]$total = [long]$count = 0
		do {
			$count = $ffile.Read($buff, 0, $buff.Length)
			$tofile.Write($buff, 0, $count)
			$total += $count
			[int]$pctcomp = ([int]($total/$ffile.Length* 100))
			[int]$secselapsed = [int]($sw.elapsedmilliseconds.ToString())/1000
			if ($secselapsed -ne 0) {
				[single]$xferrate = (($total/$secselapsed)/1mb)
			} else {
				[single]$xferrate = 0.0
			}
			if ($total % 1mb -eq 0) {
				if ($pctcomp -gt 0) {
					[int]$secsleft = ((($secselapsed/$pctcomp)* 100)-$secselapsed)
				} else {
					[int]$secsleft = 0
				}
				Write-Progress `
				-Activity ($pctcomp.ToString() + "% Copying file @ " + "{0:n2}" -f $xferrate + " MB/s")`
				-status ($from.Split("\")|select -last 1) `
				-PercentComplete $pctcomp `
				-SecondsRemaining $secsleft
			}
		} while ($count -gt 0)
		$sw.Stop()
		$sw.Reset()
	} finally {
		$ffile.Close()
		$tofile.Close()
    }
}#End function Copy-File

Function Test-VHConnection {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,Position=0)]
			[String]$targetList = $env:TargetList,
		[Parameter(Mandatory=$False,Position=1)]
			[String]$onList = $env:OnList,
		[Parameter(Mandatory=$False,Position=2)]
			[String]$offList = $env:OffList
	)
	Begin { $failPing = 0 }
	Process {
        if ((Test-Path -Path $onList)) { Remove-Item -Path $onList }
        if ((Test-Path -Path $offList)) { Remove-Item -Path $offList }
        foreach ($target in (Get-Content $targetList)) {
			try{
				if (Test-Connection -ComputerName $target -BufferSize 16 -Count 1 -Quiet) {
					Out-File -FilePath $onList -InputObject $target -Append
					continue
                } else {
                    Out-File -FilePath $offList -InputObject $target -Append
                    Write-It -msg "$target not responding to ICMP" -type "Warning"
                    $failPing += 1
                }
            } catch {
                Write-Error -Message "$_ Test-VHConnection failed"
			}
		}
		$time = Get-Date
		Write-It -msg "On/Off checks done at $time" -type "Information"
		return $failPing
	}
}#End Function Test-VHConnection

Function Stop-VHRemote {
	[CmdletBinding()]
	Param(
        [Parameter(Mandatory=$False,Position=0)]
        	[String]$targetList = $env:TargetList
	)
	Process {
		try {
			foreach ($comp in (Get-Content $targetList)) {
				taskkill /IM powershell.exe /S $comp
				taskkill /IM volatility.exe /S $comp

			}
        } catch {
			Write-Error -Message "$_ Stop-VHRemote failed." 

		}
	}
}#End Function Stop-VHRemote
Function Get-VHStatus {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=0)]
			[String]$target,
		[Parameter(Mandatory=$False,Position=1)]
		    [String]$bDonePath,
		[Parameter(Mandatory=$True,Position=2)]
		    $creds
	)
	Process {
		try {
			$hBasePath = Parse-BasePath
			if ($bDonePath -eq "") {
				$bDonePath = $hBasePath["Done"]
				
			}
			$status = Validate-Path -target $target -path $bDonePath -Creds $creds
			if ($status) {
				Write-Host "$target is done" -backgroundColor DarkGreen -ForegroundColor White

			} else {
				Write-Host "$target is still working" -BackgroundColor Red -ForegroundColor Black

			}
		} catch {
			Write-Error -Message "$_ Get-VHStatus failed"

		}
	}
}#End Function Get-VHStatus

Function Get-VHMemDump {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,Position=0)]
			[String]$target,
		[Parameter(Mandatory=$False,Position=1)]
			[String]$bDonePath = "",
		[Parameter(Mandatory=$False,Position=2)]
			[String]$gLogPath = $env:GLogPath,
		[Parameter(Mandatory=$False,Position=3)]
			[String]$imagePath = ""
	)
	Process {
		try {
			$hBasePath = Parse-BasePath
			if ($imagePath -eq "") {
				$imagePath = $hBasePath["Image"]
			
			}
			if ($bDonePath -eq "") {
				$bDonePath = $hBasePath["Done"]
				
			}
			$status = Validate-Path -target $target -path $bDonePath -Creds $global:Credential
			if ($status) {
				Write-Host "Copying memory dump from $target" -BackgroundColor White -ForegroundColor Black
				$session = New-PSSession -ComputerName $target -Credential $global:Credential
				Copy-Item -path $imagePath*.bin -Destination $gLogPath -FromSession $session
				Disconnect-PSSession $session
				Remove-PSSession $session

			} else {
				Write-Host "$target is still working" -BackgroundColor Red -ForegroundColor Black

			} 
		} catch {
			Write-Error -Message "$_ Get-VHMemDump failed"

		}
	}
}#End Function Get-VHMemDump

Function Get-VHOutput {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,Position=0)]
			[String]$targetList = $env:OnList,
		[Parameter(Mandatory=$False,Position=1)]
			[String]$bDonePath = "",
		[Parameter(Mandatory=$False,Position=2)]
			[String]$bOutput = "",
		[Parameter(Mandatory=$False,Position=3)]
			[String]$vhLog = "",
		[Parameter(Mandatory=$False,Position=4)]
			[String]$vhProfile = "",
		[Parameter(Mandatory=$False,Position=5)]
			[String]$gLogPath = $env:GLogPath,
		[Parameter(Mandatory=$False,Position=6)]
			[String]$vlogPath = $env:logPath,
		[Parameter(Mandatory=$False,Position=5)]
			[Switch]$skipOfflines
	)
	Process {
		$hBasePath = Parse-BasePath
		if ($bOutput -eq "") {
			$bOutput = $hBasePath["Output"]
		
		}
		if ($vhLog -eq "") {
			$vhLog = $hBasePath["Log"]
		
		}
		if ($vhProfile -eq "") {
			$vhProfile = $hBasePath["Profile"]
		
		}
		if ($bDonePath -eq "") {
			$bDonePath = $hBasePath["Done"]
		
		}
		
		$lineCount = (Get-Content $targetList | Measure-Object -Line).Lines
		foreach ($target in get-content $targetList) {
			try {
				if (!(Test-Connection -ComputerName $target -BufferSize 16 -Count 1 -Quiet)) {
					Write-It -msg "$target appears offline" -type "Warning"
					if ($skipOfflines) { continue }

				}
				$status = Validate-Path -target $target -Path $bDonePath -Creds $global:Credential
				if ($status) {
					Write-Host "Copying output from $target" -BackgroundColor White -ForegroundColor Black
					$session = New-PSSession -ComputerName $target -Credential $global:Credential
					Copy-Item -path $bOutput* -Destination $gLogPath -FromSession $session
					Copy-Item -path $vhLog-*.txt -Destination $vLogPath -FromSession $session 
					Copy-Item -path $vhProfile -Destination $vLogPath$target-profile.txt -FromSession $session 
					Disconnect-PSSession $session
					Remove-PSSession $session

				} else {
					Write-Host "$target is still working" -BackgroundColor Red -ForegroundColor Black

				}
			} catch {
				Write-Error -Message "$_ Get-VHOutput failed"

			}
		}
	}
}#End Function Get-VHOutput

Function Get-VHStatusAll {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,Position=0)]
		    [String]$targetList = $env:OnList,
		[Parameter(Mandatory=$False,Position=1)]
			[String]$bDonePath = ""
	)
	Process {
		try {
			$hBasePath = Parse-BasePath
			if ($bDonePath -eq "") {
				$bDonePath = $hBasePath["Done"]
			}
		    
			foreach ($target in (Get-Content $targetList)) {
				$status = Validate-Path -target $target -path $bDonePath -Creds $global:Credential
				if ($status) {
					Write-Host "$target is done" -backgroundColor DarkGreen -ForegroundColor White

				} else {
					Write-Host "$target is still working" -BackgroundColor Red -ForegroundColor Black

				}
			}
		} catch {
			Write-Error -Message "$_ Get-VHStatus failed"

		}
	}
}#End Function Get-VHStatusAll

Function Remove-VHIndices {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False,Position=0)]
            [String]$elasticIP = $env:ElasticIP,
        [Parameter(Mandatory=$False,Position=1)]
            [Int]$elasticPort = $env:ElasticPort
    )
    Process {
        try {
            $URI = $elasticIP + ":" + $elasticPort + "/VolHunter"
            curl -Method DELETE $URI >$null
            Write-It -msg "VolHunter index cleared" -type "Information"
            
        } catch {
            Write-Error -Message "$_ Remove-VHIndices failed"
            
        }
    }
}#End Function Remove-VHIndices

Function Remove-VHRemote {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$False,Position=0)]
            [String]$targetList = $env:TargetList,
		[Parameter(Mandatory=$False,Position=1)]
			[String]$rPath = "",
        [Parameter(Mandatory=$False,Position=2)]
            [Int]$maxThreads = $env:MaxThreads,
        [Parameter(Mandatory=$False,Position=3)]
		    $cred = $global:Credential
	)
	
	$hBasePath = Parse-BasePath
	if ($rPath -eq "") {
		$rPath = $hBasePath["Base"]
		
	}
	
	$cleanBlock = {
		Param(
			[Parameter(Mandatory=$True,Position=0)]
				[System.Collections.ArrayList]$blockList
				
		)
		$rPath = $blockList[0]
		Remove-Item -path $rPath -Recurse -Force
		
	}
	
	Run-VHRemote -block $cleanBlock -blockArgList $rPath -MaxThreads $maxThreads -TargetList $targetList -cred $cred
}#End Function Remove-VHRemote

Function Run-VHRemote {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
            $block,
		[Parameter(Mandatory=$True,Position=1)]
            [System.Collections.ArrayList]$blockArgList = @(),
        [Parameter(Mandatory=$False,Position=2)]
            [String]$maxThreads = $env:MaxThreads,
        [Parameter(Mandatory=$False,Position=3)]
            [String]$targetList = $env:TargetList,
        [Parameter(Mandatory=$False,Position=4)]
            $cred = $global:Credential
    )
    Process {
        try {
            $XYZ = 0
            Get-Job | Remove-Job -force
            $volPath = $env:VolPath
            $lineCount = (Get-Content $targetList | Measure-Object -Line).Lines
            Write-It -msg "Running commands against $lineCount targets - Max of $MaxThreads simultaneously" -type "Information"
			
            foreach ($target in (Get-Content $targetList)) {
                While (@(Get-Job -State running).count -ge $maxThreads) {
                    Start-Sleep -Milliseconds 10
					
                }
                try {
                    #invoke-command -AsJob -ScriptBlock $block -ComputerName $target -ArgumentList $blockArgList
                    invoke-command -AsJob -ScriptBlock $block -ComputerName $target -ArgumentList $blockArgList -Credential $cred
                
                } Catch {
                    write-error "An Error Occurred during run-VHRemote invoke-command"
                    
                }
                $XYZ++
                Write-It -msg "Starting job against $target # $XYZ / $lineCount" -type "Other"
				
            }
            Write-It -msg "All jobs started. Waiting for them to finish." -type "Information"
            $lastX = $MaxThreads
			
            While (@(Get-Job -State running).count -gt 0) {
                $x = @(Get-Job -State running).count
				
                if ($lastX -ne $x) {
                    Write-It -msg "Still running $x jobs" -type "Information"
					
                    foreach ($job in Get-Job) {
                        if ($job.State -eq "Running") {
                            Write-Host $job.Name
							
                        }
                    }
                    $lastX = $x
					
                }
                Start-Sleep 1
				
            }
            $time = Get-Date
            Write-It -msg "All jobs finished. Cleaning up. $time" -type "Information"
            Get-Job | Remove-Job -ErrorAction SilentlyContinue
			
        } catch {
			Write-Error -Message "$_ Run-VHRemote failed"
			
		}
    }
}#End Function Run-VHRemote

Function Set-VHInvestigated {
    [CmdletBinding()]
    Param(
        [ValidateScript({Test-Path $_})]
            [String]$investigated = $env:Investigated,
        [Parameter(Mandatory=$False)]
            [String]$elasticIP = $env:ElasticIP,
        [Parameter(Mandatory=$False)]
            [Int]$elasticPort = $env:ElasticPort
    )
    Process {
        foreach ($itemsCleared in Get-Content $investigated) {
            try {
                $clearedSplit = $itemsCleared.split(":")
                $URI = $elasticIP + ":" + $elasticPort + "/" + $clearedSplit[0] + "/doc/" + $clearedSplit[1] + "/_update?pretty"
                curl -Method POST $URI -ContentType "application/json" -Body '{"doc": { "investigated": "true" }}' >$null
                $message = "Cleared index " + $clearedSplit[0] + " item " + $clearedSplit[1]
                Write-It -msg $message -type "Success"
				
            } catch {
                Write-Error -Message "$_ failed on $clearedSplit[1]"
				
            }
        }
    }
}#End Function Set-VHInvestigated

Function Start-VHExecutionCleanup{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False,Position=0)]
            [String]$targetList = $env:OnList,
        [Parameter(Mandatory=$False,Position=1)]
            [String]$maxThreads = $env:MaxThreads
    )
    Process {
        try {
            $cred = $global:Credential
			$hBasePath = Parse-BasePath
			$plugins = Parse-Plugins
			$blockList = @($hBasePath, $plugins)
			
            $rerunBlock = {
                Param ( 			
					[Parameter(Mandatory=$True,Position=0)]
						[System.Collections.ArrayList]$blockList 
				)
				
				$hBasePath = $blockList[0]
				$plugins = $blockList[1]
				
				function Run-Vol {
					param (
						[string]$plugin, 
						[string]$logLocation, 
						[string]$outputDir, 
						[string]$imgLocation, 
						[string]$volProfile
					)
						
                    try {
                    	$command = $hBasePath["Tools"] + "volatility.exe"
                    	$hn = hostname
                    	Add-Content -Path $logLocation -Value "Running $plugin plugin`n"
                    	$start = Get-Date
                    	$outFile = $outputDir + $plugin + "-" + $hn + ".txt"
                    	$timeouted = $null
                    	$proc = Start-Process -FilePath $command -ArgumentList "-f $imgLocation --profile=$volProfile $plugin" -RedirectStandardOutput $outFile -PassThru
                    	$proc | Wait-Process -Timeout 3600 -ErrorAction SilentlyContinue -ErrorVariable timeouted
                    	if ($timeouted) {
                        	$proc | kill
                        	$end = Get-Date
                        	Add-Content -Path $logLocation -Value "$plugin plugin timed-out in $($end-$start)`n"
                        	continue
								
                    	}
                    	$end = Get-Date
                    	Add-Content -Path $logLocation -Value "$plugin plugin completed in $($end-$start) H:M:S.MS`n"
							
                    } catch {
						Add-Content -Path $logLocation -Value "$_ $plugin failed"
                        continue
							
                    }
                }#End RunVol

                $hostName = hostname
                $hostImg = $hostName + ".bin"           #Based on default Input for $basePath 
                $baseDir = $hBasePath["Base"]           #Base = C:\Windows\CCm\Perf\VolH\
                $imageDir = $hBasePath["Image"]         #Image = C:\Windows\CCm\Perf\VolH\Image\
                $outputDir = $hBasePath["Output"]       #Output = C:\Windows\CCm\Perf\VolH\Output\
                $toolDir = $hBasePath["Tool"]           #Tools = C:\Windows\CCm\Perf\VolH\Tools\
				$logDir = $hBasePath["Log"]             #Log =  C:\Windows\CCm\Perf\VolH\VHLog
				$doneDir = $hBasePath["Done"]           #Done = C:\Windows\CCm\Perf\VolH\VolDone.tx
				$proLocation = $hBasePath["Profile"]    #Profile = C:\Windows\CCm\Perf\VolH\VolProfile.txt
				$dumpLoaction = $baseDir + "DumpDone.txt"
                $imgLocation = $imageDir + $hostImg
                $logLocation = $logDir + "\VHLog-$hostname.txt"
                $time = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd"+"T"+"HH:mm:ss.fff"+"Z")
                $volProfile = Get-Content $proLocation
                $OSVersi = [System.Environment]::OSVersion.Version
					
                if (!(Test-Path $imgLocation)) {
                    Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 comae.io"
                    $dumpCommand = "$toolDir"+"DumpIt.exe"
                    Add-Content -Path $logLocation -Value "Starting memory dump"
                    $start = Get-Date
                    Start-Process -Filepath $dumpCommand -ArgumentList "/Q /N /J /T RAW /OUTPUT $imgLocation" -wait
                    $end = Get-Date
                    $dumpDone = "DumpIt Completed"
                    Out-File -FilePath $dumpLoaction -InputObject $dumpDone -Encoding ASCII
                    Get-Content "C:\Windows\System32\drivers\etc\hosts" | Where-Object {$_ -notmatch 'comae'} | Set-Content "C:\Windows\System32\drivers\etc\hosts2"
                    Get-Content "C:\Windows\System32\drivers\etc\hosts2" | Set-Content "C:\Windows\System32\drivers\etc\hosts"
                    Remove-Item "C:\Windows\System32\drivers\etc\hosts2"
                    Add-Content -Path "$logLocation" -Value "Memory dump completed in $($end-$start) H:M:S.MS`n"
						
				}

                $backupTemp = $env:temp
                $env:temp = $baseDir
                $env:tmp = $baseDir
                    
				foreach ($plugin in $plugins) {
					if (!(Test-Path "$outputDir\$plugin-*") -or ((Get-ItemProperty "$outputDir\$plugin-*").length -eq 0)) {
						taskkill /F /IM volatility.exe
                        Run-Vol -plugin $plugin -logLocation $logLocation -outputDir $outputDir -imgLocation $imgLocation -volProfile $volProfile
					        
					}
				}
                    
                $vhlog = "DONE"
                Out-File -FilePath $doneDir -InputObject $vhlog -Encoding ASCII
                ### FIX TEMP FOLDER CHANGE  ### <- WHAT DOES THIS EVEN MEAN!!!!
                $env:temp = $backupTemp
                $env:tmp = $backupTemp
                Add-Content -Path "$logLocation" -Value "Temp environment variables restored`n"
					
            }#End rerunBlock

            Write-Host "SENDING RERUN COMMANDS" -ForegroundColor Black -BackgroundColor Green
			Run-VHRemote -block $rerunBlock -blockArgList $blockList -MaxThreads $maxThreads -TargetList $targetList -cred $global:Credential
			
        } catch {
			Write-Error -Message "$_ Start-VHExecutionCleanup failed"
			
		}
    }
}#End Function Start-VHExecutionCleanup
Function Prep-Environment { 
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
            [String]$maxThreads = $env:MaxThreads,
        [Parameter(Mandatory=$False,Position=1)]
            [String]$targetList = $env:TargetList,
        [Parameter(Mandatory=$False,Position=2)]
            [String]$volPath = $env:VolPath,
        [Parameter(Mandatory=$True,Position=3)]
            $cred = $Global:Credential
    )
	try {
		$scriptBlock = {
		    [CmdletBinding()] 
			Param (
			    [Parameter(Mandatory=$False,Position=0)]
				    [Hashtable]$basePath
			
			)
			
			$baseDir = $BasePath["Base"]
            $imageDir = $BasePath["Image"]
            $outputDir = $BasePath["Output"]
            $toolDir = $BasePath["Tool"]
				
			if (!(Test-Path -Path $baseDir)) {
				
                foreach ( $key in $basePath.keys) {
                    if ($key -eq "Base") {
                        Write-Host "$key is being made" -BackgroundColor White -ForegroundColor Black
                        New-Item -ItemType Directory -Path ($basePath[$key]) | ForEach-Object { $_.Attributes = "hidden" }

                    } elseif ( ($key) -eq "Profile" -or ($key) -eq "Done" ) {
                        Write-Host "$key is a txt file" -BackgroundColor White -ForegroundColor Black

                    } else {
                        Write-Host "$key is being made" -BackgroundColor White -ForegroundColor Black
                        New-Item -ItemType Directory -Path ($basePath[$key]) -ErrorAction Ignore

                    }
                }						
			}
		
			return (([intptr]::size) -ne 4)
		} #End scriptblock
		
		$hBasePath = Parse-BasePath
		$dumpDest = $hBasePath["Tool"] + "DumpIt.exe"
		$volExeDest = $hBasePath["Tool"] + "volatility.exe"
    
		foreach ($target in (Get-Content $targetList)) {
			While (@(Get-Job -State running).count -ge $maxThreads) {
				Start-Sleep -Milliseconds 10
					
			}
		    try {
			    $bSize = Invoke-Command -AsJob -ComputerName $target -Credential $cred -ScriptBlock $scriptBlock -ArgumentList $hBasePath
			
		    } catch {
		        write-host "Prep-Environment Invoke-Command Failed" -background DarkRed
		        
		    }
			
			try {
			    $session = New-PSSession -ComputerName $target -Credential $cred -Authentication Negotiate
		
			} catch {
			    write-host "Prep-Environment New-PSSession failed" -background DarkRed
			    
			}
		    
            Write-Host "Copying dumpit to remote machine" -ForegroundColor Black -BackgroundColor White
			if ($bSize) {
				Copy-Item -Path $volPath\bin\DumpIt-64.exe -Destination $dumpDest -ToSession $session
					
			} else {
				Copy-Item -Path $volPath\bin\DumpIt-86.exe -Destination $dumpDest -ToSession $session
					
			}
			Copy-Item -Path $volPath\bin\volatility.exe -Destination $volExeDest -ToSession $session
            Disconnect-PSSession $session
	        Remove-PSSession $session
				
		}
		
		While (@(Get-Job -State running).count -gt 0) {
			$x = @(Get-Job -State running).count
				
			if ($lastX -ne $x) {
				Write-It -msg "Still running $x jobs" -type "Information"
					
                foreach ($job in Get-Job) {
                    if ($job.State -eq "Running") {
						Write-Host $job.Name
							
                    }
                }				
                $lastX = $x
					
            }
            Start-Sleep 1
				
		}
        $time = Get-Date
        Write-It -msg "All jobs finished. Cleaning up. $time" -type "Information"
        Get-Job | Remove-Job -ErrorAction SilentlyContinue
			
    } catch {
		Write-Error -Message "$_ Run-VHRemote failed"
			
	}
}#End Function Prep-Environment

Function Start-VHInvestigation {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False,Position=0)]
            [String]$targetList = $env:OnList,
        [Parameter(Mandatory=$False,Position=1)]
            [String]$maxThreads = $env:MaxThreads,
		[Parameter(Mandatory=$False,Position=2)]
			[System.Collections.ArrayList]$plugins = @(),
		[Parameter(Mandatory=$False,Position=3)]
		    $cred = $global:Credential
    )
    Process {
        try {
            $numOff = Test-VHConnection
            Write-Host "$numOff systems offline"
			if ($plugins.count -le 0) {
				$plugins = parse-plugins
				
			}			
			$hBasePath = Parse-BasePath
			$blockList = @($hBasePath, $env:VolPath, $plugins, $cred)
			
            $exeBlock = {
                Param(
                    $hBasePath = $args[0],
				    $volPath = $args[1],
				    $plugins = $args[2],
				    $cred = $args[3]
				)

                function Run-Vol {
                    param(
					    [string]$plugin, 
						[string]$logLocation, 
						[string]$outputDir, 
						[string]$imgLocation, 
						[string]$volProfile,
						[String]$volC,
                        $cred
					)
						
                    try {

                        $command = $volC
                        $hn = hostname
                        Add-Content -Path $logLocation -Value "Running $plugin plugin`n"
                        $start = Get-Date
                        $outFile = $outputDir + $plugin + "-" + $hn + ".txt"
                        $timeouted = $null
                        $proc = Start-Process -Credential $cred -FilePath $command -ArgumentList "-f $imgLocation --profile=$volProfile $plugin" -RedirectStandardOutput $outFile -PassThru
                        $proc | Wait-Process -Timeout 3600 -ErrorAction SilentlyContinue -ErrorVariable timeouted
                        if ($timeouted) {
                            $proc | kill
                            $end = Get-Date
                            Add-Content -Path $logLocation -Value "$plugin plugin timed-out in $($end-$start)`n"
                            continue
								
                        }
                        $end = Get-Date
                        Add-Content -Path $logLocation -Value "$plugin plugin completed in $($end-$start) H:M:S.MS`n"
							
                    } catch {
                        Add-Content -Path $logLocation -Value "$_ $plugin failed"
                        continue
							
                    }
                }#End Function Run-Vol

                $hostname = hostname
                $hostImg = $hostName + ".bin"          #Based on default Input for $basePath
                $baseDir = $hBasePath["Base"]          #Base = C:\Windows\CCm\Perf\VolH\
                $imageDir = $hBasePath["Image"]        #Image = C:\Windows\CCm\Perf\VolH\Image\
                $outputDir = $hBasePath["Output"]      #Output = C:\Windows\CCm\Perf\VolH\Output\
                $toolDir = $hBasePath["Tool"]          #Tools = C:\Windows\CCm\Perf\VolH\Tools\
				$doneDir = $hBasePath["Done"]          #Done = C:\Windows\CCm\Perf\VolH\VolDone.txt
				$logDir = $hBasePath["Log"]            #Log =  C:\Windows\CCm\Perf\VolH\VHLog
				$profileDir = $hBasePath["Profile"]    #Profile = C:\Windows\CCm\Perf\VolH\VolProfile.txt
				$unrecDir = $baseDir + "UNRECOGNIZEDPROFILE.txt"
				$imgLocation = $imageDir + $hostImg
				$logLocation = $logDir + "\VHLog-$hostname.txt"
				$vhLogLocation = $logDir + ".txt"
				$dumpCommand = $toolDir + "DumpIt.exe"
				$volCommand = $toolDir + "volatility.exe"
				$dumpText = $baseDir + "DumpDone.txt"
                $time = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd"+"T"+"HH:mm:ss.fff"+"Z")
                $volProfile = Get-Content $profileDir
                $OSVersi = [System.Environment]::OSVersion.Version
                $vhlog = "Starting VolHunter at $time `n"
                Out-File -FilePath "$logLocation" -InputObject $vhlog -Encoding ASCII

                ### DETERMINE VOLATILITY PROFILE ###
                Add-Content -Path $logLocation -Value "Determining x86 vs x64`n"
                ### Determine 32 vs 64 bit architecture
                $architecture = 64

                if ([intptr]::size -eq 4) {
                    $architecture = 86
						
                }

                Add-Content -Path $logLocation -Value "$hostname is x$architecture`n"
                ### Get systeminfo ###
                Add-Content -Path $logLocation -Value "Determining OS & Revision for Volatility profile`n"
                $sysInfo = systeminfo.exe
                $ram = (($sysinfo | select-string 'Total Physical Memory:').ToString().Split(':')[1].Trim()).Replace(" MB","")
                $diskSpace = ( gwmi Win32_LogicalDisk -filter "deviceid='C:'" | Select DeviceID, @{Name="FreeMB";Expression={[math]::Round($_.Freespace/1MB,2)}} ).FreeMB
                $osVersion = $sysInfo | select-string "OS Version"
                $sysInfo = $sysInfo | select-string "OS Name"
                Add-Content -Path $logLocation -Value "$hostname has $ram MB of RAM`n"
                Add-Content -Path $logLocation -Value "$hostname has $diskSpace MB of free space on C:`n"
                if ($diskSpace -le ([int]$ram + 2000)) {
                    #$ram use to be freeram but I never saw that var set
                    Add-Content -Path $vhLogLocation -Value "Not enough free disk space`n"
                    $volDone = "Not enough freespace on C:\ to run`n"
                    Out-File -FilePath $doneDir -InputObject $volDone -Encoding ASCII
                        
                    return 
						
                }
                Add-Content -Path $logLocation -Value "$osVersion `n"
                Add-Content -Path $logLocation -Value "$sysInfo `n"

                ### Build Volatility --profile variable based on OSVersion.Version and systeminfo output ###
                switch ($sysInfo) {
                    # Windows 10 Ver 10586/14393/15063+/none x86/64 #
                    {$_ -like "*Windows 10*"} {
                        if(($osVersi.Build -ge 10586) -and ($osVersi.Build -lt 14393)){$volProfile = "Win10x"+$architecture+"_10586"}
                        elseif(($osVersi.Build -ge 14393) -and ($osVersi.Build -lt 15063)){$volProfile = "Win10x"+$architecture+"_14393"}
                        elseif(($osVersi.Build -ge 15063) -and ($osVersi.Build -lt 16299)){$volProfile = "Win10x"+$architecture+"_15063"}
                        elseif(($osVersi.Build -ge 16299) -and ($osVersi.Build -lt 17134)){$volProfile = "Win10x"+$architecture+"_16299"}
                        elseif(($osVersi.Build -ge 17134) -and ($osVersi.Build -lt 17763)){$volProfile = "Win10x"+$architecture+"_17134"}
                        elseif($osVersi.Build -eq 17763){$volProfile = "Win10x"+$architecture+"_17763"}
                        else{$volProfile = "Win10x"+$architecture}
                            
                    }
                        # Server 2016 Ver 14393 #
                    {$_ -like "*Server 2016*"} { $volProfile = "Win2016x64_14393" } #End Server2016 switch
                    # Server 2012 #
                    {$_ -like "*Server 2012 *"} { $volProfile = "Win2012x64" }
                    # Server 2012R2, Ver 18340 #
                    {$_ -like "*Server 2012 R2*"} {
                        if($osVersion -like "*18340*") { $volProfile = "Win2012R2x64_18340" }
                        else{ $volProfile = "Win2012R2x64" }
                            
                    }
                    # Server 2008, SP1/2, x86/64 #
                    {$_ -like "*Server*2008 Standard*"} {
                        if($osVersion -like "*Service*Pack*1*"){ $volProfile = "Win2008SP1x"+$architecture }
                        else{ $volProfile = "Win2008SP2x"+$architecture }
                            
                    }
                    # Server 2008 R2 SP0/1 & SP1_23418 #
                    {$_ -like "*Server 2008 R2*"} {
                        if (!($osVersion -like "*Service Pack 1*")) { $volProfile = "Win2008R2SP0x64" }
                        elseif($osVersion -like "*23418*"){ $volProfile = "Win2008R2SP1x64_23418" }
                        else{ $volProfile = "Win2008R2SP1x64" }
                            
                    }
                    # Server 2003 SP0x86, SP1x86/64, SP2x86/64 #
                    {$_ -like "Server 2003*"} {
                        if($osVersion -like "*Service Pack 1*"){ $volProfile = "Win2003SP1x"+$architecture }
                        elseif($osVersion -like "*Service Pack 2*"){ $volProfile = "Win2003SP2x"+$architecture }
                        else{ $volProfile = "Win2003SP0x86" }
                            
                    }
                    # Vista SP0/1/2 x86/x64 #
                    {$_ -like "*Vista*"} {
                        if($osVersion -like "*Service Pack 1*"){ $volProfile = "VistaSP1x"+$architecture }
                        elseif($osVersion -like "*Service Pack 2*"){ $volProfile = "VistaSP2x"+$architecture }
                        else{ $volProfile = "VistaSP0x"+$architecture }
                            
                    }
                    # Windows 7 SP0x64/86, SP1x64/86, SP1_23418x64/86 #
                    {$_ -like "*Windows 7*"} {
                        if( !($osVersion -like "*Service Pack*") ){ $volProfile = "Win7SP0x"+$architecture }
                        elseif($osVersion -like "*23418*"){ $volProfile = "Win7SP1x"+$architecture + "_23418" }
                        else{ $volProfile = "Win7SP1x"+$architecture }
                            
                    }
                    # Windows 8.1 #
                    {$_ -like "*Windows 8.1*"} {
                        if($osVersion -like "*18340*"){ $volProfile = "Win8SP1x64_18340" }
                        else{ $volProfile = "Win8SP1x"+$architecture }
                            
                    }
                    # Windows 8 #
                        {$_ -like "*Windows 8 *"} { $volProfile = "Win8SP0x"+$architecture }
                        default {$volProfile = "ERROR"}
						
                    }#end OS Switch

                    Out-File -FilePath $profileDir -InputObject $volProfile -Encoding ASCII
                    Add-Content -Path $logLocation -Value "Volatility Profile = $volProfile `n"
                    if ($volProfile -eq "ERROR") {
                        Out-File -FilePath $unrecDir -InputObject $volProfile -Enocding ASCII
                        $volDone = "VHRemote failed due to unrecognized profile"
                        Out-File -FilePath $DoneDir -InputObject $volDone -Encoding ASCII
                        exit
                    
					}
                    ###############################
                    ### Run memory dumping tool ###
                    ###############################
                    Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 comae.io"
                    
                    Add-Content -Path $logLocation -Value "Starting memory dump"
                    Add-Content -Path $logLocation -Value "Bin file Location $imgLocation"
                    $start = Get-Date
                    #Start-Process -Credential $cred -Filepath $dumpCommand -ArgumentList "/Q /N /J /T RAW /O $imgLocation" -wait
                    Add-Content -Path $logLocation -Value "start command - `n$dumpCommand /Q /N /J /T RAW /O $imgLocation"
                    &$dumpCommand /Q /N /J /T RAW /O $imgLocation
                    $end = Get-Date
                    $dumpDone = "DumpIt Completed"
                    Out-File -FilePath $dumpText -InputObject $dumpDone -Encoding ASCII
                    Get-Content "C:\Windows\System32\drivers\etc\hosts" | Where-Object {$_ -notmatch 'comae'} | Set-Content "C:\Windows\System32\drivers\etc\hosts2"
                    Get-Content "C:\Windows\System32\drivers\etc\hosts2" | Set-Content "C:\Windows\System32\drivers\etc\hosts"
                    Remove-Item "C:\Windows\System32\drivers\etc\hosts2"
                    Add-Content -Path $logLocation -Value "Memory dump completed in $($end-$start) H:M:S.MS`n"
                    $backupTemp = $env:temp
                    $env:temp = $baseDir
                    $env:tmp = $baseDir
                    rm $doneDir
					foreach ($plugin in $plugins) {
						Run-Vol -plugin $plugin -logLocation $logLocation -outputDir $outputDir -imgLocation $imgLocation -volProfile $volProfile -volC $volCommand -cred $cred
						
					}
					
                    $vhlog = "DONE"
                    Out-File -FilePath $doneDir -InputObject $vhlog -Encoding ASCII
                    ### FIX TEMP FOLDER CHANGE ###
                    $env:temp = $backupTemp
                    $env:tmp = $backupTemp
                    Add-Content -Path "$logLocation" -Value "Temp environment variables restored`n"

            }#End Exe Block

            ### MOVE ALL FILES
            Write-Host "BEGINNING SIMULTANEOUS FILE MOVES" -ForegroundColor Black -BackgroundColor White
			Prep-Environment -MaxThreads $MaxThreads -targetList $targetList -cred $global:Credential
            ### EXECUTE ###
            Write-Host "BEGINNING EXECUTION" -ForegroundColor Black -BackgroundColor Green
            Run-VHRemote -block $exeBlock -blockArgList $blockList -MaxThreads $MaxThreads -TargetList $targetList -cred $global:Credential -ErrorAction Continue
			
        } catch {
			Write-Error -Message "$_ Start-VHInvestigation overall failed"
			
		}
    }
}#End Function Start-VHInvestigation

Function Test-VHShareName{
    $shareList = net share
    for ($test = 0; $test -lt 26; $test++) {
        $testChar = [char](65 + $test)
        [string]$testCharString = "*" + $testChar + ":\*"
        if (!($shareList -like "$testCharString")) {
            return "$testChar"
			
        }
    }
}#End Test-VHShareName

Function Watch-VHStatus{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False,Position=0)]
            [String]$targetList = $env:OnList
    )
    Process{
        try{
            $notDone = $True
            $index = 0
            $targetLength = (Get-Content $targetList | Measure-Object -Line).Lines
            $array = @()
            $doneCount = 0
            Write-It -msg "Waiting for $targetLength targets to finish. Will notify you when they complete, checking every 30 seconds." -type "Information"
            Start-Sleep 2
            while ($index -lt $targetLength) {
                $array += @($False)
                $index++
				
            }

            $index = 0
            $firstRun = 0
            $numFailed = 0
            $hBasePath = Parse-BasePath
            $bLogPath = $hBasePath["Log"]
            $bDonePath = $hBasePath["Done"]
            
            while ($notDone) {
                foreach ($target in get-content $targetList) {
                    if (!($array[$index])) {
                        #If first time thru, check if VHLog exists, otherwise VHR failed
                        if ($firstRun -lt $targetLength) {
                            $firstRun += 1
                            if (!(Test-Connection -ComputerName $target -BufferSize 16 -Count 1 -Quiet)) {
                               Write-It -msg "$target appears to be offline" -type "Error"
                               $array[$index] = $True
                               $doneCount++
                               $numFailed += 1
                               continue
							   
                            }
                            $status = Validate-Path -target $target -path $bLogPath -Creds $global:Credential
                            if (!($status)) {
                                Write-It -msg "FAILURE: $target has failed to start VolHunterRemote" -type "Error"
                                $array[$index] = $True
                                $doneCount++
                                $numFailed += 1
								
                            } else {
                                Write-It -msg "SUCCESS: $target started VolHunterRemote" -type "Success"
							}
                        }
                        $status = Validate-Path -target $target -Path $bDonePath -Creds $global:Credential
                        if ($status) {
                            $date = Get-Date
                            Write-It -msg "$target completed $date" -type "Other"
                            $array[$index] = $True
                            $doneCount++
                            Write-It -msg "$doneCount of $targetLength targets complete." -type "Information"
							
                        }
                    }
                    $index++
                }
                $index = 0
                if ($doneCount -eq $targetLength) {
                    $notDone = $False
                    continue
					
                }
                start-sleep 30
				
            }
            Write-It -msg "All $targetLength targets completed" -type "Success"
            if ($numFailed -gt 0) {
                Write-It -msg "$numFailed target failed to start VHR, check your output" -type "Error"
				
            }
        } catch {
			Write-Error -Message "$_ Watch-VHStatus failed"
		
		}
    }
}#End Watch-VHStatus

###Not to be exposed by module
Function Write-It{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=0)]
            [String]$msg,
        [Parameter(Mandatory=$True,Position=0)]
            [String]$type
    )
    Process{
        try{
            switch ($type) {
                {$_ -like "Information"} { $back = "White"; $fore = "Black"}
                {$_ -like "Warning"} { $back = "Yellow"; $fore = "Red"}
                {$_ -like "Error"} { $back = "Red"; $fore = "White"}
                {$_ -like "Success"} { $back = "DarkGreen"; $fore = "White"}
                default { Write-Host $msg; return }
				
            }
            Write-Host $msg -ForegroundColor $fore -BackgroundColor $back
			
        } catch {
			Write-Error -Message "$_ Write-It failed... I'm not sure how you managed this."
			
		}
    }
}#End Function Write-It

Export-ModuleMember -Function Get-*
Export-ModuleMember -Function Remove-*
Export-ModuleMember -Function Set-*
Export-ModuleMember -Function Convert-VHElastic
Export-ModuleMember -Function Format-VHReport
Export-ModuleMember -Function Start-VHInvestigation
Export-ModuleMember -Function Start-VHExecutionCleanup
Export-ModuleMember -Function Stop-VHRemote
Export-ModuleMember -Function Send-VHResults
Export-ModuleMember -Function Test-VHConnection
Export-ModuleMember -Function Test-VHShareName
Export-ModuleMember -Function Watch-VHStatus
Export-ModuleMember -Function Display-VHEnvironment
Export-ModuleMember -Function Parse-BasePath
Export-ModuleMember -Function Parse-Plugins
#Export-ModuleMember -Function Modify-Plugins
Export-ModuleMember -Function Validate-Path
Export-ModuleMember -Function Prep-Environment