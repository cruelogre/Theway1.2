-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.25
-- Last:
-- Content:  私人定制配置管理
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SiRenRoomCfg = { }
SiRenRoomCfg.innerEventComponent = nil
SiRenRoomCfg.InnerEvents =
{
    -- 房间操作
    SIREN_ROOM_ACT = "SIREN_ROOM_ACT",
    -- 创建房间
    SIREN_ROOM_CREATE = "SIREN_ROOM_CREATE",
    -- 玩法局数配置
    SIREN_ROOM_PLAY_TYPE_CONF = "SIREN_ROOM_PLAY_TYPE_CONF",
    -- 返回房间信息
    SIREN_ROOM_INFO = "SIREN_ROOM_INFO",
    -- 私人房最终结算
    SIREN_ROOM_BALANCE = "SIREN_ROOM_BALANCE",
    -- 私人房历史记录
    SIREN_ROOM_HISTORY = "SIREN_ROOM_HISTORY",
    -- 房间通知消息
    SIREN_ROOM_NOTIFY = "SIREN_ROOM_NOTIFY",
    --自己主动离开房间，因为后台不能给自己发送离开房间通知，所以客户端自己发。
    SIREN_ROOM_LEFT_SELF = "SIREN_ROOM_LEFT_SELF",
}
return SiRenRoomCfg