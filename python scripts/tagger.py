import json
from elasticsearch import Elasticsearch

#host = '192.168.35.133:9200'
#port = '9200'
def parentname(host, port):
    es = Elasticsearch([host], port=port)

    ### Update parent.process.name to pslist items
    res = es.search(index="volhunter", body={'size' : 10000, "query": {"match": {"plugin": "pslist"}}})

    print("%d PSLIST entries to update parent.process.name" % res['hits']['total'])
    for doc in res['hits']['hits']:
        if (doc['_source']['process.name'] != "System"):
            searchedppid = doc['_source']['process.ppid']
            searchedhostname = doc['_source']['hostname']
            ppidres = es.search(index="volhunter", body={ "query": {"bool": {"must": [{"match": {"plugin": "pslist"} }, {"match": {"process.pid": searchedppid} }, {"match":{"hostname": searchedhostname}} ] } } })
            #bob['_source']['process.name'] is now our doc['_source']['parent.process.name']
            for bob in ppidres['hits']['hits']:
                es.update(index="volhunter", doc_type="doc", id=doc["_id"], body={"doc": {"process.parent.name":bob['_source']['process.name']}})
            if (ppidres['hits']['total'] == 0):
                es.update(index="volhunter", doc_type="doc", id=doc["_id"], body={"doc": {"process.parent.name": "NULL"}})

def lineageInv(host, port):
    es = Elasticsearch([host], port=port)
    ### Update investigated field for standard process lineage
    print "Filtering standard process lineage"
    res = es.search(index="volhunter", body={'size' : 10000, "query": {"match": {"plugin": "pslist"}}})

    for doc in res['hits']['hits']:
        #Userinit -> Explorer
        if (doc['_source']['process.name'].lower() == "explorer.exe"):
            if (doc['_source']['process.parent.name'].lower() == "userinit.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #Wininit -> Services
        if (doc['_source']['process.name'].lower() == "services.exe"):
            if (doc['_source']['process.parent.name'].lower() == "wininit.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #Wininit -> LSASS
        if (doc['_source']['process.name'].lower() == "lsass.exe"):
            if (doc['_source']['process.parent.name'].lower() == "wininit.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #SMSS -> csrss
        if (doc['_source']['process.name'].lower() == "csrss.exe"):
            if (doc['_source']['process.parent.name'].lower() == "smss.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #SMSS -> SMSS
        if (doc['_source']['process.name'].lower() == "smss.exe"):
            if (doc['_source']['process.parent.name'].lower() == "smss.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #System -> SMSS
        if (doc['_source']['process.name'].lower() == "smss.exe"):
            if (doc['_source']['process.parent.name'].lower() == "system"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #services -> svchost
        if (doc['_source']['process.name'].lower() == "svchost.exe"):
            if (doc['_source']['process.parent.name'].lower() == "services.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #smss -> Wininit
        if (doc['_source']['process.name'].lower() == "wininit.exe"):
            if (doc['_source']['process.parent.name'].lower() == "smss.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #svchost -> runtimebroker
        if (doc['_source']['process.name'].lower() == "runtimebroker.exe"):
            if (doc['_source']['process.parent.name'].lower() == "svchost.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #wininit -> lsaiso
        if (doc['_source']['process.name'].lower() == "lsaiso.exe"):
            if (doc['_source']['process.parent.name'].lower() == "wininit.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #svchost -> taskhostw
        if (doc['_source']['process.name'].lower() == "taskhostw.exe"):
            if (doc['_source']['process.parent.name'].lower() == "svchost.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})
        #smss -> winlogon
        if (doc['_source']['process.name'].lower() == "winlogon.exe"):
            if (doc['_source']['process.parent.name'].lower() == "smss.exe"):
                es.update(index="volhunter", doc_type="doc", id=doc['_id'], body={"doc": {"investigated":"true"}})