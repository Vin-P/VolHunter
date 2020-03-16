from os import listdir
import os.path
import json
import re

def printError(errLine, errMessage, fd):
	"""
	:brief Prints error and either discards or exits

	:param errLine: Line in fd
	:param errMessage: Error message
	:param fd: File descriptor
	"""
	print(errMessage)
	while True:
		print(errLine)
		errorChoice = input("Error, [d]iscard data and continue, [a]bort: ")
		if (errorChoice == "d"):
			print("Discarding data..")
			return
		elif (errorChoice == "a"):
			print("Aborting..")
			fd.close()
			exit()
		else:
			print("Invalid Input")

def cmdline(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	delin = "************************************************************************"
	CL = "Command line : "
	cmdline_doc = {"process.name" : "null" , "process.pid" : "null" , "process.arguments" : "null" , "hostname" : "null" , "plugin" : "cmdline" , "investigated" : "false", "tags" : ""}

	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)

	filename = input_file.replace("cmdline-","").replace(".txt","")
	firstline = 1

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if (firstline == 1):
					firstline = 0
					continue
				if line.startswith(delin):
					cmdline_doc['hostname'] = filename
					output_file.write(json.dumps(cmdline_doc))
					output_file.write("\n")
					cmdline_doc = {"process.name" : "null" , "process.pid" : "null" , "process.arguments" : "null" , "hostname" : "null" , "plugin" : "cmdline" , "investigated" : "false", "tags" : ""}
				else:
					if line.startswith(CL):
						args = line.replace(CL,'')
						cmdline_doc['process.arguments'] = args.rstrip().replace('"',"'")
					else:
						proc = line.split()
						if proc[0].rstrip() == "pid:":
							raise ValueError('Suspected no process name found')
						if int(proc[2].rstrip()) > 1000000:
							raise ValueError('PID too high')
						cmdline_doc['process.name'] = proc[0].rstrip()
						cmdline_doc['process.pid'] = proc[2].rstrip()
						alphaCheck = bool(re.match('^[a-zA-Z0-9 _.-]+$', cmdline_doc['process.name']))
						if not alphaCheck:
							raise ValueError('222 NonAlphaNumeric characters in process name')
			except Exception as err:
				if(autoDiscard == 1):
					continue
				else:
					printError(line, err, fd)

	cmdline_doc['hostname'] = filename
	if cmdline_doc['process.pid'] != "null":
		output_file.write(json.dumps(cmdline_doc))
		output_file.write("\n")
		cmdline_doc = {"process.name" : "null" , "process.pid" : "null" , "process.arguments" : "null" , "hostname" : "null" , "plugin" : "cmdline" , "investigated" : "false", "tags" : ""}
	fd.close()
	output_file.close()
	return

