require("computercraft_mockup/loadAllCCmockup")
os.loadAPI("GPM_filefetcher")
local entrypoint = GPM_filefetcher.loadSubmodule("GithubPackageManager","entrypoint")


local function printUsage()
    print( "Incorrect usage" )
    print( "Usages:" )
    print( "GPM install <https://github.com/<owner>/<repo name>>" )
    print( "GPM install <https://github.com/<owner>/<repo name>> <branch>" )
end

local tArgs = { ... }
if #tArgs ~= 2 and #tArgs ~= 3 then
    printUsage()
    return
end

if tArgs[1] == "install" then
  if #tArgs == 2 then
    entrypoint.install(tArgs[2], "master")
  end
  if #tArgs == 3 then
    entrypoint.install(tArgs[2], tArgs[3])
  end
else
  printUsage()
end