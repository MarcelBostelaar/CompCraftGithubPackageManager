import os
import sys
import re

pattern = None

def dofile(file):
	try:
		inputstream = open(file, 'r')
		lines = inputstream.readlines()
		inputstream.close()
		hasprinted = False
		for i in range(len(lines)):
			if re.search(pattern, lines[i]) is not None:
				if not hasprinted:
					print("\n" + file)
					hasprinted = True
				print(str(i+1) + ":\t" + re.sub("^[\\s]*", "", lines[i]).replace("\n","").replace("\r",""))
	except Exception as e:
		pass


def dofolder(folder):
	names = os.listdir(folder)
	items = [os.path.join(folder,x) for x in names]
	childfolders = [x for x in items if os.path.isdir(x)]
	files = [x for x in items if os.path.isfile(x)]
	for i in childfolders:
		dofolder(i)
	for i in files:
		dofile(i)

def main():
	dofolder(".")
		
if len(sys.argv) == 2:
	pattern = sys.argv[1]
	main()
else:
	print("Wrong number of arguments, should be only regex")