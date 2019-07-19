import os

def mapLuaFiles(folder, luaFunc):
	mapFiles(folder, luaFunc, lambda x : x[-4:] == ".lua")
		
def mapFiles(folder, func, filefilterfunc):
	names = os.listdir(folder)
	items = [os.path.join(folder,x) for x in names]
	childfolders = [x for x in items if os.path.isdir(x)]
	files = [x for x in items if os.path.isfile(x) and filefilterfunc(x)]
	for i in childfolders:
		mapFiles(i, func, filefilterfunc)
	for i in files:
		func(i)