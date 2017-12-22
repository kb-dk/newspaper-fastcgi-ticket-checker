#!/usr/bin/python

# --!/usr/bin/env python2

# https://sbprojects.statsbiblioteket.dk/jira/browse/MSAVIS-4 - post process statistics log.
#
# For development purposes invoke as
#
#     python2 statistics.py fromDate=2013-07-01 toDate=2015-12-31
#
# The extra arguments trigger non-CGI output, and provides parameters to the script.
#

from __future__ import print_function  # for stderr

import ConfigParser
import cgi
import cgitb
import csv
import datetime
import glob
import gzip
import json
import os
import re
import suds
import suds.client
import sys
import time
from io import BytesIO
from lxml import etree as et

config_file_name = "../../newspaper_statistics.py.cfg"  # outside web root.

encoding = "utf-8"  # What to use for output

# ---

# If parameters this is command line. (may look at SCRIPT_* environment variables instead)

commandLine = len(sys.argv) > 1

if commandLine:
    # parse command line arguments on form "fromDate=2015-03-03" as map
    parameters = {}
    for arg in sys.argv[1:]:
        keyvalue = arg.partition("=")
        if (keyvalue[2]) > 0:
            parameters[keyvalue[0]] = keyvalue[2]
else:
    # We are a cgi script
    cgitb.enable()
    fieldStorage = cgi.FieldStorage()
    parameters = dict((key, fieldStorage.getvalue(key)) for key in fieldStorage.keys())

# -- load configuration file.  If not found, provide absolute path looked at.

absolute_config_file_name = os.path.abspath(config_file_name)
if not os.path.exists(absolute_config_file_name):
    # http://stackoverflow.com/a/14981125/53897
    print("Configuration file not found: ", absolute_config_file_name, file=sys.stderr)
    exit(1)

config = ConfigParser.SafeConfigParser()
config.read(config_file_name)

# -- create web service client from WSDL url. see https://fedorahosted.org/suds/wiki/Documentation

mediestream_wsdl = config.get("cgi", "mediestream_wsdl")
if not mediestream_wsdl:
    raise ValueError("no value for [cgi] mediestream_wsdl")


# FIXME:  Explain below problem better.
# We need to disable the cache to avoid jumping through SELinux hoops but
# suds is a pain in the a** and has no way to properly disable caching
# This just crudely redefines the default ObjectCache() to be NoCache()
# noinspection PyUnusedLocal
def ObjectCache(**kw):
    # noinspection PyUnresolvedReferences
    return suds.cache.NoCache()


suds.client.ObjectCache = ObjectCache
mediestream_webservice = suds.client.Client(mediestream_wsdl)

# -- extract configuration and setup

if "type" in parameters:
    requiredType = parameters["type"]
else:
    # We cannot generically ask for any type in batch.
    raise ValueError("'type' must be a parameter.")

if "chunksize" in parameters:
    chunksize = int(parameters["chunksize"])
else:
    # raise ValueError("'chunksize' (maximum size of summa request) must be a numeric parameter.")
    chunksize = 100  # default to recommended by toes@kb.dk if none given (for backwards compatebility)

if "fromDate" in parameters:
    start_str = parameters["fromDate"]  # "2013-06-15"
else:
    start_str = "2017-06-01"

if "toDate" in parameters:
    end_str = parameters["toDate"]
else:
    end_str = "2018-07-01"

# Example: d68a0380-012a-4cd8-8e5b-37adf6c2d47f (optionally trailed by a ".fileending")
re_doms_id_from_url = re.compile("([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(\.[a-zA-Z0-9]*)?$")

statistics_file_pattern = config.get("cgi", "statistics_file_name_pattern")
if not statistics_file_pattern:
    raise ValueError("no value for [cgi] statistics_file_name_pattern")

# http://stackoverflow.com/a/2997846/53897 - 10:00 is to avoid timezone issues in general.
start_date = datetime.date.fromtimestamp(time.mktime(time.strptime(start_str + " 10:00", '%Y-%m-%d %H:%M')))
end_date = datetime.date.fromtimestamp(time.mktime(time.strptime(end_str + " 10:00", '%Y-%m-%d %H:%M')))

namespaces = {
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "dc": "http://purl.org/dc/elements/1.1/"
}

downloadPDF = requiredType == "Download"

# -- go

