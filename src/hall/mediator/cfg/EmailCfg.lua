-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last:
-- Content:  邮件配置管理
-- 		包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local EmailCfg = { }
EmailCfg.innerEventComponent = nil
EmailCfg.InnerEvents = {
    MESSAGE_EVENT_REQMSGLIST = "MESSAGE_EVENT_REQMSGLIST";
    -- 操作消息附件(马上领取奖励)
    MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT = "MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT",
    -- 消息箱新消息数量
    MESSAGE_EVENT_NUM_NEW_MSG = "MESSAGE_EVENT_NUM_NEW_MSG",
}

return EmailCfg