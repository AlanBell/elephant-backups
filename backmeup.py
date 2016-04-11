#!/usr/bin/python3
import json
import sys
import getopt
import requests
import hashlib
import json
import os
import gnupg

class backmeup():
    def __init__(self,serverurl,name,key):
        self.endpoint=serverurl
        self.key=key
        self.name=name
        self.gpg = gnupg.GPG(gnupghome='.')
    def filebackup(self,runref,jobreference,filepath):
        #print(filepath)
        #this is a two step backup process, first we send the hash
        #depending on the response to that we might send the file
        #the hash request is going to be blocking
        with open(filepath,"rb") as f:
            filehash=self.hashfile(f)
            #print(filehash)
            payload={'jobreference':jobreference,'fileinfo':json.dumps({filepath:filehash})}
            r=requests.post(self.endpoint+'/haveyougot.php',data=payload,auth=(self.name,self.key))
            print(r.text)
            serverrequest=r.json()
            #the server responds to say it has the file with the matching hash, or it needs it
            if serverrequest['ineed'][0]==filepath:
                #we check if the server needs the file we just offered
                r=requests.post(self.endpoint+'/submit.php',params={'runref':runref,'fileinfo':json.dumps({filepath:filehash})},files={filehash:f})
                print(runref,r.text)
    def folderbackup(self,runref,jobreference,folderpath):
        #we need to walk recursively down a tree of files, checking hashes
        #there is an opportunity here to do multiple requests at a time rather than one at a time
        #but a simplistic call to filebackup should work
        #having built up our array of hashes we send it all to the server
        #that will respond confirming what files it wants
        #and also what files it thinks we may have deleted
        #there may be some opportunity to divide up huge directory trees into multiple requests
        #perhaps a folder at a time
        for root, subdirs, files in os.walk(folderpath):
            print(root)
            filelist={}
            for filename in files:
                with open(os.path.join(root,filename),"rb") as f:
                    filehash=self.hashfile(f)
                    filelist[os.path.join(root,filename)]=filehash
            payload={'jobreference':jobreference,'fileinfo':json.dumps(filelist)}
            try:
                r=requests.post(self.endpoint+'/haveyougot.php',data=payload,auth=(self.name,self.key))
                serverrequest=r.json()
                for neededfile in serverrequest['ineed']:
                    with open(neededfile,"rb") as f:
                        #rehash the file (it may have changed)
                        filehash=self.hashfile(f)
                        f.seek(0)
                        r=requests.post(self.endpoint+'/submit.php',params={'runref':runref,'jobline':jobreference,'path':root,'fileinfo':json.dumps({neededfile:filehash})},files={filehash:self.encrypt(f)})
                        print(runref,neededfile,r.text)
            except Exception as e:
                print("timed out probably, we should make a note of it and come back later. %s" % e)

        #now have a second go at anything that failed
        #this should deal with transient timeouts
        #if this should fail then we should do something more about it.

    def encrypt(self,filehandle):
        #this can return a string, or a file handle
        #return filehandle
        g=self.gpg.encrypt_file(filehandle, recipients=None, symmetric='AES256', passphrase='12345', armor=True)
        return str(g)
    def mysqlbackup(self,username,password,database,host,runref):
        print("backing up a mysql database")
    def mongodbbackup(self,username,password,database,host):
        print("backing up a mongodb database")
    def getjobs(self):
        print("getting job list from server")
        #get request to endpoint/job should provide us with our order of business
        #the key is important, it tells the backup server who we are
        #the backup server may check our IP address is valid for the key
        r=requests.get(self.endpoint + '/job.php',auth=(self.name,self.key))
        print(r.text)
        return r.json()

    def hashfile(self,afile):
        #md5 would work just fine, however this is a bit more robust
        blocksize=65536
        hasher=hashlib.sha256()
        buf=afile.read(blocksize)
        while len(buf)>0:
            hasher.update(buf)
            buf=afile.read(blocksize)
        return hasher.hexdigest()

def main(argv):
    serverurl=''
    key=''
    name=''
    try:
        opts,args=getopt.getopt(argv,"s:k:n:",["server=","name=","key="])
    except getopt.GetoptError:
        print('backmeup.py -s <backup server URL> -n <server name> -k <backup key>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-s':
            serverurl=arg
        if opt == '-k':
            key=arg
        if opt == '-k':
            name=arg
    #create a backup task to that endpoint
    backup=backmeup(serverurl,name,key)
    joblist=backup.getjobs()
    #prioritise individual file backups
    #print(joblist['files'])
    #for (job,filepath) in joblist['File'].items():
    #    backup.filebackup(joblist['runref'],job,filepath)
    for (job,filepath) in joblist['Folder'].items():
        backup.folderbackup(joblist['runref'],job,filepath)

    #now databases
    #recursively backup folders
    #finally things that are to be done incrementally, that involves storing a copy of what we send so we can generate a delta

if __name__ == "__main__":
   main(sys.argv[1:])
