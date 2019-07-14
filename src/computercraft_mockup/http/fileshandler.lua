local file = "computercraft_mockup/http/urls.txt"
local folder = "computercraft_mockup/http/"

this = {}

local function queuenew(url)
  file = io.open("computercraft_mockup/http/urls.txt", 'a')
  file:write(url .. "\n")
  file:close()
end

local function stripletters(url)
  return url:gsub("[^A-Za-z0-9]", "")
end

function this.getfile(url)
  local file = io.open(folder .. stripletters(url), 'r')
  if file == nil then
    queuenew(url)
    error("could not read file " ..url)
    return nil
  end
  local alltext = file:read("*all")
  file:close()
  return alltext
end

return this