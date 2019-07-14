import shutil
import errno
import os

def copy(src, dest):
	try:
		shutil.copytree(src, dest)
	except OSError as e:
		# If the error was caused because the source wasn't a directory
		if e.errno == errno.ENOTDIR:
			shutil.copy(src, dest)
		else:
			print('Directory not copied. Error: %s' % e)
		input("Press any key to continue")

def sanitizeLuaFile(file, targetname):
	input = open(file, 'r')
	text = input.read()
	input.close()
	os.remove(file)
	text = text.replace("""require("computercraft_mockup/loadAllCCmockup")""","--build CC ready")
	output = open(targetname, 'w')
	output.write(text)
	output.close()
			
def sanitizeLua(folder):
	names = os.listdir(folder)
	items = [os.path.join(folder,x) for x in names]
	childfolders = [x for x in items if os.path.isdir(x)]
	lua = [x for x in items if x[-4:] == ".lua" and os.path.isfile(x)]
	for i in childfolders:
		sanitizeLua(i)
	for i in lua:
		sanitizeLuaFile(i, i[:-4])

try:
	shutil.rmtree("build")
except Exception as e:
	pass
copy("src","build")
shutil.rmtree("build/computercraft_mockup")
sanitizeLua("build")