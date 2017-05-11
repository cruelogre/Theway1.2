-- require "cocos.init"

--global var



CC_CONTENT_SCALE_FACTOR = function()
    return cc.Director:getInstance():getContentScaleFactor()
end


CC_POINT_PIXELS_TO_POINTS = function(pixels)
    return cc.p(pixels.x/CC_CONTENT_SCALE_FACTOR(), pixels.y/CC_CONTENT_SCALE_FACTOR())
end

CC_POINT_POINTS_TO_PIXELS = function(points)
    return cc.p(points.x*CC_CONTENT_SCALE_FACTOR(), points.y*CC_CONTENT_SCALE_FACTOR())
end



--radiansNormalizer
function radNormalize(rad)
    local pi2 = 2*math.pi
    rad = rad % pi2
    rad = (rad + pi2)%pi2
    if rad > math.pi then
        rad = rad - math.pi
    end
    return rad
end

-- getpostable
function getPosTable(obj)
	local posX,posY = obj:getPosition()
	return {x= posX,y=posY} 
end



-- change table to enum type
function CreateEnumTable(tbl, index)
    local enumTable = {}
    local enumIndex = index or -1
    for i, v in ipairs(tbl) do
        enumTable[v] = enumIndex + i
    end
    return enumTable
end

function removeAll(table)
	if table then
		while true do
			local k =next(table)
			if not k then break end
			table[k] = nil
		end
	end

end

List = {}
function List.new()
	return {first = 0, last = -1}
end

function List.pushfirst(list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function List.pushlast(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popfirst(list)
	local first = list.first
	if first > list.last then return nil end
	local value = list[first]
	list[first] = nil
	list.first = first + 1
	return value
end

function List.poplast(list)
	local last = list.last
	if list.first > last then return nil end
	local value = list[last]
	list[last] = nil
	list.last = last - 1
	return value	
end

function List.removeAll(list)
    removeAll(list)
    list.first = 0
    list.last = -1
end

function List.getSize(list)
    return list.last - list.first + 1
end

function List.first(list)
    local value = nil
    if list.first <= list.last then
        value = list[first]
    end
    
    return value
end

function List.remove(list, index)
    if index < list.first or index > list.last then return end
    
    while index <= list.last do
        list[index] = nil
        list[index] = list[index+1]
        index = index + 1
    end
    
    list.last = list.last -1
end

function List.removeObj(list, obj)
    if obj == nil or List.getSize(list) == 0 then return end
    
    for index=list.first, List.getSize(list) do
    	if list[index] == obj then
    		List.remove(list,index)
    		break
    	end
    end    
end

function copyTable(t1, t2)
    for key, var in pairs(t1) do
        t2[key] = var
    end
end

function delayExecute(target, func, delay)
    local wait = cc.DelayTime:create(delay)
    target:runAction(cc.Sequence:create(wait, cc.CallFunc:create(func)))
end

function DEGREES_TO_RADIANS(__ANGLE__) 
    return __ANGLE__ * 0.01745329252
end
function RADIANS_TO_DEGREES(__ANGLE__)
    return __ANGLE__ * 57.29577951
end
--subtract string at k and return 1-k
function rsubStringFront(str,k)
	local ts = string.reverse(str)
	local i = string.find(ts,string.reverse(k))
	if i==nil then
		return nil
	end
	local m = string.len(ts)-i+1 - string.len(k)
	return string.sub(str,1,m)
 end
--subtract string at k and return k+1-end
function rsubStringBack(str,k)
	local ts = string.reverse(str)
	local i = string.find(ts,string.reverse(k))
	if i==nil then
		return nil
	end
	local m = string.len(ts)-i+1
	return string.sub(str,m+1,string.len(ts))
 end

--- does s only contain digits?.
function isdigit(s)
    return string.find(s,'^%d+$') == 1
end