# Titles for columns in CSV:
fieldnames = ["Timestamp", "Type", "AvisID", "Avis", "Adgangstype", "Udgivelsestidspunkt", "Udgivelsesnummer",
              "Sidenummer", "Sektion", "Klient", "schacHomeOrganization", "eduPersonPrimaryAffiliation",
              "eduPersonScopedAffiliation", "eduPersonPrincipalName", "eduPersonTargetedID",
              "SBIPRoleMapper", "MediestreamFullAccess", "UUID"]

if not commandLine:
    filename = "newspaper_stat-" + start_str + "-" + end_str
    if requiredType != "":
        filename = filename + "-" + requiredType
    print("Content-type: text/csv")
    print("Content-disposition: attachment; filename=" + filename + ".csv")
    print("")

result_file = sys.stdout

result_dict_writer = csv.DictWriter(result_file, fieldnames, delimiter="\t")
# Writes out a row where each column name has been put in the corresponding column.  If
# Danish characters show up in a header, these must be encoded too.
header = dict(zip(result_dict_writer.fieldnames, result_dict_writer.fieldnames))
result_dict_writer.writerow(header)

summa_resource_cache = {}
summa_resource_cache_max = 10000  # number of items to cache, when reached cache is flushed.

previously_seen_uniqueID = set()  # only process ticket/domsID combos once


def createOutputLine(response, group_xpath, json_entry):
    try:
        shortFormat = response.xpath(
            group_xpath + "record/field[@name='shortformat']/shortrecord")[
            0]
    except:
        shortFormat = et.Element("empty")
    # -- ready to generate output
    # noinspection PyDictCreation
    outputLine = {}
    outputLine["Type"] = "info:fedora/doms:Newspaper_Collection"
    outputLine["Adgangstype"] = json_entry["resource_type"]
    outputLine["UUID"] = json_entry["resource_id"]
    outputLine["Timestamp"] = datetime.datetime.fromtimestamp(json_entry["dateTime"]).strftime(
        "%Y-%m-%d %H:%M:%S")
    outputLine["Klient"] = "-"  # disabled to conform to logging law - was:  entry["remote_ip"]
    # print(ET.tostring(shortFormat))
    avisID_xpath = group_xpath + "record/field[@name='familyId']/text()"
    outputLine["AvisID"] = (response.xpath(avisID_xpath) or [
        ""])[0]
    outputLine["Avis"] = \
        (shortFormat.xpath("rdf:RDF/rdf:Description/newspaperTitle/text()", namespaces=namespaces) or [""])[
            0]
    outputLine["Udgivelsestidspunkt"] = \
        (shortFormat.xpath("rdf:RDF/rdf:Description/dateTime/text()", namespaces=namespaces) or [""])[0]
    outputLine["Udgivelsesnummer"] = \
        (shortFormat.xpath("rdf:RDF/rdf:Description/newspaperEdition/text()", namespaces=namespaces) or [
            ""])[0]
    outputLine["schacHomeOrganization"] = ", ".join(
        e for e in json_entry["userAttributes"].get("schacHomeOrganization", {}))
    outputLine["eduPersonPrimaryAffiliation"] = ", ".join(
        e for e in json_entry["userAttributes"].get("eduPersonPrimaryAffiliation", {}))
    outputLine["eduPersonScopedAffiliation"] = ", ".join(
        e for e in json_entry["userAttributes"].get("eduPersonScopedAffiliation", {}))
    outputLine["eduPersonPrincipalName"] = ", ".join(
        e for e in json_entry["userAttributes"].get("eduPersonPrincipalName", {}))
    outputLine["eduPersonTargetedID"] = ", ".join(
        e for e in json_entry["userAttributes"].get("eduPersonTargetedID", {}))
    outputLine["SBIPRoleMapper"] = ", ".join(e for e in entry["userAttributes"].get("SBIPRoleMapper", {}))
    outputLine["MediestreamFullAccess"] = ", ".join(
        e for e in json_entry["userAttributes"].get("MediestreamFullAccess", {}))
    if not downloadPDF:
        # Does not make sense on editions
        outputLine["Sektion"] = \
            (shortFormat.xpath("rdf:RDF/rdf:Description/newspaperSection/text()",
                               namespaces=namespaces) or [""])[0]
        outputLine["Sidenummer"] = \
            (shortFormat.xpath("rdf:RDF/rdf:Description/newspaperPage/text()", namespaces=namespaces) or [
                ""])[0]
    return outputLine


# ---


