
cc.exports.clearccExports = function()
	
	FSRegistryManager:clearFSM()
	SilentUpdateQueue:finalizer()
	ControllerMgr:finalizer()
	MediatorMgr:finalizer()
	ProxyMgr:finalizer()
	WWFacade:finalizer()
	RoomChatManager:finalizer()
	TaskManager:finalizer()
	
end
--这里重新引入
cc.exports.requireExport = function ()
	local exportsTable = {
		
		"app.managers.ControllerManager",
		"app.managers.MediatorManager",
		"app.managers.ProxyManager",
		"app.managers.WWFacade",
		
		"app.data.DataCenter",
		
		"app.config.wwCsvCfg",
		
		"app.utilities.UIFactory",
		--"app.utilities.UmengManager",
		"app.utilities.ToolMd5",
		
		"app.views.common.LoadingManager",
		
		"app.hotupdate.SilentUpdateQueue",
		
		"packages.statebase.FSRegistryManager",
		"packages.framebase.FixUIUtils",
		"packages.framebase.i18nUtils",
		"packages.framebase.NetWorkBridge",
		"packages.framebase.WWAnimatePackerLua",
		"packages.framebase.WWAsynResLoader",
		"packages.framebase.WWNetAdapter",
		
		"WhippedEgg.util.RoomChatManager",
		"WhippedEgg.util.ChatAnimatorFactory",
		
		"hall.data.TaskManager",
		"hall.data.TaskFactory",
		
	}
	for _,v in ipairs(exportsTable) do
		require(v)
	end
	
end
cc.exports.setNilExports = function()
	
	
	--状态机清空
	FSRegistryManager = nil
	--控制器清空
	ControllerMgr = nil
	--视图管理器清空
	MediatorMgr = nil
	--委托管理器清空
	ProxyMgr = nil
	--事件派发清空
	WWFacade = nil
	--网络适配器清空
	WWNetAdapter = nil
	--网桥清空
	NetWorkBridge = nil
	--
	WWAnimatePackerLua = nil
	--资源加载器清空
	WWAsynResLoader = nil
	--UI适配器清空
	FixUIUtils = nil

	--缓存中心清空
	DataCenter = nil
	
	--GameManageFactory = nil
	PromotionGameManage = nil
	RandomGameManage = nil
	RcirclesGameManage = nil
	GameModel = nil
	--动画管理器清空
	GDAnimator = nil
	
	wwCsvCfg = nil
	cjson = nil
	md5 = nil
	UIFactory = nil
	
	--UmengManager = nil
	
	LoadingManager = nil
	
	i18n = nil
	--静默下载队列
	SilentUpdateQueue = nil
	--动画播放器
	ChatAnimatorFactory = nil
	--房间聊天管理器
	RoomChatManager = nil
	
	TaskManager = nil
	
	TaskFactory = nil
end
