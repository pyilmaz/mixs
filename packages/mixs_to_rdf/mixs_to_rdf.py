#!/usr/bin/env python

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

__author__ = "John Wieczorek"
__copyright__ = "Copyright 2016 Regents of the University of California"
__version__ = "mixs_to_rdf.py 2016-05-04T16:44-03:00"

# This script produces MIxS as RDF from current and previous mixs_core.csv exports 
# from the MIxS management database.
#
# Example:
#
# python mixs_to_rdf.py ./versions/2016-05-03/ ./versions/2013-03-26/ mixsterms-test.rdf

import sys
import os.path
import unittest
from datetime import datetime

try:
    # need to install unicodecsv for this to be used
    # pip install unicodecsv
    import unicodecsv as csv
except ImportError:
    import warnings
    warnings.warn("can't import `unicodecsv` encoding errors may occur")
    import csv

def make_mixs_core_as_rdf(workspace, previousworkspace, mixsasrdffilename=None):
    """Construct the RDF document
    parameters:
        workspace - path to the directory containing the current MIxS definition files
        previousworkspace - path to the directory containing the previous MIxS definition 
            files
        mixsasrdffilename - the name of the output file to be written to the workspace
    returns:
        success - True if the output document was created successfully, otherwise False
    """
    # Cannot function without a designated workspace
    if workspace is None or len(workspace)==0:
        print 'No workspace given'
        return None

    # Cannot function without an actual directory where the workspace points
    if os.path.isdir(workspace) == False:
        print 'workspace %s not found' % workspace
        return None

    # Cannot function without a designated previousworkspace
    if previousworkspace is None or len(previousworkspace)==0:
        print 'No workspace given'
        return None

    # Cannot function without an actual directory where the previousworkspace points
    if os.path.isdir(previousworkspace) == False:
        print 'previous workspace %s not found' % previousworkspace
        return None

    # Cannot function without an outputfile
    if mixsasrdffilename is None or len(mixsasrdffilename)==0:
        mixsasrdffilename = 'mixsterms.rdf'
        print 'output file set to %' % mixsasrdffilename

    mixscorefilename = 'mixs_core.csv'

    ws = workspace.strip('/') + '/' 
    pws = previousworkspace.strip('/') + '/' 

    classlookupfile = ws + 'class_lookup.csv'
    dwclookupfile = ws + 'dwc_lookup.csv'
    envolookupfile = ws + 'envo_lookup.csv'
    mixsclassesfilename = ws + 'mixs-classes.rdf'
    mixsheaderfilename = ws + 'mixs-header.rdf'

    currentmixscorefilename = ws + mixscorefilename
    previousmixscorefilename = pws + mixscorefilename

    currentmixsasrdffilename = ws + mixsasrdffilename
    previousmixsasrdffilename = pws + 'mixsterms.rdf'

    # Check for the existence of input files to create the new version of the RDF file
    check = currentmixscorefilename
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = previousmixscorefilename
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = previousmixsasrdffilename
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = classlookupfile
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = dwclookupfile
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = envolookupfile
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = mixsclassesfilename
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False
    check = mixsheaderfilename
    if os.path.isfile(check) == False:
        print '%s not found' % check
        return False

    # Get a dictionary of MIxS terms that are from Darwin Core
    dwctermsdict = dwc_lookup_dict(dwclookupfile)
#    print 'dwctermsdict:\n%s' % dwctermsdict

    # Get a dictionary of MIxS terms that are from ENVO
    envotermsdict = envo_lookup_dict(envolookupfile)
#    print 'envotermsdict:\n%s' % envotermsdict

    # Get a dictionary of MIxS class lookups
    classdict = class_lookup_dict(classlookupfile)

    # Create a dictionary of MIxS terms from the current MIxS database output
    currentmixsdict = mixs_dict(currentmixscorefilename)
    sortedmixslist = sorted(list(currentmixsdict))
#    print 'Current mixs term list:\n%s' % sortedmixslist

    # Create a dictionary of MIxS terms from the previous MIxS database output
    previousmixsdict = mixs_dict(previousmixscorefilename)
#    print 'Previous MIxS dict:\n%s' % previousmixsdict

    # Create a dictionary of MIxS terms with their issued dates from the previous MIxS 
    # RDF file
    issued_dates = get_dates('<dcterms:issued', previousmixsasrdffilename)
