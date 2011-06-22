# TODO: Add comment
# 
# Author: feipan
###############################################################################

runPBR<-function(txt){
	linearNormalization(txt)
}
runRBnorm<-function(txt){
	linearNormalization(txt,method="RBN")
}
runMAnorm<-function(txt){
	require(limma)
	fileName<-tclvalue(tkgetOpenFile(filetypes="{{{CSV File} {.csv}} {{All File} *}}"))
	if(!nchar(fileName)){
		msg<-"pls select a data matrix file first\n"
		tkmessageBox(message=msg)
		stop(msg)
	}
	dataAll<-readDataFile.2(fileName,header1=T)
	dataNorm<-normalizeBetweenArrays(as.matrix(dataAll))
	return(dataNorm)
}
runPBR_ADJ<-function(txt){
	require(PBR)
	PBR_AdjDialog("PBR ADJ Normalization")
	if(!exists("Normalization_dataAll"))return()
	if(!nchar(Normalization_dataAll)||!nchar(Normalization_batch_set_ref)){
		msg<-"Please select the data matrix and batch set reference\n"
		tkmessageBox(message=msg)
		stop(msg)
	}
	dataAll<-readDataFile.2(Normalization_dataAll,header1=T)
	dataFactor<-readDataFile.2(Normalization_batch_set_ref,header1=T)
	ord<-order(names(dataFactor))
	if(nrow(dataAll)!=nrow(dataFactor) | !any(names(dataFactor)==names(dataAll))){
		cat("data matrix should have the same length and col name of data batch set ref\n")
	}
	dataFactor<-dataFactor[,ord]
	dataAll<-dataAll[,order(names(dataAll))]
	dataBatch<-dataFactor[1,]
	dataSet<-dataFactor[2,]
	dataRef<-dataFactor[3,]
	dataNorm<-PBR.ADJ(dataAll,dataBatch,dataSet,dataRef)
	if(exists("Normalization_dataAll"))rm("Normalization_dataAll",envir=.GlobalEnv)
	if(exists("Normalization_batch_set_ref"))rm("Normalization_batch_set_ref",envir=.GlobalEnv)
	return(dataNorm)
}
linearNormalization_test<-function(){
	reValue<-c("c:\\temp\\READ\\beta.txt","c:\\temp\\READ\\batch.txt","c:\\temp\\READ\\control.txt")
	linearNormalization()
}
linearNormalization<-function(txt=NULL,toPlot=T,toSave=T,method="PBR"){
	require(PBR)
	linearNormalizationDialog("PBR Batch Normalization")
	if(is.null(reValue))return()
	normalization_FN_Y<-reValue[1];normalization_FN_Batch<-reValue[2];normalization_FN_Batch_new<-reValue[3]
	y<-NULL;x<-NULL;y.new=NULL;x.new=NULL;y.norm=NULL;
	scaling=TRUE;median=FALSE
	if(filedir(normalization_FN_Y)==""){
		if(!exists(normalization_FN_Y) ||!exists(normalization_FN_Batch) ){
			msg=paste("> Please check the data",normalization_FN_Y,"and",normalization_FN_Batch," has been loaded")
			tkinsert(txt,"end",msg)
			stop(msg)
		}
		y<-normalization_FN_Y;x<-normalization_FN_Batch
	}else{
		if(!is.null(txt)){
			msg=paste("> Input data data file is: ",normalization_FN_Y,"\n",sep="")
			tkinsert(txt,"end",msg)
			msg=paste("> Input batch data file is:",normalization_FN_Batch,"\n",sep="")
			tkinsert(txt,"end",msg)
		}
		
		y<-readDataFile.2(normalization_FN_Y,header1=T,rowName=1)
		x<-readDataFile.2(normalization_FN_Batch,header1=T,isNum=F,rowName=1)
		nm<-names(x);x<-as.character(x[1,]);names(x)<-nm
		if(length(x)!=ncol(y)){
			msg<-"> Please check the number of the batches is the same as the number of samples in the data\n"
			if(!is.null(txt)) tkinsert(txt,"end",msg)
			stop(msg)
		}
	}
	ord<-order(names(x))
	x<-x[ord]
	y<-y[,order(names(y))]
	if(!any(names(x)==names(y))){
		msg<-"> Please check the name of the batches match the names of the data\n"
		if(!is.null(txt)) tkinsert(txt,"end",msg)
		stop(mst)
	}
		
	if(file.exists(normalization_FN_Batch_new)){
		if(!is.null(txt)){
			msg=paste("> Input control meta data file is: ",normalization_FN_Batch_new,"\n",sep="")
			tkinsert(txt,"end",msg)
		}
		x.new<-readDataFile.2(normalization_FN_Batch_new,header1=T,isNum=F,rowName=1)
		nm<-names(x.new);x.new<-as.numeric(x.new[1,]);names(x.new)<-nm
		if(length(x.new)!=ncol(y)){
			msg<-"> Please check dimension the control sample data.\n"
			if(!is.null(txt)) tkinsert(txt,"end",msg)
			stop(msg)
		}
		ord<-order(names(x.new))
		x.new<-x.new[ord]
		if(!any(names(x.new)==names(y))){
			msg<-"> Please check name of control data.\n"
			if(!is.null(txt)) tkinsert(txt,"end",msg)
			stop(msg)
		}
		ind<-which(x.new=="1")
		if(length(ind)>0) {
			y.new<-y[,ind];y<-y[,-ind]
			x.new<-x[ind];x<-x[-ind]
		}else{
			msg<-"> The control meta data should be TRUE/FALSE, T/F, or 1/0.\n"
			if(!is.null(txt))tkinsert(txt,"end",msg);
			stop(msg)
		}
	}
	
	if(!is.null(txt))tkinsert(txt,"end",paste("> Start to normalize data...",date(),"\n"))
	outDir<-filedir(normalization_FN_Y)
	y.norm<-PBR(y,x,scaling=scaling,median=median)
	if(toPlot==T)normalizationPlot(y,y.norm,x,outDir=outDir)
	if(!is.null(x.new)){
		y.new.norm<-PBR(y,x,y.new,x.new,scaling=scaling,median=median)
		if(toPlot==T)scatterPlots(y.new,y.new.norm,outDir)
	}
	if(toSave==TRUE) {
		fn<-file.path(outDir,"beta.norm.csv")
		write.table(as.data.frame(y.norm),file=fn,row.names=T,sep=",",quote=F)
		save(y.norm,file=file.path(outDir,"beta.norm.rdata"))
		if(!is.null(x.new))save(y.new.norm,file=file.path(outDir,"beta.ctr.norm.rdata"))
		msg<-paste("> Finished data normalization.",date()," \nPlease check out the normalized data at ",fn,"\n",sep="")
		if(!is.null(txt))tkinsert(txt,"end",msg);cat(msg)
	}
	return(y.norm)
}
#linearNormalization<-function(txt=NULL,toPlot=F,toSave=T,method="PBR"){
#	require(PBR)
#	linearNormalizationDialog("Batch Normalization")
#	if(!exists("normalization_FN_Y"))return()
#	if(!nchar(normalization_FN_Y) ||!nchar(normalization_FN_Batch) ||!nchar(normalization_Scaling) ||!nchar(normalization_Median)){
#		msg=">Please check the data has been loaded"
#		tkinsert(txt,"end",msg)
#		stop(msg)
#	}
#	if(!is.null(txt)){
#		msg=paste("> Input data file ",normalization_FN_Y,"\n",sep="")
#		tkinsert(txt,"end",msg)
#		msg=paste("> Input batch file ",normalization_FN_Batch,"\n",sep="")
#		tkinsert(txt,"end",msg)
#	}
#	
#	#y<-read.table(file=normalization_FN_Y,sep=",",header=T,row.names=1)
#	#x<-read.table(file=normalization_FN_Batch,sep=",",header=T,row.names=1)
#	y<-readDataFile.2(normalization_FN_Y,header1=T)
#	x<-readDataFile.2(normalization_FN_Batch,header1=T,isNum=F)
#	x<-as.factor(x[1,])
#	if(length(x)!=ncol(y)){
#		msg<-"Please check the number of the batches is the same as the number of samples in the data\n"
#		if(!is.null(txt)) tkinsert(txt,"end",msg)
#		stop(msg)
#	}
#	ord<-order(names(x))
#	x<-x[ord]
#	y<-y[,order(names(y))]
#	if(!any(names(x)==names(y))){
#		msg<-"Please check the name of the batches match the names of the data\n"
#		if(!is.null(txt)) tkinsert(txt,"end",msg)
#		stop(mst)
#	}
#	y.new=NULL;
#	x.new=NULL;
#	y.norm=NULL;
#	scaling <- normalization_Scaling
#	median <- normalization_Median
#	if(exists("normalization_FN_Y_new") && exists("normalization_FN_Batch_new")){
#		if(!is.null(txt)){
#			msg=paste(">Input new data file ",normalization_FN_Y_new,"\n",sep="")
#			tkinsert(txt,"end",msg)
#			msg=paste(">Input new batch file ",normalization_FN_Batch_new,"\n",sep="")
#			tkinsert(txt,"end",msg)
#		}
##		y.new<-read.table(file=normalization_FN_Y_new,header=T,sep=",",row.names=1)
##		x.new<-read.table(normalization_FN_Batch_new,header=T,sep=",",row.names=1)
#		y.new<-readDataFile.2(normalization_FN_Y_new,header1=T)
#		x.new<-readDataFile.2(normalization_FN_Batch_new,header1=T)
#		x.new<-as.factor(x.new[1,])
#		if(length(x.new)!=ncol(y.new)){
#			msg<-"check data.new\n"
#			if(!is.null(txt)) tkinsert(txt,"end",msg)
#			stop(msg)
#		}
#		ord<-order(x.new)
#		x.new<-x.new[ord]
#		y.new<-y.new[,ord]
#		if(!any(names(x.new)==names(y.new))){
#			msg<-"check name of data new..\n"
#			if(!is.null(txt)) tkinsert(txt,"end",msg)
#			stop(msg)
#		}
#		y.norm<-PBR(y,x,y.new,x.new,scaling=scaling,median=median)
#	}else{
#		y.norm<-PBR(y,x,scaling=scaling,median=median)
#	}
#	if(toPlot==TRUE) normalizationPlot(y.norm)
#	if(toSave==TRUE) {
#		fn<-paste(normalization_FN_Y,".csv",sep="")
#		write.table(as.dataframe(y.norm),file=fn,row.names=F,sep=",")
#		cat(paste(">Done. Please check out the normalized data at ",fn,"\n",sep=""))
#	}
#	if(exists("normalization_FN_Y"))rm("normalization_FN_Y",envir = .GlobalEnv)
#	if(exists("normalization_FN_Batch"))rm("normalization_FN_Batch",envir = .GlobalEnv)
#	if(exists("normalization_FN_Y_new"))rm("normalization_FN_Y_new",envir = .GlobalEnv)
#	if(exists("normalization_FN_Batch_new"))rm("normalization_FN_Batch_new",envir = .GlobalEnv)
#	if(exists("normalization_Scaling"))rm("normalization_Scaling",envir = .GlobalEnv)
#	if(exists("normalization_Median"))rm("normalization_Median",envir = .GlobalEnv)
#	return(y.norm)
#}
PBR_AdjDialog<-function(title=""){
	dlg<-startDialog(title)
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"DNA Methylation Beta Value Data File:","",name="betaFn")
	addTextEntryWidget(dlg1,"DNA Methylation Batch Meta Data File:","",name="batchFn")
	addTextEntryWidget(dlg1,"Reference Sample Set Data File:","",name="refSampSetFn")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("betaFn","batchFn","refSampSetFn"))
}

