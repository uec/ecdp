# TODO: Add comment
# 
# Author: feipan
###############################################################################

##############################
# plot and store all the control figures
##############################
probePlot_test<-function(){
	mData<-get(print(load(file="C:\\Documents and Settings\\feipan\\workspace\\methPipe\\data\\methData_test.rdata")))
	setwd("c:\\temp")
	gFileDir<-"c:\\temp"
	probePlot(mData=mData,data.dir=gFileDir)
	
	load(file="c:\\temp\\test2\\5543207015_idat.rda")
	probePlot(mData=idat,data.dir=gFileDir)
}
probePlot <-function(mData=NULL,txt=NULL,data.dir=NULL,fn=NULL,gtype="png"){
	if(is.null(mData)){
		mData<-get("mData",env=.GlobalEnv)
		if(is.null(mData)){
			msg<-"Data has been loaded/generated\n"
			tkmessageBox(message=msg);cat(msg)
			return()
		}
	}
	if(!is.null(txt)) tkinsert(txt,"end",paste("> Starting to generate the probe signal intensity plot ...",date(),"\n"))
	if(is.null(fn)){
		fn<-"mu_plot.png"
		if(gtype=="pdf") fn<-"mu_plot.pdf"
	}
	g.M<-NULL;g.U<-NULL
	if(class(mData)=="MethyLumiSet"){
		g.M<-mData@assayData$methylated
		g.U<-mData@assayData$unmethylated
	}
	else {
		g.M=getM(mData)
		g.U=getU(mData)
	}
	if(is.null(data.dir))data.dir<-gFileDir
	MUplot(g.M,g.U,toFile=TRUE,pname=fn,data.dir,gtype=gtype)
	if(!is.null(txt)) tkinsert(txt,"end","> Finished generating the probe plots\n")
}

MUplot<-function(M,U,toFile=FALSE,pname="",data.dir="",gtype="png"){
	figName<-NULL
	if(toFile==FALSE){
		X11()
	}else{
		gdat.name=pname
		figName<-file.path(data.dir,gdat.name)
		if(gtype=="png") png(filename=figName,width=1280,height=1280)
		else pdf(file=figName,width=10,height=7)
	}
	par(mfrow=c(2,2))
	plotDensity(M)
	plotDensity(U)
	boxplot(M,col="blue",main="M")
	boxplot(U,col="green",main="U")
	if(toFile==TRUE){
		dev.off()
		#shell.exec(figName)
	}
}

rfgc<-function(cData){
	rst.all<-NULL
	for(i in 1:length(cData)){
		#rst<-split(cData[[i]][,c(7,10)],as.factor(cData[[i]][,2]))
		rst<-split(cData[[i]][,c("Grn","Red")],as.factor(cData[[i]]$type))
		if(is.null(rst.all)){
			rst.all<-rst
		}else{
			for(j in 1:length(rst)){
				rst.all[[j]]<-c(rst.all[[j]],rst[[j]])
			}
		}
	}
	return(rst.all)
}
plotControlProfiles <- function(cData=NULL,figName="control_profile.png",toFile=FALSE,outDir,gtype="png")
{
	if(is.null(cData))
		cData<-readControlData()
	if(toFile==TRUE){
		if(gtype=="png")png(file=file.path(outDir,figName),width=1280,height=1280)
		else pdf(file=file.path(outDir,figName),width=10,height=30)
	}else{
		X11(width=1280,height=1280)
	}
	params <- par(bg="white")
	gData<-list()
	nn<-NULL
	if(class(cData)=="MethyLumiQC"){
		ctr.m<-cData@assayData$methylated
		ctr.u<-cData@assayData$unmethylated
		ctr.type<-featureData(cData)@data$Type
		for(i in 1:ncol(ctr.m)){
			dat<-data.frame(type=ctr.type,Grn=ctr.m[,i],Red=ctr.u[,i])
			gData<-c(gData,list(dat))
		}
		names(gData)<-dimnames(ctr.m)[[2]]
		gData<-rfgc(gData)
		nn<-unique(ctr.type)
	}
	else {
		gData<-rfgc(cData)
		nn<-unique(cData[[1]]$type)
	}
	n1<-ceiling(length(nn)/2)
	par(mfrow=c(n1,2))
	gData<-numListData(gData)
	for(i in 1:length(nn)){
		name1<-names(gData[[i]])
		ind<-order(name1)
		dat<-NULL
		dat<-sapply(ind,function(x){c(dat,gData[[i]][[x]])})
		names(dat)<-name1[ind]
		boxplot(dat,col=(i+1),main=nn[i])
	}
	par(params)
	
	if(toFile==TRUE){
		dev.off()
		#shell(file.path(outDir,figName))
	}
}

