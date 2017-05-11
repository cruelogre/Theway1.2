-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   cruelogre
-- Date:     2016.09.14
-- Last:    
-- Content: 物品奖励
-- Detail：
--			2016.09.14 创建 仅支持本地文件
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------
require("app.config.wwGoodsInfo")
local WWItemSprite = class("WWItemSprite",cc.Node)

local WWNetSprite = require("app.views.customwidget.WWNetSprite")

function WWItemSprite:createItem(param)
	if not param or type(param)~="table" then
		return nil
	end
	return WWItemSprite:create(param)
end
function WWItemSprite:ctor(param)
	self:init(param)
end

--[[
-- param.defaultSrc --默认本地图片 （网络图）
-- param.remoteSrc --远程图片地址 （网络图）
-- param.count --数量
-- param.id
--]]
function WWItemSprite:init(param)
	local fileName = getGoodsSrcByFid(param.id)
	local fontColor =  param.fontColor or cc.c3b(0xff,0xff,0x00)
	
	if not fileName or not cc.FileUtils:getInstance():isFileExist(fileName) then
		local defaultSrc = param.defaultSrc
		local remoteSrc = param.remoteSrc
		self.img = WWNetSprite:create(defaultSrc, remoteSrc)
		
	else
		self.img = ccui.ImageView:create(fileName)
	end

	self:addChild(self.img)

	self.count = ccui.Text:create("","FZZhengHeiS-B-GB.ttf",30)
	self.count:setString("x"..param.count)
	self.count:setTextColor(fontColor)
	self.count:setPosition(cc.p(0,-self.img:getContentSize().height/2))
	self:addChild(self.count)
end

function WWItemSprite:getContentSize( ... )
	-- body
	return {width = self.img:getContentSize().width,height = self.count:getContentSize().height}
end

return WWItemSprite