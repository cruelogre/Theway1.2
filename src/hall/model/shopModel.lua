-------------------------------------------------------------------------
-- Desc:    商城协议
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local shopModel = class("shopModel")

shopModel.MSG_ID = {
    Msg_ShopList_send               = 0x640101, -- 6553857, 请求商城一级菜单
    Msg_ShopList_Ret                = 0x640115, -- 6553877, 新版充值菜单信息
};

function shopModel:ctor(target)
-- 0x640101 = 6553857 = Msg_ShopList_send
-- 请求商城一级菜单
local Msg_ShopList_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
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

-- 0x640115 = 6553877 = Msg_ShopList_Ret
-- 新版充值菜单信息
local Msg_ShopList_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.MneuID = netWWBuffer:readInt()
    local count = netWWBuffer:readShort()
    local Items = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.ItemID = netWWBuffer:readInt()
        t_row1.Name = netWWBuffer:readLengthAndString()
        t_row1.Icon = netWWBuffer:readLengthAndString()
        t_row1.Hot = netWWBuffer:readChar()
        t_row1.CashTpye = netWWBuffer:readChar()
        t_row1.ChargeType = netWWBuffer:readChar()
        t_row1.ToUser = netWWBuffer:readChar()
        t_row1.ChargeCmd = netWWBuffer:readLengthAndString()
        t_row1.MenuData = netWWBuffer:readLengthAndString()
        t_row1.MenuFlag = netWWBuffer:readInt()
        t_row1.Money = netWWBuffer:readInt()
        t_row1.SP = netWWBuffer:readInt()
        t_row1.SPServiceID = netWWBuffer:readInt()
        t_row1.Cash = netWWBuffer:readInt()
        t_row1.DonateCash = netWWBuffer:readInt()
        t_row1.MenuKey = netWWBuffer:readLengthAndString()
        t_row1.Description1 = netWWBuffer:readLengthAndString()
        t_row1.Description2 = netWWBuffer:readLengthAndString()
        t_row1.Description3 = netWWBuffer:readLengthAndString()
        table.insert(Items, t_row1)
    end
    t_result["Items"] = Items

    local Confirms = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Confirm = netWWBuffer:readChar()
        table.insert(Confirms, t_row1)
    end
    t_result["Confirms"] = Confirms

    local SmsTypes = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.SmsType = netWWBuffer:readShort()
        t_row1.SmsOrder = netWWBuffer:readLengthAndString()
        table.insert(SmsTypes, t_row1)
    end
    t_result["SmsTypes"] = SmsTypes

    local MenuTypes = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.MenuType = netWWBuffer:readChar()
        t_row1.TMagicID = netWWBuffer:readInt()
        table.insert(MenuTypes, t_row1)
    end
    t_result["MenuTypes"] = MenuTypes

    t_result.ReqType = netWWBuffer:readChar()
    local MCountTables = {}
    for i=1, count do
        local t_row1 = {}
        local count2 = netWWBuffer:readChar()
        local Magics = {}
        t_row1.MCount = count2
        for i=1, count2 do
            local t_row2 = {}
            t_row2.MagicID = netWWBuffer:readInt()
            t_row2.MagicName = netWWBuffer:readLengthAndString()
            t_row2.MagicCount = netWWBuffer:readInt()
            t_row2.MagicFID = netWWBuffer:readInt()
            table.insert(Magics, t_row2)
        end
        t_row1["Magics"] = Magics

        table.insert(MCountTables, t_row1)
    end
    t_result["MCountTables"] = MCountTables

    local Discounts = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.Discount = netWWBuffer:readChar()
        table.insert(Discounts, t_row1)
    end
    t_result["Discounts"] = Discounts

    local bankIDs = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.bankID = netWWBuffer:readInt()
        t_row1.sceneID = netWWBuffer:readInt()
        t_row1.hallID = netWWBuffer:readInt()
        table.insert(bankIDs, t_row1)
    end
    t_result["bankIDs"] = bankIDs

    local showTypes = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.showType = netWWBuffer:readChar()
        table.insert(showTypes, t_row1)
    end
    t_result["showTypes"] = showTypes

    local showOrders = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.showOrder = netWWBuffer:readInt()
        table.insert(showOrders, t_row1)
    end
    t_result["showOrders"] = showOrders

    local buttonTexts = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.buttonText = netWWBuffer:readLengthAndString()
        table.insert(buttonTexts, t_row1)
    end
    t_result["buttonTexts"] = buttonTexts


    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x640115 = 6553877 = Msg_ShopList_Ret
-- 新版充值菜单信息线程函数解析关系注册
local Msg_ShopList_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","MneuID"},
    {"loop",
          {"short","Items"},
          {"int","ItemID"},
          {"string","Name"},
          {"string","Icon"},
          {"char","Hot"},
          {"char","CashTpye"},
          {"char","ChargeType"},
          {"char","ToUser"},
          {"string","ChargeCmd"},
          {"string","MenuData"},
          {"int","MenuFlag"},
          {"int","Money"},
          {"int","SP"},
          {"int","SPServiceID"},
          {"int","Cash"},
          {"int","DonateCash"},
          {"string","MenuKey"},
          {"string","Description1"},
          {"string","Description2"},
          {"string","Description3"},
    },
    {"loop",
          {"none","Confirms"},
          {"char","Confirm"},
    },
    {"loop",
          {"none","SmsTypes"},
          {"short","SmsType"},
          {"string","SmsOrder"},
    },
    {"loop",
          {"none","MenuTypes"},
          {"char","MenuType"},
          {"int","TMagicID"},
    },
    {"char","ReqType"},
    {"loop",
          {"none","MCountTables"},
    {"loop",
          {"char","Magics","MCount"},
          {"int","MagicID"},
          {"string","MagicName"},
          {"int","MagicCount"},
          {"int","MagicFID"},
    },
    },
    {"loop",
          {"none","Discounts"},
          {"char","Discount"},
    },
    {"loop",
          {"none","bankIDs"},
          {"int","bankID"},
          {"int","sceneID"},
          {"int","hallID"},
    },
    {"loop",
          {"none","showTypes"},
          {"char","showType"},
    },
    {"loop",
          {"none","showOrders"},
          {"int","showOrder"},
    },
    {"loop",
          {"none","buttonTexts"},
          {"string","buttonText"},
    },

    } 
    --return a table
   return t_reflxTable
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_ShopList_send, Msg_ShopList_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_ShopList_Ret, Msg_ShopList_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_ShopList_Ret,Msg_ShopList_Ret_Threadread())


end

return shopModel
