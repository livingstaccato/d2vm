#!/bin/sh

qemu-system-x86_64 -hda /home/tim.perkins/al2023.qcow2 -boot c -net user -nographic -m 4192 -smp 2 -cpu SandyBridge