numListData<-function(dat){
	if(class(dat)!="list")return()
	for(i in 1:length(dat)){
		len<-length(dat[[i]])
		for(j in 1:len){
			dat[[i]][[j]]<-as.numeric(dat[[i]][[j]])
		}
	}
	return(dat)
}
##########
#########
controlPlot_test<-function(){
	cData<-get(print(load(file="C:\\Documents and Settings\\feipan\\workspace\\methPipe\\data\\cDat_test.rdata")))
	gFileDir<-"c:\\temp"
	controlPlot(cData=cData,outDir=gFileDir)
	
	load(file="c:\\temp\\IDAT\\processed\\5640277011_idat.rda")
	controlPlot(mData=idat,outDir="c:\\temp\\IDAT")
}
controlPlot<-function(mData=NULL,cData=NULL,txt=NULL,toSave=T,outDir=NULL,fn=NULL,gtype="png"){
	if(is.null(cData)){
		if(is.null(mData))cData<- get("cData",env=.GlobalEnv)#readControlData(txt);
		else {
			if(class(mData)=="methData")cData<-getCData(mData)
			else if(class(mData)=="MethyLumiSet")cData<-mData@QC #getIDATctrData(mData)
			else{
				cat("unknown data type\n")
				return()
			}
		}
		if(is.null(cData)){
			msg<-"Data has been loaded/generated\n"
			tkmessageBox(message=msg);cat(msg)
			return()
		}
	}

	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to generate the profile plots of the control probes ...",date(),"\n"))
	if(is.null(outDir))outDir<-gFileDir
	if(toSave==TRUE){
		if(is.null(fn)){
			fn<-"control_plot.png" 
			if(gtype=="pdf") fn<-"control_plot.pdf"
		}
		plotControlProfiles(cData,figName=fn,toFile=toSave,outDir,gtype=gtype)
	}else{
		plotControlProfiles(cData,toFile=toSave,gtype=gtype)
	}
	if(!is.null(txt)) tkinsert(txt,"end","> Finished the control probe plots\n")
}

controlPlot.1<-function(mData=NULL,cData=NULL,txt=NULL,toSave=T,outDir=NULL,fn=NULL,gtype="png"){
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to generate the profile plots of the control probes ...",date(),"\n"))
	if(is.null(cData)){
		if(is.null(mData))cData<- get("cData",env=.GlobalEnv)#readControlData(txt);
		else cData<-getCData(mData)
	}
	if(is.null(outDir))outDir<-gFileDir
	if(toSave==TRUE){
		if(is.null(fn)){
			fn<-"control_plot.png" 
			if(gtype=="pdf") fn<-"control_plot.pdf"
		}
		plotControlProfiles(cData,figName=fn,toFile=toSave,outDir,gtype=gtype)
	}else{
		plotControlProfiles(cData,toFile=toSave,gtype=gtype)
	}
	if(!is.null(txt)) tkinsert(txt,"end",">Finished the control probe plots\n")
}

