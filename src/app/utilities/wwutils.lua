function cc.exports.performFunction(callback, delay)
    -- body
    local scheduler = cc.Director:getInstance():getScheduler()
    delay = checknumber(delay)
    if delay < 0 then delay = 0 end

    local entryId
    entryId = scheduler:scheduleScriptFunc( function(dt)
        -- body
        scheduler:unscheduleScriptEntry(entryId)

        callback()
    end , delay, false)
end

function cc.exports.hexhtml2c3b(htmlColor)
    -- body
    local r, g, b = string.match(htmlColor,
    "^#([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])$")
    r, g, b = tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)

    return cc.c3b(r, g, b)
end

function cc.exports.hexstr2c3b(strColor, withPrefix)
    -- body
    local r, g, b
    if withPrefix then
        r, g, b = string.match(strColor,
        "^0[xX]([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])$")
    else
        r, g, b = string.match(strColor,
        "^([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])$")
    end
    r, g, b = tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)

    return cc.c3b(r, g, b)
end

--[[
--  formatTime - "yyyy-mm-dd hh:MM:ss"
--]]

local function splitDataTime(formatTime)
    -- body
    return formatTime:match("^(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)$")
end

function cc.exports.formatTime2Number(formatTime)
    -- body
    if not formatTime or type(formatTime) ~= "string" then
        return os.time()
    end

    local year, month, day, hour, min, sec = splitDataTime(formatTime)
    if nil == year then
        return os.time()
    end

    return os.time( { year = year; month = month; day = day; hour = hour; min = min; sec = sec; })
end
-- 秒转换成时间 表
function cc.exports.secondToTime(secounds)
    local hourLen = 60 * 60
    local minusLen = 60
    local hour = math.floor(secounds / hourLen)
    local minus = math.floor((secounds - hour * hourLen) / minusLen)
    local secound = secounds % minusLen
    return { hour = hour, minus = minus, secound = secound }
end
-- 秒转换成时间 00:00:00
function cc.exports.secoundToTimeString(secounds)
    local showStr = tostring(secounds)
    local t = secondToTime(secounds)


    if t.hour > 0 then
        showStr = string.format("%s", t.hour > 9 and tostring(t.hour) or "0" .. tostring(t.hour))
        showStr = showStr .. ":" .. string.format("%s", t.minus > 9 and tostring(t.minus) or "0" .. tostring(t.minus))
        showStr = showStr .. ":" .. string.format("%s", t.secound > 9 and tostring(t.secound) or "0" .. tostring(t.secound))
    else
        if t.minus > 0 then
            showStr = string.format("%s", t.minus > 9 and tostring(t.minus) or "0" .. tostring(t.minus))
            showStr = showStr .. ":" .. string.format("%s", t.secound > 9 and tostring(t.secound) or "0" .. tostring(t.secound))
        else
            showStr = tostring(t.secound)
        end
    end

    return showStr
end

-- 秒转换成时间 最大时间为分钟  显示为 xx分钟 或者 xx分xx秒
function cc.exports.secoundToTimeString2(secounds)
	local secounds1 = tonumber(secounds)
    local showStr = tostring(secounds1)
   --一分钟之内
	if secounds1 <60 then
		showStr = showStr..i18n:get('str_common','comm_second')
	elseif secounds1 % 60 ==0 then --整数分钟
		showStr = string.format("%d%s",(secounds1/60),i18n:get('str_common','comm_minus1'))
	else
		showStr = string.format("%d%s%d%s",(secounds1/60),i18n:get('str_common','comm_minus0')
		,(secounds1%60),i18n:get('str_common','comm_second'))
	end
    return showStr
end

-- 秒转换成时间 00:00 全部显示 最大为分钟
function cc.exports.secoundToTimeString3(secounds)
    local showStr = tostring(secounds)
    local t = secondToTime(secounds)
	local minus =  t.hour*60+t.minus
	showStr = string.format("%s", minus > 9 and tostring(minus) or "0" .. tostring(minus))
	showStr = showStr .. ":" .. string.format("%s", t.secound > 9 and tostring(t.secound) or "0" .. tostring(t.secound))
    return showStr
