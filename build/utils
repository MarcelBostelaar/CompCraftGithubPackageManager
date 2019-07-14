function findAll(pattern, someString)
	local items = {}
	local S,E = string.find(someString, pattern)
	while S do
		items[#items+1] = {S,E}
		S,E = string.find(someString,pattern,E+1)
	end
	return items
end

function split(pattern, someString)
	local matches = findAll(pattern, someString)
	local prev = 0
	local items = {}
	for unit, i in pairs(matches) do
		items[#items + 1] = string.sub(someString,prev, i[1]-1)
		prev = i[2] + 1
	end
	items[#items + 1] = string.sub(someString,prev, #someString)
	return items
end