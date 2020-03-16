import json
import os.path
from os import listdir
from os.path import isfile, join
from elasticsearch import Elasticsearch

elasticIP = "192.168.35.133"
elasticPort = "9200"
while True:
  print("Elastic IP: {}".format(elasticIP))
  print("Elastic Port: {}".format(elasticPort))
  user_input = int(input("Are these correct?\n1: Yes\n2: Update IP\n3: Update port\n"))
  if user_input == 2:
    elasticIP = input("Enter new IP: ")
  elif user_input == 3:
    elasticPort = input("Enter new port #: ")
  elif user_input == 1:
    break
  else:
    print("You entered an invalid selection")

es = Elasticsearch([elasticIP], port=elasticPort)

invfilepath = "./inv.txt"
with open(invfilepath,"r") as f:
    for line in f:
        print ("Updating _id {}".format(line))
        id = line.rstrip()
        es.update(index="volhunter", doc_type="doc", id=id, body={"doc": {"investigated":"true"}})
