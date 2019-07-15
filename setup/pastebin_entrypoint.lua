-- wget copy since its not in every version yet
--get insert
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
--end get insert
--wget insert
local function wget( sUrl, sFile, override)  
	if not http then
		printError( "wget requires http API" )
		printError( "Set http_enable to true in ComputerCraft.cfg" )
		return
	end
	 
	-- Determine file to download
	local sPath = shell.resolve( sFile )
	if fs.exists( sPath ) and not override then
		print( "File already exists" )
		return
	end

	-- Do the get
	local res = get( sUrl )
	if res then
		local file = fs.open( sPath, "w" )
		file.write( res )
		file.close()

		print( "Downloaded as "..sFile )
	end
end
-- end wget insert

--dofile insert
local function dofile(absfilename) --dofile is broken in some versions
	local file = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename)
	end
	return file()
end
--end dofile insert
--branch insert
local branch = "master"
--end branch insert
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/setup/setuploader.lua", "setuploader.lua", true)
dofile("setuploader.lua")