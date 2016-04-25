#!/usr/bin/python

import fileinput, os, string, sys,warnings, shutil, pprint, linecache

template_fa_f=sys.argv[1]
haplotype_f=sys.argv[3]
snp_f=sys.argv[2]
left_bound=int(sys.argv[4])
up_bound=int(sys.argv[5])
out_dir=sys.argv[6]
f_id=sys.argv[7]

snp_m=open(snp_f, 'r')
lines=snp_m.readlines()

to_transpose=[]
snp_gp=[]
cn=-1
#debug_out=open(out_dir+"/debug.txt","a")
for line in lines:
	cn=cn+1
	if cn==0:
		continue

	data=line.strip().split(" ")
	pos=int(data[1])
	if pos < left_bound:
		continue

	if pos > up_bound:
		break

	snp_gp.append(data)
	to_transpose.append(linecache.getline(haplotype_f, cn).strip().replace(" ", ""))

transposed=zip(*to_transpose)

snp_m.close()

def rewrite(sn, rev_dict):
	template_fa=open(template_fa_f, 'r')
	lines=template_fa.readlines()
	n=-1
	cn=0
	out_f=out_dir+"/fasta/"+sn+".fa"
	out=open(out_f, 'a')
#	for item in rev_dict:
#		line_no=item[0]
#		chr_no=item[1]

	line_i=-1
	for line in lines:
		line_i=line_i+1
		data=line.strip()

		if len(rev_dict) <= cn:
			out.write(data+"\n")
			continue

		if line_i<>rev_dict[cn][0]:
			out.write(data+"\n")
			continue

		for chr_i in range(len(data)):
			if len(rev_dict)<=cn:
				out.write(data[chr_i])
				continue

			if chr_i==(rev_dict[cn][1]-1) and line_i == rev_dict[cn][0]:
				out.write(rev_dict[cn][3])
				cn=cn+1
#				print(str(rev_dict[cn-1][0])+str(line_i)+"\t"+str(chr_i))

			else:
				out.write(data[chr_i])
			
		out.write("\n")	
			
	
	out.close()


cn=-1
for item in transposed:
	cn=cn+1
	sn=cn/2+3

	snp_n=-1
	rev_dict=[]
	for gp in item:
		snp_n=snp_n+1
		if gp=="0":
			continue

		if len(snp_gp[snp_n][2]) > 1 or len(snp_gp[snp_n][3]) > 1:
			continue

#		debug_out.write(snp_gp[snp_n][1]+" ")
		offset=int(snp_gp[snp_n][1])-left_bound+1
		line_no=offset/60+1
		chr_no=offset%60
		if chr_no==0:
			chr_no=60

#		debug_out.write(str(line_no)+" "+str(chr_no)+"\n")
		rev_dict.append((line_no,chr_no,snp_gp[snp_n][2],snp_gp[snp_n][3]))

	fa_n=linecache.getline(f_id,int(sn)).split()[0]
	rewrite(fa_n,rev_dict)
#	print(str(len(rev_dict)))


#debug_out.close()
