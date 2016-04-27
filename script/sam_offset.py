#!/usr/bin/python
import sys, os

fn=sys.argv[1]
of=int(sys.argv[2])
chr_l=int(sys.argv[3])
sam=open(fn, 'r')
lines=sam.readlines()
ofn=fn.split(".")[0]+"_os.sam"
ouf=open(ofn, 'w')
n=0
sqn=0
for line in lines:
        data = line.strip()
        if data[0] == '@':
                if data[1:3] == "SQ":
                        if sqn == 0:
                                data = data.split("\t")
                                for item in data[0:-1]:
                                        ouf.write("%s\t" % item)

                                ouf.write( "LN:" + str(chr_l) + "\n" )
                                sqn = 1

                        continue

                ouf.write(line)
                continue

        data=data.split("\t")
        data[3] = int(data[3]) + of - 1
        data[7] = int(data[7]) + of - 1
        for item in data[0:-1]:
                ouf.write("%s\t" % item)

        ouf.write(data[-1]+"\n")

ouf.close()
sam.close()
os.remove(fn)
os.rename(ofn, fn)
