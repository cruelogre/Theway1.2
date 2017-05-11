-------------------------------------------------------------------------
-- Title:	        排行榜
-- Author:     Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local RankProxy = class("RankProxy", require("packages.mvc.Proxy"))
local RankCfg = require("hall.mediator.cfg.RankCfg")
local RankRequest = require("hall.request.RankRequest")
-- local getStr = function(flag) return i18n:get("str_rank", flag) end
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local table = table

function RankProxy:init()
    print("RankProxy init")
    self._rankNetModel = require("hall.model.ranknetModel"):create(self)
    self._msgIds = self._rankNetModel.MSG_ID
    --    self._userData = DataCenter:getUserdataInstance()
    self:start()
end

function RankProxy:start()
    -- 排行榜数据响应
    self:registerMsgId(self._msgIds.Msg_RankInfo_Ret, handler(self, self._handleMsg), "RANK_PROXY_Msg_RankInfo_Ret")
    -- 社区关系请求通用响应（含排行榜请求）
    self:registerRootMsgId(self._msgIds.Msg_MemberRequest_send, handler(self, self._handleRootMsg), "RANK_Msg_MemberRequest_send")
end

function RankProxy:stop()
    self:unregisterMsgId(self._msgIds.Msg_RankInfo_Ret, "RANK_PROXY_Msg_RankInfo_Ret")
    self:unregisterRootMsgId(self._msgIds.Msg_MemberRequest_send, "RANK_Msg_MemberRequest_send")
end

function RankProxy:_handleMsg(msgType, msg)
    LoadingManager:endLoading()
    --    wwdump(msg, "排行榜(社区关系)收到消息" .. msgType)
    local dispatchEventId = nil
    local dispatchData = nil

    if msgType == self._msgIds.Msg_RankInfo_Ret then
        -- 排行榜消息
        table.walk(msg.headInfo, function(v, k) table.merge(msg.rankInfo[k], v) end)
        table.walk(msg.otherInfo, function(v, k) table.merge(msg.rankInfo[k], v) end)
        table.walk(msg.genderInfo, function(v, k) table.merge(msg.rankInfo[k], v) end)
        msg.headInfo, msg.otherInfo, msg.genderInfo = nil, nil, nil
        if msg.TopType == 48 then
            -- 掼蛋排行榜
            dispatchEventId = RankCfg.InnerEvents.GD_RANK_INFO
            dispatchData = msg
        end
    end
    if dispatchEventId and RankCfg.innerEventComponent then
        RankCfg.innerEventComponent:dispatchEvent( { name = dispatchEventId, _userdata = dispatchData })
    end
end

function RankProxy:_handleRootMsg(msgType, msgTable)
    LoadingManager:endLoading()
    wwdump(msgTable, "排行榜（社区关系）收到通用消息：" .. msgType)

    local dispatchEventId = nil
    local dispatchData = nil

    if msgType == self._msgIds.Msg_MemberRequest_send then
        -- 社区关系请求（排行榜）通用响应
        toast(msgTable.kReason)
    end
    if dispatchEventId and RankCfg.innerEventComponent then
        RankCfg.innerEventComponent:dispatchEvent( { name = dispatchEventId, _userdata = dispatchData })
    end
end

return RankProxy