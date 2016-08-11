#!/usr/bin/python
import sys, os

fn=sys.argv[1]
sam=open(fn, 'r')
lines=sam.readlines()
ouf=open("impute_assoc.ped", 'w')

genf=open("impute", "r")
n=0
tn=len(lines)/2
gend=genf.readlines()
for line in lines:
        data = line.strip().split(" ")
        n=n+1
        if n <= tn:
		ouf.write(data[0]+" 1")
	else:						#case
		ouf.write(data[0]+" 2")
        
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

mf=open("impute_assoc.map", 'w')
for gen_line in gend:
        data_gen=gen_line.strip().split(" ")
        mf.write(data_gen[0]+" "+data_gen[0]+":"+data_gen[2]+" 0 "+data_gen[2]+"\n")

genf.close()
mf.close()
