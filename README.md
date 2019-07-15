# CompCraftGithubPackageManager (WIP)

GithubPackageManager is a package manager for computercraft.
It allows you to download repositories from github that follow the supported structure as a package in the manager, in the spirit of package managers like pip.
It features a relative path fetcher to make relative path retrieval easier.
The minimal structure is as follows:
* All files in the 'build' folder are copied
* Any loaded module fetched with the relative path fetcher returns a table of its functions/values, rather than putting them into global.

#### How to use:
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

#### Future feature list:
* Actual usability so you can download packages
* Dependencies
* Startup initialisation support

#### Known bugs: