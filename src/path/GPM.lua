require("computercraft_mockup/loadAllCCmockup")
os.loadAPI("GPM/GPM_filefetcher")
local install = GPM_filefetcher.loadSubmodule("GithubPackageManager","install")
local alias = GPM_filefetcher.loadSubmodule("GithubPackageManager","alias")


local function printUsage()
    print( "Incorrect usage" )
    print( "Usages:" )
    print( "GPM install <https://github.com/<owner>/<repo name>/alias>" )
    print( "GPM install <https://github.com/<owner>/<repo name>/alias> <branch>" )
    print( "GPM alias <https://github.com/<owner>/<repo name>> <aliasname>" )
end

local tArgs = { ... }

if tArgs[1] == "install" then
  local fetchedAlias = alias.getAlias(tArgs[2])
  if fetchedAlias ~= nil then
    print("Alias found")
    tArgs[2] = fetchedAlias
  else
    print("Alias not found, trying to use it as a direct url")
  end
  if #tArgs == 2 then
    install.install(tArgs[2], "master")
    return
  end
  if #tArgs == 3 then
    install.install(tArgs[2], tArgs[3])
    return
  end
end
if tArgs[1] == "alias" then
  if #tArgs ~= 3 then
    printUsage()
    return
  end
  alias.addAlias(tArgs[2], tArgs[3])
  return
end
printUsage()