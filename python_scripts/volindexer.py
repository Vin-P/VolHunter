#!/bin/python3

import json, os, tagger
from elasticsearch import Elasticsearch, helpers

def main(ip, port, dirpath):
    """
    :brief Connect to Elastic server, populate records and post them

    :param ip: IP of Elastic server
    :param port: Port of Elastic server
    :param dirpath: File path of root directory
    """
    es      = set_client(ip, port)
    records = set_records(dirpath)

    print("Enriching data locally. Setting parent name.")
    enriched_records = tagger.parentname_local(records)
    post_records(es, enriched_records, dirpath)
    print("Parent process names updated.\n")

def set_client(ip, port):
    """
    :brief Set IP/Port and test connection

    :param ip: IP of Elastic server
    :param port: Port of Elastic server
    :return Elasticsearch object containing connection info.
    """
    esclient = Elasticsearch([ip], port=port)
    testconnection(esclient)
    return esclient

def set_records(dirpath):
    """
    :brief Populate records object

    :param dirpath: File path of root directory
    :return records object
    """
    records = []
    path    = dirpath + "/VHdata/output/"

    if len(os.listdir(path)) == 0:
        print("No files found in log diretory...\n")
        exit()

    for log in os.listdir(path):
        with open(path + log, 'r') as fd:
            for line in fd:
                records.append(line)

    print("Number of records to be indexed: ", len(records))
    return records

def post_records(es, records, dirpath):
    """
    :brief Index and move log files

    :param es: Elasticsearch object containing connection info
    :param records: Elasticsearch records object
    :param dirpath: File path of root directory
    """
    log_path     = dirpath + "/VHdata/output/"
    process_path = dirpath + "/VHdata/processed/"

    data = ({'_op_type': 'index',
             '_index': 'volhunter',
             '_type' : 'doc',
             '_source'   : record
             }
             for record in records)

    helpers.bulk(es, data)
    print("Index complete, moving processed log files...")
    for log in os.listdir(log_path):
        os.rename(log_path + log, process_path + log)
    

def testconnection(esclient):
    """
    :brief Test connection to elastic server

    :param esclient: Elasticsearch object containing elastic server connection info.
    """
    link = esclient.ping()
    if link:
        print("Uplink established...\n")
    else:
        print("Unable to establish connection, exiting.\n")
        exit()

#if __name__ == "__main__":
#    os.system('clear')
    # TODO: What args are being passed to main()? above it needs ip, port, and dirpath
#    main()
