-------------------------------------------------------------------------
-- Desc:    签到模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local userSignInModel = class("userSignInModel")

userSignInModel.MSG_ID = {
    Msg_UserSignInReq_send          = 0x10201, -- 66049, 用户签到请求
    Msg_UserSignInCalendar_Ret      = 0x10202, -- 66050, 用户签到日历
};

function userSignInModel:ctor(target)
-- 0x10201 = 66049 = Msg_UserSignInReq_send
-- 用户签到请求
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
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x10202 = 66050 = Msg_UserSignInCalendar_Ret
-- 用户签到日历
local Msg_UserSignInCalendar_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.CurDate = netWWBuffer:readLengthAndString()
    t_result.CardCount = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local signArr = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.DayIndex = netWWBuffer:readChar()
        t_row1.Status = netWWBuffer:readChar()
        t_row1.DayAward = netWWBuffer:readLengthAndString()
        t_row1.EventType = netWWBuffer:readInt()
        t_row1.EventData = netWWBuffer:readInt()
        t_row1.EventDesc = netWWBuffer:readLengthAndString()
        table.insert(signArr, t_row1)
    end
    t_result["signArr"] = signArr

    local count = netWWBuffer:readShort()
    local awardArr = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.DayNo = netWWBuffer:readChar()
        t_row1.AwardStatus = netWWBuffer:readChar()
        t_row1.AwardDesc = netWWBuffer:readLengthAndString()
        table.insert(awardArr, t_row1)
    end
    t_result["awardArr"] = awardArr


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x10202 = 66050 = Msg_UserSignInCalendar_Ret
-- 用户签到日历线程函数解析关系注册
local Msg_UserSignInCalendar_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

         {"string","CurDate"},
         {"int","CardCount"},
     {"loop",
          {"short","signArr"},
          {"char","DayIndex"},
          {"char","Status"},
          {"string","DayAward"},
          {"int","EventType"},
          {"int","EventData"},
          {"string","EventDesc"},
     },
     {"loop",
          {"short","awardArr"},
          {"char","DayNo"},
          {"char","AwardStatus"},
          {"string","AwardDesc"},
     },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_UserSignInReq_send, Msg_UserSignInReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_UserSignInCalendar_Ret, Msg_UserSignInCalendar_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_UserSignInCalendar_Ret,Msg_UserSignInCalendar_Ret_Threadread())


end

return userSignInModel