linearNormalizationDialog<-function(title=""){
	dlg<-startDialog(title)
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"DNA Methylation Beta Value Data File:","",name="normalization_FN_Y")
	addTextEntryWidget(dlg1,"DNA Methylation Batch Meta Data File:","",name="normalization_FN_Batch")
	#addTextEntryWidget(dlg1,"Control Sample Beta Value Data File (opt):","",name="normalization_FN_Y_new")
	addTextEntryWidget(dlg1,"Control Sample Meta Data File (opt):","",name="normalization_Batch_new")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("normalization_FN_Y","normalization_FN_Batch","normalization_Batch_new"))
}


ebaysNormalization<-function(txt){
	tkmessageBox(
			message = "This feature is under development")

}
fitModel.linear <- function(y,x){
	mod.ln<-function(y1,x){
		x<-as.factor(x)
		y1<-as.numeric(y1)
		mod <- lm(y1~x)
		mod$residuals+mean(y1)
	}
	t(apply(y,1,mod.ln,x))
}

fitModel.ln2b <- function(y,x,y.new,x.new,scaling=TRUE,median=FALSE,debug=F,capMethod="capMax"){
	if(debug){
		browser()
	}
	if(is.null(y) || is.null(x) ||is.null(y.new)||is.null(x.new)){
		stop("please check the input data is not NULL\n")
	}
	if(dim(y)[1]!=dim(y.new)[1]){
		stop("The row number of the y and y.new are expected to be the same\n")
	}
	x<-as.factor(x)
	if(nlevels(x)<nlevels(as.factor(x.new))){
		stop("please check the number of the levels of x is not less than that of x.new\n")
	}
	if(ncol(y.new)!=length(x.new)){
		stop("please check the input of batch.new and y.new,same number of col are expected.\n")
	}
	x.new<-factor(x.new,levels=levels(x))
	n.row <- nrow(y.new)
	n.col <- ncol(y.new)
	y.norm <- NULL
	y.new <- y.new[,order(x.new)]
	x.new <-x.new[order(x.new)]
	
	rep.batch<-function(y,batch,batch.new){
		batch=levels(batch)
		dat<-data.frame(Y=y,batch=batch)
		dat1<-data.frame(batch.new=batch.new)
		rst<-merge(dat1,dat,by.x=1,by.y=2,all.x=T)
		rst<-rst[order(batch.new),]
		return(rst$Y)
	}
	for(i in 1:dim(y.new)[1]){
		y1<-as.numeric(y[i,])
		if(median==T){
			md<-tapply(y1,x,median)
			y.pred<-rep.batch(md,x,x.new)
			if(scaling){
				y.pred<-y.new[i,]*median(y1)/y.pred
			}else{
				y.pred<y.new[i,]-y.pred+median(y1)
			}
		}else{#case of median==F
			md<-tapply(y1,x,mean)
			y.pred<-rep.batch(md,x,x.new)
			if(scaling==T){
				y.pred<-y.new[i,]*mean(y1)/y.pred
			}else{
				#case of scaling ==F
				y.pred<-y.new[i,]-y.pred+mean(y1)
			}
		}
		y.pred <-as.numeric(y.pred)
		y.norm <-c(y.norm,y.pred)
		if(capMethod == "capMax"){
			y.norm<-replace(y.norm,which(y.norm>1),1)
		} else if(capMethod=="fisher"){ #linear trans
			require(VGAM)
			y.norm<-fisherz(y.norm,inverse=T)
		}
	}
	matrix(y.norm,n.row,n.col)
}
fitModel.ln2 <- function(y,x,y.new,x.new,scaling=TRUE,median=FALSE,debug=F,capMax=T){
	if(debug){
		browser()
	}
	if(is.null(y) || is.null(x) ||is.null(y.new)||is.null(x.new)){
		stop("please check the input data is not NULL\n")
	}
	if(dim(y)[1]!=dim(y.new)[1]){
		stop("The row number of the y and y.new are expected to be the same\n")
	}
	x<-as.factor(x)
	if(nlevels(x)<nlevels(as.factor(x.new))){
		stop("please check the number of the levels of x is not less than that of x.new\n")
	}
	if(ncol(y.new)!=length(x.new)){
		stop("please check the input of batch.new and y.new,same number of col are expected.\n")
	}
	x.new<-factor(x.new,levels=levels(x))
	n.row <- nrow(y.new)
	n.col <- ncol(y.new)
	y.norm <- NULL
	y.new <- y.new[,order(x.new)]
	x.new <-x.new[order(x.new)]
#	rep.batch<-function(y,batch){
#		n.batch <- as.numeric(lapply(split(batch,batch),length))
#		y.tot <-NULL
#		for(i in 1:nlevels(batch)){
#			y.tot<-c(y.tot,rep(y[i],n.batch[i]))
#		}
#		return(y.tot)
#	}
	rep.batch<-function(y,batch,batch.new){
		batch=levels(batch)
		dat<-data.frame(Y=y,batch=batch)
		dat1<-data.frame(batch.new=batch.new)
		rst<-merge(dat1,dat,by.x=1,by.y=2,all.x=T)
		rst<-rst[order(batch.new),]
		return(rst$Y)
	}
	for(i in 1:dim(y.new)[1]){
		y1<-as.numeric(y[i,])
		if(median==T){
			md<-tapply(y1,x,median)
			y.pred<-rep.batch(md,x,x.new)
			if(scaling){
				y.pred<-y.new[i,]*median(y1)/y.pred
			}else{
				y.pred<y.new[i,]-y.pred+median(y1)
			}
		}else{#case of median==F
			mod <- lm(y1~x)
			coef <- mod$coefficients
			names(coef)<-names(table(x))
			y.pred <- c(coef[1],c(coef+coef[1])[-1])
			#y.pred=y.new[i,]-rep.batch(y.pred,x.new)+mean(y1)
			y.pred<-rep.batch(y.pred,x,x.new)
			if(scaling==T){
				y.pred<-y.new[i,]*mean(y1)/y.pred
			}else{
				#case of scaling ==F
				y.pred<-y.new[i,]-y.pred+mean(y1)
			}
		}
		y.pred <-as.numeric(y.pred)
		y.norm <-c(y.norm,y.pred)
		if(capMax==T) y.norm<-replace(y.norm,which(y.norm>1),1)
	}
	matrix(y.norm,n.row,n.col)
}

