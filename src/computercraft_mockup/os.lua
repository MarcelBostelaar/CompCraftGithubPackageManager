local this = {}
--[[
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

local function copytable(sometable)
  copy = {}
  for i,v in pairs(sometable) do
    copy[i] = v
  end
  return copy
end
  
local function subtractTable(superset, subset)
  copiedSuperSet = copytable(superset)
  for i,_ in pairs(copiedSuperSet) do
    if subset[i] ~= nil then
      copiedSuperSet[i] = nil
    else
      print(i)
    end
  end
  return copiedSuperSet
end
]]

function this.loadAPI(filepath)
  if filepath == "GPM_filefetcher" then
    _G.GPM_filefetcher = require("computercraft_mockup/GPM_filefetcher")
    return
  else
    error("loadAPI for anything but the file fetcher is not supported in the mockup. Use dofile instead and make table modules")
  end
  --[[
  local splitted = split("/", filepath)
  local name = splitted[#splitted]
  local old_global = copytable(_G)
  require(filepath)
  print(getGitInfo ~= nil)
  local new_global = _G
  _G = old_global
  _G[name] = subtractTable(new_global, old_global)]]
end

return this