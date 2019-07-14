require("computercraft_mockup/loadAllCCmockup")
os.loadAPI("github_PM_filefetcher")
local httpfuncs = github_PM_filefetcher.loadSubmodule("GithubPackageManager","http/functions")
local url_handler = github_PM_filefetcher.loadSubmodule("GithubPackageManager","url_handler")
local jsonparser = github_PM_filefetcher.loadSubmodule("GithubPackageManager","tinyjsonparser")

local function getTreeURL(gitInfo, branch)
	local url = "https://api.github.com/repos/" .. gitInfo.ownerName .. "/" .. gitInfo.repoName .."/git/trees/".. branch .."?recursive=1"
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
    return item.path:sub(subdir:len()+1) == (subdir .. "/")
  end
  return filter(filterDirectory, treelist)
end
  
function test_printallfiles(gitaddress, branch)
  local info = url_handler.getGitInfo(gitaddress)
  local treeurl = getTreeURL(info, branch)
  local parsed = jsonparser.parse(httpfuncs.get(treeurl))
  local ofinterest = filterBlob(filterSubdirectory(parsed.tree, "build"))
  print(ofinterest)
end

test_printallfiles("https://github.com/MarcelBostelaar/DeepLearningAi.git", "master")