#!/usr/bin/python3

import random

f=open("/usr/share/dict/cracklib-small")
lines = f.readlines()
f.close()

f=open("./scribd.pdf", "w")
f.write("".join(random.sample(lines, 1000)))
f.close()
