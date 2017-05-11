local UserInfo_widget_cgsex = class("UserInfo_widget_cgsex", require("app.views.uibase.PopWindowBase"))
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
-- 通用界面
local csbCommonPath = "csb.hall.userinfo.UserinfoLayer_common"
-- 修改性别
local csbCgSexPath = "csb.hall.userinfo.Userinfo_widget_cgsex"
local getStr = function(flag) return i18n:get("str_userInfo", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end

function UserInfo_widget_cgsex:ctor(userInfoLayer)
    UserInfo_widget_cgsex.super.ctor(self)

    self._userInfoLayer = userInfoLayer
    self._userInfo = userInfoLayer._userInfo
    self.logTag = "UserInfo_widget_cgsex.lua"

    self:init()
end

function UserInfo_widget_cgsex:init()
    local bgCommon = require(csbCommonPath):create().root:addTo(self)
    local imgBg = bgCommon:getChildByName("Image_bg")
    local imgCntnt = imgBg:getChildByName("Image_content")
    local imgTitle = imgBg:getChildByName("Image_title")
    local txtTitle = imgTitle:getChildByName("Text_title")
    local imgBottomShadow = imgBg:getChildByName("Image_1")

--    FixUIUtils.stretchUI(bgCommon)
    FixUIUtils.setRootNodewithFIXED(bgCommon)
    FixUIUtils.stretchUI(imgBg)
--    FixUIUtils.stretchUI(imgBottomShadow)

    self:popIn(imgBg, Pop_Dir.Right)

    txtTitle:setString(getStr("title_modify_gender"))
    local changeSexLayer = require(csbCgSexPath):create().root:addTo(imgCntnt)
    local imgMale = changeSexLayer:getChildByName("Image_male"):setTouchEnabled(true)
    local imgFemale = changeSexLayer:getChildByName("Image_female"):setTouchEnabled(true)
    local cbMale = imgMale:getChildByName("CheckBox_male")
    local cbFemale = imgFemale:getChildByName("CheckBox_female")
    cbMale.opposite = cbFemale
    cbFemale.opposite = cbMale
    imgMale.cb = cbMale
    imgFemale.cb = cbFemale

    local male = tonumber(self._userInfo.Gender) == 1
    cbMale:setSelected(male):setEnabled(not male)
    cbFemale:setSelected(not male):setEnabled(male)

    imgMale:addClickEventListener(handler(self, self._btnCallback))
    imgFemale:addClickEventListener(handler(self, self._btnCallback))
    cbMale:addEventListener(handler(self, self._checkBoxCallback))
    cbFemale:addEventListener(handler(self, self._checkBoxCallback))
    local _, handle = UserInfoCfg.innerEventComponent:addEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX, function()
        -- 修改性别失败，则恢复原性别
        local datas = DataCenter:getData(UserInfoCfg.InnerEvents.MESSAGE_EVENT_MODIFY_SEX)
        if not datas.isSucc then
            cbMale:setSelected(not cbMale:isSelected()):setEnabled(not cbMale:isSelected())
            cbFemale:setSelected(not cbFemale:isSelected()):setEnabled(not cbFemale:isSelected())
        end
    end , "childLayer_changeSex")
    changeSexLayer:onNodeEvent("cleanup", function()
        UserInfoCfg.innerEventComponent:removeEventListener(handle)
    end )

end

function UserInfo_widget_cgsex:_btnCallback(node)
    if not self._userInfo then return end
    local name = node:getName()
	playSoundEffect("sound/effect/anniu")
    if name == "Image_male" then
        if not node.cb:isSelected() then
            wwlog(self.logTag, "设为男性")
            self:_checkBoxCallback(node.cb, ccui.CheckBoxEventType.selected)
        end
    elseif name == "Image_female" then
        if not node.cb:isSelected() then
            wwlog(self.logTag, "设为女性")
            self:_checkBoxCallback(node.cb, ccui.CheckBoxEventType.selected)
        end
    end
end

function UserInfo_widget_cgsex:_checkBoxCallback(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        -- selected
        --        CheckBox_female
        --        CheckBox_male
		playSoundEffect("sound/effect/anniu")
        sender:setSelected(true):setEnabled(false)
        sender.opposite:setSelected(false):setEnabled(true)
        if sender:getName() == "CheckBox_female" then
            UserProxy:modifyFemale()
        else
            UserProxy:modifyMale()
        end
    else
        -- unselected
    end
end

function UserInfo_widget_cgsex:onEnter()
    UserInfo_widget_cgsex.super.onEnter(self)


end

function UserInfo_widget_cgsex:onExit()
    UserInfo_widget_cgsex.super.onExit(self)
end


return UserInfo_widget_cgsex