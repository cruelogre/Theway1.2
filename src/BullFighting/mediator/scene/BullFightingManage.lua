------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  斗牛总管理器基类
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local BullFightingManage = class("BullFightingManage")
local BullFinghtingCfg = require("BullFighting.mediator.cfg.BullFinghtingCfg")

require("BullFighting.util.BullDefine")
local BullFightingScene = require("BullFighting.mediator.scene.BullFightingScene")
local BullBackGrand = require("BullFighting.mediator.view.BullBackGrand")
local BullFoldMenuLayer = require("BullFighting.mediator.view.BullFoldMenuLayer")
local BullDealCardLayer = require("BullFighting.mediator.view.BullDealCardLayer")
local BullMyPlayer = require("BullFighting.mediator.view.BullMyPlayer")
local BullOtherPlayer = require("BullFighting.mediator.view.BullOtherPlayer")
local BullEffectLayer = require("BullFighting.mediator.view.BullEffectLayer")

local JumpFilter = require("packages.statebase.filter.JumpFilter")
local BullfightPokerUtil = require("BullFighting.util.BullfightPokerUtil")

cc.exports.BullZorderLayer = {
	BullBackGrandZorder = 0,          --背景
	BullDealCardLayerZorder = 1,		--发牌层
    RightPlayerZorder = 2,			--右玩家
    RightUpPlayerZorder = 3,			--右上玩家
    LeftUpPlayerZorder = 4,			--左上玩家
	LeftPlayerZorder = 5,				--左玩家
	BullMyPlayerZorder = 6,			--我
	BullEffectLayerZorder = 7,		--特效
	BullFoldMenuLayerZorder = 8,		--菜单栏
}

--初始化界面
--@param gameType 游戏类型
function BullFightingManage:createGame()
	self.logTag = "BullFightingManage.lua"
	wwlog(self.logTag,"创建游戏场景")

	-- playBackGroundMusic("sound/backMusic/matchBackGroundMusic",true)
	local random = math.random(0,1)
	if random == 0 then
		playBackGroundMusic("sound/backMusic/niubgbairen",true)
	else
		playBackGroundMusic("sound/backMusic/niubgqingkuai",true)
	end
	--创建游戏场景
	self.gameScene = BullFightingScene:create(function ( ... )
		-- body
		if self.BullFoldMenuLayer then
			self.BullFoldMenuLayer:exitGame()
		end
	end)
	
	--游戏背景层
	self.BullBackGrand = BullBackGrand:create()
    self.gameScene:addChild(self.BullBackGrand,BullZorderLayer.BullBackGrandZorder)

	--菜单层
	self.BullFoldMenuLayer = BullFoldMenuLayer:create()
	self.gameScene:addChild(self.BullFoldMenuLayer,BullZorderLayer.BullFoldMenuLayerZorder)

    --发牌层
	self.BullDealCardLayer = BullDealCardLayer:create()
	self.gameScene:addChild(self.BullDealCardLayer,BullZorderLayer.BullDealCardLayerZorder)

	--特效层
	self.BullEffectLayer = BullEffectLayer:create()
	self.gameScene:addChild(self.BullEffectLayer,BullZorderLayer.BullEffectLayerZorder)

	--我
    self.SelfPlayer = BullMyPlayer:create()
	self.gameScene:addChild(self.SelfPlayer,BullZorderLayer.BullMyPlayerZorder)
	
	self.playersData = {} --所有玩家
	self.playerLayer = {}
	self.deletePlayersData = {}

	--飘信封
	self.emailFlyTable = {}

	self.gameState = BullGameStateType.waitBegin

	return self.gameScene
end

function BullFightingManage:onExit( ... )
	-- body
	self.playersData = {} --所有玩家
	self.playerLayer = {}
	self.deletePlayersData = {}
	self.emailFlyTable = {}

	self.gameState = BullGameStateType.waitBegin

	self.BullBackGrand  = nil

	self.BullFoldMenuLayer = nil
	self.BullDealCardLayer = nil
	self.BullMyPlayer = nil
	self.BullEffectLayer = nil
	self.LeftPlayer = nil
	self.LeftUpPlayer = nil
	self.RightUpPlayer = nil
	self.RightPlayer = nil
	self.SelfPlayer = nil

	if self.dealCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
		self.dealCardScriptFuncId = false
	end

	if self.randomBankScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.randomBankScriptFuncId)
		self.randomBankScriptFuncId = false
	end

	self:clearGameData()
end

--清理缓存
function BullFightingManage:clearGameData( ... )
	-- body
	--离开匹配 清空缓存 下次进来继续匹配
	wwlog(self.logTag,"清除游戏开局或者恢复对局数据")
	DataCenter:clearData(BullFinghtingCfg.InnerEvents.DN_EVENT_INNORROOM)
