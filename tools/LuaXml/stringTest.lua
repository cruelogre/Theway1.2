--subtract string at k and return 1-k
function rsubStringFront(str,k)
	local ts = string.reverse(str)
	i = string.find(ts,string.reverse(k))
	if i==nil then
		return nil
	end
	m = string.len(ts)-i+1 - string.len(k)
	return string.sub(str,1,m)
 end
--subtract string at k and return k+1-end
function rsubStringBack(str,k)
	local ts = string.reverse(str)
	i = string.find(ts,string.reverse(k))
	if i==nil then
		return nil
	end
	m = string.len(ts)-i+1
	return string.sub(str,m+1,string.len(ts))
end
--[[local originstr = "test\\2321s\\fsada\\fsa.lua"
local p = "\\"
local s = rsubStringBack(originstr,p)
print(originstr)
print(s)--]]