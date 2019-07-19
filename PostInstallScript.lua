--branch insert
local branch = "master"
--end branch insert
--get insert
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
--end get insert
--wget insert
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
--end wget insert
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/config/GPM_filefetcher.lua" ,"GPM/GPM_filefetcher", true)
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/config/packagepaths" ,"GPM/packagepaths", true)
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/config/startupscript.lua" ,"GPM/startupscript", true)