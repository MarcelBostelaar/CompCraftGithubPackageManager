require("computercraft_mockup/loadAllCCmockup")
os.loadAPI("GPM/GPM_filefetcher")
local httpfuncs = GPM_filefetcher.loadSubmodule("GithubPackageManager","http/functions")
local url_handler = GPM_filefetcher.loadSubmodule("GithubPackageManager","url_handler")
local jsonparser = GPM_filefetcher.loadSubmodule("GithubPackageManager","tinyjsonparser")

local targetfolder = "build"

local function getTreeURL(gitInfo, branch)
  assert(gitInfo)
  assert(branch)
  assert(gitInfo.ownerName)
  assert(gitInfo.repoName)
	local url = "https://api.github.com/repos/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .."/git/trees/".. branch .."?recursive=1"
	return url
end

local function getResourceURL(gitInfo, branch, relativeurl)
  assert(gitInfo)
  assert(branch)
  assert(gitInfo.ownerName)
  assert(gitInfo.repoName)
  local url = "https://raw.githubusercontent.com/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .. "/" .. branch .. "/" .. relativeurl
  return url
end

local function getPackageJsonURL(gitInfo, branch)
  assert(gitInfo)
  assert(branch)
  assert(gitInfo.ownerName)
  assert(gitInfo.repoName)
  local url = "https://raw.githubusercontent.com/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .. "/" .. branch .. "/package.json"
  return url
end

local function getPostInstallScriptURL(gitInfo, branch)
  assert(gitInfo)
  assert(branch)
  assert(gitInfo.ownerName)
  assert(gitInfo.repoName)
  local url = "https://raw.githubusercontent.com/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .. "/" .. branch .. "/PostInstallScript.lua"
  return url
end

local function filter(func, treelist)
  returns = {}
  for _,v in pairs(treelist) do
    if func(v) then
      returns[#returns+1] = v
    end
  end
  return returns
end

local function filterBlob(treelist)
  local function isBlob(item)
    return item.type == "blob"
  end
  return filter(isBlob, treelist)
end

local function filterSubdirectory(treelist, subdir)
  local function filterDirectory(item)
    local subbed = item.path:sub(1,subdir:len()+1)
    return subbed == (subdir .. "/")
  end
  return filter(filterDirectory, treelist)
end
  
local function getFilesInfo(gitaddress, branch)
  local info = url_handler.getGitInfo(gitaddress)
  local treeurl = getTreeURL(info, branch)
  local parsed = jsonparser.parse(httpfuncs.get(treeurl))
  local ofinterest = filterBlob(filterSubdirectory(parsed.tree, targetfolder))
  local items = {}
  for _,v in pairs(ofinterest) do
    local struct = {}
    struct.path = v.path:sub(targetfolder:len()+2)
    struct.url = getResourceURL(info, branch, v.path)
    items[#items+1] = struct
  end
  return items
end

local function copyRemoteFiles(gitaddress, branch, targetfolder)
  local itemstocopy = getFilesInfo(gitaddress, branch)
  for _,v in pairs(itemstocopy) do
    httpfuncs.wget(v.url, targetfolder .. "/" .. v.path, true)
  end
end

local function getPackageJson(gitaddress, branch)
  assert(gitaddress)
  assert(branch)
  local info = url_handler.getGitInfo(gitaddress, branch)
  local url = getPackageJsonURL(info,branch)
  local text = httpfuncs.get(url)
  assert(text)
  local parsed = jsonparser.parse(text)
  assert(parsed)
  return parsed
end

local function getPostInstallScript(gitaddress, branch)
  assert(gitaddress)
  assert(branch)
  local info = url_handler.getGitInfo(gitaddress, branch)
  local url = getPostInstallScriptURL(info,branch)
  assert(url)
  print("getting  postinstall script")
  local text = httpfuncs.get(url)
  assert(text)
  print(text)
  print("loading file")
  local loaded = loadstring(text)
  assert(loaded)
  print("loaded file")
  return loaded
end

local this = {}
this.copyRemoteFiles = copyRemoteFiles
this.getPackageJson = getPackageJson
this.getPostInstallScript = getPostInstallScript
return this