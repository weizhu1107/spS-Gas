#!/usr/bin/python

import fileinput, os, string, sys,warnings

hap_ref=sys.argv[1]
left_bound=int(sys.argv[2])
up_bound=int(sys.argv[3])
f_id=sys.argv[4]

snp_m=open(hap_ref, 'r')
lines=snp_m.readlines()

out_f=open(f_id+".txt","w")

cn=0
for line in lines:
        cn=cn+1
        if cn==1:
                out_f.write("rs pos X0 X1 maf\n")
                continue

        data=line.strip().split("\t")
        pos=int(data[1])

        if pos < left_bound:
                continue

        if pos > up_bound:
                break

        out_f.write(data[0]+" "+data[1]+" "+data[2]+" "+data[3]+" "+data[4]+"\n")

out_f.close()
snp_m.close()
