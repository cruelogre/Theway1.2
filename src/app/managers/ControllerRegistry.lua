--[[
	Controller控制器注册表
	1、用于ControllerManager对各个Controller进行实例化、管理以及查询之用
	2、表由键值对组成，
		key - controller索引标记，
		value - 用于require的参数，进行实例化操作(用户自己永远不要自己实例化)
--]]

local registry = {
	-- SOUND				= "app.controller.Toolkits.SoundController"; -- 游戏声音控制相关Controller
	--AUCTION_SCENE 		= "app.controller.AuctionScene.AuctionSceneController";

	--------------for TestCase---------------------
	-- EXAMPLE				= "app.controller.TestCase.ExampleController";
	-- NET_TEST			= "app.controller.TestCase.NetTestController";
}

return registry