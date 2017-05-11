-------------------------------------------------------------------------
-- Desc:    Lua原生桥接实现类
-- Author:  diyal.yin
-- Date:    2015.12.07
-- Last:
-- Notice:  每个接口都要实现跨平台判断
-- Content:  
--   2015.12.07 diyal.yin 新建文件
--   2015.12.07 diyal.yin 添加调用录音接口
--   2015.12.08 diyal.yin 添加调用播放录音接口
--   2015.12.08 diyal.yin 添加调用获取录音音频振幅接口
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local LuaNativeBridge = class("LuaNativeBridge")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local luaj
local luaoc


local PhoneToolPath = "com/ww/platform/utils/PhoneTool"
-- local UmengClassPath = "org.cocos2dx.cpp/AppActivity";
local webHelperPath
local className, classUmengName


function LuaNativeBridge:ctor()
	self.logTag = "LuaNativeBridge.lua"
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		luaj = require "cocos.cocos2d.luaj"
		
		className = "com/ww/platform/wwaudio/LuaNatiaveInterface";
		classUmengName = "com/mas/wawapak/sdk/util/SdkUtil"
		webHelperPath = "org/cocos2dx/lib/Cocos2dxWebViewHelper"
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
		luaoc = require "cocos.cocos2d.luaoc"
		className = "LuaObjectCBridge"
		classUmengName = "LuaUmengObjectCBridge"
	end
end

--[[
Lua调用Native 录音开始
--]]
function LuaNativeBridge:callAudioRecordStart()

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = { ww.LuaDataBridge:getInstance():getUserId() }  --传参
	    local sigs = "(Ljava/lang/String;)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(className,"audioRecordStart",args,sigs)

	    if not ok then
	        wwlog("[wawagame luaj] luaj error:", ret)
	    else
	        wwlog("[wawagame luaj] The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
	end
end


--[[
Lua调用Native 停止录音 并且回调Lua函数
--]]
function LuaNativeBridge:callAudioRecordStop(stopRecordFunc)

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

	    local function callbackLua(voicePath)
	    	if voicePath then
		        wwlog("[wawagame luaj] record success -> %s", voicePath)

		        stopRecordFunc(voicePath)
	    	end
	    end
	    local args = { "audioRecordStop", callbackLua }
	    local sigs = "(Ljava/lang/String;I)V"
	    local ok = luaj.callStaticMethod(className,"audioRecordStop",args,sigs)
	    if not ok then
	        wwlog("[wawagame luaj]call callback error")
	    else
	        wwlog("[wawagame luaj]call callback ok")
	    end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
	end
end

--[[
Lua调用Native 播放录音 并且回调Lua函数
--]]
function LuaNativeBridge:callPlayAudio( sVoiceName )

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

	    local function callbackPlayLua( params )
	    	if params == 'success' then
		        wwlog("[wawagame luaj] Play success")
	    	end
	    end
	    local args = { sVoiceName, callbackPlayLua }
	    local sigs = "(Ljava/lang/String;I)V"
	    local ok = luaj.callStaticMethod(className,"audioPlay",args,sigs)
	    if not ok then
	        wwlog("[wawagame luaj]call callback error")
	    else
	        wwlog("[wawagame luaj]call callback ok")
	    end

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
	end
end

--[[
获取到当前录音的振幅（最大绝对值）
--]]
function LuaNativeBridge:callGetAmplitude()
	local voiceValue = 0
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

	    local args = {}
	    local sigs = "()I"
	    local ok, ret = luaj.callStaticMethod(className,"audioGetAmplitude",args,sigs)
	    if not ok then
	        wwlog("[wawagame luaj]call callback error")
	    else
	        wwlog("[wawagame luaj]call callback ok")
	    end
		voiceValue = ret
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
	end
	return voiceValue
end

--[[
拨打电话
--]]
function LuaNativeBridge:makePhoneCall(phonenum)

	--这里电话号码，可以在配置文件读取

	wwlog("LuaNativeBridge:makePhoneCall", phonenum)

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		wwlog("LuaNativeBridge makePhoneCall android")
		local args = {phonenum}
    	local sigs = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(PhoneToolPath,"makePhoneCall",args,sigs)
    	if not ok then
	        wwlog("[wawagame luaj] luaj error:", ret)
	    else
	        wwlog("[wawagame luaj] The ret is:", ret)
	    end
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) then
		wwlog("LuaNativeBridge makePhoneCall ios")

	    local args = {
					    phonenum = phonenum
					}
		local ok,ret  = luaoc.callStaticMethod(className,"makePhoneCall", args)

		if not ok then

		else
		    wwlog("LuaNativeBridge makePhoneCall error2")
		end
	end

