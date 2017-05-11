-------------------------------------------------------------------------
-- Desc:    登录模块
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local loginModel = class("loginModel")

loginModel.MSG_ID = {
    Msg_putClientModuleID_send      = 0x10147, -- 65863, 客户端通知后台当前功能模块ID,这个对上号，才能收到后台的滚报
    Msg_Login_send                  = 0x20101, -- 131329, 登录请求
    Msg_Login_Ret                   = 0x20102, -- 131330, 登录返回
    Msg_Logout_send                 = 0x20103, -- 131331, 退出请求
    Msg_LogoutInfo_Ret              = 0x20104, -- 131332, 退出确认消息
    Msg_NotifyUser_Ret              = 0x20105, -- 131333, 上下线通知消息
};

function loginModel:ctor(target)
-- 0x10147 = 65863 = Msg_putClientModuleID_send
-- 客户端通知后台当前功能模块ID,这个对上号，才能收到后台的滚报
local Msg_putClientModuleID_send_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x20101 = 131329 = Msg_Login_send
-- 登录请求
local Msg_Login_send_write = function(sendTable)

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
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeShort(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeChar(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])

    return wb
end

-- 0x20102 = 131330 = Msg_Login_Ret
-- 登录返回
local Msg_Login_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.VerStatus = netWWBuffer:readChar()
    t_result.DownloadURL = netWWBuffer:readLengthAndString()
    t_result.Description = netWWBuffer:readLengthAndString()
    t_result.userid = netWWBuffer:readInt()
    t_result.nickname = netWWBuffer:readLengthAndString()
    t_result.gender = netWWBuffer:readChar()
    t_result.vip = netWWBuffer:readChar()
    t_result.parameter = netWWBuffer:readInt()
    t_result.freshguagua = netWWBuffer:readShort()
    t_result.subscription = netWWBuffer:readShort()
    t_result.mask = netWWBuffer:readLengthAndString()
    t_result.tip1 = netWWBuffer:readLengthAndString()
    t_result.tip2 = netWWBuffer:readLengthAndString()
    t_result.tip3 = netWWBuffer:readLengthAndString()
    t_result.userPwd = netWWBuffer:readLengthAndString()
    t_result.hallversion = netWWBuffer:readLengthAndString()
    t_result.moreGame = netWWBuffer:readChar()
    t_result.awardbeancount = netWWBuffer:readInt()
    t_result.intparam1 = netWWBuffer:readInt()
    t_result.compassswitch = netWWBuffer:readShort()
    t_result.exchageswitch = netWWBuffer:readShort()
    t_result.wealSwitch = netWWBuffer:readShort()
    t_result.DKUserid = netWWBuffer:readLengthAndString()
    t_result.DiffPkg = netWWBuffer:readChar()
    local count = netWWBuffer:readShort()
    local list = {}
    for i=1, count do
        local t_row1 = {}
        t_row1.magicName = netWWBuffer:readLengthAndString()
        t_row1.magicID = netWWBuffer:readInt()
        t_row1.fid = netWWBuffer:readInt()
        t_row1.magiccount = netWWBuffer:readInt()
        table.insert(list, t_row1)
    end
    t_result["list"] = list

    t_result.subject = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x20102 = 131330 = Msg_Login_Ret
-- 登录返回线程函数解析关系注册
local Msg_Login_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"char","VerStatus"},
    {"string","DownloadURL"},
    {"string","Description"},
    {"int","userid"},
    {"string","nickname"},
    {"char","gender"},
    {"char","vip"},
    {"int","parameter"},
    {"short","freshguagua"},
    {"short","subscription"},
    {"string","mask"},
    {"string","tip1"},
    {"string","tip2"},
    {"string","tip3"},
    {"string","userPwd"},
    {"string","hallversion"},
    {"char","moreGame"},
    {"int","awardbeancount"},
    {"int","intparam1"},
    {"short","compassswitch"},
    {"short","exchageswitch"},
    {"short","wealSwitch"},
    {"string","DKUserid"},
    {"char","DiffPkg"},
    {"loop",
          {"short","list"},
          {"string","magicName"},
          {"int","magicID"},
          {"int","fid"},
          {"int","magiccount"},
    },
    {"string","subject"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x20103 = 131331 = Msg_Logout_send
-- 退出请求
local Msg_Logout_send_write = function(sendTable)

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

    return wb
end

-- 0x20104 = 131332 = Msg_LogoutInfo_Ret
-- 退出确认消息
local Msg_LogoutInfo_Ret_read = function(reciveMsgId, netWWBuffer)

    if type(netWWBuffer) ~= "userdata" then
       flog("[Wawagame Error] This function value netWWBuffer must a userdata")
       return
    end

    -- wwlog("Paser msg id -> %d", reciveMsgId)
    local t_result = {}

    t_result.UserID = netWWBuffer:readInt()
    t_result.ExitType = netWWBuffer:readChar()
    t_result.Power = netWWBuffer:readInt()
    t_result.Longevity = netWWBuffer:readInt()
    t_result.Charm = netWWBuffer:readInt()
    t_result.Cash = netWWBuffer:readInt()
    t_result.logonID = netWWBuffer:readInt()
    t_result.onlineTime = netWWBuffer:readShort()
    t_result.Magic701 = netWWBuffer:readChar()
    t_result.Bean = netWWBuffer:readInt()
    t_result.GameCash = netWWBuffer:readLengthAndString()

    -- ccdump(t_result) --打印table

    return t_result
end

-- 0x20104 = 131332 = Msg_LogoutInfo_Ret
-- 退出确认消息线程函数解析关系注册
local Msg_LogoutInfo_Ret_Threadread = function(reciveMsgId, netWWBuffer)

    local t_reflxTable = {

    {"int","UserID"},
    {"char","ExitType"},
    {"int","Power"},
    {"int","Longevity"},
    {"int","Charm"},
    {"int","Cash"},
    {"int","logonID"},
    {"short","onlineTime"},
    {"char","Magic701"},
    {"int","Bean"},
    {"string","GameCash"},

    } 
    --return a table
   return t_reflxTable
end

-- 0x20105 = 131333 = Msg_NotifyUser_Ret
-- 上下线通知消息
local Msg_NotifyUser_Ret_write = function(sendTable)

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
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeLengthAndString(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])
    wb:writeInt(sendTable[autoPlus(nIndex)])

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_putClientModuleID_send, Msg_putClientModuleID_send_write, target)
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_Login_send, Msg_Login_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_Login_Ret, Msg_Login_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_Login_Ret,Msg_Login_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_Logout_send, Msg_Logout_send_write, target)
    NetWorkBridge:setMsgReadReflex(self.MSG_ID.Msg_LogoutInfo_Ret, Msg_LogoutInfo_Ret_read, target)
    WWNetAdapter:bindMsgTable(self.MSG_ID.Msg_LogoutInfo_Ret,Msg_LogoutInfo_Ret_Threadread())
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_NotifyUser_Ret, Msg_NotifyUser_Ret_write, target)


end

return loginModel
