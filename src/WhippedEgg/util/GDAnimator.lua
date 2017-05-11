-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.07
-- Last: 
-- Content:  游戏中打牌特效播放控制
-- Modify:	2016.12.13 添加动画资源加载和卸载
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local GDAnimator = class("GDAnimator")
local GDAnimationCfg = require("WhippedEgg.event.GDAnimationCfg")
--公共纹理事先加载
local textures = {
	"guandan/pokerAnim/guandan_label.png",
	"guandan/pokerAnim/guandan_light.png",
}
local plists = {

	"guandan/pokerAnim/guandan_label.plist",
	"guandan/pokerAnim/guandan_light.plist",
}
function GDAnimator:ctor()
	self.uniqueId = self.__cname.."_lua"
	
	self.uniqueIdMap = {}
	
end
--播放
--@param parentNodeLower 父节点低层
--@param parentNodeUpper 父节点高层
--@param cardType 牌类型
--@param pos 位置
--@param isSelf 是否是我
function GDAnimator:play(parentNodeLower,parentNodeUpper,cardType,pos,isSelf)
	
	local animInfo = self:getAnimationInfo(cardType)
	if not animInfo then
		wwlog(self.uniqueId,"动画数据异常,牌类型:"..tostring(cardType))
		return
	end
	local loadcb = function ()
		self:play0(parentNodeLower,parentNodeUpper,cardType,pos,isSelf,animInfo)
	end
	self:loadAnimRes(animInfo,cardType,loadcb)
	
end
--实际播放
--@param parentNodeLower 父节点低层
--@param parentNodeUpper 父节点高层
--@param cardType 牌类型
--@param pos 位置
--@param isSelf 是否是我
--@param animInfo 动画数据
function GDAnimator:play0(parentNodeLower,parentNodeUpper,cardType,pos,isSelf,animInfo)
	local node = animInfo.Node
	local animations = animInfo.Animation
	local playIndex = 1 --当前播放的索引
	local mynodeLower = cc.Node:create()
	parentNodeLower:addChild(mynodeLower)
	local mynodeUpper = cc.Node:create()
	parentNodeUpper:addChild(mynodeUpper)
	if #node>0 and #animations>0 then
		self:playAnimationByIndex(mynodeLower,mynodeUpper,cardType,pos,isSelf,node,animations,playIndex)	
	end
end
--资源加载
--@param animInfo 动画数据
--@param cardType 牌类型
--@param loadCB 加载完成回调
function GDAnimator:loadAnimRes(animInfo,cardType,loadCB)
	if animInfo.Textures then
		self.uniqueIdMap = self.uniqueIdMap or {}
		local commonUniqueId = self.uniqueId..tostring(cardType)
		local has = false
		table.walk(self.uniqueIdMap,function (v,k)
			if v==commonUniqueId then
				has = true
			end
		end)
		if not has then
			table.insert(self.uniqueIdMap,commonUniqueId)
		end
		
		WWAsynResLoader:loadTexture(commonUniqueId,animInfo.Textures,function ()
			WWAsynResLoader:loadPlist(commonUniqueId,animInfo.Plists)
			if loadCB and type(loadCB)=="function" then
				loadCB()
			end
		end)
	else
		if loadCB and type(loadCB)=="function" then
			loadCB()
		end
	end
end
--播放配置中索引位置的处的特效
function GDAnimator:playAnimationByIndex(parentNodeLower,parentNodeUpper,cardType,pos,isSelf,node,animations,playIndex)
	if playIndex>#node or playIndex>#animations then
		return
	end
	for ii,vv in pairs(node[playIndex]) do
			local animNode = require(vv):create()
			
			if animations[playIndex][ii].zorder ~=nil and tonumber(animations[playIndex][ii].zorder) < 0 then
				print("lower effect.......")
				parentNodeLower:addChild(animNode.root,10+ii)
			else
				parentNodeUpper:addChild(animNode.root,10+ii)
			end
			
			
			if animations[playIndex][ii].isfull ~=nil and animations[playIndex][ii].isfull == true then
				animNode.root:setPosition(display.center)
			else
				if not isSelf then
					animNode.root:setScale(animNode.root:getScale()*0.5)
				end
				local width = animations[playIndex][ii].width
				local height = animations[playIndex][ii].height
				local diff = cc.p(0,0)
				if width then
					if not isSelf then
						width = tonumber(width)/2
					end
					diff.x = tonumber(width)/2
					
				end
				if  height then
					if not isSelf then
						height = tonumber(height)/2
					end
					diff.y = tonumber(height)/2
				end
				print("----------->",pos.x,pos.y)
				animNode.root:setPosition(cc.pAdd(pos,diff))
			end

			
			animNode.animation:play(animations[playIndex][ii].name,false)
			local isEnd = animations[playIndex][ii].isEnd
			local endTag = animations[playIndex][ii].endTag
			if (endTag ~=nil and endTag == true) or (isEnd ~=nil and isEnd ==true) then
				animNode.animation:setAnimationEndCallFunc1(animations[playIndex][ii].name,function ()
					if isEnd~=nil and isEnd==true then
						parentNodeLower:removeAllChildren()
						parentNodeLower:removeFromParent()
						parentNodeUpper:removeAllChildren()
						parentNodeUpper:removeFromParent()
						print("delete animations.......")
					else
						self:playAnimationByIndex(parentNodeLower,parentNodeUpper,cardType,pos,isSelf,node,animations,playIndex+1)
					end
					
				end)
			end
			if animations[playIndex][ii].delay then
				animNode.animation:retain()
				animNode.root:setVisible(false)
				animNode.root:runAction(cc.Sequence:create(cc.DelayTime:create(animations[playIndex][ii].delay),cc.CallFunc:create(function ()
					animNode.root:setVisible(true)
					animNode.root:runAction(animNode.animation)
				end)))
			else
				animNode.root:runAction(animNode.animation)
			end		
	end
		

end
--通过牌类型获取动画配置信息
function GDAnimator:getAnimationInfo(cardType)
	local animInfo = nil
	for _,v in pairs(GDAnimationCfg) do
		for _,vv in pairs(v.cardType) do
			if vv == cardType then
				animInfo = v
				break
			end
		end
	end
	return animInfo
end
--加载动画资源
function GDAnimator:loadAnimationRes()
	removeAll(self.uniqueIdMap)
	self.uniqueIdMap = self.uniqueIdMap or {}
	local commonUniqueId = self.uniqueId.."0"
	table.insert(self.uniqueIdMap,commonUniqueId)
	WWAsynResLoader:loadTexture(commonUniqueId,textures,function ()
		WWAsynResLoader:loadPlist(commonUniqueId,plists)
		wwlog(commonUniqueId,cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	end)
end
--卸载动画资源
function GDAnimator:unloadAnimationRes()
	for _,v in pairs(self.uniqueIdMap) do
		WWAsynResLoader:unloadTexture(v)
		WWAsynResLoader:unloadPlist(v)
	end
	wwlog(self.uniqueId,cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

cc.exports.GDAnimator = cc.exports.GDAnimator or GDAnimator:create()
return cc.exports.GDAnimator