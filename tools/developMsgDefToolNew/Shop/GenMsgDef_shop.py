#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息   部分需要手动修改
_fileName = { 'name' : 'shopModel', 'context' : '商城协议' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_ShopList_send': {
        'comment': '请求商城一级菜单',
        'msgid' : 0x640101,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'UserID'),
            ('char',                     'Type'),
            ('int',                      'MenuID'),
            ('short',                    'OP'),
            ('int',                      'SP'),
            ('string',                   'Account'),
            ('string',                   'Mid'),
            ('char',                     'Newflag'),
            ('string',                   'Iconsize'),
            ('int',                      'Param1'),
            ('int',                      'Param2'),
            ('int',                      'Param3'),
            ('int',                      'Param4'),
            ('int',                      'bankID'),
            ('int',                      'sceneID'),
            ('int',                      'hallID'),
        ],
    }, 
    'Msg_ShopList_Ret': {
        'comment': '新版充值菜单信息',
        'msgid' : 0x640115,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'MneuID'),
            ('loop',   {
                'loopTableKey' :           'Items',
                'loopReadType' :           'short',
                 'fields': [
                    ('int',                'ItemID'),
                    ('string',             'Name'),
                    ('string',                'Icon'),  #斗2没有读取，但是要读取字节
                    ('char',               'Hot'),
                    ('char',               'CashTpye'),
                    ('char',               'ChargeType'),
                    ('char',               'ToUser'),
                    ('string',             'ChargeCmd'),
                    ('string',             'MenuData'),
                    ('int',                'MenuFlag'),
                    ('int',                'Money'),
                    ('int',                'SP'),
                    ('int',                'SPServiceID'),
                    ('int',                'Cash'),
                    ('int',                'DonateCash'),
                    ('string',             'MenuKey'),
                    ('string',             'Description1'),
                    ('string',             'Description2'),
                    ('string',             'Description3'),
                ],
            }),
            #从Confirm字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'Confirms',   
                'loopReadType' :           'none',
                 'fields': [
                    ('char',               'Confirm'),
                ],
            }),
            #从SmsType字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'SmsTypes', 
                'loopReadType' :           'none',
                 'fields': [
                    ('short',              'SmsType'),
                    ('string',             'SmsOrder'),
                ],
            }),  
            #从MenuType字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'MenuTypes', 
                'loopReadType' :           'none',
                 'fields': [
                    ('char',               'MenuType'),
                    ('int',                'TMagicID'),
                ],
            }),
            #ReqType是循环外字段，注意文档不对
            ('char',               'ReqType'),
            #从MenuType字段开始重新循环
            ('loop',   {
                #嵌套读取道具内容 MCount
                'loopTableKey' :           'MCountTables',
                'loopReadType' :           'none',
                 'fields': [
                    ('loop',   {
                        #嵌套读取道具内容 MCount
                        'loopTableKey' :           'Magics',
                        'loopReadType' :           'char',
                        'loopCountKey' :           'MCount',
                         'fields': [
                            ('int',                'MagicID'),
                            ('string',             'MagicName'),
                            ('int',                'MagicCount'),
                            ('int',                'MagicFID'),
                        ],
                    }),
                ],
            }),
            #从Discount字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'Discounts', 
                'loopReadType' :           'none',
                 'fields': [
                    ('char',               'Discount'),
                ],
            }),
            #从bankID字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'bankIDs', 
                'loopReadType' :           'none',
                 'fields': [
                    ('int',               'bankID'),
                    ('int',               'sceneID'),
                    ('int',               'hallID'),
                ],
            }),
            #从showType字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'showTypes', 
                'loopReadType' :           'none',
                 'fields': [
                    ('char',               'showType'),
                ],
            }),
            #从showOrder字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'showOrders', 
                'loopReadType' :           'none',
                 'fields': [
                    ('int',               'showOrder'),
                ],
            }),
            #从buttonText字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'buttonTexts', 
                'loopReadType' :           'none',
                 'fields': [
                    ('string',               'buttonText'),
                ],
            }),
        ],
    }, 
    
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