end

--[[
open live800
--]]
function LuaNativeBridge:openLive800(url)

	local function callNativeFunc( endURL )
	wwlog("LuaNativeBridge:openLive800 CallBack")
	    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    	local args = {
	    		endURL 
	    	}
	    	local sigs ="(Ljava/lang/String;)V"
	    	local ok,ret = luaj.callStaticMethod(PhoneToolPath,"loadWapActivity",args,sigs);
	    	if not ok then
		        wwlog("[wawagame luaj] luaj error:", ret)
		    else
		        wwlog("[wawagame luaj] The ret is:", ret)
		    end
	    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
	    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
	    or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
	        local args = { 
	    				    url = endURL
	    			     }
	        local ok,ret  = luaoc.callStaticMethod(className,"openLive800", args)
	        if not ok then
	        else
	            print("The ret is:", ret)
	        end
	    end
	end

    ToolCom:getLive800URL(callNativeFunc)
end


function LuaNativeBridge:showAlterViewWithText( titleStr, contentStr )

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	
        local args = { 
		    title = titleStr,
		    content = contentStr,
	    }
        local ok,ret  = luaoc.callStaticMethod(className,"showAlterViewWithText", args)
        if not ok then
        else
            print("The ret is:", ret)
        end
	end
end


--
function LuaNativeBridge:CallBackfunc( saveNativePath )
	--发送通知上传头像
	wwlog(self.logTag, "上传头像......")
	local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
	ww.WWGameData:getInstance():setStringForKey("UploadHeadPath_"..userid, saveNativePath)
	ToolCom:uploadHead(saveNativePath)

	-- 刷新头像
	-- cc.Director:getInstance():getEventDispatcher():dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_HEAD_NATIVE)
end

