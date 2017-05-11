local SiRenRoomRequest = { }
local sirennetModel = require("hall.model.sirennetModel")


-- 加入房间
function SiRenRoomRequest.joinRoom(target, RoomID)
    print("****************************************************joinRoom")
    SiRenRoomRequest._roomAct(target, 1, RoomID)
end

-- 返回房间
function SiRenRoomRequest.returnRoom(target, RoomID)
    SiRenRoomRequest._roomAct(target, 2, RoomID)
end

-- 解散房间
function SiRenRoomRequest.releaseRoom(target, RoomID)
    SiRenRoomRequest._roomAct(target, 3, RoomID)
end

-- 开始游戏
function SiRenRoomRequest.startGame(target, RoomID)
    SiRenRoomRequest._roomAct(target, 4, RoomID)
end

-- 历史记录
function SiRenRoomRequest.history(target)
    SiRenRoomRequest._roomAct(target, 5, 0)
end

-- 私人房配置
function SiRenRoomRequest.roomConf(target)
    SiRenRoomRequest._roomAct(target, 6, 0)
end

-- 退出房间
function SiRenRoomRequest.quitRoom(target, roomID)
    SiRenRoomRequest._roomAct(target, 7, roomID)
end

-- 创建房间
-- 1:创建升级玩法。2：创建逢人配玩法，3：创建团团转玩法
function SiRenRoomRequest.createRoom(target, Playtype, PlayData, RoomCardCount, DWinPoint, MultipleData,GameID)
    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(sirennetModel.MSG_ID.Msg_GDCreateRoomReq_send,4 * 4),0xff),
        bit.band(bit.rshift(sirennetModel.MSG_ID.Msg_GDCreateRoomReq_send,2 * 4),0xff),
        bit.band(bit.rshift(sirennetModel.MSG_ID.Msg_GDCreateRoomReq_send,0 * 4),0xff),
		--游戏ID
		GameID or wwConfigData.GAME_ID,
        -- (int2)请求类型,
        -- 1= 升级玩法
        -- 2=逢人配
        -- 3=团团转
        Playtype,
        -- (int2)局数或者过几
        PlayData,
        -- (int2)使用房卡数量
        RoomCardCount,
        -- (int1)双下赢的分数
        DWinPoint,
        -- (String)炸弹和同花顺翻倍，1表示翻倍，0表示不翻倍，”,”分割，例如”1,0”
        MultipleData
    }
--    dump(paras)
    target:sendMsg(sirennetModel.MSG_ID.Msg_GDCreateRoomReq_send, paras)
    removeAll(paras)
end

-- 操作房间
function SiRenRoomRequest._roomAct(target, actType, RoomID,GameID)
    LoadingManager:startLoading(0.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(sirennetModel.MSG_ID.Msg_GDRoomAct_send,4 * 4),0xff),
        bit.band(bit.rshift(sirennetModel.MSG_ID.Msg_GDRoomAct_send,2 * 4),0xff),
        bit.band(bit.rshift(sirennetModel.MSG_ID.Msg_GDRoomAct_send,0 * 4),0xff),
        -- (int2)请求类型,
        -- 1=加入房间
        -- 2=返回房间
        -- 3=解散房间
        -- 4=开始游戏
        -- 5=历史记录
        -- 6=请求私人房配置
        actType,
        -- (int4)房间号
        RoomID,
		--游戏ID
		GameID or wwConfigData.GAME_ID,
    }
	wwdump(paras,"SiRenRoomRequest._roomAct")
    target:sendMsg(sirennetModel.MSG_ID.Msg_GDRoomAct_send, paras)
    removeAll(paras)
end

return SiRenRoomRequest