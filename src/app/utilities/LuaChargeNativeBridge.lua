-------------------------------------------------------------------------
-- Desc:    充值接口调用
-- Author:  diyal.yin
-- Date:    2016.09.13
-- Last:
-- Notice:  每个接口都要实现跨平台判断
-- Content:  
--   2016.09.13 diyal.yin 新建文件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local LuaChargeNativeBridge = class("LuaChargeNativeBridge")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local luaj
local luaoc

local className = "com/ww/platform/utils/ChargeUtils";
local PhoneToolPath ="com/ww/platform/utils/PhoneTool";

function LuaChargeNativeBridge:ctor()
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
将Json序列化成ChargeMenuInfoEntity
@parem orderId 订单ID
@parem jsonString 
@parem chargeReportStateCallBack  充值结果接口的数据回调函数
@parem chargeStateCallBack        充值接口状态回调函数  24
@parem payState2Lua		          Andrioid端状态回调到底层C++  29
--]]
function LuaChargeNativeBridge:callNativeChargeInfo(orderId, 
													jsonString, 
													chargeReportStateCallBack,
													chargeStateCallBack,
													payState2Lua)
	--local state = 0
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = { 
		    orderId, --orderId
		    jsonString, --jsonString
		    chargeReportStateCallBack,
		    chargeStateCallBack,
		    payState2Lua,
	    }  --传参
	    --local sigs = "(Ljava/lang/String;Ljava/lang/String;)I"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(className,"nativeChargeMenuInfo",args)

	    if not ok then
	        cclog("[wawagame luaj] luaj error:", ret)
	    else
	        cclog("[wawagame luaj] The ret is:", ret)
	    end
	    --state = ret;
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    		wwlog(tostring(DataCenter:getUserdataInstance():getValueByKey("userid")))
    		wwlog(tostring(DataCenter:getUserdataInstance():getValueByKey("nickname")))

	        local args = {
	        				userid = tostring(DataCenter:getUserdataInstance():getValueByKey("userid")),
	    				    orderId = orderId,
	    				    jsonString = jsonString,
	    				    chargeReportStateCallBack = chargeReportStateCallBack,
	    				    chargeStateCallBack = chargeStateCallBack,
	    				    payState2Lua = payState2Lua,
	    			     }
	        local luaoc = require "cocos.cocos2d.luaoc"
	        local className = "LuaChargeObjectCBridge"
	        local ok,ret  = luaoc.callStaticMethod(className,"requestOrderid", args)
	        cclog("[wawagame luaj] luaj callNativeChargeInfo ios:")
	        if not ok then
	        else
	            print("The ret is:", ret)
        	end
	
		--return state
	end
end

--[[
	将新短信返回的消息给java
	@parem  isfast   是否是快充
	@parem  resultjson 新短信对应消息的json
	@parem  menujson   充值菜单对应的json


--]]
function LuaChargeNativeBridge:callNativenMessage_SMSCommandResp(isfast,
																 resultjson,
																 menujson,
																 chargeReportStateCallBack,
																 chargeStateCallBack,
																 payState2Lua)
	
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
	    local args = { 
		    isfast, --orderId
		    resultjson,
		    menujson, --jsonString
		    chargeReportStateCallBack,
		    chargeStateCallBack,
		    payState2Lua,
		    
	    }  --传参
	    local sigs = "(ILjava/lang/String;Ljava/lang/String;III)V"  --回调函数形参签名

	    local ok,ret  = luaj.callStaticMethod(className,"nMessage_SMSCommandResp",args,sigs)

	    if not ok then
	        cclog("[wawagame luaj] luaj error:", ret)
	    else
	        cclog("[wawagame luaj] The ret is:", ret)
	    end
	    
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
    	--TODO Add iOS native interface
	end
		
end

return LuaChargeNativeBridge