#    print 'Previous issued dates:\n%s' % issued_dates
    
    # Create a dictionary of MIxS terms with their modified dates from the previous MIxS 
    # RDF file
    modified_dates = get_dates('<dcterms:modified', previousmixsasrdffilename)
#    print 'Previous modified dates:\n%s' % modified_dates

    # Create a file to write the RDF into
    with open(currentmixsasrdffilename, 'w') as rdffile:

        # Copy the contents of the headerfile into the outputfile as a starting point
        with open(mixsheaderfilename, 'rU') as headerfile:
            for line in headerfile:
                rdffile.write(line)

        # Write the RDF for the MIxS Class terms to the outputfile
        # These are not managed in the source database and must be added from an
        # additional document.

        rdffile.write('  <!-- CLASSES -->\n')
        rdffile.write('  <!-- Class definitions come from classes.rdf. -->\n\n')

        # Copy the contents of the Class file into the outputfile
        with open(mixsclassesfilename, 'rU') as classfile:
            for line in classfile:
                rdffile.write(line)

        rdffile.write('\n  <!-- MIxS PROPERTIES -->\n')
        rdffile.write('  <!-- Property definitions come from processing mixs_core.csv. -->\n')

        # Write the RDF for the MIxS property terms to the outputfile
        header = None
        dialect = csv_file_dialect(currentmixscorefilename)

        for term in sortedmixslist:
            previousmixsrow = None
            if term in previousmixsdict:
                previousmixsrow = previousmixsdict[term]
            termrdf = mixs_term_as_rdf(currentmixsdict[term], previousmixsrow, 
                issued_dates, modified_dates, classdict, dwctermsdict, envotermsdict)
            if termrdf is not None:
                rdffile.write(termrdf)

        # Close the RDF in the output file
        rdffile.write('</rdf:RDF>')
    if os.path.isfile(currentmixsasrdffilename) == False:
        print '%s not found' % currentmixsasrdffilename
        return False
    return True

def mixs_term_as_rdf(currentrow, previousrow, issued_dates, modified_dates, classdict, 
    dwctermsdict, envotermsdict, indent='  '):
    """Construct an RDF record for the term including the following attributes:
        rdf:Description
        owl:sameAs
        rdfs:label
        rdfs:comment
        dcterms:description
        rdfs:isDefinedBy
        rdf:type
        dwcattributes:status
        dcterms:issued
        dcterms:modified
        dwcattributes:organizedInClass
    parameters:
        currentrow - dictionary containing the current information for the term
        previousrow - dictionary containing the previous information for the term
        issued_dates - dictionary containing the previous terms and their issued dates
        modified_dates - dictionary containing the previous terms and their modified dates
        classdict - dictionary containing class lookups from section values
        dwctermsdict - dictionary containing Darwin Core term lookups
        envotermsdict - dictionary containing ENVO term lookups
        indent - string to use for indent formatting
    returns:
        rdf - the term from currentrow rendered in RDF
    """

    rdf = None
    if currentrow is None or len(currentrow)==0:
        return None

    ### rdf:Description
    rdf =  '%s<rdf:Description rdf:about="http://gensc.org/ns/mixs/%s">\n' % \
        (indent, currentrow['short_name'])

    if currentrow['short_name'] in dwctermsdict:
        ### owl:sameAs
        rdf += '%s%s<owl:sameAs rdf:resource="http://rs.tdwg.org/dwc/terms/%s"/>\n' % \
        (indent, indent, dwctermsdict[currentrow['short_name']])
    elif currentrow['short_name'] in envotermsdict:
        ### owl:sameAs
        rdf += '%s%s<owl:sameAs rdf:resource="http://purl.obolibrary.org/obo/%s"/>\n' % \
        (indent, indent, envotermsdict[currentrow['short_name']])
    else:
        ### rdfs:label
        rdf += '%s%s<rdfs:label xml:lang="en">%s</rdfs:label>\n' % \
            (indent, indent, currentrow['long_name'])

        ### rdfs:comment
        rdf += '%s%s<rdfs:comment xml:lang="en">%s</rdfs:comment>\n' % \
            (indent, indent, currentrow['definition'])

        ### dcterms:description
        rdf += '%s%s<dcterms:description xml:lang="en">%s</dcterms:description>\n' % \
            (indent, indent, currentrow['example'])

        ### rdfs:isDefinedBy
        rdf += '%s%s<rdfs:isDefinedBy rdf:resource="http://gensc.org/ns/mixs/" />\n' % \
            (indent, indent)

        ### rdf:type
        rdf += '%s%s<rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property" />\n' % \
            (indent, indent)

        ### dwcattributes:status
        rdf += '%s%s<dwcattributes:status>recommended</dwcattributes:status>\n' % \
            (indent, indent)

        # The MIxS source database does not track information for the following terms. They 
        # must be constructed from additional documents.

        ### dwcattributes:organizedInClass
        orgclass = classdict[currentrow['section']]
        rdf += '%s%s<dwcattributes:organizedInClass rdf:resource="http://gensc.org/ns/mixs/terms/%s" />\n' % \
            (indent, indent, orgclass)

        ### dcterms:issued
        # Get it from the issued_dates dictionary. If not there, use today.
        issued_date = None
        if currentrow['short_name'] in issued_dates:
            issued_date = issued_dates[currentrow['short_name']]
        if issued_date is None:
            issued_date = datetime.strftime(datetime.now(),'%Y-%m-%d')
        rdf += '%s%s<dcterms:issued>%s</dcterms:issued>\n' % (indent, indent, issued_date)

        ### dcterms:modified
        # Get it from or by comparing content to the previously published version for 
        # the same rdf:Description
        if term_diff(currentrow, previousrow)==True:
            # Set modified to today 
            modified_date = datetime.strftime(datetime.now(),'%Y-%m-%d')
        else:
            # Set modified to the previous value of modified
            modified_date = modified_dates[currentrow['short_name']]
        rdf += '%s%s<dcterms:modified>%s</dcterms:modified>\n' % \
            (indent, indent, modified_date)

    # Close the term Description
    rdf += '%s</rdf:Description>\n' % indent

    return rdf