test_plot<-function(){
	Myhscale <- 1.5    # Horizontal scaling
	Myvscale <- 1.5    # Vertical scaling
	tt1 <- tktoplevel()
	tkwm.title(tt1,"A parabola")
	img <- tkrplot(tt1,fun=plotControlProfiles,hscale=Myhscale,vscale=Myvscale)
	tkgrid(img)
	copy.but <- tkbutton(tt1,text="Copy to Clipboard",command=function()CopyToClip())
	tkgrid(copy.but)
	x=-100:100
	y=x^2
	plot(x,y)
}
plotFailureRate_test<-function(){
	outDir<-"c:\\temp\\test2"
	load(file=file.path(outDir,"5543207015_idat.rda"))
	plotFailureRate(outDir=outDir,mData=idat)
	
	load(file="c:\\temp\\IDAT\\processed\\5640277011_idat.rda")
	plotFailureRate(idat,outDir="c:\\temp\\IDAT")
	pvalue2<-calPvalueIDAT(idat,bp.method="z-score",platform="meth450k")
	idat<-assayDataElementReplace(idat,"pvals",pvalue2)
	plotFailureRate(idat,figName="FailureRate2.png",outDir="c:\\temp\\IDAT")
	
	load(file="C:\\temp\\KIRC\\mData.rdata")
	pkg<-attr(mData,"pkgname")
	plotFailureRate(mData,outDir="c:\\temp",batch=pkg)
}
plotFailureRate<-function(mData=NULL,txt=NULL,toSave=T,figName="FailureRate.png",outDir=NULL,pCut=0.05,sCut=0.1,batch=NULL,gtype="png"){
	if(is.null(mData)){
		mData<- get("mData",envir=.GlobalEnv) #loadRawData()
		if(is.null(mData)){
			msg<-"Data has been loaded/generated\n"
			tkmessageBox(message=msg);cat(msg)
			return()
		}
	}
	if(!is.null(txt)) tkinsert(txt,"end",paste("> Start to generate the sample failure rate plot ...",date(),"\n"))
	if(gtype=="pdf") figName<-"FailureRate.pdf"
	failureRate<-NULL;perDetectRate<-NULL
	if(class(mData)=="data.frame"){
		failureRate<-colSums(apply(mData,2,is.na))/ncol(mData)
	}else{
		perDetectRate<-calDetectionRate(mData,pCut)
		failureRate<-perDetectRate[[1]]
	}
	if(is.null(batch)){
		pkg<-attr(mData,"pkgname")
		if(!is.null(pkg)) batch<-pkg
	}
	plotDetectRate(failureRate,toSave,figName,outDir,sCut=pCut,batch=batch,gtype=gtype)
	if(!is.null(txt)) tkinsert(txt,"end","> Finished the sample failure rate plot\n")
	return(perDetectRate)
}
plotFailureRate.1<-function(mData=NULL,txt=NULL,toSave=T,figName="FailureRate.png",outDir=NULL,pCut=0.05,sCut=0.1,gtype="png"){
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to generate the success rate plot ...",date(),"\n"))
	if(is.null(mData)){
		mData<- get("mData",envir=.GlobalEnv) #loadRawData()
	}
	perDetectRate<-calDetectionRate(mData,pCut)
	if(gtype=="pdf") figName<-"FailureRate.pdf"
	plotDetectRate(perDetectRate[[1]],toSave,figName,outDir,sCut,gtype=gtype)
	if(!is.null(txt)) tkinsert(txt,"end",">Finished the success rate plot\n")
	return(perDetectRate)
}
plotSuccessRate_test<-function(){
	mData<-get(print(load(file="C:\\Documents and Settings\\feipan\\workspace\\methPipe\\data\\methData_test.rdata")))
	plotFailureRate(outDir="c:\\temp",mData=mData)
}

