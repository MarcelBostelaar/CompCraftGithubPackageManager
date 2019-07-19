local function findAll(pattern, someString)
	local items = {}
	local S,E = string.find(someString, pattern)
	while S do
		items[#items+1] = {S,E}
		S,E = string.find(someString,pattern,E+1)
	end
	return items
end

local function split(pattern, someString)
	local matches = findAll(pattern, someString)
	local prev = 0
	local items = {}
	for unit, i in pairs(matches) do
		items[#items + 1] = string.sub(someString,prev, i[1]-1)
		prev = i[2] + 1
	end
	items[#items + 1] = string.sub(someString,prev, #someString)
	return items
end

local function join(list, joiner)
	local total = nil
	for _,v in ipairs(list) do
		if total == nil then
			total = v
		else
			total = total .. joiner .. v
		end
	end
	return total
end	
local configPath = "GPM"
local packagepathPath = "packagepaths"

--[[
Loads and deserializes a config file
]]
function LoadConfig(file)
	local opened = fs.open(configPath .. "/" .. file, 'r')
  assert(opened, "Could not open config file: " .. configPath .. "/" .. file)
	local alltext = opened.readAll()
  opened.close()
  assert(alltext)
	local deserialized = textutils.unserialize(alltext)
  assert(deserialized,"Could not deserialize " .. file)
  return deserialized
end
--[[
Writes table to a config file if it doesnt exist yet
]]
function CreateConfigIfNotExist(file, defaultcontent)
  local thispath = configPath .. "/" .. file
	local opened = fs.open(thispath, 'r')
	if opened == nil then
    print("Config file ".. file .." didnt exist")
		opened = fs.open(thispath, 'w')
    opened.write(defaultcontent)
    opened.close()
	end
end

function ReplaceConfigIfCorrupt(file, content)
	local opened = fs.open(configPath .. "/" .. file, 'r')
  assert(opened, "Could not find config file: " .. configPath .. "/" .. file)
	local alltext = opened.readAll()
  opened.close()
  assert(alltext)
	local deserialized = textutils.unserialize(alltext)
  if deserialized == nil then
    print("Config file ".. file .." was corrupt")
    WriteConfig(file, content)
  end
end

--[[
Serializes and writes a table to a config file
]]
function WriteConfig(file, content)
  local opened = fs.open(configPath .. "/" .. file, 'w')
  assert(opened, "cannot open " .. configPath .. "/" .. file)
	opened.write(textutils.serialize(content))
  opened.close()
end

local function WritePackageData(data)
  WriteConfig(packagepathPath, data)
end

function loadPackageData()
	return LoadConfig(packagepathPath)
end

function addPackageData(packagejson, installationfolder)
  assert(packagejson)
  assert(installationfolder)
  assert(packagejson.package_name)
  local existingdata = loadPackageData()
  local folderlocation = installationfolder .. "/" .. packagejson.package_name
  if existingdata[packagejson.package_name] == nil then
	existingdata[packagejson.package_name] = {}
  end
  existingdata[packagejson.package_name].folder = folderlocation
  if packagejson.path ~= nil then
    existingdata[packagejson.package_name].path = folderlocation .. "/" .. packagejson.path
  end
  WritePackageData(existingdata)
end

local function fetchPathOfModule(modulename)
	local deserialized = loadPackageData()
	if deserialized[modulename] == nil then
		print(deserialized)
		error("Could not find package path " .. modulename)
	end
	return deserialized[modulename].folder
end

--dofile insert
local function dofile(absfilename) --dofile is broken in some versions
	local file, err = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename .. " : " .. err)
	end
	return file()
end
--end dofile insert

function getAbsolutePath(modulename, relativePath)
  assert(modulename)
  assert(relativePath)
	local modulepath = fetchPathOfModule(modulename)
  assert(modulepath, "Could not fetch path of module: " .. modulename)
	local modulesplitted = split("/", modulepath)
  assert(modulesplitted)
	local splitted = split("/", relativePath)
  assert(splitted)
	local countedescapes = 0
	local gotreal = false
	for _,v in ipairs(splitted) do
		if v == ".." and not gotreal then
			countedescapes = countedescapes + 1
		else
			gotreal = true
		end
	end
	local newpath = {}
	for i=1,#modulesplitted - countedescapes do
		newpath[i] = modulesplitted[i]
	end
	for i=countedescapes+1,#splitted do
		newpath[#newpath+1] = splitted[i]
	end
	local joined = join(newpath, "/")
	return joined
end

function loadSubmodule(modulename, relativePath)
	local abspath = getAbsolutePath(modulename, relativePath)
	if abspath == nil then
		error("Could not resolve path " .. relativePath .. " in module " .. modulename)
	end
	return dofile(abspath)
end