end

function BullFightingManage:initRoom( userdata )
	-- body
	wwlog(self.logTag,"刚刚进来 初始化房间")
	self.initRoomData = clone(userdata)
	self.BankUserID = self.initRoomData.BankerId --本局庄家
	self.gameState = userdata.GameStatus
	if self.gameState == BullGameStateType.Settlement then
		self.gameState = BullGameStateType.waitBegin
	end
	
	if userdata.MySeatId == BullSeverPlayerType.SelfPlayerSeat then --5 54321
		BullPlayerType.SelfPlayerSeat = 5 --我自己
		BullPlayerType.RightPlayerSeat = 4 --右玩家
		BullPlayerType.RightUpPlayerSeat = 3 --右上玩家
		BullPlayerType.LeftUpPlayerSeat = 2 --左上玩家
		BullPlayerType.LeftPlayerSeat = 1--左玩家
	elseif userdata.MySeatId == BullSeverPlayerType.RightPlayerSeat then --4 43215 
		BullPlayerType.SelfPlayerSeat = 4 --我自己
		BullPlayerType.RightPlayerSeat = 3 --右玩家
		BullPlayerType.RightUpPlayerSeat = 2 --右上玩家
		BullPlayerType.LeftUpPlayerSeat = 1 --左上玩家
		BullPlayerType.LeftPlayerSeat = 5--左玩家
	elseif userdata.MySeatId == BullSeverPlayerType.RightUpPlayerSeat then --3 32154
		BullPlayerType.SelfPlayerSeat = 3 --我自己
		BullPlayerType.RightPlayerSeat = 2 --右玩家
		BullPlayerType.RightUpPlayerSeat = 1 --右上玩家
		BullPlayerType.LeftUpPlayerSeat = 5 --左上玩家
		BullPlayerType.LeftPlayerSeat = 4--左玩家
	elseif userdata.MySeatId == BullSeverPlayerType.LeftUpPlayerSeat then --2 21543
		BullPlayerType.SelfPlayerSeat = 2 --我自己
		BullPlayerType.RightPlayerSeat = 1 --右玩家
		BullPlayerType.RightUpPlayerSeat = 5 --右上玩家
		BullPlayerType.LeftUpPlayerSeat = 4 --左上玩家
		BullPlayerType.LeftPlayerSeat = 3--左玩家
	elseif userdata.MySeatId == BullSeverPlayerType.LeftPlayerSeat then --1 15432
		BullPlayerType.SelfPlayerSeat = 1 --我自己
		BullPlayerType.RightPlayerSeat = 5 --右玩家
		BullPlayerType.RightUpPlayerSeat = 4 --右上玩家
		BullPlayerType.LeftUpPlayerSeat = 3 --左上玩家
		BullPlayerType.LeftPlayerSeat = 2--左玩家
	end

	self.playersData = {}
	for k,v in pairs(userdata.UserTable) do
		local playerNode = {}
		playerNode.Chip = v.Chip --财富
		playerNode.GameStatus = userdata.GameStatus --1-抢庄 2-下注 3-亮牌 4-结算
		playerNode.Grade = v.Grade -- 用户1等级
		playerNode.Icon = v.Icon  --用户1头像
		playerNode.Gender = tonumber(v.Gender)  --用户性别
		playerNode.PlayType = userdata.PlayType --(int1)玩法类型
		playerNode.SeatId = v.SeatId --座位
		playerNode.Type = 1 --(int1)=1 进房间=2 退房间
		playerNode.UserId = v.UserId  --(int1)用户id
		playerNode.UserName = v.UserName --用户名

		if #userdata.UserTable == 1 and playerNode.UserId == userdata.UserId then --最开始匹配我一个 我不显示旁观
			playerNode.Status = 2 --(int1) 状态1= 旁观者2= 对局者
		else
			playerNode.Status = v.Status --(int1) 状态1= 旁观者2= 对局者
		end
		playerNode.BetRate = v.BetRate --(int1)用户1 下注倍数-1 表示自己还没下注
		playerNode.CardStatus = v.CardStatus --(int1) 状态1：四张暗牌2：四张明牌3：五张暗牌4：五张明牌
		playerNode.Card = v.Card --用户1的牌
		playerNode.BullNum = v.BullNum --用户1的牌型；0-无牛 1-牛丁 以此类推 10-牛牛11-四炸 12-五花牛 13-五小牛
		playerNode.ShowPokerTime = v.ShowPokerTime --用户1的亮牌时间
		playerNode.isShow = v.isShow --(int1) 是否亮牌0：未亮牌1：已亮牌

		table.insert(self.playersData,playerNode)
	end

	self:addInitPlayer(self.playersData)

	if #self.playersData > 1 then
		self.SelfPlayer:setChatButtonState(false)

		if self.initRoomData.GameStatus == BullGameStateType.Settlement then --刚刚进来就结算
			self.SelfPlayer:setWaitState( BullWaitState.BullWaitBegin,self.initRoomData.RemainTime )
		end
	end 
