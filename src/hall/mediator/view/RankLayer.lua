-------------------------------------------------------------------------
-- Title:        排行榜
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Modify: 2016/12/26 修改显示用户信息界面的方式，直接改成状态机触发显示
--			修改方法 tableTouched
--			删除方法 showUserInfoView
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local RankLayer = class("RankLayer", require("app.views.uibase.PopWindowBase"), require("packages.mvc.Proxy"))
local TAG = "RankLayer.lua"
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local hallFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL)
local csbMainPath = "csb.hall.rank.rank"
local csbListItemPath = "csb.hall.rank.rank_list_item"
local RankCfg = require("hall.mediator.cfg.RankCfg")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().RankProxy)
local UserProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")
-- local HallProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local request = require("hall.request.RankRequest")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local getStr = function(flag) return i18n:get("str_rank", flag) end
local getUserInfoStr = function(flag) return i18n:get("str_userInfo", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local userData = DataCenter:getUserdataInstance()
local function traverseNode(node, table)
    local name = node:getName()
    if table then
        table[name] = node
    end
    for idx, child in pairs(node:getChildren()) do
        traverseNode(child, table)
    end
end

function RankLayer:ctor()
    RankLayer.super.ctor(self)

    self.uis = { }
    -- tableView
    self._listRank = nil
    -- 数据
    self._rankInfo = nil
    -- 大小
    self._sizeListRank = nil

    self:setDisCallback( function(...)
        -- body
        FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
    end )
    self:init()
end

function RankLayer:init()
    local root = require(csbMainPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")

    traverseNode(root, self.uis)
    self:_initView()

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)
    performFunction( function()
        -- 请求排行榜
        request.requestGDRankInfo(proxy)
    end , 0.20)
end

-- 初始化界面
function RankLayer:_initView()
    -- 金币
    self.uis.gold_count:setString(ToolCom.splitNumFix(tonumber(userData:getValueByKey("GameCash")) or 0))
    -- 头像
    local param = {
        headFile = userData:getValueByKey("gender") == 1 and "guandan/head_boy.png" or "guandan/head_girl.png",
        maskFile = "",
        frameFile = "common/common_userheader_frame_userinfo.png",
        headType = 1,
        radius = 87.5,
        -- (如果是11 则是默认头像，101，是自己审核头像（网络获取）， 102是待审核头像)
        headIconType = userData:getValueByKey("IconID"),
        userID = userData:getValueByKey("userid"),
    }
    -- 头像
    WWHeadSprite:create(param):setScale(0.70):addTo(self.uis.head_node)
    -- 排行榜列表
    self._sizeListRank = { width = self.uis.list_bg:width(), height = cc.Director:getInstance():getVisibleSize().height - self.uis.img_top_com:height() -180 }
    self._listRank = cc.TableView:create(self._sizeListRank):addTo(self.uis.list_bg):offsetY(14)
    self._listRank:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listRank:setDelegate()
    self._listRank:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listRank:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._listRank:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._listRank:registerScriptHandler(handler(self, self.tableTouched), cc.TABLECELL_TOUCHED)
    self._listRank:registerScriptHandler(handler(self, self.tableCellSizeForIdx), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listRank:registerScriptHandler(handler(self, self.tableCellAtIdx), cc.TABLECELL_SIZE_AT_INDEX)
    self._listRank:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    -- 细节优化，居中。
    self.uis.head_node:posY((self._listRank:posY() + self._sizeListRank.height + self.uis.list_bg:height()) / 2)
    self.uis.Text_8:posY(self.uis.head_node:posY())
    self.uis.Image_11:posY(self.uis.head_node:posY())
end

-- 一页能显示下几条
-- local itemInOneFrame = 6.5
function RankLayer:tableCellSizeForIdx()
    return self._sizeListRank.width, 142
end

local viewHolder, tmpInfoItem, flag_rank_top3 = nil, nil, { "flag_rank_1", "flag_rank_2", "flag_rank_3" }
function RankLayer:tableCellAtIdx(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        local width, height = self:tableCellSizeForIdx(view, idx)
        cell:setContentSize( { width = width, height = height })
    end
    viewHolder = cell._viewHolder
    if not viewHolder then
        local root = require(csbListItemPath):create().root:addTo(cell):center(cell)
        local uis = { } traverseNode(root, uis)
        cell._viewHolder = uis
        viewHolder = cell._viewHolder
    end
    tmpInfoItem = self._rankInfo.rankInfo[idx + 1]
    -- 名字
    viewHolder.name:setString(tmpInfoItem.Nickname)
    -- 分
    viewHolder.Text_1:setString(ToolCom.splitNumFix(tonumber(tmpInfoItem.Score) or 0))
    -- 前3标志
    viewHolder.rank_num:setVisible(tmpInfoItem.No > 3):setString(idx + 1)
    for k, v in ipairs(flag_rank_top3) do viewHolder[v]:setVisible(k == tmpInfoItem.No) end
    -- 头像
    viewHolder.head_node:removeAllChildren()
    local param = {
        headFile = tmpInfoItem.Gender == 1 and "guandan/head_boy.png" or "guandan/head_girl.png",
        maskFile = "",
        frameFile = "common/common_userheader_frame_userinfo.png",
        headType = 1,
        radius = 87.5,
        -- (如果是11 则是默认头像，101，是自己审核头像（网络获取）， 102是待审核头像)
        headIconType = tmpInfoItem.IconID,
        userID = tmpInfoItem.UserID,
    }
    -- 头像
    WWHeadSprite:create(param):setScale(0.70):addTo(viewHolder.head_node)
    return cell
end

function RankLayer:numberOfCellsInTableView()
    return(self._rankInfo and self._rankInfo.rankInfo) and(#self._rankInfo.rankInfo) or 0
end

-- 避免连续点击发送多个请求，导致产生多个弹框
local flag_to_show = false
function RankLayer:tableTouched(tableView, cell)
    playSoundEffect("sound/effect/anniu")
    if not flag_to_show then
        flag_to_show = true
        performFunction( function() flag_to_show = false end, 1.0)
        --UserProxy:requestUserInfo(self._rankInfo.rankInfo[cell:getIdx() + 1].UserID)
		--这里触发状态机，显示玩家信息界面
		FSRegistryManager:currentFSM():trigger("userinfo",
		{parentNode = display.getRunningScene(), zorder = 4,userid = self._rankInfo.rankInfo[cell:getIdx() + 1].UserID})
    end
end

-- 个人信息弹框
function RankLayer:showUserInfoView(info)
    local userInfoView = require("app.views.uibase.PopWindowBase"):create():addTo(self)
    local node = require("csb.hall.userinfo.UserinfoLayer"):create().root:addTo(userInfoView)
    FixUIUtils.setRootNodewithFIXED(node)

    local uis = { }
    traverseNode(node, uis)
    FixUIUtils.stretchUI(uis.Image_bg)
    userInfoView:popIn(uis.Image_bg, Pop_Dir.Right)
    uis.Button_switch:setVisible(false)
    uis.hint_bind_reward:setVisible(false)
    uis.Image_edit:setVisible(false)

    -- id
    uis.Text_id:setString(getUserInfoStr("id_prefix") .. info.UserID)
    -- 性别
    if tonumber(info.Gender) == 1 then
        uis.Text_sex:setString(getUserInfoStr("sex_prefix") .. getComStr("male"))
        uis.Image_sex:loadTexture("userinfo_img_male.png", 1)
    else
        uis.Text_sex:setString(getUserInfoStr("sex_prefix") .. getComStr("female"))
        uis.Image_sex:loadTexture("userinfo_img_female.png", 1)
    end
    -- 位置
    uis.Text_location:setString(getUserInfoStr("region_prefix") ..((info.Region and info.Region ~= "") and info.Region or getUserInfoStr("unkown_region")))
    -- 名字
    uis.Text_name:setString(info.Nickname)
    uis.Text_gold:setString(ToolCom.splitNumFix(tonumber(info.GameCash)))
    uis.Text_crystal:setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))


    uis.Text_diamond:setString(ToolCom.splitNumFix(tonumber(info.Diamond)))
    uis.Text_number:setString(info.AllPlay)
    uis.Text_number_0:setString(info.Victories == "" and "0.0%" or info.Victories .. "%")
    -- 头像
    local param = {
        headFile = info.Gender == 1 and "guandan/head_boy.png" or "guandan/head_girl.png",
        maskFile = "guandan/head_mask.png",
        frameFile = "common/common_userheader_frame_userinfo.png",
        headType = 1,
        radius = 87.5,
        -- (如果是11 则是默认头像，101，是自己审核头像（网络获取）， 102是待审核头像)
        headIconType = info.IconID,
        userID = info.UserID,
    }

    WWHeadSprite:create(param):setScale(1.3):addTo(uis.Image_top)
    :setPosition(uis.Image_top:getContentSize().width * 0.15, uis.Image_top:getContentSize().height * 0.5)
end


function RankLayer:_handleProxy(event)
    if event.name == RankCfg.InnerEvents.GD_RANK_INFO then
        -- 掼蛋排行榜数据
        self._rankInfo = event._userdata
        -- 刷新列表
        self._listRank:reloadData()
        -- 我的排名
        self.uis.rank_num:setString((self._rankInfo.MyNo == 0) and getStr("not_in_rank") or self._rankInfo.MyNo)
        -- 我的数据
        self.uis.gold_count:setString(ToolCom.splitNumFix(tonumber(self._rankInfo.MyScore) or 0))
    end
end

function RankLayer:onEnter()
    RankLayer.super.onEnter(self)
    -- 排行榜响应
    RankCfg.innerEventComponent:addEventListener(RankCfg.InnerEvents.GD_RANK_INFO, handler(self, self._handleProxy))
    -- 个人详情
	--由状态机管理
--[[    self._listener = WWFacade:addCustomEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, function(event)
        -- 个人详情
        self:showUserInfoView(event._userdata[1])
    end )--]]
end

function RankLayer:onExit()
    -- 注销监听广播的句柄
    WWFacade:removeEventListener(self._listener)
    RankLayer.super.onExit(self)
end

return RankLayer