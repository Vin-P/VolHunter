<#
.SYNOPSIS
At scale dumping and analysis (Volatility) of memory
.DESCRIPTION
Kicker is used to send VolHunter to remote systems and execute it.
Will also allow for gathering of Volatility output to trusted system.
Please note: You should only run Kicker on Windows 8+ (PSv3+, PSv5 HIGHLY RECOMMENDED)
             Your targets MUST either have WMIC enabled, or failing that, be PSv3+ and allow WinRM
                e.g. Default Windows 7 will not work if WMIC is disabled
             PSv5 is required to send logs to Elastic
When defining plugins, you can type "all" to run them all or specify individual plugins with a "/" between each
.EXAMPLE
    PS> .\Kicker.ps1 -DumpMem True -Plugins cmdline/malfind -TargetList .\targetlist.txt -MaxThreads 20
    Will push tools and execute VolHunter on 20 systems simultaneously until all systems in .\targetlist.txt have been touched
    Will tell VolHunter to dump memory to C:\VolH\Image\[hostname].bin and then run Volatility cmdline and malfind plugins
.EXAMPLE
    PS> .\Kicker.ps1 -GatherOutput True -LocalShipping True -CleanUp True
    Will validate that Volatility has completed on each target system, copy parsed output to local host .\GatheredLogs\
    then send each parsed output file to ElasticSearch, then remove VolHunter from remote systems
.EXAMPLE
    PS> .\Kicker.ps1 -DumpMem True -Plugins all -CheckDone True -GatherOutput True -LocalShipping True -CleanUp True
    Will push tools, execute VolHunter, dump memory, run all supported volatility plugins, parse output, notify you when each remote system completes,
    Gather all parsed output, send gathered logs to Elastic, and then clean up remote hosts
.NOTES
    Author: Michael "FUMBLES" Russell
    Date:   17 June 2018
.PARAMETER TargetList
    Takes a file with hostnames of target systems to run VolHunter on.
    Each target must be its own line with no more than 1 blank line at the end of the file
.PARAMETER DumpMem
    True/False, defaults to False. True will tell remote system to dump memory to
    C:\VolH\Image\[hostname].bin
.PARAMETER Volatility
    Deprecated input parameter. Use -Plugins
.PARAMETER ElasticIP
    Define the IP address of your Elastic ingest node
    Default value should be changed when placing script on new launching system
.PARAMETER ElasticPort
    Define the port your Elastic ingest node listens on
    Default value of 9200 per standard Elastic install
    Value should be changed if you modified Elastic node's settings
.PARAMETER CleanUp
    True/False, defaults to False. True will tell your launching system to validate
    that VolHunter has completed on each remote system, defined by -TargetList by
    checking that C:\VolH\VolDone.txt exists, and then forcefully deleting the C:\VolH
    folder structure and all child files and directories
.PARAMETER GatherOutput
    True/False, defaults to False. True will tell your launching system to validate
    that VolHunter has completed in same manner as -CleanUp. This parameter will copy
    each parsed text file from C:\VolH\Output\[plugin-hostname].txt to local 
    .\GatheredLogs\[plugin-hostname].txt and delete the output on the target system to
    avoid duplication in Elastic
.PARAMETER LocalShipping
    True/False, defaults to False. True will make a curl (Invoke-WebRequest) call to your
    ElasticIP:ElasticPort/_bulk and send the content of all files in .\GatheredLogs
    After sending the content of each file, the file will be deleted from local folder
    in order to avoid duplication in Elastic
.PARAMETER Investigated
    Optional parameter with default of $null. If you provide a path to a text file,
    Kicker will send a curl request to specified Elastic node (ElasticIP:ElasticPort)
    to change the "investigated" attribute to true in order to hide specified entries
    from dashboards. Note, all entries sent to Elastic have a default value of investigated:false
    
    Format for text file is one entry per line as follows
    [plugin]:[_id value]
    
    Example
    cmdline:xsyyx337kajxx

    This file can be built by using the script BuildInvestigatedList.ps1
    See notes in that script for help to build this list
