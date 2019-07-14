-- wget copy since its not in every version yet

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

function wget( sUrl, sFile, override)  
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

-- end wget copy

wget("https://raw.githubusercontent.com/kelseyhightower/helloworld/master/README.md", "test", true)
shell.run("test")