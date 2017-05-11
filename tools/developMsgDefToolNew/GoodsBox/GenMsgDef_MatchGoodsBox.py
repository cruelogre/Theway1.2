#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'goodsBoxModel', 'context' : '游戏物品箱模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_EquipReq_send': {
        'comment': '请求用户比赛物品箱的各种门票,门票碎片数据',
        'msgid' : 0x110801,
        'msgtype': 'write', 
        'fields': [
            ('char',                    'Type'),
            ('int',                    'GameID'),
            ('int',                    'ObjectID'),
        ],
    },
    'Msg_EquipList_Ret': {
        'comment': '用户比赛物品箱的各种门票,门票碎片',
        'msgid' : 0x110802,
        'msgtype': 'read', 
        'fields': [
            ('int',                    'UserID'),
            ('int',                     'GameID'),
            ('loop',   {
                'loopTableKey' :           'goodsInfo',
                'loopReadType' :           'short',
                'fields': [
                    ('int',                'UserEquipID'),
                    ('int',                'EquipID'),
                    ('int',              'EquipCount'),
                    ('string',             'Name'),
                    ('string',               'ExpireTime'),
                    ('int',               'Fid'),
				],
            }),
			('loop',   {
                'loopTableKey' :           'magicType',
                'loopReadType' :           'none',
                'fields': [
                    ('char',              'MagicType'),
				],
            }),
			('loop',   {
                'loopTableKey' :           'status',
                'loopReadType' :           'none',
                'fields': [
                    ('char',               'Status'),
				],
            }),
        ],
    },
	'Msg_MatchEquipInfo_Ret': {
        'comment': '比赛物品的说明信息',
        'msgid' : 0x110803,
        'msgtype': 'read', 
        'fields': [
            ('int',                    'EquipID'),
            ('string',                     'Desc'),
			('string',                     'introduce'),
        ],
    },
	'Msg_GameEquipInfo_Ret': {
        'comment': '游戏物品的详细说明信息',
        'msgid' : 0x110804,
        'msgtype': 'read', 
        'fields': [
            ('int',                    'ObjectID'),
            ('string',                     'Desc'),
			('string',                     'introduce'),
			('string',                     'Name'),
			('int',                     'totalCount'),
			('loop',   {
                'loopTableKey' :           'goodsInfo',
                'loopReadType' :           'short',
                'fields': [
                    ('int',               'magicCount'),
					('string',               'Expire'),
				],
            }),
            ('char',               'type'),
             ('loop',   {
                'loopTableKey' :           'goodsInfo2',
                'loopReadType' :           'none',
                'fields': [
                    ('int',               'UserEquipID'),
                    ('int',               'magicID'),
                    ('int',               'FID'),
                    ('int',               'expireMinute'),
                    ('string',               'Name'),
                ],
            }),
        ],
    },
	'Msg_GameEquipNumber_Ret': {
        'comment': '游戏物品的数量信息',
        'msgid' : 0x110805,
        'msgtype': 'read', 
        'fields': [
            ('int',                    'gameID'),
            ('int',                     'Fid'),
			('int',                     'Count'),
        ],
    },
    'Msg_GameEquipDesc_Ret': {
        'comment': '游戏道具的详细信息',
        'msgid' : 0x110807,
        'msgtype': 'read', 
        'fields': [
            ('int',                    'gameID'),
            ('int',                     'magicID'),
            ('int',                     'FID'),
            ('string',                     'Name'),
            ('string',                     'introduce'),
            ('string',                     'Desc'),
            ('char',                     'magicType'),
            ('char',                     'ExpireType'),
            ('int',                     'Expire'),
            ('loop',   {
                'loopTableKey' :           'goodsInfo',
                'loopReadType' :           'short',
                'fields': [
                    ('int',               'magicID'),
                    ('int',               'FID'),
                    ('string',               'Name'),
                    ('string',               'introduce'),
                    ('string',               'Desc'),
                    ('char',               'magicType'),
                    ('char',               'ExpireType'),
                    ('int',                     'Expire'),
                    ('int',                     'magicCount'),
                ],
            }),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
