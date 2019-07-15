this = {}

local function exists (sUrl)
	local ok, err = http.checkURL( sUrl )
	if not ok then
		print( "Cannot find " .. sUrl )
		if err then
			print( err )
		end
		return false
	end
	return true
end
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


this.exists = exists
this.get = get
this.wget = wget

return this