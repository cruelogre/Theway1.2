-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  房间聊天管理器
--			1.配置聊天表情
--			2.配置聊天常用文字
--			3.播放聊天内容

-- v1.1 添加清空播放数据
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RoomChatManager = class("RoomChatManager")

local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")

local RoomChatData = require("config.RoomChatData")
local WWQueue = require("app.utilities.WWQueue")
local ChatAnimatorFactory = require("hall.util.ChatAnimatorFactory")

local scheduler = cc.Director:getInstance():getScheduler()



function RoomChatManager:ctor()
	
	self.logTag = "RoomChatManager.lua"
	self.gameId = wwConfigData.GAME_ID --默认游戏ID是惯蛋的
	self.facialData = {}
	self.charecterData = {}
	self.handlers = {}
	self.updateId = nil
	--self.animator = WWQueue:create()
	self.animators = {}
	self.facialPlayDatas = {} --播放表情的位置信息集合
	self.charPlayDatas = {} --播放文字的位置信息集合
	self:initFacialConfig()
	self:initCharecterConfig()
	self:initSchedule()
	self:initEventListener()
	
end
--初始化表情配置
function RoomChatManager:initFacialConfig()
	self.facialData = RoomChatData[self.gameId].facialData

end
--初始化文字配置
function RoomChatManager:initCharecterConfig()
	self.charecterData = RoomChatData[self.gameId].charecterData
end

function RoomChatManager:initSchedule()
	if not self.updateId then
		self.updateId = scheduler:scheduleScriptFunc(handler(self,self.update), 0.1, false)
	end
	
end
--设置当前的游戏ID
--@param gameID 当前聊天的游戏ID
function RoomChatManager:setCurGameID(gameID)
	self.gameId = gameID or wwConfigData.GAME_ID
	self:initFacialConfig()
	self:initCharecterConfig()
	self:clearFacialPlayData()
	self:clearCharPlayData()
end
--返回当前游戏ID
function RoomChatManager:getCurGameID()
	return self.gameId or wwConfigData.GAME_ID
end
--添加表情播放的数据
--@param playData 组成表情播放的table表
-- 字段需要 
-- playid 播放ID
--	userid 用户ID
--	parentNode 父节点 
-- 	position 播放的位置 
--	zorder 层级

function RoomChatManager:addFacialPlayData(playData)
	if playData.playid then
		self.facialPlayDatas[tostring(playData.playid)] = playData
	end
end

function RoomChatManager:updateFacialId(playid,userid)
	local facialData = self.facialPlayDatas[tostring(playid)]
	facialData.userid = userid
end
--清空表情播放数据
function RoomChatManager:clearFacialPlayData()
	removeAll(self.facialPlayDatas)
end
--设置游戏数据
function RoomChatManager:setGameData(param)
	self.gameData = param or {}
end
--返回游戏数据
function RoomChatManager:getGameData()
	return self.gameData or {}
end

--添加文字播放的数据
--@param playData 组成文字播放的table表

-- 字段需要 
--  playid 播放ID
--	userid 用户ID
--	parentNode 父节点 
-- 	position 播放的位置 
--	zorder 层级
--	flippedX 是否X轴镜像
--	flippedY 是否Y轴镜像
function RoomChatManager:addCharPlayData(playData)
	
	if playData.playid then
		self.charPlayDatas[tostring(playData.playid)] = playData
	end
end

function RoomChatManager:updateCharId(playid,userid)
	local charData = self.charPlayDatas[tostring(playid)]
	facialData.userid = userid
end

--清空文字播放数据
function RoomChatManager:clearCharPlayData()
	removeAll(self.charPlayDatas)
end
--计时器 迭代动画队列
function RoomChatManager:update()
	for _,animatorQueue in pairs(self.animators) do
		local animator = animatorQueue:getBack()
		if animator then
			if animator:getState()==RoomChatCfg.animatorState.Init then
				animator:play()
				break
			elseif animator:getState()==RoomChatCfg.animatorState.Stoped then
				animatorQueue:popBack()
			end
		end
	end
end

function RoomChatManager:initEventListener()
	local _,handler6 = RoomChatCfg.innerEventComponent:addEventListener(
	RoomChatCfg.InnerEvents.RMCHAT_EVENT_RECIEVED_DATA,handler(self,self.commondEventHandle))
	table.insert(self.handlers,handler6)
