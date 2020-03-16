VolHunter aims to automate the initial triage of volatile memory on remote systems, and allow for human review of the data through Kibana and ElasticSearch.

Current limitations:
- You MUST run VolHunter from a system with PowerShell version 5 for full capability
- Target systems must either be running PSv3+ or have WMIC enabled if using PSv1 or PSv2
- Currently only supports Windows 7+/Server 03+
- Requires use of administrator credentials (Only type 3 logons used, creds are protected)
- Only runs max of 5 Volatility plugins (More to be added later)

Examples and explanations are included in comments of the scripts. Operator manual to be developed by DOK.

Status: 90COS/CYK tasked to finish. Start date - 12/09/19. TIP submission pending.

Requirements:
-Powershell v3+
	-Fallback to WMIC and SMB if unable to use Powershell [Not complete]
-Push and execute on X number of hosts at the same time (user defined number of threads)
-Ability to check status of all or 1 jobs
	-Detailed status [Not complete]
-Ability to pull results
-Ability to delete everything when done 
-Convert output to UTF-8
-Convert output to JSON for Kibana
-Pass data to Elastic
-Enrich data
-Erase data or flag as done

Wish List:
-Linux version [This would likely solve 92COS 2nd TIP submission for *Nix Memory Snapshots]
-Erase Windows logs
-Additional modules
-Volitility 3.0 support

Developer TODOs:
-Code review
-Add error/bounds checking
-Convert to Python 3
-Document and comment code
	-Create TTP page
-Create test plan
