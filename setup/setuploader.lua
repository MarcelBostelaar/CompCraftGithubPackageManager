-- wget copy since its not in every version yet
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

--dofile insert
local function dofile(absfilename) --dofile is broken in some versions
	local file, err = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename .. " : " .. err)
	end
	return file()
end
--end dofile insert

local function copyFile(url, filename)
	wget(url, "packages/GithubPackageManager/" .. filename, true)
end


print("Downloading filefetcher program")
--branch insert
local branch = "master"
--end branch insert
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/config/GPM_filefetcher.lua" ,"GPM/GPM_filefetcher", true)
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/config/packagepaths" ,"GPM/packagepaths", true)
wget("https://raw.githubusercontent.com/MarcelBostelaar/CompCraftGithubPackageManager/" .. branch .. "/config/startupscript.lua" ,"GPM/startupscript", true)

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

local giturl = "https://github.com/MarcelBostelaar/CompCraftGithubPackageManager"

gitCommunicator.copyRemoteFiles(giturl, branch, "packages/GithubPackageManager")

print("Finished copying remote files")

if not fs.exists( "startup" ) then
  local temp = fs.open("startup", "w")
  temp.close()
end
local input = fs.open("startup", "r")
local text= input.readAll()
input.close()
local output = fs.open("startup", "w")
output.writeLine([[shell.run("GPM/startupscript")]])
output.write(text)
output.close()


print("Starting install")

local install = dofile("packages/GithubPackageManager/" .. "install")
install.install(giturl, branch)

print("Finished installing package manager")


fs.delete("setuploader.lua")