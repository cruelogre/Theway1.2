local UserInfo_widget_cghead = class("UserInfo_widget_cghead"
, require("app.views.uibase.PopWindowBase")
, require("packages.mvc.Mediator")
)

-- 通用界面
local csbCommonPath = "csb.hall.userinfo.UserinfoLayer_common"
local LuaNativeBridge = require("app.utilities.LuaNativeBridge"):create()
-- 修改头像
local csbCgHeadPath = "csb.hall.userinfo.Userinfo_widget_cghead"
local getStr = function(flag) return i18n:get("str_userInfo", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local userData = DataCenter:getUserdataInstance()

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local Toast = require("app.views.common.Toast")

function UserInfo_widget_cghead:ctor(userInfoLayer)
    UserInfo_widget_cghead.super.ctor(self)
    self._userInfoLayer = userInfoLayer
    self._userInfo = userInfoLayer._userInfo
    self.logTag = "UserInfo_widget_cghead.lua"
    self:init()
end

function UserInfo_widget_cghead:init()
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

    txtTitle:setString(getStr("title_modify_head"))
    local chageHeadLayer = require(csbCgHeadPath):create().root:addTo(imgCntnt)
    local imgTakePic = chageHeadLayer:getChildByName("Image_takepic"):setTouchEnabled(true)
    local imgChoose = chageHeadLayer:getChildByName("Image_choose"):setTouchEnabled(true)
    --    local imgReset = chageHeadLayer:getChildByName("Image_reset"):setTouchEnabled(true)
    imgTakePic:addClickEventListener(handler(self, self._btnCallback))
    imgChoose:addClickEventListener(handler(self, self._btnCallback))
    --    imgReset:addClickEventListener(handler(self, self._btnCallback))


    local function eventCustomListener1(event)
        -- local str = "Custom event 1 received, "..event._usedata.." times"
        -- 事件通知到，C++调用Lua不能带参，所以这里，收到通知后，根据UserID规则去获取
        wwlog(self.logTag,"收到事件回调")
            if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
            or ((cc.PLATFORM_OS_IPAD == targetPlatform))
            or ((cc.PLATFORM_OS_MAC == targetPlatform))
			or cc.PLATFORM_OS_WINDOWS == targetPlatform  then
                wwlog(self.logTag, "ios 上传头像......")
                ToolCom:uploadHead(ToolCom:getHeadNativePath())
            end
    end

    local function uploadSuccess(event)
        wwlog(self.logTag, "上传头像 成功")
        Toast:makeToast(i18n:get("str_userInfo", "uploadSuccess"), 2.0):show()

        -- 修改用户中心的头像信息
        DataCenter:getUserdataInstance():setUserInfoByKey("IconID", 102)
        wwlog(self.logTag, "上传后头像 %d", DataCenter:getUserdataInstance():getValueByKey("IconID"))

        -- --清理纹理缓存
              -- cc.Director:getInstance():getTextureCache():removeTextureForKey(ToolCom:getHeadNativePath())
	
		-- 刷新头像
		cc.Director:getInstance():getEventDispatcher():dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_HEAD_NATIVE)
        -- 关闭头像界面
        self:removeFromParent()
    end

    local function uploadFailure(event)
        wwlog(self.logTag, "上传头像 失败")
        Toast:makeToast(i18n:get("str_userInfo", "uploadfailure"), 1.0):show()
    end

    self.listener1 = cc.EventListenerCustom:create(COMMON_EVENTS.C_ONAVATARCROP, eventCustomListener1)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener1, 1)

    self.listener2 = cc.EventListenerCustom:create(COMMON_EVENTS.C_UPLOAD_HEAD_SUCCESS, uploadSuccess)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener2, 1)

    self.listener3 = cc.EventListenerCustom:create(COMMON_EVENTS.C_UPLOAD_HEAD_FAIL, uploadFailure)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener3, 1)

end

function UserInfo_widget_cghead:_btnCallback(node)
    if not self._userInfo then return end
    local name = node:getName()

    local userid = DataCenter:getUserdataInstance():getValueByKey("userid")
    -- local filePath = ToolCom:getHeadNativePath()


    playSoundEffect("sound/effect/anniu")
    if name == "Image_takepic" then
        wwlog(self.logTag, "拍照")
        LuaNativeBridge:openCameraAndSavePic(userid)
        -- ww.IPhoneTool:getInstance():openCameraAndSavePic(userid)
    elseif name == "Image_choose" then
        wwlog(self.logTag, "从相册选择")
        LuaNativeBridge:openPhotoAndSavePic(userid)
        -- ww.IPhoneTool:getInstance():openPhotoAndSavePic(userid)
    elseif name == "Image_reset" then
        wwlog(self.logTag, "重置默认头像")
    end
end

function UserInfo_widget_cghead:onEnter()
    UserInfo_widget_cghead.super.onEnter(self)


end

function UserInfo_widget_cghead:onExit()
    UserInfo_widget_cghead.super.onExit(self)
end


return UserInfo_widget_cghead