end

function BullFightingManage:addInitPlayer()
	-- body
	if #self.playersData <= 1 then
		self.SelfPlayer:setWaitState(BullWaitState.BullSettlment,0)
		self.BullDealCardLayer:setMatchingVisible(true)
	else
		self.BullDealCardLayer:setMatchingVisible(false)
	end 
	
	removeAll(self.playerLayer)
	self.playerLayer = {}
	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.RightPlayerSeat then
			--玩家右
			if not self.RightPlayer then
				self.RightPlayer = BullOtherPlayer:create(BullSeverPlayerType.RightPlayerSeat)
				self.gameScene:addChild(self.RightPlayer,BullZorderLayer.RightPlayerZorder)
			end

			self.RightPlayer:EnterBullGame(v)
			if v.Status == 2 then --对局
				table.insert(self.playerLayer,self.RightPlayer)
			end
			break
		end
	end

	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.RightUpPlayerSeat then
			--右上
			if not self.RightUpPlayer then
				self.RightUpPlayer = BullOtherPlayer:create(BullSeverPlayerType.RightUpPlayerSeat)
				self.gameScene:addChild(self.RightUpPlayer,BullZorderLayer.RightUpPlayerZorder)
			end

			self.RightUpPlayer:EnterBullGame(v)
			if v.Status == 2 then --对局
				table.insert(self.playerLayer,self.RightUpPlayer)
			end
			break
		end
	end

	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.LeftUpPlayerSeat then
			--左上
			if not self.LeftUpPlayer then
				self.LeftUpPlayer = BullOtherPlayer:create(BullSeverPlayerType.LeftUpPlayerSeat)
				self.gameScene:addChild(self.LeftUpPlayer,BullZorderLayer.LeftUpPlayerZorder)
			end
		
			self.LeftUpPlayer:EnterBullGame(v)
			if v.Status == 2 then --对局
				table.insert(self.playerLayer,self.LeftUpPlayer)
			end
			break
		end
	end

	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.LeftPlayerSeat then
			--玩家左
			if not self.LeftPlayer then
				self.LeftPlayer = BullOtherPlayer:create(BullSeverPlayerType.LeftPlayerSeat)
				self.gameScene:addChild(self.LeftPlayer,BullZorderLayer.LeftPlayerZorder)
			end
			
			self.LeftPlayer:EnterBullGame(v)
			if v.Status == 2 then --对局
				table.insert(self.playerLayer,self.LeftPlayer)
			end
			break
		end
	end

	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.SelfPlayerSeat then
			self.SelfPlayer:EnterBullGame(v)
			if v.Status == 2 then --对局
				table.insert(self.playerLayer,self.SelfPlayer)
			end
			break
		end
	end
end

--添加玩家
function BullFightingManage:addPlayerBySit( playerInfo )
	-- body
	table.insert(self.playersData,playerInfo)
	self:addInitPlayer(self.playersData)
end

--添加待删除玩家
function BullFightingManage:addDelPlayer( playerInfo )
	-- body
	wwlog(self.logTag,"添加待删除玩家")
	if self.gameState == BullGameStateType.waitBegin then
		self:delPlayerBySit(playerInfo)
	else
		if self:getPlayerInfoById(playerInfo.UserId) and self:getPlayerInfoById(playerInfo.UserId).Status == 1 then --旁观
			self:delPlayerBySit(playerInfo)
		else
			table.insert(self.deletePlayersData,playerInfo)
		end
	end
end

--删除已经添加缓存玩家
function BullFightingManage:delAllAddedPlayer()
	-- body
	wwlog(self.logTag,"删除已经添加缓存玩家")
	for k,v in pairs(self.deletePlayersData) do
		self:delPlayerBySit(v)
	end

	self.deletePlayersData = {}
end

