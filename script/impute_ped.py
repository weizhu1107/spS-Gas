#!/usr/bin/python
import sys, os

fn=sys.argv[1]
sam=open(fn, 'r')
lines=sam.readlines()
ofn=fn.split("_")[0]+"_assoc.ped"
ouf=open(ofn, 'w')

genf=open("impute", "r")
n=0
tn=len(lines)/2
gend=genf.readlines()
for line in lines:
        data = line.strip().split(" ")
        n=n+1
        if n <= tn:
		ouf.write(data[0]+" 1\n")
	else:						#case
		ouf.write(data[0]+" 2\n")
        
        for genl in gend:
                data_gen = genl.strip().split(" ")
                if float(data_gen[2+n*3]) >= 0.9:
                        gp=data_gen[3]+" "+data_gen[3]
                elif float(data_gen[3+n*3]) >= 0.9:
                        gp=data_gen[3]+" "+data_gen[4]
                elif float(data_gen[4+n*3]) >= 0.9:
                        gp=data_gen[4]+" "+data_gen[4]
                else:
                        gp="0 0"

                ouf.write(" "+gp)

        ouf.write("\n")

ouf.close()
sam.close()
genf.close()
