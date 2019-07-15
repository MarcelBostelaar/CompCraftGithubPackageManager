require("computercraft_mockup/loadAllCCmockup")
os.loadAPI("GPM_filefetcher")
local GHcomm = GPM_filefetcher.loadSubmodule("GithubPackageManager","githubCommunicator")

this = {}
function this.install(gitURL, branch)
  assert(gitURL)
  assert(branch)
  print("Installing branch " .. branch .. " of package " .. gitURL)
  local packagejson = GHcomm.getPackageJson(gitURL, branch)
  assert(packagejson)
  assert(packagejson.package_name)
  GHcomm.copyRemoteFiles(gitURL, branch, "packages/" .. packagejson.package_name)
  GPM_filefetcher.addPackageData(packagejson, "packages")
  term.clear()
  print("Finished installing branch " .. branch .. " of package " .. gitURL)
  print("Please reboot the pc to complete installation")
end
return this