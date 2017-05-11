local LoginSceneController = class("LoginSceneController",require("packages.mvc.Controller"))
import(".LoginEvent", "login.event.")
import(".HallEvent", "hall.event.")
import(".wwGameConst","app.config.")
import(".wwConfigData","app.config.")
import(".wwConst","app.config.")
require("app.config.wwModuleConfig")

--require("login.fsm.LoginFSRegistry")
local IPhoneTool = ww.IPhoneTool:getInstance()

function LoginSceneController:init()

	--注册大厅进入事件
	self:registerEventListener(LOGIN_SCENE_EVENTS.MAIN_ENTRY, handler(self, self.onSceneEntry))
	self:registerEventListener(LOGIN_SCENE_EVENTS.JUMP_TO_HALL,handler(self, self.jumpToHall))
	self:registerEventListener(LOGIN_SCENE_EVENTS.NET_WORK_UNABALABLE,handler(self, self.networkErrorCB))
end

function LoginSceneController:onSceneEntry(eventData)
	cclog("进入登录场景......")
	self.hasJumpOut = false
	self.loginFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_LOGIN)
	--显示背景
	self.currentSec = os.time()
	self.networkError = false
	self:getLoginMediator():showBG()
	--连接服务器  根据打开方式，判断是否自动登录
	
	--自动登录
	self:getLoginProxy():connectServer()

end


function LoginSceneController:networkErrorCB()
	print("LoginSceneController  networkErrorCB")
	self.networkError = true
end

function LoginSceneController:jumpToHall()
	local diff = os.time() - self.currentSec
	print(diff)
	if diff< 1 then
		print("太短了 在等会LoginSceneController")
		return 
	end
	if self.hasJumpOut then
		print("已经不在当前场景了LoginSceneController")
		return 
	end
	
--[[	if DataCenter:getUserdataInstance():getValueByKey("updateState") 
		and tonumber(DataCenter:getUserdataInstance():getValueByKey("updateState"))>0 then
		
		local state = self.loginFSM:currentState()
	--如果当前栈顶是按钮状态，则不切换状态了
		if state.mStateName~="UIUpdateAssetState" then 
			local param = {
			parentNode = self:getLoginMediator().scene;
			localZorder = 2;
			gameId = ModuleConfig.ModuleId.g_ChatGameID;
			moduleId=ModuleConfig.ModuleId.g_ChatGameID
			}
			self.loginFSM:trigger("updateAsset",param)
		end
	else
		FSRegistryManager:clearFSM(FSMConfig.FSM_LOGIN)
		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
	end--]]
	--跳转之前先判断是否有版本更新，主要更新大厅的lua代码和资源
	FSRegistryManager:clearFSM(FSMConfig.FSM_LOGIN)
	--进入场景的时候，加入是否登录成功的状态标志
	
	local jumpType = nil
	if IPhoneTool:isNetworkConnected() and not self.networkError then
		if not DataCenter:getUserdataInstance():getGetUserInfo() then
			jumpType = HALL_ENTERINTENT.ENTER_LOGINING
		end
	else
		jumpType = HALL_ENTERINTENT.ENTER_NETWORK_ERROR
	end
	print("jumpType",jumpType)
	WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY,jumpType)

	
	
	
end

function LoginSceneController:getLoginMediator()
	
	return self:getMediator(self:getMediatorRegistry().LOGIN_SCENE)
end

function LoginSceneController:getLoginProxy()
	return self:getProxy(self:getProxyRegistry().LOGIN_SCENE)
end
return LoginSceneController