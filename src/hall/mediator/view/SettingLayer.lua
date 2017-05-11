-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.18
-- Last: 
-- Content:  设置界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingLayer = class("SettingLayer",require("app.views.uibase.PopWindowBase"),require("packages.mvc.Mediator"))

local SettingCfg = require("hall.mediator.cfg.SettingCfg")
--[[local SettingLayer_PlayMode = require("hall.mediator.view.SettingLayer_PlayMode")
local SettingLayer_FeedBack = require("hall.mediator.view.SettingLayer_FeedBack")
local SettingLayer_About = require("hall.mediator.view.SettingLayer_About")--]]

local SettingProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SETTING)
local GameModel = require("WhippedEgg.Model.GameModel")

local Toast = require("app.views.common.Toast")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local SettingUIPercentMax = 92
local SettingUIPercentMin = 8


-- 红点配置
local _redpoint_config =
{
    -- 更新红点代码：WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "set", true)
    -- 上面的shop就是converter的key值set，true显示红点，false取消红点。
    converter =
    {
        set = "Button_checkupdate",

    },
    -- 有些红点需要作微调，
    offset =
    {
        mail = nil,
    }
}

function SettingLayer:ctor(param)
	SettingLayer.super.ctor(self)
	self:init()
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
	self.upgradeHandlers = {}
	self.redPoint = param.redPoint
	self.openUI = param.openType--进入设置界面就需要打开的界面
end

