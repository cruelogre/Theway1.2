-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  逢人配玩法
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RandomGameManage = class("RandomGameManage",require("WhippedEgg.GameManageRoot.GameManageBase"))

--初始化界面
--@param gameType 游戏类型
--@param ismutiple 组队还是单人
function RandomGameManage:createGame(gameType,ismutiple )
	return RandomGameManage.super.createGame(self,gameType,ismutiple)
end

----------------------------------------------------------------------------------------------------
--发牌相关
----------------------------------------------------------------------------------------------------
--本次打几
function RandomGameManage:setCurGamePlayNum(isBankerOurs) --打谁的牌 到底是对方还是我们
	-- body
	wwlog(self.logTag,"设置本次打几")
	GameModel.isPlayerBankerType = lightWiner.winerAll
	GameModel.nowCardVal = GameModel.myNumber-1 --本次打几保存
	GameModel.nowCardColor = FOLLOW_TYPE.TYPE_H

	wwplyaCardLog("-------------------------本局主牌打"..PlayCardSwitch(GameModel.nowCardVal).."-----------------")
end

--主牌花色
function RandomGameManage:setPlayCardColor( color )
	-- body
	GameModel.nowCardColor = FOLLOW_TYPE.TYPE_H
end

function RandomGameManage:setPlayerInfo( playerType, players )
	-- body
	--发牌准备
	local function functionCardReady( ... )
		-- body
		self.gameState = GameStateType.Ready
		
		local function beginMatchAniEnd( ... )
			-- body
			self:getTipsAniLayer():playEggPain(function ( num )
				-- body
				self:getTipsAniLayer():setCurGamePlayNum(num,handler(self,self.DealCard),self.matchData)
			end)
		end
		wwlog(self.logTag,"先播放开始动画逢人配")
		self:getTipsAniLayer():beginMatchAni( beginMatchAniEnd,self.matchData )
		self:setDealCardReady()
		self:matchContinue()
	end

	self.gameState = GameStateType.WaitPlayerInfo
	if playerType == Player_Type.UpPlayer then
		self.UpPlayerReady = true
		if self.UpPlayerID and self.UpPlayerID ~= players.side1[2].UserID then
			self.newPlayer = true
		end
		self.UpPlayerID = players.side1[2].UserID
	elseif playerType == Player_Type.LeftPlayer then
		self.LeftPlayerReady = true
		if self.LeftPlayerID and self.LeftPlayerID ~= players.side2[1].UserID then
			self.newPlayer = true
		end
		self.LeftPlayerID = players.side2[1].UserID
	elseif playerType == Player_Type.RightPlayer then
		self.RightPlayerReady = true
		if self.RightPlayerID and self.RightPlayerID ~= players.side2[2].UserID then
			self.newPlayer = true
		end
		self.RightPlayerID = players.side2[2].UserID
	elseif playerType == Player_Type.SelfPlayer then
		self.MyPlayerReady = true
	end

	--最后一个设置完
	if playerType == Player_Type.RightPlayer then
		wwlog(self.logTag,"最后一个设置完")
		if self.newPlayer then
			self:setRank(Player_Type.LeftPlayer,0)
	  		self:setRank(Player_Type.RightPlayer,0)
	  		self:setRank(Player_Type.SelfPlayer,0)
	  		self:setRank(Player_Type.UpPlayer,0)

	  		if GameManageFactory.gameType ~= Game_Type.ClassicalRandomGame then
				self:getUpPlayer():runMoveAction(function ( ... )
					-- body
					self:getUpPlayer():setHeadInfo(players.side1[2])
				end)
				self:getLeftPlayer():runMoveAction(function ( ... )
					-- body
					self:getLeftPlayer():setHeadInfo(players.side2[1])
				end)
				self:getRightPlayer():runMoveAction(function ( ... )
					-- body
					self:getRightPlayer():setHeadInfo(players.side2[2])
					self.MyPlayer:setHeadInfo(players.side1[1])
					functionCardReady()
				end)
			else
				self:getUpPlayer():setHeadInfo(players.side1[2])
				self:getLeftPlayer():setHeadInfo(players.side2[1])
				self:getRightPlayer():setHeadInfo(players.side2[2])
				self.MyPlayer:setHeadInfo(players.side1[1])

				functionCardReady()
			end
  		else
			self:getUpPlayer():setHeadInfo(players.side1[2])
			self:getLeftPlayer():setHeadInfo(players.side2[1])
			self:getRightPlayer():setHeadInfo(players.side2[2])
			self.MyPlayer:setHeadInfo(players.side1[1])

			functionCardReady()
		end
	end	
end

cc.exports.RandomGameManage = cc.exports.RandomGameManage or RandomGameManage:create()
return cc.exports.RandomGameManage
