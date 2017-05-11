-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.10
-- Last: 
-- Content:  游戏中UI特效播放控制
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDUIAnimator = class("GDUIAnimator")
local GDUIAnimatorCfg = require("WhippedEgg.event.GDUIAnimatorCfg")
function GDUIAnimator:ctor()
	self.uniqueId = self.__cname.."_lua"
	
end
--播放UI动画
--@param parentNode 父节点
--@param pos 位置
--@param zorder 层级
--@param UIType GDUIAnimatorCfg.Type 动画播放类型
--@param UIImage 需要修改的ImgeView 集合
--@param UIText 需要修改的Text 集合
--@param Visivle 需要显示的控件 集合 {xxx = true,yyy = false}
--@param firstAnimName 进入需要播放动画的名字
--@param animationFrame 动画名称和监听 {callback = xxx,param = yyy}
--@param animationEnd 播放结束回调 {callback = xxx,param = yyy}
--@param loadedCB 加载完成UI后回调 loadedCB(node) 回传参数是当前创建好的node节点
function GDUIAnimator:play(parentNode,pos,zorder,UIType,UIImage,UIText,Visivle,firstAnimName,animationFrame,animationEnd,loadedCB)
	local animInfo = self:getAnimationInfo(UIType)
	if not animInfo then
		wwlog(self.uniqueId,"UI动画数据异常,UI类型:"..tostring(UIType))
		return
	end
	local loadcb = function ()
		self:play0(parentNode,pos,zorder,animInfo)
	end
	--组装animInfo
	animInfo.UIImage = UIImage or {}
	animInfo.UIText = UIText or {}
	animInfo.Visivle = Visivle or {}
	animInfo.loadedCallback = loadedCB
	animInfo.Animation.name = firstAnimName or "animation0"
	animInfo.Animation.frames = animationFrame or {} --动画名称回调
	animInfo.Animation.ends = animationEnd or nil --结束回调
	self:loadAnimRes(animInfo,loadcb)
end
--实际播放动画
--@param parentNode 父节点
--@param pos 位置
--@param zorder 层级
--@param animInfo 动画数据
function GDUIAnimator:play0(parentNode,pos,zorder,animInfo)
	local animNode = require(animInfo.Node):create()
	if not animNode.root then
		wwlog(self.uniqueId,"不支持的UI动画文件")
	end
	if not isLuaNodeValid(parentNode) then
		wwlog(self.uniqueId,"动画父节点非法")
	end
	for name,value in pairs(animInfo.Visivle) do
		local node = self:seekNodeByName(animNode.root,name)
		if isLuaNodeValid(node) then
			node:setVisible(value)
		end
	end
	for name,value in pairs(animInfo.UIImage) do
		local node = self:seekNodeByName(animNode.root,name)
		if isLuaNodeValid(node) and value.texture then
			node:loadTexture(value.texture,value.type or UI_TEX_TYPE_PLIST)
		end
	end
	for name,value in pairs(animInfo.UIText) do
		local node = self:seekNodeByName(animNode.root,name)
		if isLuaNodeValid(node) then
			node:setString(value)
		end
	end
	if animInfo.loadedCallback then
		animInfo.loadedCallback(animNode.root)
	end
	parentNode:addChild(animNode.root,zorder or ww.topOrder)
	animNode.root:setPosition(pos or cc.p(0,0))
	animNode.root:runAction(animNode.animation)
	if animInfo.Animation.ends then
		local animEnd = animInfo.Animation.ends
		animNode.animation:setAnimationEndCallFunc1(animInfo.Animation.name,function ()
			animNode.animation:stop()
			animNode.root:removeFromParent() --播放完成就删除了
			if animEnd.callback and type(animEnd.callback)=="function" then
				animEnd.callback(animEnd.param)
			end
			removeAll(animInfo)
		end)
	end
	if animInfo.Animation.frames then
		animNode.animation:setFrameEventCallFunc(function (frame)
			for name,v in pairs(animInfo.Animation.frames) do
				if frame:getEvent()==name then
					if type(v.callback)=="function" then
						v.callback(animNode.root,animNode.animation,v.param)
					end
					if v.isEnd==true then --表示最后一个 要删除了
						animNode.animation:stop()
						animNode.root:removeFromParent() --播放完成就删除了
						removeAll(animInfo)
					end
					break
				end
			end
		end)
	end
	animNode.animation:play(animInfo.Animation.name,false)
end



--资源加载
--@param animInfo 动画数据
--@param loadCB 加载完成回调
function GDUIAnimator:loadAnimRes(animInfo,loadCB)
	if animInfo.Textures then
		WWAsynResLoader:loadTexture(self.uniqueId,animInfo.Texture,function ()
			WWAsynResLoader:loadPlist(self.uniqueId,animInfo.Plist)
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
--通过UI类型获取动画配置信息
function GDUIAnimator:getAnimationInfo(UIType)
	local animInfo = nil
	for _,v in pairs(GDUIAnimatorCfg.animInfo) do
		if v.Type == UIType then
			animInfo = v
			break
		end
	end
	return animInfo and clone(animInfo) or nil
end

function GDUIAnimator:seekNodeByName(node,name)
	if not isLuaNodeValid(node) then
		return nil
	end
	if node:getName()==name then
		return node
	end
	for idx, child in pairs(node:getChildren()) do
		
		local res = self:seekNodeByName(child,name)
		if isLuaNodeValid(res) then
			return res
		end
	end

end
--卸载动画资源
function GDUIAnimator:unloadAnimationRes()
	WWAsynResLoader:unloadTexture(self.uniqueId)
	WWAsynResLoader:unloadPlist(self.uniqueId)
	wwlog(self.uniqueId,cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end
cc.exports.GDUIAnimator = cc.exports.GDUIAnimator or GDUIAnimator:create()
return cc.exports.GDUIAnimator