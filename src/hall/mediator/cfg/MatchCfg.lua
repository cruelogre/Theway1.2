-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchCfg = {}
MatchCfg.innerEventComponent = nil
MatchCfg.InnerEvents = {
	MATCH_EVENT_ROOMLIST = "MATCH_EVENT_ROOMLIST", --比赛列表
	MATCH_EVENT_DETAIL0   = "MATCH_EVENT_DETAIL0", --赛事详情(内容界面)
	MATCH_EVENT_DETAIL   = "MATCH_EVENT_DETAIL", --赛事详情
	MATCH_EVENT_DETAIL_DESC   = "MATCH_EVENT_DETAIL_DESC", --赛事描述
	MATCH_EVENT_FOUNDMATES_FACE   = "MATCH_EVENT_FOUNDMATES_FACE", --玩家列表(面对面)
	MATCH_EVENT_FOUNDMATES_FACE_ALL   = "MATCH_EVENT_FOUNDMATES_FACE_ALL", --玩家列表(面对面所有的)
	MATCH_EVENT_FOUNDMATES_ADDFRIEND   = "MATCH_EVENT_FOUNDMATES_ADDFRIEND", --玩家列表(比赛邀请好友列表)
	MATCH_EVENT_CONDITION   = "MATCH_EVENT_CONDITION", --报名条件
	MATCH_EVENT_REWARD   = "MATCH_EVENT_REWARD", --排名奖励
	MATCH_EVENT_NOTIFYUSER = "MATCH_EVENT_NOTIFYUSER", --比赛通知
	MATCH_EVENT_NOTIFYUSER_QUIT = "MATCH_EVENT_NOTIFYUSER_QUIT", --退赛相关
	MATCH_EVENT_COST		= "MATCH_EVENT_COST", --比赛报名消耗
	MATCH_EVENT_START_DATA		= "MATCH_EVENT_START_DATA", --比赛开赛 数据  data轮次/局数
	MATCH_EVENT_UPGRADE		= "MATCH_EVENT_UPGRADE", --比赛晋级  data晋级人数
	MATCH_EVENT_RANK_CHANGE		= "MATCH_EVENT_RANK_CHANGE", --玩家名次变化
	MATCH_EVENT_ELIMINATE_CHANGE	= "MATCH_EVENT_ELIMINATE_CHANGE", --玩家淘汰人数变化
	MATCH_EVENT_OBSOLETED 		= "MATCH_EVENT_OBSOLETED", --我被淘汰了
	MATCH_EVENT_WAITOTHERS 		= "MATCH_EVENT_WAITOTHERS", --一轮打完，等待其他玩家
	MATCH_EVENT_WAITOTHERS_RANKDATA 		= "MATCH_EVENT_WAITOTHERS_RANKDATA", --一轮打完，等待其他玩家
	MATCH_EVENT_RESTORE_SCENE 		= "MATCH_EVENT_RESTORE_SCENE", --恢复现场通知
	MATCH_EVENT_COUNT_RESOTORE		= "MATCH_EVENT_COUNT_RESOTORE", --定人赛恢复现场
	MATCH_EVENT_INVITE_FRIEND = "MATCH_EVENT_INVITE_FRIEND", --邀请好友通知
	MATCH_EVENT_REFUSE_INVITE = "MATCH_EVENT_REFUSE_INVITE", --拒绝邀请
	MATCH_EVENT_AGREE_INVITE = "MATCH_EVENT_AGREE_INVITE", --同意邀请
	MATCH_EVENT_WILL_START = "MATCH_EVENT_WILL_START", --比赛即将开赛
	MATCH_EVENT_INVITE_SUCCESS = "MATCH_EVENT_INVITE_SUCCESS", --组队成功
	MATCH_EVENT_INVITE_FAILED = "MATCH_EVENT_INVITE_FAILED", --组队失败 好友已经组队成功
	MATCH_EVENT_SIGN_FAILED = "MATCH_EVENT_SIGN_FAILED", --报名失败
	MATCH_EVENT_FRIEND_QUIT = "MATCH_EVENT_FRIEND_QUIT", --组队的好友退赛
}
-- 设置中的http 请求的cid
MatchCfg.cids = {
	{5,MatchCfg.InnerEvents.MATCH_EVENT_DETAIL_DESC,"match_detail"}, --赛事详情
	{1,MatchCfg.InnerEvents.MATCH_EVENT_CONDITION,"match_condition"}, --报名条件
	{2,MatchCfg.InnerEvents.MATCH_EVENT_REWARD,"match_reward"}, --排名奖励
}

