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

local function get( sUrl )
	print( "Connecting to " .. sUrl .. "... " )

	if not exists(sUrl) then
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

local function wget( sUrl, sFile, override)  
	if not http then
		print( "wget requires http API" )
		print( "Set http_enable to true in ComputerCraft.cfg" )
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


this.exists = exists
this.get = get
this.wget = wget

return this