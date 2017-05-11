local WWAsynResLoader = class("WWAsynResLoader")

require("packages.framebase.WWAnimatePackerLua")
function WWAsynResLoader:ctor()
	self.m_textureLoadCount = {}
	self.m_texturePaths = {}
	self.m_textureLoadHandler = {}
	self.m_armatureLoadCount = {}
	self.m_armaturePaths = {}
	self.m_armatureLoadHandler = {}
	
	self.m_plistPaths = {}
	
	self.m_soundPaths = {}
	
	self.m_frameAnimationPaths = {}

	self.loadTextureScriptHander = {} --  加载资源完毕下一帧回调
end
function WWAsynResLoader:loadTexture(uniqueId,resList,cbFun)
	self.m_texturePaths[uniqueId] = self.m_texturePaths[uniqueId] or {}
	if resList then
		table.walk(resList,function (v,k)
			local len = table.nums(self.m_texturePaths[uniqueId])
			self.m_texturePaths[uniqueId][len+1] = v
		end)
	end
	--self.m_texturePaths[uniqueId] = resList
	self.m_textureLoadHandler[uniqueId] = cbFun
	self.m_textureLoadCount[uniqueId] = self.m_textureLoadCount[uniqueId] or 0
	
	--self.m_textureLoadCount[uniqueId] = 0
	self:loadTexture0(uniqueId)
end
function WWAsynResLoader:loadPlist(uniqueId,resList)
	self.m_plistPaths[uniqueId] = self.m_plistPaths[uniqueId] or {}
	if resList then
		table.walk(resList,function (v,k)
			local len = table.nums(self.m_plistPaths[uniqueId])
			self.m_plistPaths[uniqueId][len+1] = v
		end)
	end
	--self.m_plistPaths[uniqueId] = resList
	for _,v in pairs(resList) do
		cc.SpriteFrameCache:getInstance():addSpriteFrames(v)
	end
end

function WWAsynResLoader:loadMusic(uniqueId,resList)
	self.m_soundPaths[uniqueId] = resList
	
	for _,v in pairs(resList) do
--		cc.SimpleAudioEngine:getInstance():preloadEffect(v)
		ww.WWSoundManager:getInstance():addPreloadEffResource(v)
	end
	ww.WWSoundManager:getInstance():preloadResource()
end

function WWAsynResLoader:loadAmature(uniqueId,resList,cbFun)
	self.m_armatureLoadCount[uniqueId] = 0
	self.m_armaturePaths[uniqueId] = resList
	self.m_armatureLoadHandler[uniqueId] = cbFun
	self:loadAmature0(uniqueId)
	
end
function WWAsynResLoader:loadFrameAnimation(uniqueId,resList)
	self.m_frameAnimationPaths[uniqueId] = resList
	for _,v in pairs(resList) do
		WWAnimatePackerLua:loadAnimations(v)
	end
	
end

function WWAsynResLoader:loadAmature0(uniqueId)
	local paths = self.m_armaturePaths[uniqueId]
	local dataLoaded = function (percent)
		self:amatureCB(uniqueId)
	end
	if table.nums(paths)>0 then
		for _,v in pairs(paths) do
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(v, dataLoaded)
		end
	else
		dataLoaded(1)
	end
	
end

function WWAsynResLoader:loadTexture0(uniqueId)
	local paths = self.m_texturePaths[uniqueId]
	if table.nums(paths)>0 then
		if paths and type(paths) == "table" then
			for _,v in pairs(paths) do
				cc.Director:getInstance():getTextureCache():addImageAsync(v,function (texture)
					self:textureCB(uniqueId)
				end)
			end
		end
	else
		self:textureCB(uniqueId)
	end
	
end
function WWAsynResLoader:amatureCB(uniqueId)
	
	self.m_armatureLoadCount[uniqueId]= self.m_armatureLoadCount[uniqueId]+1
	if self.m_armatureLoadCount[uniqueId] >= table.nums(self.m_armaturePaths[uniqueId]) then
		if self.m_armatureLoadHandler[uniqueId] then
			self.m_armatureLoadHandler[uniqueId]()
			
		end
	end
end

function WWAsynResLoader:textureCB(uniqueId)
	if self.m_textureLoadCount[uniqueId] == nil then
		return
	end
	self.m_textureLoadCount[uniqueId]= self.m_textureLoadCount[uniqueId]+1
	if self.m_textureLoadCount[uniqueId] >= table.nums(self.m_texturePaths[uniqueId]) then
		self.m_textureLoadCount[uniqueId] = 0 --重置
		if self.m_textureLoadHandler[uniqueId] then
			if not self.loadTextureScriptHander[uniqueId] then
				self.loadTextureScriptHander[uniqueId] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
					-- body
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loadTextureScriptHander[uniqueId])
					self.loadTextureScriptHander[uniqueId] = nil
					if self.m_textureLoadHandler[uniqueId] then
						self.m_textureLoadHandler[uniqueId]()
					else
						wwlog("resource callback empty")
					end
				end, 0, false)
			else
				wwlog("same resource load too short!")
				
			end
		end
	end
end
function WWAsynResLoader:unloadTexture(uniqueId)
	local paths = self.m_texturePaths[uniqueId]
	if paths then
		for _,v in pairs(paths) do
			cc.Director:getInstance():getTextureCache():removeTextureForKey(v)
		end
		self.m_texturePaths[uniqueId] = nil
	end
	if self.m_textureLoadHandler[uniqueId] then
		self.m_textureLoadHandler[uniqueId] = nil
	end
	if self.m_textureLoadCount[uniqueId] then
		self.m_textureLoadCount[uniqueId] = nil
	end
end
function WWAsynResLoader:unloadPlist(uniqueId)
	
	local paths = self.m_plistPaths[uniqueId]
	if paths then
		for _,v in ipairs(paths) do
			cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(v)
		end
		self.m_plistPaths[uniqueId] = nil
	end
end

function WWAsynResLoader:unloadArmature(uniqueId)
	local paths = self.m_armaturePaths[uniqueId]

	
	if paths then
		for _,v in ipairs(paths) do
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v)
		end
		self.m_armaturePaths[uniqueId] = nil
	end
	if self.m_armatureLoadHandler[uniqueId] then
		self.m_armatureLoadHandler[uniqueId] = nil
		
	end
	if self.m_armatureLoadCount[uniqueId] then
		self.m_armatureLoadCount[uniqueId] = nil
	end
	
end
function WWAsynResLoader:unloadSound(uniqueId)
	
	local paths= self.m_soundPaths[uniqueId]
	if paths then		
		self.m_soundPaths[uniqueId] = nil
	end
	ww.WWSoundManager:getInstance():unloadResource()
end


function WWAsynResLoader:unloadFrameAnimation(uniqueId)
	local paths= self.m_frameAnimationPaths[uniqueId]
	if paths then
		for _,v in pairs(paths) do
			WWAnimatePackerLua:unloadAnimation(v)
		end
		self.m_frameAnimationPaths[uniqueId] = nil
	end


end
cc.exports.WWAsynResLoader = cc.exports.WWAsynResLoader or WWAsynResLoader:create()
return cc.exports.WWAsynResLoader