MatchCfg.enterTypes = {
	[1] = {
		fid = 10170998,name = "金币",storeOpenType = 2,spfile= "common/common_gold_efficon.png"
	},
	[2] = {
		fid = 20010993,name = "钻石",storeOpenType = 1,spfile= "common/common_diamond.png"
	},
	[3] = {
		fid = 10172001,name = "门票",storeOpenType = 4,spfile= "common/common_ticket_basic.png"
	},
	
}
--比赛消息通知类型
MatchCfg.NotifyType = {
	MATCH_WILL_START = 1, --比赛即将开赛
	MATCH_QUIT_SUCCESS = 2, --比赛退赛成功
	MATCH_QUIT_SUCCESS_HAS_STARTED = 3, --退赛成功，比赛已开始，不返回门票
	MATCH_QUIT_FAILED_ING = 4, --正在开赛中，不允许退赛
	MATCH_QUIT_FAILED_NOT_EXISTS = 5, --不在比赛中，不允许退赛
	MATCH_CANCELED_NOT_ENOUGH = 6, --人数不足，比赛被取消
	MATCH_SIGN_SUCCESS = 7, --报名成功
	MATCH_SIGN_FAILED = 8, --报名失败
	MATCH_FRIEND_QUIT = 9, --好友退赛
	MATCH_START = 11, --开赛
	MATCH_UPGRADE = 12, --晋级下一轮
	MATCH_OBSOLESCENCE = 13, --被淘汰
	MATCH_OVER = 14, --比赛结束
	MATCH_WAITING_OTHERS = 15, --等待其他桌完成对局
	MATCH_RESUME_GAME = 16, --恢复现场
	MATCH_RANK_CHANGE = 17, --玩家名次变化
	MATCH_INVITE_FRIEND_QUIT = 18, --组队好友退赛
	MATCH_COUNT_RESTORE = 19, --恢复定人赛比赛报名

	MATCH_FRIEND_AGREE = 21, --好友同意组队
	MATCH_FRIEND_SUCCESS = 22, --组队成功
	MATCH_FRIEND_FAILED = 23, --组队失败，好友已经组队
}
MatchCfg.refreshInterval = 5 --刷新间隔  单位:s
MatchCfg.mateRequestInterval = 30 --请求好友时间间隔  单位:s

MatchCfg.numberValidTime = 30 --四个数字的有效时间  单位:s
MatchCfg.matchSendnumberTime = 0 --发送四个数字的时间
MatchCfg.searchSendnumbers = nil --搜索的四个数字

MatchCfg.enterMatchId = 0 --进入的比赛ID

MatchCfg.minPermitDiffX = 50 --滑动的时候 允许记录的变化的最小差值
--通过cid 获取事件的名字
function MatchCfg.getEventByCid(cid)
	local eventName = nil
	for _,v in pairs(MatchCfg.cids) do
		if v[1]==cid then
			eventName = v[2]
			break
		end
	end
	return eventName
end
--通过cid 获取title
function MatchCfg.getTileByCid(cid)
	local titleName = nil
	for _,v in pairs(MatchCfg.cids) do
		if v[1]==cid then
			titleName = v[3]
			break
		end
	end
	return titleName
end

--[[
--获取比赛相关的图片资源的绝对地址
pType 1 拉取比赛的赛区图片  2 拉取对应比赛的前n名奖励图片
--]]
function MatchCfg:getMatchImageURL( pType, matchid, rankID )
	local para = {}
	para.vt = 1
	para.st = 10008001
	para.uid = DataCenter:getUserdataInstance():getValueByKey("userid")
	if pType == 2 then
		para.mst = rankID
	else
		para.mst = 1
	end
	para.picid = matchid
	para.phototype = pType

	return ToolCom:getWapUrl(para)
end

return MatchCfg