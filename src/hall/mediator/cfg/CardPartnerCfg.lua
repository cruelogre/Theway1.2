-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.12.30
-- Last: 
-- Content:  房间选择配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local CardPartnerCfg = {}
CardPartnerCfg.innerEventComponent = nil
CardPartnerCfg.InnerEvents = {
	CP_EVENT_PARTNERLIST = "CP_EVENT_PARTNERLIST", --牌友列表
	CP_EVENT_SEARCH_OK = "CP_EVENT_SEARCH_OK", --搜索好友OK
	CP_EVENT_SESSION_LIST = "CP_EVENT_SESSION_LIST", --会话列表  包括好友聊天最新消息 添加好友请求 好友拒绝添加好友恢复
	CP_EVENT_FRIEND_CHAT_CONTENT = "CP_EVENT_FRIEND_CHAT_CONTENT", --未读消息内容列表 根据好友ID来保存 当阅读后 从消息内存中删除 写入到数据库中
	CP_EVENT_AGREE_FRINED_ROOT = "CP_EVENT_AGREE_FRINED_ROOT", --同意添加好友 root 下行
	CP_EVENT_REFUSE_FRINED_ROOT = "CP_EVENT_REFUSE_FRINED_ROOT", --拒绝添加好友 root 下行
	CP_EVENT_AGREE_FRINED = "CP_EVENT_AGREE_FRINED", --同意添加好友 对方收到
	CP_EVENT_REFUSE_FRINED = "CP_EVENT_REFUSE_FRINED", --拒绝添加好友 对方收到
	
	CP_EVENT_FOUNDMATES_FACE   = "CP_EVENT_FOUNDMATES_FACE", --通过牌友扫到的玩家列表(面对面)
	CP_EVENT_FOUNDMATES_FACE_ALL = "CP_EVENT_FOUNDMATES_FACE_ALL",--玩家列表(面对面所有的)
	
	CP_EVENT_GAME_INVITE_FRIENDLIST = "CP_EVENT_GAME_INVITE_FRIENDLIST",-- 游戏中可邀请的好友列表
	CP_EVENT_GAME_INVITEED = "CP_EVENT_GAME_INVITEED",-- 收到好友邀请进入游戏
	CP_EVENT_GAME_AGREE_INVITEED = "CP_EVENT_GAME_AGREE_INVITEED",-- 同意好友邀请进入游戏
	CP_EVENT_GAME_REFUSE_INVITEED = "CP_EVENT_GAME_REFUSE_INVITEED",-- 拒绝好友邀请进入游戏
	CP_EVENT_GAME_FRIEND_DELETED = "CP_EVENT_GAME_FRIEND_DELETED",-- 好友删除成功
}

CardPartnerCfg.friendSearchLen = 20 --单次搜索好友的最大人数
CardPartnerCfg.sessionSearchLen = 15 --单次显示聊天数据的最大长度

CardPartnerCfg.characterBubbleMaxLen = 50 --气泡文字的最大长度
CardPartnerCfg.characterMaxCount = 60 --输入文字最大的输入长度


CardPartnerCfg.refreshInterval = 5 --刷新间隔  单位:s
CardPartnerCfg.mateRequestInterval = 30 --请求好友时间间隔  单位:s

CardPartnerCfg.numberValidTime = 30 --四个数字的有效时间  单位:s
CardPartnerCfg.matchSendnumberTime = 0 --发送四个数字的时间
CardPartnerCfg.searchSendnumbers = nil --搜索的四个数字


-- %Y-%m-%d %H:%M:%S
--print(os.time{year=1970, month=1, day=1, min=2,hour=0, sec=1})
--显示时间
--@param strTime 传入的时间字符串 格式是 yyyy-mm-dd HH:MM:SS
function CardPartnerCfg.getshowTime(strTime)
	local times = string.split(strTime," ")
	local todayTable = os.date("*t")
	local strTable = {}
	if times and type(times)=="table" and table.nums(times)>=2 then
		local data1 = string.split(times[1],"-")
		local data2 = string.split(times[2],":")
		if data1 and type(data1)=="table" and table.nums(data1)>=3 and
			data2 and type(data2)=="table" and table.nums(data2)>=3 then
			strTable.year=tonumber(data1[1])
			strTable.month=tonumber(data1[2])
			strTable.day=tonumber(data1[3])
			strTable.hour=tonumber(data2[1])
			strTable.min=tonumber(data2[2])
			strTable.sec=tonumber(data2[3])
		end
	end
	if strTable.year and strTable.month and strTable.day and strTable.hour and strTable.min and strTable.sec then
		if todayTable.year == strTable.year and todayTable.month == strTable.month and todayTable.day == strTable.day then
			return string.format("%s:%s",strTable.hour > 9 and tostring(strTable.hour) or "0"..tostring(strTable.hour),
									strTable.min > 9 and tostring(strTable.min) or "0"..tostring(strTable.min))
		elseif todayTable.year == strTable.year and todayTable.month == strTable.month and todayTable.day -1 == strTable.day then
			return i18n:get('str_cardpartner','partner_yestoday')
		else
			return string.format("%s-%s",strTable.month > 9 and tostring(strTable.month) or "0"..tostring(strTable.month),
									strTable.day > 9 and tostring(strTable.day) or "0"..tostring(strTable.day))
		end
	else
		return nil
	end

end
return CardPartnerCfg