# https://stackoverflow.com/a/13335919/53897
for statistics_file_name in sorted(glob.iglob(statistics_file_pattern)):

    # Log files in production are named:
    # thumbnails.log
    # thumbnails.log.2017-10-30.gz
    # thumbnails.log.2017-10-31
    # They are rolled over at midnight so contains the previous days log.

    if not os.path.isfile(statistics_file_name):
        continue

    # Only process filenames with a YYYY-MM-DD date if they are in range.
    # Todays log was rolled over at midnight at the first entry of today,
    # and contains yestedays entries so we need an additional day

    filenameDateMatch = re.search(r"\d\d\d\d-\d\d-\d\d", statistics_file_name)
    if filenameDateMatch:
        filename_date = datetime.date.fromtimestamp(
            time.mktime(time.strptime(filenameDateMatch.group() + " 10:00", '%Y-%m-%d %H:%M')))

        if not start_date <= filename_date <= (end_date + datetime.timedelta(days=1)):
            continue

    # For now just skip compressed files.
    if statistics_file_name.endswith(".gz"):
        statistics_file = gzip.open(statistics_file_name, "rb")
    else:
        statistics_file = open(statistics_file_name, "rb")

    # Read the file in chunks of "chunksize" lines and make a single Summa request for each.
    eof_seen = False
    while not eof_seen:
        query_keys = []  # for summa batch query
        lineInformation = []  # processed chunk

        while len(query_keys) < chunksize:
            line = statistics_file.readline()
            if not line:
                eof_seen = True
                break

            # Mon Jun 22 15:28:02 2015: {"resource_id":"...","remote_ip":"...","userAttributes":{...},
            #                            "dateTime":1434979682,"ticket_id":"...","resource_type":"Download"}

            lineParts = line.partition(": ")
            loggedJson = lineParts[2]

            try:
                entry = json.loads(loggedJson)
            except:
                print("Bad JSON skipped from ", statistics_file_name, ": ", loggedJson, file=sys.stderr)
                continue

            # -- line to be considered?

            entryDate = datetime.date.fromtimestamp(entry["dateTime"])

            if not start_date <= entryDate <= end_date:
                continue

            if requiredType != "" and not requiredType == entry["resource_type"]:
                continue

            resource_id = entry["resource_id"]

            # -- only process each ticket/domsID once (deep zoom makes _many_ requests).

            uniqueID = resource_id + " " + entry["ticket_id"] + " " + str(downloadPDF)

            if uniqueID in previously_seen_uniqueID:
                continue
            else:
                previously_seen_uniqueID.add(uniqueID)

            if downloadPDF:
                query_key = "doms_aviser_edition:uuid:" + resource_id
            else:
                query_key = "doms_aviser_page:uuid:" + resource_id

            query_keys.append(query_key)
            tuple = (query_key, entry)
            lineInformation.append(tuple)

        # -- Anything to process?

        if len(query_keys) == 0:
            continue

        # -- Yes!

        query = {}
        if downloadPDF:
            query["search.document.query"] = "editionUUID:(\"%s\")" % "\" OR \"".join(query_keys)
            query["search.document.maxrecords"] = "%d" % (chunksize * 2)  # all + margin
            query["search.document.startindex"] = "0"
            query["search.document.resultfields"] = "editionUUID, pageUUID, shortformat, familyId"
            query["solrparam.facet"] = "false"
            query["group"] = "true"
            query["group.field"] = "editionUUID"
            query["search.document.collectdocids"] = "false"
        else:
            query["search.document.query"] = "pageUUID:(\"%s\")" % "\" OR \"".join(query_keys)
            query["search.document.maxrecords"] = "%d" % (chunksize * 2)  # all + margin
            query["search.document.startindex"] = "0"
            query["search.document.resultfields"] = "pageUUID, shortformat, familyId"
            query["solrparam.facet"] = "false"
            query["group"] = "true"
            query["group.field"] = "pageUUID"
            query["search.document.collectdocids"] = "false"

        queryJSON = json.dumps(query)
        # FIXME:  May time out.  Handle that gracefully.
        summa_resource_text = mediestream_webservice.service.directJSON(queryJSON)

        # Get the ElementTree for the returned XML string.
        summa_resource = et.parse(BytesIO(bytes(bytearray(summa_resource_text, encoding='utf-8'))))

        # reprocess each line
        for query_key, entry in lineInformation:
            group_xpath = "/responsecollection/response/documentresult/group[@groupValue='" + query_key + "']/"

            result = createOutputLine(summa_resource, group_xpath, entry)

            encodedOutputLine = dict((key, result[key].encode(encoding)) for key in result.keys())
            result_dict_writer.writerow(encodedOutputLine)
        # --

    # end - while not eof

    statistics_file.close()
    # result_file.close() - can't on sys.stdout.

# end - for statistics_name in ...