def term_diff(currentrow, previousrow):
    """Determine if any attributes of a term have changed between two versions.
    parameters:
        currentrow - dictionary of more recent attributes
        previousrow - dictionary of more previous attributes
    returns:
        success - True if there is any difference in attributes, otherwise False
    """
    # Cannot function properly without a currentrow
    if currentrow is None or len(currentrow)==0:
        return None

    # If no previousrow is given, the term did not exist in the previous version.
    if previousrow is None or len(previousrow)==0:
        print 'No previous version for %s' % currentrow['short_name']
        return True

    # Check the fields in the current row against the same ones in the previousrow
    for key in currentrow:
        # See if the field is in the previousrow
        try:
            oldval = previousrow[key]
        except:
            # It isn't, so there is a term difference
            print 'Previous RDF file had no field %s for %s' % \
                (key, currentrow['short_name'])
            return True
        # Check to see if the content of the two versions is the same
        if currentrow[key] != previousrow[key]:
            # They aren't, so there is a difference
            print 'Field %s changed from previous version' % currentrow['short_name']
            print 'Current %s:\n%s' % (key, currentrow[key])
            print 'Previous %s:\n%s' % (key, previousrow[key])
            return True
    # There is no difference between the contents of the corresponding fields
    return False

def get_dates(attribute, rdffilename):
    """Get the dates in a specific attribute for terms in an RDF file. 
    parameters:
        attribute - string for the date property (e.g., '<dcterms:issued'
        rdffilename - the full path to the rdf file to search
    returns:
        dates - a dictionary of terms with dates for the given attribute
    """
    # Cannot function without an attribute
    if attribute is None or len(attribute)==0:
        return None
    # Cannot function without an rdffilename
    if rdffilename is None or len(rdffilename)==0:
        return None
    # Cannot function without an actual file where rdffilename points
    if os.path.isfile(rdffilename) == False:
        return None

    # Set up the dictionary for the dates to return
    dates = {}
    # Work with the file given by rdffilename
    with open(rdffilename, 'rU') as rdffile:
        # Get the first line of the rdffile
        line = rdffile.readline()
        # Look through the lines of the rdffile until we find a term Description
        while len(line)>0:
            term = None
            date = None
            if '<rdf:Description' in line:
                term = term_from_rdf(line)
                # From here, look for the desired data attribute
                while len(line)>0 and attribute not in line:
                    line = rdffile.readline()
                # If we have a date attribute get the date out of it
                if line is not None:
                    date = date_from_rdf(attribute, line)
            # If we have the date attribute for the term, add them to the dates 
            # dictionary
            if term is not None and date is not None:
                dates[term]=date
            line = rdffile.readline()
    # Return the dates dictionary with { term:date } pairs
    return dates

