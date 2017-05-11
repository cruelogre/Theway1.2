-------------------------------------------------------------------------
-- Desc:    设置模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local settingModel = class("settingModel")

settingModel.MSG_ID = {
    Msg_SettingFeedback_Ret         = 0x4020a, -- 262666, 问题反馈回应
    Msg_SettingFeedback_send        = 0x4020a, -- 262666, 问题反馈请求
};

function settingModel:ctor(target)
-- 0x4020a = 262666 = Msg_SettingFeedback_Ret
-- 问题反馈回应
local Msg_SettingFeedback_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x4020a = 262666 = Msg_SettingFeedback_Ret
-- 问题反馈回应线程函数解析关系注册
local Msg_SettingFeedback_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {


    } 
    --return a table
   return t_reflxTable
end

-- 0x40210 = 262672 = Msg_SettingFeedback_send
-- 问题反馈请求
local Msg_SettingFeedback_send_write = function(sendTable)

    if nil == sendTable then
       flog("[Wawagame Error] sendTable must not nil")
       return nil
    end

    local nIndex = 0
    local autoPlus = function(nNum)
       nIndex = nIndex + 1
       return nIndex
    end

    local wb = ww.WWBuffer:create()
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_SettingFeedback_Ret, Msg_SettingFeedback_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_SettingFeedback_Ret,Msg_SettingFeedback_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_SettingFeedback_send, Msg_SettingFeedback_send_write, target)


end

return settingModel
