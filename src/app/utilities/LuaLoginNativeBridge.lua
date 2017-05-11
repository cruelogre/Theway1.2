-------------------------------------------------------------------------
-- Desc:    登录接口调用
-- Author:
-- Date:    2016.12.15
-- Last:
-- Notice:  每个接口都要实现跨平台判断
-- Content:
--
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local LuaLoginNativeBridge = class("LuaLoginNativeBridge")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local Toast = require("app.views.common.Toast")
local luaj
local luaoc

local className = "com/ww/platform/utils/LoginUtil";

function LuaLoginNativeBridge:ctor()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        luaj = require "cocos.cocos2d.luaj"
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform)
        or((cc.PLATFORM_OS_IPAD == targetPlatform))
        or((cc.PLATFORM_OS_MAC == targetPlatform)) then
        -- TODO Add iOS native interface
        luaoc = require "cocos.cocos2d.luaoc"
    end
end


--[[
调用sdk登录的方法
@parem   loginsuccess 登录成功的functionid
@parem   loginfailed  登录失败的functionid
@parem   loginlocal   本地登录的functionid(没有第三方sdk登录)

]]
function LuaLoginNativeBridge:callNativeLogin(loginsuccess,
        loginfailed,
        loginlocal)
    -- local state = 0
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {
            loginsuccess,
            loginfailed,
            loginlocal
        }
        -- 传参
        -- local sigs = "(Ljava/lang/String;Ljava/lang/String;)I"  --回调函数形参签名

        local ok, ret = luaj.callStaticMethod(className, "LoginSdk", args)

        if not ok then
            wwlog("[wawagame luaj] luaj login error:", ret)
        else
            wwlog("[wawagame luaj] luaj login success The ret is:", ret)
        end
        -- state = ret;
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform)
        or((cc.PLATFORM_OS_IPAD == targetPlatform))
        or((cc.PLATFORM_OS_MAC == targetPlatform)) then
         loginlocal()
        -- local args = {
        -- 				loginsuccess = loginsuccess,
        --     loginfailed = loginfailed,
        --     }
        -- local luaoc = require "cocos.cocos2d.luaoc"
        -- local className = "LuaChargeObjectCBridge"
        -- local ok,ret  = luaoc.callStaticMethod(className,"requestOrderid", args)
        -- wwlog("[wawagame luaj] luaj callNativeChargeInfo ios:")
        -- if not ok then
        -- else
        --     print("The ret is:", ret)
        -- end

        -- return state
    else
        -- 平台登录
        loginlocal()
    end
end


--[[
调用sdk切换账号的方法
@parem   loginsuccess 登录成功的functionid
@parem   loginfailed  登录失败的functionid
@parem   loginlocal   本地登录的functionid（没有第三方sdk登录）
]]
function LuaLoginNativeBridge:callNativeSwitchAccount(loginsuccess,
        loginfailed,
        loginlocal)
    -- local state = 0
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {
            loginsuccess,
            loginfailed,
            loginlocal,
        }
        -- 传参
        -- local sigs = "(Ljava/lang/String;Ljava/lang/String;)I"  --回调函数形参签名

        local ok, ret = luaj.callStaticMethod(className, "SwitchAccount", args)

        if not ok then
            wwlog("[wawagame luaj] luaj switchaccount error:", ret)
        else
            wwlog("[wawagame luaj] switchaccount success The ret is:", ret)
        end
        -- state = ret;
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform)
        or((cc.PLATFORM_OS_IPAD == targetPlatform))
        or((cc.PLATFORM_OS_MAC == targetPlatform)) then
         loginlocal()
        -- local args = {
        -- 				loginsuccess = loginsuccess,
        --     loginfailed = loginfailed,
        --     }
        -- local luaoc = require "cocos.cocos2d.luaoc"
        -- local className = "LuaChargeObjectCBridge"
        -- local ok,ret  = luaoc.callStaticMethod(className,"requestOrderid", args)
        -- wwlog("[wawagame luaj] luaj callNativeChargeInfo ios:")
        -- if not ok then
        -- else
        --     print("The ret is:", ret)
        -- end

        -- return state
    else
        -- 非第三方登录情况
        loginlocal()
    end
end



--[[
调用sdk退出的方法
@parem   loginsuccess 登录成功的functionid
@parem   loginfailed  登录失败的functionid
@parem   logoutlocal  没有第三方sdk退出调用斗地主本身的退出方法
]]
function LuaLoginNativeBridge:callNativeLogout(logoutsuccess,
        logoutfailed,
        logoutlocal)
    -- local state = 0
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {
            logoutsuccess,
            logoutfailed,
            logoutlocal,
        }
        -- 传参
        -- local sigs = "(Ljava/lang/String;Ljava/lang/String;)I"  --回调函数形参签名

        local ok, ret = luaj.callStaticMethod(className, "Logout", args)

        if not ok then
            wwlog("[wawagame luaj] luaj logout error:", ret)
        else
            wwlog("[wawagame luaj] logout success The ret is:", ret)
        end
        -- state = ret;
    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform)
        or((cc.PLATFORM_OS_IPAD == targetPlatform))
        or((cc.PLATFORM_OS_MAC == targetPlatform)) then
        logoutlocal()
        -- local args = {
        -- 				loginsuccess = loginsuccess,
        --     loginfailed = loginfailed,
        --     }
        -- local luaoc = require "cocos.cocos2d.luaoc"
        -- local className = "LuaChargeObjectCBridge"
        -- local ok,ret  = luaoc.callStaticMethod(className,"requestOrderid", args)
        -- wwlog("[wawagame luaj] luaj callNativeChargeInfo ios:")
        -- if not ok then
        -- else
        --     print("The ret is:", ret)
        -- end

        -- return state
    else
        -- 非第三方登录情况
        logoutlocal()
    end
end

return LuaLoginNativeBridge