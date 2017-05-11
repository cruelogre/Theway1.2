-------------------------------------------------------------------------
-- Desc:    客户端广告
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ReqClientADInfo = class("ReqClientADInfo")

ReqClientADInfo.MSG_ID = {
    Msg_UserSignInReq_send          = 0x10142, -- 65858, 请求客户端广告信息
    Msg_RespClientADInfo_Ret        = 0x10143, -- 65859, 响应广告信息
};

function ReqClientADInfo:ctor(target)
-- 0x10142 = 65858 = Msg_UserSignInReq_send
-- 请求客户端广告信息
local Msg_UserSignInReq_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x10143 = 65859 = Msg_RespClientADInfo_Ret
-- 响应广告信息
local Msg_RespClientADInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.GameID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local ads = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.adID = netWWBuffer:readInt()
        t_row1.name = netWWBuffer:readLengthAndString()
        t_row1.picParam = netWWBuffer:readLengthAndString()
        t_row1.StartTime = netWWBuffer:readLongLong()
        t_row1.EndTime = netWWBuffer:readLongLong()
        table.insert(ads, t_row1)
    end
    t_result["ads"] = ads

    local count = netWWBuffer:readShort()
    local Counts = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.CtrlParam = netWWBuffer:readLengthAndString()
        table.insert(Counts, t_row1)
    end
    t_result["Counts"] = Counts


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x10143 = 65859 = Msg_RespClientADInfo_Ret
-- 响应广告信息线程函数解析关系注册
local Msg_RespClientADInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"int","GameID"},
    {"loop",
          {"short","ads"},
          {"int","adID"},
          {"string","name"},
          {"string","picParam"},
          {"long long","StartTime"},
          {"long long","EndTime"},
    },
    {"loop",
          {"short","Counts"},
          {"string","CtrlParam"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_UserSignInReq_send, Msg_UserSignInReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RespClientADInfo_Ret, Msg_RespClientADInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RespClientADInfo_Ret,Msg_RespClientADInfo_Ret_Threadread())


end

return ReqClientADInfo
