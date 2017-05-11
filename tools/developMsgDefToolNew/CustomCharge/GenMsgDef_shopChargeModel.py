#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息   部分需要手动修改
_fileName = { 'name' : 'shopChargeModel', 'context' : '商城充值逻辑协议' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_LXCharge_send': {
        'comment': '充值请求订单信息',
        'msgid' : 0x640112,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'UserID'),
            ('int',                     'money'),
            ('string',                   'Mid'),
            ('string',                    'Mdn'),
            ('int',                      'Sp'),
            ('int',                   'SPServiceiD'),
            ('string',                   'Consumecode'),
            ('char',                     'Moneytype'),
            ('char',                   'Type'),
            ('string',                      'signedData'),
            ('string',                      'signature'),
            ('char',                      'Newflag'),
            ('short',                      'chargeSp'),
            ('int',                      'Parameter1'),
            ('string',                      'StrPram1'),
            ('string',                      'StrPram2'),
            ('int',                      'GameID'),
            ('int',                      'MagicID'),
            ('int',                      'MoneyFen'),
            ('int',                      'menuId'),
            ('int',                      'bankID'),
            ('int',                      'sceneID'),
            ('int',                      'hallID'),
        ],
    }, 
    'Msg_ResultInfo_Ret': {
        'comment': '充值结果信息',
        'msgid' : 0x640103,
        'msgtype': 'read', 
        'fields': [
            ('int',                        'UserID'),
            ('char',                        'Result'),
            ('int',                        'addMoney'),
            ('int',                        'Money'),
            ('string',                     'Description'),
            ('char',                       'Moneytype'),
            ('string',                       'Status'),
            ('char',                       'Flag'),
            ('string',                       'FeeID'),
            ('string',                       'BillTime'),
            ('string',                       'AddGameCash'),
            ('string',                       'GameCash'),
            ('string',                       'Param'),
            ('int',                       'chargeSP'),
            ('string',                       'spServiceID'),
            ('int',                       'chargeMoney'),
            ('string',                       'OrderID'),
            ('char',                       'WeekVip'),
            ('int',                       'VipSCoder'),
            ('int',                       'TMagicID'),
            ('loop',   {
                'loopTableKey' :           'Items',
                'loopReadType' :           'char',
                 'fields': [
                    ('int',                'MagicID'),
                    ('string',             'MagicName'),
                    ('int',                'MagicCount'),
                    ('int',               'MagicFID'),
                ],
            }),
            ('short',                     'chargeType'),
        ],
    }, 

    'msg_NMESSAGE_SMSCOMMANDRESP':{
        'comment': '新短信充值返回的消息',
        'msgid' : 0x64011a,
        'msgtype': 'read',
        'fields':[
            ('char',                       'result'),
            ('int',                        'chargeType'),
            ('string',                     'orderId'),
            #从Ports字段开始重新循环
            ('loop',   {
                'loopTableKey' :           'comCount',   
                'loopReadType' :           'short',
                 'fields': [
                    ('string',               'Port'),
                    ('string',               'Command'),
                    ('int',                  'intervalTime'),
                    ('char',                 'Type'),                   
                ],
            }),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
