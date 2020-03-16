<#
.SYNOPSIS

VolHunter aims to grab an image of live system memory, automate relevant 
volatility scans to gather initial triage datapoints, then send them to
an ElasticStack node for analysis via the Kicker script.

VolHunter can be run locally on a host system, to enable remote/mass scans,
utilize Kicker.ps1 to push VolHunter and relevant executables. 
Volatility and DumpIt (or chosen memory capturing tool such as Winpmem) 
need to be placed into C:\VolH\Tools

Outline of VolHunter Folder Structure:
C:\VolH\Image\     Stores memory dump file
C:\VolH\Output\    Stores raw & parsed volatility output
C:\VolH\Tools\     Stores volatility, VolHunterRemote, and DumpIt


.PARAMETER dumpFlag
An optional parameter, default value of false. When set to true
will run memory dumping utility and save in C:VolH\Image\

.PARAMETER volFlag
An optional parameter, default value of false. When set to true
will run all currently VolHunter usable volatility plugins

.NOTES
    Author: Michael "FUMBLES" Russell
    Date:   17 June 2018
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=0)]
        [String]$dumpFlag = $null,
    [Parameter(Mandatory=$False,Position=1)]
        [String]$volFlag=$null,
    [Parameter(Mandatory=$False,Position=2)]
        [String]$Plugins=$null
)

##################
### Initialize ###
##################
if($Plugins){$volFlag = "True"}
$GLOBALSTART = Get-Date

### Static Variables ###
$hostName = hostname
$hostImg = $hostName + ".bin"
$baseDir = "C:\VolH\"
$imageDir = "C:\VolH\Image\"
$outputDir = "C:\VolH\Output\"
$toolDir = "C:\VolH\Tools\"
$imgLocation = "C:\VolH\Image\$hostImg"
$time = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd"+"T"+"HH:mm:ss.fff"+"Z")
$outer = 0
$inner = 0
$Architecture = 64
$OSVersi = [System.Environment]::OSVersion.Version
$logLocation = "C:\VolH\VHLog-$hostname.txt"

$vhlog = "Starting VolHunter`n"
Out-File -FilePath "$logLocation" -InputObject $vhlog -Encoding ASCII

###################################################################
### QUERY SYSTEM DETAILS TO DETERMINE --PROFILE= FOR VOLATILITY ###
###################################################################

Add-Content -Path "$logLocation" -Value "Determining x86 vs x64`n"
### Determine 32 vs 64 bit architecture
if([intptr]::size -eq 4){
    $Architecture = 86
}
Add-Content -Path "$logLocation" -Value "$hostname is x$Architecture`n"

### Get systeminfo ###
Add-Content -Path "$logLocation" -Value "Determining OS & Revision for Volatility profile`n"
$sysInfo = systeminfo.exe
$ram = (($sysinfo | select-string 'Total Physical Memory:').ToString().Split(':')[1].Trim()).Replace(" MB","")
$diskSpace = ( gwmi Win32_LogicalDisk -filter "deviceid='C:'" | Select DeviceID, @{Name="FreeMB";Expression={[math]::Round($_.Freespace/1MB,2)}} ).FreeMB
$osVersion = $sysInfo | select-string "OS Version"
$sysInfo = $sysInfo | select-string "OS Name"
Add-Content -Path "$logLocation" -Value "$hostname has $ram MB of RAM`n"
Add-Content -Path "$logLocation" -Value "$hostname has $diskSpace MB of free space on C:`n"
if($diskSpace -lt ([int]$freeRam + 2000) ){
    Add-Content -Path "C:VolH\VHLog.txt" -Value "Not enough free disk space`n"
    $volDone = "Not enough freespace on C:\ to run`n"
    Out-File -FilePath "C:\VolH\VolDone.txt" -InputObject $volDone -Encoding ASCII
    return
}
Add-Content -Path "$logLocation" -Value "$osVersion `n"
Add-Content -Path "$logLocation" -Value "$sysInfo `n"

