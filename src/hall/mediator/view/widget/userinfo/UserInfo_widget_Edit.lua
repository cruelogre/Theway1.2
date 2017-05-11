local UserInfo_widget_Edit = class("UserInfo_widget_Edit", require("app.views.uibase.PopWindowBase"))
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
-- 通用界面
local csbCommonPath = "csb.hall.userinfo.UserinfoLayer_common"
-- 编辑
local csbEditPath = "csb.hall.userinfo.Userinfo_widget_edit"
local userData = DataCenter:getUserdataInstance()
local getStr = function(flag) return i18n:get("str_userInfo", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end

function UserInfo_widget_Edit:ctor(userInfoLayer)
    UserInfo_widget_Edit.super.ctor(self)

    self._userInfoLayer = userInfoLayer
    self._userInfo = userInfoLayer._userInfo
    self.logTag = "UserInfo_widget_Edit.lua"

    self:init()
end

function UserInfo_widget_Edit:init()
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

    txtTitle:setString(getStr("title_edit"))
    local editLayer = require(csbEditPath):create().root:addTo(imgCntnt)
    local imgCgHead = editLayer:getChildByName("Image_top"):setTouchEnabled(true)
    self.imgTop = imgCgHead
    local imgCgNick = editLayer:getChildByName("Image_nickname"):setTouchEnabled(true)
    local imgCgSex = editLayer:getChildByName("Image_sex"):setTouchEnabled(true)
    self.txtNickname = imgCgNick:getChildByName("Text_nickname"):setVisible(false)
    self.txtNickname = cc.LabelTTF:create("Nickname", "FZZhengHeiS-B-GB.ttf", 32):setAnchorPoint(cc.p(0.0, 0.5)):setColor(cc.c3b(0x3E, 0x32, 0x1C)):pos(self.txtNickname:pos()):addTo(self.txtNickname:getParent())
    self.txtSex = imgCgSex:getChildByName("Text_sex")
    self.flagSexMale = imgCgSex:getChildByName("Image_sex_0")
    self.flagSexFemale = imgCgSex:getChildByName("Image_sex_0_0")

    local iconFile = userData:getHeadIcon()
    local param = { headFile = iconFile, maskFile = "#hall_bottom_role.png", headType = 1, radius = 87.5 }

    --    local sp = WWHeadSprite:create(param)
    --    sp:setPosition(195, 120)
    --    imgCgHead:addChild(sp, 100)

    imgCgHead:addClickEventListener(handler(self, self._btnCallback))
    imgCgNick:addClickEventListener(handler(self, self._btnCallback))
    imgCgSex:addClickEventListener(handler(self, self._btnCallback))

    self:updateView( {
        Gender = tonumber(self._userInfo.Gender),
        Nickname = self._userInfo.Nickname
    } )
    self:reflashHead()

    -- 屏蔽修改头像，删除代码取消屏蔽---------start
    -- imgCgHead:setTouchEnabled(false)
    -- ccui.Helper:seekWidgetByName(imgCgHead, "Text_cghead"):setVisible(false)
    -- ccui.Helper:seekWidgetByName(imgCgHead, "Image_arrow"):setVisible(false)
    -- 屏蔽修改头像，删除代码取消屏蔽---------end
end

function UserInfo_widget_Edit:reflashHead()
    if self.imgTop then
        if self.headIcon then self.headIcon:removeFromParent(); self.headIcon = nil end
        local param = {
            headFile = userData:getHeadIcon(),
            maskFile = "guandan/head_mask.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
            headType = 1,
            radius = 87.5,
            headIconType = DataCenter:getUserdataInstance():getValueByKey("IconID"),
            userID = DataCenter:getUserdataInstance():getValueByKey("userid")
        }
        self.headIcon = WWHeadSprite:create(param):setScale(1.3):addTo(self.imgTop)
        :setPosition(self.imgTop:getContentSize().width * 0.2, self.imgTop:getContentSize().height * 0.5)
    end
end

function UserInfo_widget_Edit:updateView(data)
    if data.Nickname then
        self.txtNickname:setString(data.Nickname)
    end
    if data.Gender then
        if self.txtSex:getString() ~= tostring(data.Gender) then
            self.flagSexMale:setVisible(tonumber(data.Gender) == 1)
            self.flagSexFemale:setVisible(tonumber(data.Gender) ~= 1)
            self.txtSex:setString(getComStr(tonumber(data.Gender) == 1 and "male" or "female"))
            self:reflashHead()
        end
    end
end

function UserInfo_widget_Edit:_btnCallback(node)
    if not self._userInfo then return end
    local name = node:getName()
    playSoundEffect("sound/effect/anniu")
    if name == "Image_top" then
        wwlog(self.logTag, "修改头像")
        self._userInfoLayer:showChildLayer("changeHead")
    elseif name == "Image_nickname" then
        wwlog(self.logTag, "修改昵称")
        self._userInfoLayer:showChildLayer("changeNick")
    elseif name == "Image_sex" then
        wwlog(self.logTag, "修改性别")
        self._userInfoLayer:showChildLayer("changeSex")
    end
end

function UserInfo_widget_Edit:onEnter()
    UserInfo_widget_Edit.super.onEnter(self)
end

function UserInfo_widget_Edit:onExit()
    self.super.onExit(self)
end


return UserInfo_widget_Edit