--删除玩家
function BullFightingManage:delPlayerBySit( playerInfo )
	-- body
	for i=#self.playersData,1,-1 do
		if self.playersData[i].UserId == playerInfo.UserId then
			if self.playersData[i].SeatId == BullPlayerType.RightPlayerSeat then
				wwlog(self.logTag,"删除右玩家")
				self.RightPlayer:exitBullGame()
			elseif self.playersData[i].SeatId == BullPlayerType.RightUpPlayerSeat then
				wwlog(self.logTag,"删除右上玩家")
				self.RightUpPlayer:exitBullGame()
			elseif self.playersData[i].SeatId == BullPlayerType.LeftUpPlayerSeat then
				wwlog(self.logTag,"删除左上玩家")
				self.LeftUpPlayer:exitBullGame()
			elseif self.playersData[i].SeatId == BullPlayerType.LeftPlayerSeat then
				wwlog(self.logTag,"删除左玩家")
				self.LeftPlayer:exitBullGame()
			end
			self:clearEamilFlyByPlayerType(self.playersData[i].SeatId)
			table.remove(self.playersData,i)
			break
		end
	end
	wwlog(self.logTag,"剩余个数"..#self.playersData)
	self:addInitPlayer(self.playersData)
end

--清除播放加好友动画记录
function BullFightingManage:clearEamilFlyByPlayerType( playerType )
	-- body
	self.emailFlyTable[playerType] = {}

	for k,v in pairs(self.emailFlyTable) do
		if k ~= playerType then
			for i=#v,1,-1 do
				if v[1] == playerType then
					table.remove(v,i)
					break
				end
			end
		end
	end
end

--切换后台 清空桌面
function BullFightingManage:clearGame( ... )
	-- body
	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.RightPlayerSeat then
			wwlog(self.logTag,"删除右玩家")
			self.RightPlayer:exitBullGame()
		elseif v.SeatId == BullPlayerType.RightUpPlayerSeat then
			wwlog(self.logTag,"删除右上玩家")
			self.RightUpPlayer:exitBullGame()
		elseif v.SeatId == BullPlayerType.LeftUpPlayerSeat then
			wwlog(self.logTag,"删除左上玩家")
			self.LeftUpPlayer:exitBullGame()
		elseif v.SeatId == BullPlayerType.LeftPlayerSeat then
			wwlog(self.logTag,"删除左玩家")
			self.LeftPlayer:exitBullGame()
		end
	end
	self.SelfPlayer:resetGame()
	self.BullDealCardLayer:setMatchingVisible(false)
	self.playersData = {} --所有玩家
	self.playerLayer = {}
	self.BullDealCardLayer:releaseCards()
	
	if self.dealCardScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
		self.dealCardScriptFuncId = false
	end

	if self.randomBankScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.randomBankScriptFuncId)
		self.randomBankScriptFuncId = false
	end
end

--玩家可以显示完成
function BullFightingManage:CanShowCompleteCard( UserId )
	-- body
	self.gameState = BullGameStateType.ShowCard --亮牌
	local playerInfo = self:getPlayerInfoById(UserId)
	local Player = self:findPlayerBySeatId(playerInfo.SeatId)
	if isLuaNodeValid(Player) then
		Player:setComplete()
	end
end

--玩家下注
function BullFightingManage:setMultiple( UserId,Score )
	-- body
	local playerInfo = self:getPlayerInfoById(UserId)
	local Player = self:findPlayerBySeatId(playerInfo.SeatId)
	if isLuaNodeValid(Player) then
		Player:setMultiple(Score)
	end
end

--玩家亮牌结算
function BullFightingManage:settment(userdata)
	-- body
	wwlog(self.logTag,"结算")
    self:closePlayerInfo()

	wwlog(self.logTag,"结算 开始",os.date("[%Y-%m-%d %H:%M:%S] ", os.time())) 
	self.gameState = BullGameStateType.Settlement --结算
	self.SelfPlayer:setWaitState(BullWaitState.BullSettlment,userdata.CreateGameTimeOut)

	for k,v in pairs(userdata.PlayTable) do
		local playerInfo = self:getPlayerInfoById(v.UserID)
		local Player = self:findPlayerBySeatId(playerInfo.SeatId)
		Player.BullInfo.Chip = v.FinalChip
		Player:setHeadInfo()
		if isLuaNodeValid(Player) then
			if #userdata.PlayTable == k then --最后一个
				Player:CalculaCardResult(v,function ( ... )
					-- body
					if userdata.isAllKill == 1 then --通杀
						self.BullEffectLayer:alkillAniamte(function ( ... )
							-- body
							self:rollGold(userdata)
						end)
					else
						self:rollGold(userdata)
					end
				end)
			else
				Player:CalculaCardResult(v)
			end
		end
	end

	-- 清空玩家信息缓存 方便再次点击再次拉取
	DataCenter:clearData(BullFinghtingCfg.InnerEvents.DN_EVENT_USERINFO_RESP)
end

