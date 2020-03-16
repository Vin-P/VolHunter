<#
.SYNOPSIS

This script will build the "Investigated.txt" file which is used
in conjunction with Kicker.ps1 -Investigated .\Investigated.txt
Builds output in the [plugin]:[id] format to set the investigated
flag to true on items so they are excluded from dashboards

.PARAMETER plugin
Mandatory parameter. Give it the name of the index you pulled from Kibana
Options are currently psscan, cmdline, ssdt, malfind

.PARAMETER KibanaOutput
Mandatory parameter. Provide local or absolute path to the saved output
from Kibana / Discover / (Arrow below timeline) / Response  after you have
searched for the items you want to set to investigated:true

.NOTES
    Author: Michael "FUMBLES" Russell
    Date:   17 June 2018
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$plugin = "malfind",
    [Parameter(Mandatory=$True,Position=1)]
        [String]$KibanaOutput=".\KibanaOut.txt"
)

$test = Get-Content $KibanaOutput
$test2 = ($test | Select-String -Pattern "_id")
$test2 = $test2 -replace("_id","")
$test2 = $test2 -replace('"": "',"")
$test2 = $test2 -replace('",',"")
$test2 = $test2 -replace('\s',"")

foreach($line in $test2){
    $OutStr = $plugin + ":" + $line
    Out-File -FilePath ".\Investigated.txt" -InputObject $OutStr -Encoding ASCII -Append
}
