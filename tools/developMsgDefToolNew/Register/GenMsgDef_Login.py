#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'loginModel', 'context' : '登录模块' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_Login_send': {
        'comment': '登录请求',
        'msgid' : 0x020101,
        'msgtype': 'write',
        'fields': [
            ('string', 'useriD'),
            ('string', 'userPwd'),
            ('char', 'loginType'),
            ('int', 'sp'),
            ('short', 'op'),
            ('int', 'moduleid'),
            ('char', 'language'),
            ('int', 'hallid'),
            ('string', 'version'),
            ('string', 'model'),
            ('char', 'dmenu'),
            ('char', 'guagua'),
            ('char', 'imgformat'),
            ('string', 'sdkapid'),
            ('string', 'key'),
            ('string', 'md5'),
            ('short', 'width'),
            ('short', 'height'),
            ('string', 'mobilemodel'),
            ('short', 'resFile'),
            ('short', 'ext1'),
            ('int', 'monsterid'),
            ('int', 'operatorCode'),
            ('string', 'phoneModel'),
            ('string', 'manufacture'),
            ('string', 'apnType'),
            ('string', 'idCode'),
            ('string', 'imei'),
            ('string', 'sdkversion'),
            ('int', 'ext2'),
            ('short', 'playmode'),
            ('char', 'loginReward'),
            ('string', 'mac'),
            ('string', 'signatureMd5'),
            ('char', 'functionId'),
            ('int', 'signId'),
            ('char', 'ext3'),
            ('string', 'locAccount'),
            ('string', 'locPassword'),
            ('string', 'iccid'),
        ],
    },
    'Msg_Login_Ret': {
        'comment': '登录返回',
        'msgid' : 0x020102,
        'msgtype': 'read',
        'fields': [
            ('char', 'VerStatus'),
            ('string', 'DownloadURL'),
            ('string', 'Description'),
            ('int', 'userid'),
            ('string', 'nickname'),
            ('char', 'gender'),
            ('char', 'vip'),
            ('int', 'parameter'),
            ('short', 'freshguagua'),
            ('short', 'subscription'),
            ('string', 'mask'),
            ('string', 'tip1'),
            ('string', 'tip2'),
            ('string', 'tip3'),
            ('string', 'userPwd'),
            ('string', 'hallversion'),
            ('char', 'moreGame'),
            ('int', 'awardbeancount'),
            ('int', 'intparam1'),
            ('short', 'compassswitch'),
            ('short', 'exchageswitch'),
            ('short', 'wealSwitch'),
            ('string', 'DKUserid'),
            ('char', 'DiffPkg'),
            ('loop', {
                'loopTableKey':                 'list',
				'loopReadType':                 'short',
                'fields':                       [
                    ('string', 'magicName'),
                    ('int', 'magicID'),
                    ('int', 'fid'),
                    ('int', 'magiccount'),
                  
                ],
                }),
            ('string', 'subject'),
        ],
    },
    'Msg_Logout_send': {
        'comment': '退出请求',
        'msgid' : 0x020103,
        'msgtype': 'write',
        'fields': [
            ('int', 'userID'),
            ('char', 'exitType'),
        ],
    },
    'Msg_LogoutInfo_Ret': {
        'comment': '退出确认消息',
        'msgid' : 0x020104,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('char', 'ExitType'),
            ('int', 'Power'),
            ('int', 'Longevity'),
            ('int', 'Charm'),
            ('int', 'Cash'),
            ('int', 'logonID'),
            ('short', 'onlineTime'),
            ('char', 'Magic701'),
            ('int', 'Bean'),
            ('string', 'GameCash'),
        ],
    },
    'Msg_NotifyUser_Ret': {
        'comment': '上下线通知消息',
        'msgid' : 0x020105,
        'msgtype': 'write',
        'fields': [
            ('string', 'UserID'),
            ('int', 'Type'),
            ('int', 'ModuleID'),
            ('string', 'ModuleName'),
            ('int', 'GuaGua'),
            ('string', 'NickName'),
            ('int', 'Magic701'),
            ('int', 'Vip'),
            ('int', 'Gender'),
        ],
    },
	'Msg_putClientModuleID_send': {
        'comment': '客户端通知后台当前功能模块ID,这个对上号，才能收到后台的滚报',
        'msgid' : 0x010147,
        'msgtype': 'write', 
        'fields': [
            ('int',                     'moduleID'),
            ('int',                   'Sp'),
            ('char',                   'Language'),
            ('int',                   'hallID'),
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
