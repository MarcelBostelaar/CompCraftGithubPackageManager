# CompCraftGithubPackageManager

GithubPackageManager is a package manager for computercraft.
It allows you to download repositories from github that follow the supported structure as a package in the manager, in the spirit of package managers like pip.
It features a relative path fetcher to make relative path retrieval easier.
The minimal structure is as follows:
* All files in the 'build' folder are copied
* In the top level of your github repo there needs to be a file "package.json". This needs to contain at least the field "package_name". Optionally, it can include a field "path" which is the folder inside the build which is to be added to the computercraft path, making its contents available to be run on command line from anywhere.
* Any loaded module fetched with the relative path fetcher returns a table of its functions/values, rather than putting them into global.

#### How to install:
Make sure you use a pastebin utility that has been fixed. Do this by copying the utility and changing the following line:
From 
~~~~
local response = http.get(
	"http://pastebin.com/raw.php?i="..textutils.urlEncode( paste )
	)
~~~~
To 
~~~~
local response = http.get(
	"http://pastebin.com/raw/"..textutils.urlEncode( paste ) 
	)
~~~~
Use the following command
~~~~
pastebin run ytPwwFgg
~~~~
or
~~~~
yourpastebincopy run ytPwwFgg
~~~~

This will install the package manager onto your system.

#### How to use:
Once you installed GPM, simply write:
~~~~
GPM install <your repo url here>
~~~~
or
~~~~
GPM install <your repo url here> <branchname here>
~~~~
If the given url points to a github repository with the correct layout, it will be downloaded and installed.

#### Future feature list:
* Dependencies
* Startup initialisation support

#### Known bugs:
* Shell is unavailable in scripts loaded with the file fetcher due to not being excecuted via shell.