controlIndexPlot<-function(txt=NULL,fromRawData=F,out.dir=NULL,toSave=F){
	if(is.null(cData)){
		if(fromRawData==TRUE){
			cData<-loadRawQCData()
		}else{
			cData<-loadQCData()
		}
	}
	
	if(is.null(out.dir)){
		out.dir<-gFileDir #tempdir();
	}
	
	controlIndex<-calControlIndex(cData)
	plotCtrIndex(controlIndex)
	if(toSave==T){
#		qcIndex<-list(dataIndex=perDetectRate,ctrIndex=controlIndex)
#		ctrIndex=list(perDetectRate=perDetectRate,controlIndex=controlIndex)
		#qcIndex<-list(ctrIndex=controlIndex)
		ctrIndex=list(controlIndex=controlIndex)
		save(ctrIndex,file=file.path(out.dir,"ctrIndex.rdata"))
		if(!is.null(txt)){
			tkconfigure(txt, state="normal")
			out<-paste("< Done\n Please check out the control Index report at ",out.dir,"/ctrIndex.rdata",sep="")
			tkinsert(txt,"end",out)
			tkconfigure(txt, state="disabled")
		}
	}
}
plotCtrIndex<-function(controlIndex,outdir=NULL,isLog=T){
	#X11()
	if(is.null(outdir)) outdir<-gFileDir
	figName<-file.path(outdir,"controlIndex.png")
	png(file=figName,width=1280,height=1280)
	len<-ceiling(length(controlIndex)/2)
	par(mfrow=c(len,2))
	#sapply(controlIndex,function(x)barplot(x,col=2:(length(x)+1)))#,main=names(x)))
	name1<-names(controlIndex)
	for(i in 1:length(controlIndex)){
		nm<-name1[i]
		dat<-controlIndex[[i]]
		if(isLog==T){
			dat<--log10(controlIndex[[i]])
		}
		ym<-NULL
		if(length(na.omit(dat)==0)){
			ym<-0.1
			next;
		}else{
			ym<-max(dat,na.rm=T)+0.1
		}
		barplot(dat,col=2:(length(dat)+1),main=nm,ylim=c(0,1))
	}
	dev.off()
	#shell.exec(figName)
}
plotDetectRate_test<-function(){
	perDetectRate<-c(0.0006164334,0.0003626079,0.0008702589,0.0003263471,0.0003263471,0.0001087824,0.0002175647)
	names(perDetectRate)<-c( "TCGA-AA-3675-01A-02D-1110-05","TCGA-AA-3966-01A-01D-1110-05", "TCGA-AA-3970-01A-01D-1110-05","TCGA-AA-3994-01A-01D-1110-05", "TCGA-AY-4070-01A-01D-1110-05","TCGA-AY-4071-01A-01D-1110-05")
	plotDetectRate(perDetectRate,T,"f.png","c:\\temp")
}
plotDetectRate<-function(perDetectRate,toSave,figName,outDir=NULL,sCut=0.05,batch=NULL,gtype="png"){
	width<-length(perDetectRate)*15
	if(width<1200) width<-1200
	color<-2:(length(perDetectRate)+1)
	if(!is.null(batch))color<-color.batch(batch)
	if(toSave==TRUE){
		if(is.null(outDir)) outDir<-gFileDir
		if(gtype=="png")png(file.path(outDir,figName),width=width,height=1200)
		else pdf(file.path(outDir,figName),width=10,height=10)
	}else{
		X11()
	}
	tit<-paste("Proportion of Probes with Detection Pvalue Greater than and Equal to",sCut)
	par(las=3,mar=c(10,4,4,2)+0.1,cex.lab=0.1)
	ylim<-ifelse(max(perDetectRate)>sCut,max(perDetectRate),sCut)+0.05
	barplot(perDetectRate,col=color,main=tit,ylim=c(0,ylim),border=T)
	abline(sCut,0,col="red")
	if(!is.null(batch)){
		legend("top",unique.2(batch),fill=unique.2(color))
	}
	if(toSave==TRUE){
		dev.off()
	}
}

plotDetectRate.1<-function(perDetectRate,toSave,figName,outDir=NULL,sCut=0.1,gtype="png"){
	if(toSave==TRUE){
		if(is.null(outDir)) outDir<-gFileDir
		if(gtype=="png")png(file.path(outDir,figName),width=1200,height=1200)
		else pdf(file.path(outDir,figName),width=10,height=10)
	}else{
		X11()
	}
	tit<-"Proportion of Probes with Detection Pvalue Greater than 0.05"
	par(las=3,mar=c(10,4,4,2)+0.1,cex.lab=0.1)
	ylim<-ifelse(max(perDetectRate)>sCut,max(perDetectRate),sCut)+0.05
	barplot(perDetectRate,col=2:(length(perDetectRate)+1),main=tit,ylim=c(0,ylim),border=T)
	abline(sCut,0,col="red")
	if(toSave==TRUE){
		dev.off()
	}
}

