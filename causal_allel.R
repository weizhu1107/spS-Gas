#*********************************************************************************
# Calculates the variance in liability explained by a single biallelic loci.
# PA: allele frequency of the risk allele (denoted A)
# RR1: relative risk of Aa (one risk allele) compared to aa (no risk allele)
# RR2: relative risk of AA (two risk alleles) compared to aa (no risk allele)
# K:  overall probability of disease in population
# Returns the variance explained (Vg) and the mean liability for each genotype (the overall liability is normalized to mean 0 and variance 1)
#*********************************************************************************


sn=commandArgs(TRUE)[1]
fn=paste("/DataStorage/Backup/xc/ngs/h_legend_maf/",sn,".txt",sep="")
ofn=paste("/DataStorage/Backup/xc/ngs/causal_list/",sn,".txt",sep="")
d=read.table(fn,header=T,sep=" ")

func.Vg <- function (PA,RR1,RR2,K) {
Paa = (1-PA)^2
PAa = 2*PA*(1-PA)
PAA = PA^2
muaa=0
faa= K/(Paa + PAa*RR1 + PAA*RR2)
fAa= RR1*faa
fAA= RR2*faa 
T = qnorm(1-faa) 
muAa = T-qnorm(1-fAa)
muAA = T-qnorm(1-fAA)
mean.all= PAa*muAa+ PAA*muAA
Vg= Paa*(muaa-mean.all)^2 + PAa*(muAa-mean.all)^2+ PAA*(muAA-mean.all)^2
actual.Vg =  Vg/(1+Vg) 
VR = 1-actual.Vg 
actual.T = Paa*sqrt(VR)*qnorm(1-faa) + PAa*sqrt(VR)*qnorm(1-fAa) + PAA*sqrt(VR)*qnorm(1-fAA)
actual.muaa = actual.T - sqrt(VR) * qnorm(1-faa)
actual.muAa = actual.T - sqrt(VR) * qnorm(1-fAa)
actual.muAA = actual.T - sqrt(VR) * qnorm(1-fAA)

res <- list(Vg=actual.Vg,muaa=actual.muaa, muAa = actual.muAa, muAA=actual.muAA)
res

} 

K=0.093
d=d[which(d[,5]>0 & d[,5]<1),]
nt=length(d[,1])
nc=30
ci=sample(nt,nc)
dop=d[ci,]
dop$RR1=1
dop$RR2=1
dop$VE=0


opt_fun=function(x,maf,t_ve) {
	RR2=x
	RR1=(1+RR2)/2	
	ve=func.Vg(maf,RR1,RR2,K)$Vg
	(ve-t_ve)^2
}

i=1
while(i<=30){
	ve=0
	RR2=1
	RR1=(1+RR2)/2
	re=optimize(opt_fun,c(1,10),tol=0.0001,t_ve=0.01,maf=dop[i,5])
	dop[i,]$RR1=round((1+re$minimum)/2,2)
	dop[i,]$RR2=2*dop[i,]$RR1-1
	dop[i,]$VE=func.Vg(dop[i,5],dop[i,]$RR1,dop[i,]$RR2,K)$Vg
	i=i+1
}

write.table(dop,ofn,quote=F,col.names=T,row.names=F)