def term_from_rdf(line):
    """Get the term out of a line from an RDF file.
    parameters:
        line - string for the line from the RDF file
    returns:
        term - string containing the term name
    """
    # Cannot function without a line string
    if line is None or len(line)==0:
        return None

    # Set up the substring that denotes the beginning of a term definition
    s = '<rdf:Description'

    # Figure out what part of the string contains just the term name
    # start is the position in line where '<rdf:Description>' begins
    start = line.find(s)
    
    # If the target substring is not in line, abort
    if start == -1:
        return None
    
    # seekfrom is the position after '<rdf:Description>'
    seekfrom = start+len(s)+1

    # end is the position of the last character of the term string - 2 character before
    # the '>' closing the rdf:Description
    end = line.find('>',seekfrom) - 1
    
    # start is the first position following the last '/' in the term name
    newstart = line.rfind('/',start,end) + 1

    # Return the term name from the line
    return line[newstart:end]    

def date_from_rdf(attribute, line):
    """Get the date for a specific attribute out of a line in an RDF file. 
    parameters:
        attribute - string for the date property (e.g., '<dcterms:issued'
        line - string for the line from the RDF file
    returns:
        date - string containing the date
    """
    # Cannot function without an attribute
    if attribute is None or len(attribute)==0:
        return None
    # Cannot function without an line
    if line is None or len(line)==0:
        return None

	# Mark the beginning of the date where the attribute ends
    start = line.find(attribute)+len(attribute)+1
    
    # Mark the end after the length of a standard ISO date in yyyy-mm-dd format
    end = start+10

    # Return the date string
    return line[start:end]

def mixs_dict(mixscorefilename, dialect=None):
    """Get the MIxS core file as a dictionary.
    parameters:
        mixscorefilename - the full path to the class from MIxS core export file
        dialect - a csv.dialect object with the attributes of the file
    returns:
        mixsdict - dictionary of MIxS terms
    """
    # Cannot function without a core file name
    if mixscorefilename is None or len(mixscorefilename)==0:
        return None

    # Cannot function without an actual file where mixscorefilename points
    if os.path.isfile(mixscorefilename) == False:
        print 'Core file %s not found' % mixscorefilename
        return None

    # Create the dictionary for the MIxS Core properties
    mixsdict = {}

    # If no explicit dialect for the file is given, figure it out from the file
    if dialect is None:
        dialect = csv_file_dialect(mixscorefilename)

    # Open up the MIxS core file for processing
    with open(mixscorefilename, 'rU') as mixscorefile:
        reader = csv.DictReader(mixscorefile, dialect=dialect)
        # Read the header
        reader.fieldnames
        
        # Iterate through the rows in the input and create a dictionary entry for each
        # term, with the term name as the key and the rest of the row as the value
        for row in reader:
#            print '%s' % row
            term = row['short_name']
            mixsdict[term]=row

    # Return the dictionary of terms
    return mixsdict

def class_lookup_dict(lookupfile, dialect=None):
    """Get the class lookup as a dictionary.
    parameters:
        lookupfile - the full path to the class from section lookup file
        dialect - a csv.dialect object with the attributes of the file
    returns:
        classdict - a dictionary of sections and their corresponding classes
    """
    # Cannot function without a lookup file name
    if lookupfile is None or len(lookupfile)==0:
        return None

    # Cannot function without an actual file where lookupfile points
    if os.path.isfile(lookupfile) == False:
        print 'lookup file %s not found' % lookupfile
        return None

    # Create the dictionary for the class lookups
    classdict = {}

    # If no explicit dialect for the file is given, figure it out from the file
    if dialect is None:
        dialect = csv_file_dialect(lookupfile)

    # Open up the class lookup file for processing
    with open(lookupfile, 'rU') as csvfile:
        reader = csv.DictReader(csvfile, dialect=dialect)
        # Read the header
        reader.fieldnames

        # Iterate through the rows in the input and create a dictionary entry for class, 
        # with the section name in MIxS as the key and the lookup value from the field
        # 'organizedInClass'
        for row in reader:
