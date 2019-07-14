--doesnt support escaped or special strings

local function debugmessage(message, json)
	--print(message)
	--print(json:sub(1,50))
	--os.pullEvent( "key" )
end

local parseLine, parseDict, parseList, parseValue

local function consumeWhitespace(json)
	debugmessage("Parsing whitespace", json)
	local value =  string.gsub(json,"^%s+","")
	return value
end

local function ReadNumber(json)
	debugmessage("Parsing number",json)
	json = consumeWhitespace(json)
	if json:len() > 0 then
		local start,ending = json:find("^[0-9]+")
		if start ~= nil and ending ~= nil then
			return tonumber(json:sub(1,ending)),json:sub(ending+1)
		end
	end
	return nil, json
end

local function ReadLiteral(literal, json)
	debugmessage("Parsing literal " .. literal,json)
	json = consumeWhitespace(json)
	if json:len() > 0 then
		local start,ending = json:find("^" .. literal)
		if start ~= nil and ending ~= nil then
			return json:sub(1,ending), json:sub(ending+1)
		end
	end
	return nil, json
end

local function ReadTrue(json)
	debugmessage("Parsing true",json)
	local ret, rest = ReadLiteral("true", json)
	if ret ~= nil then
		return true,rest
	end
	return nil, json
end

local function ReadFalse(json)
	debugmessage("Parsing false",json)
	local ret, rest = ReadLiteral("false", json)
	if ret ~= nil then
		return false,rest
	end
	return nil, json
end

local function consumeChar(character, json)
	debugmessage("Parsing char " .. character,json)
	json = consumeWhitespace(json)
	if json:len() > 0 then
		if json:sub(1,1) == character then
			return json:sub(2)
		end
	end
	return nil
end

local function readString(json)
	debugmessage("Parsing string",json)
	json = consumeWhitespace(json)
	if json:len() >= 2 then
		if string.sub(json,1,1) == "\"" then
			json = json:sub(2)
			local start, ending = string.find(json,"\"")
			if start ~= nil and ending ~= nil then
				return string.sub(json,1,start-1), json:sub(ending+1)
			end
		end
	end
	return nil, json
end

parseLine = function(json)
	debugmessage("Parsing line",json)
	local name, step1 = readString(json)
	local step2 = consumeChar(":",step1)
	
	if name == nil or step2 == nil then
		return nil, json
	end
	
	local returnvalue = {}
	returnvalue.name = name

	local function handle(funcwithresult)
		local ret,step = funcwithresult(step2)
		if ret ~= nil then
			returnvalue.value = ret
			return returnvalue, step
		end
		return nil, step2
	end

	local possibilities = {readString, ReadNumber, ReadTrue, ReadFalse, parseValue}

	for _,x in ipairs(possibilities) do
		local result,rest = handle(x)
		if result ~= nil then
			return result, rest
		end
	end
	return nil, json
end

local function parseCommaSeperated(json, opener, closer, func)
	debugmessage("Parsing comma seperated", json)
	local afterOpener = consumeChar(opener, json)
	if afterOpener == nil then
		debugmessage("Failed parsing comma seperated opening", json)
		return nil, json
	end
	local values = {}
	local continue = true
	local jsonSoFar = afterOpener
	while continue do
		local result, step = func(jsonSoFar)
		if result ~= nil then
			jsonSoFar = step
			values[#values+1] = result
			local afterComma = consumeChar(",", jsonSoFar)
			if afterComma ~= nil then
				jsonSoFar = afterComma
			else
				continue = false
			end
		else
			continue = false
		end
	end
	local afterclose = consumeChar(closer, jsonSoFar)
	if afterclose == nil then
		return nil, json
	end
	return values,afterclose
end

parseDict = function(json)
	debugmessage("parsing dict",json)
	local parsed, stepjson = parseCommaSeperated(json, "{", "}", parseLine)
	if parsed ~= nil then
		local value = {}
		for _, entry in pairs(parsed) do
			value[entry.name] = entry.value
		end
		return value, stepjson
	end
	return nil, json
end

parseList = function(json)
	debugmessage("Parsing list",json)
	return parseCommaSeperated(json, "[", "]", parseDict)
end

parseValue = function(json)
	debugmessage("Parsing value",json)
	local isDict, dictstep = parseDict(json)
	if isDict ~= nil then
		return isDict, dictstep
	end
	local isList, liststep = parseList(json)
	if isList ~= nil then
		return isList, liststep
	end
	return nil, json
end


this = {}

function this.parse(json)
	debugmessage("Parse", json)
	local parsed, rest = parseDict(json)
	if parsed == nil then
		debugmessage("Failed parsing", json)
		return nil
	end
	if consumeWhitespace(rest):len() > 0 then
		print("Parsed json, but the following remains: ")
		print(rest)
	end
	return parsed
end

return this