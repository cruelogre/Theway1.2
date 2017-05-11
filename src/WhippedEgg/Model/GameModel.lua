-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  Modle
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GameModel = class("GameModel")
import(".ConstType","WhippedEgg.")
local RegionTypeSwitch = {
	nanJing = 0,
	normal = 1,
}

function GameModel:ctor( ... )
	-- body
	self.mChooseSignle = false      --是否是单选
	self.nowCardVal = CARD_VALUE.R2 -- 这次要打的牌
	self.nowCardColor = FOLLOW_TYPE.TYPE_H -- 这次要打的牌的花色

	self.roomPoints = 0 --房间底分
	self.myNumber = 0 --我们打几
	self.opppsiteNumber = 0 --对方打几
	self.isPlayerBankerType = lightWiner.winerAll --我们庄家

	self.RegionType = 'n'  --方言
end

--方言设置
function GameModel:setSoundRegionType( regionType )
	-- body
	if regionType == RegionTypeSwitch.nanJing then
		self.RegionType = 'n'
	elseif regionType == RegionTypeSwitch.normal then
		self.RegionType = 'p'
	end
end

cc.exports.GameModel = cc.exports.GameModel or GameModel:create()
return cc.exports.GameModel