### Build Volatility --profile variable based on OSVersion.Version and systeminfo output ###
switch ($sysInfo){
    # Windows 10 Ver 10586/14393/none x86/64 #
    {$_ -like "*Windows 10*"} { 
        if( ($osVersion -like "*10586*") -or ($osVersion -like "*14393*") ){$volProfile = "Win10x"+$Architecture+"_"+$OSVersi.Build}
        else{$volProfile = "Win10x"+$Architecture}
    }

    # Server 2016 Ver 14393 #
    {$_ -like "*Server 2016*"} { $volProfile = "Win2016x64_14393" } #End Server2016 switch

    # Server 2012 #
    {$_ -like "*Server 2012 *"} { $volProfile = "Win2012x64" }

    # Server 2012R2, Ver 18340 #
    {$_ -like "*Server 2012 R2*"} {
        if($osVersion -like "*18340*"){ $volProfile = "Win2012R2x64_18340" }
        else{ $volProfile = "Win2012R2x64" }
    }

    # Server 2008, SP1/2, x86/64 #
    {$_ -like "*Server*2008 Standard*"} {
        if($osVersion -like "*Service*Pack*1*"){ $volProfile = "Win2008SP1x"+$Architecture }
        else{ $volProfile = "Win2008SP2x"+$Architecture }
    }

    # Server 2008 R2 SP0/1 & SP1_23418 #
    {$_ -like "*Server 2008 R2*"} {
        if( !($osVersion -like "*Service Pack 1*") ){ $volProfile = "Win2008R2SP0x64" }
        elseif($osVersion -like "*23418*"){ $volProfile = "Win2008R2SP1x64_23418" }
        else{ $volProfile = "Win2008R2SP1x64" }
    }

    # Server 2003 SP0x86, SP1x86/64, SP2x86/64 #
    {$_ -like "Server 2003*"} {
        if($osVersion -like "*Service Pack 1*"){ $volProfile = "Win2003SP1x"+$Architecture }
        elseif($osVersion -like "*Service Pack 2*"){ $volProfile = "Win2003SP2x"+$Architecture }
        else{ $volProfile = "Win2003SP0x86" }
    }

    # Vista SP0/1/2 x86/x64 #
    {$_ -like "*Vista*"} {
        if($osVersion -like "*Service Pack 1*"){ $volProfile = "VistaSP1x"+$Architecture }
        elseif($osVersion -like "*Service Pack 2*"){ $volProfile = "VistaSP2x"+$Architecture }
        else{ $volProfile = "VistaSP0x"+$Architecture }
    }

    # Windows 7 SP0x64/86, SP1x64/86, SP1_23418x64/86 #
    {$_ -like "*Windows 7*"} {
        if( !($osVersion -like "*Service Pack*") ){ $volProfile = "Win7SP0x"+$Architecture }
        elseif($osVersion -like "*23418*"){ $volProfile = "Win7SP1x"+$Architecture + "_23418" }
        else{ $volProfile = "Win7SP1x"+$Architecture }
    }

    # Windows 8.1 #
    {$_ -like "*Windows 8.1*"} {
        if($osVersion -like "*18340*"){ $volProfile = "Win8SP1x64_18340" }
        else{ $volProfile = "Win8SP1x"+$Architecture }
    }

    # Windows 8 #
    {$_ -like "*Windows 8 *"} { $volProfile = "Win8SP0x"+$Architecture }

    default {$volProfile = "ERROR"}
}

Out-File -FilePath "C:\VolH\VolProfile.txt" -InputObject $volProfile -Encoding ASCII
Add-Content -Path "$logLocation" -Value "Volatility Profile = $volProfile `n"

if($volProfile -eq "ERROR"){ 
    Out-File -FilePath "C:\VolH\UNRECOGNIZEDPROFILE.txt" -InputObject $volProfile -Enocding ASCII
    exit
}

###############################
### Run memory dumping tool ###
###############################

### Dump Memory ###
if($dumpFlag){
    if($Architecture -eq "64"){
        $dumpCommand = "C:\VolH\Tools\DumpIt-64.exe"
    }
    else{
        $dumpCommand = "C:\VolH\Tools\DumpIt-86.exe"
    }
    Add-Content -Path "$logLocation" -Value "Starting memory dump`n"
    $start = Get-Date
    Start-Process -Filepath $dumpCommand -ArgumentList "/Q /N /J /T RAW /OUTPUT $imgLocation" -wait
    $end = Get-Date
    $dumpDone = "DumpIt Completed"
    Out-File -FilePath "C:\VolH\DumpDone.txt" -InputObject $dumpDone -Encoding ASCII
    Add-Content -Path "$logLocation" -Value "Memory dump completed in $($end-$start) H:M:S.MS`n"
}

