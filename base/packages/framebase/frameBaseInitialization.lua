-------------------------------------------------------------------------
-- Desc:    Support初始化
-- Author:  diyal.yin
-- Date:    2015.10.22
-- Last: 
-- Content:  这个文件是框架基础构建文件。只能用来放Support级别的实现。
--           就不必再去setRawset来绕过全局变量元表检测 
-- modify :
-- 2016-08-10 diyal.yin  将Helper整合进来
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

--[[ 加载日志模块 ]]
require "packages.framebase.LogUtils"

require "packages.framebase.Helper"

--------------------------------------------------------------------------
--定义全局函数 API
--------------------------------------------------------------------------
--[[打印表]]--
-- function printTab(tab)
--   for i,v in pairs(tab) do
--     if type(v) == "table" then
--       print("table",i,"{")
--       printTab(v)
--       print("}")
--     else
--      print(v)
--     end
--   end
-- end

--[[ 根据16进制颜色值得到RGB值 ]]--
function ConvertHexToRGB(hex)  
    local red = string.sub(hex, 1, 2)  
    local green = string.sub(hex, 3, 4)  
    local blue = string.sub(hex, 5, 6)   
    red = tonumber(red, 16)
    green = tonumber(green, 16)  
    blue = tonumber(blue, 16) 
    return cc.c3b(red, green, blue)
end

--[[ 根据16进制颜色值得到RGB值 ]]--
function ConvertHex2RGBTab(hex)  
    local rgbTable = {}
    local red = string.sub(hex, 1, 2)  
    local green = string.sub(hex, 3, 4)  
    local blue = string.sub(hex, 5, 6)   

    table.insert(rgbTable, tonumber(red, 16))
    table.insert(rgbTable, tonumber(green, 16))
    table.insert(rgbTable, tonumber(blue, 16))

    return rgbTable
end

--[[
创建枚举类型
--@param tbl 枚举Key
--@param index 起始索引
--定义  local ENMU_TEST = CreatEnumTable( {a, b}, 1)
--使用  ENMU_TEST.a
]]--
function CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1
    end 
    return enumtbl 
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

--android部分使用
function callNetSwitchEvent()
    print("callNetSwitchEvent")
    cc.Director:getInstance():getEventDispatcher():dispatchCustomEvent("onNetStateChange")
end