calControlIndex<-function(cData){
	ctrIndex<-list()
	ctr.summary<-lapply(cData,function(x)summary(x))
	cdat<-rfgc(cData)
	ctr.pvalue<-lapply(cdat,calPvalue)
	calPvalue<-function(dat){
		len<-length(dat)
		pvalue<-c()
		len1<-seq(1,len,2)
		for(i in len1){
			dat.1<-as.numeric(dat[[i]])
			dat.2<-as.numeric(dat[[(i+1)]])
			p.value<-NA
			if(length(na.omit(dat.1))>=3 & length(na.omit(dat.2))>=3){
				wtest<-wilcox.test(dat.1,dat.2)
				p.value<-wtest$p.value
			}
			pvalue<-c(pvalue,p.value)
		}
		return(pvalue)
	}
	return(ctr.pvalue)
}
calPvalueIDAT_test<-function(){
	library(methylumIDAT)
	load(file="c:\\temp\\test2\\meth27k\\processed\\5543207015\\5543207015_idat.rda")
	pv<-calPvalueIDAT(idat)
	load(file="c:\\temp\\IDAT\\5640277011\\5640277011_idat.rda")
	pv<-calPvalueIDAT(idat,platform="meth450k")
}
calPvalueIDAT<-function(idat,p.method="z-score",platform="meth27k"){
	if(platform=="meth27k")data(NegCtlCode)
	else if(platform=="meth450k") data(NegCtlCode450)
	ctl_code<-ctl_code[,1]
	fdat<-featureData(idat@QC)@data$Address
	cdat.m<-idat@QC@assayData$methylated
	cdat.u<-idat@QC@assayData$unmethylated
	ind<-is.element(fdat,ctl_code)
	cdat.neg.m<-cdat.m[ind,]
	cdat.neg.u<-cdat.u[ind,]
	dat.m<-idat@assayData$methylated
	dat.u<-idat@assayData$unmethylated
	pvalue.m<-calpvalue.2(dat.m,cdat.neg.m,pvalue.method=p.method)
	pvalue.u<-calpvalue.2(dat.u,cdat.neg.u,pvalue.method=p.method)
	pvalue<-ifelse(dat.m>dat.u,pvalue.m,pvalue.u)
	dimnames(pvalue)<-dimnames(dat.m)
	attr(pvalue,"p.method")<-p.method
	return(pvalue)
}

calpvalue.2<-function(dat,ctr,pvalue.method="z-score",alternative="less"){
	pvalue<-matrix(1,ncol=ncol(dat),nrow=nrow(dat),dimnames=dimnames(as.matrix(dat)))	
	if(pvalue.method=="z-score"){
		for(i in 1:nrow(dat)){
			for(j in 1:ncol(dat)){
				pvalue[i,j]<-pnorm((dat[i,j]-mean(ctr[,j],na.rm=T))/sd(ctr[,j],na.rm=T),lower.tail=F)
			}
		}
	}else if(pvalue.method=="z-test"){
		for(i in 1:nrow(dat)){
			for(j in 1:ncol(dat)){
				pvalue[i,j]<-pnorm((dat[i,j]-mean(ctr[,j],na.rm=T))/sd(ctr[,j],na.rm=T)/sqrt(length(ctr[,j])),lower.tail=F)
			}
		}
	}else if(pvalue.method=="t-test"){
		for(i in 1:nrow(dat)){
			for(j in 1:ncol(dat)){
				if(!is.na(dat[i,j])) pvalue[i,j]<-t.test(ctr[,j],mu=dat[i,j],alternative=alternative)$p.value
				else pvalue[i,j]<-NA
			}
		}
		
	}else if(pvalue.method=="mw-test"){
		for(i in 1:nrow(dat)){
			for(j in 1:ncol(dat)){
				options(warn=-1)
				if(!is.na(dat[i,j]))pvalue[i,j]<-wilcox.test(ctr[,j],mu=dat[i,j],alternative=alternative,exact=T)$p.value
				else pvalue[i,j]<-NA
				options(warn=0)
			}
		}
	}else{
		stop("pvalue.method is unknown")
		
	}
	return(pvalue)
}

calpvalue<-function(dat,ctr,pvalue.method="z-score",alternative="less"){
	pvalue<-matrix(1,ncol=ncol(dat),nrow=nrow(dat))
	
	if(pvalue.method=="z-score"){
		pvalue=pnorm((dat-mean(ctr,na.rm=T))/sd(ctr,na.rm=T),lower.tail=F)
	}else if(pvalue.method=="z-test"){
		pvalue<-pnorm((dat-mean(ctr,na.rm=T))/sd(ctr,na.rm=T)/sqrt(length(ctr)),lower.tail=F)
	}else if(pvalue.method=="t-test"){
		for(i in 1:nrow(dat)){
			for(j in 1:ncol(dat)){
				
				pvalue[i,j]<-t.test(ctr,mu=dat[i,j],alternative=alternative)$p.value
			}
		}
		
	}else if(pvalue.method=="mw-test"){
		
		for(i in 1:nrow(dat)){
			for(j in 1:ncol(dat)){
				pvalue[i,j]<-wilcox.test(ctr,mu=dat[i,j],alternative=alternative)$p.value
			}
		}
	}else{
		stop("pvalue.method is unknown")
		
	}
	return(pvalue)
}

