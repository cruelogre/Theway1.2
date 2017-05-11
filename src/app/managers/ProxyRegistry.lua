--[[
	Proxy委托器注册表
	1、用于ProxyManager对各个Proxy进行实例化、管理以及查询之用
	2、表由键值对组成，
		key - controller索引标记，
		value - 用于require的参数，进行实例化操作(用户自己永远不要自己实例化)
--]]
local registry = {
	-- TIMER				= "app.proxy.Toolkits.TimerProxy"; 	-- 游戏中的定时器模块
	-- SOUND				= "app.proxy.Toolkits.SoundProxy"; 	-- 游戏声音控制相关Proxy	
	--AUCTION_SCENE 		= "app.proxy.AuctionScene.AuctionSceneProxy";
	-- HELP_API			= "app.proxy.Toolkits.HelperAPIProxy";	-- 请求获取帮助信息
	NET_WORK			= "app.proxy.global.NetWorkProxy";
	HOT_UPDATE			= "app.proxy.global.HotUpdateProxy";
	--------------for TestCase---------------------
	-- EXAMPLE				= "app.proxy.TestCase.ExampleProxy";
	-- NET_TEST			= "app.proxy.TestCase.NetTestProxy";
}

return registry