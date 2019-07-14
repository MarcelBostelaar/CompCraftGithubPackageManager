local files = require("computercraft_mockup/http/fileshandler")

local function checkURL(url)
  return files.getfile(url) ~= nil
end

local function get(url)
  if not checkURL(url) then
    error("Could not find url: " .. url)
  end
  local response = {}
  function response.readAll()
    return files.getfile(url)
  end
  function response.close()
  end
  return response
end

this = {}
this.get = get
this.checkURL = checkURL
return this