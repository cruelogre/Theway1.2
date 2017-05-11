-------------------------------------------------------------------------
-- Desc:    卓盟数据上传
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local LoveotaModel = class("LoveotaModel")

LoveotaModel.MSG_ID = {
    Msg_CheckVersion_send           = 0x2011b, -- 131355, 卓盟数据上传
};

function LoveotaModel:ctor(target)
-- 0x2011b = 131355 = Msg_CheckVersion_send
-- 卓盟数据上传
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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_CheckVersion_send, Msg_CheckVersion_send_write, target)


end

return LoveotaModel
