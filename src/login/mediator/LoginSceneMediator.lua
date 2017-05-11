local LoginSceneMediator = class("LoginSceneMediator",require("packages.mvc.Mediator"))

local WWAnimatePackerLua = require("packages.framebase.WWAnimatePackerLua")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--require("login.fsm.LoginFSRegistry")
function LoginSceneMediator:init()
	cclog("LoginSceneMediator init...")
		--test just show button view
	
	self.loginFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_LOGIN)
end
function LoginSceneMediator:showBG()
	self.scene = cc.Scene:create()
	
	local function BGFun()
		local bg = display.newSprite("login/login_bg.jpg")
		bg:setPosition(display.center)
		bg:setScaleY(ww.scaleY)
		self.scene:addChild(bg)
		bg:setOpacity(0)
		bg:runAction(cc.FadeIn:create(0.2))
	end
	local splashFile = "logores/splash.jpg"
	if cc.FileUtils:getInstance():isFileExist(splashFile) and
	(cc.PLATFORM_OS_ANDROID == targetPlatform
	or cc.PLATFORM_OS_WINDOWS == targetPlatform) then
		local flash = display.newSprite(splashFile)
		flash:setPosition(display.center)
		local size = flash:getContentSize()
		local visibleSize = cc.Director:getInstance():getVisibleSize()
		flash:setScaleY(visibleSize.height/size.height)
		flash:setScaleX(visibleSize.width/size.width)
		self.scene:addChild(flash)
		flash:setOpacity(0)
		flash:runAction(cc.Sequence:create(cc.FadeIn:create(0.1),cc.DelayTime:create(1.0),cc.FadeTo:create(0.2,20),cc.CallFunc:create(BGFun),cc.RemoveSelf:create(true)))
	else
		BGFun()
	end
	
	
	self.loginFSM:onEntry(self.scene)

	
	self.scene:runAction(cc.Sequence:create(
	cc.DelayTime:create(2.5),
	cc.CallFunc:create(handler(self,self.delayGo))
		)
	)
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.scene)
    else
        cc.Director:getInstance():runWithScene(self.scene)
    end
	
end
function LoginSceneMediator:delayGo()
	print("LoginSceneMediator  delayGo")
	LoadingManager:endLoading()
	WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.JUMP_TO_HALL)
end


return LoginSceneMediator