--金币滚动
function BullFightingManage:rollGold( userdata )
	-- body
	wwlog(self.logTag,"金币滚动")
	local bankPlayerInfo = self:getPlayerInfoById(self.BankUserID)
	local BankPlayer = self:findPlayerBySeatId(bankPlayerInfo.SeatId)
	local BankPlayerGetGold = false

	local losePlayer = {}
	local winPlayer = {}
	for k,v in pairs(userdata.PlayTable) do
		if self.BankUserID ~= v.UserID then
			local PlayerInfo = self:getPlayerInfoById(v.UserID)
			local Player = self:findPlayerBySeatId(PlayerInfo.SeatId)
			if v.WinLoseFlag == 2 then --输
				table.insert(losePlayer,{Player = Player,InCome = v.InCome})
			elseif v.WinLoseFlag == 1 then --赢
				table.insert(winPlayer,{Player = Player,InCome = v.InCome})
			end
		else
			BankPlayerGetGold = v.InCome
		end
	end

	--先收集输的
	if next(losePlayer) then
		for k,v in pairs(losePlayer) do
			if k == #losePlayer then --最后一个
				self.BullEffectLayer:rollGold(v.Player:getGoldPos(),BankPlayer:getGoldPos(),math.abs(v.InCome)/BullGoldToImg,function ( ... )
					-- body
					if next(winPlayer) then
						for m,n in pairs(winPlayer) do
							if m == #winPlayer then
								self.BullEffectLayer:rollGold(BankPlayer:getGoldPos(),n.Player:getGoldPos(),n.InCome/BullGoldToImg,function ( ... )
									-- body
									self:continueGame(userdata)
								end)
								n.Player:setGoldAnimate(n.InCome)
							else
								self.BullEffectLayer:rollGold(BankPlayer:getGoldPos(),n.Player:getGoldPos(),n.InCome/BullGoldToImg)
								n.Player:setGoldAnimate(n.InCome)
							end
						end
					else
						self:continueGame(userdata)
					end
				end)
				v.Player:setGoldAnimate(v.InCome)
			else
				self.BullEffectLayer:rollGold(v.Player:getGoldPos(),BankPlayer:getGoldPos(),math.abs(v.InCome)/BullGoldToImg)
				v.Player:setGoldAnimate(v.InCome)
			end
		end
	else
		for k,v in pairs(winPlayer) do
			if k == #winPlayer then
				self.BullEffectLayer:rollGold(BankPlayer:getGoldPos(),v.Player:getGoldPos(),v.InCome/BullGoldToImg,function ( ... )
					-- body
					self:continueGame(userdata)
				end)
				v.Player:setGoldAnimate(v.InCome)
			else
				self.BullEffectLayer:rollGold(BankPlayer:getGoldPos(),v.Player:getGoldPos(),v.InCome/BullGoldToImg)
				v.Player:setGoldAnimate(v.InCome)
			end
		end
	end

	--庄家的金币获得
	BankPlayer:setGoldAnimate(BankPlayerGetGold)
end

--继续游戏
function BullFightingManage:continueGame( userdata )
	-- body
	if userdata.isEnough == 0 then --足够
		wwlog(self.logTag,"继续下一把游戏 重置玩家状态")
		for k,v in pairs(self.playerLayer) do
			v:continueGame()
		end

		--这把我旁观
		for k,v in pairs(self.playersData) do
			if v.SeatId == BullPlayerType.SelfPlayerSeat then
				if v.Status == 1 then --这把我旁观
					self.SelfPlayer:continueGame()
				end
				break
			end
		end
	elseif userdata.isEnough == 1 then --不够
	    BullFightingManage:exitGame()
	end
end

--通过位置查找玩家
function BullFightingManage:findPlayerBySeatId( SeatId )
	-- body
	wwlog(self.logTag,"通过位置查找玩家")
	if SeatId == BullPlayerType.RightPlayerSeat then
		return self.RightPlayer
	elseif SeatId == BullPlayerType.RightUpPlayerSeat then
		return self.RightUpPlayer
	elseif SeatId == BullPlayerType.LeftUpPlayerSeat then
		return self.LeftUpPlayer
	elseif SeatId == BullPlayerType.LeftPlayerSeat then
		return self.LeftPlayer
	elseif SeatId == BullPlayerType.SelfPlayerSeat then
		return self.SelfPlayer
	end
end

--通过id找玩家信息
function BullFightingManage:getPlayerInfoById( UserId )
	-- body
	for k,v in pairs(self.playersData) do
		if UserId == v.UserId then
			wwlog(self.logTag,"通过id找玩家信息")
			return v
		end
	end

	wwlog(self.logTag,"竟然没找到人")
end

