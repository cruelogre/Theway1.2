-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.15
-- Last: 
-- Content:  大厅底部Layer布局文件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallTopLayer_view = {}

--大小Size
HallTopLayer_view.constantUISize = 
{
    -- ['inputSize'] = cc.size(211, 64), --输入框大小
}

HallTopLayer_view.UI_POS = 
{
    --大厅底部BG
    {
        n="sp_hall_bottom_bg",  
        t="sp", 
        x=ww.px(960), y=ww.py(75),
        od=1, 
        res="#hall_bottom_bg.png" 
    },
    --头像
    -- {
    --     n="sp_hall_bottom_role",  
    --     t="sp", 
    --     x=ww.px(132), y=ww.py(87.5),
    --     od=1, 
    --     res="#hall_bottom_role.png" 
    -- },
    {
        n="btn_hall_bottom_role", 
        t="btn", 
        x=ww.px(132), y=ww.py(87.5),
        od=1,
        tg = 2,
        res={"hall_bottom_role.png","hall_bottom_role.png","", ccui.TextureResType.plistType}
    },
    --名称
    {
        n="txt_username", 
        t="txt", 
        x=ww.px(410), y=ww.py(100), 
        arc={0.5, 0.5}, 
        od=1, 
        align = cc.TEXT_ALIGNMENT_LEFT,
        color=ConvertHex2RGBTab('000000'),
        rect={300},
        size=42,
        txt="蛙蛙游戏"
    },
    --v图标
    -- {
    --     n="sp_hall_bottom_v",  
    --     t="sp", 
    --     x=ww.px(508), y=ww.py(100),
    --     od=1, 
    --     res="#hall_bottom_vip.png" 
    -- },
    --金币
    {
        n="btn_hall_gold", 
        t="btn", 
        x=ww.px(365), y=ww.py(33),
        od=1,
        tg = 2,
        res={"hall_bottom_moneybg.png","hall_bottom_moneybg.png","", ccui.TextureResType.plistType}
    },
    {
        n="sp_hall_bottom_gold",  
        t="sp", 
        x=ww.px(10), y=ww.py(20.5),
        od=1, 
        parent="btn_hall_gold",
        res="common/common_gold.png" 
    },
    {
        n="txt_gold", 
        t="txt", 
        x=ww.px(103), y=ww.py(20.5), 
        arc={0.5, 0.5}, 
        od=1, 
        color=ConvertHex2RGBTab('ffffff'),
        size=28,
        parent="btn_hall_gold",
        txt="0"
    },
    --钻石
    {
        n="btn_hall_diamond", 
        t="btn", 
        x=ww.px(596), y=ww.py(33),
        od=1,
        tg = 2,
        res={"hall_bottom_moneybg.png","hall_bottom_moneybg.png","", ccui.TextureResType.plistType}
    },
    {
        n="sp_hall_bottom_diamond",  
        t="sp", 
        x=ww.px(10), y=ww.py(20.5),
        od=1, 
        parent="btn_hall_diamond",
        res="common/common_diamond.png" 
    },
    {
        n="txt_diamond", 
        t="txt", 
        x=ww.px(103), y=ww.py(20.5), 
        arc={0.5, 0.5}, 
        od=1, 
        color=ConvertHex2RGBTab('ffffff'),
        size=28,
        parent="btn_hall_diamond",
        txt="0"
    },
    --商店按钮
    {
        n="btn_hall_shop", 
        t="btn", 
        x=ww.px(870), y=ww.py(85), 
        od=1,
        tg = 2,
        res={"hall_bottom_shop.png","","", ccui.TextureResType.plistType} 
    },
    --活动按钮
    {
        n="btn_hall_activity", 
        t="btn", 
        x=ww.px(1086), y=ww.py(85), 
        od=1,
        tg = 3,
        res={"hall_bottom_activity.png","","", ccui.TextureResType.plistType} 
    },
    --任务按钮
    {
        n="btn_hall_task", 
        t="btn", 
        x=ww.px(1314), y=ww.py(85), 
        od=1,
        tg = 4,
        res={"hall_bottom_task.png","","", ccui.TextureResType.plistType} 
    },
    --兑换按钮
    {
        n="btn_hall_exchange", 
        t="btn", 
        x=ww.px(1524), y=ww.py(85), 
        od=1,
        tg = 5,
        res={"hall_bottom_exchange.png","","", ccui.TextureResType.plistType} 
    },
    --排行按钮
    {
        n="btn_hall_rank", 
        t="btn", 
        x=ww.px(1756), y=ww.py(85), 
        od=1,
        tg = 6,
        res={"hall_bottom_rank.png","","", ccui.TextureResType.plistType} 
    }
}

return HallTopLayer_view