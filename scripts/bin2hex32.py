#!/usr/bin/env python3
import sys

if len(sys.argv) != 3:
    print("usage: bin2hex32.py input.bin output.hex")
    sys.exit(1)

infile = sys.argv[1]
outfile = sys.argv[2]

data = open(infile, "rb").read()

while len(data) % 4 != 0:
    data += b"\x00"

with open(outfile, "w") as f:
    for i in range(0, len(data), 4):
        word = data[i] | (data[i+1] << 8) | (data[i+2] << 16) | (data[i+3] << 24)
        f.write(f"{word:08x}\n")
