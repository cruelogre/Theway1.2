-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.26
-- Last:
-- Content:  房间选择的代理类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SiRenRoomProxy = class("SiRenRoomProxy", require("packages.mvc.Proxy"))
local SiRenRoomCfg = require("hall.mediator.cfg.SiRenRoomCfg")
local SiRenRoomRequest = import("..request.SiRenRoomRequest")
local getStr = function(flag) return i18n:get("str_sirenrm", flag) end
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end

function SiRenRoomProxy:init()
    print("SiRenRoomProxy init")
    self._sirenNetModel = require("hall.model.sirennetModel"):create(self)
    self._msgIds = self._sirenNetModel.MSG_ID
    self._userData = DataCenter:getUserdataInstance()

    self:start()
end

function SiRenRoomProxy:start()
    -- 玩法局数配置
    self:registerMsgId(self._msgIds.Msg_GDRoomSet_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF)
    -- 返回房间信息
    self:registerMsgId(self._msgIds.Msg_GDRoomInfo_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO)
    -- 私人房最终结算
    self:registerMsgId(self._msgIds.Msg_GDRoomResult_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_BALANCE)
    -- 私人房历史记录
    self:registerMsgId(self._msgIds.Msg_GDRoomHistory_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_HISTORY)
    -- 房间通知消息
    self:registerMsgId(self._msgIds.Msg_GDRoomNotify_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY)
    -- 房间操作
    self:registerRootMsgId(self._msgIds.Msg_GDRoomAct_send, handler(self, self._handleRootMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT)
    -- 创建房间
    self:registerRootMsgId(self._msgIds.Msg_GDCreateRoomReq_send, handler(self, self._handleRootMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE)
end

function SiRenRoomProxy:stop()
    self:unregisterMsgId(self._msgIds.Msg_GDRoomSet_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF)
    self:unregisterMsgId(self._msgIds.Msg_GDRoomInfo_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO)
    self:unregisterMsgId(self._msgIds.Msg_GDRoomResult_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_BALANCE)
    self:unregisterMsgId(self._msgIds.Msg_GDRoomHistory_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_HISTORY)
    self:unregisterMsgId(self._msgIds.Msg_GDRoomNotify_Ret, handler(self, self._handleMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY)
    self:unregisterRootMsgId(self._msgIds.Msg_GDRoomAct_send, SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT)
    self:unregisterRootMsgId(self._msgIds.Msg_GDCreateRoomReq_send, handler(self, self._handleRootMsg), SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE)
end

function SiRenRoomProxy:_handleMsg(msgType, msgTable)
    -- wwlog("私人房收到消息",msgType)
    -- dump(msgTable)
    LoadingManager:endLoading()
    local dispatchEventId = nil
    local dispatchData = nil

    if msgType == self._msgIds.Msg_GDRoomAct_send then
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_ACT
        -- 房间操作
    elseif msgType == self._msgIds.Msg_GDCreateRoomReq_send then
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_CREATE
        -- 创建
    elseif msgType == self._msgIds.Msg_GDRoomSet_Ret then
        -- 私人房配置
        local data = { }
        table.walk(msgTable.roomConf, function(v, k)
            data[v.PlayType] = { }
            local tmpData = data[v.PlayType]
            for idx = 1, #v.PlayData do
                tmpData[#tmpData + 1] = { PlayData = string.byte(string.sub(v.PlayData, idx, idx)), RoomCard = string.byte(string.sub(v.RoomCard, idx, idx)) }
            end
        end )
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_PLAY_TYPE_CONF
        --
        dispatchData = data
    elseif msgType == self._msgIds.Msg_GDRoomInfo_Ret then
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO
        -- 返回房间信息
        dispatchData = msgTable
        DataCenter:cacheData(dispatchEventId, dispatchData)
    elseif msgType == self._msgIds.Msg_GDRoomResult_Ret then
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_BALANCE
        -- 私人房结束
        dispatchData = msgTable
        WWFacade:dispatchCustomEvent(dispatchEventId, dispatchData)
		WWFacade:dispatchCustomEvent(require("hall.mediator.cfg.RoomChatCfg").InnerEvents.RMCHAT_EVENT_CLOSEUI)
    elseif msgType == self._msgIds.Msg_GDRoomHistory_Ret then
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_HISTORY
        -- 历史记录
        dispatchData = msgTable.history
    elseif msgType == self._msgIds.Msg_GDRoomNotify_Ret then
        dispatchEventId = SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY
        -- 通知
        dispatchData = msgTable
        WWFacade:dispatchCustomEvent(dispatchEventId, dispatchData)
    end
    -- dump(dispatchData)
    if dispatchEventId and SiRenRoomCfg.innerEventComponent then
        SiRenRoomCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId,
            _userdata = dispatchData
        } )
	elseif dispatchEventId and  dispatchEventId == SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO then
		self:dispatchEvent(dispatchEventId,dispatchData)
    elseif dispatchEventId and dispatchEventId == SiRenRoomCfg.InnerEvents.SIREN_ROOM_NOTIFY and dispatchData.Type == 3 then
        SiRenRoomRequest.quitRoom(self, dispatchData.RoomID)
    end
end

function SiRenRoomProxy:_handleRootMsg(msgType, msgTable)
    LoadingManager:endLoading()
    local dispatchEventId = nil
    local dispatchData = nil
    if msgType == self._msgIds.Msg_GDRoomAct_send then
        -- 房间操作异常
        toast(msgTable.kReason, 2.0)
    elseif msgType == self._msgIds.Msg_GDCreateRoomReq_send then
        -- 创建房间异常
        if msgTable.kReasonType == 2 then
            toast(getStr("create_room_fail"))
        else
            toast(msgTable.kReason, 2.0)
        end
    else
        toast(msgTable.kReason, 2.0)
    end
    if dispatchEventId and SiRenRoomCfg.innerEventComponent then
        SiRenRoomCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId,
            _userdata = dispatchData
        } )
    end
end

return SiRenRoomProxy