simBetaData<-function(){
#	batch <- as.factor(rep(c(1,2,3),3))
#	M <- matrix(rgamma(900,0.8),100,9)
#	U <- matrix(rgamma(900,0.4),100,9)
#	beta.raw <- M/(M+U)
	
	batch <- as.factor(rep(c(1,2,3),3))
	beta.raw <- matrix(rbeta(900,0.8,0.5),100,9)
	return(list(beta=beta.raw,batch=batch))
}
simNormData<-function(){
	dat <- matrix(rnorm(1000),50,20)
	batch<-as.factor(c(rep(c(1,2,3),6),1,3))
	dat.new<-matrix(rnorm(300),50,6)
	batch.new<-as.factor(c(1,2,3,1,2,2))
	return(list(beta=dat,batch=batch,beta.new=dat.new,batch.new=batch.new))
}

#################
# from PBR packages
################
PBR<-function (y, x, y.new = NULL, x.new = NULL, scaling = TRUE, median = FALSE) 
{
	if (!is.factor(x)) 
		x <- factor(x)
	y.all <- y
	if (!is.null(x.new)) {
		x.new <- factor(x.new)
		y.all <- cbind(as.data.frame(y), as.data.frame(y.new))
	}
	PBR1 <- function(y.all, x, x.new = NULL, scaling = TRUE, 
			median = TRUE) {
		y.m <- NULL
		n <- length(x)
		y <- as.numeric(y.all[1:n])
		if (is.null(x.new)) {
			x.new <- x
			y.new <- y
		}
		else {
			y.new <- y.all[(n + 1):(n + length(x.new))]
		}
		if (median) {
			y.bm <- tapply(y, x, median, na.rm = T)
			y.m <- median(y, na.rm = T)
		}
		else {
			y.bm <- tapply(y, x, mean, na.rm = T)
			y.m <- mean(y, na.rm = T)
		}
		y.norm <- y.new
		rep.batch <- function(y.bm, x.new) {
			x.table <- table(x.new)
			n <- length(x.new)
			y1 <- c()
			for (i in 1:n) {
				y1 <- c(y1, rep(as.numeric(y.bm[x.new[i]], x.table[x.new[i]])))
			}
			return(y1)
		}
		y.pred <- rep.batch(y.bm, x.new)
		resid <- y.new - y.pred
		if (scaling) {
			if (!any(y.pred == 0 || y.pred == 1 || is.na(y.pred))) 
				y.norm <- ifelse(resid > 0, (resid * (1 - y.m)/(1 - 
										y.pred) + y.m), y.m * (1 + resid/y.pred))
		}
		else {
			y.norm <- resid + y.m
		}
		y.norm
	}
	t(apply(y.all, 1, PBR1, x, x.new, scaling, median))
}