calpvalue_test<-function(){
	dat<-matrix(rnorm(20),nrow=2)
	ctr<-rnorm(16,0.1)
	pv<-calpvalue(dat,ctr,"z-test")
	pv1<-calpvalue(dat,ctr,"z-score")
	pv2<-calpvalue(dat,ctr,"t-test")
	pv3<-calpvalue(dat,ctr,"mw-test")
}
calZscore_test<-function(){
	dat<-matrix(c(0.1,0.4,1,3),nrow=2)
	ctr<-matrix(rnorm(100),nrow=2)
	score<-calZscore(dat,ctr,"rapidGUI")
	
	dat<-matrix(rnorm(20),ncol=2)
	ctr<-rnorm(16,0.1)
	ctr<-matrix(ctr,ncol=2,nrow=16,byrow=F)
	score<-calScore(dat,ctr,"rapidGUI")
}
calZscore<-function(dat,ctr,package="rapid.pro",pvalue=T){
	if(ncol(dat)!=ncol(ctr))return()
	library.dynam(package,package)
	mu<-apply(ctr,2,function(x)mean(x,na.rm=T));se<-apply(ctr,2,function(x)sd(x,na.rm=T)/sqrt(length(x)))
	rst<-.C("zscore",rst=as.double(dat),as.integer(nrow(dat)),as.integer(ncol(dat)),as.double(mu),as.double(se))$rst
	if(pvalue==T)rst<-pnorm(rst,lower.tail=F)
	return(matrix(rst,nrow=nrow(dat)))
}
calScore<-function(dat,ctr,package="rapid.pro",pvalue=T){
	if(ncol(dat)!=ncol(ctr))return()
	library.dynam(package,package)
	mu<-apply(ctr,2,function(x)mean(x,na.rm=T));sd<-apply(ctr,2,function(x)sd(x,na.rm=T))
	rst<-.C("zscore",rst=as.double(dat),as.integer(nrow(dat)),as.integer(ncol(dat)),as.double(mu),as.double(sd))$rst
	if(pvalue==T)rst<-pnorm(rst,lower.tail=F)
	return(matrix(rst,nrow=nrow(dat)))
}
calDetectionRate<-function(mData,threshold=0.05){
	if(is.null(mData)){
		cat("mData is null\n")
		return;
	}
	mData.beta<-NULL;mData.pvalue<-NULL;mData.M<-NULL;mData.U<-NULL;sampID<-NULL
	if(class(mData)=="MethyLumiSet"){
		mData.beta<-mData@assayData$betas
		mData.pvalue<-mData@assayData$pvals #calPvalueIDAT(mData)
		mData.M<-mData@assayData$methyalted
		mData.U<-mData@assayData$unmethylated
		sampID<-dimnames(mData.M)[[2]]
	}else{
		mData.beta<-getBeta(mData)
		mData.pvalue<-getPvalue(mData)
		mData.M<-getM(mData)
		mData.U<-getU(mData)
		sampID<-getID(mData)
	}
	n.col<-ncol(mData.beta)
	n.row<-nrow(mData.beta)
	mData.summary<-c()
	summary.M<-summary(mData.M)
	summary.U<-summary(mData.U)
	summary.beta<-summary(mData.beta)
	summary.pvalue<-summary(mData.pvalue)
	mData.rate<-c()
	for(i in 1:n.col){
		summary.detectionRate<-sum(as.numeric(mData.pvalue[,i])>threshold,na.rm=T)/n.row
		mData.rate<-c(mData.rate,summary.detectionRate)
		
	}
	names(mData.rate)<-sampID
	mData.summary<-list(mData.rate,summary.M,
			summary.U,summary.beta,
			summary.pvalue)
	return(mData.summary)
}

