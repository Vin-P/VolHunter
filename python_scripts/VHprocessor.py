import argparse
import convert
import ipaddress
import os
import shutil
import jsonformat
import encoder
import volindexer
import tagger
from os.path import isfile, join
from elasticsearch import Elasticsearch


def format_and_ingest(vhfilepath, process_folder, output_folder, elasticIP, elasticPort, dirpath):
    """
    :brief Validate paths, convert to utf8 with Linux line endings, convert to json, and call volindexer

    :param vhfilepath: File path for VolHunter data
    :param process_folder: File path for processing folder
    :param output_folder: File path for output folder
    :param elasticIP: IP address of elastic server
    :param elasticPort: Port of elastic server
    :param dirpath: File path of root directory
    """
    #Validate that assumed paths are correct
    print("Root path {}".format(dirpath))
    print("VH data folder {}".format(vhfilepath))
    print("Processing folder {}".format(process_folder))
    print("Output folder {}".format(output_folder))
    user_input = input("Verify paths are correct.\nIf so, enter any key to continue\nIf not, enter q to quit. Rerun program with correct path using -d or --dir [PATH]\n")
    if user_input == "q":
        exit()
    #Convert to utf8 with Linux line endings
    encoder.encoding(vhfilepath, process_folder)
    input("Files converted. Pausing for your review. Enter any key to continue.\n")

    #Convert to json, remove processed files
    jsonformat.jsonparsing(process_folder, output_folder)
    input("Files formatted in json. Pausing for your review. Enter any key to continue.\n")
    for the_file in os.listdir(process_folder):
        file_path = os.path.join(process_folder, the_file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
        except Exception as err:
            print(err)

    volindexer.main(elasticIP, elasticPort, dirpath)
    print("Files shipped.")
    print("### Ensure you have built the index in Kibana before proceeding ###")


def mark_as_done(ip, port, id_file):
    """
    :brief Marks _id's as investigated in Elastic server

    :param ip: IP of Elastic server
    :param port: Port of Elastic server
    :param id_file: File of _id's to be marked as done
    """
    id_array = []
    es = Elasticsearch([ip], port=port)
    with open(id_file,"r") as fd:
        for line in fd:
            id_array.append(line.strip('\n'))
    fd.close()
    for _id in id_array:
        if _id != "":
            es.update(index="volhunter", doc_type="doc", id=_id, body={"doc": {"investigated":"true"}})


# Parse arguments
parser = argparse.ArgumentParser(description="Python program to convert, format, enrich, and injest data from VolHunter to Elastic, investigate the data, and run MITRE CAR Rules on it.", 
                                 usage="Use '%(prog)s -h' for more information", formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument("action", choices=["convert","investigate","car","all","delete","mark"], 
                    help="Choose action:\n"
                         "convert\tConvert, format, locally enrich, and ingest data to Elastic\n"
                         "investigate\tInvestigate for standard lineage\n"
                         "car\tRun MITRE CAR Rules\n"
                         "all\tRun convert, enrich, and car\n"
                         "delete\tDelete data from VolHunter Index CAN'T UNDO\n"
                         "mark\tMark _id's provided in .txt file as investigated. Must specify -f/--file with file path or file name if in same directory.")
parser.add_argument("--ip", "-i", default="20.25.20.142", help="IP of Elastic Stack server. Default: 20.25.20.142")
parser.add_argument("--port", "-p", default="9200", help="Port of Elastic Stack server. Default: 9200")
parser.add_argument("--dir", "-d", default=os.getcwd(), help="Root path for VHdata. Default: {}".format(os.getcwd()))
parser.add_argument("--file", "-f", default=None, help="TXT file containing _id's to be marked as investigated separated by a new line. Required for 'mark' command.")
args = parser.parse_args()

# Validate IP and port
try:
    ipaddress.ip_address(args.ip)
except:
    print("IP address is not valid.")
    exit()
try:
    if 1 > int(args.port) or int(args.port) > 65535:
        raise ValueError
except:
    print("Port is not valid.")
    exit()

# Validate file path
vhfilepath = args.dir + "/VHdata/gatheredlogs"
process_folder = args.dir + "/VHdata/converted/"
output_folder = args.dir + "/VHdata/output/"
if not(os.path.isdir(args.dir)):
    print("'dir' file path is not valid: {}".format(args.dir))
    print("Rerun program with correct path using -d or --dir [PATH]\n")
    exit()
elif not(os.path.isdir(vhfilepath)):
    print("'vhfilepath' file path is not valid: {}".format(vhfilepath))
    exit()
elif not(os.path.isdir(process_folder)):
    print("'process_folder' file path is not valid: {}".format(process_folder))
    exit()
elif not(os.path.isdir(output_folder)):
    print("'output_folder' file path is not valid: {}".format(output_folder))
    exit()

if args.file != None and not(os.path.isfile(args.file)):
    print("--file specified but value is not a valid file.")
    exit()
elif args.file != None and os.path.splitext(args.file)[-1].lower() != ".txt":
    print("File specified is not a .txt file.")
    exit()

# Main
if args.action == "convert":
    format_and_ingest(vhfilepath, process_folder, output_folder, args.ip, args.port, args.dir)
    print("Format, enrich, and ingest complete. Exiting.\n")
    exit()
elif args.action == "investigate":
    tagger.lineageInv(args.ip, args.port)
    print("Set investigated for standard lineage. Exiting.\n")
    exit()
elif args.action == "car":
    tagger.carRules(args.ip, args.port)
    print("CAR Rules complete. Exiting.\n")
    exit()
elif args.action == "all":
    format_and_ingest(vhfilepath, process_folder, output_folder, args.ip, args.port, args.dir)
    user_input = input("Format, enrich, and ingest complete. Pausing for your review. Enter 'q' to quit, any other key to continue to lineage investigation.\n")
    if user_input == "q":
        exit()
    tagger.lineageInv(args.ip, args.port)
    user_input = input("Set investigated for standard lineage. Pausing for your review. Enter 'q' to quit, any other key to continue to CAR Rules.\n")
    if user_input == "q":
        exit()
    tagger.carRules(args.ip, args.port)
    print("CAR Rules complete. Exiting.\n")
    exit()
elif args.action == "delete":
    es = Elasticsearch([args.ip], port=args.port)
    volindexer.testconnection(es)
    # BUG: indices.delete has no 'ignore' parameter
    # See: elasticsearch-py.readthedocs.io/en/master/api.html
    # Ignore is a global option. It looks like you can pass an ignore parameter but they dont document it in the indices.delete section
    es.indices.delete(index='volhunter', ignore=[400, 404])
    print("Elastic server data delted.\n")
    for item in os.listdir(process_folder):
        os.remove(process_folder+item)
    for item in os.listdir(args.dir+"/VHdata/processed/"):
        os.remove(args.dir+"/VHdata/processed/"+item)
    for item in os.listdir(output_folder):
        os.remove(output_folder+item)
    print("Converted, Process, and Output folder data deleted. Exiting.\n")
    exit()
elif args.action == "mark":
    mark_as_done(args.ip, args.port, args.file)
    print("_id's marked. Exiting.\n")
    exit()
else:
    print("Argparse error.")
    exit()