#            print 'row: %s' % row
            classdict[row['section']]=row['organizedInClass']

    # Return the dictionary of classes
    return classdict

def dwc_lookup_dict(lookupfile, dialect=None):
    """Get the Darwin Core term lookup as a dictionary.
    parameters:
        lookupfile - the full path to the Darwin Core term lookup file
        dialect - a csv.dialect object with the attributes of the file
    returns:
        dwcdict - a dictionary of terms and their corresponding Darwin Core terms
    """
    # Cannot function without a lookup file name
    if lookupfile is None or len(lookupfile)==0:
        return None

    # Cannot function without an actual file where lookupfile points
    if os.path.isfile(lookupfile) == False:
        print 'lookup file %s not found' % lookupfile
        return None

    # Create the dictionary for the Darwin Core lookups
    dwcdict = {}

    # If no explicit dialect for the file is given, figure it out from the file
    if dialect is None:
        dialect = csv_file_dialect(lookupfile)

    # Open up the Darwin Core lookup file for processing
    with open(lookupfile, 'rU') as csvfile:
        reader = csv.DictReader(csvfile, dialect=dialect)
        reader.fieldnames

        # Iterate through the rows in the input and create a dictionary entry for the
        # MIxS terms, with the Darwin Core term name as the value
        for row in reader:
#            print 'row: %s' % row
            dwcdict[row['mixsterm']]=row['dwcterm']

    # Return the dictionary of Darwin Core terms
    return dwcdict

def envo_lookup_dict(lookupfile, dialect=None):
    """Get the ENVO term lookup as a dictionary.
    parameters:
        lookupfile - the full path to the ENVO term lookup file
        dialect - a csv.dialect object with the attributes of the file
    returns:
        envodict - a dictionary of MIxS terms and their corresponding ENVO terms
    """
    # Cannot function without a lookup file name
    if lookupfile is None or len(lookupfile)==0:
        return None

    # Cannot function without an actual file where lookupfile points
    if os.path.isfile(lookupfile) == False:
        print 'lookup file %s not found' % lookupfile
        return None

    # Create the dictionary for the ENVO lookups
    envodict = {}

    # If no explicit dialect for the file is given, figure it out from the file
    if dialect is None:
        dialect = csv_file_dialect(lookupfile)

    # Open up the ENVO lookup file for processing
    with open(lookupfile, 'rU') as csvfile:
        reader = csv.DictReader(csvfile, dialect=dialect)
        reader.fieldnames

        # Iterate through the rows in the input and create a dictionary entry for the
        # MIxS terms, with the Darwin Core term name as the value
        for row in reader:
#            print 'row: %s' % row
            envodict[row['mixsterm']]=row['envoterm']

    # Return the dictionary of ENVO terms
    return envodict

def csv_file_dialect(fullpath):
    """Detect the dialect of a CSV or TXT data file.
    parameters:
        fullpath - full path to the file to process
    returns:
        dialect - a csv.dialect object with the detected attributes
    """
    # Cannot function without a file
    if fullpath is None or len(fullpath)==0:
        return None

    # Cannot function without an actual file where full path points
    if os.path.isfile(fullpath) == False:
        return None

    # Let's look at up to readto bytes from the file
    readto = 4096
    filesize = os.path.getsize(fullpath)
    if filesize < readto:
        readto = filesize

    with open(fullpath, 'rb') as file:
        # Try to read the specified part of the file
        try:
            buf = file.read(readto)
#            print 'buf:\n%s' % buf
            # Make a determination based on existence of tabs in the buffer, as the
            # Sniffer is not particularly good at detecting TSV file formats. So, if the
            # buffer has a tab in it, let's treat it as a TSV file 
            if buf.find('\t')>0:
                return tsv_dialect()
#            dialect = csv.Sniffer().sniff(file.read(readto))
            # Otherwise let's see what we can find invoking the Sniffer.
            dialect = csv.Sniffer().sniff(buf)
        except csv.Error:
            # Something went wrong, so let's try to read a few lines from the beginning of 
            # the file
            try:
                file.seek(0)
#                print 'Re-sniffing with tab to %s' % (readto)
                sample_text = ''.join(file.readline() for x in xrange(2,4,1))
                dialect = csv.Sniffer().sniff(sample_text)
            # Sorry, couldn't figure it out
            except csv.Error:
