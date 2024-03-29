import re
import os
import shutil
import shared

insert = [("--dofile insert", "--end dofile insert", """
local function dofile(absfilename) --dofile is broken in some versions
	local file, err = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename .. " : " .. err)
	end
	return file()
end
"""),
("--wget insert", "--end wget insert", """
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
"""),
("--get insert", "--end get insert", """
local function get( sUrl )
	write( "Connecting to " .. sUrl .. "... " )

	local ok, err = http.checkURL( sUrl )
	if not ok then
		error(err)
		if err then
			printError( err )
		end
		return nil
	end

	local response = http.get( sUrl , nil , true )
	if not response then
		error( "Failed." )
		return nil
	end

	print( "Success." )

	local sResponse = response.readAll()
	response.close()
	return sResponse
end
"""),
("--branch insert", "--end branch insert", """
local branch = "master"
""")

]


def placebetween(commentbefore, commentafter, code, text):
	return re.sub(re.escape(commentbefore) + "[\\s\\S]*" + re.escape(commentafter), commentbefore +  code +  commentafter, text)
	
def process(text):
	for i in insert:
		text = placebetween(i[0], i[1], i[2], text)
	return text

def sanitizeLuaFile(filename):
	inputfile = open(filename, 'r')
	text = inputfile.read()
	inputfile.close()
	outputfile = open(filename, 'w')
	outputfile.write(process(text))
	outputfile.close()

shared.mapLuaFiles(".", sanitizeLuaFile)