.PARAMETER clearIndices
    True/False, defaults to False. True will make a curl request to your defined
    Elastic node and delete ALL data from ALL VolHunter related indices
    THIS CANNOT BE UNDONE
.PARAMETER MaxThreads
    Accepts an integer to define the maximum number of concurrent systems that Kicker will
    run against. Default value is 10. Note, the higher the number the more host CPU and 
    network resources will be consumed on your launching system.
.PARAMETER CheckDone
    True/False, defaults to False. True will cause your system to monitor all targets, waiting for 
    the existence of C:\VolH\VolDone.txt
    When this parameter is used, Kicker will check all systems that haven't completed every 30 seconds
    As targeted systems complete, this will notify you the approximate time of completion of each system,
    the name of the system that completed, and the Done/Total system count
.PARAMETER Plugins
    Default value of $null
    Define which plugins you want Volatility to run against each remote memory dump.
    To run all plugins, provide "all" without quotation marks
    To run a defined set of plugins, provide plugin1/plugin2 with a / between each
    Currently supported plugins:
    all (will run all plugins)
    cmdline
    malfind
    mutantscan
    psscan
    ssdt
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=0)]
        [String]$TargetList=".\targetlist.txt",
    [Parameter(Mandatory=$False,Position=1)]
        [String]$DumpMem = $null,
    [Parameter(Mandatory=$False,Position=2)]
        [String]$Volatility = $null,
    [Parameter(Mandatory=$False,Position=3)]
        [String]$ElasticIP = "192.168.35.133",
    [Parameter(Mandatory=$False,Position=4)]
        [Int]$ElasticPort = 9200,
    [Parameter(Mandatory=$False,Position=5)]
        [String]$CleanUp = $null,
    [Parameter(Mandatory=$False,Position=6)]
        [String]$GatherOutput = $null,
    [Parameter(Mandatory=$False,Position=7)]
        [String]$LocalShipping = $null,
    [Parameter(Mandatory=$False,Position=9)]
        [String]$Investigated = $null,
    [Parameter(Mandatory=$False,Position=9)]
        [String]$clearIndices = $null,
    [Parameter(Mandatory=$False,Position=10)]
        [Int]$MaxThreads = 10,
    [Parameter(Mandatory=$False,Position=11)]
        [String]$CheckDone = $null,
    [Parameter(Mandatory=$False,Position=12)]
        [String]$Plugins = $null
)

##################
### Initialize ###
##################
if($Plugins){$Volatility = "True"}

Clear-Host
Write-Host "
██╗   ██╗ ██████╗ ██╗     ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ 
██║   ██║██╔═══██╗██║     ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██║   ██║██║   ██║██║     ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
╚██╗ ██╔╝██║   ██║██║     ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
 ╚████╔╝ ╚██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
  ╚═══╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
                                                                              
"

#######################################
### Parallel execution of VolHunter ###
#######################################
$cleanBlock = {
    Param([string] $target)
    "`nTarget is $target"
    Invoke-Command -Computer $target -ScriptBlock {Remove-Item -path C:\VolH -recurse -force}
    "`nFiles and folders deleted`n"
}

