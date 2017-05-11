--[[
	帧动画控制器
	提供：
		1.加载帧动画
		2.播放帧动画（包含加载）
		3.释放帧动画资源
--]]
local WWAnimatePackerLua = class("WWAnimatePackerLua")
require "packages.framebase.Helper"
function WWAnimatePackerLua:ctor()
	
end
function WWAnimatePackerLua:getInstance()
	if self._wwanimatepacker == nil then
		self._wwanimatepacker = WWAnimatePackerLua.new()
	end
	return self._wwanimatepacker
end
--[[
	获取帧动画
	@param name 文件路径，没有后缀名
	@param animateName 动画名称，可以没有，如果动画名字为空则以文件名（无后缀名）为动画名称播放
--]]
function WWAnimatePackerLua:getAnimate(name,animateName)
	if type(name)~="string" then
		return nil
	end
	
	name = self:parserLuaFile(name)
	
	if not cc.FileUtils:getInstance():isFileExist(name) then
		return nil
	end
	
	self:loadAnimations(name)
	local animFile = name
	
	if string.find(animFile,".luac")~=nil then
		animFile = rsubStringFront(animFile,".luac")
		--animFile = string.sub(animFile,0,string.len(animFile)-5)
	elseif  string.find(animFile,".lua")~=nil then
		--animFile = string.sub(animFile,0,string.len(animFile)-4)
		animFile = rsubStringFront(animFile,".lua")
	end
	if animateName~=nil then
		animFile = animateName
	end
	local aname = rsubStringBack(animFile,"/")
	if aname==nil then
		aname = rsubStringBack(animFile,"\\")
	end
	local animation = cc.AnimationCache:getInstance():getAnimation(aname)
	if animation~=nil then
		return cc.Animate:create(animation)
	end
	return nil
end
--[[
	加载帧动画
	@param path lua文件路径
--]]
function WWAnimatePackerLua:loadAnimations(path)
	path = self:parserLuaFile(path)
	if not cc.FileUtils:getInstance():isFileExist(path) then
		return nil
	end
	local filedata = require(path)
	--filedata.plists[1]
	
	local plistFilePath = rsubStringFront(path,"/")
	if not plistFilePath then
		plistFilePath = rsubStringFront(path,"\\")
	end
	if not plistFilePath then return end
	
	
	
	filedata.plists = filedata.plists or {}

	self:iterator(filedata.plists,function (v)
		cc.SpriteFrameCache:getInstance():addSpriteFrames(plistFilePath.."/"..v)
	end)
	
	
	
	filedata.animations = filedata.animations or {}
	
	self:iterator(filedata.animations,function (animation)
		local sparr = {}
		for key,value in ipairs(animation.spriteFrame) do
			local spf = cc.SpriteFrameCache:getInstance():getSpriteFrame(value)
			table.insert(sparr,spf)
		end
		local anim = cc.Animation:createWithSpriteFrames(sparr,animation.delay)
		if anim~=nil then
			cc.AnimationCache:getInstance():addAnimation(anim,animation.name)
		end
	end)
	
end 
--[[
	释放帧动画
	@param path lua文件路径
--]]
function WWAnimatePackerLua:unloadAnimation(path)
	path = self:parserLuaFile(path)
	if not cc.FileUtils:getInstance():isFileExist(path) then return end
	
	local filedata = require(path)
		local plistFilePath = rsubStringFront(path,"/")
	if not plistFilePath then
		plistFilePath = rsubStringFront(path,"\\")
	end
	if not plistFilePath then return end
	
	filedata.animations = filedata.animations or {}
	self:iterator(filedata.animations,function (animation)
		if animation.name then
			cc.AnimationCache:getInstance():removeAnimation(animation.name)
		end
	end)
	
	filedata.plists = filedata.plists or {}

	self:iterator(filedata.plists,function (v)
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistFilePath.."/"..v)
	end)
	
	
end


function WWAnimatePackerLua:iterator(tableData,fun)
	if tableData and type(tableData)=="table" and type(fun)=="function" then
		for _,v in pairs(tableData) do
			fun(v)
		end
	end
		
end

function WWAnimatePackerLua:parserLuaFile(path)
	if string.find(path,".luac")==nil and cc.FileUtils:getInstance():isFileExist(path..".luac") then
		path = path..".luac"
	elseif string.find(path,".lua")==nil and cc.FileUtils:getInstance():isFileExist(path..".lua") then
		path = path..".lua"
	end
	return path
end


cc.exports.WWAnimatePackerLua = cc.exports.WWAnimatePackerLua or WWAnimatePackerLua:create()
return cc.exports.WWAnimatePackerLua