#!/usr/bin/python
import sys, os

fn=sys.argv[1]
sam=open(fn, 'r')
lines=sam.readlines()
ofn=fn.split("_")[0]+"_assoc.ped"
ouf=open(ofn, 'w')
n=0
tn=len(lines)/2
for line in lines:
	data = line.strip().split("\t")
	n=n+1
	if n <= tn:
		ouf.write(data[0]+" 1\n")
	else:
		ouf.write(data[0]+" 2\n")	#case
		
ouf.close()
sam.close()
