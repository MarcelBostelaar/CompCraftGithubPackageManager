require("computercraft_mockup/loadAllCCmockup")
os.loadAPI("github_PM_filefetcher")
local httpfuncs = github_PM_filefetcher.loadSubmodule("GithubPackageManager","http/functions")
local url_handler = github_PM_filefetcher.loadSubmodule("GithubPackageManager","url_handler")
local jsonparser = github_PM_filefetcher.loadSubmodule("GithubPackageManager","tinyjsonparser")

local targetfolder = "build"

local function getTreeURL(gitInfo, branch)
	local url = "https://api.github.com/repos/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .."/git/trees/".. branch .."?recursive=1"
	return url
end

local function getResourceURL(gitInfo, branch, relativeurl)
  local url = "https://raw.githubusercontent.com/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .. "/" .. branch .. "/" .. relativeurl
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
  print(shell == nil)
  local itemstocopy = getFilesInfo(gitaddress, branch)
  for _,v in pairs(itemstocopy) do
    httpfuncs.wget(v.url, targetfolder .. "/" .. v.path, true)
  end
end

local this = {}
this.copyRemoteFiles = copyRemoteFiles
return this