--[[
openPhotoAndSavePic 打开相册
--]]
function LuaNativeBridge:openPhotoAndSavePic(userid)

    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")


    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    	local args = {
    		userid,
    		handler(self,self.CallBackfunc),
    	}
    	local sigs ="(II)V"
    	local ok,ret = luaj.callStaticMethod(PhoneToolPath,"pickHeadFromAlbum",args,sigs);
    	if not ok then
	        wwlog("[wawagame luaj] luaj error:", ret)
	    else
	        wwlog("[wawagame luaj] The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform)) 
	or (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
	    --Iphone tool
	    ww.IPhoneTool:getInstance():openPhotoAndSavePic(userid)
    end
end

--[[
openPhotoAndSavePic 打开相机.拍照
--]]
function LuaNativeBridge:openCameraAndSavePic(userid)

    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    	local args = {
    		userid,
    		handler(self, self.CallBackfunc),
    	}
    	local sigs ="(II)V"
    	local ok,ret = luaj.callStaticMethod(PhoneToolPath,"pickHeadFromCamera",args,sigs);
    	if not ok then
	        wwlog("[wawagame luaj] luaj error:", ret)
	    else
	        wwlog("[wawagame luaj] The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
	    --Iphone tool
	    ww.IPhoneTool:getInstance():openCameraAndSavePic(userid)
    end
end

--[[
获取到当前手机支持的支付方式
--]]
function LuaNativeBridge:getPhoneInstallInfo()
	local ret = 0;
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then

	    local args = {}
	    local sigs = "()I"
	    local ok, typeValue = luaj.callStaticMethod(PhoneToolPath,"getInstallInfo",args,sigs)
	    if not ok then
	        wwlog("[wawagame luaj]getPhoneInstallInfo callback error")
	    else
	        wwlog("[wawagame luaj]getPhoneInstallInfo callback ok")
	    end
		ret = typeValue
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
	end

    wwlog("getPhoneInstallInfo ret:"..ret);
	return ret;
end

--[[
获取当前手机的ip
--]]

function LuaNativeBridge:getIpAddress()
	local ipvalues = "";
	wwlog("LuaNativeBridge:getIpAddress()....")
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    	local args = {}
	    local sigs = "()Ljava/lang/String;"
    	local ok,ret = luaj.callStaticMethod(PhoneToolPath,"getIpAddress",args,sigs);
    	if not ok then
	        wwlog("[wawagame luaj] luaj error:", ret)
	    else
	        wwlog("[wawagame luaj] The ret is:", ret)
	    end
	    ipvalues = ret
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
        -- local luaoc = require "cocos.cocos2d.luaoc"
        -- local className = "LuaObjectCBridge"
        local ok,ret  = luaoc.callStaticMethod(className,"getIpAddress")
        ipvalues = ret
        if not ok then
        else
            print("The ret is:", ret)
        end
    end
    	wwlog("LuaNativeBridge:getIpAddress ret:"..ipvalues)
    	return ipvalues
end

--[[
获取当前手机的ip
ios 设置到钥匙串
--]]

function LuaNativeBridge:setUserIDKeyChian(userinfo)

	local userinfos = ""
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform))  then

        local args = { 
    				    userinfo = userinfo
    			    }
        local ok,ret  = luaoc.callStaticMethod(className,"setUserIDKeyChian", args)
        if not ok then
        else
            print("The ret is:", ret)
        end
    end
end

--[[
获取当前手机的ip
ios 从钥匙串获取用户密码
--]]

function LuaNativeBridge:getUserIDKeyChian()

	local userinfos = ""
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform))  then

        local ok,ret  = luaoc.callStaticMethod(className,"getUserIDKeyChian")
        if not ok then
        else
            print("The ret is:", ret)
        end
        userinfos = ret
    end
    return userinfos
end

----------------------------------------------------
-------------- umeng event start -------------------
----------------------------------------------------
-- local Toast = require("app.views.common.Toast")

-- Umeng upload event
function LuaNativeBridge:umengevent(eventKey)
	
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = {eventKey}  --传参
	    local sigs = "(Ljava/lang/String;)V"  --回调函数形参签名

    	-- Toast:makeToast("调用 umengevent",2.0):show()

	    local ok,ret  = luaj.callStaticMethod(classUmengName,"sendUmengEvent",args,sigs)

	    if not ok then
	        wwlog("sendUmengEvent2Java luaj error:", ret)
	    else
	        wwlog("sendUmengEvent2Java The ret is:", ret)

	        -- Toast:makeToast("调用 sendUmengEvent2Java succ",2.0):show()
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	
        local args = { 
		    eventid = eventKey
	    }
    	local ok,ret  = luaoc.callStaticMethod(classUmengName, "eventCount", args)
    	if not ok then
    	else
    	    print("The ret is:", ret)
    	end
	end
	wwlog("LuaNativeBridge ======================= umengevent success!");
end

