import urllib.request
import os
import re

def stripurl(url):
	return re.sub("[^A-Za-z0-9]", "", url)

def dosingleurl(url):
	req = urllib.request.Request(
		url, 
		data=None, 
		headers={
			'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
		}
		)

	resp = urllib.request.urlopen(req)
	with open(stripurl(url),"w") as fd:
		fd.write(resp.read().decode('utf-8'))
	
inputfile = open("urls.txt")
lines = inputfile.readlines()

errors = False

for i in set(lines):
	try:
		dosingleurl(i)
	except Exception as e:
		errors = True
		print("could not find: " + i)
		print(e)
		
inputfile.close()
os.remove("urls.txt")
open("urls.txt", 'w').close()
if(errors):
	input("Press Enter to continue...")