end

function RoomChatManager:commondEventHandle(event)
	
	if event.name==RoomChatCfg.InnerEvents.RMCHAT_EVENT_RECIEVED_DATA then
		self:handleChatData(event.name)
	end

end

--处理网络聊天数据返回
--@param name
function RoomChatManager:handleChatData(name)
	local chatDatas = DataCenter:getData(RoomChatCfg.InnerEvents.RMCHAT_EVENT_RECIEVED_DATA)
	
	if not chatDatas or not next(chatDatas) then
		return
	end
	local tempChat = {}
	copyTable(chatDatas[1],tempChat)
	table.remove(chatDatas,1)
	
	local msg = tempChat.Content
	local facialData = self:checkFacialMsg(msg)
	if facialData then --表情
		local facialPlayData = self:getAnimationDataByUserId(RoomChatCfg.animatorType.Facial,tempChat.UserID)
		if facialPlayData then
			self:playFacial(facialPlayData.playid,facialData,facialPlayData)
		end
	else --文字
		local charData = {}
		charData.content = msg
		local charPlayData = self:getAnimationDataByUserId(RoomChatCfg.animatorType.Character,tempChat.UserID)
		if charPlayData then
			self:playCharecter(charPlayData.playid,charData,charPlayData)
		end
	end

	
end
--通过用户ID查询特效播放数据
--@param aniType 特效类型
--@param userid 用户ID
function RoomChatManager:getAnimationDataByUserId(aniType,userid)
	local retData = nil
	local tempData = nil
	if aniType == RoomChatCfg.animatorType.Facial then
		tempData = self.facialPlayDatas
	elseif aniType == RoomChatCfg.animatorType.Character then
		tempData = self.charPlayDatas
	end
	if tempData then
		for _,fd in pairs(tempData) do
			if fd.userid==userid then
				retData = fd
				break
			end
			
		end
	end
	return retData
end

--检查是否为表情动画，如果是返回表情动画数据，否则返回nil
function RoomChatManager:checkFacialMsg(msg)
	local retFd = nil
	for _,fd in pairs(self.facialData) do
		if fd.shortcut==msg then
			retFd = fd
			break
		end
	end
	return retFd
end
--添加通用动画
--@param playId 播放唯一标识符
--@param animator 动画模型 ChatAnimatorBase子类 
function RoomChatManager:addAnimation(playId,animator)
	if animator then
		local animatorQueue = self.animators[tostring(playId)]
		if not animatorQueue then
			animatorQueue = WWQueue:create()
			self.animators[tostring(playId)] = animatorQueue
		end
		animatorQueue:pushFront(animator)
		
	end
end
--播放表情动画
--@param playId 动画ID 一个ID使用一个队列，可以用用户ID来区分
function RoomChatManager:playFacial(playId,facialData,playData)
	wwlog(self.logTag,"%s 播放表情动画",tostring(playId))
	local animator = ChatAnimatorFactory:createAnimator(RoomChatCfg.animatorType.Facial,facialData,playData)
	self:addAnimation(playId,animator)

end
--播放文字动画
function RoomChatManager:playCharecter(playId,charData,playData)
	wwlog(self.logTag,"%s 播放文字动画",tostring(playId))
	local animator = ChatAnimatorFactory:createAnimator(RoomChatCfg.animatorType.Character,charData,playData)
	self:addAnimation(playId,animator)
	
end
--清空聊天队列
function RoomChatManager:clearChatQueue()
	for _,animatorQueue in ipairs(self.animators) do
		animatorQueue:clear()
	end
end

function RoomChatManager:unregisterEventListener()
	if RoomChatCfg.innerEventComponent then
		for _,v in pairs(self.handlers) do
			RoomChatCfg.innerEventComponent:removeEventListener(v)
		end
	end

end

function RoomChatManager:finalizer()
	if self.updateId then
		scheduler:unscheduleScriptEntry(self.updateId)
	end
	self:unregisterEventListener()
	self:clearChatQueue()
end
cc.exports.RoomChatManager = cc.exports.RoomChatManager or RoomChatManager:create()
return RoomChatManager