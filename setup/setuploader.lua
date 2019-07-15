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

--dofile insert
local function dofile(absfilename) --dofile is broken in some versions
	local file = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename)
	end
	return file()
end
--end dofile insert

local function copyFile(url, filename)
	wget(url, "packages/GithubPackageManager/" .. filename, true)
end


print("Downloading filefetcher program")

local branch = "master"

wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/setup/github_PM_filefetcher.lua" ,"github_PM_filefetcher", true)
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/setup/packagepaths" ,"packagepaths", true)

print("Finished downloading filefetcher program")
print("Downloading bootstrapper code for package manager")

copyFile("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/build/githubCommunicator", "githubCommunicator")
copyFile("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/build/http/functions", "http/functions")
copyFile("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/build/tinyjsonparser", "tinyjsonparser")
copyFile("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/build/url_handler", "url_handler")
copyFile("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/build/utils", "utils")

print("Finished downloading bootstrapper code")
print("Downloading full package manager")

local gitCommunicator = dofile("packages/GithubPackageManager/" .. "githubCommunicator")

gitCommunicator.copyRemoteFiles("https://github.com/MarcelBostelaar/CompCraftGithubPackageManager", branch, "packages/GithubPackageManager")

print("Finished installing package manager")