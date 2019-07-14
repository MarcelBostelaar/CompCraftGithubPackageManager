local this = {}

function this.loadSubmodule(modulename, relativepath)
  if modulename ~= "GithubPackageManager" then
    print("Cannot open module " .. modulename .. " in mockup CC")
    return
  end
  return dofile(relativepath .. ".lua")
end

return this