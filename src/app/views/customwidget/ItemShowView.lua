-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   diyal.yin
-- Date:     2016/09/27
-- Last:    
-- Content:  物品获取展示
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------

local ItemShowView = class("ItemShowView",require("app.views.uibase.PopWindowBase"))

--@param items 所有物品
--@param isAquire 是否获得 否则是购买
function ItemShowView:ctor(items,isAquire)
    --背景
    ItemShowView.super.ctor(self)
    self:setOpacity(200)
    print(items)
    self.items = items or {}
    print(#self.items)
	self.isAquire = isAquire
    self:initUI()
end

function ItemShowView:initUI()
   --文字
    local buyOKText = require("csb.hall.animation.Node_buyOK_text"):create()
    if not buyOKText then
        return
    end
    self.buyOKTextRoot = buyOKText["root"]
    self.buyOKTextAni = buyOKText["animation"]
	--Image_text
	if self.isAquire then
		self.buyOKTextRoot:getChildByName("Image_text"):ignoreContentAdaptWithSize(true)
		self.buyOKTextRoot:getChildByName("Image_text"):loadTexture("acquire_anim_text.png",1)
	end
	
    self.buyOKTextRoot:runAction(self.buyOKTextAni)
    self:addChild(self.buyOKTextRoot)
    self.buyOKTextRoot:setPosition(cc.p(screenSize.width/2,screenSize.height*0.68))

    self.buyOKTextAni:play("animation0",false)
    self.buyOKTextRoot:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function ( ... )
        -- body
        self:popShowItem()
    end)))

    --物品
    self.showItemRoot = {}
    self.showItemAni = {}

    for i=1,3 do
         local showItem = require("csb.hall.animation.Node_buyOK_icon"):create()
        if not showItem then
            return
        end
        table.insert(self.showItemRoot,showItem["root"])
        table.insert(self.showItemAni,showItem["animation"])

        self.showItemRoot[i]:runAction(self.showItemAni[i])
        self:addChild(self.showItemRoot[i])
        self.showItemRoot[i]:setVisible(false)
    end
end

function ItemShowView:popShowItem()
    -- body
    local function updateItem( idx,posX )
        -- body
        playSoundEffect("sound/effect/huodedaoju")
        self.showItemRoot[idx]:setVisible(true)
        local sp_icon = self.showItemRoot[idx]:getChildByName("sp_icon")
        local Text_number = self.showItemRoot[idx]:getChildByName("Text_number")
        local buy_anim_aperture = self.showItemRoot[idx]:getChildByName("buy_anim_aperture")

        local pos = cc.p(screenSize.width/2 + posX,screenSize.height*0.45)
        self.showItemRoot[idx]:setPosition(cc.p(screenSize.width/2,screenSize.height*0.45))
        self.showItemRoot[idx]:setScale(0.1)
        self.showItemRoot[idx]:runAction(cc.Spawn:create(cc.MoveTo:create(0.25,pos),
            cc.ScaleTo:create(0.25,1)))
        self.showItemAni[idx]:play("animation0",false)
        self.showItemAni[idx]:setAnimationEndCallFunc1("animation0",function ()
            self.showItemAni[idx]:play("animation1",true)
        end)

        local cellData = self.items[idx]
        local nNum = cellData.num
        if cellData.MagicID then
            local netSprite = ToolCom:createGoodsSprite(cellData.MagicID)
            sp_icon:setOpacity(0)
            sp_icon:setCascadeOpacityEnabled(false)
            sp_icon:addChild(netSprite)
            netSprite:setPosition(cc.p(sp_icon:getContentSize().width/2,sp_icon:getContentSize().height/2))
            Text_number:setString(cellData.name.."x"..nNum)
        elseif cellData.fid then
            local goodInfo = getGoodsByFid(cellData.fid)
            sp_icon:setTexture(goodInfo.src)
            sp_icon:setOpacity(255)
            Text_number:setString(goodInfo.name.."x"..nNum)
        end
    end

    local animate
    if #self.items > 0 then
        if #self.items == 1 then
            animate = updateItem(1,-1)
        elseif #self.items == 2 then
            updateItem(1,-240)
            self.showItemRoot[1]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
                -- body
                updateItem(2,240)
            end)))
        else
            updateItem(1,-360)
            self.showItemRoot[1]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
                -- body
                updateItem(2,0)
                self.showItemRoot[2]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function ( ... )
                    -- body
                    updateItem(3,360)
                    self.showItemRoot[1]:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ( ... )
                        -- body
                         for i=1,3 do
                            table.remove(self.items,1)
                        end
                        if #self.items > 0 then
                            self.showItemRoot[1]:setVisible(false)
                            self.showItemRoot[2]:setVisible(false)
                            self.showItemRoot[3]:setVisible(false)
                            self:popShowItem()
                        end
                    end)))
                end)))
            end)))
        end
    end
end

function ItemShowView:show()
    self:addTo(display.getRunningScene(),ww.topOrder)
end

return ItemShowView
