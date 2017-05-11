-----------------------------------------
-- comment:
--      例子：
--        --斗地主，UI控件的一些样式
--        local DDZ_StyleUIBean =
--        {
--             DDZ_BtnTest =
--            {
--                [gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Btn,
--                [gUIBeanStyleConfField.KeyBtn_Normal] = "GameScene/button/green.png",
--                [gUIBeanStyleConfField.KeyBtn_Selected] = "GameScene/button/red.png",
--                [gUIBeanStyleConfField.KeyBtn_Disabled] = "GameScene/button/red.png",
--                [gUIBeanStyleConfField.KeyBtn_ClickEffect] = nil,
--                [gUIBeanStyleConfField.KeyAnchorP] = cc.p(0.5,0.5)
--            },
--            DDZ_CbTest =
--            {
--                [gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Checkbox,
--                -- 未选择时的normal状态
--                [gUIBeanStyleConfField.KeyCb_Bg] = "test/check_box_normal.png",
--                -- 未选择时的selected状态
--                [gUIBeanStyleConfField.KeyCb_BgSelected] = "test/check_box_normal_press.png",
--                -- 未选择时候的disabled状态
--                [gUIBeanStyleConfField.KeyCb_BgDisabled] = "test/check_box_normal_disable.png",
--                -- 选择时的normal状态
--                [gUIBeanStyleConfField.KeyCb_Crs] = "test/check_box_active.png",
--                -- 选择时的disabled状态
--                [gUIBeanStyleConfField.KeyCb_FrntCrsDisabled] = "test/check_box_active_disable.png",
--                [gUIBeanStyleConfField.KeyAnchorP] = cc.p(0.5,0.5),
--            },
--            DDZ_TestTTF =
--            {
--                [gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label,
--                [gUIBeanStyleConfField.KeyLbl_Type] = gUIBeanConstant.Label_TTF,
--                [gUIBeanStyleConfField.KeyLbl_TTFConf] =
--                {
--                    fontFilePath = "test/arial.ttf",
--                    fontSize = 40,
--                    glyphs = cc.GLYPHCOLLECTION_DYNAMIC,
--                    customGlyphs = nil,
--                    distanceFieldEnabled = true
--                },
--                [gUIBeanStyleConfField.KeyLbl_TxtClr] = cc.c4b(255,255,255,255),
--                [gUIBeanStyleConfField.KeyLbl_VAlgn] = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM,
--                [gUIBeanStyleConfField.KeyLbl_HAlgn] = cc.TEXT_ALIGNMENT_CENTER,
--                [gUIBeanStyleConfField.KeyLbl_Dimens] =
--                {
--                    width = 500.0,
--                    height = 100.0
--                },
--                [gUIBeanStyleConfField.KeyLbl_MaxLineW] = 120.0,
--                [gUIBeanStyleConfField.KeyLbl_ClipMargin] = true,
--                [gUIBeanStyleConfField.KeyLbl_LineHeight] = 50.0,
--                [gUIBeanStyleConfField.KeyLbl_LineBreakWithOutSpace] = true,
--                [gUIBeanStyleConfField.KeyAnchorP] = cc.p(0.5,0.5),
--                [gUIBeanStyleConfField.KeyOpacity] = 200,
--                [gUIBeanStyleConfField.KeyLbl_OutLineClr] = cc.c4b(255,0,255,255),
--                [gUIBeanStyleConfField.KeyLbl_OutLineSize] = 1,
--                [gUIBeanStyleConfField.KeyLbl_ShdwClr] = cc.c4b(255,0,255,255),
--                [gUIBeanStyleConfField.KeyLbl_ShdwOffset] = cc.size(3,3),
--                [gUIBeanStyleConfField.KeyLbl_GlowClr] = cc.c4b(255,255,255,255)
--            },
--            DDZ_TestCharMap =
--            {
--                [gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label,
--                [gUIBeanStyleConfField.KeyLbl_Type] = gUIBeanConstant.Label_CharMap,
--                [gUIBeanStyleConfField.KeyLbl_CharMap] = "test/test_charmap.png",
--                [gUIBeanStyleConfField.KeyLbl_ItemW] = 48,
--                [gUIBeanStyleConfField.KeyLbl_ItemH] = 64,
--                [gUIBeanStyleConfField.KeyLbl_Strt] = 32,
--                [gUIBeanStyleConfField.KeyAnchorP] = cc.p(0.5,0.5),
--                [gUIBeanStyleConfField.KeyOpacity] = 200
--            },
--            DDZ_TestBMFnt =
--            {
--                [gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label,
--                [gUIBeanStyleConfField.KeyLbl_Type] = gUIBeanConstant.Label_BMFnt,
--                [gUIBeanStyleConfField.KeyLbl_BMFnt] = "test/bitmapFontTest2.fnt",
--                [gUIBeanStyleConfField.KeyLbl_FntSize] = 24,
--                [gUIBeanStyleConfField.KeyLbl_TxtClr] = cc.c4b(255,255,255,255),
--                [gUIBeanStyleConfField.KeyAnchorP] = cc.p(0.5,0.5),
--            },
--            DDZ_TestSysFont =
--            {
--                [gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label,
--                [gUIBeanStyleConfField.KeyLbl_Type] = gUIBeanConstant.Label_SysFnt,
--                [gUIBeanStyleConfField.KeyLbl_SysFnt] = "arial",
--                -- [gUIBeanStyleConfField.KeyLbl_SysFnt] = "Helvetica",
--                [gUIBeanStyleConfField.KeyLbl_SysFnt] = "Marker Felt",
--                [gUIBeanStyleConfField.KeyLbl_FntSize] = 30,
--                [gUIBeanStyleConfField.KeyLbl_TxtClr] = cc.c4b(255,255,0,255),
--                [gUIBeanStyleConfField.KeyAnchorP] = cc.p(0.5,0.5),
--            }
--      }
--      --保存到全部表中
--      require("app.utilities.StyleUIMgr").load(DDZ_StyleUIBean)
--      StyleBtn，StyleCheckBox，Stylelabel快速创建...
--      --从全局表中清除相关样式
--      require("app.utilities.StyleUIMgr").unload(DDZ_StyleUIBean)
-- author: Jackie刘龙
-----------------------------------------
local StyleUIMgr = { }

-- StyleUI控件的一些常量
cc.exports.gUIBeanConstant = {
    -- 控件类型
    Label = "Label",
    -- 控件类型
    Btn = "Btn",
    -- 控件类型
    Checkbox = "Checkbox",
    -- 控件Label类型
    Label_TTF = "TTF",
    -- 控件Label类型
    Label_BMFnt = "BMFnt",
    -- 控件Label类型
    Label_CharMap = "CharMap",
    -- 控件Label类型
    Label_SysFnt = "SysFnt",
    LINE = "######################"
}

-- UI控件的样式配置table中每个元素可能包含的key
cc.exports.gUIBeanStyleConfField = {
    -- 控件类型，最好加上
    KeyType = "BeanType",
    KeyAnchorP = "AnchorPoint",
    KeyOpacity = "Opacity",
    -----------Btn的样式配置table中每个元素中可能包含的key
    KeyBtn_Normal = "btnNormal",
    KeyBtn_Selected = "btnSelected",
    -- 可选
    KeyBtn_Disabled = "btnDisabled",
    -- 点击音效，可选
    KeyBtn_ClickEffect = "btnClickEffect",
    -----------Checkbox的样式配置table中每个元素中可能包含的key
    -- 未选择时的normal状态
    KeyCb_Bg = "CbBg",
    -- 未选择时的selected状态
    KeyCb_BgSelected = "CbBgSelected",
    -- 未选择时候的disabled状态
    KeyCb_BgDisabled = "CbBgDisabled",
    -- 选择时的normal状态
    KeyCb_Crs = "cross",
    -- 选择时的disabled状态，可选
    KeyCb_FrntCrsDisabled = "CbFcDisabled",
    -- 点击音效，可选
    KeyCb_ClickEffect = "CbclickEffect",
    -----------Label的样式配置table中每个元素中可能包含的key
    -- 决定了文本的显示方式（createWithTTF，createWithBMFnt，createWithCharMap，createWithSystemFont）
    KeyLbl_Type = "LblType",
    -- 以下key对应的值根据LblType来选择性使用
    -- createWithTTF需要用到的配置
    KeyLbl_TTFConf = "LblTTFConf",
    -- createWithBMFnt需要用到的字体,fnt文件和png文件
    KeyLbl_BMFnt = "LblBMFnt",
    -- createWithBMFnt需要用到的字体
    KeyLbl_CharMap = "LblCharMap",
    -- CharMap方式有两种创建方式直接传CharMap文件和传Charmap文件对应的plist文件
    -- setCharMap(plist)会报错：Assert Failed on Lua exectue,upgrade cocos2dx version
    --    KeyLbl_CharMapPlist = "LblCharMapPlist",
    -- createWithSystemFont需要用到的字体
    KeyLbl_SysFnt = "LblSysFnt",
    -- 文本大小
    KeyLbl_FntSize = "LblFntSize",
    -- 文本颜色
    KeyLbl_TxtClr = "LblTxtClr",
    -- 荧光效果 只有TTF用到
    KeyLbl_GlowClr = "LblGlowClr",
    -- 描边大小，只有TTF和SysFnt用到
    KeyLbl_OutLineSize = "LblOutLineSize",
    -- 描边颜色，只有TTF和SysFnt用到
    KeyLbl_OutLineClr = "LblOutLineClr",
    -- 阴影
    KeyLbl_ShdwClr = "LblShdwClr",
    -- 阴影偏移
    KeyLbl_ShdwOffset = "LblShdwOffset",
    --    -- 阴影模糊指数,
    --    KeyLbl_BlrRds = "LblBlrRds",
    -- CharMap用到
    KeyLbl_ItemW = "LblItemWidth",
    -- CharMap用到
    KeyLbl_ItemH = "LblItemHeight",
    -- CharMap用到
    KeyLbl_Strt = "LblStrt",
    KeyLbl_HAlgn = "LblHAlgn",
    KeyLbl_VAlgn = "LblVAlgn",
    KeyLbl_Dimens = "LblDimem",
    KeyLbl_Width = "LblWidth",
    KeyLbl_MaxLineW = "LblMaxLineW",
    KeyLbl_ClipMargin = "LblClipMargin",
    KeyLbl_LineHeight = "LblLineHeight",
    KeyLbl_LineBreakWithOutSpace = "LblLineBreakWithoutSpace",
}
-- 全部UI控件的样式配置table，通过StyleUIMgr.loadRes添加。Stylebtn，StyleCheckbox，StyleLabel
cc.exports.gUIBeanStyleConf = {
}
-- btn样式配置冲突,loadConf时，全局配置中已经存在相同名的元素
local btnStyleResConflictHint = [[
btn style config res conflict!]]
-- btn样式配置冲突,loadConf时，全局配置中已经存在相同名的元素
local checkBoxStyleResConflictHint = [[
checkbox style config res conflict!]]
-- Label样式配置冲突,loadConf时，全局配置中已经存在相同名的元素
local lblStyleResConflictHint = [[
label style config res conflict!]]

-- 加载Style配置到全局表中
function StyleUIMgr:load(styleConf)
    if styleConf then
        local tmp = nil
        for i, v in pairs(styleConf) do
            tmp = gUIBeanStyleConf[i]
            if tmp then
                if tmp[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Label then
                    print(gUIBeanConstant.LINE)
                    print(lblStyleResConflictHint)
                    print(i .. [[ is already element of gUIBeanStyleConf,try dump***Info for more info]])
                    print(gUIBeanConstant.LINE)
                elseif tmp[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Checkbox then
                    print(gUIBeanConstant.LINE)
                    print(checkBoxStyleResConflictHint)
                    print(i .. [[ is already element of gUIBeanStyleConf,try dump***Info for more info]])
                    print(gUIBeanConstant.LINE)
                elseif tmp[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Btn then
                    print(gUIBeanConstant.LINE)
                    print(btnStyleResConflictHint)
                    print(i .. [[ is already an element of gUIBeanStyleConf,try dump***Info for more info]])
                    print(gUIBeanConstant.LINE)
                end
            else
                gUIBeanStyleConf[i] = v
            end
        end
    end
end
-- 从全局table中卸载指定配置
function StyleUIMgr:unload(styleConf)
    if styleConf then
        for i, k in pairs(styleConf) do
            gUIBeanStyleConf[i] = nil
        end
    end
end
-- 快速创建一个BtnStyle
function StyleUIMgr:createBtnStyle(strNormal, strSelected, strDisabled, strClickEffect)
    local ret = { }
    ret[gBtnStyleConfField.KeyNormal] = strNormal
    ret[gBtnStyleConfField.KeySelected] = strSelected
    ret[gBtnStyleConfField.KeyDisabled] = strDisabled
    ret[gBtnStyleConfField.KeyClickEffect] = strClickEffect
    return ret
end
-- 快速创建一个CheckboxStyle
function StyleUIMgr:createCheckboxStyle(background, backgroundSelected, backgroundDisabled, cross, frontCrossDisabled)
    local ret = { }
    ret[gUIBeanStyleConfField.KeyBackground] = background
    ret[gUIBeanStyleConfField.KeyBackgroundSelected] = backgroundSelected
    ret[gUIBeanStyleConfField.KeyBackgroundDisabled] = backgroundDisabled
    ret[gUIBeanStyleConfField.KeyCross] = cross
    ret[gUIBeanStyleConfField.KeyFrontCrossDisabled] = frontCrossDisabled
    return ret
end
-- 快速创建一个TTF类型的Label Style
function StyleUIMgr:createLabelTTFStyle(TTFConf, txtColor)
    local ret = { }
    ret[gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label_TTF
    ret[gUIBeanStyleConfField.KeyTxtColor] = txtColor
    ret[gUIBeanStyleConfField.KeyTTFConf] = TTFConf
    return ret
end
-- 快速创建一个CharMap类型的Label Style
function StyleUIMgr:createLabelCharMapStyle(pngPath, itemWidth, itemHeight, startCharMap)
    local ret = { }
    ret[gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label_CharMap
    ret[gUIBeanStyleConfField.KeyCharMapFile] = pngPath
    ret[gUIBeanStyleConfField.KeyItemWidth] = itemWidth
    ret[gUIBeanStyleConfField.KeyItemHeight] = itemHeight
    ret[gUIBeanStyleConfField.KeyStartCharMap] = startCharMap
    return ret
end
-- 快速创建一个BMFnt类型的Label Style
function StyleUIMgr:createLabelBMFntStyle(bmFontFile)
    local ret = { }
    ret[gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label_BMFnt
    ret[gUIBeanStyleConfField.KeyBMFntFile] = bmFontFile
    return ret
end
-- 快速创建一个SysFnt类型的Label Style
function StyleUIMgr:createLabelSysFntStyle(sysFnt, fntSize, txtColor)
    local ret = { }
    ret[gUIBeanStyleConfField.KeyType] = gUIBeanConstant.Label_SysFnt
    ret[gUIBeanStyleConfField.KeySysFntFile] = sysFnt
    ret[gUIBeanStyleConfField.KeyFntSize] = fntSize
    ret[gUIBeanStyleConfField.KeyTxtColor] = txtColor
    return ret
end
-- 打印当前保存的全部style
function StyleUIMgr:dumpStyleInfo()
    --    require("app.utilities.ToolCommon"):printTable('BtnStyleConf', gUIBeanStyleConf)
    dump(gUIBeanStyleConf, "###################StyleConf");
end
-- 打印全局表中已经保存的BtnStyle
function StyleUIMgr:dumpBtnStyleInfo()
    local styles = { };
    if gUIBeanStyleConf then
        for i, v in pairs(gUIBeanStyleConf) do
            if v[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Btn then
                styles[i] = v
            end
        end
    end
    dump(styles, "###################BtnStyleConf")
end
-- 打印全局表中已经保存的CheckboxStyle
function StyleUIMgr:dumpCBStyleInfo()
    local styles = { };
    if gUIBeanStyleConf then
        for i, v in pairs(gUIBeanStyleConf) do
            if v[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Checkbox then
                styles[i] = v
            end
        end
    end
    dump(styles, "###################CheckBoxStyleConf")
end
-- 打印全局表中已经保存的LabelStyle
function StyleUIMgr:dumpLabelStyleInfo()
    local styles = { };
    if gUIBeanStyleConf then
        for i, v in pairs(gUIBeanStyleConf) do
            if v[gUIBeanStyleConfField.KeyType] == gUIBeanConstant.Label then
                styles[i] = v
            end
        end
    end
    dump(styles, "###################LabelStyleConf")
end

cc.exports.StyleUIMgr = cc.exports.StyleUIMgr or StyleUIMgr

return cc.exports.StyleUIMgr