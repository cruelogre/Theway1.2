-------------------------------------------------------------------------
-- Desc:    排行榜模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ranknetModel = class("ranknetModel")

ranknetModel.MSG_ID = {
    Msg_MemberRequest_send          = 0x30101, -- 196865, 社区关系请求
    Msg_RankInfo_Ret                = 0x3011b, -- 196891, 排行榜数据
};

function ranknetModel:ctor(target)
-- 0x30101 = 196865 = Msg_MemberRequest_send
-- 社区关系请求
local Msg_MemberRequest_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x3011b = 196891 = Msg_RankInfo_Ret
-- 排行榜数据
local Msg_RankInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.TopType = netWWBuffer:readInt()
    t_result.TimeStr = netWWBuffer:readLengthAndString()
    t_result.MyNo = netWWBuffer:readInt()
    t_result.MyScore = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readShort()
    local rankInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.No = netWWBuffer:readInt()
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.Nickname = netWWBuffer:readLengthAndString()
        t_row1.Province = netWWBuffer:readLengthAndString()
        t_row1.Score = netWWBuffer:readLengthAndString()
        table.insert(rankInfo, t_row1)
    end
    t_result["rankInfo"] = rankInfo

    local count = netWWBuffer:readShort()
    local headInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.IconID = netWWBuffer:readInt()
        t_row1.IconTS = netWWBuffer:readLengthAndString()
        table.insert(headInfo, t_row1)
    end
    t_result["headInfo"] = headInfo

    local otherInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Region = netWWBuffer:readLengthAndString()
        t_row1.Servicecode = netWWBuffer:readInt()
        table.insert(otherInfo, t_row1)
    end
    t_result["otherInfo"] = otherInfo

    local genderInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Gender = netWWBuffer:readChar()
        table.insert(genderInfo, t_row1)
    end
    t_result["genderInfo"] = genderInfo


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x3011b = 196891 = Msg_RankInfo_Ret
-- 排行榜数据线程函数解析关系注册
local Msg_RankInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","TopType"},
    {"string","TimeStr"},
    {"int","MyNo"},
    {"string","MyScore"},
    {"loop",
          {"short","rankInfo"},
          {"int","No"},
          {"int","UserID"},
          {"string","Nickname"},
          {"string","Province"},
          {"string","Score"},
    },
    {"loop",
          {"short","headInfo"},
          {"int","IconID"},
          {"string","IconTS"},
    },
    {"loop",
          {"none","otherInfo"},
          {"string","Region"},
          {"int","Servicecode"},
    },
    {"loop",
          {"none","genderInfo"},
          {"char","Gender"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_MemberRequest_send, Msg_MemberRequest_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_RankInfo_Ret, Msg_RankInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_RankInfo_Ret,Msg_RankInfo_Ret_Threadread())


end

return ranknetModel
