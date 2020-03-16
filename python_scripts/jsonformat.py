import convert
import os.path
from os import listdir
from os.path import isfile, join

def jsonparsing(vhfilepath, output_folder):
	"""
	:brief Convert to json, remove processed files

	:param vhfilepath: File path for VolHunter data
	:param output_folder: File path of output
	"""
	###BE SURE TO UPDATE THESE
	cmdline_output = output_folder + 'cmdline.json'
	dlllist_output = output_folder + 'dlllist.json'
	ldrmodules_output = output_folder + "ldrmodules.json"
	malfind_output = output_folder + 'malfind.json'
	netscan_output = output_folder + "netscan.json"
	pslist_output = output_folder + 'pslist.json'
	psxview_output = output_folder + 'psxview.json'
	ssdt_output = output_folder + 'ssdt.json'
	timers_output = output_folder + "timers.json"

	#Query user to auto discard bad data results
	while True:
		print("Do you want to auto discard bad scan results?")
		user_input = int(input("1: Yes\n2: No\n"))
		if user_input == 1:
			autoDiscard = 1
			break
		elif user_input == 2:
			autoDiscard = 0
			break
		else:
			print("Invalid Input")

	#Iterate over and process each file in the folder
	for dirpath,_,filenames in os.walk(vhfilepath):
		for file_name in filenames:
			file_process = os.path.abspath(os.path.join(dirpath, file_name))

			if "cmdline" in file_process:
				convert.cmdline(file_process, cmdline_output, autoDiscard)
			elif "ssdt" in file_process:
				convert.ssdt(file_process, ssdt_output, autoDiscard)
			elif "malfind" in file_process:
				convert.malfind(file_process, malfind_output, autoDiscard)
			elif "psxview" in file_process:
				convert.psxview(file_process, psxview_output, autoDiscard)
			elif "pslist" in file_process:
				convert.pslist(file_process, pslist_output, autoDiscard)
			elif "dlllist" in file_process:
				convert.dlllist(file_process, dlllist_output, autoDiscard)
			elif "timers" in file_process:
				convert.timers(file_process, timers_output, autoDiscard)
			elif "ldrmodules" in file_process:
				convert.ldrmodules(file_process, ldrmodules_output, autoDiscard)
			elif "netscan" in file_process:
				convert.netscan(file_process, netscan_output, autoDiscard)
			else:
				print("Unknown file type: {}".format(file_process))
