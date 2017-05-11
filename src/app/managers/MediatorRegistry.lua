--[[
	Mediator中介器注册表
	1、用于MediatorManager对各个Mediator进行实例化、管理以及查询之用
	2、表由键值对组成，
		key - controller索引标记，
		value - 用于require的参数，进行实例化操作(用户自己永远不要自己实例化)
--]]

local registry = {
	-- SCENE 				= "app.mediator.Toolkits.SceneMediator"; -- 游戏中场景切换与管理相关Mediator
	--AUCTION_SCENE 		= "app.mediator.AuctionScene.AuctionSceneMediator";

	--------------for TestCase---------------------
	-- EXAMPLE				= "app.mediator.TestCase.ExampleMediator";
	-- SOUND_TEST			= "app.mediator.TestCase.SoundTestMediator";
	-- TIMER_TEST			= "app.mediator.TestCase.TimerTestMediator";
	-- SCENE_TEST			= "app.mediator.TestCase.SceneTestMediator";
	-- WWAUDIO_COMPONENT_TEST = 'app.mediator.TestCase.WWAudioComponentTestMediator';
	-- WWTIMER_COMPONENT_TEST = "app.mediator.TestCase.WWTimerComponentTestMediator";
}

return registry