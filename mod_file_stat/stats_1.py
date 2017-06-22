#!/usr/bin/python
# stats.py response to Michaels' email:
# 20170507 6:21PM
#Hi Tom,
#I am helping Pramod write a paper about high performance computing
#transformations using nmodl and in the introduction I'm toying with a possible
#paragraph that reads.
#
#Most published NEURON models rely on model specific NMODL descriptions.
#For example, as of this writing, the ModelDB database
#(https://sendslab.med.yale.edu/modeldb) contains model code for xxx
#NEURON models which include xxx mod files of which xxx are unique.
#Of the total number, xxx of these are channel, and xxx are ion accumulation
#models, xxx are synapse models, xxx are electrode models, and xxx
#describe artificial cells.
#
#Can you fill in as many of the xxx as are easily figured out. It is not necessary
#to be perfect. eg. Number of mod files containing
#ARTIFICIAL_CELL and NET_RECEIVE and net_event,
#POINT_PROCESS and NET_RECEIVE
#ELECTRODE_CURRENT
#USEION and READ current
#SUFFIX and ((USEION and WRITE current) || NONSPECIFIC_CURRENT)
#I'm hoping total number and unique number come from the modelview info.
#Thanks.
#Michael
#

keywords=[['ARTIFICIAL_CELL', 'NET_RECEIVE', 'net_event'],
['POINT_PROCESS', 'NET_RECEIVE'],
['ELECTRODE_CURRENT'],
['USEION', 'READ i'],
['SUFFIX','USEION', 'WRITE i'],
['SUFFIX','USEION', 'NONSPECIFIC_CURRENT']]

print "analyse of these collections of keywords"
for keywordlist in keywords:
  print keywordlist

# from http://stackoverflow.com/questions/18262293/python-open-every-file-in-a-folder

yourpath = 'modeldb'
all_mod_files=[]
 
import os
for root, dirs, files in os.walk(yourpath, topdown=False):
    for name in files:
        path_and_name=os.path.join(root, name)
        # print(path_and_name)
        if len(name)>4:
          if name[-4:].lower()=='.mod':
            all_mod_files.append(path_and_name)
    #for name in dirs:
        # print(os.path.join(root, name))
        # stuff

mod_files_hash={} # filename with path is key, value is md5 hash
hash_mod_files={} # hash is the key, list of mod files that have that hash is key
# from http://stackoverflow.com/questions/3431825/generating-an-md5-checksum-of-a-file
import hashlib

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

for filename in all_mod_files:
  mod_hash=md5(filename)
  mod_files_hash[filename]=md5(filename)
  if mod_hash in hash_mod_files:
    if hash_mod_files[mod_hash]:
      hash_mod_files[mod_hash]=hash_mod_files[mod_hash].append(filename)
    else:
      # print "in none case filename=",filename,', hash=',mod_hash
      hash_mod_files[mod_hash]=[filename]
  else:
    hash_mod_files[mod_hash]=[filename]

print "there are ",len(all_mod_files),' mod files in modeldb of which ',len(hash_mod_files), ' are unique'

# loop over mod files recording which ones have the lists in keywords.  For each list in keywords, all the 
# list items in each list must be present.


def test_in_file(teststring, filetext):
  for line in filetext:
    if teststring in line:
       return True
  return False

# from http://stackoverflow.com/questions/26367812/appending-to-list-in-python-dictionary
from collections import defaultdict

# make a dictionary that has each list from in the keywords list as a
# value and the filename with path of the mod files matching that list
# as the value.

mod_files_with_keywords={}
out_file=open('output_file.dat','w')

key='' # will assign key strings below
for filename in all_mod_files:
  filetext=open(filename,'r').readlines()
  # print 'processing filename:',filename
  for keylist in keywords:
    num_found=0 # count how many keywords in a particular list were found
    for test_element in keylist:
      if (test_in_file(test_element, filetext)):
        num_found=num_found+1
    # print repr(keylist),' found ' ,num_found, ' out of ',len(keylist)
    if num_found==len(keylist):
      key=repr(keylist)
      out_file.write('%s %s %s\n'%(mod_files_hash[filename], filename, key.replace(' ','')))
      # must add the filename to the dict's value for key of that list
      # since a list can not be a key we make the list a string with repr
      if key in mod_files_with_keywords:
          if mod_files_with_keywords[key]:
            mod_files_with_keywords[key]=mod_files_with_keywords[key].append(filename)
          else:
            # print "in none case filename=",filename,', list=',keylist
            mod_files_with_keywords[key]=[filename]
      else:
          mod_files_with_keywords[key]=[filename]

out_file.close()
"""
# the below reveals something is wrong with the dictionary
for key in mod_files_with_keywords:
  if mod_files_with_keywords[key]:
    print key, " has ", len(mod_files_with_keywords[key])
    print key, mod_files_with_keywords[key]
"""
# something is wrong with the dictionary so will proceed to process the output_file.dat
mod_data=open('output_file.dat','r').readlines()
# starts with format like
# "1ff8blahblahblah modeldb/185328/Moore2015/hhkchan.mod ['SUFFIX','USEION','WRITEi']\n"

# change the mod_data into an array of lists
m_d = []
for element in mod_data:
  triple=element.split(' ')
  triple[2]=triple[2].replace('\n','')
  m_d.append(triple)

# find the types of mod files selected
new_search_keys=[]
for keywordlist in keywords:
  print repr(keywordlist).replace(' ','')
  new_search_keys.append(repr(keywordlist).replace(' ',''))

# for each new_search_keys find out how many mod files and how many duplicates
for keyelement in new_search_keys:
  print '--------------------------------------------------------------'
  print "For search key element: ", keyelement
  num_of_keyelement=0
  hashes_of_results=[]
  for element in m_d:
    if element[2]==keyelement:
      num_of_keyelement = num_of_keyelement + 1
      hashes_of_results.append(element[0])
  print "        there are",num_of_keyelement,"files of which",len(set(hashes_of_results)),"are unique"
