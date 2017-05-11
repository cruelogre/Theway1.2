
local WWNetSprite = class("WWNetSprite",cc.Sprite)

function WWNetSprite:ctor(defaultImg, url, redirectUrl)
	self.logTag = "WWNetSprite"
	self.defaultImg = defaultImg
	self.url = url or ""
	self.redirectUrl = redirectUrl or ""

	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	self:init()

--[[	local ressolution = require "resConfig"

	if ressolution.width and CC_DESIGN_RESOLUTION.width then
		self:setScale(ressolution.width/CC_DESIGN_RESOLUTION.width)
	end--]]
	
end
--判断dataTable 数组中是否存在dataKey
function WWNetSprite:isExistInTableArr(dataTable,dataKey)
	local exists = false
	for _,v in ipairs(dataTable) do
		if v==dataKey then
			exists = true
		end
	end
	return exists
end
function WWNetSprite:init()
	if self.defaultImg and string.len(self.defaultImg)>0 then
		--self.sp = display.newSprite(self.defaultImg)
		if string.byte(self.defaultImg) == 35 then
			--print("spriteframe",self.defaultImg)
			self:initWithSpriteFrameName(string.sub(self.defaultImg, 2))
		else
			self:initWithFile(self.defaultImg)
		end
		
	else
		--self.sp = cc.Sprite:create()
	end

	if (self.url ~= nil) and (self.url ~= "") then
		-- return
	-- else
		--self.sp:addTo(self)
		local emtypDatas = DataCenter:getData(COMMON_TAG.C_NETSPRITE_FAILED)
		if emtypDatas and self:isExistInTableArr(emtypDatas,md5.sumhexa(self.url)) then --下载失败的
			return
		end

		-- wwlog("获取头像 url不为空")
		
		if self.redirectUrl then
			--self:getHttpRedirectUrl()
			self:getSrc(self.url)
		else
			self:getSrc(self.url)
		end
	end
	
end

function WWNetSprite:initNetTexture(texture)
	if not isLuaNodeValid(self) or self.url==nil then
		wwlog("我都已经被释放了，不要再调用我了")
		return
	end
	if not texture then
		local emtypDatas = DataCenter:getData(COMMON_TAG.C_NETSPRITE_FAILED)
		if not emtypDatas then
			emtypDatas = {}
			table.insert(emtypDatas,md5.sumhexa(self.url))
			DataCenter:cacheData(COMMON_TAG.C_NETSPRITE_FAILED,emtypDatas)
		elseif not self:isExistInTableArr(emtypDatas,md5.sumhexa(self.url)) then
			table.insert(emtypDatas,md5.sumhexa(self.url))
		end
		--dump(emtypDatas)
		--DataCenter:cacheData(self.url,{empty = true})
		return
	end
	local stringUrl = md5.sumhexa("NET_SPRITE"..self.url)
	local downloadedDatas = DataCenter:getData(COMMON_TAG.C_NETSPRITE_DOWNLOAD)
	if not downloadedDatas then
		downloadedDatas = {}
		table.insert(downloadedDatas,stringUrl)
		DataCenter:cacheData(COMMON_TAG.C_NETSPRITE_DOWNLOAD,downloadedDatas)
	elseif not self:isExistInTableArr(downloadedDatas,stringUrl) then
		table.insert(downloadedDatas,stringUrl)
	end
	local ressolution = require "resConfig"

	if ressolution.width and CC_DESIGN_RESOLUTION.width then
		self:setScale(self:getScale()*ressolution.width/CC_DESIGN_RESOLUTION.width)
	end
	self:initWithTexture(texture)
end

--重定向获取到的URL，执行下载
function WWNetSprite:getSrc(url)
	local stringUrl = md5.sumhexa("NET_SPRITE"..url)
	local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(stringUrl)
	if texture then 
		-- wwlog(self.logTag,"取缓存中的纹理")
		--取缓存中的纹理
		local ressolution = require "resConfig"

		if ressolution.width and CC_DESIGN_RESOLUTION.width then
			self:setScale(self:getScale()*ressolution.width/CC_DESIGN_RESOLUTION.width)
		end
		self:initWithTexture(texture)
	else
		wwlog(self.logTag,"下载纹理")
		--这里我们将纹理加载到内存中，在适当的时候应该要释放
		self.imgdownloader = ww.ImageDownLoader:create(url,stringUrl)
		self.imgdownloader:excute(handler(self,WWNetSprite.initNetTexture))
	end
end
--[[
--针对Web重定向处理
--利用一次钓鱼请求，获取重定向后的地址
function WWNetSprite:getHttpRedirectUrl()
	
	local stringUrl = "NET_SPRITE"..self.url
    local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(stringUrl)
	if texture then
		self:initWithTexture(texture)
	else
		local xhr = cc.XMLHttpRequest:new()
		--xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
		xhr:open("GET", self.url) 

		local function onReadyStateChange()
			print("http", xhr.status,xhr.readyState,self.url)
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				-- wwlog("http", xhr.status)
				local response   = xhr.response
				
				--dump(response)
				local httpHeads = xhr:getAllResponseHeaders()
				local headSplit = Split(httpHeads, "\n")
				local locationStr = headSplit[7]

				local redirectStr = string.gsub(locationStr,"Location:","")
				redirectStr = string.trim(redirectStr)

				local stringUrl = "NET_SPRITE"..self.url
				wwlog("根据新的URL去获取", stringUrl)
				--这里我们将纹理加载到内存中，在适当的时候应该要释放
				self.imgdownloader = ww.ImageDownLoader:create(redirectStr,stringUrl)
				self.imgdownloader:excute(handler(self,self.initNetTexture))
	   
			else
				-- wwlog("xhr.readyState/status is: %d, %d", xhr.readyState,xhr.status)
			end
		end
		xhr:registerScriptHandler(onReadyStateChange)
		xhr:send()
	end		

end--]]

function WWNetSprite:onEnter()
--	WWNetSprite.super.onEnter(self)
end

function WWNetSprite:onExit()
--	WWNetSprite.super.onExit(self)
	-- wwlog(self.logTag,"WWNetSprite onExit")
	if self.imgdownloader then
		self.imgdownloader:removeHandler()
		self.imgdownloader = nil
		wwlog(self.logTag,"WWNetSprite delete imgdownloader")
	end
end

return WWNetSprite