end
--[[

时间格式成日期
time：指定时间，需是os.time()返回值
format:时间格式 "%Y-%m-%d" 或 "%Y/%m/%d" 或 "%Y/%m/%d %H:%M:%S" 默认"%Y-%m-%d %H:%M:%S"
return：格式好的日期

]]
function cc.exports.secondToDate(time, format)
    local date
    format = format or "%Y-%m-%d %H:%M:%S"

    if time ~= nil then
        --        if type(time) ~= "number" then
        --            error("type error")
        --        end
        date = os.date(format, time)
    else
        date = os.date(format, os.time())
    end
    return date
end

function cc.exports.getTimestampvalue()
    local format = "%Y-%m-%d %H:%M:%S"
    return os.date(format, os.time())
end

function cc.exports.number2FormatTime(number)
    -- body
    number = checknumber(number)

    return os.date("%Y-%m-%d %X", number)
end

--[[
--  根据指定的精度获取时间差
-- @param[in] precision - 精度标识
-- @note: "y"-年, "m"-月, "d"-日, "h"-时, "M"-分, "s"-秒
--]]
function cc.exports.timeDiffWithPrecision(time1, time2, precision)
    -- body
    if type(time1) == "number" then
        time1 = number2FormatTime(time1)
    end
    if type(time2) == "number" then
        time2 = number2FormatTime(time2)
    end
    local y, m, d, h, M, s = splitDataTime(time1)
    local time1Table = { year = y, month = m, day = d, hour = h, min = M, sec = s }
    y, m, d, h, M, s = splitDataTime(time2)
    local time2Table = { year = y, month = m, day = d, hour = h, min = M, sec = s }
    precision = precision or "s"
    repeat
        if precision == "s" then break end
        time1Table.sec = 0
        time2Table.sec = 0

        if precision == "M" then break end
        time1Table.min = 0
        time2Table.min = 0

        if precision == "h" then break end
        time1Table.hour = 0
        time2Table.hour = 0

        if precision == "d" then break end
        time1Table.day = 1
        time2Table.day = 1

        if precision == "m" then break end
        time1Table.month = 1
        time2Table.month = 1

        if precision == "y" then break end
        time1Table.year = 0
        time2Table.year = 0
    until true

    return os.time(time1Table) - os.time(time2Table)
end

-- function cc.exports.dumpInfo(value, desciption, nesting)
--     wwlog("Please use ")
--     if type(DEBUG) ~= "number" or DEBUG < 2 then return end

--     return dump(value, desciption, nesting)
-- end

-----------------------------------------------------------------------------------------
-- keyboard binding
function cc.exports.bindKeyboardEventWithSceneGraph(callback, node)
    -- body
    local function onKeyPressed(keyCode, event)
        -- body
        return callback(cc.Handler.EVENT_KEYBOARD_PRESSED, keyCode, event)
    end

    local function onKeyReleased(keyCode, event)
        -- body
        return callback(cc.Handler.EVENT_KEYBOARD_RELEASED, keyCode, event)
    end
    local keyboardListener = cc.EventListenerKeyboard:create()
    keyboardListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    keyboardListener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardListener, node)
    return keyboardListener
end

function cc.exports.bindKeyboardReleasedEventWithSceneGraph(callback, node)
    -- body
    local function innerCallback(touchType, keyCode, event)
        -- body
        if touchType == cc.Handler.EVENT_KEYBOARD_RELEASED then
            return callback(keyCode, event)
        end
    end
    return bindKeyboardEventWithSceneGraph(innerCallback, node)
end

function cc.exports.bindKeyboardPressedEventWithSceneGraph(callback, node)
    -- body
    local function innerCallback(touchType, keyCode, event)
        -- body
        if touchType == cc.Handler.EVENT_KEYBOARD_PRESSED then
            return callback(keyCode, event)
        end
    end

    return bindKeyboardEventWithSceneGraph(innerCallback, node)
end