######################
# Jan 10, 2010
######################
normalizeTCGAPkg.2_test<-function(){
	tcgaPath<-"c:\\temp\\tcga"
	outPath<-"c:\\temp\\test"
	reposPath<-"c:\\temp\\tcga\\repos"
	normalizeTCGAPkg.2(tcgaPath,outPath)
}
normalizeTCGAPkg.2<-function(tcgaPath=NULL,outPath=NULL,reposPath=NULL,toPlot=T,toValidate=T){
	if(is.na(tcgaPath)) tcgaPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga"
	if(is.na(outPath)) outPath<-"/auto/uec-02/shared/production/methylation/meth27k/normalized"
	cancerType<-list.files(tcgaPath)
	cancerType<-cancerType[-grep("repos",cancerType)]
	for (cn in cancerType){
		curDir<-file.path(tcgaPath,cn)
		clearTCGARepos(curDir,reposPath)
		Pkgs<-list.files(curDir,pattern=".gz")
		Pkgs<-Pkgs[-grep("md5",Pkgs)]
		lvl3Pkgs<-Pkgs[grep("Level_3",Pkgs)]
		outDir<-file.path(outPath,cn)
		if(!file.exists(outDir)) dir.create(outDir)
		for(lvl3Pkg in lvl3Pkgs) uncompress(file.path(curDir,lvl3Pkg),outDir)
		lvl3FNs<-list.files(outDir,pattern=".txt",recursive=T)
		lvl3FNs<-lvl3FNs[-grep("MANIFEST*|DESCRIPTION*",lvl3FNs)]
		lvl3Data<-NULL;pids<-NULL
		Sids<-c();SNs<-c()
		for(fn in lvl3FNs){
			dat<-read.delim(file=file.path(outDir,fn),sep="\t",header=F,row.names=1,as.is=T)
			Sids<-c(Sids,dat[1,2])
			dat<-dat[-c(1,2),]
			if(is.null(pids)) {
				pids<-row.names(dat)
				lvl3Data<-data.frame(as.numeric(dat[,1]))
			}
			else{ 
				dat<-dat[pids,]
				lvl3Data<-data.frame(lvl3Data,as.numeric(dat[,1]))
			}
			sn<-strsplit(filetail(fn),"\\.")[[1]][[4]]
			SNs<-c(SNs,sn)
		}
		row.names(lvl3Data)<-pids
		names(lvl3Data)<-Sids
		names(SNs)<-Sids
		rst<-removeNormalSamples(lvl3Data)
		lvl3Data<-rst$tumor
		lvl3Data.n<-rst$norm
		SNs.n<-SNs[names(lvl3Data.n)]
		SNs<-SNs[names(lvl3Data)]
		if(length(SNs)<=1) next
		lvl3Data.norm<-PBR(lvl3Data,as.factor(SNs))
		if(nrow(lvl3Data.n)>0){
			lvl3Data.nnorm<-PBR(lvl3Data,as.factor(SNs),lvl3Data.n,as.factor(SNs.n))
			SNs<-c(SNs,SNs.n)
			ind<-order(SNs)
			SNs<-SNs[ind]
			lvl3Data<-cbind(lvl3Data,lvl3Data.n)[,ind]
			lvl3Data.norm<-cbind(lvl3Data.norm,lvl3Data.nnorm)[,ind]
		}
		save(lvl3Data,file=file.path(outDir,paste(cn,".rdata",sep="")))
		save(lvl3Data.norm,file=file.path(outDir,paste(cn,".norm.rdata",sep="")))
		
		if(toPlot==T){
			boxplot.2(lvl3Data,color=SNs,main="Before Normalization",fn=file.path(outDir,paste(cn,".png",sep="")))
			boxplot.2(lvl3Data.norm,color=SNs,main="After Normalization",fn=file.path(outDir,paste(cn,".norm.png",sep="")))
		}
		lvl3PkgNM<-sapply(lvl3Pkgs,function(x)gsub(".tar.gz","",x))
		dimnames(lvl3Data.norm)[[2]]<-names(lvl3Data)
		for(pn in lvl3PkgNM){
			if(!file.exists(file.path(outDir,pn))) dir.create(file.path(outDir,pn))
		}
		createNormalizedPkgs(lvl3Data.norm,outDir,lvl3PkgNM,SNs)
		if(toValidate==T){
			magePkg<-Pkgs[grep("mage",Pkgs)]
			file.copy(file.path(curDir,magePkg),file.path(outDir,magePkg),overwrite=T)
			file.copy(paste(file.path(curDir,magePkg),".md5",sep=""),paste(file.path(outDir,magePkg),".md5",sep=""),overwrite=T)
			lvl12Pkgs<-Pkgs[grep("Level_1|Level_2",Pkgs)]
			for(pkg in lvl12Pkgs){
				file.copy(file.path(curDir,pkg),file.path(outDir,pkg),overwrite=T)
				file.copy(paste(file.path(curDir,pkg),".md5",sep=""),paste(file.path(outDir,pkg),".md5",sep=""),overwrite=T)
			}
			validatePkg(outDir)
		}
	}
}
normalizeTCGAPkg_test<-function(){
	tcgaPath<-"c:\\temp\\tcga"
	outPath<-"c:\\temp\\test"
	normalizeTCGAPkg(tcgaPath,outPath)
}

