-------------------------------------------------------------------------
-- Title:	        排行榜（社区关系请求）
-- Author:     Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
--        对应文档：获取社区关系消息定义.doc
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local RankRequest = { }
local ranknetModel = require("hall.model.ranknetModel")

-- 掼蛋财富榜
function RankRequest.requestGDRankInfo(proxy)
    RankRequest.requestMemberInfo(proxy)
end

-- 获取社区关系请求
function RankRequest.requestMemberInfo(proxy, userID, ObjectID, Type, Start, Count, Param1, Param2)
    LoadingManager:startLoading(1.0, LOADING_MODE.MODE_NORMAL, i18n:get("str_common", "comm_waiting"))
    local paras = {
        bit.band(bit.rshift(ranknetModel.MSG_ID.Msg_MemberRequest_send,4 * 4),0xff),
        bit.band(bit.rshift(ranknetModel.MSG_ID.Msg_MemberRequest_send,2 * 4),0xff),
        bit.band(bit.rshift(ranknetModel.MSG_ID.Msg_MemberRequest_send,0 * 4),0xff),
        -- 用户ID
        UserID or DataCenter:getUserdataInstance():getValueByKey("userid"),
        -- (int4)操作对象ID，视Type不同而不同
        -- Type = 6时候，ObjecteID=48 灌蛋每日富豪榜
        ObjectID or 48,
        -- (int1)获取关系类型：
        -- 0 获取婚恋详细信息
        -- 1 获取战队详细信息
        -- 2 获取在线用户清单
        -- 3 获取好友(黑名单)清单
        -- 4 获取战队成员清单
        -- 5获取帮会成员清单
        -- 6 获取用户排行榜
        -- 7获取战队排行榜
        -- 8 获取当前摆雷台的战队清单
        -- 9 获取帮会详细信息
        -- 10 获取我的社区关系清单
        -- 11 获取指定用户与本人关系信息
        -- 12 获取可约战列表
        -- 13 已速配玩家avatar
        Type or 6,
        -- (int2)开始位置：1表示从(包括)第1个开始
        -- 约定：Start<2000，超出此范围时取Start=1
        Start or 1,
        -- (int2)返回记录数量：
        -- 约定：Count>=1 and Count<=40，超出此范围时取Count=5
        Count or 50,
        -- GameID
        Param1 or 0,
        -- PlayType,
        Param2 or 0,
    }
    --    dump(paras)
    proxy:sendMsg(ranknetModel.MSG_ID.Msg_MemberRequest_send, paras)
    removeAll(paras)
end

return RankRequest