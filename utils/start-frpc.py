#!/usr/bin/env python

import os
import pprint
import random
import string
import logging
import argparse

logging.basicConfig(level=os.environ.get('LOGLEVEL', 'INFO'))

parser = argparse.ArgumentParser('Start frpc and connect to server')
parser.add_argument(
    '-s',
    '--server',
    type=str,
    default='huawei.yousiki.top:10000',
    help='remote server (addr:port), default huawei.yousiki.top:10000',
)
parser.add_argument(
    '-l',
    '--local_port',
    type=int,
    default=22,
    help='local port, default 22 (ssh)',
)
parser.add_argument(
    '-r',
    '--remote_port',
    type=int,
    default=None,
    help='remote port, default random',
)
parser.add_argument(
    '-p',
    '--password',
    type=str,
    default=None,
    help='root password, default random',
)
parser.add_argument(
    '-n',
    '--name',
    type=str,
    default=None,
    help='service name, default random',
)
args = parser.parse_args()

logging.info(pprint.pformat(vars(args)))

if args.remote_port is None:
    args.remote_port = random.randint(20000, 40000)
    logging.info(f'using random remote_port: {args.remote_port}')

if args.password is None:
    args.password = ''.join(
        random.choices(string.ascii_uppercase + string.digits, k=8))
    logging.info(f'using random password: {args.password}')

if args.name is None:
    args.name = ''.join(
        random.choices(string.ascii_uppercase + string.digits, k=6))
    logging.info(f'using random name: {args.name}')

server_addr, server_port = args.server.split(':')

username = 'root'
password = args.password

os.system(f'echo "{username}:{password}" | chpasswd')
os.system('/etc/init.d/ssh restart')

logging.info(f"""
**********************************************
service name: {args.name}
server addr: {server_addr}
server port: {server_port}
local port: {args.local_port}
remote port: {args.remote_port}
username: {username}
password: {password}
**********************************************

use this command to entry the container:
    ssh {username}@{server_addr} -p {args.remote_port}
default password:
    {password}
""")

os.system(
    f'frpc tcp -p kcp --tls_enable -s {args.server} -l {args.local_port} -r {args.remote_port} -n {args.name}'
)