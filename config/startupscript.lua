os.loadAPI("GPM/GPM_filefetcher")

local function getpaths()
  local data = GPM_filefetcher.loadPackageData()
  local sPath = shell.path()
  for _,v in pairs(data) do
    if v.path ~= nil then
      sPath = sPath .. ":/" .. v.path
    end
  end
  shell.setPath(sPath)
end

getpaths()