-------------------------------------------------------------------------
-- Desc:    客户端版本相关
-- Author:  协议脚本工具生成文件
-- Info:    Version2.0 模块化支持
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local versionModel = class("versionModel")

versionModel.MSG_ID = {
    Msg_CheckVersion_send           = 0x20107, -- 131335, 客户端版本检查
    Msg_VersionStatus_Ret           = 0x20108, -- 131336, 版本信息
};

function versionModel:ctor(target)
-- 0x20107 = 131335 = Msg_CheckVersion_send
-- 客户端版本检查
local Msg_CheckVersion_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x20108 = 131336 = Msg_VersionStatus_Ret
-- 版本信息
local Msg_VersionStatus_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- cclog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.VerStatus = netWWBuffer:readInt()
    t_result.DownloadURL = netWWBuffer:readLengthAndString()
    t_result.Description = netWWBuffer:readLengthAndString()
    t_result.DiffPkg = netWWBuffer:readInt()

    -- ccdump(t_result) --打印table

    return t_result
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_CheckVersion_send, Msg_CheckVersion_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_VersionStatus_Ret, Msg_VersionStatus_Ret_read, target)


end

return versionModel