def ssdt(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	ssdt_doc = {"ssdt.function" : "null" , "ssdt.owner" : "null" , "ssdt.entry" : "null" , "ssdt.address" : "null" , "hostname" : "null" , "plugin" : "ssdt" , "investigated" : "false", "tags" : ""}

	#File to write to
	output_file = open(output_path,"a+")
	input_file = os.path.basename(input_path)
	filename = input_file.replace("ssdt-","").replace(".txt","")

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if not "Entry " in line:
					continue
				else:
					ssdt = line.split()
					ssdt_doc['ssdt.function'] = ssdt[3]
					ssdt_doc['ssdt.owner'] = ssdt[6]
					ssdt_doc['ssdt.entry'] = ssdt[1].replace(":","")
					ssdt_doc['ssdt.address'] = ssdt[2]
					ssdt_doc['hostname'] = filename
					output_file.write(json.dumps(ssdt_doc))
					output_file.write("\n")
					ssdt_doc = {"ssdt.function" : "null" , "ssdt.owner" : "null" , "ssdt.entry" : "null" , "ssdt.address" : "null" , "hostname" : "null" , "plugin" : "ssdt" , "investigated" : "false", "tags" : ""}
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()
	output_file.close()
	return

def malfind(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	malfind_doc = {"process.name" : "null" , "process.pid" : "null" , "malfind.address" : "null" , "hostname" : "null" , "plugin" : "malfind" , "investigated" : "false" , "malfind.ascii" : "null" , "malfind.assembly" : "null" , "tags" : ""}
	tracktwo = "null"
	trackthree = "null"
	tagarray = []
	#File to write to
	output_file = open(output_path,"a+")
	input_file = os.path.basename(input_path)

	filename = input_file.replace("malfind-","").replace(".txt","")
	group_track = 0

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if ((not line) or (line == "\n")):
					group_track += 1
					if group_track == 3:
						group_track = 0
						malfind_doc['hostname'] = filename
						tracktwoarray = tracktwo.split("\n")
						trackthreearray = trackthree.split("\n")
						malfind_doc['malfind.ascii'] = tracktwoarray
						malfind_doc['malfind.assembly'] = trackthreearray
						#CHECK FOR MZ HEADERS
						if any("MZ" in s for s in malfind_doc['malfind.ascii']):
							tagarray.append("MZHEADER")
						#CHECK FOR FUNCTION PROLOGUE
						if any("MOV EBP, ESP" in s for s in malfind_doc['malfind.assembly']):
							tagarray.append("FUNCPROLOGUE")
						malfind_doc['tags'] = tagarray
						output_file.write(json.dumps(malfind_doc))
						output_file.write("\n")
						tagarray = []
						tracktwo = "null"
						trackthree = "null"

						malfind_doc = {"process.name" : "null" , "process.pid" : "null" , "malfind.address" : "null" , "hostname" : "null" , "plugin" : "malfind" , "investigated" : "false" , "malfind.ascii" : "null" , "malfind.assembly" : "null" , "tags" : ""}
						continue
				else:
					if group_track == 0:
						if "Process: " in line:
							data = line.split()
							malfind_doc['process.name'] = data[1]
							malfind_doc['process.pid'] = data[3]
							malfind_doc['malfind.address'] = data[5]
					if group_track == 1:
						if tracktwo == "null":
							tracktwo = line.replace('"',"'").replace("[","{").replace("]","}")
						else:
							tracktwo = tracktwo + line.replace('"',"'").replace("[","{").replace("]","}")
					if group_track == 2:
						if trackthree == "null":
							trackthree = line.replace('"',"'").replace("[","{").replace("]","}")
						else:
							trackthree = trackthree + line.replace('"',"'").replace("[","{").replace("]","}")
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()
	output_file.close()
	return

def psxview(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	psxview_doc = {"process.offset.physical" : "null" , "process.name" : "null" , "process.pid" : "null" , "psxview.pslist" : "null" , "hostname" : "null" , "plugin" : "psxview" , "investigated" : "false" , "psxview.psscan" : "null" , "psxview.thrdproc" : "null" , "psxview.pspcid" : "null" , "psxview.csrss" : "null" , "psxview.session" : "null" , "psxview.deskthrd" : "null" , "psxview.exittime" : "null", "tags" : ""}

	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)

	filename = input_file.replace("psxview-","").replace(".txt","")
	openlines = 0

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if openlines < 2:
					openlines += 1
				else:
					data = line.split()
					psxview_doc['hostname'] = filename
					if len(data) == 13:
						psxview_doc['process.offset.physical'] = data[0]
						psxview_doc['process.name'] = data[1]
						psxview_doc['process.pid'] = data[2]
						psxview_doc['psxview.pslist'] = data[3]
						psxview_doc['psxview.psscan'] = data[4]
						psxview_doc['psxview.thrdproc'] = data[5]
						psxview_doc['psxview.pspcid'] = data[6]
						psxview_doc['psxview.csrss'] = data[7]
						psxview_doc['psxview.session'] = data[8]
						psxview_doc['psxview.deskthrd'] = data[9]
						psxview_doc['psxview.exittime'] = data[10] + " " + data[11] + " " + data[12]
					#Missing process.name and timestamp
					elif len(data) == 9:
						psxview_doc['process.offset.physical'] = data[0]
						#psxview_doc['process.name'] = data[1]
						psxview_doc['process.pid'] = data[1]
						psxview_doc['psxview.pslist'] = data[2]
						psxview_doc['psxview.psscan'] = data[3]
						psxview_doc['psxview.thrdproc'] = data[4]
						psxview_doc['psxview.pspcid'] = data[5]
						psxview_doc['psxview.csrss'] = data[6]
						psxview_doc['psxview.session'] = data[7]
						psxview_doc['psxview.deskthrd'] = data[8]
						psxview_doc['psxview.exittime'] = "null"
					#Missing timestamp
					elif len(data) == 10:
						psxview_doc['process.offset.physical'] = data[0]
						psxview_doc['process.name'] = data[1]
						psxview_doc['process.pid'] = data[2]
						psxview_doc['psxview.pslist'] = data[3]
						psxview_doc['psxview.psscan'] = data[4]
						psxview_doc['psxview.thrdproc'] = data[5]
						psxview_doc['psxview.pspcid'] = data[6]
						psxview_doc['psxview.csrss'] = data[7]
						psxview_doc['psxview.session'] = data[8]
						psxview_doc['psxview.deskthrd'] = data[9]
						psxview_doc['psxview.exittime'] = "null"
					else:
						raise ValueError('Suspected bad scan result with incorrect number of fields')

					alphaCheck = bool(re.match('^[a-zA-Z0-9 _.-]+$', psxview_doc['process.name']))
					if not alphaCheck:
						raise ValueError('NonAlphaNumeric characters in process name')
					numCheck = bool(re.match('^[0-9]+$', psxview_doc['process.pid']))
					if not numCheck:
						raise ValueError('NonNumeric characters in process pid')
					output_file.write(json.dumps(psxview_doc))
					output_file.write("\n")
					psxview_doc = {"process.offset.physical" : "null" , "process.name" : "null" , "process.pid" : "null" , "psxview.pslist" : "null" , "hostname" : "null" , "plugin" : "psxview" , "investigated" : "false" , "psxview.psscan" : "null" , "psxview.thrdproc" : "null" , "psxview.pspcid" : "null" , "psxview.csrss" : "null" , "psxview.session" : "null" , "psxview.deskthrd" : "null" , "psxview.exittime" : "null", "tags" : ""}
					continue
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()

def pslist(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	pslist_doc = {"process.offset.virtual" : "null" , "process.name" : "null" , "process.pid" : "null" , "process.ppid" : "null" , "hostname" : "null" , "plugin" : "pslist" , "investigated" : "false" , "process.threads" : "null" , "process.handles" : "null" , "process.session" : "null" , "process.wow64" : "null" , "process.starttime" : "null" , "process.exittime" : "null", "process.parent.name" : "null", "tags" : ""}
	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)

	filename = input_file.replace("pslist-","").replace(".txt","")
	openlines = 0

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if openlines < 2:
					openlines += 1
				else:
					data = line.split()
					if(len(data) == 7):
						raise ValueError('Suspected false EPROCESS artifact')
					if not (data[2].isdigit()):
						raise ValueError('Corrupted entry')
					pslist_doc['process.offset.virtual'] = data[0]
					pslist_doc['process.name'] = data[1]
					pslist_doc['process.pid'] = data[2]
					pslist_doc['process.ppid'] = data[3]
					pslist_doc['process.threads'] = data[4]
					pslist_doc['process.handles'] = data[5]
					pslist_doc['process.session'] = data[6]
					pslist_doc['process.wow64'] = data[7]
					if len(data) > 8:
						pslist_doc['process.starttime'] = data[8] + " " + data[9] + " " + data[10]
						pslist_doc['hostname'] = filename
					if len(data) == 14:
						pslist_doc['process.exittime'] = data[11] + " " + data[12] + " " + data[13]
					else:
						pslist_doc['process.exittime'] = "null"
					output_file.write(json.dumps(pslist_doc))
					output_file.write("\n")
					pslist_doc = {"process.offset.virtual" : "null" , "process.name" : "null" , "process.pid" : "null" , "process.ppid" : "null" , "hostname" : "null" , "plugin" : "pslist" , "investigated" : "false" , "process.threads" : "null" , "process.handles" : "null" , "process.session" : "null" , "process.wow64" : "null" , "process.starttime" : "null" , "process.exittime" : "null", "process.parent.name" : "null", "tags" : ""}
					continue
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()

def nonblank_lines(fd):
	for line in fd:
		stripped_line = line.rstrip()
		if stripped_line:
			yield stripped_line

def dlllist(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	CL = "Command line :"
	basearray = []
	sizearray = []
	loadcountarray = []
	loadtimearray = []
	patharray = []
	tagarray = []

	dlllist_doc = {"process.name" : "null" , "process.pid" : "null" , "process.arguments" : "null" , "hostname" : "null" , "plugin" : "dlllist" , "investigated" : "false" , "dlllist.base" : "null" , "dlllist.size" : "null" , "dlllist.loadcount" : "null" , "dlllist.loadtime" : "null" , "dlllist.path" : "null" , "tags" : ""}
	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)

	filename = input_file.replace("dlllist-","").replace(".txt","")
	firstline = 1
	groupcount = 0

	with open(input_path,"r") as f_in:
		for liners in nonblank_lines(f_in):
			try:
				line = liners.rstrip()
				if (firstline == 1):
					firstline = 0
					continue
				if "*****" in line:
					dlllist_doc['hostname'] = filename
					dlllist_doc['dlllist.base'] = basearray
					dlllist_doc['dlllist.size'] = sizearray
					dlllist_doc['dlllist.loadcount'] = loadcountarray
					dlllist_doc['dlllist.loadtime'] = loadtimearray
					dlllist_doc['dlllist.path'] = patharray
					#Search for non system32 paths
					for s in dlllist_doc['dlllist.path']:
						if (("C:" not in s.upper()) and ("WINDOWS" not in s.upper()) and (".EXE" not in s.upper()) and ("NULL" not in s.upper()) and (s != "")):
							tagarray.append("InjectedDLL")
							tagarray.append(s)
							dlllist_doc['tags'] = tagarray
						elif (("SYSTEM32" not in s.upper()) and ("NULL" not in s.upper()) and (".EXE" not in s.upper()) and (s != "") and ("WINSXS" not in s.upper())  and ("SYSWOW64" not in s.upper())  and ("WINDOWS\\MICROSOFT.NET" not in s.upper())  and ("WINDOWS\\ASSEMBLY" not in s.upper())):
							tagarray.append("NonSys32DLL")
							tagarray.append(s)
							dlllist_doc['tags'] = tagarray

					groupcount = 0
					output_file.write(json.dumps(dlllist_doc))
					output_file.write("\n")
					dlllist_doc = {"process.name" : "null" , "process.pid" : "null" , "process.arguments" : "null" , "hostname" : "null" , "plugin" : "dlllist" , "investigated" : "false" , "dlllist.base" : "null" , "dlllist.size" : "null" , "dlllist.loadcount" : "null" , "dlllist.loadtime" : "null" , "dlllist.path" : "null" , "tags" : ""}
					basearray = []
					sizearray = []
					loadcountarray = []
					loadtimearray = []
					patharray = []
					tagarray = []
				else:
					if groupcount == 0:
						if line.startswith(CL):
							args = line.replace(CL,'')
							dlllist_doc['process.arguments'] = args.rstrip().replace('"',"'")
							groupcount += 1
						elif line.startswith("Unable to read PEB"):
							continue
						else:
							proc = line.split()
							if proc[0].rstrip() == "pid:":
								raise ValueError('Suspected no process name found')
							if (int(proc[2].rstrip()) > 400000):
								raise ValueError('Non realistic PID value')
							dlllist_doc['process.name'] = proc[0].rstrip()
							dlllist_doc['process.pid'] = proc[2].rstrip()
					else:
						if line.startswith("Base"):
							continue
						elif line.startswith("-----"):
							continue
						else:
							data = line.split()
							basearray.append(data[0])
							sizearray.append(data[1])
							loadcountarray.append(data[2])
							if len(data) == 3:
								patharray.append("null")
								loadtimearray.append("null")
							elif (data[3].startswith("2") or data[3].startswith("1")):
								timeval = data[3] + data[4] + data[5]
								loadtimearray.append(timeval)
								#6-end of array goes to path
								ind = 6
								pathval = ""
								while(ind < len(data)):
									pathval = pathval + " " + data[ind]
									ind = ind + 1
								patharray.append(pathval)
							else: #3-end of array REST OF LENGTH GOES TO PATH
								ind = 3
								pathval = ""
								while(ind < len(data)):
									pathval = pathval + " " + data[ind]
									ind = ind + 1
								patharray.append(pathval)
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, f_in)

	dlllist_doc['hostname'] = filename
	dlllist_doc['dlllist.base'] = basearray
	dlllist_doc['dlllist.size'] = sizearray
	dlllist_doc['dlllist.loadcount'] = loadcountarray
	dlllist_doc['dlllist.loadtime'] = loadtimearray
	dlllist_doc['dlllist.path'] = patharray
	#Search for non system32 paths
	for s in dlllist_doc['dlllist.path']:
		if (("SYSTEM32" not in s.upper()) and ("NULL" not in s.upper()) and (".EXE" not in s.upper()) and (s != "") and ("WINSXS" not in s.upper())  and ("SYSWOW64" not in s.upper())  and ("WINDOWS\\MICROSOFT.NET" not in s.upper())  and ("WINDOWS\\ASSEMBLY" not in s.upper())):
			tagarray.append("NonSys32DLL")
			tagarray.append(s)
			dlllist_doc['tags'] = tagarray
		if (("C:" not in s.upper()) and (".EXE" not in s.upper()) and ("NULL" not in s.upper()) and (s != "")):
			tagarray.append("InjectedDLL")
			tagarray.append(s)
			dlllist_doc['tags'] = tagarray
	groupcount = 0
	output_file.write(json.dumps(dlllist_doc))
	output_file.write("\n")

	f_in.close()
	output_file.close()

def timers(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	timers_doc = {"timer.offset.virtual" : "null" , "timer.duetime" : "null" , "timer.period" : "null" , "timer.signaled" : "null" , "hostname" : "null" , "plugin" : "timers" , "investigated" : "false" , "timer.routine" : "null" , "timer.module" : "null", "tags" : ""}
	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)

	filename = input_file.replace("timers-","").replace(".txt","")
	openlines = 0

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if openlines < 2:
					openlines += 1
				else:
					data = line.split()
					timers_doc['timer.offset.virtual'] = data[0]
					timers_doc['timer.duetime'] = data[1]
					timers_doc['timer.period'] = data[2]
					timers_doc['timer.signaled'] = data[3]
					timers_doc['timer.routine'] = data[4]
					timers_doc['timer.module'] = data[5]
					timers_doc['hostname'] = filename
					output_file.write(json.dumps(timers_doc))
					output_file.write("\n")
					timers_doc = {"timer.offset.virtual" : "null" , "timer.duetime" : "null" , "timer.period" : "null" , "timer.signaled" : "null" , "hostname" : "null" , "plugin" : "timers" , "investigated" : "false" , "timer.routine" : "null" , "timer.module" : "null", "tags" : ""}
					continue
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()
	output_file.close()

def ldrmodules(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	ldrmodules_doc = {"process.pid" : "null" , "process.name" : "null" , "module.address.virtual" : "null" , "module.inload" : "null" , "hostname" : "null" , "plugin" : "ldrmodules" , "investigated" : "false" , "module.ininit" : "null" , "module.inmem" : "null" , "module.path" : "null", "tags" : ""}
	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)

	filename = input_file.replace("ldrmodules-","").replace(".txt","")
	openlines = 0

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if openlines < 2:
					openlines += 1
				else:
					data = line.split()
					ldrmodules_doc['process.pid'] = data[0]
					ldrmodules_doc['process.name'] = data[1]
					ldrmodules_doc['module.address.virtual'] = data[2]
					ldrmodules_doc['module.inload'] = data[3]
					ldrmodules_doc['module.ininit'] = data[4]
					ldrmodules_doc['module.inmem'] = data[5]
					xcount = 6
					while xcount < len(data):
						if xcount == 6:
							ldrmodules_doc['module.path'] = data[6]
						else:
							ldrmodules_doc['module.path'] = ldrmodules_doc['module.path'] + " " + data[xcount]
						xcount += 1
					ldrmodules_doc['hostname'] = filename

					output_file.write(json.dumps(ldrmodules_doc))
					output_file.write("\n")
					ldrmodules_doc = {"process.pid" : "null" , "process.name" : "null" , "module.address.virtual" : "null" , "module.inload" : "null" , "hostname" : "null" , "plugin" : "ldrmodules" , "investigated" : "false" , "module.ininit" : "null" , "module.inmem" : "null" , "module.path" : "null", "tags" : ""}
					continue
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()
	output_file.close()

def netscan(input_path, output_path, autoDiscard):
	"""
	:brief

	:param input_path: Input file path
	:param output_path: Output json file path
	:param autoDiscard: Auto Discard flag
	"""
	netscan_doc = {"net.offset.physical" : "null" , "net.protocol" : "null" , "net.local" : "null" , "net.foreign" : "null" , "hostname" : "null" , "plugin" : "netscan" , "investigated" : "false" , "net.state" : "null" , "process.pid" : "null" , "process.name" : "null" , "net.starttime" : "null", "tags" : "" }
	#File to write to
	output_file = open(output_path,"a+")
	#Filename of input file
	input_file = os.path.basename(input_path)
	filename = input_file.replace("netscan-","").replace(".txt","")
	openlines = 0

	with open(input_path,"r") as fd:
		for line in fd:
			try:
				if openlines < 1:
					openlines += 1
				else:
					data = line.split()
					netscan_doc['hostname'] = filename
					netscan_doc['net.offset.physical'] = data[0]
					netscan_doc['net.protocol'] = data[1]
					netscan_doc['net.local'] = data[2]
					netscan_doc['net.foreign'] = data[3]
					#All fields present - 10
					#No time, all others present - 7
					if (len(data) == 10 or len(data) == 7):
						netscan_doc['net.state'] = data[4]
						netscan_doc['process.pid'] = data[5]
						netscan_doc['process.name'] = data[6]
						if len(data) == 10:
							netscan_doc['net.starttime'] = data[7] + " " + data[8] + " " + data[9]
					#No owner, no time
					elif len(data) == 6:
						netscan_doc['net.state'] = data[4]
						netscan_doc['process.pid'] = data[5]
					#No state, yes date/time
					else:
						#Likely a glitched scan result with no process.name
						if data[4] == "CLOSED":
							raise ValueError('Suspected bad scan result with false PID and no process name')
						elif data[4] == "-1":
							raise ValueError('Suspected closed UDP artifact')
						netscan_doc['net.state'] = "null"
						netscan_doc['process.pid'] = data[4]
						netscan_doc['process.name'] = data[5]
						netscan_doc['net.starttime'] = data[6] + " " + data[7] + " " + data[8]
					if ((netscan_doc['process.pid'] == "-1") or (netscan_doc['process.pid'] == "0")):
						raise ValueError('False PID found')
					alphaCheck = bool(re.match('^[a-zA-Z0-9 _.-]+$', netscan_doc['process.name']))
					if not alphaCheck:
						raise ValueError('NonAlphaNumeric characters in process name')
					output_file.write(json.dumps(netscan_doc))
					output_file.write("\n")
					netscan_doc = {"net.offset.physical" : "null" , "net.protocol" : "null" , "net.local" : "null" , "net.foreign" : "null" , "hostname" : "null" , "plugin" : "netscan" , "investigated" : "false" , "net.state" : "null" , "process.pid" : "null" , "process.name" : "null" , "net.starttime" : "null", "tags" : "" }
					continue
			except Exception as err:
				if(autoDiscard == 1):
					#print(err)
					#print(line)
					continue
				else:
					printError(line, err, fd)
	fd.close()
