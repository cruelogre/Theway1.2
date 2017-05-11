-------------------------------------------------------------------------
-- Desc:    商城充值逻辑协议
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local shopChargeModel = class("shopChargeModel")

shopChargeModel.MSG_ID = {
    Msg_ResultInfo_Ret              = 0x640103, -- 6553859, 充值结果信息
    Msg_LXCharge_send               = 0x640112, -- 6553874, 充值请求订单信息
    msg_NMESSAGE_SMSCOMMANDRESP     = 0x64011a, -- 6553882, 新短信充值返回的消息
};

function shopChargeModel:ctor(target)
-- 0x640103 = 6553859 = Msg_ResultInfo_Ret
-- 充值结果信息
local Msg_ResultInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.Result = netWWBuffer:readChar()
    t_result.addMoney = netWWBuffer:readInt()
    t_result.Money = netWWBuffer:readInt()
    t_result.Description = netWWBuffer:readLengthAndString()
    t_result.Moneytype = netWWBuffer:readChar()
    t_result.Status = netWWBuffer:readLengthAndString()
    t_result.Flag = netWWBuffer:readChar()
    t_result.FeeID = netWWBuffer:readLengthAndString()
    t_result.BillTime = netWWBuffer:readLengthAndString()
    t_result.AddGameCash = netWWBuffer:readLengthAndString()
    t_result.GameCash = netWWBuffer:readLengthAndString()
    t_result.Param = netWWBuffer:readLengthAndString()
    t_result.chargeSP = netWWBuffer:readInt()
    t_result.spServiceID = netWWBuffer:readLengthAndString()
    t_result.chargeMoney = netWWBuffer:readInt()
    t_result.OrderID = netWWBuffer:readLengthAndString()
    t_result.WeekVip = netWWBuffer:readChar()
    t_result.VipSCoder = netWWBuffer:readInt()
    t_result.TMagicID = netWWBuffer:readInt()
    local count = netWWBuffer:readChar()
    local Items = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MagicID = netWWBuffer:readInt()
        t_row1.MagicName = netWWBuffer:readLengthAndString()
        t_row1.MagicCount = netWWBuffer:readInt()
        t_row1.MagicFID = netWWBuffer:readInt()
        table.insert(Items, t_row1)
    end
    t_result["Items"] = Items

    t_result.chargeType = netWWBuffer:readShort()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x640103 = 6553859 = Msg_ResultInfo_Ret
-- 充值结果信息线程函数解析关系注册
local Msg_ResultInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"char","Result"},
    {"int","addMoney"},
    {"int","Money"},
    {"string","Description"},
    {"char","Moneytype"},
    {"string","Status"},
    {"char","Flag"},
    {"string","FeeID"},
    {"string","BillTime"},
    {"string","AddGameCash"},
    {"string","GameCash"},
    {"string","Param"},
    {"int","chargeSP"},
    {"string","spServiceID"},
    {"int","chargeMoney"},
    {"string","OrderID"},
    {"char","WeekVip"},
    {"int","VipSCoder"},
    {"int","TMagicID"},
    {"loop",
          {"char","Items"},
          {"int","MagicID"},
          {"string","MagicName"},
          {"int","MagicCount"},
          {"int","MagicFID"},
    },
    {"short","chargeType"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x640112 = 6553874 = Msg_LXCharge_send
-- 充值请求订单信息
local Msg_LXCharge_send_write = function(sendTable)

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
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x64011a = 6553882 = msg_NMESSAGE_SMSCOMMANDRESP
-- 新短信充值返回的消息
local msg_NMESSAGE_SMSCOMMANDRESP_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.result = netWWBuffer:readChar()
    t_result.chargeType = netWWBuffer:readInt()
    t_result.orderId = netWWBuffer:readLengthAndString()
    local count = netWWBuffer:readShort()
    local comCount = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Port = netWWBuffer:readLengthAndString()
        t_row1.Command = netWWBuffer:readLengthAndString()
        t_row1.intervalTime = netWWBuffer:readInt()
        t_row1.Type = netWWBuffer:readChar()
        table.insert(comCount, t_row1)
    end
    t_result["comCount"] = comCount


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x64011a = 6553882 = msg_NMESSAGE_SMSCOMMANDRESP
-- 新短信充值返回的消息线程函数解析关系注册
local msg_NMESSAGE_SMSCOMMANDRESP_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","result"},
    {"int","chargeType"},
    {"string","orderId"},
    {"loop",
          {"short","comCount"},
          {"string","Port"},
          {"string","Command"},
          {"int","intervalTime"},
          {"char","Type"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ResultInfo_Ret, Msg_ResultInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ResultInfo_Ret,Msg_ResultInfo_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_LXCharge_send, Msg_LXCharge_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.msg_NMESSAGE_SMSCOMMANDRESP, msg_NMESSAGE_SMSCOMMANDRESP_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.msg_NMESSAGE_SMSCOMMANDRESP,msg_NMESSAGE_SMSCOMMANDRESP_Threadread())


end

return shopChargeModel
