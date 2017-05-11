-------------------------------------------------------------------------
-- Desc:    Support初始化
-- Author:  diyal.yin
-- Date:    2015.11.12
-- Last: 
-- Content:  统一处理Log
--    尽量使用wwlog cclog虽然可以用，但是不建议使用
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

-- local print_raw = print

-- print = function(...)
--     if DEBUG > 1 then
--         print_raw(string.format(...))
--     end
-- end
--------------------------------------------------------------------------
--log相关
--------------------------------------------------------------------------
--[[构造cocos风格日志函数]]--
--不建议用，请使用wwlog
cclog = function(...)

    if DEBUG >= 2 then

        local tmp = ...
        if tmp == nil then
            cclog('nil')
            return
        end

        print(string.format(...))
        writeLogFile(...)
    end
end

wwlog = function( moduleName, ...)
    
    if moduleName and ... then
        cclog( '['.. moduleName .. ']' .. string.format(...))
    else
        cclog( moduleName )
    end
end

wwplyaCardLog = function(...)
    if ... and DEBUG >= 2 then
        writePlayCardLogFile(...)
    end
end

--[[错误日志]]--
flog = function(moduleName, ...)
    if string.match(moduleName, '.*/warn')
        or string.match(moduleName, '.*/error')
        or string.match(moduleName, '.*/fatal')
        or string.match(moduleName, 'battle/.*')
        or string.match(moduleName, 'network/.*')
        or string.match(moduleName, '[sqlite]/.*')
    then

        print(moduleName .. ' - ' .. string.format(...))
        writeLogFile(moduleName .. ' - ' .. string.format(...))
    end
end

writeLogFile = function( ... )
    --如果开启了写日志
    if _logConfigParam.writeLog and (DEBUG == 3)  then
		
        local filePath = ww.IPhoneTool:getInstance():getExternalFilesDir().._logConfigParam.logfileName
        io.writefile(filePath, os.date("[%Y-%m-%d %H:%M:%S] ", os.time()) .. string.format(...).."\n", "a")
    else
    end
end

writePlayCardLogFile = function( ... )
    --如果开启了写日志
    if _logConfigParam.writeLog and (DEBUG == 3)  then
        
        local filePath = ww.IPhoneTool:getInstance():getExternalFilesDir().._logConfigParam.playCardLogfileName
        io.writefile(filePath, os.date("[%Y-%m-%d %H:%M:%S] ", os.time()) .. string.format(...).."\n", "a")
    else
    end
end


if DEBUG >= 2 then
    --[[日志文件初始化]]
    function initLogFile()
        local filePath = ww.IPhoneTool:getInstance():getExternalFilesDir().._logConfigParam.logfileName
        if io.exists(filePath) then
            local fileSize = io.filesize(filePath)
            if fileSize > _logConfigParam.logfileSize then
                cclog('[Log Module] logfile is too big, restart from now on : %d', fileSize)
                io.writefile(filePath, string.format('----------------------------------------------------'
                                                     ..'\n[Log Module] logfile is too big, restart from now on')
                                                     .."\n----------------------------------------------------\n", "w+"
                                                    )
            else
                cclog('[Log Module] Currency log file size is : %d', fileSize)
            end
        end

        local playCardLogfile = ww.IPhoneTool:getInstance():getExternalFilesDir().._logConfigParam.playCardLogfileName
        if io.exists(playCardLogfile) then
            local fileSize = io.filesize(playCardLogfile)
            if fileSize > _logConfigParam.logfileSize then
                cclog('[Log Module] logfile is too big, restart from now on : %d', fileSize)
                io.writefile(playCardLogfile, string.format('----------------------------------------------------'
                                                     ..'\n[Log Module] logfile is too big, restart from now on')
                                                     .."\n----------------------------------------------------\n", "w+"
                                                    )
            else
                cclog('[Log Module] Currency log file size is : %d', fileSize)
            end
        end
    end
    initLogFile()
end

--[[ #param luaTable ]]--
function postLog( str )

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open(_logConfigParam.httpPost, _logConfigParam.logServerAdress)

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local sendStr = "username=".._logConfigParam.username .. "&info="..str
    xhr:send(sendStr)
end

local function ccdump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function wwdump(value, desciption, nesting)

    if (DEBUG < 3) or (not _logConfigParam.OpenWWdump) then
        --三级Debug Level以下，或者关闭写dump，则直接return
        return
    end 
       
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    cclog("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(ccdump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent or "", ccdump_value_(desciption) or "", spc or "", ccdump_value_(value) or "")
        -- elseif lookupTable[tostring(value)] then
        --     result[#result +1 ] = string.format("%s%s%s = *REF*", indent, ccdump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent or "", ccdump_value_(desciption) or "")
            else
                result[#result +1 ] = string.format("%s%s = {", indent or "", ccdump_value_(desciption) or "")
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = ccdump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent or "")
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        cclog(line)
    end
end

--[[ #param luaTable ]]--
function showErrorDialog( str )
    if _logConfigParam.dialogLog and (DEBUG >= 1)  then
        --配置了弹窗日志，且Debug Level级别 > 0的情况下，crash弹窗
        ww.IPhoneTool:getInstance():showMessage(str, "Lua Error")
    else
    end
end

--[[重写错误堆栈捕获]]
__G__TRACKBACK__ = function(msg)
    -- local msg = debug.traceback(msg, 3)
    local msgAll = "LUA ERROR: " .. tostring(msg) .. "\n"
        ..debug.traceback().. "\n"

    print(msg)
  
    if _logConfigParam.UploadLog and (DEBUG >= 1) then
        --打开了上传，并且DEBUG Level 大于0 时候，上传
        if (cc.PLATFORM_OS_ANDROID == targetPlatform) 
            or (cc.PLATFORM_OS_IPHONE == targetPlatform) 
            or ((cc.PLATFORM_OS_IPAD == targetPlatform))
            or ((cc.PLATFORM_OS_MAC == targetPlatform))  then

            local phoneModel = tostring(ww.IPhoneTool:getInstance():getPhoneModel())
            local sdkVersion = ww.IPhoneTool:getInstance():getSDkVersion()
            local wifiState = ww.IPhoneTool:getInstance():getWifiState()
  
            local endMsgAll = 
            "UserID:"..DataCenter:getUserdataInstance():getValueByKey("userid").. "\n"
            .."PhoneModel:".. phoneModel .. "\n"
            .."OS:".. sdkVersion .. "\n"
            .."ifWifi:".. wifiState .. "\n"
                .. "\n"
                ..msgAll
            postLog(endMsgAll)
        else
            local endMsgAll = 
            "UserID:"..DataCenter:getUserdataInstance():getValueByKey("userid").. "\n"
                .. "\n"
                ..msgAll
            postLog(endMsgAll)
        end
    end

    if _logConfigParam.writeLog and (DEBUG >= 2) then
        --写日志
        writeLogFile(msgAll)
    end

    if _logConfigParam.dialogLog and (DEBUG  >= 1) then
        --弹窗日志
        showErrorDialog(msgAll)
    end

    return msg
end