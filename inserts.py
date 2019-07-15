import re
import os
import shutil

dofile = ("--dofile insert", "--end dofile insert", """
local function dofile(absfilename) --dofile is broken in some versions
	local file = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename)
	end
	return file()
end
""")
wget = ("--wget insert", "--end wget insert", """
local function wget( sUrl, sFile, override)  
	if not http then
		printError( "wget requires http API" )
		printError( "Set http_enable to true in ComputerCraft.cfg" )
		return
	end
	 
	-- Determine file to download
	if fs.exists( sFile ) and not override then
		print( "File already exists" )
		return
	end

	-- Do the get
	local res = get( sUrl )
	if res then
		local file = fs.open( sFile, "w" )
		file.write( res )
		file.close()

		print( "Downloaded as "..sFile )
	end
end
""")
get = ("--get insert", "--end get insert", """
local function get( sUrl )
	write( "Connecting to " .. sUrl .. "... " )

	local ok, err = http.checkURL( sUrl )
	if not ok then
		print( "Failed." )
		if err then
			printError( err )
		end
		return nil
	end

	local response = http.get( sUrl , nil , true )
	if not response then
		print( "Failed." )
		return nil
	end

	print( "Success." )

	local sResponse = response.readAll()
	response.close()
	return sResponse
end
""")


def placebetween(commentbefore, commentafter, code, text):
	return re.sub(re.escape(commentbefore) + "[\\s\\S]*" + re.escape(commentafter), commentbefore +  code +  commentafter, text)
	
def process(text):
	text = placebetween(dofile[0], dofile[1], dofile[2], text)
	text = placebetween(wget[0], wget[1], wget[2], text)
	text = placebetween(get[0], get[1], get[2], text)
	return text

def sanitizeLuaFile(filename):
	inputfile = open(filename, 'r')
	text = inputfile.read()
	inputfile.close()
	outputfile = open(filename, 'w')
	outputfile.write(process(text))
	outputfile.close()
	
def sanitizeLua(folder):
	names = os.listdir(folder)
	items = [os.path.join(folder,x) for x in names]
	childfolders = [x for x in items if os.path.isdir(x)]
	lua = [x for x in items if x[-4:] == ".lua" and os.path.isfile(x)]
	for i in childfolders:
		sanitizeLua(i)
	for i in lua:
		sanitizeLuaFile(i)
		
sanitizeLua("src")
sanitizeLua("setup")