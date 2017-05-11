-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.15
-- Last: 
-- Content:  中心内容区域Layer布局文件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallContentLayer_view = {}

--大小Size
HallContentLayer_view.constantUISize = 
{

}

HallContentLayer_view.UI_POS = 
{
    --掼蛋经典玩法
    {
        n="btn_hall_normal", 
        t="btn", 
        x=ww.px(666), y=ww.py(540), 
        od=2,
        tg = 2,
        res={"hall_room_normal.png","","", ccui.TextureResType.plistType} 
    },
    --牛牛
    {
        n="btn_hall_bullfight", 
        t="btn", 
        x=ww.px(1146), y=ww.py(540), 
        od=2,
        tg = 2,
        res={"hall_room_buillfight.png","","", ccui.TextureResType.plistType} 
    },
    --大奖赛
    {
        n="btn_hall_high", 
        t="btn", 
        x=ww.px(1684), y=ww.py(700), 
        od=2,
        tg = 2,
        -- res={"hall_room_high_lady.png","","", ccui.TextureResType.plistType} 
        res={"hall_room_high_title.png","","", ccui.TextureResType.plistType} 
    },
    --私人定制
    {
        n="btn_hall_personal", 
        t="btn", 
        x=ww.px(1684), y=ww.py(415), 
        od=2,
        tg = 2,
        res={"hall_room_personal.png","","", ccui.TextureResType.plistType} 
    },
}

return HallContentLayer_view