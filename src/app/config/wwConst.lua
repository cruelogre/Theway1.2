local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--固定不变动的配置，热更资源的时候后台不要传这个文件，一个渠道 sp op 固定，不通过热更改变
cc.exports.wwConst = {
    CLIENTNAME = "小新掼蛋";
    OP = 20;
    SP = 6666;--  6000
	
	CATEGORY_ID = "guandan"; --帮助信息分类ID
	
	MODULE_CONST = function ()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
		or ((cc.PLATFORM_OS_IPAD == targetPlatform))
		or ((cc.PLATFORM_OS_MAC == targetPlatform)) then
			return "Guandan_ios"
		else
			return "Guandan"
		end
	end;
}
