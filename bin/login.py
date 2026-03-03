#!/usr/bin/env python3
# Satisfy the OTP of many logins all in one go
# especially useful for ultra2,cirrus,etc which don't work properly with Mobaxterm.
# Use the same ssh key for them all, it will be ignored if not appropriate.

import pyotp
import pexpect
import sys
import time

timeout=4 # seconds
cirr='XXXXXXXXXXXYYQF2IASY6ZNBEU'
u2='XXXXXXXXXXXXXXBWIH5HU5O7IY'
e147='XXXXXXXXXXXXXMFWRDS7JFIRZI'
e114='XXXXXXXXXXXX2WLQVR7OUWPUIA'
e040='XXXXXXXXXXXXXXJNLFU2T3DFJA'

logins = [
        ('abrooksz62@login.cirrus.ac.uk', cirr),
        ('abrooksc@sdf-cs1.epcc.ed.ac.uk', u2),
        ('andrewb147@eidf-gateway.epcc.ed.ac.uk', e147),
        ('ab-eidfstaff@eidf-gateway.epcc.ed.ac.uk', e114),
        ('abrooks-040@eidf-gateway.epcc.ed.ac.uk', e040),
        ]

for host,mfa in logins:

    totp = pyotp.TOTP(mfa)
    otp = totp.now()
    print(host,otp)
    try:
        child = pexpect.spawn('ssh -i /home/arb/.ssh/mobaterm_private %s' % host)
        child.expect('TOTP', timeout=timeout)
        child.sendline(otp)
        child.expect('Last login', timeout=timeout)
        print(child.before)
        child.kill(0)
    except:
        print('Tried %s' % host)