normalizationPlot<-function(data,data.norm,batch,toSave=T,outDir=NULL,gtype="png"){
	if(toSave==F)X11()
	else{
		width<-ncol(data)*10; 
		if(gtype=="png"){
			if(!is.null(outDir)) fn<-file.path(outDir,"norm_plot.png")
			else fn<-file.path(gFileDir,"norm_plot.png")
			png(filename=fn,width=width,height=640)
		}else{
			if(!is.null(outDir))fn<-file.path(outDir,"norm_plot.pdf")
			else fn<-file.path(gFileDir,"norm_plot.pdf")
			pdf(fn,width=12,height=10)
		}
	}
	par(mfrow=c(2,1))
	boxplot(data,col=color.batch(batch),main="Beta Value Before Normalization")
	boxplot(data.norm,col=color.batch(batch),main="Beta Value After Normalization")
	if(toSave==T) {
		dev.off()
		#shell(fn)
	}
}
scatterPlots<-function(dat,dat.norm,outDir){
	dat.norm<-get(load(file="c:\\temp\\KIRC\\beta.ctr.norm.rdata"));outDir<-"c:\\temp"
	scatterPlot(na.omit(dat),"Control Sample Before Normalization",fn=file.path(outDir,"control.png"))
	scatterPlot(na.omit(dat.norm),"Control Sample After Normalization",fn=file.path(outDir,"control.norm.png"))
}
scatterPlot<-function(data,title="",fn=NULL,isTCGA=T){
	diag.panel = function (x, ...) {
		par(new = TRUE)
		hist(x, 
				col = "light blue", 
				probability = TRUE, 
				axes = FALSE, 
				main = "")
		lines(density(x), 
				col = "red", 
				lwd = 3)
		rug(x)
	}
	
	panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
	{
		usr <- par("usr"); on.exit(par(usr))
		par(usr = c(0, 1, 0, 1))
		r <- abs(cor(x, y))
		txt <- format(c(r, 0.123456789), digits=digits)[1]
		txt <- paste(prefix, txt, sep="")
		if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
		text(0.5, 0.5, txt, cex = cex.cor * r)
	}
	if(is.null(fn))X11()
	else png(filename=fn,width=ncol(data)*100,height=ncol(data)*100)
	if(isTCGA==T){
		data<-as.data.frame(data)
		nm<-gsub("\\.","-",names(data))
		names(data)<-sapply(nm,function(x)paste(c("    ",strsplit(x,"-")[[1]][5:6]),collapse="."))
	}
	pairs(data,main=title,
			lower.panel=panel.smooth,
			diag.panel =diag.panel,
			upper.panel=panel.cor)
	if(!is.null(fn)) dev.off()
}

normalizationPlot.1<-function(data){
	X11()
	boxplot(data,col="green",main="boxplot of the normalized data")
	
	diag.panel = function (x, ...) {
		par(new = TRUE)
		hist(x, 
				col = "light blue", 
				probability = TRUE, 
				axes = FALSE, 
				main = "")
		lines(density(x), 
				col = "red", 
				lwd = 3)
		rug(x)
	}
	
	
	
	panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
	{
		usr <- par("usr"); on.exit(par(usr))
		par(usr = c(0, 1, 0, 1))
		r <- abs(cor(x, y))
		txt <- format(c(r, 0.123456789), digits=digits)[1]
		txt <- paste(prefix, txt, sep="")
		if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
		text(0.5, 0.5, txt, cex = cex.cor * r)
	}
	X11()
	pairs(data,main="scatter plot of the normalizaed data",
			lower.panel=panel.smooth,
			diag.panel =diag.panel,
			upper.panel=panel.cor)
}
plotDensity<-function(dat,color=NULL,xlab="",ylab="",main=""){
	if(is.null(color))plot(density(na.omit(dat[,1])),main=main,col=1)
	else plot(density(na.omit(dat[,1])),main=main,col=color[1])
	if(ncol(dat)>=2){
		for(i in 2:ncol(dat)){
			par(new=T,yaxt="n",xaxt="n")
			if(is.null(color))plot(density(na.omit(dat[,i])),main=main,col=i,xlab=xlab,ylab=ylab)
			else plot(density(na.omit(dat[,i])),main=main,col=color[i],xlab=xlab,ylab=ylab)
		}
	}
}

