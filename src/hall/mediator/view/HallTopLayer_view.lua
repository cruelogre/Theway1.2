-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.15
-- Last: 
-- Content:  顶部Layer布局文件
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
	--大厅Title
	{
	    n="sp_hall_title_bg",  
	    t="sp", 
	    x=ww.px(960), y=ww.py(1020),
	    od=1, 
	    res="#hall_title_bg.png" 
	},
	--大厅Title name
	{
	    n="sp_hall_title_name",  
	    t="sp", 
	    -- parent="sp_hall_title_bg",
	    x=ww.px(960), y=ww.py(1020),
	    od=2, 
	    res="logores/hall_title_name.png" 
	},
    --设置按钮
    {
        n="btn_hall_set", 
        t="btn", 
        x=ww.px(128), y=ww.py(1023), 
        od=1,
        tg = 2,
        res={"hall_set.png","","", ccui.TextureResType.plistType} 
    },
    --邮件按钮
    {
        n="btn_hall_mail", 
        t="btn", 
        x=ww.px(286), y=ww.py(1023), 
        od=1,
        tg = 2,
        res={"hall_mail.png","","", ccui.TextureResType.plistType} 
    },
    --签到按钮
    {
        n="btn_hall_sign", 
        t="btn", 
        x=ww.px(436), y=ww.py(1023), 
        od=1,
        tg = 2,
        res={"hall_sign.png","","", ccui.TextureResType.plistType} 
    },
    --背包按钮
    {
        n="btn_hall_bag", 
        t="btn", 
        x=ww.px(1396), y=ww.py(1023), 
        od=1,
        tg = 2,
        res={"hall_bag.png","","", ccui.TextureResType.plistType} 
    },
    --首充按钮
    {
        n="btn_hall_firstcharge", 
        t="btn", 
        x=ww.px(1592), y=ww.py(1003), 
        od=1,
        tg = 2,
        res={"hall_firstcharge_bg.png","","", ccui.TextureResType.plistType} 
    },
    --娱乐场按钮
    {
        n="btn_hall_amusement", 
        t="btn", 
        x=ww.px(1814), y=ww.py(985), 
        od=1,
        tg = 2,
        res={"hall_amusement.png","","", ccui.TextureResType.plistType} 
    },
    {
        n="sp_hall_amusement_label",  
        t="sp", 
        -- x=ww.px(107.5), y=ww.py(107.5),
        x=ww.px(1814), y=ww.py(985), 
        od=1, 
        -- parent="btn_hall_amusement",
        res="#hall_amusement_label.png" 
    },
}

return HallTopLayer_view