#                print 'No dice'
                return None
    
    # Fill in some standard values for the remaining dialect attributes        
    if dialect.escapechar is None:
        dialect.escapechar='/'
    dialect.skipinitialspace=True
    dialect.strict=False
    return dialect

def read_header(fullpath, dialect = None):
    """Get the header line of a CSV or TXT data file.
    parameters:
        fullpath - the full path to the file to process
        dialect - a csv.dialect object with the attributes of the input file
    returns:
        header - a list containing the fields in the original header
    """
    # Cannot function without a file
    if fullpath is None or len(fullpath)==0:
        return None

    # Cannot function without an actual file where full path points
    if os.path.isfile(fullpath) == False:
        return None

    header = None

    # If no explicit dialect for the file is given, figure it out from the file
    if dialect is None:
        dialect = csv_file_dialect(fullpath)

    # Open up the file for processing
    with open(fullpath, 'rU') as csvfile:
        reader = csv.DictReader(csvfile, dialect=dialect)
        # header is the list as returned by the reader
        header=reader.fieldnames

    # Return the header from the file
    return header

def clean_header(header):
    """Construct a header from the cleaned field names in a header.
    parameters:
        header - the header to clean
    returns:
        cleanheader - the header after cleaning
    """
    # Cannot function without a header
    if header is None or len(header)==0:
        return None

    cleanheader = []
    i=1

    # Clean every field in the header and append it to the cleanheader
    for field in header:
        cleanfield = clean_field_name(field)
        if len(cleanfield)==0:
            cleanfield = 'field%s' % i
        cleanheader.append(cleanfield)
        i+=1

    # Return a version of the header that has been cleaned
    return cleanheader
    
def clean_field_name(fieldname):
    """Construct a clean field name as a lowercase field name stripped of white space.
    parameters:
        fieldname - the field name to clean
    returns:
        cleanfield - the field name after changing to lower case and stripping white space
    """
    # Cannot function without a fieldname
    if fieldname is None or len(fieldname)==0:
        return None

    cleanfield = fieldname.strip().lower()
    return cleanfield

### Testing Framework ###
# Conducts tests as it runs the MIxS as RDF creation process
class MIxSToRDFFramework():

    classlookupfile = 'class_lookup.csv'
    dwclookupfile = 'dwc_lookup.csv'
    envolookupfile = 'envo_lookup.csv'
    mixscorefilename = 'mixs_core.csv'
    mixsclassesfilename = 'mixs-classes.rdf'
    mixsheaderfilename = 'mixs-header.rdf'

    def dispose(self):
#         testcorerdffile = self.testcorerdffile
#         if os.path.isfile(testcorerdffile):
#             os.remove(testcorerdffile)
        return True

class MIxSToRDFTestCase(unittest.TestCase):
    workspace = None
    previousworkspace = None
    rdfoutput = None

    def setUp(self):
        self.framework = MIxSToRDFFramework()

    def tearDown(self):
        self.framework.dispose()
        self.framework = None

    def test_source_files_exist(self):
        print 'testing source_files_exist'
        ws = self.workspace
        pws = self.previousworkspace
        classlookupfile = self.framework.classlookupfile
        dwclookupfile = self.framework.dwclookupfile
        envolookupfile = self.framework.envolookupfile
        mixscorefilename = self.framework.mixscorefilename
        mixsclassesfilename = self.framework.mixsclassesfilename
        mixsheaderfilename = self.framework.mixsheaderfilename

        check = ws.strip('/')+'/'+classlookupfile
        self.assertTrue(os.path.isfile(check), check + ' does not exist')
        
        check = ws.strip('/')+'/'+dwclookupfile
        self.assertTrue(os.path.isfile(check), check + ' does not exist')

        check = ws.strip('/')+'/'+envolookupfile
        self.assertTrue(os.path.isfile(check), check + ' does not exist')

        check = ws.strip('/')+'/'+mixscorefilename
        self.assertTrue(os.path.isfile(check), check + ' does not exist')

        check = ws.strip('/')+'/'+mixsclassesfilename
        self.assertTrue(os.path.isfile(check), check + ' does not exist')

        check = ws.strip('/')+'/'+mixsheaderfilename
        self.assertTrue(os.path.isfile(check), check + ' does not exist')

        check = pws.strip('/')+'/'+mixscorefilename
        self.assertTrue(os.path.isfile(check), check + ' does not exist')

    def test_csv_file_dialect(self):
        print 'testing csv_file_dialect'
        ws = self.workspace
        pws = self.previousworkspace
        classlookupfile = self.framework.classlookupfile
        dwclookupfile = self.framework.dwclookupfile
        envolookupfile = self.framework.envolookupfile
        mixscorefilename = self.framework.mixscorefilename
        mixsclassesfilename = self.framework.mixsclassesfilename
        mixsheaderfilename = self.framework.mixsheaderfilename

        check = ws.strip('/')+'/'+classlookupfile
        dialect = csv_file_dialect(check)
