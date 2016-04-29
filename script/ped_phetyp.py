#!/usr/bin/python
import sys, os

fn=sys.argv[1]
sam=open(fn, 'r')
lines=sam.readlines()
ofn=fn.split(".")[0]+"_p.ped"
ouf=open(ofn, 'w')
n=0
tn=len(lines)/2
for line in lines:
	data = line.strip().split("\t")
	n=n+1
	if n <= tn:
		data[5] = "1" #case
	else:
		data[5] = "2" #case
		

	for item in data:
		ouf.write("%s\t" % item)
	ouf.write("\n")


ouf.close()
sam.close()
os.remove(fn)
os.rename(ofn, fn)