function cc.exports.bindKeyboardEventWithFixedPriority(callback, priority)
    -- body
    local function onKeyPressed(keyCode, event)
        -- body
        return callback(cc.Handler.EVENT_KEYBOARD_PRESSED, keyCode, evnet)
    end

    local function onKeyReleased(keyCode, event)
        -- body
        return callback(cc.Handler.EVENT_KEYBOARD_RELEASED, keyCode, event)
    end

    priority = checkint(priority)
    local keyboardListener = cc.EventListenerKeyboard:create()
    keyboardListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    keyboardListener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(keyboardListener, priority)
    return keyboardListener
end

function cc.exports.bindKeyboardPressedEventWithFixedPriority(callback, priority)
    -- body
    local function innerCallback(touchType, keyCode, event)
        -- body
        if touchType == cc.Handler.EVENT_KEYBOARD_PRESSED then
            return callback(keyCode, event)
        end
    end

    return bindKeyboardEventWithFixedPriority(innerCallback, priority)
end

function cc.exports.bindKeyboardReleasedEventWithFixedPriority(callback, priority)
    -- body
    local function innerCallback(touchType, keyCode, event)
        -- body
        if touchType == cc.Handler.EVENT_KEYBOARD_RELEASED then
            return callback(keyCode, event)
        end
    end

    return bindKeyboardEventWithFixedPriority(innerCallback, priority)
end

function cc.exports.unbindKeyboardListener(eventListener)
    -- body
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:removeEventListener(eventListener)
end

-- 遍历utf8字符串，callback = function(startIdx,len) return true end
-- startIdx遍历到某个字符时的起始idx，len为字节长度，
-- return true停止遍历，false继续遍历
function cc.exports.travelUtf8Str(str, callback)
    if str then
        local ret = { }
        local idx = 1
        local utf8Sets = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
        while idx <= #str do
            local tmp = string.byte(str, idx)
            local i = #utf8Sets
            while utf8Sets[i] do
                if tmp >= utf8Sets[i] then
                    -- ret[idx] = i
                    -- ret[#ret + 1] = { k = idx, v = i }
                    if callback(idx, i) then return end
                    idx = idx + i
                    break
                end
                i = i - 1
            end
        end
    end
end

-- 获取target中不超过len长度的字串。规定：一个多字节字符占2个长度，单个字节字符占1个长度。
function cc.exports.subUtf8Str(target, maxLen)
    local tmpLen = 0
    local tmpAdapter = 0
    local ret = nil
    travelUtf8Str(target, function(start, len)
        if tmpAdapter +(len > 1 and 2 or 1) > maxLen then
            ret = string.sub(target, 1, tmpLen)
            return true
        end
        tmpLen = tmpLen + len
        tmpAdapter = tmpAdapter +(len > 1 and 2 or 1)
    end )
    return ret or target
end

-- 返回utf-8编码的混合字符串中的字符个数
function cc.exports.getLenUtf8Str(target)
    local ret = 0
    travelUtf8Str(target, function(start, len)
        ret = ret + 1
    end )
    return ret
end


--截取前X个汉字 或者9个字符
function cc.exports.subHanziStr( context ,len)
	-- body
	local len = len or 5
	local length = string.len(context)
	local hanzi = 0
	local yinwen = 0
	if length > len*2 then
		local str = ""
		local ibyte = 1
		for i=1,length do
			local cValue = string.byte(context,ibyte)
			if cValue > 0 and cValue < 127 then
				str = str..string.sub(context,ibyte,ibyte)
				yinwen = yinwen + 1
				ibyte = ibyte + 1
			else --utf8中文占3个字符
				str = str..string.sub(context,ibyte,ibyte+2)
				hanzi = hanzi + 1
				ibyte = ibyte + 3
			end

			if ibyte > length then
				if hanzi >= len or yinwen >= len*2 or hanzi*3+yinwen >= len*2 then
					return str.."..."
				else
					return str
				end
			else
				if hanzi >= len or yinwen >= len*2 or hanzi*3+yinwen >= len*2 then
					return str.."..."
				end
			end
		end
	else
		return context
	end
end
--------------------------------------------------------------------------------------------
function cc.exports.isLuaNodeValid(node)
    -- body
    return(node and not tolua.isnull(node))
end

--有序table逆序
function cc.exports.reverseTable( tab )
    local tmp = {}
    for i = 1, #tab do
        local key = #tab
        tmp[i] = table.remove(tab)
    end

    return tmp
end