plotDensity.2<-function(dat,color=NULL,xlab="",ylab="",main="",fn=NULL){
	if(is.null(fn)){
		X11()
	}
	else{
		png(filename=fn,width=1280,height=640)
	}
	if(is.null(color))plot(density(na.omit(dat[,1])),main=main,col=1)
	else plot(density(na.omit(dat[,1])),main=main,col=color[1])
	if(ncol(dat)>=2){
		for(i in 2:ncol(dat)){
			par(new=T,yaxt="n",xaxt="n")
			if(is.null(color))plot(density(na.omit(dat[,i])),main=main,col=i,xlab=xlab,ylab=ylab)
			else plot(density(na.omit(dat[,i])),main=main,col=color[i],xlab=xlab,ylab=ylab)
		}
	}
	if(!is.null(fn)) dev.off()
}
boxplot.2<-function(dat,color=NULL,main="",fn=NULL){
	if(is.null(fn)){
		X11()
	}else{
		png(filename=fn,width=1280,height=640)
	}
	if(!is.null(color)) color<-color.batch(color)
	boxplot(dat,col=color,main=main)
	if(!is.null(fn)) dev.off()
}
###################
#
####################
plotDetectionPvalue_test<-function(){
	data(mData)
	plotDetectionPvalue(mdat=mData,outDir="c:\\temp")
}
plotDetectionPvalue<-function(txt=NULL,mdat=NULL,outDir=NULL,fn=NULL){
	if(is.null(mdat)) mdat<-get("mData",env=.GlobalEnv)
	if(is.null(outDir)) outDir<-gFileDir
	if(is.null(fn)) fn<-"DetectPvalue.png"
	pv<-getPvalue(mdat)
	bv<-getBeta(mdat)
	png(filename=file.path(outDir,fn),height=640,width=640)
	par(mfrow=c(1,2),ylog=T)
	plot(as.numeric(bv),as.numeric(pv),main="",col=1,xlim=c(0,1),xlab="Beta value",ylab="Detection P Value")
	plot(density(as.numeric(pv)),xlim=c(0,0.005),main="")
	dev.off()
}


##########
# util
###########
color.batch<-function (batch) 
{
	color.numb <- table(batch)
	color.numb<-color.numb[unique.2(batch)]
	color <- c()
	for (i in 1:length(color.numb)) {
		ii <- i + 1
		color <- c(color, rep(ii, color.numb[i]))
	}
	color
}
unique.2<-function(dats){
	rst<-c()
	for(dat in dats){
		if(!is.element(dat,rst)) rst<-c(rst,dat)
	}
	return(rst)
}
compareDataFile_test<-function(){
	betas<-"c:\\temp\\IDAT\\processed\\BetaValue.csv"
	betas2<-"c:\\temp\\IDAT\\processed\\BetaValue.lvl2.csv"
	compareDataFile(betas,betas2)
}
compareDataFile<-function(idatFn=NULL,mdatFn=NULL){
	if(is.null(idatFn))idatFn<-"C:\\temp\\test3\\meth27k\\processed\\5543207013\\Methylation_Signal_Intensity.csv"
	if(is.null(mdatFn))mdatFn<-"C:\\temp\\test2\\meth27k\\processed\\5543207013\\Methylation_Signal_Intensity.csv"
	idat<-read.delim(file=idatFn,sep=",",row.names=1)
	mdat<-read.delim(file=mdatFn,sep=",",row.names=1)
	#mdat<-round(mdat)
	mdat<-mdat[,names(idat)]
	mdat<-mdat[row.names(idat),]
	cat("The number of NA in the first data is\n");show(table(is.na(idat)))
	cat("The number of NA in the second data is\n");print(table(is.na(mdat)))
	summary(idat)
	summary(mdat)
	dat<-data.frame(idat,mdat)
	ind<-c(seq(1,ncol(dat),2),seq(2,ncol(dat),2));dat<-dat[,order(ind)]
	color<-rep(3,ncol(dat));color[seq(1,ncol(dat),2)]<-2;y.min<-min(dat[,1],na.rm=T)*0.9;y.max<-max(dat[,1],na.rm=T)*1.2
	boxplot(dat,col=color,ylim=c(y.min,y.max));legend("topright",legend=c(filetail(idatFn),filetail(mdatFn)),fill=color)
	dif<-abs(idat-mdat)
	summary(dif)
}