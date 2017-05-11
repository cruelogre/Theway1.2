local JsonDecorator = class("JsonDecorator")

cc.exports.cjson = cc.exports.cjson or luaopen_cjson()

function JsonDecorator:ctor()
	-- body  
end

function JsonDecorator:decode(param)
	-- body
	--[[
	local state = string.match(param, "^%b{}$")
	if not state then 
		return {param}
	end

	return cjson.decode(param)
	--]]

	return pcall(cjson.decode, param)
end

function JsonDecorator:encode(param)
	-- body
	--[[
	if type(param) ~= "table" then 
		local tmp = {param}
		return cjson.encode(tmp)
	else 
		return cjson.encode(param)
	end 
	--]]
	return pcall(cjson.encode, param)
end

return JsonDecorator