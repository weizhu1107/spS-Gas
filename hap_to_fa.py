#!/usr/bin/python

import fileinput, os, string, sys,warnings, shutil, pprint

fn=sys.argv[1]
chrom=sys.argv[2]
low_bound=int(sys.argv[3])
ln_s=1+low_bound/60+1
pos_s=low_bound%60
if pos_s == 0:
	pos_s = 60
	ln_s = ln_s - 1

rl=int(sys.argv[4])

line_length=60

fasta_f=open(fn, 'r')
lines = fasta_f.readlines()
out=open(sys.argv[5],"w")

ap=line_length*(ln_s-1)+pos_s
ep=ap+rl-1
e_ln=ep/60+1
e_pos=ep%60
if e_pos ==0:
	e_pos = 60
	e_ln = e_ln - 1

print(str(e_ln)+","+str(e_pos))

n=1
fl_tag=1
buf_in=0
out.write(">"+chrom+"\n")
for line in lines:
	if n<ln_s:
		n=n+1
		continue

	seq=str(line.strip())
	if n < e_ln:
		if fl_tag == 1:
			buf_wait = line_length - pos_s + 1
			if (buf_in + buf_wait) < 60:
				out.write(seq[(pos_s-1):(line_length)])
				buf_in = buf_in + buf_wait
			else:
				x_l = buf_in + buf_wait - line_length
				buf_i = line_length - buf_in  + pos_s - 1
				out.write(seq[(pos_s-1):(buf_i)] + "\n" + seq[buf_i:(buf_i + x_l)])
				buf_in = x_l

			fl_tag=0

		else:	
                        buf_i = line_length - buf_in
                        out.write(seq[0:(buf_i)] + "\n" + seq[buf_i:(line_length)])

		n=n+1
		continue

	if fl_tag == 1:
		out.write(seq[(pos_s-1):(e_pos)]+"\n")
	else:
		buf_wait = e_pos
		buf_i = line_length - buf_in
		if (buf_in + buf_wait) < 60:
			out.write(seq[0:(e_pos)]+"\n")
		else:
			out.write(seq[0:(buf_i)] + "\n")
			if buf_i<e_pos:
				out.write(seq[buf_i:(e_pos)]+"\n")
	break

out.close()
fasta_f.close()	
