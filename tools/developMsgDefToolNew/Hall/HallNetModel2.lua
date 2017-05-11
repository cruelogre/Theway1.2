-------------------------------------------------------------------------
-- Desc:    大厅消息1.2
-- Author:  协议脚本工具生成文件
-- Info:    Version3.0 模块化支持
-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local HallNetModel2 = class("HallNetModel2")

HallNetModel2.MSG_ID = {
    Msg_GDHallAction_send2          = 0x60802, -- 395266, 玩家游戏大厅操作1.2
};

function HallNetModel2:ctor(target)
-- 0x60802 = 395266 = Msg_GDHallAction_send2
-- 玩家游戏大厅操作1.2
local Msg_GDHallAction_send2_write = function(sendTable)

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

    return wb
end

    --将函数注册到映射表
    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.Msg_GDHallAction_send2, Msg_GDHallAction_send2_write, target)


end

return HallNetModel2