--更新开局玩家数据
function BullFightingManage:updateBeginPlayerData( userdata )
	-- body
	self.gameState = BullGameStateType.Begin --开局

	for m,n in pairs(self.playersData) do
		local find = false
		for k,v in pairs(userdata.PlayTable) do
			if v.UserId == n.UserId then
				find = true
				n.Chip = v.Chip
				n.Grade = v.Grade
				n.GameStatus = BullGameStateType.Begin --开局
				n.Status = 2  --(int1) 状态1= 旁观者2= 对局者
				n.BetRate = -1 --用户1 下注倍数-1 表示自己还没下注
				break
			end
		end

		if not find then
			n.GameStatus = BullGameStateType.Begin --开局
			n.Status = 1  --(int1) 状态1= 旁观者2= 对局者
			n.BetRate = -1 --用户1 下注倍数-1 表示自己还没下注
		end
	end

	self:addInitPlayer(self.playersData)
	local SelfPlayerData = self:getPlayerInfoById(userdata.MyUserId)
	if SelfPlayerData then
		SelfPlayerData.Card = userdata.MyCard
		SelfPlayerData.BullNum = userdata.MyBullNum
	end

	for k,v in pairs(self.playersData) do
		if v.SeatId == BullPlayerType.RightPlayerSeat then
			self.RightPlayer:resetGame()
		elseif v.SeatId == BullPlayerType.RightUpPlayerSeat then
			self.RightUpPlayer:resetGame()
		elseif v.SeatId == BullPlayerType.LeftUpPlayerSeat then
			self.LeftUpPlayer:resetGame()
		elseif v.SeatId == BullPlayerType.LeftPlayerSeat then
			self.LeftPlayer:resetGame()
		elseif v.SeatId == BullPlayerType.SelfPlayerSeat then
			self.SelfPlayer:resetGame()
		end
	end
end

--选择倍数阶段
function BullFightingManage:chooseMultiple( userdata )
	-- body
	wwlog(self.logTag,"下注")
	self.gameState = BullGameStateType.Cathectic --投注
	local isBanker = false
	if userdata.BankUserID == userdata.MyUserId then
		isBanker = true
	end

	if isBanker then --我是庄家就等待别人下注
		self.SelfPlayer:setWaitState(BullWaitState.BullWaitOtherChoose,userdata.HandleTime)
	else
		self.SelfPlayer:setCanMultiple(userdata.MyBetScore,userdata.HandleTime)
	end
end

--开始动画
function BullFightingManage:playBeginAni( callBack,BankUserID )
	-- body
	self.dealCardCallBack = callBack --回调
	self.BankUserID = BankUserID --本局庄家
	self.BullEffectLayer:beginAniamte(function ( ... )
		-- body
		self:randomBank()
	end)

	self.SelfPlayer:setChatButtonState(false)
end

--随机庄家
function BullFightingManage:randomBank( ... )
	-- body
	if not self.randomBankScriptFuncId then
		self.randomBankScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.randomBankFunc), 0.25, false)
	end

	self.randomInx = 1
	self.randomCount = 3
	self.lastRomdonPlayer = false
	self.curRomdonPlayer = false
end

--随机庄家动画
function BullFightingManage:randomBankFunc( ... )
	-- body
	if  self.randomCount <= 0 then
		if self.lastRomdonPlayer then
			self.lastRomdonPlayer:setRadomBanker(false)
		end

		self.curRomdonPlayer = self.playerLayer[self.randomInx]
		if self.curRomdonPlayer then
			playSoundEffect("sound/effect/bullfight/bankchoose")

			self.curRomdonPlayer:setRadomBanker(true)
			self.lastRomdonPlayer = self.curRomdonPlayer
		end

		if self.curRomdonPlayer and self.curRomdonPlayer.UserId == self.BankUserID then
			local playerInfo = self:getPlayerInfoById(self.BankUserID)
			local Player = self:findPlayerBySeatId(playerInfo.SeatId)
			if isLuaNodeValid(Player) then
				Player:setIsBanker(true,true,function ( ... )
					-- body
					if self.dealCardCallBack then
						self.dealCardCallBack()
					end
				end)
			end
			if self.randomBankScriptFuncId then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.randomBankScriptFuncId)
				self.randomBankScriptFuncId = false
			end
		else
			self.randomInx = self.randomInx + 1
		end
	else
		if self.lastRomdonPlayer then
			self.lastRomdonPlayer:setRadomBanker(false)
		end

		self.curRomdonPlayer = self.playerLayer[self.randomInx]
		if self.curRomdonPlayer then
			playSoundEffect("sound/effect/bullfight/bankchoose")
			
			self.curRomdonPlayer:setRadomBanker(true)
			self.lastRomdonPlayer = self.curRomdonPlayer
		end

		self.randomInx = self.randomInx+1
		if self.randomInx > #self.playerLayer and self.randomCount > 0 then
			self.randomInx = 1
			self.randomCount = self.randomCount - 1
		end
	end
