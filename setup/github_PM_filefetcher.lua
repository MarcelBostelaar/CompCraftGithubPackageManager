function findAll(pattern, someString)
	local items = {}
	local S,E = string.find(someString, pattern)
	while S do
		items[#items+1] = {S,E}
		S,E = string.find(someString,pattern,E+1)
	end
	return items
end

function split(pattern, someString)
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

function join(list, joiner)
	local total = nil
	for _,v in ipairs(list) do
		print(v)
		if total == nil then
			total = v
		else
			total = total .. joiner .. v
		end
	end
	return total
end	

local function fetchPathOfModule(modulename)
	local opened = fs.open("packagepaths", 'r')
	if fs == nil then
		error("Could not open package paths file")
	end
	local alltext = opened.readAll()
	local deserialized = textutils.unserialize(alltext)
	if deserialized[modulename] == nil then
		print(deserialized)
		error("Could not find package path " .. modulename)
	end
	return deserialized[modulename]
end

--dofile insert
local function dofile(absfilename) --dofile is broken in some versions
	local file = loadfile(absfilename)
	if file == nil then
		error("Could not load file " .. absfilename)
	end
	return file()
end
--end dofile insert

function getAbsolutePath(modulename, relativePath)
	local modulepath = fetchPathOfModule(modulename)
	local modulesplitted = split("/", modulepath)
	local splitted = split("/", relativePath)
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
	print("PATH:")
	for i=1,#modulesplitted - countedescapes do
		print(modulesplitted[i])
		newpath[i] = modulesplitted[i]
	end
	for i=countedescapes+1,#splitted do
		print(splitted[i])
		newpath[#newpath+1] = splitted[i]
	end
	local joined = join(newpath, "/")
	return joined
end

function loadSubmodule(modulename, relativePath)
	print("loading submodule " .. modulename .. " " .. relativePath)
	local abspath = getAbsolutePath(modulename, relativePath)
	if abspath == nil then
		error("Could not resolve path " .. relativePath .. " in module " .. modulename)
	end
	print(abspath)
	print(dofile == nil)
	return dofile(abspath)
end