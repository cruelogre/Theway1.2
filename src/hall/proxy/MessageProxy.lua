-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.09.23
-- Last:
-- Content:  消息模块代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MessageProxy = class("MessageProxy", require("packages.mvc.Proxy"))

local EmailCfg = require("hall.mediator.cfg.EmailCfg")
local Toast = require("app.views.common.Toast")

function MessageProxy:init()
    self.logTag = "MessageProxy.lua"
    self._messageModel = require("hall.model.messageModel"):create(self)

    self:registerMsg()
end

function MessageProxy:registerMsg()
    self:registerMsgId(self._messageModel.MSG_ID.Msg_MsgList_Ret, handler(self, self.response))
    self:registerMsgId(self._messageModel.MSG_ID.Msg_SendTalk_Ret, handler(self, self.response))


    -- 注册Root消息 Type = 1 3 4
    self:registerRootMsgId(self._messageModel.MSG_ID.Msg_UserMsgDataReq_send, handler(self, self.response))
end

function MessageProxy:response(msgId, msgTable)

    local dispatchEventId = nil
    local dispatchData = nil
    --wwdump(msgTable, "msgTable:" .. msgId, 5)

    if msgId == self._messageModel.MSG_ID.Msg_MsgList_Ret then
        -- wwdump(msgTable, "消息模块收到消息:" .. msgId)
        -- 用户消息箱消息列表
        dispatchEventId = EmailCfg.InnerEvents.MESSAGE_EVENT_REQMSGLIST
        --        dispatchData = msgTable
        DataCenter:cacheData(EmailCfg.InnerEvents.MESSAGE_EVENT_REQMSGLIST, msgTable)
        -- 红点展示
        WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "mail", #msgTable.messages > 0)
    elseif msgId == self._messageModel.MSG_ID.Msg_SendTalk_Ret then
        -- 滚报消息
        --        local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
        --        toast("收到广播")
        addMsgScroll(msgTable.Content)
    elseif msgId == self._messageModel.MSG_ID.Msg_UserMsgDataReq_send then
        wwdump(msgTable, "消息模块收到消息:" .. msgId)
        if msgTable.kReasonType == 4 then
            -- 操作附件的响应
            dispatchEventId = EmailCfg.InnerEvents.MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT
            DataCenter:cacheData(EmailCfg.InnerEvents.MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT, {
                isSucc = msgTable.kResult == 0,
                msgID = msgTable.kReason
            } )
        elseif msgTable.kReasonType == 1 then
            -- 消息箱新消息数量
            dispatchEventId = EmailCfg.InnerEvents.MESSAGE_EVENT_NUM_NEW_MSG
            DataCenter:cacheData(EmailCfg.InnerEvents.MESSAGE_EVENT_NUM_NEW_MSG, { num = msgTable.kReason })
        end
    end

    if dispatchEventId and EmailCfg.innerEventComponent then
        EmailCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId;
            _userdata = dispatchData;
        } )
    end
end

-- 获取消息列表
-- mType
-- 1=消息箱新消息数量
-- 2=未读消息列表
-- 3=消息回执
-- 4=操作消息附件(马上领取奖励)
function MessageProxy:requestMessageInfo(mType, msgID, param1, param2)

    local paras = {
        4,
        11,
        1,
        mType,
        msgID,
        param1,
        param2
    }
    self:sendMsg(self._messageModel.MSG_ID.Msg_UserMsgDataReq_send, paras)
end

return MessageProxy