end

function BullFightingManage:bullDealCard( userdata )
	-- body
	self.bullDealCardData = userdata
	self.SelfPlayer:runAction(cc.Sequence:create(cc.CallFunc:create(function ( ... )
		-- body
		self.SelfPlayer:CalculaCardClose()
	end),cc.DelayTime:create(0.5),cc.CallFunc:create(function ( ... )
			-- body
		--准备牌数据
		self:addInitPlayer(self.playersData)
		self.BullDealCardLayer:createCards(#self.playerLayer)
		self:playerCreateCards()
		self.dealCardLayerIdx = 1

		--超时下注
		wwlog(self.logTag,"超时下注")
		for k,v in pairs(userdata.ScoreInfos) do
			self:setMultiple(v.UserId,v.Score)
		end

		wwlog("发牌时间调试 开始",os.date("[%Y-%m-%d %H:%M:%S] ", os.time()))
		if not self.dealCardScriptFuncId then
			self.dealCardScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.dealCard), 0.15, false)
		end
	end)))
end

function BullFightingManage:dealCard( ... )
	-- body
	if self.dealCardLayerIdx <= #self.playerLayer then
		--body
		local function otherDealCardCallBack( ... )
			-- body
			wwlog(self.logTag,"这把我旁观 别人发完牌要显示他们打牌时间")
			self.SelfPlayer:setWaitState(BullWaitState.BullWaitCaculate,self.bullDealCardData.BetTime)
		end

		--这把我旁观 别人发完牌要显示他们打牌时间
		local isMyLook = false
		for k,v in pairs(self.playersData) do
			if v.SeatId == BullPlayerType.SelfPlayerSeat and v.Status == 1 then
				isMyLook = true
				break
			end
		end

		if self.playerLayer[self.dealCardLayerIdx].BullInfo.SeatId == BullPlayerType.SelfPlayerSeat then
			self.SelfPlayer:dealCard(self.bullDealCardData)
		elseif self.playerLayer[self.dealCardLayerIdx].BullInfo.SeatId == BullPlayerType.RightPlayerSeat then
			if isMyLook and self.dealCardLayerIdx == #self.playerLayer then
				self.RightPlayer:dealCard(otherDealCardCallBack)
			else
				self.RightPlayer:dealCard()
			end
		elseif self.playerLayer[self.dealCardLayerIdx].BullInfo.SeatId == BullPlayerType.RightUpPlayerSeat then
			if isMyLook and self.dealCardLayerIdx == #self.playerLayer then
				self.RightUpPlayer:dealCard(otherDealCardCallBack)
			else
				self.RightUpPlayer:dealCard()
			end
		elseif self.playerLayer[self.dealCardLayerIdx].BullInfo.SeatId == BullPlayerType.LeftUpPlayerSeat then
			if isMyLook and self.dealCardLayerIdx == #self.playerLayer then
				self.LeftUpPlayer:dealCard(otherDealCardCallBack)
			else
				self.LeftUpPlayer:dealCard()
			end
		elseif self.playerLayer[self.dealCardLayerIdx].BullInfo.SeatId == BullPlayerType.LeftPlayerSeat then
			if isMyLook and self.dealCardLayerIdx == #self.playerLayer then
				self.LeftPlayer:dealCard(otherDealCardCallBack)
			else
				self.LeftPlayer:dealCard()
			end
		end

		self.dealCardLayerIdx = self.dealCardLayerIdx + 1
	else
		wwlog("发牌时间调试 结束",os.date("[%Y-%m-%d %H:%M:%S] ", os.time()))

		if self.dealCardScriptFuncId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.dealCardScriptFuncId)
			self.dealCardScriptFuncId = false
		end
		self.BullDealCardLayer:releaseCards()
	end
end

