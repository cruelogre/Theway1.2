local UserInfo_widget_cgnick = class("UserInfo_widget_cgnick", require("app.views.uibase.PopWindowBase"))
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
-- 通用界面
local csbCommonPath = "csb.hall.userinfo.UserinfoLayer_common"
-- 修改名字
local csbCgNickPath = "csb.hall.userinfo.Userinfo_widget_cgnick"
local userData = DataCenter:getUserdataInstance()
local getStr = function(flag) return i18n:get("str_userInfo", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end

function UserInfo_widget_cgnick:ctor(userInfoLayer)
    UserInfo_widget_cgnick.super.ctor(self)
    self._userInfoLayer = userInfoLayer
    self._userInfo = userInfoLayer._userInfo
    self.logTag = "UserInfo_widget_cgnick.lua"
    self:init()
end

function UserInfo_widget_cgnick:init()
    local bgCommon = require(csbCommonPath):create().root:addTo(self)
    local imgBg = bgCommon:getChildByName("Image_bg")
    local imgCntnt = imgBg:getChildByName("Image_content")
    local imgTitle = imgBg:getChildByName("Image_title")
    local txtTitle = imgTitle:getChildByName("Text_title")
    local imgBottomShadow = imgBg:getChildByName("Image_1")

    --    FixUIUtils.stretchUI(bgCommon)
    FixUIUtils.setRootNodewithFIXED(self)
    FixUIUtils.stretchUI(imgBg)
    --    FixUIUtils.stretchUI(imgBottomShadow)

    self:popIn(imgBg, Pop_Dir.Right)

    txtTitle:setString(getStr("title_modify_nick"))
    local changeNameLayer = require(csbCgNickPath):create().root:addTo(imgCntnt)
    local imgTop = changeNameLayer:getChildByName("Image_top")
    local inputName = imgTop:getChildByName("TextField_name"):onEvent(handler(self, self._textFieldCallback))
    local btnClear = imgTop:getChildByName("Button_clear")
    inputName:setString(self._userInfo.Nickname)
    btnClear.inputName = inputName
    btnClear:addClickEventListener(handler(self, self._btnCallback))

end

function UserInfo_widget_cgnick:_btnCallback(node)
    if not self._userInfo then return end
    local name = node:getName()
    playSoundEffect("sound/effect/anniu")
    if name == "Button_clear" then
        -- 清除昵称
        wwlog(self.logTag, "清除昵称")
        node.inputName:setString("")
    end
end

function UserInfo_widget_cgnick:_textFieldCallback(event)
--    wwlog(self.logTag, "输入字符:" .. event.target:getString())
    event.target:setString(subUtf8Str(event.target:getString(), 14))
    if event.name == "ATTACH_WITH_IME" then
    elseif event.name == "DETACH_WITH_IME" then
        if event.target:getName() == "TextField_name" then
            -- 修改昵称
            local oldName = userData:getValueByKey("nickname")
            local newName = event.target:getString()
            if oldName ~= newName and newName and newName ~= "" then
                --                "[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+"
                wwlog(self.logTag, "修改名字" .. newName)
                UserProxy:modifyNickname(newName)
            end
        end
    elseif event.name == "INSERT_TEXT" then
    elseif event.name == "DELETE_BACKWARD" then
    end
end

function UserInfo_widget_cgnick:onEnter()
    UserInfo_widget_cgnick.super.onEnter(self)


end

function UserInfo_widget_cgnick:onExit()
    UserInfo_widget_cgnick.super.onExit(self)
end

return UserInfo_widget_cgnick