#        print 'dialect:\n%s' % dialect_attributes(dialect)
        self.assertIsNotNone(dialect, 'unable to detect csv file dialect')
        self.assertEqual(dialect.delimiter, ',',
            'incorrect delimiter detected for csv file')
        self.assertEqual(dialect.lineterminator, '\r\n',
            'incorrect lineterminator for csv file')
        self.assertEqual(dialect.escapechar, '/',
            'incorrect escapechar for csv file')
        self.assertEqual(dialect.quotechar, '"',
            'incorrect quotechar for csv file')
        self.assertFalse(dialect.doublequote,
            'doublequote not set to False for csv file')
        self.assertEqual(dialect.quoting, csv.QUOTE_MINIMAL,
            'quoting not set to csv.QUOTE_MINIMAL for csv file')
        self.assertTrue(dialect.skipinitialspace,
            'skipinitialspace not set to True for csv file')
        self.assertFalse(dialect.strict,
            'strict not set to False for csv file')

        check = ws.strip('/')+'/'+dwclookupfile
        dialect = csv_file_dialect(check)
#        print 'dialect:\n%s' % dialect_attributes(dialect)
        self.assertIsNotNone(dialect, 'unable to detect csv file dialect')
        self.assertEqual(dialect.delimiter, ',',
            'incorrect delimiter detected for csv file')
        self.assertEqual(dialect.lineterminator, '\r\n',
            'incorrect lineterminator for csv file')
        self.assertEqual(dialect.escapechar, '/',
            'incorrect escapechar for csv file')
        self.assertEqual(dialect.quotechar, '"',
            'incorrect quotechar for csv file')
        self.assertFalse(dialect.doublequote,
            'doublequote not set to False for csv file')
        self.assertEqual(dialect.quoting, csv.QUOTE_MINIMAL,
            'quoting not set to csv.QUOTE_MINIMAL for csv file')
        self.assertTrue(dialect.skipinitialspace,
            'skipinitialspace not set to True for csv file')
        self.assertFalse(dialect.strict,
            'strict not set to False for csv file')

        check = ws.strip('/')+'/'+envolookupfile
        dialect = csv_file_dialect(check)
#        print 'dialect:\n%s' % dialect_attributes(dialect)
        self.assertIsNotNone(dialect, 'unable to detect csv file dialect')
        self.assertEqual(dialect.delimiter, ',',
            'incorrect delimiter detected for csv file')
        self.assertEqual(dialect.lineterminator, '\r\n',
            'incorrect lineterminator for csv file')
        self.assertEqual(dialect.escapechar, '/',
            'incorrect escapechar for csv file')
        self.assertEqual(dialect.quotechar, '"',
            'incorrect quotechar for csv file')
        self.assertFalse(dialect.doublequote,
            'doublequote not set to False for csv file')
        self.assertEqual(dialect.quoting, csv.QUOTE_MINIMAL,
            'quoting not set to csv.QUOTE_MINIMAL for csv file')
        self.assertTrue(dialect.skipinitialspace,
            'skipinitialspace not set to True for csv file')
        self.assertFalse(dialect.strict,
            'strict not set to False for csv file')

        check = ws.strip('/')+'/'+mixscorefilename
        dialect = csv_file_dialect(check)