$block = {
    Param([string] $target, [string]$DumpMem, [string]$Volatility, [string]$volPath, [string]$Plugins)

    ### Validate system is online ###
    if( !(Test-Connection -ComputerName $target -BufferSize 16 -Count 1 -Quiet) ){
        "`n$target is not responding to ICMP. Possibly offline.`n"
        Return
    }

    ### Determine if $target is an acceptable target ###
    $sysInfo = Invoke-Command -ComputerName $target -ScriptBlock{systeminfo.exe}
    $sysInfo = $sysInfo | select-string "OS Name"
    if( !($sysInfo -like "*Windows 10*") -and !($sysInfo -like "*Server*") -and !($sysInfo -like "*Vista*") -and !($sysInfo -like "*Windows 7*") -and !($sysInfo -like "*Windows 8*") ){
        "$target is a currently unsupported OS"
        $sysInfo
        Return
    }
    
    ### Kick off VolHunter as necessary ###
    if( ($DumpMem) -or ($Volatility) ){
        "`nTarget is $target"
        $baseDir = "C:\VolH\"
        $imageDir = "C:\VolH\Image\"
        $outputDir = "C:\VolH\Output\"
        $toolDir = "C:\VolH\Tools\"

        ### Create folders on target folder ###
        Invoke-Command -ComputerName $target -ScriptBlock{
            if(!(Test-Path -Path "C:\VolH\")){
                New-Item -ItemType directory -Path ("C:\VolH\") | %{$_.Attributes = "hidden"}
                New-Item -ItemType directory -Path ("C:\VolH\Image\")
                New-Item -ItemType directory -Path ("C:\VolH\Output\")
                New-Item -ItemType directory -Path ("C:\VolH\Tools\")
            }
        } >$null 2>&1
        "`nFolders Created on $target"

        ### Identify x86 vs x64 ###
        if( (Invoke-Command -ComputerName $target -ScriptBlock {[intptr]::size}) -eq 4){
            $Architecture = 86
        }
        else{
            $Architecture = 64
        }
        
        ### Check if DumpIt/Vol already exist, if no, then push ###
        if( !( (Test-Path -Path "\\$target\C$\VolH\Tools\volatility.exe") -and (Test-Path -Path "\\$target\C$\VolH\Tools\DumpIt-*") ) ){
            ### Move correct EXEs to target ###
            if($Architecture -eq "64"){
                Copy-Item -Path $volPath\bin\DumpIt-64.exe -Destination "\\$target\C$\VolH\Tools\DumpIt-64.exe"
                Copy-Item -Path $volPath\bin\volatility-64.exe -Destination "\\$target\C$\VolH\Tools\volatility.exe"
            }
            else{
                Copy-Item -Path $volPath\bin\DumpIt-86.exe -Destination "\\$target\C$\VolH\Tools\DumpIt-86.exe"
                Copy-Item -Path $volPath\bin\volatility-86.exe -Destination "\\$target\C$\VolH\Tools\volatility.exe"
            }
            "`nTools Shipped to $target`n"
        }
        if( !(Test-Path -Path "\\$target\C$\VolH\Tools\VolHunterRemote.ps1") ){
            Copy-Item -Path $volPath\bin\VolHunterRemote.ps1 -Destination "\\$target\C$\VolH\Tools"
            "`nVolHunter Shipped to $target`n"
        }
        
        ### Execute VolHunter on target ###
        try{
            "`nAttempting to run on $target via Invoke-Command -InDisconnectedSession`n"
            "`n$target MUST be running PSv3 or greater!`n"

            $scriptBlock = { 
                $dumper = $args[0]
                $voll = $args[1]
                $plugs = $args[2]
                Start-Process powershell.exe -ArgumentList "-c C:\VolH\Tools\VolHunterRemote.ps1 $dumper $voll $plugs"
            }
            Invoke-Command -ComputerName $target -InDisconnectedSession -ScriptBlock $scriptBlock -ArgumentList $DumpMem,$Volatility,$Plugins -ErrorVariable results 2>$null
            if($results -like "*Disconnected sessions are supported only*"){
                throw 'PS less than v3'
            }
            else{ "`nStarting VolHunter on $target via Invoke-Command -InDisconnectedSession`n" }
        }
        catch{
            "`nTarget running < PSv3, trying WMIC`n"
            Get-WmiObject -List -Class Win32_OperatingSystem -Computer $target -ErrorVariable results 1>$null 2>$null
            if($results -like "*Could not get*"){
                "`nWMIC is NOT enabled on $target `n"
                return
            }
            else{
                "`nWMIC enabled on $target `n"
                "`nStarting VolHunter on $target via WMIC`n"
                $targIP = [Net.Dns]::GetHostAddresses("$target") | select-object IPAddressToString -expandproperty IPAddressToString
                WMIC /node:"$targIP" process call create "powershell.exe -c C:\VolH\Tools\VolHunterRemote.ps1 -dumpFlag $DumpMem -volFlag $Volatility $Plugins" 2>$null
            }
        }
    }
} #End $block

###########################
### Start parallel jobs ###
###########################
Get-Job | Remove-Job
$volPath = Get-Location
$volPath = [string]$volPath -split("----")

if( ($DumpMem) -or ($Volatility) ){
    #Start the jobs
    $lineCount = (Get-Content $TargetList | Measure-Object -Line).Lines
    "*** Starting VolHunter against $lineCount targets - Max of $MaxThreads targets simultaneously ***"
    foreach ($target in get-content $TargetList){
        While (@(Get-Job -state running).count -ge $MaxThreads){
            Start-Sleep -Milliseconds 10
        }
        Start-Job -ScriptBlock $block -ArgumentList $target, $DumpMem, $Volatility, $volPath, $Plugins >$null
        "Starting job against $target"
    }
    #Wait for all jobs to finish
    "*** All jobs started. Waiting for them to finish. ***"
    $lastX = $MaxThreads
    While (@(Get-Job -State running).count -gt 0){
        $x = @(Get-Job -State running).count
        if($lastX -ne $x){
            "Still running $x jobs"
            $lastX = $x
        }
        start-sleep 1
    }
    #Get information from each job
    foreach($job in Get-Job){
        $info = (Receive-Job -Id ($job.Id))
        [string]$jobOut = $info | Select-String -Pattern "Target is "
        $filename = $jobOut.Replace("Target is ","")
        $filename = $filename.Replace("`n","")
        $jobPath = ".\JobLogs\" + $filename + "-" + $job.Id + ".txt"
        Out-File -FilePath "$jobPath" -InputObject $info -Encoding ASCII  
    }
    #Remove all jobs created
    "*** All jobs finished. Cleaning up. ***"
    Get-Job | Remove-Job
    "*** Kicker complete. Wait for VolHunter to complete. ***"
}

######################################################
######################################################
##### Extra functions, operate on localhost only #####
######################################################
######################################################

###########################################
### Check if all targets have completed ###
### Report which ones not done yet      ###
###########################################
if($CheckDone){
    $notDone = $True
    $index = 0
    $targetLength = (Get-Content $TargetList | Measure-Object -Line).Lines
    $array = @()
    $doneCount = 0
    "Waiting for $targetLength targets to finish. Will notify you when they complete, checking every 30 seconds."
    while($index -lt $targetLength){
        $array += @($False)
        $index++
    }
    $index = 0
    while($notDone){
        foreach($target in get-content $TargetList){
            if( !($array[$index]) ){
                if(Test-Path "\\$target\C$\VolH\VolDone.txt"){
                    $date = Get-Date
                    "$target completed $date"
                    $array[$index] = $True
                    $doneCount++
                    "$doneCount of $targetLength targets complete."
                }
            }
            $index++
        }
        $index = 0
        if($doneCount -eq $targetLength){
            $notDone = $False
            continue
        }
        start-sleep 30
    }
    "All $targetLength targets completed"
}

##################################################################
### Gather Logs - Copies parsed Volatility output from targets ###
##################################################################
if($GatherOutput){
    foreach($target in get-content $TargetList){
        if(Test-Path "\\$target\C$\VolH\VolDone.txt"){
            "Grabbing parsed output from $target"
            Copy-Item -Path "\\$target\C$\VolH\Output\*.txt" -Destination .\GatheredLogs\
            Remove-Item -Path "\\$target\C$\VolH\Output\*.txt" -force
            Copy-Item -Path "\\$target\C$\VolH\VHLog-*.txt" -Destination .\VHLogs\
            Remove-Item -Path "\\$target\C$\VolH\VHLog-*.txt" -force
        }
        else{
            "Volatility not complete on $target"
        }
    }
}

###########################################################################
### Local Shipping - Sends all parsed output files from .\GatheredLogs\ ###
### Then deletes each item to prevent duplication in ElasticSearch      ###
###########################################################################
$testURI = $ElasticIP + ":" + $ElasticPort
if($LocalShipping){
    try{
        if( !((curl -Method GET $testURI) -like "*tagline*") ){ throw 'Not PSv5' }
        $URI = $ElasticIP + ":" + $ElasticPort + "/" + '_bulk'
        $files = Get-ChildItem .\GatheredLogs\*
        foreach($file in $files) {
            curl -Method POST $URI -ContentType: application/json -InFile $file >$null 2>&1
            "Shipped $file to Elastic"
            Remove-Item -path $file -force
        }
    } catch {
        Write-Error "You're not running PSv5, you can't curl"
    }
}

###########################################################
### Clean Up - Deletes C:\VolH and all subfolders/files ###
###########################################################
if($CleanUp){
    #Start the jobs
    $lineCount = (Get-Content $TargetList | Measure-Object -Line).Lines
    "*** Cleaning up $lineCount targets - Max of $MaxThreads targets simultaneously ***"
    foreach ($target in get-content $TargetList){
        While (@(Get-Job -state running).count -ge $MaxThreads){
            Start-Sleep -Milliseconds 10
        }
        Start-Job -ScriptBlock $cleanBlock -ArgumentList $target >$null
        "Cleaning up $target"
    }
    #Wait for all jobs to finish
    "*** All jobs started. Waiting for them to finish. ***"
    $lastX = $MaxThreads
    While (@(Get-Job -State running).count -gt 0){
        $x = @(Get-Job -State running).count
        if($lastX -ne $x){
            "Still running $x jobs"
            $lastX = $x
        }
        start-sleep 1
    }
    #Get information from each job
    foreach($job in Get-Job){
        $info = (Receive-Job -Id ($job.Id))
        [string]$jobOut = $info | Select-String -Pattern "Target is "
        $filename = $jobOut.Replace("Target is ","")
        $filename = $filename.Replace("`n","")
        $jobPath = ".\JobLogs\" + $filename + "-Cleaned-" + $job.Id + ".txt"
        Out-File -FilePath "$jobPath" -InputObject $info -Encoding ASCII  
    }
    #Remove all jobs created
    "*** All jobs finished. Cleaning up. ***"
    Get-Job | Remove-Job
    "*** Cleanup completed ***"
}

####################################################################################
### Investigated - Updates items in ElasticSearch                                ###
### Changes the "investigated" field to true so they're filtered from dashboards ###
### File must have one entry per line in format  [Index]:[_id]                   ###
####################################################################################
if( !([string]::IsNullOrEmpty($Investigated)) ){
    foreach ($itemsCleared in get-content $Investigated){
        $clearedSplit = $itemsCleared.split(":")
        $URI = $ElasticIP + ":" + $ElasticPort + "/" + $clearedSplit[0] + "/doc/" + $clearedSplit[1] + "/_update?pretty"
        curl -Method POST $URI -ContentType "application/json" -Body '{"doc": { "investigated": "true" }}' >$null
        "Cleared index " + $clearedSplit[0] + " item " + $clearedSplit[1]
    }
}

###########################################################################
### Clear Indices - Removes all items in each VolHunter supported index ###
###########################################################################
if($clearIndices){
    $URI = $ElasticIP + ":" + $ElasticPort + "/malfind"
    curl -Method DELETE $URI >$null
    "Malfind index cleared"

    $URI = $ElasticIP + ":" + $ElasticPort + "/psscan"
    curl -Method DELETE $URI >$null
    "PSScan index cleared"

    $URI = $ElasticIP + ":" + $ElasticPort + "/ssdt"
    curl -Method DELETE $URI >$null
    "SSDT index cleared"

    $URI = $ElasticIP + ":" + $ElasticPort + "/cmdline"
    curl -Method DELETE $URI >$null
    "CMDLine index cleared"

    $URI = $ElasticIP + ":" + $ElasticPort + "/mutantscan"
    curl -Method DELETE $URI >$null
    "MutantScan index cleared"
}