normalizeTCGAPkg<-function(tcgaPath=NULL,outPath=NULL,toPlot=T){
	if(is.na(tcgaPath)) tcgaPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga"
	if(is.na(outPath)) outPath<-"/auto/uec-02/shared/production/methylation/meth27k/normalized"
	cancerType<-list.files(tcgaPath)
	cancerType<-cancerType[-grep("repos",cancerType)]
	for (cn in cancerType){
		curDir<-file.path(tcgaPath,cn)
		Pkgs<-list.files(curDir,pattern=".gz")
		Pkgs<-Pkgs[-grep("md5",Pkgs)]
		lvl3Pkgs<-Pkgs[grep("Level_3",Pkgs)]
		outDir<-file.path(outPath,cn)
		if(!file.exists(outDir)) dir.create(outDir)
		for(lvl3Pkg in lvl3Pkgs) uncompress(file.path(curDir,lvl3Pkg),outDir)
		lvl3FNs<-list.files(outDir,pattern=".txt",recursive=T)
		lvl3FNs<-lvl3FNs[-grep("MANIFEST*|DESCRIPTION*",lvl3FNs)]
		lvl3Data<-NULL;pids<-NULL
		Sids<-c();SNs<-c()
		for(fn in lvl3FNs){
			dat<-read.delim(file=file.path(outDir,fn),sep="\t",header=F,row.names=1,as.is=T)
			Sids<-c(Sids,dat[1,2])
			dat<-dat[-c(1,2),]
			if(is.null(pids)) {
				pids<-row.names(dat)
				lvl3Data<-data.frame(as.numeric(dat[,1]))
			}
			else{ 
				dat<-dat[pids,]
				lvl3Data<-data.frame(lvl3Data,as.numeric(dat[,1]))
			}
			sn<-strsplit(filetail(fn),"\\.")[[1]][[4]]
			SNs<-c(SNs,sn)
		}
		row.names(lvl3Data)<-pids
		names(lvl3Data)<-Sids
		names(SNs)<-Sids
		lvl3Data<-removeNormalSamples(lvl3Data)$tumor
		SNs<-SNs[names(lvl3Data)]
		if(length(SNs)<=1) next
		lvl3Data.norm<-PBR(lvl3Data,as.factor(SNs))
		save(lvl3Data,file=file.path(outDir,paste(cn,".rdata",sep="")))
		save(lvl3Data.norm,file=file.path(outDir,paste(cn,".norm.rdata",sep="")))
		if(toPlot==T){
			boxplot.2(lvl3Data,color=SNs,main="Before Normalization",fn=file.path(outDir,paste(cn,".png",sep="")))
			boxplot.2(lvl3Data.norm,color=SNs,main="After Normalization",fn=file.path(outDir,paste(cn,".norm.png",sep="")))
		}
		lvl3PkgNM<-sapply(lvl3Pkgs,function(x)gsub(".tar.gz","",x))
		dimnames(lvl3Data.norm)[[2]]<-names(lvl3Data)
		createNormalizedPkgs(lvl3Data.norm,outDir,lvl3PkgNM,SNs)
		magePkg<-Pkgs[grep("mage",Pkgs)]
		file.copy(file.path(curDir,magePkg),file.path(outDir,magePkg))
		file.copy(paste(file.path(curDir,magePkg),".md5",sep=""),paste(file.path(outDir,magePkg),".md5",sep=""))

	}
}