###########################################################
### Run RunScans to get Volatility to analyze the image ###
###########################################################
$command = "C:\VolH\Tools\volatility.exe"



    ############################################
    ### Use for testing sample memory images ###
    ############################################
    #$hostName = "conficker"
    #$imgLocation = "C:\VolH\Image\$hostName.img"
    #$volProfile = "WinXPSP2x86"



if($volFlag){
    ### TEMPORARILY CHANGE $env:temp TO BYPASS BLOCKED TEMP FOLDER EXECUTION ###
    Add-Content -Path "$logLocation" -Value "Changing temp environment variables`n"
    $backupTemp = $env:temp
    $env:temp = "C:\VolH\"
    $env:tmp = "C:\VolH\"

    if( ($Plugins -like "*malfind*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Running malfind plugin`n"
        $outFile = $outputDir + "malfind.json"
        $start = Get-Date
        Start-Process -Filepath $command -ArgumentList "-f $imgLocation --profile=$volProfile malfind --output=json" -RedirectStandardOutput $outFile -wait
        $end = Get-Date
        Add-Content -Path "$logLocation" -Value "Malfind plugin completed in $($end-$start) H:M:S.MS`n"
    }

    if( ($Plugins -like "*ssdt*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Running ssdt plugin`n"
        $outFile = $outputDir + "ssdt.json"
        $start = Get-Date
        Start-Process -Filepath $command -ArgumentList "-f $imgLocation ssdt --output=json --profile=$volProfile" -RedirectStandardOutput $outFile -wait
        $end = Get-Date
        Add-Content -Path "$logLocation" -Value "SSDT plugin completed in $($end-$start) H:M:S.MS`n"
    }

    if( ($Plugins -like "*cmdline*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Running cmdline plugin`n"
        $start = Get-Date
        $outFile = $outputDir + "cmdline.json"
        Start-Process -Filepath $command -ArgumentList "-f $imgLocation cmdline --output=json --profile=$volProfile" -RedirectStandardOutput $outFile -wait
        $end = Get-Date
        Add-Content -Path "$logLocation" -Value "Cmdline plugin completed in $($end-$start) H:M:S.MS`n"
    }

    if( ($Plugins -like "*psscan*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Running psscan plugin`n"
        $start = Get-Date
        $outFile = $outputDir + "psscan.json"
        Start-Process -Filepath $command -ArgumentList "-f $imgLocation psscan --output=json --profile=$volProfile" -RedirectStandardOutput $outFile -wait
        $end = Get-Date
        Add-Content -Path "$logLocation" -Value "PSScan plugin completed in $($end-$start) H:M:S.MS`n"
    }

    if( ($Plugins -like "*mutantscan*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Running mutantscan plugin`n"
        $start = Get-Date
        $outFile = $outputDir + "mutantscan.json"
        Start-Process -FilePath $command -ArgumentList "-f $imgLocation mutantscan --output=json --profile=$volProfile" -RedirectStandardOutput $outFile -wait
        $end = Get-Date
        Add-Content -Path "$logLocation" -Value "MutantScan plugin completed in $($end-$start) H:M:S.MS`n"
    }

    ### FIX TEMP FOLDER CHANGE ###
    $env:temp = $backupTemp
    $env:tmp = $backupTemp
    Add-Content -Path "$logLocation" -Value "Temp environment variables restored`n"

    ###########################################################
    ### Parse Volatility json output to prepare for Elastic ###
    ###########################################################
    #Standard Elastic formatting
    $OutStr = ""
    $startNew = "{"
    $ending = "}"
    $SYS = '"host.hostname":'
    $timeStamp = '"@timestamp":'
    $verStr = '"@ecs_version":"1",'
    $agentStr = '"@agent.name":"Volatility",'
    $investigatedStr = '"investigated":"false",'

    ######### SECTION 1: Parse & Ship PSSCAN module #########
    if( ($Plugins -like "*psscan*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Parsing PSSCAN`n"
        $pluginStr = '"event.module":"PSSCAN"'
        $offsetStr = '"event.Offset":'
        $procStr = '"event.Process":'
        $pidStr = '"event.PID":'
        $ppidStr = '"event.PPID":'
        $pdbStr = '"event.PDB":'
        $timeCreatedStr = '"event.TimeCreated":'
        $timeExitedStr = '"event.TimeExited":'

        #Create header for Elastic ingestion
        $OutStr = '{"index":{"_id":null,"_index":"psscan","_type":"doc","_routing":null}}' + "`n"

        #Get Volatility output file from PSSCAN plugin
        $word = Get-Content -Path ($outputDir + "psscan.json")

        #Format & Split volatility output, store in $array
        $length = $word.length -99
        $word = $word.substring(10,$length)
        $word = $word -replace ']',"`n"
        $word = $word.Replace(", [","")
        $word = $word.Replace("[","")
        $word = $word.Replace(", ","~")
        $word = $word -replace '"([a-z\.]+)"~','$1~'
        $word = $word.Replace('"',"'")
        $word = $word.Replace("'`n","'~")
        $array = $word.split('~')

        #Nested loop.
        #Outer while(< $array.Length), iterates over all items from original plugin execution, now each its own array index
        #Inner loop, tags each item with its field, formats $OutStr for eventual sending to Elastic
        #Each finding of psscan plugin returns 7 items
        #Offset, Process, PID, PPID, PDB, Time Created, Time Exited
        while($outer -lt $array.Length){
            while($inner -lt 7){
                #Opens new index item, adds formatting, system, @timestamp, Offset
                if($inner -eq 0){            
                    $OutStr = $OutStr + $startNew + $SYS + '"' + $hostName + '",' + $timeStamp + '"' + $time + '",' + $investigatedStr + $offsetStr + '"' + $array[$outer] + '",'
                }
                #Add Process
                if($inner -eq 1){
                    $OutStr = $OutStr + $procStr + '"' + $array[$outer] + '",'
                }
                #Add PID
                if($inner -eq 2){
                    $OutStr = $OutStr + $pidStr + '"' + $array[$outer] + '",'
                }

                #Add PPID
                if($inner -eq 3){
                    $OutStr = $OutStr + $ppidStr + '"' + $array[$outer] + '",'
                }

                #Add PDB
                if($inner -eq 4){
                    $OutStr = $OutStr + $pdbStr + '"' + $array[$outer] + '",'
                }

                #Add Time Created
                if($inner -eq 5){
                    $OutStr = $OutStr + $timeCreatedStr + '"' + $array[$outer] + '",'
                }
                #Add Time Exited, @version, plugin, closer
                if($inner -eq 6){
                    $OutStr = $OutStr + $timeExitedStr + '"' + $array[$outer] + '",' + $verStr + $pluginStr + $ending
                }

                $outer++
                $inner++
            }
            $inner = 0

            #SAVE THE STR TO FILE, RESET LOOP
            $path = $outputDir + "PSSCAN-$hostName.txt"
            Out-File -FilePath $path -InputObject $OutStr -Encoding ASCII -Append
            $OutStr = '{"index":{"_id":null,"_index":"psscan","_type":"doc","_routing":null}}' + "`n"
        }
        "PSSCAN parsing complete"
        $inner = 0
        $outer = 0
        Add-Content -Path "$logLocation" -Value "Finished parsing PSSCAN`n"
    }

    ######### SECTION 2: Parse & Ship SSDT module #########
    if( ($Plugins -like "*ssdt*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Parsing SSDT`n"
        $tableStr = '"event.Table":'
        $tableOffsetStr = '"event.TableOffset":'
        $numEntriesStr = '"event.NumEntries":'
        $entryStr = '"event.Entry":'
        $addrStr = '"event.Addr":'
        $funcStr = '"event.Function":'
        $ownerStr = '"event.Owner":'
        $pluginStr = '"event.module":"SSDT"'

        #Create header for Elastic ingestion
        $OutStr = '{"index":{"_id":null,"_index":"ssdt","_type":"doc","_routing":null}}' + "`n"

        #Get Volatility output file from SSDT plugin
        [string]$word = Get-Content -Path ($outputDir + "ssdt.json")

        #Format & Split volatility output, store in $array
        $length = $word.length-206
        $word = $word.substring(113,$length)
        $word = $word.Replace("], [",",")
        $word = $word.Replace('"',"")
        $word = $word.Replace(" ","")
        $array = $word.split(',')

        #Nested loop.
        #Outer while(< $array.Length), iterates over all items from original plugin execution, now each its own array index
        #Inner loop, tags each item with its field, formats $OutStr for eventual sending to Elastic
        #Each finding of ssdt plugin returns 7 items
        #Table, TableOffset, NumEntries, Entry, Address, Function, Owner
        while($outer -lt $array.Length){
            while($inner -lt 7){
                #Opens new index item, adds formatting, system, @timestamp, Table
                if($inner -eq 0){            
                    $OutStr = $OutStr + $startNew + $SYS + '"' + $hostName + '",' + $timeStamp + '"' + $time + '",' + $investigatedStr + $tableStr + '"' + $array[$outer] + '",'
                }
                #Add TableOffset
                if($inner -eq 1){
                    $OutStr = $OutStr + $tableOffsetStr + '"' + $array[$outer] + '",'
                }
                #Add NumEntries
                if($inner -eq 2){
                    $OutStr = $OutStr + $numEntriesStr + '"' + $array[$outer] + '",'
                }

                #Add Entry
                if($inner -eq 3){
                    $OutStr = $OutStr + $entryStr + '"' + $array[$outer] + '",'
                }

                #Add Address
                if($inner -eq 4){
                    $OutStr = $OutStr + $addrStr + '"' + $array[$outer] + '",'
                }

                #Add Function
                if($inner -eq 5){
                    $OutStr = $OutStr + $funcStr + '"' + $array[$outer] + '",'
                }
                #Add Owner, @version, plugin, closer
                if($inner -eq 6){
                    $OutStr = $OutStr + $ownerStr + '"' + $array[$outer] + '",' + $verStr + $pluginStr + $ending
                }

                $outer++
                $inner++
            }
            $inner = 0

            #SAVE THE STR TO FILE, SEND TO ELASTIC, RESET
            $path = $outputDir + "SSDT-$hostName.txt"
            Out-File -FilePath $path -InputObject $OutStr -Encoding ASCII -Append
            $OutStr = '{"index":{"_id":null,"_index":"ssdt","_type":"doc","_routing":null}}' + "`n"
        }
        "SSDT parsing complete"
        $inner = 0
        $outer = 0
        Add-Content -Path "$logLocation" -Value "Finished parsing SSDT`n"
    }

    ######### SECTION 3: Parse & Ship CMDLINE module #########
    if( ($Plugins -like "*cmdline*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Parsing CMDLINE`n"
        $processStr = '"event.process":'
        $pidStr = '"event.pid":'
        $cmdStr = '"event.CommandLine":'
        $pluginStr = '"event.module":"CMDLINE"'

        #Create header for Elastic ingestion
        $OutStr = '{"index":{"_id":null,"_index":"cmdline","_type":"doc","_routing":null}}' + "`n"

        #Get Volatility output file from CMDLINE plugin
        [string]$word = Get-Content -Path ($outputDir + "cmdline.json")

        #Format Volatility Output
        $length = $word.length -60
        $word = $word.substring(11,$length)
        $word = $word.Replace("], [","~[")
        $word = $word.Replace("[","")
        $word = $word -replace ', ([\d]+), ','~$1~'
        $word = $word -replace '"',"'"
        $array = $word.split('~')

        #Nested loop.
        #Outer while(< $array.Length), iterates over all items from original plugin execution, now each its own array index
        #Inner loop, tags each item with its field, formats $OutStr for eventual sending to Elastic
        #Each finding of cmdline plugin returns 3 items
        #Process, PID, Command Line Arguments
        while($outer -lt $array.Length){
            while($inner -lt 3){
                #Opens new index item, adds formatting, system, @timestamp, process
                if($inner -eq 0){
                    $array[$outer] = $array[$outer].substring(1,($array[$outer].length-2))             
                    $OutStr = $OutStr + $startNew + $SYS + '"' + $hostName + '",' + $timeStamp + '"' + $time + '",' + $investigatedStr + $processStr + '"' + $array[$outer] + '",'
                }
                #Add PID
                if($inner -eq 1){
                    $OutStr = $OutStr + $pidStr + '"' + $array[$outer] + '",'
                }
                #Add Command Line Arguments, @version, plugin, closer
                if($inner -eq 2){
                    $array[$outer] = $array[$outer].substring(1,($array[$outer].length-2))
                    $OutStr = $OutStr + $cmdStr + '"' + $array[$outer] + '",' + $verStr + $pluginStr + $ending
                }

                $outer += 1
                $inner += 1
            }
            $inner = 0
    
            $path = $outputDir + "CMDLINE-$hostName.txt"
            Out-File -FilePath $path -InputObject $OutStr -Encoding ASCII -Append
            $OutStr = '{"index":{"_id":null,"_index":"cmdline","_type":"doc","_routing":null}}' + "`n"
        }
        "Cmdline parsing complete"
        $inner = 0
        $outer = 0
        Add-Content -Path "$logLocation" -Value "Finished parsing CMDLINE`n"
    }

    ######### SECTION 4: Parse & Ship MALFIND module #########
    if( ($Plugins -like "*malfind*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Parsing Malfind`n"
        $processStr = '"event.process":'
        $pidStr = '"event.pid":'
        $memAddrStr = '"event.memAddress":'
        $vadStr = '"event.VadTag":'
        $protectionStr = '"event.Protection":'
        $flagsStr = '"event.Flags":'
        $dataStr = '"event.Data":'
        $pluginStr = '"event.module":"MALFIND"'

        #Create header for Elastic ingestion
        $OutStr = '{"index":{"_id":null,"_index":"malfind","_type":"doc","_routing":null}}' + "`n"

        #Get Volatility output file from MALFIND plugin
        $word = Get-Content -Path ($outputDir + "malfind.json")

        #Format Volatility Output
        $word = $word -replace "([\d]+), ([\d]+)",'"$1" "$2"'
        $word = $word -replace '", "','" "'
        $word = $word -replace '" "','~'
        $word = $word -replace '"',''
        $word = $word.Replace("], [","~")
        $length = $word.length -73
        $word = $word.substring(9,$length)
        $array = $word.split('~')

        #Nested loop.
        #Outer while(< $array.Length), iterates over all items from original plugin execution, now each its own array index
        #Inner loop, tags each item with its field, formats $OutStr for eventual sending to Elastic
        #Each finding of malfind plugin returns 7 items
        #Process, PID, Address, VadTag, Protection, Flags, Data
        while($outer -lt $array.Length){
            while($inner -lt 7){
                #Opens new index item, adds formatting, system, @timestamp, process
                if($inner -eq 0){            
                    #Remove extraneous newlines at start of proc names #2-end
                    if($array[$outer].Substring(0,1) -eq "`n"){
                        $subStrLen = $array[$outer].Length
                        $array[$outer] = $array[$outer].Substring(1,$subStrLen-1)
                    }
                    $OutStr = $OutStr + $startNew + $SYS + '"' + $hostName + '",' + $timeStamp + '"' + $time + '",' + $investigatedStr + $processStr + '"' + $array[$outer] + '",'
                }
                #Add PID
                if($inner -eq 1){
                    $OutStr = $OutStr + $pidStr + '"' + $array[$outer] + '",'
                }
                #Add memAddress
                if($inner -eq 2){
                    $OutStr = $OutStr + $memAddrStr + '"' + $array[$outer] + '",'
                }

                #Add VadTag
                if($inner -eq 3){
                    $OutStr = $OutStr + $vadStr + '"' + $array[$outer] + '",'
                }

                #Add Protection
                if($inner -eq 4){
                    $OutStr = $OutStr + $protectionStr + '"' + $array[$outer] + '",'
                }

                #Add Flags
                if($inner -eq 5){
                    $OutStr = $OutStr + $flagsStr + '"' + $array[$outer] + '",'
                }
                #Add Data, @version, plugin, closer
                if($inner -eq 6){
                    $OutStr = $OutStr + $dataStr + '"' + $array[$outer] + '",' + $verStr + $pluginStr + $ending
                }

                $outer++
                $inner++
            }
            $inner = 0

            $path = $outputDir + "MALFIND-$hostName.txt"
            Out-File -FilePath $path -InputObject $OutStr -Encoding ASCII -Append
            $OutStr = '{"index":{"_id":null,"_index":"malfind","_type":"doc","_routing":null}}' + "`n"
        }
        "Malfind parsing complete"
        $inner = 0
        $outer = 0
        Add-Content -Path "$logLocation" -Value "Finished parsing Malfind`n"
    }

    ### SECTION 5: Parse & Ship mutantscan module ###
    if( ($Plugins -like "*mutantscan*") -or ($Plugins -like "all") ){
        Add-Content -Path "$logLocation" -Value "Parsing MutantScan`n"
        $offsetStr = '"event.offset":'
        $ptrStr = '"event.pointer":'
        $hndStr = '"event.handle":'
        $signalStr = '"event.signal":'
        $threadStr = '"event.thread":'
        $cidStr = '"event.cid":'
        $nameStr = '"event.name":'
        $pluginStr = '"event.module":"MUTANTSCAN"'

        #Create header for Elastic ingestion
        $OutStr = '{"index":{"_id":null,"_index":"mutantscan","_type":"doc","_routing":null}}' + "`n"

        #Get Volatility output file from MUTANTSCAN plugin
        [string]$word = Get-Content -Path ($outputDir + "mutantscan.json")

        #Format Volatility Output
        $length = $word.Length - 97
        $word = $word.Substring(10,$length)
        $word = $word -replace "], ","~"
        $word = $word.Replace("[","")
        $word = $word.Replace(", ","~")
        $word = $word.Replace('"',"'")
        $array = $word.Split('~')

        #Nested loop.
        #Outer while(< $array.Length), iterates over all items from original plugin execution, now each its own array index
        #Inner loop, tags each item with its field, formats $OutStr for eventual sending to Elastic
        #Each finding of mutantscan plugin returns 7 items
        #Offset(P), Pointer, Handle, Signal, Thread, CID, Name
        while($outer -lt $array.Length){
            while($inner -lt 7){
                #Opens new index item, adds formatting, system, @timestamp, offset
                if($inner -eq 0){
                    $OutStr = $OutStr + $startNew + $SYS + '"' + $hostName + '",' + $timeStamp + '"' + $time + '",' + $investigatedStr + $offsetStr + '"' + $array[$outer] + '",'
                }
                #Add PTR
                if($inner -eq 1){
                    $OutStr = $OutStr + $ptrStr + '"' + $array[$outer] + '",'
                }
                #Add Handle
                if($inner -eq 2){
                    $OutStr = $OutStr + $hndStr + '"' + $array[$outer] + '",'
                }

                #Add Signal
                if($inner -eq 3){
                    $OutStr = $OutStr + $signalStr + '"' + $array[$outer] + '",'
                }

                #Add Thread
                if($inner -eq 4){
                    $OutStr = $OutStr + $threadStr + '"' + $array[$outer] + '",'
                }

                #Add CID
                if($inner -eq 5){
                    $OutStr = $OutStr + $cidStr + '"' + $array[$outer] + '",'
                }
                #Add name, @version, plugin, closer
                if($inner -eq 6){
                    $OutStr = $OutStr + $nameStr + '"' + $array[$outer] + '",' + $verStr + $pluginStr + $ending
                }

                $outer++
                $inner++
            }
            $inner = 0

            $path = $outputDir + "MUTANTSCAN-$hostName.txt"
            Out-File -FilePath $path -InputObject $OutStr -Encoding ASCII -Append
            $OutStr = '{"index":{"_id":null,"_index":"mutantscan","_type":"doc","_routing":null}}' + "`n"
        }
        "Mutantscan parsing complete"
        $inner = 0
        $outer = 0
        Add-Content -Path "$logLocation" -Value "Finished parsing MutantScan`n"
    }
} #End $volFlag check

##################################################
### Secure your output data from snooping eyes ###
##################################################

### Public key encrypt the .IMG file, Volatility output .JSON files, and Parsed .txt files ###
#$PublicCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)
#$ByteArray = [System.Text.Encoding]::UTF8.GetBytes($ClearText)
#$EncryptedByteArray = $PublicCert.PublicKey.Key.Encrypt($ByteArray,$true)
#$EncryptedBase64String = [Convert]::ToBase64String($EncryptedByteArray)

#############################################
### Finalize VolHunter, Record Total Time ###
#############################################
$GLOBALEND = Get-Date
Add-Content -Path "$logLocation" -Value "TOTAL RUNTIME $($GLOBALEND-$GLOBALSTART) H:M:S.MS`n"
Add-Content -Path "$logLocation" -Value "VolHunter is now complete!`n"
$volDone = "Volatility completed"
Out-File -FilePath "C:\VolH\VolDone.txt" -InputObject $volDone -Encoding ASCII