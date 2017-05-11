-------------------------------------------------------------------------
-- Desc:    兑换中心模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local exchangenetModel = class("exchangenetModel")

exchangenetModel.MSG_ID = {
    Msg_ExchangeDataReq_send        = 0x110901, -- 1116417, 请求兑换中心数据
    Msg_ConvertibleEquipList_Ret    = 0x110902, -- 1116418, 可兑换商品列表
    Msg_ExchangeTextInfo_Ret        = 0x110903, -- 1116419, 各种说明文字信息
    Msg_ConvertibleEquipInfo_Ret    = 0x110904, -- 1116420, 兑换商品详情
    Msg_ExchangeCommit_send         = 0x110905, -- 1116421, 兑换(领取)请求
    Msg_ReceiverList_Ret            = 0x110906, -- 1116422, 收获信息
    Msg_setReceiver_send            = 0x110907, -- 1116423, 设置收货人
    Msg_MyAwardList_Ret             = 0x110908, -- 1116424, 我的奖品列表
    Msg_ThirdpartyAccessReq_send    = 0x110909, -- 1116425, 第三方授权相关操作
    Msg_WeiXinAccessInfo_Ret        = 0x11090a, -- 1116426, 微信授权返回
};

function exchangenetModel:ctor(target)
-- 0x110901 = 1116417 = Msg_ExchangeDataReq_send
-- 请求兑换中心数据
local Msg_ExchangeDataReq_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x110902 = 1116418 = Msg_ConvertibleEquipList_Ret
-- 可兑换商品列表
local Msg_ConvertibleEquipList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.Type = netWWBuffer:readChar()
    t_result.MyCoupon = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local exchangeInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.ExchID = netWWBuffer:readInt()
        t_row1.EquipID = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.Stock = netWWBuffer:readInt()
        t_row1.NeedCoupon = netWWBuffer:readInt()
        t_row1.ObjectType = netWWBuffer:readChar()
        t_row1.Expire = netWWBuffer:readLengthAndString()
        table.insert(exchangeInfo, t_row1)
    end
    t_result["exchangeInfo"] = exchangeInfo

    local statusInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.beginSecond = netWWBuffer:readInt()
        t_row1.State = netWWBuffer:readChar()
        table.insert(statusInfo, t_row1)
    end
    t_result["statusInfo"] = statusInfo

    t_result.ExchCenterID = netWWBuffer:readInt()
    local otherInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.ExchMagicID = netWWBuffer:readInt()
        t_row1.ExchMagicFID = netWWBuffer:readInt()
        t_row1.ExchMagicName = netWWBuffer:readLengthAndString()
        t_row1.BindingPhone = netWWBuffer:readChar()
        t_row1.limitCount = netWWBuffer:readInt()
        t_row1.limitDay = netWWBuffer:readInt()
        table.insert(otherInfo, t_row1)
    end
    t_result["otherInfo"] = otherInfo


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110902 = 1116418 = Msg_ConvertibleEquipList_Ret
-- 可兑换商品列表线程函数解析关系注册
local Msg_ConvertibleEquipList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"char","Type"},
    {"int","MyCoupon"},
    {"loop",
          {"short","exchangeInfo"},
          {"int","ExchID"},
          {"int","EquipID"},
          {"string","Name"},
          {"int","Stock"},
          {"int","NeedCoupon"},
          {"char","ObjectType"},
          {"string","Expire"},
    },
    {"loop",
          {"none","statusInfo"},
          {"int","beginSecond"},
          {"char","State"},
    },
    {"int","ExchCenterID"},
    {"loop",
          {"none","otherInfo"},
          {"int","ExchMagicID"},
          {"int","ExchMagicFID"},
          {"string","ExchMagicName"},
          {"char","BindingPhone"},
          {"int","limitCount"},
          {"int","limitDay"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x110903 = 1116419 = Msg_ExchangeTextInfo_Ret
-- 各种说明文字信息
local Msg_ExchangeTextInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readChar()
    local count = netWWBuffer:readShort()
    local info = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Subject = netWWBuffer:readLengthAndString()
        t_row1.Content = netWWBuffer:readLengthAndString()
        table.insert(info, t_row1)
    end
    t_result["info"] = info


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110903 = 1116419 = Msg_ExchangeTextInfo_Ret
-- 各种说明文字信息线程函数解析关系注册
local Msg_ExchangeTextInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","Type"},
    {"char","Desc"},
    {"loop",
          {"short","info"},
          {"string","Subject"},
          {"string","Content"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x110904 = 1116420 = Msg_ConvertibleEquipInfo_Ret
-- 兑换商品详情
local Msg_ConvertibleEquipInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.ExchID = netWWBuffer:readInt()
    t_result.EquipID = netWWBuffer:readInt()
    t_result.Price = netWWBuffer:readInt()
    t_result.NeedCoupon = netWWBuffer:readInt()
    t_result.Stock = netWWBuffer:readInt()
    t_result.ConvertedCount = netWWBuffer:readInt()
    t_result.Desc = netWWBuffer:readLengthAndString()
    t_result.endDate = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110904 = 1116420 = Msg_ConvertibleEquipInfo_Ret
-- 兑换商品详情线程函数解析关系注册
local Msg_ConvertibleEquipInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","ExchID"},
    {"int","EquipID"},
    {"int","Price"},
    {"int","NeedCoupon"},
    {"int","Stock"},
    {"int","ConvertedCount"},
    {"string","Desc"},
    {"string","endDate"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x110905 = 1116421 = Msg_ExchangeCommit_send
-- 兑换(领取)请求
local Msg_ExchangeCommit_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x110906 = 1116422 = Msg_ReceiverList_Ret
-- 收获信息
local Msg_ReceiverList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    local count = netWWBuffer:readShort()
    local info = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.RecordID = netWWBuffer:readInt()
        t_row1.RealName = netWWBuffer:readLengthAndString()
        t_row1.Phone = netWWBuffer:readLengthAndString()
        t_row1.Address = netWWBuffer:readLengthAndString()
        t_row1.Default = netWWBuffer:readChar()
        table.insert(info, t_row1)
    end
    t_result["info"] = info


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110906 = 1116422 = Msg_ReceiverList_Ret
-- 收获信息线程函数解析关系注册
local Msg_ReceiverList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"loop",
          {"short","info"},
          {"int","RecordID"},
          {"string","RealName"},
          {"string","Phone"},
          {"string","Address"},
          {"char","Default"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x110907 = 1116423 = Msg_setReceiver_send
-- 设置收货人
local Msg_setReceiver_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x110908 = 1116424 = Msg_MyAwardList_Ret
-- 我的奖品列表
local Msg_MyAwardList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.Type = netWWBuffer:readChar()
    t_result.GameID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local info = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserExchID = netWWBuffer:readInt()
        t_row1.EquipID = netWWBuffer:readInt()
        t_row1.EquipName = netWWBuffer:readLengthAndString()
        t_row1.ExchangeTime = netWWBuffer:readLengthAndString()
        t_row1.Desc = netWWBuffer:readLengthAndString()
        t_row1.Flag = netWWBuffer:readChar()
        t_row1.ObjectType = netWWBuffer:readChar()
        table.insert(info, t_row1)
    end
    t_result["info"] = info

    local userInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.UserID = netWWBuffer:readInt()
        t_row1.NickName = netWWBuffer:readLengthAndString()
        t_row1.Price = netWWBuffer:readInt()
        t_row1.Phone = netWWBuffer:readLengthAndString()
        t_row1.Address = netWWBuffer:readLengthAndString()
        table.insert(userInfo, t_row1)
    end
    t_result["userInfo"] = userInfo

    local magicInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.ExchMagicID = netWWBuffer:readInt()
        t_row1.ExchMagicName = netWWBuffer:readLengthAndString()
        table.insert(magicInfo, t_row1)
    end
    t_result["magicInfo"] = magicInfo

    local recipientInfo = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Recipient = netWWBuffer:readLengthAndString()
        table.insert(recipientInfo, t_row1)
    end
    t_result["recipientInfo"] = recipientInfo


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x110908 = 1116424 = Msg_MyAwardList_Ret
-- 我的奖品列表线程函数解析关系注册
local Msg_MyAwardList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","Type"},
    {"int","GameID"},
    {"loop",
          {"short","info"},
          {"int","UserExchID"},
          {"int","EquipID"},
          {"string","EquipName"},
          {"string","ExchangeTime"},
          {"string","Desc"},
          {"char","Flag"},
          {"char","ObjectType"},
    },
    {"loop",
          {"none","userInfo"},
          {"int","UserID"},
          {"string","NickName"},
          {"int","Price"},
          {"string","Phone"},
          {"string","Address"},
    },
    {"loop",
          {"none","magicInfo"},
          {"int","ExchMagicID"},
          {"string","ExchMagicName"},
    },
    {"loop",
          {"none","recipientInfo"},
          {"string","Recipient"},
    },

    } 
    --return a table
   return t_reflxTable
end

-- 0x110909 = 1116425 = Msg_ThirdpartyAccessReq_send
-- 第三方授权相关操作
local Msg_ThirdpartyAccessReq_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x11090a = 1116426 = Msg_WeiXinAccessInfo_Ret
-- 微信授权返回
local Msg_WeiXinAccessInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.result = netWWBuffer:readChar()
    t_result.openid = netWWBuffer:readLengthAndString()
    t_result.nickname = netWWBuffer:readLengthAndString()
    t_result.sex = netWWBuffer:readChar()
    t_result.province = netWWBuffer:readLengthAndString()
    t_result.city = netWWBuffer:readLengthAndString()
    t_result.country = netWWBuffer:readLengthAndString()
    t_result.headimgurl = netWWBuffer:readLengthAndString()
    t_result.privilege = netWWBuffer:readLengthAndString()
    t_result.unionid = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x11090a = 1116426 = Msg_WeiXinAccessInfo_Ret
-- 微信授权返回线程函数解析关系注册
local Msg_WeiXinAccessInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","result"},
    {"string","openid"},
    {"string","nickname"},
    {"char","sex"},
    {"string","province"},
    {"string","city"},
    {"string","country"},
    {"string","headimgurl"},
    {"string","privilege"},
    {"string","unionid"},

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_ExchangeDataReq_send, Msg_ExchangeDataReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ConvertibleEquipList_Ret, Msg_ConvertibleEquipList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ConvertibleEquipList_Ret,Msg_ConvertibleEquipList_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ExchangeTextInfo_Ret, Msg_ExchangeTextInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ExchangeTextInfo_Ret,Msg_ExchangeTextInfo_Ret_Threadread())
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ConvertibleEquipInfo_Ret, Msg_ConvertibleEquipInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ConvertibleEquipInfo_Ret,Msg_ConvertibleEquipInfo_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_ExchangeCommit_send, Msg_ExchangeCommit_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ReceiverList_Ret, Msg_ReceiverList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ReceiverList_Ret,Msg_ReceiverList_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_setReceiver_send, Msg_setReceiver_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_MyAwardList_Ret, Msg_MyAwardList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_MyAwardList_Ret,Msg_MyAwardList_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_ThirdpartyAccessReq_send, Msg_ThirdpartyAccessReq_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_WeiXinAccessInfo_Ret, Msg_WeiXinAccessInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_WeiXinAccessInfo_Ret,Msg_WeiXinAccessInfo_Ret_Threadread())


end

return exchangenetModel