removeNormalSamples<-function(dat){
	samples<-names(dat)
	samples.type<-sapply(samples,function(x)strsplit(x,"-")[[1]][4])
	ind<-grep("20A|11A",samples.type)
	samples.norm<-samples[ind]
	samples.tumor<-samples[-ind]
	dat.norm<-dat[,samples.norm]
	dat.tumor<-dat[,samples.tumor]
	return(list(tumor=dat.tumor,normal=dat.norm))
}
createNormalizedPkgs<-function(dat.norm,outDir,Pkgs,SNs){
	dat.norm<-as.data.frame(dat.norm)
	if(!exists("HumanMethylation27.adf")) data(HumanMethylation27.adf)
	dat.norm<-dat.norm[HumanMethylation27.adf$IlmnID,]
	samples<-names(dat.norm)
	for(i in 1:length(Pkgs)){
		sn<-strsplit(Pkgs[i],"\\.")[[1]][5]
		sids<-samples[SNs==sn]
		dat.pkg<-dat.norm[,sids]
		pref<-paste(strsplit(Pkgs[i],"\\.")[[1]][c(1:3,5)],collapse=".")
		for(j in 1:length(sids)){
			sid<-sids[j]
			fn<-file.path(outDir,Pkgs[i],paste(pref,".lvl-3.",sid,".txt",sep=""))
			write(paste("Hybridization REF",sid,sid,sid,sid,sep="\t"),file=fn)
			write(paste("Composite Element REF","Beta_Value","Gene_Symbol","Chromosome","Genomic_Coordinate",sep="\t"),file=fn,append=T)
			dat<-data.frame(HumanMethylation27.adf$IlmnID,dat.pkg[,j],HumanMethylation27.adf$SYMBOL,HumanMethylation27.adf$Chr,HumanMethylation27.adf$MapInfo)
			write.table(dat,file=fn,sep="\t",quote=F,col.names=F,append=T,row.names=F)
		}
		createManifestByLevel.2(file.path(outDir,Pkgs[i]))
		compressDataPackage(file.path(outDir,Pkgs[i]))
	}
}