-- 友盟计数事件2，两参数
function LuaNativeBridge:umengevent2(eventKey, eventValue)
	
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = {eventKey, eventValue}  --传参
	    local sigs = "(Ljava/lang/String;Ljava/lang/String;)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(classUmengName,"sendUmengevent2",args,sigs)

	    if not ok then
	        wwlog("sendUmengEvent2Java luaj error:", ret)
	    else
	        wwlog("sendUmengEvent2Java The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	
        local args = { 
		    eventid = eventKey,
		    eventValue = eventValue
	    }
    	local ok,ret  = luaoc.callStaticMethod(classUmengName, "eventCount2", args)
    	if not ok then
    	else
    	    print("The ret is:", ret)
    	end
	end
	wwlog("LuaNativeBridge ======================= umengevent success!");
end

-- pay统计
-- eventType 1 充值 2 充值并且购买道具
function LuaNativeBridge:eventPay(eventType, cash, source, coin, item, amount, price)
	
	wwlog("umeng eventPay start")

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = {
		    tostring(eventKey), --支付统计上报类型
		    tostring(cash),  --真实币数量
		    tostring(source), --支付渠道
		    tostring(coin), --虚拟币数量
		    tostring(item), --道具名称
		    tostring(amount), --道具数量
		    tostring(price), --道具单价
	    }  --传参
	    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(classUmengName,"sendUmengEventPay",args,sigs)

	    if not ok then
	        wwlog("send umeng eventPay luaj error:", ret)
	    else
	        wwlog("send umeng  eventPay The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	
        local args = { 
		    eventType = eventKey, --支付统计上报类型
		    cash = cash,  --真实币数量
		    source = source, --支付渠道
		    coin = coin, --虚拟币数量
		    item = item, --道具名称
		    amount = amount, --道具数量
		    price = price, --道具单价
	    }
    	local ok,ret  = luaoc.callStaticMethod(classUmengName, "eventPay", args)
    	if not ok then
    	else
    	    print("The ret is:", ret)
    	end
	end
	wwlog("LuaNativeBridge ======================= umengevent success!");
end

--购买道具事件
function LuaNativeBridge:eventBuy(item, amount, price)
	
	wwlog("umeng eventBuy start")

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = {		    
		    tostring(item), 
		    tostring(amount),
		    tostring(price), 
		}  --传参
	    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(classUmengName,"sendUmengEventBuy",args,sigs)

	    if not ok then
	        wwlog("sendUmengEvent2Java luaj error:", ret)
	    else
	        wwlog("sendUmengEvent2Java The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	
        local args = { 
		    item = item,
		    amount = amount,
		    price = price
	    }
    	local ok,ret  = luaoc.callStaticMethod(classUmengName, "eventBuy", args)
    	if not ok then
    	else
    	    print("The ret is:", ret)
    	end
	end
	wwlog("LuaNativeBridge ======================= eventBuy success!");
end

function LuaNativeBridge:getZhuomengData(zhuomengHandler)
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		local hotupdateCB = function ()
			--oldvername, newvername, updated, lbuid
			print("hotupdateCB ret")
		end
		local args = {
			hotupdateCB,
		}
		
		if zhuomengHandler and type(zhuomengHandler)=="function" then
			args[#args] = zhuomengHandler
		end
		local sigs = "(I)V"  --回调函数形参签名
		local ok,ret = luaj.callStaticMethod(PhoneToolPath,"initHotUpdateData",args,sigs)
		if not ok then
	        cclog("[wawagame luaj] luaj error:", ret)
		else
		    cclog("[wawagame luaj] The ret is:", ret)
		end
	elseif cc.PLATFORM_OS_WINDOWS == targetPlatform then
		if zhuomengHandler and type(zhuomengHandler)=="function" then
			zhuomengHandler("1.0.0|1.0.1|false|101")
		end
	end

end

function LuaNativeBridge:addWebInterface(webcallBack)
	--webHelperPath
	wwlog("LuaNativeBridge addWebInterface start")

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		local webCB = function (arg)
			--oldvername, newvername, updated, lbuid
			print("web ret",arg)
		end
	    local args = {		    
		   webCB 
		}  --传参
		if webcallBack and type(webcallBack)=="function" then
			args[#args] = webcallBack
		end
	    local sigs = "(I)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(webHelperPath,"addWebInterface",args,sigs)

	    if not ok then
	        wwlog("addWebInterface luaj error:", ret)
	    else
	        wwlog("addWebInterface The ret is:", ret)
	    end
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
			
	end
	wwlog("LuaNativeBridge ======================= addWebInterface success!");
end

return LuaNativeBridge