function SettingLayer:init()
	print("SettingLayer init")
	self.node = require("csb.hall.setting.settingLayer"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	

	--testing
	self:setDisCallback(function ( ... )
		-- body
		FSRegistryManager:currentFSM():trigger("back")
	end)
	
	self.imgId = self.node:getChildByName("Image_17")
	local tagImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_19")
	local oldSize = tagImg:getContentSize()
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	--Image_19
	local newSize = tagImg:getContentSize()
	self:manualFix(oldSize,newSize)
	self:popIn(self.imgId,Pop_Dir.Right)
	
	
end

function SettingLayer:registerListener()
	if HotUpdateCfg.innerEventComponent then
	local x,handler1 = HotUpdateCfg.innerEventComponent:addEventListener(HotUpdateCfg.InnerEvents.UPGRADE_NO_HOTUPDATE
			,handler(self,self.upgradeEvent),"SettingLayer.upgradeEvent")
	local _,handler2 = HotUpdateCfg.innerEventComponent:addEventListener(HotUpdateCfg.InnerEvents.UPGRADE_PACKAGE_UPDATE
			,handler(self,self.upgradeEvent),"SettingLayer.upgradeEvent")
	table.insert(self.upgradeHandlers,handler1)
	table.insert(self.upgradeHandlers,handler2)
	
	--self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
	
	end
end

function SettingLayer:unregisterListener()
	if HotUpdateCfg.innerEventComponent then
		for _,v in ipairs(self.upgradeHandlers) do
			HotUpdateCfg.innerEventComponent:removeEventListener(v)
		end
	end
	--self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
end

function SettingLayer:upgradeEvent(event)
	local msgId = event.name
	local data = event._userdata
	if msgId==HotUpdateCfg.InnerEvents.UPGRADE_NO_HOTUPDATE then --当前就是最新的版本
		Toast:makeToast(i18n:get('str_setting','setting_no_update'), 1.0):show()
	elseif msgId == HotUpdateCfg.InnerEvents.UPGRADE_PACKAGE_UPDATE then --需要整包下载
		wwlog(self.logTag,"需要整包下载")
		
		if (cc.PLATFORM_ANDROID == targetPlatform) then
			Toast:makeToast(i18n:get('str_setting','setting_no_update'), 1.0):show()
		end
		
	end
end


function SettingLayer:refreshInfo(params)

    local handleType = params[1]
    if handleType == 2 then
        -- 红点通知
        local flag, isShow = _redpoint_config.converter[params[2]], params[3]
        if flag then
            local target = ccui.Helper:seekWidgetByName(self.imgId,"Button_checkupdate")
            if target then
				target:removeChildByName("redPoint")
                if isShow then
                    -- 显示红点
					local redPoint = display.newSprite("common/red_point.png")
					target:addChild(redPoint,2)
					redPoint:setName("redPoint")
                    redPoint:setPosition(cc.p(target:getContentSize().width*0.95, target:getContentSize().height*0.92))
                end
            end
        end
    end
end

function SettingLayer:onEnter()
	-- body
	SettingLayer.super.onEnter(self)
	self:initViewData()
	self:initLocalText()
	self:registerListener()
	--self.redPoint
	self:refreshInfo({2,"set",self.redPoint})
	if self.openUI then
		performWithDelay(self,handler(self,self.openUILayer),0.1)
	end
end
function SettingLayer:onExit()
	SettingLayer.super.onExit(self)
	self:unregisterScriptHandler()
	self:unregisterListener()
	self.openUI = nil
end

function SettingLayer:openUILayer()
	--SettingCfg.openUI
	local openTag = SettingCfg.openUI[tonumber(self.openUI)]
	if openTag then
		local openWidget = ccui.Helper:seekWidgetByName(self.imgId,openTag)
		self:centerTouchListener(openWidget,ccui.TouchEventType.ended)
	end
end

function SettingLayer:initViewData()
	
	ccui.Helper:seekWidgetByName(self.imgId,"Text_currentversion"):setString(
		tostring(wwConfigData.GAME_VERSION).."."..tostring(wwConfigData.GAME_SUBVERSION))
	
	local gamedata = ww.WWGameData:getInstance()
	local top = ccui.Helper:seekWidgetByName(self.imgId,"Image_top")
	local center = ccui.Helper:seekWidgetByName(self.imgId,"Panel_center")
	local bottom = ccui.Helper:seekWidgetByName(self.imgId,"Panel_bottom")
	local sliderMusic = ccui.Helper:seekWidgetByName(top,"Slider_music")
	sliderMusic = tolua.cast(sliderMusic,"ccui.Slider")
	if sliderMusic then
		local musicpercent = gamedata:getIntegerForKey(SettingCfg.ConstData.SETTING_MUSIC_PERCENT,100)
		
		sliderMusic:setPercent(self:switchDataToUI(musicpercent))
		sliderMusic:addEventListener(handler(self,self.sliderListener))
		self:setMusicVolume(self:switchDataToUI(musicpercent))
	end
	
	local sliderSound = ccui.Helper:seekWidgetByName(top,"Slider_sound")
	sliderSound = tolua.cast(sliderSound,"ccui.Slider")
	if sliderSound then
		local soundpercent = gamedata:getIntegerForKey(SettingCfg.ConstData.SETTING_SOUND_PERCENT,100)
		
		sliderSound:setPercent(self:switchDataToUI(soundpercent))
		sliderSound:addEventListener(handler(self,self.sliderListener))
		self:setSoundVolume(self:switchDataToUI(soundpercent))
	end
	self.imgShake = ccui.Helper:seekWidgetByName(top,"Image_shake")
	self.imgShake0 = ccui.Helper:seekWidgetByName(top,"Image_shake_0")
	self.imgShake = tolua.cast(self.imgShake,"ccui.ImageView")
	if self.imgShake then
		local shakeflag = gamedata:getBoolForKey(SettingCfg.ConstData.SETTING_SHAKE_SWITCH,true)
		print("shakeflag",shakeflag)
		self.imgShake:setTag(shakeflag and 1 or -1)
		self.imgShake0:setTag(shakeflag and 1 or -1)
		self.imgShake:addTouchEventListener(handler(self,self.centerTouchListener))
		self.imgShake0:addTouchEventListener(handler(self,self.centerTouchListener))
		self.imgShake:setVisible(shakeflag)
		self.imgShake0:setVisible(not shakeflag)
		--imgShake:loadTexture(shakeflag and "hall/setting/setting_switch_on.png" or "hall/setting/setting_switch_off.png")
		
	end
	
	self.imgMusicCard = ccui.Helper:seekWidgetByName(top,"Image_musiccard")
	self.imgMusicCard0 = ccui.Helper:seekWidgetByName(top,"Image_musiccard_0")
	self.imgMusicCard = tolua.cast(self.imgMusicCard,"ccui.ImageView")
	if self.imgMusicCard then
		local cardflag = gamedata:getBoolForKey(SettingCfg.ConstData.SETTING_SOUNDCARD_SWITCH,true)
		print("cardflag",cardflag)
		self.imgMusicCard:setTag(cardflag and 1 or -1)
		self.imgMusicCard0:setTag(cardflag and 1 or -1)
		self.imgMusicCard:addTouchEventListener(handler(self,self.centerTouchListener))
		self.imgMusicCard0:addTouchEventListener(handler(self,self.centerTouchListener))
		self.imgMusicCard:setVisible(cardflag)
		self.imgMusicCard0:setVisible(not cardflag)
		--imgMusicCard:loadTexture(cardflag and "hall/setting/setting_switch_on.png" or "hall/setting/setting_switch_off.png")
	end
	
	ccui.Helper:seekWidgetByName(center,"Button_play"):addTouchEventListener(handler(self,self.centerTouchListener))
	ccui.Helper:seekWidgetByName(center,"Button_question"):addTouchEventListener(handler(self,self.centerTouchListener))
	ccui.Helper:seekWidgetByName(bottom,"Button_clearcache"):addTouchEventListener(handler(self,self.centerTouchListener))
	ccui.Helper:seekWidgetByName(bottom,"Button_checkupdate"):addTouchEventListener(handler(self,self.centerTouchListener))
	ccui.Helper:seekWidgetByName(bottom,"Button_about"):addTouchEventListener(handler(self,self.centerTouchListener))
	--ccui.Helper:seekWidgetByName(bottom,"Button_clearcache"):setBright(false)
	--ccui.Helper:seekWidgetByName(bottom,"Button_checkupdate"):setBright(false)
end
--本地化
function SettingLayer:initLocalText()
	--title
	
	ccui.Helper:seekWidgetByName(self.imgId,"Text_13"):setString(i18n:get('str_setting','setting_title'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_music"):setString(i18n:get('str_setting','setting_bg_music'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_sound"):setString(i18n:get('str_setting','setting_sound_effect'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_shake"):setString(i18n:get('str_setting','setting_shake'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_musiccard"):setString(i18n:get('str_setting','setting_card_voice'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_19"):setString(i18n:get('str_setting','setting_game_mode'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_19_0"):setString(i18n:get('str_setting','setting_feedback'))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_clearcache"):setTitleText(i18n:get('str_setting','setting_clear_cache'))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_checkupdate"):setTitleText(i18n:get('str_setting','setting_check_update'))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_about"):setTitleText(i18n:get('str_setting','setting_about_us'))
	ccui.Helper:seekWidgetByName(self.imgId,"Text_currentversion_pre"):setString(i18n:get('str_setting','setting_current_version'))
end
function SettingLayer:centerTouchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		local btn = tolua.cast(ref,"ccui.Button")
		if not btn or btn:isBright() then
			playSoundEffect("sound/effect/anniu")
		end
		
		if name=="Button_play" then
			if SettingCfg.btnMap[name] then
				UmengManager:eventCount(SettingCfg.btnMap[name].umCount)
				display.getRunningScene():addChild(require(SettingCfg.btnMap[name].layer):create(),self:getLocalZOrder()+1)
			end
			--UmengManager:eventCount("SetGamePlay")

			--display.getRunningScene():addChild(SettingLayer_PlayMode:create(),self:getLocalZOrder()+1)
			
		elseif name == "Button_question" then
			if SettingCfg.btnMap[name] then
				UmengManager:eventCount(SettingCfg.btnMap[name].umCount)
				display.getRunningScene():addChild(require(SettingCfg.btnMap[name].layer):create(),self:getLocalZOrder()+1)
			end
			--UmengManager:eventCount("SetQA")

			--display.getRunningScene():addChild(SettingLayer_FeedBack:create(),self:getLocalZOrder()+1)
		elseif name == "Button_about" then
			if SettingCfg.btnMap[name] then
				UmengManager:eventCount(SettingCfg.btnMap[name].umCount)
				display.getRunningScene():addChild(require(SettingCfg.btnMap[name].layer):create(),self:getLocalZOrder()+1)
			end
			--UmengManager:eventCount("SetAbout")

			--display.getRunningScene():addChild(SettingLayer_About:create(),self:getLocalZOrder()+1)
		elseif name == "Button_clearcache" then
			--clear cache
			UmengManager:eventCount("SetClean")

			local para = {}
			para.leftBtnlabel = i18n:get('str_common','comm_no')
			para.rightBtnlabel = i18n:get('str_common','comm_yes')
			para.singleName = tostring("SettingProxy:clearCache")
			para.rightBtnCallback = function ()
				SettingProxy:clearCache()
			end
			para.showclose = false  --是否显示关闭按钮
			--eventTable.MatchName
			para.content = i18n:get('str_setting','setting_clear_cache_tip')

			local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
	
		elseif name == "Button_checkupdate" then
			--check update
			--拉取热更数据
			--这里要先停止静默更新
			UmengManager:eventCount("SetUpdateCheck")

			SilentUpdateQueue:stopAllDownloadTask()
			
			local HotUpdateProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HOT_UPDATE)
			HotUpdateProxy:requestLuahotData(true,true)
			LoadingManager:startLoading(0.8)
		elseif name == "Image_shake" or name == "Image_musiccard" or 
			name == "Image_shake_0" or name == "Image_musiccard_0" then
			local tag = ref:getTag()
			tag = tag*-1
			ref:setTag(tag)
			--ref:loadTexture(tag>0 and "hall/setting/setting_switch_on.png" or "hall/setting/setting_switch_off.png")
			
			if name=="Image_shake" or name=="Image_shake_0" then
				self.imgShake:setVisible(tag>0)
				self.imgShake:setTag(tag)
				self.imgShake0:setVisible(tag<0)
				self.imgShake0:setTag(tag)
				ww.WWGameData:getInstance():setBoolForKey(SettingCfg.ConstData.SETTING_SHAKE_SWITCH,tag>0 and true or false)
			elseif name=="Image_musiccard" or name=="Image_musiccard_0" then

				self.imgMusicCard:setVisible(tag>0)
				self.imgMusicCard:setTag(tag)
				self.imgMusicCard0:setVisible(tag<0)
				self.imgMusicCard0:setTag(tag)
				GameModel:setSoundRegionType(tag>0 and 0 or 1)
				ww.WWGameData:getInstance():setBoolForKey(SettingCfg.ConstData.SETTING_SOUNDCARD_SWITCH,tag>0 and true or false)
			end
			
		end
	end
end

function SettingLayer:sliderListener(ref,eventType)
	
	if eventType==ccui.SliderEventType.slideBallUp then
		local p = ref:getPercent()
	
		p = math.min(p,SettingUIPercentMax)
		p = math.max(p,SettingUIPercentMin)
		ref:setPercent(p)
	
		
		local name = ref:getName()
		if name=="Slider_music" then
			self:setMusicVolume(ref:getPercent())
		elseif name== "Slider_sound" then
			self:setSoundVolume(ref:getPercent())
		end
	elseif eventType == ccui.SliderEventType.percentChanged then
		local p = ref:getPercent()
		p = math.min(p,SettingUIPercentMax)
		p = math.max(p,SettingUIPercentMin)
		ref:setPercent(p)
		local name = ref:getName()
		if name=="Slider_music" then
			self:setMusicVolume(ref:getPercent())
		elseif name== "Slider_sound" then
			self:setSoundVolume(ref:getPercent())
		end
		
	end
end

function SettingLayer:setMusicVolume(percent)
	local datapercent = self:switchUIToData(percent)
	--print("set music volume ",datapercent,percent)
	
	ww.WWGameData:getInstance():setIntegerForKey(SettingCfg.ConstData.SETTING_MUSIC_PERCENT,datapercent)
	ww.WWSoundManager:getInstance():setBackgroundMusicVolume(datapercent/100.0)
end
function SettingLayer:setSoundVolume(percent)
	local datapercent = self:switchUIToData(percent)
	--print("set sound volume ",datapercent,percent)
	ww.WWGameData:getInstance():setIntegerForKey(SettingCfg.ConstData.SETTING_SOUND_PERCENT,datapercent)
	ww.WWSoundManager:getInstance():setEffectsVolume(datapercent/100.0)
	
end
--把UI百分比转换成数据百分比
function SettingLayer:switchUIToData(percent)
	local diff = SettingUIPercentMax - SettingUIPercentMin
	return (percent - SettingUIPercentMin)*100/diff
end
--把数据百分比转换成UI百分比
function SettingLayer:switchDataToUI(percent)	
	local diff = SettingUIPercentMax - SettingUIPercentMin
	
	return percent*diff/100 + SettingUIPercentMin

end



-- 手动适配UI
function SettingLayer:manualFix(oldSize,newSize)
 
    if newSize.height / oldSize.height <= 1.1 then
		return
    end
    local panelCenter = ccui.Helper:seekWidgetByName(self.imgId, "Panel_center")
	
	panelCenter:setPositionY(newSize.height/2 - panelCenter:getContentSize().height/2)
   
end

return SettingLayer