#        print 'dialect:\n%s' % dialect_attributes(dialect)
        self.assertIsNotNone(dialect, 'unable to detect csv file dialect')
        self.assertEqual(dialect.delimiter, ',',
            'incorrect delimiter detected for csv file')
        self.assertEqual(dialect.lineterminator, '\r\n',
            'incorrect lineterminator for csv file')
        self.assertEqual(dialect.escapechar, '/',
            'incorrect escapechar for csv file')
        self.assertEqual(dialect.quotechar, '"',
            'incorrect quotechar for csv file')
        self.assertFalse(dialect.doublequote,
            'doublequote not set to False for csv file')
        self.assertEqual(dialect.quoting, csv.QUOTE_MINIMAL,
            'quoting not set to csv.QUOTE_MINIMAL for csv file')
        self.assertTrue(dialect.skipinitialspace,
            'skipinitialspace not set to True for csv file')
        self.assertFalse(dialect.strict,
            'strict not set to False for csv file')

    def test_read_headers(self):
        print 'testing read_headers'
        ws = self.workspace
        pws = self.previousworkspace
#        ws = self.framework.workspace
#        pws = self.framework.previousworkspace
        classlookupfile = self.framework.classlookupfile
        dwclookupfile = self.framework.dwclookupfile
        envolookupfile = self.framework.envolookupfile
        mixscorefilename = self.framework.mixscorefilename
        mixsclassesfilename = self.framework.mixsclassesfilename
        mixsheaderfilename = self.framework.mixsheaderfilename

        check = ws.strip('/')+'/'+classlookupfile
        header = read_header(check)
        modelheader = []
        modelheader.append('section')
        modelheader.append('organizedInClass')
#        print 'len(header)=%s len(model)=%s\nheader:\n%smodel:\n%s' \
#            % (len(header), len(modelheader), header, modelheader)
        self.assertEqual(len(header), 2, 'incorrect number of fields in header')
        self.assertEqual(header, modelheader, 'header not equal to the model header')

        check = ws.strip('/')+'/'+dwclookupfile
        header = read_header(check)
        modelheader = []
        modelheader.append('mixsterm')
        modelheader.append('dwcterm')
#        print 'len(header)=%s len(model)=%s\nheader:\n%smodel:\n%s' \
#            % (len(header), len(modelheader), header, modelheader)
        self.assertEqual(len(header), 2, 'incorrect number of fields in header')
        self.assertEqual(header, modelheader, 'header not equal to the model header')

        check = ws.strip('/')+'/'+envolookupfile
        header = read_header(check)
        modelheader = []
        modelheader.append('mixsterm')
        modelheader.append('envoterm')
#        print 'len(header)=%s len(model)=%s\nheader:\n%smodel:\n%s' \
#            % (len(header), len(modelheader), header, modelheader)
        self.assertEqual(len(header), 2, 'incorrect number of fields in header')
        self.assertEqual(header, modelheader, 'header not equal to the model header')

        check = ws.strip('/')+'/'+mixscorefilename
        header = read_header(check)
        modelheader = []
        modelheader.append('short_name')
        modelheader.append('long_name')
        modelheader.append('definition')
        modelheader.append('expected_value')
        modelheader.append('syntax')
        modelheader.append('example')
        modelheader.append('occurrence')
        modelheader.append('section')
        modelheader.append('eu')
        modelheader.append('ba')
        modelheader.append('pl')
        modelheader.append('vi')
        modelheader.append('org')
        modelheader.append('me')
        modelheader.append('mimarks_s')
        modelheader.append('mimarks_c')
        modelheader.append('pos')
        modelheader.append('preferred_unit')
#        print 'len(header)=%s len(model)=%s\nheader:\n%smodel:\n%s' \
#            % (len(header), len(modelheader), header, modelheader)
        self.assertEqual(len(header), 18, 'incorrect number of fields in header')
        self.assertEqual(header, modelheader, 'header not equal to the model header')

    def test_make_mixs_core_as_rdf(self):
        print 'testing make_mixs_core_as_rdf'
        ws = self.workspace
        pws = self.previousworkspace
        output = self.rdfoutput
        success = make_mixs_core_as_rdf(ws, pws, output)

        s = '%s not written to %s' % (output, ws)
        self.assertTrue(success, s)

if __name__ == '__main__':
    if len(sys.argv)>1:
        MIxSToRDFTestCase.rdfoutput = sys.argv.pop()
        MIxSToRDFTestCase.previousworkspace = sys.argv.pop()
        MIxSToRDFTestCase.workspace = sys.argv.pop()
    unittest.main()
