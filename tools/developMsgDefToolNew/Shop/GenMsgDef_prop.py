#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息   部分需要手动修改
_fileName = { 'name' : 'shopPropModel', 'context' : '道具商城协议' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_MagicStoreReq_send': {
        'comment': '请求游戏道具商店数据',
        'msgid' : 0x110B01,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'Type'),
            ('int',                     'GameID'),
            ('int',                      'ObjectID'),
            ('char',                    'CashType'),
            ('int',                      'bankID'),
        ],
    }, 
    'Msg_StoreMagicList_Ret': {
        'comment': '游戏商店商品列表',
        'msgid' : 0x110B02,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'GameID'),
            ('int',                        'StoreID'),
            ('loop',   {
                'loopTableKey' :           'StoreMagicInfos',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',                'StoreMagicID'),
                    ('int',                'MagicID'),
                    ('int',                'Money'), 
                    ('string',               'Name'),
                    ('string',               'Description'),
                    ('string',               'Introduce'),
                ],
            }),
            #从magicCount字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'fids',   
                'loopReadType' :           'none',
                 'fields': [
                    ('int',               'magicCount'),
                    ('int',               'fid'),
                ],
            }),
            #从Expire字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'Expires', 
                'loopReadType' :           'none',
                 'fields': [
                    ('string',              'Expire'),
                ],
            }),
            ('int',                'bankID'),
            #从marketMoney字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'marketMoneys', 
                'loopReadType' :           'none',
                 'fields': [
                    ('int',               'marketMoney'),
                ],
            }),
            #从dayLimit字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'dayLimits', 
                'loopReadType' :           'none',
                 'fields': [
                    ('int',               'dayLimit'),
                    ('int',               'monthLimit'),
                    ('char',               'buystatus'),
                ],
            }),
        ],
    },
    'Msg_BuyMagicReq_send': {
        'comment': '购买道具请求',
        'msgid' : 0x110301,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'MagicID'),
            ('int',                     'Price'),
            ('short',                      'Count'),
            ('int',                    'DestUserID'),
            ('int',                      'GameID'),
            ('int',                      'PlayID'),
            ('string',                      'Mid'),
            ('char',                      'CashType'),
            ('char',                      'playType'),
            ('int',                      'StoreID'),
            ('int',                      'GameZoneID'),
            ('int',                      'bankID'),
            ('int',                      'targetGameID'),
            ('int',                      'storeMagicID'), #add
        ],
    },
    'Msg_BuyMagicResp_Ret': {
        'comment': '购买道具回复',
        'msgid' : 0x110302,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'MagicID'),
            ('int',                        'DestUserID'),
            ('int',                        'BuyPrice'),
            ('char',                        'result'),
            ('int',                        'SpareTime'),
            ('int',                        'UseCash'),
            ('string',                        'Desc'),
            ('char',                        'CashType'),
            ('short',                        'Count'),
            ('int',                        'bankID'),
            ('long long',                        'gameCash'),
        ],
    },
	'Msg_UseMagicResp_Ret': {
        'comment': '道具使用情况',
        'msgid' : 0x110305,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'GamePlayID'),
            ('int',                        'MagicID'),
            ('int',                        'FromUserID'),
            ('int',                        'ToUserID'),
            ('string',                     'Param'),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
