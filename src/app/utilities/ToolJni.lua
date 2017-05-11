--[[
if you want to require "app.utilities.ToolJni", make sure you are in eclipse environment, otherwise use cc.PLATFORM_OS_ANDROID instead
]]

local jniTool = { }

local target = cc.Application:getInstance():getTargetPlatform()
local luaj = require "cocos.cocos2d.luaj"

--指定java端处理数据的类
--for test, class in java not finish
local className = "com/cocos2dx/sample/LuaJavaBridgeTest/LuaJavaBridgeTest"


function jniTool.callJavaTest(a, b)
	if target == cc.PLATFORM_OS_ANDROID then
		local args = { a, b }
		local sigs = "(II)I"

		--for test, method "addTwoNumbers" in java not finish
		local ok, ret = luaj.callStaticMethod(className, "addTwoNumbers", args, sigs)
		if not ok then
			print("luaj error:", ret)
		else
			print("The ret is:", ret)
		end
	end
end


local function callbackinLua(param)
	if "success" == param then
		print("java call back success")
	end
end

-- args:参数列表,数组格式的table（{1,"2",2.0,true}）
-- retType: 返回类型（F,Z,I,Ljava/lang/String;等）
-- 例子：checkArguments({1,"2",2.0,true},"V") = ( I Ljava/lang/String; F Z)V
local function checkArguments(args, retType)
    if type(ret) ~= "string" or type(args) ~= "table" then return nil end

    local sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")" .. retType

    return table.concat(sig)
end

function jniTool.callLuabackTest()
	local args = { "callbackinLua", callbackinLua }
	local sigs = "(Ljava/lang/String;I)V"

	--for test, method "callbackLua" in java not finish
	local ok = luaj.callStaticMethod(className, "callbackLua", args, sigs)
	if not ok then
		print("call callback error")
	end
end

return jniTool