--创建牌数据
function BullFightingManage:playerCreateCards( ... )
	-- body
	for k,v in pairs(self.playerLayer) do
		if v.BullInfo.SeatId == BullPlayerType.SelfPlayerSeat then --我
			local SelfPlayerData = self:getPlayerInfoById(v.BullInfo.UserId)
			self.SelfPlayer:createCards(SelfPlayerData.Card,handler(self,self.delDealNode),#self.playerLayer*BULL_DISTRIBUTE_CARD_MIN_NUM - (k-1)*BULL_DISTRIBUTE_CARD_MIN_NUM)
		elseif v.BullInfo.SeatId == BullPlayerType.LeftPlayerSeat then --左
			self.LeftPlayer:createCards(BullCards,handler(self,self.delDealNode),#self.playerLayer*BULL_DISTRIBUTE_CARD_MIN_NUM - (k-1)*BULL_DISTRIBUTE_CARD_MIN_NUM)
		elseif v.BullInfo.SeatId == BullPlayerType.LeftUpPlayerSeat then --左上
			self.LeftUpPlayer:createCards(BullCards,handler(self,self.delDealNode),#self.playerLayer*BULL_DISTRIBUTE_CARD_MIN_NUM - (k-1)*BULL_DISTRIBUTE_CARD_MIN_NUM)
		elseif v.BullInfo.SeatId == BullPlayerType.RightUpPlayerSeat then --右上
			self.RightUpPlayer:createCards(BullCards,handler(self,self.delDealNode),#self.playerLayer*BULL_DISTRIBUTE_CARD_MIN_NUM - (k-1)*BULL_DISTRIBUTE_CARD_MIN_NUM)
		elseif v.BullInfo.SeatId == BullPlayerType.RightPlayerSeat then --右
			self.RightPlayer:createCards(BullCards,handler(self,self.delDealNode),#self.playerLayer*BULL_DISTRIBUTE_CARD_MIN_NUM - (k-1)*BULL_DISTRIBUTE_CARD_MIN_NUM)
		end
	end
end

--自减发牌层的牌
function BullFightingManage:delDealNode( idx )
	-- body
	local cardNode = self.BullDealCardLayer:getCardByIdx(idx) --获取最上层一张牌
	if cardNode then
		--发牌层当前节点删除
		cardNode:removeFromParent()
	end
end

--退出
function BullFightingManage:exitGame( ... )
	-- body
	local bullFightingMediator =  MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().BULLFIGHTING_SCENE)
	local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
	BullFightingSceneProxy:requestLobbyActionHandle(bullFightingMediator.GameZoneID, 14)  --请求进入随机、看牌场房间

	local jumpFilter = JumpFilter:create(1,FSConst.FilterType.Filter_Enter,1)
	jumpFilter:setJumpData("chooseRoom",{ zorder=3,crType = 2
		,gameid=wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID
	, playType = wwConfigData.GAMELOGICPARA.BULLFIGHT.PLAYTYPE} )
	FSRegistryManager:getFSM(FSMConfig.FSM_HALL):addFilter("UIRoot",jumpFilter)

	WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
end

function BullFightingManage:requestUserInfo(userid,clearAll)
	self.reqUserId = userid
	local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
	BullFightingSceneProxy:requestUserInfo(userid)
end

--查看玩家信息
function BullFightingManage:checkPlayInfo( playerType,info )
	-- body
	self.BullFoldMenuLayer:checkPlayerInfo(playerType,info)
end

--关闭玩家信息
function BullFightingManage:closePlayerInfo( ... )
	-- body
	if isLuaNodeValid(self.BullFoldMenuLayer) then
		self.BullFoldMenuLayer:closePlayerInfo()
	end
	self.reqUserId = nil
end

--玩家加好友
function BullFightingManage:reponseFriend( FromUserID,ToUserID )
	-- body
	local playerInfoFrom = self:getPlayerInfoById(FromUserID)
	local playerInfoTo = self:getPlayerInfoById(ToUserID)
	
	--玩家不在房间中
	if not playerInfoFrom or not playerInfoTo then
		return
	end

	local PlayerFrom = self:findPlayerBySeatId(playerInfoFrom.SeatId)
	local PlayerTo = self:findPlayerBySeatId(playerInfoTo.SeatId)

	local function FromUserIDToUserID(playerInfoFrom,playerInfoTo)
		-- body
		self.emailFlyTable[playerInfoFrom.SeatId] = self.emailFlyTable[playerInfoFrom.SeatId] or {}
		for k,v in pairs(self.emailFlyTable[playerInfoFrom.SeatId]) do
			if v == playerInfoTo.SeatId then
				return true
			end
		end

		return false
	end

	if isLuaNodeValid(PlayerFrom) and isLuaNodeValid(PlayerTo) and not FromUserIDToUserID(playerInfoFrom,playerInfoTo) then
		table.insert(self.emailFlyTable[playerInfoFrom.SeatId],playerInfoTo.SeatId)
		self.BullEffectLayer:moveEmailAni(PlayerFrom:getHeadPos(),PlayerTo:getHeadPos())
	end
end

cc.exports.BullFightingManage = cc.exports.BullFightingManage or BullFightingManage:create()
return cc.exports.BullFightingManage