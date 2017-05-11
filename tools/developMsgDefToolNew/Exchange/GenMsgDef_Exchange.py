#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'exchangenetModel', 'context' : '兑换中心模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_ExchangeDataReq_send': {
        'comment': '请求兑换中心数据',
        'msgid' : 0x110901,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'Type'),
            ('int',                     'GameID'),
            ('int',                      'ObjectID'),
            ('int',                      'Param1'),
			('int',                      'Pram2'),
        ],
    },
	'Msg_ExchangeCommit_send': {
        'comment': '兑换(领取)请求',
        'msgid' : 0x110905,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'Type'),
            ('int',                     'ExchID'),
            ('int',                      'EquipID'),
            ('int',                      'Coupon'),
			('string',                      'RealName'),
			('string',                      'Phone'),
			('string',                      'Address'),
			('string',                      'MagicName'),
        ],
    },
	'Msg_setReceiver_send': {
        'comment': '设置收货人',
        'msgid' : 0x110907,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'Type'),
            ('int',                     'RecordID'),
            ('string',                      'RealName'),
            ('string',                      'Phone'),
			('string',                      'Address'),
			('char',                      'Default'),
        ],
    },
	'Msg_ThirdpartyAccessReq_send': {
        'comment': '第三方授权相关操作',
        'msgid' : 0x110909,
        'msgtype': 'write', 
        'fields': [
            ('char',              'Type'),
            ('string',            'Param1'),
            ('string',            'Param2'),
            ('string',            'Param3'),
        ],
    },
    'Msg_ConvertibleEquipList_Ret': {
        'comment': '可兑换商品列表',
        'msgid' : 0x110902,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'UserID'),
            ('char',                     'Type'),
            ('int',                        'MyCoupon'),
            ('loop',   {
                'loopTableKey' :           'exchangeInfo',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'ExchID'),
                    ('int',                'EquipID'),
                    ('string',                'Name'),
                    ('int',                'Stock'),
                    ('int',                'NeedCoupon'),
                    ('char',                'ObjectType'),
					('string',                'Expire'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'statusInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('int',             'beginSecond'),
                    ('char',                'State'),
                ],
            }),
			('int',                'ExchCenterID'),
			('loop',   {
                'loopTableKey' :           'otherInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('int',             'ExchMagicID'),
                    ('int',             'ExchMagicFID'),
                    ('string',          'ExchMagicName'),
                    ('char',            'BindingPhone'),
                    ('int',             'limitCount'),
                    ('int',             'limitDay'),
                ],
            }),
        ],
    },   
	'Msg_ExchangeTextInfo_Ret': {
        'comment': '各种说明文字信息',
        'msgid' : 0x110903,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'Type'),
            ('char',                     'Desc'),
            ('loop',   {
                'loopTableKey' :           'info',
                'loopReadType' :           'short',
                 'fields': [
                    ('string',             'Subject'),
                    ('string',             'Content'),
                ],
            }),
        ],
    },
	'Msg_ConvertibleEquipInfo_Ret': {
        'comment': '兑换商品详情',
        'msgid' : 0x110904,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'ExchID'),
            ('int',                     'EquipID'),
			('int',                     'Price'),
			('int',                     'NeedCoupon'),
			('int',                     'Stock'),
			('int',                     'ConvertedCount'),
			('string',                     'Desc'),
		    ('string',                     'endDate'),
        ],
    },  
	'Msg_ReceiverList_Ret': {
        'comment': '收获信息',
        'msgid' : 0x110906,
        'msgtype': 'read', 
        'fields': [
            ('loop',   {
                'loopTableKey' :           'info',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'RecordID'),
                    ('string',             'RealName'),
					('string',             'Phone'),
					('string',             'Address'),
					('char',             'Default'),
                ],
            }),
        ],
    },
	'Msg_MyAwardList_Ret': {
        'comment': '我的奖品列表',
        'msgid' : 0x110908,
        'msgtype': 'read', 
        'fields': [
            ('char',             'Type'),
			('int',             'GameID'),
			('loop',   {
                'loopTableKey' :           'info',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',             'UserExchID'),
                    ('int',             'EquipID'),
					('string',             'EquipName'),
					('string',             'ExchangeTime'),
					('string',             'Desc'),
					('char',             'Flag'),
					('char',             'ObjectType'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'userInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('int',             'UserID'),
                    ('string',             'NickName'),
					('int',             'Price'),
					('string',             'Phone'),
					('string',             'Address'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'magicInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('int',             'ExchMagicID'),
                    ('string',          'ExchMagicName'),
                ],
            }),
			('loop',   {
                'loopTableKey' :           'recipientInfo',
                'loopReadType' :           'none',
                 'fields': [
                    ('string',             'Recipient'),
                ],
            }),
        ],
    },
	'Msg_WeiXinAccessInfo_Ret': {
        'comment': '微信授权返回',
        'msgid' : 0x11090a,
        'msgtype': 'read', 
        'fields': [
            ('char',              'result'),
			('string',           'openid'),
			('string',           'nickname'),
			('char',           	'sex'),
			('string',             'province'),
			('string',             'city'),
			('string',             'country'),
			('string',             'headimgurl'),
			('string',             'privilege'),
			('string',             'unionid'),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
