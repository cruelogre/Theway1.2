-------------------------------------------------------------------------
-- Desc:    微信分享接口调用
-- Author:  
-- Date:    2016.09.26
-- Last:
-- Notice:  每个接口都要实现跨平台判断
-- Content:  
--   2016.09.26 
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local LuaWxShareNativeBridge = class("LuaWxShareNativeBridge")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local Toast = require("app.views.common.Toast")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local luaj
local luaoc

local className = "com/ww/platform/utils/WeiXinUtils";

function LuaWxShareNativeBridge:ctor()
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		luaj = require "cocos.cocos2d.luaj"
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
		luaoc = require "cocos.cocos2d.luaoc"
	end
end

--[[
微信分享图片
@parem sessiontype 微信分享朋友圈或者是聊天界面(1朋友圈 2 微信聊天界面)
@parem url 

--]]
function LuaWxShareNativeBridge:callNativeShareByPhotos(url,sessiontype)
	--local state = 0
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = { 
	    	url, --url
	    	sessiontype,
	    	handler(self,self.wxShareResult),
	    }  --传参
	    local sigs = "(Ljava/lang/String;Ljava/lang/String;I)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(className,"shareByPhotos",args,sigs)

	    if not ok then
	        cclog("[wawagame luaj] luaj error:", ret)
	    else
	        cclog("[wawagame luaj] The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	local args = {
					    url = url,
					    sessiontype = sessiontype,
					    tagname = wwConst.CLIENTNAME,
					    MessageExt = wwConst.CLIENTNAME,
					    action = wwURLConfig.SHARE_DOWNLOAD_URL,
					    wxShareResult = handler(self,self.wxShareResult),
					}
		if handlerX and type(handlerX)=="function" then
			args[#args] = handlerX
		end
		local luaoc = require "cocos.cocos2d.luaoc"
        local className = "LuaWXShareObjectCBridge"
		local ok,ret  = luaoc.callStaticMethod(className,"weixinsharebyphonto", args)
	end

end



--[[
	微信分享链接
	sessiontype(1朋友圈 2 微信聊天界面)
	title  url标题
	des    url描述
	url    分享链接
	photoUrl  缩略图路径
--]]
function LuaWxShareNativeBridge:callNativeShareByUrl(sessiontype, title, des,url,photoUrl,handlerX)

	if(cc.PLATFORM_OS_ANDROID == targetPlatform) then
		local args = {
			sessiontype,
			title,
			des,
			url,
			photoUrl,
			handler(self,self.wxShareResult),
		}
		if handlerX and type(handlerX)=="function" then
			args[#args] = handlerX
		end
		local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"  --回调函数形参签名
		local ok,ret = luaj.callStaticMethod(className,"shareByUrl",args,sigs)
		if not ok then
	        cclog("[wawagame luaj] luaj error:", ret)
		else
		    cclog("[wawagame luaj] The ret is:", ret)
		end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	local args = {
					    url = url,
					    sessiontype = sessiontype,
					    title = title,
					    des = des,
					    photoUrl = photoUrl,
					    wxShareResult = handler(self,self.wxShareResult),
					}
		if handlerX and type(handlerX)=="function" then
			args.wxShareResult= handlerX
		end
		local luaoc = require "cocos.cocos2d.luaoc"
        local className = "LuaWXShareObjectCBridge"
		local ok,ret  = luaoc.callStaticMethod(className,"weixinsharebyurl", args)
	else
		if handlerX then
			handlerX("yes")
		end
	end
end

function LuaWxShareNativeBridge:wxShareResult(result)
	cclog("[wawagame luaj] LuaWxShareNativeBridge:wxShareResult result=%s:",result)
	--Toast:makeToast("微信分享结果告知", 1.0):show()
end


return LuaWxShareNativeBridge