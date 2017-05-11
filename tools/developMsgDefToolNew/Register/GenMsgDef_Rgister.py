#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'registerModel', 'context' : '注册模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_Register_send': {
        'comment': '注册请求',
        'msgid' : 0x010105,
        'msgtype': 'write', 
        'fields': [
            ('char',                      'userType'),
            ('char',                     'vip'),
            ('string',                      'password'),
            ('short',                      'mid'),
            ('short',                      'mdn'),
            ('char',                      'language'),
            ('string',                      'nickname'),
            ('char',                      'sex'),
            ('int',                      'header'),
            ('int',                      'region'),
            ('short',                      'op'),
            ('int',                      'sp'),
            ('string',                      'manufacture'),
            ('short',                      'mdn'),
            ('char',                      'registerType'),
            ('short',                      'mail'),
			('string',                      'MAC'),
			('int',                      'gameID'),
			('int',                      'hallID'),
        ], 
    },
    'Msg_Rgister_Ret': {
        'comment': '注册返回',
        'msgid' : 0x010105,
        'msgtype': 'read', 
        'fields': [
            
        ],
    },
	'Msg_UpdateUserInfo_send': {
        'comment': '更新用户信息，响应General',
        'msgid' : 0x010104,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'UserID'),
            ('string',                     'Password'),
            ('string',                      'NickName'),
            ('char',                      'Gender'),
            ('int',                      'IconID'),
            ('char',                      'GameWatch'),
            ('string',                      'PetName'),
            ('int',                      'PetImageID'),
            ('char',                      'PetStatus'),
            ('char',                      'EatStyle'),
            ('string',                      'Sign'),
            ('char',                      'PetPlayMoney'),
            ('int',                      'Province'),
            ('int',                      'City'),
            ('string',                      'BloodType'),
            ('string',                      'Hobby'),
            ('string',                      'Mail'),
            ('string',                      'RealName'),
            ('string',                      'BirthDay'),
            ('string',                      'Introduce'),
            ('char',                      'OpenPrivacy'),
        ], 
    },    
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
