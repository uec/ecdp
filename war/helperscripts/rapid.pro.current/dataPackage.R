# TODO: Add comment
# 
# Author: feipan
###############################################################################



test_create_level_1_data<-function(){
	load(file.path("c:\\temp","mData.Rdata"))
	package_name<-"jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.Level_1"
	ver<-"1.0.0"
	create_level_1_data(mData,ver,package_name)
}

create_level_1_data<-function(mData=NULL,ver=NULL,package_name=NULL,dir.work=NULL){
	hd1<-"Hybridization REF"
	header<-paste("Composite Element REF","Cy3","Cy5","Detection Pvalue",sep="\t")
	readMetaData()
	sampID<-getSampID(mData)
	IlmnID<-getProbeID(mData)
	M<-getM(mData)
	U<-getU(mData)
	pvalue<-getPvalue(mData)
	if(is.null(dir.work)){
		dir.work<-"c:\\temp"
	}
	setwd(dir.work)
	dir.create(package_name)
	fp<-file.path(dir.work,package_name)
	setwd(fp)
	for(i in 1:length(sampID)){
		fn<-file.path(fp,paste(sampID[i],ver,"txt",sep="."))
		zz<-file(fn,"wt")
		cat(paste(hd1,sampID[i],sampID[i],sampID[i],sampID[i],"\t"),file=zz,"\n")
		cat(header,file=zz,"\n")
		for(j in 1:nrow(M)){
			cat(paste(IlmnID[j],M[j],U[j],pvalue[j],sep="\t"),file=zz,"\n")
		}
		close(zz)
	}
}

test_create_level_2_data<-function(){
	load(file.path("c:\\temp","mData.Rdata"))
	threshold<-0.05
	create_level_2_data(mData,ver="1.2.0",pacakge_name="jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA002_CPI")
}
create_level_2_data<-function(mData,ver=NULL,package_name=NULL,threshold=0.05,dir.work){
	if(is.null(dir.work)){
		dir.work<-"c:\\temp"
	}
	setwd(dir.work)
	head1<-paste("Composite Element REF","Beta Value",sep="\t")
	hd1<-"Hybridization REF"
	betaValue<-getBeta(mData)
	pValue<-getPvalue(mData)
	betaValue<-ifelse(pValue<threshold,betaValue,"NA")
	sampID<-getSampID(mData)
	IlmnID<-getProbeID(mData)
	if(!exists(package_name)) dir.create(package_name)
	fpath<-file.path(dir.work,package_name)
	setwd(fpath)
	for(i in 1:length(sampID)){
		fn<-file.path(fpath,paste(sampID[i],ver,"txt",sep="."))
		file.cur<-file(fn,"wt")
		cat(paste(hd1,sampID[i],sep="\t"),file=file.cur,"\n")
		cat(head1,file=file.cur,"\n")
		for(j in 1:nrow(betaValue)){
			cat(paste(IlmnID[j],betaValue[j]),file=file.cur,"\n")
		}
		close(file.cur)
	}
}



create_level_1_Infinium<-function(mData,ver=NULL,package_name=NULL,dir.work=NULL,sampID=NULL){
	hd1<-"Hybridization REF"
	header<-paste("Composite Element REF",
			"Methylated_Signal_Intensity (M)",
			"M_Number_Beads	M_STDERR",
			"Un-Methylated_Signal_Intensity (U)",
			"U_Number_Beads	U_STDERR",
			"Negative_Control_Grn_Avg_Intensity",	
			"Negative_Control_Grn_STDERR",
			"Negative_Control_Red_Avg_Intensity",
			"Negative_Control_Red_STDERR",
			"Detection_P_Value",sep="\t")
	if(is.null(sampID))sampID<-getSampID(mData)
	IlmnID<-getID(mData)
	M<-getM(mData)
	U<-getU(mData)
	pvalue<-getPvalue(mData)
	
	mstd<-getMSTD(mData)
	ustd<-getUSTD(mData)
	negCtrGrn<-getNegCtrGrn(mData)
	negStdGrn<-getNegStdGrn(mData)
	negCtrRed<-getNegCtrRed(mData)
	netStdRed<-getNegStdRed(mData)
	setwd(dir.work)
	if(!file.exists(package_name))dir.create(package_name)
	for(i in 1:ncol(M)){
		fn<-paste(pack_name,ver,sep="")
		zz<-file(fn,"wt")
		cat(paste(hd1,sampID[i],sampID[i],sampID[i],sampID[i],
						sampID[i],sampID[i],sampID[i],
						sampID[i],sampID[i],sep="\t"))
		cat(header,file=zz,"\n")
		for(j in 1:nrow(M)){
			cat(paste(IlmnID[j],M[j],mstd[j],U[j],ustd[j],negCtrGrn[j],negStdGrn[j],netCtrRed[j],negStdRed[j]),file=zz,"\n")
		}
		close(zz)
	}
}
crete_level_2_Infinium<-function(mData,ver=NULL,package_name=NULL,threshold=0.05,dir.work=NULL,sampID=NULL)
{
	hd1<-"Hybridization REF"
	header<-paste("Composite Element REF","Beta_Value")
	if(is.null(sampID)) sampID<-getSampID(mData)
	IlmnID<-getProbeID(mData)
	bv<-getBeta(mData)
	pv<-getPvalue(mData)
	betaValue<-ifelse(pv<threshold,bv,"NA")
	if(is.null(dir.work)){
		dir.work<-"c:\\temp"
	}
	setwd(dir.work)
	if(!file.exists(package_name)){
		dir.create(package_name)
	}
	for(i in 1:length(sampID)){
		fn<-paste(package_name,sampID[i],"Level_2",ver,sep=".")
		zz<-file(fn,"wt")
		cat(paste(hd1,"Beta Value",sep="\t"),file=zz,"\n")
		cat(header)
		for(j in 1:nrow(bv)){
			cat(paste(IlmnID[j],betaValue[j],sep="\t"),file=zz,"\n")
		}
		close(zz)
	}
}
create_level_3_Infinium<-function(mData,ver=NULL,package_name=NULL,threshold=0.05,dir.work=NULL,sampID=NULL){
	hd1<-"Hybridization REF"
	header<-paste("Composite Element REF","Beta_Value",
			"Gene_Symbol","Chromosome","Genomic_Coordinate",sep="\t")
	if(is.null(sampID))sampID<-getSampID(mData)
	ilmnID<-getProbeID(mData)
	betaValue<-getBeta(mData)
	pvalue<-getPvalue(mData)
	betaValue<-ifelse(pvalue<threshold,betaValue,"NA")
	library(methAnnot)
	getData()
	len<-nrow(humanMeth27k)	
	setwd(dir.work)
	if(!file.exists(package_name))dir.create(package_name)
	for(i in 1:length(sampID)){
		fn<-paste(pack_name,"Level_3",ver,sep="")
		zz<-file(fn,"wt")
		cat(paste(hd1,sampID[i],sampID[i],sampID[i],sampID[i]),file=zz,"\n")
		cat(header,file=zz,"\n")
		for(j in 1:len){
			cat(paste(ilmnID[j],betaValue[j],humanMeth27k$Symbol[j],
							humanMeth27k$Chr[j],humanMeth27k$MapInfo[j],sep="\t"),file=zz,"\n")
		}
		close(fn)
	}
}
createManifestByLevel.2_test<-function(){
	pkg_folder<-"C:\\tcga\\repos\\jhu-usc.edu_COAD.HumanMethylation27.1"
	lvl_folder<-"jhu-usc.edu_COAD.HumanMethylation27.Level_1.1.0.0"
	createManifestByLevel.2(pkg_folder,lvl_folder)
}
createManifestByLevel.2<-function(pkg_folder,lvl_folder=NULL){
	if(is.null(lvl_folder)){
		lvl_folder<-filetail(pkg_folder) #tclvalue(tclfile.tail(pkg_folder))
		pkg_folder<-filedir(pkg_folder) #tclvalue(tclfile.dir(pkg_folder))
	}
	setwd(file.path(pkg_folder,lvl_folder))
	if(file.exists("MANIFEST.txt")) file.remove("MANIFEST.txt")
	if(R.Version()$os=="mingw32"){
		md5sum<-"md5sum"
		if(file.exists(system.file("Rtools",package="rapid"))) md5sum<-file.path(system.file("Rtools",package="rapid"),"md5sum")
		shell(paste(md5sum," -t *.* > MANIFEST.txt",sep=""))
	}else if(substr(R.Version()$os,1,5)=="linux"){
		system("md5sum *.* >MANIFEST.txt")
	}else{
		system("MD5 -r *.* > MANIFEST.txt")
	}
}



createManifest<-function(pkg_folder,lvl_folder,zz){
	#pref6<-file.path(pkg_folder,lvl_folder) #flist[i];#file.path(pkg_folder,flist[i])
	pref6<-lvl_folder
	cat("cd ", pref6,"\n",file=zz)
	command<-paste("md5sum *.* > MANIFEST.txt")
	cat(command,"\n",file=zz)
	cat("cd ..\n",file=zz)
}
modifyManifest<-function(pkg_folder,lvl_folder){
	pref6<-file.path(pkg_folder,lvl_folder)#flist[i])
	mfn<-file.path(pref6,"MANIFEST.txt")
	fc<-readLines(mfn)
	ind<-grep("MANIFEST",fc)
	fc<-fc[-ind]
	fc.new<-gsub("\\*","",fc)
	#cat(fc.new,file=mfn)
	rr<-data.frame(fc.new)
	write.table(rr,file=mfn,row.names=F,col.names=F,quote=F)
}
createManifestByLevel<-function(pkg_folder){
	setwd(pkg_folder)
	flist<-list.files()
	runBat<-file.path(pkg_folder,"run.bat")
	zz<-file(runBat,"w")
	for(i in 1:length(flist)){
		createManifest(pkg_folder,flist[i],zz)
#		pref6<-flist[i];#file.path(pkg_folder,flist[i])
#		cat("cd ", pref6,"\n",file=zz)
#		command<-paste("md5sum *.* > MANIFEST.txt")
#		cat(command,"\n",file=zz)
#		cat("cd ..\n",file=zz)
	}
	close(zz)
	shell(runBat)
	
	for(i in 1:length(flist)){
		modifyManifest(pkg_folder,flist[i])
#		pref6<-file.path(pkg_folder,flist[i])
#		mfn<-file.path(pref6,"MANIFEST.txt")
#		fc<-readLines(mfn)
#		ind<-grep("MANIFEST",fc)
#		fc<-fc[-ind]
#		fc.new<-gsub("\\*","",fc)
#		#cat(fc.new,file=mfn)
#		rr<-data.frame(fc.new)
#		write.table(rr,file=mfn,row.names=F,col.names=F,quote=F)
	}
	#unlink(runBat)
}
compressDataPackage_test<-function(){
	pkg_folder<-"c:\\temp\\4698"
	compressDataPackage(pkg_folder)
	pkg_folder<-"/auto/uec-02/shared/production/methylation/meth27k/3435323"
	compressDataPackage(pkg_folder)
	pkg_folder<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\5543207013\\jhu-usc.edu_STAD.HumanMethylation27.1\\jhu-usc.edu_STAD.HumanMethylation27.mage-tab.1.1.0"
	compressDataPackage(pkg_folder)
}
####
# rapid
#####
compressDataPackage<-function(pkg_folder,lvl_fdname=NULL){
	if(is.null(lvl_fdname)){
		lvl_fdname<-filetail(pkg_folder)
		pkg_folder<-filedir(pkg_folder)
	}
	setwd(pkg_folder)
	
	if(R.Version()$os=="mingw32"){
		tar<-"tar"
		if(file.exists(system.file("Rtools",package="rapid"))) tar<-file.path(system.file("Rtools",package="rapid"),"tar")
		command <- paste(tar," -cvf ",lvl_fdname,".tar ",lvl_fdname,sep="")
		system(command,wait=T)
		gzip<-"gzip"
		if(file.exists(system.file("Rtools",package="rapid"))) gzip<-file.path(system.file("Rtools",package="rapid"),"gzip")
		command <- paste(gzip," -f ",lvl_fdname,".tar ",sep="")
		system(command,wait=T)
		md5sum<-"md5sum"
		if(file.exists(system.file("Rtools",package="rapid"))) md5sum<-file.path(system.file("Rtools",package="rapid"),"md5sum")
		command <- paste(md5sum," ",lvl_fdname,".tar.gz>",lvl_fdname,".tar.gz.md5",sep="")
		shell(command)
	}else{
		command <- paste("tar -cvf ",lvl_fdname,".tar ",lvl_fdname,sep="")
		system(command,wait=T)
		command <- paste("gzip -f ",lvl_fdname,".tar ",sep="")
		system(command,wait=T)
		if(substr(R.Version()$os,1,5)=="linux"){
			command <- paste("md5sum ",lvl_fdname,".tar.gz>",lvl_fdname,".tar.gz.md5",sep="")
		}else{
			command <- paste("MD5 -r ",lvl_fdname,".tar.gz>",lvl_fdname,".tar.gz.md5",sep="")
		}
		system(command)
	}
}

#compressDataPackage<-function(pkg_folder,lvl_fdname=NULL){
#	if(is.null(lvl_fdname)){
#		lvl_fdname<-filetail(pkg_folder)
#		pkg_folder<-filedir(pkg_folder)
#	}
#	setwd(pkg_folder)
#	
#	if(R.Version()$os=="mingw32"){
#		tar<-"tar"
#		if(file.exists(system.file("Rtools",package="rapid"))) tar<-file.path(system.file("Rtools",package="rapid"),"tar")
#		command <- paste(tar," -cvf ",lvl_fdname,".tar ",lvl_fdname,sep="")
#		system(command,wait=T)
#		gzip<-"gzip"
#		if(file.exists(system.file("Rtools",package="rapid"))) gzip<-file.path(system.file("Rtools",package="rapid"),"gzip")
#		command <- paste(gzip," -f ",lvl_fdname,".tar ",sep="")
#		system(command,wait=T)
#		md5sum<-"md5sum"
#		if(file.exists(system.file("Rtools",package="rapid"))) md5sum<-file.path(system.file("Rtools",package="rapid"),"md5sum")
#		command <- paste(md5sum," ",lvl_fdname,".tar.gz>",lvl_fdname,".tar.gz.md5",sep="")
#		shell(command)
#	}else{
#		command <- paste("tar -cvf ",lvl_fdname,".tar ",lvl_fdname,sep="")
#		system(command,wait=T)
#		command <- paste("gzip -f ",lvl_fdname,".tar ",sep="")
#		system(command,wait=T)
#		command <- paste("md5sum ",lvl_fdname,".tar.gz>",lvl_fdname,".tar.gz.md5",sep="")
#		system(command)
#	}
#}

sendMessage<-function(txt=NULL,msg=""){
	if(!is.null(txt)){
		tkinsert(txt,"end",msg)
	}else{
		cat(msg)
	}
}
createLvl1Package_test<-function(){
	library(tcltk)
	datDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\TCGA Batch 26 Data Package"
	reValue<-c(file.path(datDir,"TCGA Batch 26 Methylated Signal Intensity.xls"),file.path(datDir,"TCGA Batch 26 Methylated Bead Std Error.xls"),file.path(datDir,"TCGA Batch 26 Avg Number of Methylated Beads.xls"),
			file.path(datDir,"TCGA Batch 26 Unmethylated Signal Intensity.xls"),file.path(datDir,"TCGA Batch 26 Unmethylated Bead Std Error.xls"),file.path(datDir,"TCGA Batch 26 Avg Number of Unmethylated Beads.xls"),
			file.path(datDir,"TCGA Batch 26 Negative Control Signal_Red.xls"),file.path(datDir,"TCGA Batch 26 Negative Control SIgnal_Green.xls"),"jhu-usc.edu_GBM.HumanMethylation27.Level_1.1.1.0",
			file.path(datDir,"TCGA Batch 26 README.txt"),"c:\\temp",file.path(datDir,"TCGA Batch 26 Detection p-values_bk.xls"))
	
	createLvl1Package(auto=T)
	
	reValue<-c(file.path(datDir,"TCGA Batch 26 Methylated Signal Intensity.csv"),file.path(datDir,"TCGA Batch 26 Methylated Bead Std Error.csv"),file.path(datDir,"TCGA Batch 26 Avg Number of Methylated Beads.csv"),
			file.path(datDir,"TCGA Batch 26 Unmethylated Signal Intensity.csv"),file.path(datDir,"TCGA Batch 26 Unmethylated Bead Std Error.csv"),file.path(datDir,"TCGA Batch 26 Avg Number of Unmethylated Beads.csv"),
			file.path(datDir,"TCGA Batch 26 Negative Control Signal_Red.csv"),file.path(datDir,"TCGA Batch 26 Negative Control SIgnal_Green.csv"),"jhu-usc.edu_GBM.HumanMethylation27.Level_1.1.1.0",
			file.path(datDir,"TCGA Batch 26 README.txt"),"c:\\temp",file.path(datDir,"TCGA Batch 26 Detection p-values_bk.csv"))
	assign("reValue",reValue,env=.GlobalEnv)
	createLvl1Package(auto=T)
}

createLvl1Package<-function(txt=NULL,auto=F){
	if(auto==F)createLvl1PackageDialog("Create Level 1 Data Package")
	if(is.null(reValue))return()
	if(!is.txt(txt)) tkinsert(txt,"end",message=">Start to creating the level_1 data packages:\n")
	sig_A<-reValue[1]
	sig_A_n<-reValue[2]
	sig_A_se<-reValue[3]
	sig_B<-reValue[4]
	sig_B_n<-reValue[5]
	sig_B_se<-reValue[6]
	ctr_R_fn<-reValue[7]
	ctr_G_fn<-reValue[8]
	tcgaPackage_name<-reValue[9]
	readme_fn<-reValue[10]
	outdir<-file.path(reValue[11],tcgaPackage_name)
	if(!file.exists(outdir))dir.create(outdir)
	setwd(outdir)           #
	pvalue_fn<-reValue[12]
	reValue<<-NULL
	pref<-paste(c(strsplit(tcgaPackage_name,"\\.")[[1]][c(1,2,3,5)],"lvl-1."),collapse=".")
	rst<-processLevel1Data(sig_A,sig_A_n,sig_A_se,sig_B,sig_B_n,sig_B_se,ctr_R_fn,ctr_G_fn,pvalue_fn,pref)
	
	if(readme_fn!=""){
		file.copy(readme_fn,file.path(outdir,"DESCRIPTION.TXT"))
	}
	lvl_1_fdname<-outdir
	createManifestByLevel.2(lvl_1_fdname)
	compressDataPackage(lvl_1_fdname)
	if(!is.null(txt)){
		msg<-paste(">Finished creating the level-1 data package...",date(),"\n",sep="")
		tkinsert(txt,"end",msg)
	}	
}
#createLvl1Package<-function(txt=NULL,auto=F){
#	if(auto==F)createLvl1PackageDialog("Create Level 1 Data Package")
#	if(is.null(reValue))return()
#	sig_A<-reValue[1]
#	sig_A_n<-reValue[2]
#	sig_A_se<-reValue[3]
#	sig_B<-reValue[4]
#	sig_B_n<-reValue[5]
#	sig_B_se<-reValue[6]
#	ctr_R_fn<-reValue[7]
#	ctr_G_fn<-reValue[8]
#	tcgaPackage_name<-reValue[9]
#	readme_fn<-reValue[10]
#	outdir<-file.path(reValue[11],tcgaPackage_name)
#	if(!file.exists(outdir))dir.create(outdir)
#	pvalue_fn<-reValue[12]
#	reValue<<-NULL
#	pref<-paste(c(strsplit(tcgaPackage_name,"\\.")[[1]][c(1,2,3,5)],"lvl-1."),collapse=".")
#	rst<-processLevel1Data()
#	
#	if(readme_fn!=""){
#		file.copy(readme_fn,file.path(outdir,"DESCRIPTION.TXT"))
#	}
#	lvl_1_fdname<-outdir
#	createManifestByLevel.2(lvl_1_fdname)
#	compressDataPackage(lvl_1_fdname)
#	if(!is.null(txt)){
#		msg<-paste("> Finished creating the level-1 data package...",date(),"\n",sep="")
#		tkinsert(txt,"end",msg)
#	}	
#}
updateLvl1Package<-function(txt=NULL){
	updateLvl1PackageDialog.2("Update Level 1 Data Pacakge")
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",">Start to create the level 1 data package\n")
	lvl_1_fdname<-file.path(reValue[2],reValue[4])
	create_lvl1_data_pkg(reValue[1],reValue[2],reValue[3],reValue[4])
	createManifestByLevel.2(lvl_1_fdname)
	compressDataPackage(lvl_1_fdname)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished the level 1 data packaging\n")
}
updateLvl1PackageDialog.2<-function(tit=""){
	dlg<-startDialog(tit)
	dlg1<-tkfrm(dlg)
	tkgrid(tklabel(dlg,text=" "))
	addTextEntryWidget(dlg1,"Select the Data Source Folder:","",isFolder=T,name="srcDataFolder")
	addTextEntryWidget(dlg1,"Select the Level 1 Package Folder:","",isFolder=T,name="pkgFolder")
	addTextEntryWidget(dlg1,"Select the Description File (Opt):","",isFolder=F,name="description")
	addTextEntryWidget(dlg1,"Type in the Data Package Name:","",isFolder=F,withSelectButton=F,name="pkgName")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("srcDataFolder","pkgFolder","description","pkgName"),pad=T)
}
createLvl1PackageDialog<-function(tit=""){
	dlg<-startDialog(tit)
	dlg1<-tkfrm(dlg)
	tkgrid(tklabel(dlg,text=" "))
	addTextEntryWidget(dlg1,"The Methylated Signal Intensity (M):","",isFolder=F,name="sig_A")
	addTextEntryWidget(dlg1,"The STDERR of Methylated Intensity:","",isFolder=F,name="sig_A_n")
	addTextEntryWidget(dlg1,"The Number of Methylated Beads:","",isFolder=F,name="sig_A_se")
	addTextEntryWidget(dlg1,"The Un-methylated Signal Intensity (U):","",isFolder=F,name="sig_B")
	addTextEntryWidget(dlg1,"The STDERR of Un-methylated Intensity:","",isFolder=F,name="sig_B_n")
	addTextEntryWidget(dlg1,"The Number of Un-methylated Beads:","",isFolder=F,name="sig_B_se")
	addTextEntryWidget(dlg1,"The Negative Red Control Intensity (Ctr_R):","",isFolder=F,name="ctr_R")
	addTextEntryWidget(dlg1,"The Negative Grn Control Intensity (Ctr_G):","",isFolder=F,name="ctr_G")
	addTextEntryWidget(dlg1,"The Detection P Values:","",isFolder=F,name="pvalue_fn")
	addTextEntryWidget(dlg1,"The Description File Name (opt):","",isFolder=F,name="descriptFn")
	addTextEntryWidget(dlg1,"The Data Output Folder:","c:/tcga",isFolder=T,name="outdir")
	addTextEntryWidget(dlg1,"The Level 1 Data Package Name:","jhu-usc.edu_OV.HumanMethylation27.Level_1.1.1.0",isFolder=F,withSelectButton=F,name="pkgName")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("sig_A","sig_A_n","sig_A_se","sig_B","sig_B_n","sig_B_se","ctr_R","ctr_G","pkgName","descriptFn","outdir","pvalue_fn"),pad=T)
}
createLvl2Package<-function(txt=NULL){
	createLvlPkgDialog("Create Level 2 Data Package","jhu-usc.edu_OV.HumanMethylation27.Level_2.1.0.0")
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",">Start to craete level 2 data package\n")
	lvlPkg<-file.path(reValue[2],reValue[4])
	create_lvl2_data_pkg.2(reValue[1],lvlPkg,reValue[3])
	createManifestByLevel.2(lvlPkg)
	compressDataPackage(lvlPkg)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished level 2 data packaging\n")
}
createLvlPkgDialog<-function(tit="",pkgName=""){
	dlg<-startDialog(tit)
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the data source Folder:","",isFolder=T,name="src_folder")
	addTextEntryWidget(dlg1,"Select the Level Package Folder:","",isFolder=T,name="lvl2_folder")
	addTextEntryWidget(dlg1,"Select the description file (opt):","",isFolder=F,name="descriptFn")
	addTextEntryWidget(dlg1,"Type in the Data Package Name:",pkgName,isFolder=F,withSelectButton=F,name="pkgName")
	tkgrid(tklabel(dlg,text=" "),dlg1)
	tkgrid.configure(dlg1,columnspan=2)
	endDialog(dlg,c("src_folder","lvl2_folder","descriptFn","pkgName"),pad=T)
}
updateLvl2Pkg<-function(txt=NULL){
	updateLvl2PackageDialog("Update Level 2 Data Package")
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",">Start to create level 2 data package\n")
	new_pkg_folder<-reValue[2]
	create_lvl2_data_pkg.2(reValue[1],reValue[2],reValue[3],reValue[4],reValue[5])
	updateDescriptFn(reValue[1],reValue[2])
	createManifestByLevel.2(new_pkg_folder)
	compressDataPackage(new_pkg_folder)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Finished ",date(),"\n"))
}
updateLvl2PackageDialog<-function(tit=""){
	dlg<-startDialog(tit)
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select Level 1 Data Folder:","",isFolder=T,name="lvl_1_folder")
	addTextEntryWidget(dlg1,"Select Leve 2 Package Folder:","",isFolder=T,name="lvl_2_folder")
	addTextEntryWidget(dlg1,"Select Description File (Opt.):","",isFolder=F,name="descriptFn")
	addTextEntryWidget(dlg1,"Select Detection P Value File (Opt.):","",isFolder=F,name="PvalueFn")
	addTextEntryWidget(dlg1,"Set the minimum p value threshold:","0.05",name="pvalueMin",withSelectButton=F)
	tkgrid(tklabel(dlg,text=" "),dlg1)
	tkgrid.configure(dlg1,columnspan=2)
	endDialog(dlg,c("lvl_1_folder","lvl_2_folder","descriptFn","PvalueFn","pvalueMin"),pad=T)
}
############
# arrayPath: used for adding well poistion, barcodes and plate id for meth450k
############
createMagePkg_test<-function(){
	pkgDir<-"C:\\temp\\test2\\meth27k\\batches2\\48"
	pkgDir<-"C:\\temp\\test\\meth27k\\tcga\\STAD\\jhu-usc.edu_STAD.HumanMethylation27.1.1.0"
	createMagePkg(pkgDir)
	
	pkgDir<-"c:\\temp\\test3\\meth450k\\batches\\1"
	createMagePkg(pkgDir,platform="meth450k")
	
	pkgDir<-"C:\\temp\\IDAT\\meth450k\\tcga\\COAD"
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth450"
	createMagePkg(pkgDir,arrayPath,platform="meth450k")
	
	pkgDir<-"C:\\temp\\IDAT\\meth450k\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0"
}
createMagePkg<-function(pkgDir=NULL,arrayPath=NULL,txt=NULL,auto=T,platform="meth27k"){
	lvl1Pkg<-NULL;lvl2Pkg<-NULL;lvl3Pkg<-NULL;magePkg<-NULL;arch_numb_lvl1<-NULL;arch_numb_lvl2<-NULL;arch_numb_lvl3<-NULL
	if(auto==T){
		pkgFn<-list.files(pkgDir,pattern=".tar.gz")
		pkgFn<-pkgFn[-grep(".md5",pkgFn)]
		lvl1Pkg<-file.path(pkgDir,pkgFn[grep("Level_1",pkgFn)])
		lvl2Pkg<-file.path(pkgDir,pkgFn[grep("Level_2",pkgFn)])
		lvl3Pkg<-file.path(pkgDir,pkgFn[grep("Level_3",pkgFn)])
		magePkg<-file.path(pkgDir,gsub("Level_1","mage-tab",pkgFn[grep("Level_1",pkgFn)]))
	}else{
		createMageDialog.2("Create Mage Tab Package")
		if(is.null(reValue)) return()
		lvl1Pkg<-reValue[1];lvl2Pkg<-reValue[2];lvl3Pkg<-reValue[3]
		manifest_dir<-file.path(cDir,reValue[4])
		if(reValue[4]=="") magePkg<-filetail(gsub("Level_1","mage-tab",reValue[1]))
		else magePkg<-reValue[4]
	}
	if(length(lvl1Pkg)>0){
		uncompress(lvl1Pkg);
		lvl1Pkg<-gsub(".tar.gz","",lvl1Pkg);
		arch_numb_lvl1<-strsplit(lvl1Pkg,"Level_1")[[1]][2]
	}
	if(length(lvl2Pkg)>0){
		uncompress(lvl2Pkg);
		lvl2Pkg<-gsub(".tar.gz","",lvl2Pkg);
		arch_numb_lvl2<-strsplit(lvl2Pkg,"Level_2")[[1]][2]
	}
	if(length(lvl3Pkg)>0){
		uncompress(lvl3Pkg)
		lvl3Pkg<-gsub(".tar.gz","",lvl3Pkg)
		arch_numb_lvl3<-strsplit(lvl3Pkg,"Level_3")[[1]][2]
	}
	manifest_dir<-paste(strsplit(magePkg,"mage-tab")[[1]][1],"mage-tab.1.0.0",sep="")
	if(!is.null(txt)) tkinsert(txt,"end","> Start creating mage tab package\n")
	if(file.exists(manifest_dir)) unlink(manifest_dir,T);dir.create(manifest_dir)
	fn<-filetail(lvl1Pkg)
	snum<-strsplit(fn,"\\.")[[1]]
	snum<-snum[length(snum)-2]
	pref4<-paste(strsplit(fn,".Level")[[1]][1],".",snum,sep="")
	
	sampleIDs<-getSampleID(gsub(".tar.gz","",lvl1Pkg))
	create_Mage_TAB_SDRF.1(pref4,sampleIDs,manifest_dir,arch_numb_lvl1,arch_numb_lvl2,arch_numb_lvl3,arrayPath,platform=platform)
	type_pkg<-strsplit(strsplit(pref4,"edu_")[[1]][2],"\\.")[[1]][1]
	create_IDF_file(pref4,manifest_dir,type_pkg,platform=platform)
	adf_fn<-paste(pref4,".adf.txt",sep="")
	create_ADF_file(adf_fn,manifest_dir,platform=platform)
	createManifestByLevel.2(manifest_dir)
	compressDataPackage(manifest_dir)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished creating mage tab package\n")
}

createMagePkg.1<-function(pkgDir=NULL,txt=NULL,auto=T){
	lvl1Pkg<-NULL;lvl2Pkg<-NULL;lvl3Pkg<-NULL;magePkg<-NULL;
	if(auto==T){
		pkgFn<-list.files(pkgDir,pattern=".tar.gz")
		pkgFn<-pkgFn[-grep(".md5",pkgFn)]
		lvl1Pkg<-file.path(pkgDir,pkgFn[grep("Level_1",pkgFn)])
		lvl2Pkg<-file.path(pkgDir,pkgFn[grep("Level_2",pkgFn)])
		lvl3Pkg<-file.path(pkgDir,pkgFn[grep("Level_3",pkgFn)])
		magePkg<-file.path(pkgDir,gsub("Level_1","mage-tab",pkgFn[grep("Level_1",pkgFn)]))
	}else{
		createMageDialog.2("Create Mage Tab Package")
		if(is.null(reValue)) return()
		lvl1Pkg<-reValue[1];lvl2Pkg<-reValue[2];lvl3Pkg<-reValue[3]
		manifest_dir<-file.path(cDir,reValue[4])
		if(reValue[4]=="") magePkg<-filetail(gsub("Level_1","mage-tab",reValue[1]))
		else magePkg<-reValue[4]
	}
	uncompress(lvl1Pkg);uncompress(lvl2Pkg);uncompress(lvl3Pkg)
	lvl1Pkg<-gsub(".tar.gz","",lvl1Pkg);lvl2Pkg<-gsub(".tar.gz","",lvl2Pkg);lvl3Pkg<-gsub(".tar.gz","",lvl3Pkg)
	manifest_dir<-paste(strsplit(magePkg,"mage-tab")[[1]][1],"mage-tab.1.0.0",sep="")
	if(!is.null(txt)) tkinsert(txt,"end",">Start creating mage tab package\n")
	if(file.exists(manifest_dir)) unlink(manifest_dir,T);dir.create(manifest_dir)
	fn<-filetail(lvl1Pkg)
	snum<-strsplit(fn,"\\.")[[1]]
	snum<-snum[length(snum)-2]
	pref4<-paste(strsplit(fn,".Level")[[1]][1],".",snum,sep="")
	arch_numb_lvl1<-strsplit(lvl1Pkg,"Level_1")[[1]][2]
	arch_numb_lvl2<-strsplit(lvl2Pkg,"Level_2")[[1]][2]
	arch_numb_lvl3<-strsplit(lvl3Pkg,"Level_3")[[1]][2]
	sampleIDs<-getSampleID(gsub(".tar.gz","",lvl1Pkg))
	create_Mage_TAB_SDRF.1(pref4,sampleIDs,manifest_dir,arch_numb_lvl1,arch_numb_lvl2,arch_numb_lvl3)
	type_pkg<-strsplit(strsplit(pref4,"edu_")[[1]][2],"\\.")[[1]][1]
	create_IDF_file(pref4,manifest_dir,type_pkg)
	adf_fn<-paste(pref4,".adf.txt",sep="")
	create_ADF_file(adf_fn,manifest_dir)
	createManifestByLevel.2(manifest_dir)
	compressDataPackage(manifest_dir)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished creating mage tab package\n")
}

createMageDialog.2<-function(tit=" "){
	dlg<-startDialog(tit)
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select Level 1 Data Package:","",isFolder=F,name="lvl1_pkg",fileType="gz")
	addTextEntryWidget(dlg1,"Select Level 2 Data Package:","",isFolder=F,name="lvl2_pkg",fileType="gz")
	addTextEntryWidget(dlg1,"Select Level 3 Data Package:","",isFolder=F,name="lvl3_pkg",fileType="gz")
	addTextEntryWidget(dlg1,"The Mage-tab Package Name:","jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.0.0",isFolder=F,name="mage_pkg",withSelectButton=F)
	tkgrid(tklabel(dlg,text=" "),dlg1)
	tkgrid.configure(dlg1,columnspan=2)
	endDialog(dlg,c("lvl1_pkg","lvl2_pkg","lvl3_pkg","mage_pkg"),pad=T)
}
createMageDialog<-function(tit=" "){
	dlg<-startDialog(tit)
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select Level 1 Data Folder:","",isFolder=T,name="lvl1_folder")
	addTextEntryWidget(dlg1,"Select Level 2 Data Folder:","",isFolder=T,name="lvl2_folder")
	addTextEntryWidget(dlg1,"Select Level 3 Data Folder:","",isFolder=T,name="lvl3_folder")
	tkgrid(tklabel(dlg,text=" "),dlg1)
	tkgrid.configure(dlg1,columnspan=2)
	endDialog(dlg,c("lvl1_folder","lvl2_folder","lvl3_folder"),pad=T)
}
updateMagePkgDlg.2<-function(){
	dlg<-startDialog("Update mage tab package")
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the New Data Package (.gz):","",isFolder=F,name="lvlPkgNew")
	addTextEntryWidget(dlg1,"Select the Old Data Package (.gz):","",isFolder=F,name="lvlPkgOld")
	addTextEntryWidget(dlg1,"Select the SDRF File:","",isFolder=F,name="sdrf_file")
	addTextEntryWidget(dlg1,"Select Level-4 Sample Calls (Opt):","",isFolder=F,name="lvl4call")
	addTextEntryWidget(dlg1,"Increase the serial number of SDRF File:","YES",withSelectButton=F,name="incSN")
	tkgrid(tklabel(dlg,text=" "),dlg1)
	tkgrid.configure(dlg1,columnspan=2)
	endDialog(dlg,c("lvlPkgNew","sdrf_file","lvl4call","incSN","lvlPkgOld"),pad=T)
}
updateMagePkgDlg<-function(){
	dlg<-startDialog("Update mage tab package")
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the Data Level Folder:","",isFolder=T,name="lvl_folder")
	addTextEntryWidget(dlg1,"Select the SDRF File:","",isFolder=F,name="sdrf_file")
	addTextEntryWidget(dlg1,"Select Level-4 Sample Calls (Opt):","",isFolder=F,name="lvl4call")
	addTextEntryWidget(dlg1,"Increase the serial number of SDRF File:","YES",withSelectButton=F,name="incSN")
	tkgrid(tklabel(dlg,text=" "),dlg1)
	tkgrid.configure(dlg1,columnspan=2)
	endDialog(dlg,c("lvl_folder","sdrf_file","lvl4call","incSN"),pad=T)
}
GBM_samples<-function(){
	oma02Fn<-"C:\\tcga\\GBM_OMA002\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA002_CPI.mage-tab.1.1.0\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA002_CPI.1.sdrf.txt"
	oma03Fn<-"C:\\tcga\\GBM_OMA003\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.mage-tab.1.1.0\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.1.sdrf.txt"
	infiniumFn<-"C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.15.0\\jhu-usc.edu_GBM.HumanMethylation27.8.sdrf.txt"
	datFn<-c(oma02Fn,oma03Fn,infiniumFn)
	for(fn in datFn){
		dat<-read.table(file=fn,sep="\t",as.is=T,header=T)
		dim(dat)
		sampleID<-sapply(dat[,1],function(x)paste(strsplit(x,"-")[[1]][1:3],collapse="-"))
		length(unique(sampleID))
	}
	#265/240 oma02
	#271/246 oma03
	# 370/262 infinim
	ind<-!is.na(dat[,34]) #dat for inifinim
	table(ind)
#	FALSE  TRUE 
#	271    99 
	length(unique(sampleID))
#	[1] 91
}
######
#
########
updateLvl4Calls.2_test<-function(){
	platform<-"GBM-03"
	mageDir<-"c:\\tcga\\GBM_OMA003\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.mage-tab.1.2.0"
	mageFn<-"jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.1.sdrf.txt"
	updateLvl4Calls.2(mageDir,mageFn,platform)
	
	platform<-"GBM-02"
	mageDir<-"c:\\tcga\\GBM_OMA002\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA002_CPI.mage-tab.1.2.0"
	mageFn<-"jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA002_CPI.1.sdrf.txt"
	updateLvl4Calls.2(mageDir,mageFn,platform)
	
}
updateLvl4Calls.2<-function(mageDir=NULL,mageFn=NULL,platform="Meth27"){
	if(is.null(mageDir))mageDir<-"C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.17.0"
	if(is.null(mageFn))mageFn<-"jhu-usc.edu_GBM.HumanMethylation27.8.sdrf.txt"
	sdrf<-read.table(file=file.path(mageDir,mageFn),sep="\t",header=T,as.is=T,check.names=F)
	lvl4.call<-read.table(file="c:\\tcga\\others\\GBM_Level4_ClusterIDs.txt",header=T,sep="\t",as.is=T)
	sdrf.sid<-sdrf[,1]
	lvl4.sids<-lvl4.call[,1]
	sdrf.lvl4<-sdrf[,"Comment [LEVEL-4 G-CIMP STATUS]"]
	for(i in 1:length(lvl4.sids)){
		sid<-lvl4.sids[i]
		ind<-grep(sid,sdrf.sid)
		if(sum(ind)>0){
			#sdrf2<-sdrf.lvl4[ind]
			if(length(ind)>1) cat(paste(sid,":",length(ind),"\t",lvl4call,"\n"))
			if(platform=="Meth27")lvl4call<-lvl4.call[i,2]
			else if(platform=="GBM-03") lvl4call<-lvl4.call[i,4]
			else lvl4call<-lvl4.call[i,3]
			if(lvl4call=="2") sdrf.lvl4[ind]<-"Cluster 2"
			else if(lvl4call=="3") sdrf.lvl4[ind]<-"Cluster 3"
			else if(lvl4call=="1") {
				cat(paste(sdrf2,":=GCIMP\n"))
				sdrf.lvl4[ind]<-"Cluster 1"
			}else{
				cat(paste(sdrf2,"\t",lvl4call,"\n"))
				sdrf.lvl4[ind]<-NA
			}
		}
	}
	#sdrf[,"Comment [ClUSTER STATUS]"]<-sdrf.lvl4
	sdrf$'Comment [LEVEL-4 CLUSTER STATUS]'<-sdrf.lvl4
	if(platform=="Meth27")names(sdrf)<-c("Extract Name","Protocol REF","Labeled Extract Name","Label","Term Source REF","Protocol REF","Hybridization Name","Array Design File","Term Source REF","Protocol REF","Scan Name","Protocol REF","Protocol REF","Normalization Name","Derived Array Data Matrix File","Comment [TCGA Data Level]","Comment [TCGA Data Type]","Comment [TCGA Include for Analysis]","Comment [TCGA Archive Name]","Protocol REF","Normalization Name","Derived Array Data Matrix File","Comment [TCGA Data Level]","Comment [TCGA Data Type]","Comment [TCGA Include for Analysis]","Comment [TCGA Archive Name]","Protocol REF","Normalization Name","Derived Array Data Matrix File","Comment [TCGA Data Level]","Comment [TCGA Data Type]","Comment [TCGA Include for Analysis]","Comment [TCGA Archive Name]","Comment [G-CIMP STATUS]","Comment [CLUSTER STATUS]")
	else names(sdrf)<-c("Extract Name","Protocol REF","Labeled Extract Name","Label","Term Source REF","Protocol REF","Hybridization Name","Array Design File","Term Source REF","Protocol REF","Scan Name","Protocol REF","Protocol REF","Normalization Name","Derived Array Data Matrix File","Comment [TCGA Data Level]","Comment [TCGA Data Type]","Comment [TCGA Include for Analysis]","Comment [TCGA Archive Name]","Protocol REF","Normalization Name","Derived Array Data Matrix File","Comment [TCGA Data Level]","Comment [TCGA Data Type]","Comment [TCGA Include for Analysis]","Comment [TCGA Archive Name]","Comment [G-CIMP STATUS]","Comment [CLUSTER STATUS]")
	write.table(sdrf,file=file.path(mageDir,mageFn),sep="\t",row.names=F,quote=F)
	rst<-table(sdrf.lvl4)
	return(rst)
}
updateLvl4Calls<-function(sdrfFn,lvl4CallFn,txt=NULL){
	sdrf<-read.table(file=sdrfFn,sep="\t",as.is=T)
	lvl4call<-readDataFile.2(lvl4CallFn,isNum=F,rowName=NULL)
	nh<-paste("Comment [",names(lvl4call)[2],"]",sep="")
	lvl4.new<-data.frame(calls=rep("NA",nrow(sdrf)),stringsAsFactors=F)
	names(lvl4.new)<-nh
	sdrf.new<-data.frame(sdrf,lvl4.new)
	sdrf.new[1,]<-c(sdrf[1,],nh)
	names(sdrf.new)<-sdrf.new[1,]
	for(i in 1:nrow(lvl4call)){
		ind<-sum(regexpr(lvl4call[i,1],sdrf.new[,1])>=1)
		if(ind>=1){
			ind<-grep(lvl4call[i,1],sdrf.new[,1])
			msg<-paste(">Find match of the sample of ",lvl4call[i,1]," from SDRF ",sdrf.new[ind,1],"\t",i,"\n")
			cat(msg)
			#if(!is.null(txt)) tkinsert(txt,"end",msg)
			sdrf.new[ind,nh]<-as.character(lvl4call[i,2])
		}else{
			msg<-paste("No match found for sample ",lvl4call[i,1],"\n")
			if(!is.null(txt)) tkinsert(txt,"end",msg)
			cat(msg)
		}
	}
	print(table(sdrf.new[,nh]))
	msg<-">Finished updating Level-4 Data Calls\n"
	cat(msg)
	if(!is.null(txt)) tkinsert(txt,"end",msg)
	write.table(sdrf.new,file=sdrfFn,sep="\t",row.names=F,quote=F,col.names=F)
}
updateMagePkg.2<-function(txt=NULL){
	updateMagePkgDlg.2()
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",">Start to update mage tab package\n")
	mageFolder<-filedir(reValue[2])
	mageFile<-filetail(reValue[2])
	if(reValue[3]!="") updateLvl4Calls(reValue[2],reValue[3],txt)
	if(reValue[4]=="YES") mageFolder<-updateMageSN(mageFolder)
	if(reValue[1]!=""){
		dat<-strsplit(strsplit(filetail(reValue[1]),"Methylation27.")[[1]][2],"\\.tar")[[1]][1]
		dat.old<-strsplit(strsplit(filetail(reValue[5]),"Methylation27.")[[1]][2],"\\.tar")[[1]][1]
		sdrf<-readLines(file.path(mageFolder,mageFile))
		sdrf<-gsub(dat.old,dat,sdrf)
		write(sdrf,file=file.path(mageFolder,mageFile))
	}
	createManifestByLevel.2(mageFolder)
	compressDataPackage(mageFolder)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished updating mage tab package\n")
}
updateMagePkg<-function (txt = NULL) 
{
	updateMagePkgDlg()
	if (is.null(reValue)) 
		return()
	if (!is.null(txt)) 
		tkinsert(txt, "end", ">Start to update mage tab package\n")
	mageFolder <- filedir(reValue[2])
	if (reValue[3] != "") 
		updateLvl4Calls(reValue[2], reValue[3], txt)
	if (reValue[4] == "YES") 
		mageFolder <- updateMageSN(mageFolder)
	if (reValue[1] != "") {
		dat <- strsplit(reValue[1], "Methylation27.")[[1]][2]
		tt <- strsplit(dat, "\\.")[[1]]
		tt[2] <- as.numeric(tt[2]) - 1
		dat.old <- paste(tt, collapse = ".")
		sdrf <- readLines(reValue[2])
		sdrf <- gsub(dat.old, dat, sdrf)
		write(sdrf, file = reValue[2])
	}
	createManifestByLevel.2(mageFolder)
	compressDataPackage(mageFolder)
	reValue <<- NULL
	if (!is.null(txt)) 
		tkinsert(txt, "end", ">Finished updating mage tab package\n")
}

createLvl3Package<-function(txt=NULL){
	createLvlPkgDialog("Create level 3 data package","jhu-usc.edu_OV.HumanMethylation27.Level_3.1.0.0")
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",">Start creating lvl 3 data package\n")
	lvl3pkg<-file.path(reValue[2],reValue[4])
	createLvl3Pkg(reValue[1],lvl3pkg,reValue[3])
	createManifestByLevel.2(lvl3pkg)
	compressDataPackage(lvl3pkg)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished lvl 3 data packaging\n")
}

createLvl3Pkg<-function(src_folder,lvl3_folder,descriptFn=NULL){
	flists<-list.files(src_folder,pattern=".txt")
	flists<-flists[grep("lvl-3",flists)]
	if(!file.exists(lvl3_folder)) dir.create(lvl3_folder)
	for( fn in flists){
		write(readLines(file.path(src_folder,fn)),file.path(lvl3_folder,fn))
	}
	if(!is.null(descriptFn)) {
		options(warn=-1)
		write(readLines(descriptFn),file.path(lvl3_folder,"DESCRIPTION.txt"))
		options(warn=1)
	}
}
updateLvl3Pkg_test<-function(){
	newPkgFolder<-"C:\\temp\\test\\jhu-usc.edu_COAD.HumanMethylation27.1\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.1.1.0"
	srcDataFolder<-"C:\\temp\\test\\jhu-usc.edu_COAD.HumanMethylation27.1\\jhu-usc.edu_COAD.HumanMethylation27.Level_2.1.0.0"
	descriptFn<-"C:\\temp\\test\\jhu-usc.edu_COAD.HumanMethylation27.1\\jhu-usc.edu_COAD.HumanMethylation27.Level_2.1.0.0\\DESCRIPTION.txt"
	reValue<-c(srcDataFolder,newPkgFolder,"YES","",descriptFn)
	assign("reValue",reValue,envir=.GlobalEnv)
	updateLvl3Pkg(NULL,TRUE)
}
updateLvl3Pkg_test.2<-function(){
	pkg2<-"/auto/uec-02/shared/tmp/repos/jhu-usc.edu_BRCA.HumanMethylation27.1/jhu-usc.edu_BRCA.HumanMethylation27.Level_2.1.0.0"
	pkg3Dir<-"/auto/uec-02/shared/tmp/repos/jhu-usc.edu_BRCA.HumanMethylation27.1/jhu-usc.edu_BRCA.HumanMethylation27.Level_3.1.0.0"
	descriptionFn<-"/auto/uec-02/shared/tmp/repos/jhu-usc.edu_BRCA.HumanMethylation27.1/jhu-usc.edu_BRCA.HumanMethylation27.Level_3.1.0.0/DESCRIPTION.txt"
	magePkg<-"/auto/uec-02/shared/tmp/repos/jhu-usc.edu_BRCA.HumanMethylation27.1/jhu-usc.edu_BRCA.HumanMethylation27.mage-tab.1.1.0"
	reValue<-c(pkg2,pkg3Dir,"YES",magePkg,descriptionFn)
	assign("reValue",reValue,envir=.GlobalEnv)
	updateLvl3Pkg(NULL,TRUE)
}
updateLvl3Pkg<-function(txt=NULL,auto=F){
	if(auto==F)updateLvlPackageDialog("Update Level 3 Data Package")
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to create level 3 data package...",date(),"\n",sep=""))
	src_data_folder<-reValue[1]
	new_pkg_folder<-reValue[2]
	descriptFn<-reValue[5]
	if(!file.exists(new_pkg_folder)) dir.create(new_pkg_folder)
	create_lvl3_data.2(src_data_folder,new_pkg_folder)
	old_pkg<-filetail(new_pkg_folder)
	new_pkg<-NULL
	if(file.exists(descriptFn)) {
		options(warn=-1)
		write(readLines(descriptFn),file.path(new_pkg_folder,"DESCRIPTION.txt"))
		options(warn=1)
	}
	if(reValue[3]=="YES"){
		new_pkg_folder<-updatePkgSN(new_pkg_folder)
		new_pkg<-filetail(new_pkg_folder)
	}
	if(reValue[4]!=""){
		updateMageTabFile(reValue[4],old_pkg,new_pkg)
	}
	updateDescriptFn(old_pkg,new_pkg_folder)
	createManifestByLevel.2(new_pkg_folder)
	compressDataPackage(new_pkg_folder)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Done\n")
}

updateDescriptFn<-function(old_pkg,new_pkg_folder){
	fn<-file.path(new_pkg_folder,"DESCRIPTION.txt")
	old_pkg_sn<-strsplit(old_pkg,"Level_..")[[1]][2]
	new_pkg_sn<-strsplit(filetail(new_pkg_folder),"Level_..")[[1]][2]
	if(file.exists(fn)){
		descrip<-readLines(fn)
		descrip.new<-gsub(old_pkg_sn,new_pkg_sn,descrip)
		write(descrip.new,fn)
	}
}
updateDescriptFn_test<-function(){
	updateDescriptFn("jhu-usc.edu_COAD.HumanMethylation27.Level_3.1.0.0","C:\\tcga\\repos\\jhu-usc.edu_COAD.HumanMethylation27.1\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.1.1.0")
	updateDescriptFn("jhu-usc.edu_COAD.HumanMethylation27.Level_3.3.0.0","C:\\tcga\\repos\\jhu-usc.edu_COAD.HumanMethylation27.3\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.3.1.0")
	updateDescriptFn("jhu-usc.edu_COAD.HumanMethylation27.Level_3.4.0.0","C:\\tcga\\repos\\jhu-usc.edu_COAD.HumanMethylation27.4\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.4.1.0")
	
}
updatePkgSN<-function(PkgFolder){
	new_pkg_folder<-PkgFolder
	new_pkg_folder1<-new_pkg_folder
	pkg_name<-filetail(new_pkg_folder)
	pkg_folder<-filedir(new_pkg_folder)
	t1<-strsplit(pkg_name,"\\.")[[1]]
	old_pkg<-paste(t1[4],t1[5],t1[6],t1[7],collapse="",sep=".")
	t1[6]<-as.numeric(t1[6])+1
	new_pkg<-paste(t1[4],t1[5],t1[6],t1[7],sep=".")
	pkg_name_new<-paste(t1,collapse=".")
	new_pkg_folder<-file.path(pkg_folder,pkg_name_new)
	if(file.exists(new_pkg_folder))file.remove(new_pkg_folder)
	file.rename(new_pkg_folder1,new_pkg_folder)
	return(new_pkg_folder)
}
updateMageSN<-function(magePkgFolder){
	new_pkg_folder<-magePkgFolder
	new_pkg_folder1<-new_pkg_folder
	pkg_name<-tclvalue(tclfile.tail(new_pkg_folder))
	pkg_folder<-tclvalue(tclfile.dir(new_pkg_folder))
	t1<-strsplit(pkg_name,"\\.")[[1]]
	old_pkg<-paste(t1[4],t1[5],t1[6],t1[7],collapse="",sep=".")
	t1[6]<-as.numeric(t1[6])+1
	new_pkg<-paste(t1[4],t1[5],t1[6],t1[7],sep=".")
	pkg_name_new<-paste(t1,collapse=".")
	new_pkg_folder<-file.path(pkg_folder,pkg_name_new)
	file.rename(new_pkg_folder1,new_pkg_folder)
	return(new_pkg_folder)
}
updateMageTabFile<-function(mageFolder,old_pkg,new_pkg){
	sdrf_fn<-list.files(mageFolder,pattern=".sdrf")
	dat<-readLines(file.path(mageFolder,sdrf_fn))
	dat<-gsub(old_pkg,new_pkg,dat)
	write(dat,file=file.path(mageFolder,sdrf_fn))
	createManifestByLevel.2(mageFolder)
	compressDataPackage(mageFolder)
}
updateLvlPackageDialog<-function(tit=""){
	dlg<-startDialog(tit)
	tkgrid(tklabel(dlg,text="   "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the Leve 2 Data Folder:","",isFolder=T,name="srcDataFolder")
	addTextEntryWidget(dlg1,"Select the Level 3 Packge Folder:","",isFolder=T,name="newPkgFolder")
	addTextEntryWidget(dlg1,"Select the Mage Manifest Folder (Opt):","",isFolder=T,name="mageTabFolder")
	addTextEntryWidget(dlg1,"Select the Description File (Opt):","",isFolder=F,name="descriptFn")
	addTextEntryWidget(dlg1,"Increase the Package Series Number:","YES",withSelectButton=F,name="pkgSeriesNumber")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("srcDataFolder","newPkgFolder","pkgSeriesNumber","mageTabFolder","descriptFn"),pad=T)
}
###############################
#

createDataPackage.2<-function(txt=NULL,old_scheme=F,new_scheme=F,packaging=TRUE,auto=F,
		pkgname=NULL,isTCGA=F,arraymapping=NULL){
	if(auto==F) createDataPackageDialog("Create TCGA Data Package")
	if(!is.null(txt)){
		msg<-paste("> Starting ..., on ",date(),"\n",sep="")
		tkinsert(txt,"end",msg)
	}
	sig_A <- tcgaPackage_A
	sig_A_se <- tcgaPackage_A_se
	sig_B <- tcgaPackage_B
	sig_B_se<- tcgaPackage_B_se
	ctr_R_fn <- tcgaPackage_R_ctr
	ctr_G_fn <- tcgaPackage_G_ctr
	pvalue_fn <- tcgaPackage_pvalue_fn
	beta_fn <- tcgaPackage_beta_fn
	sig_A_n <-tcgaPackage_A_n
	sig_B_n <-tcgaPackage_B_n
	tcgaPackage_outdir<-tcgaPackage_outputDir
	if(!is.null(pkgname)) tcgaPackage_name<-pkgname
	readme_fn<-NULL
	if(exists("tcgaPackage_Descrip_fn")) readme_fn<-tcgaPackage_Descrip_fn
	data.dir<-filedir(sig_A)
	if(!is.null(txt)){
		msg<-paste(">Input DNA Un-Methlation Signal Intensity File is: ",filetail(tcgaPackage_A),"\n",sep="")
		cat(msg)
		msg<-paste(">Input STDER of DNA Un-Methlation Intensity File is: ",filetail(tcgaPackage_A_se),"\n",sep="")
		cat(msg)
		msg<-paste(">Input Beads Number of DNA Un-Methlation Intensity File is: ",filetail(tcgaPackage_A_n),"\n",sep="")
		cat(msg)
		msg<-paste(">Input DNA Methlation Signal Intensity File is: ",filetail(tcgaPackage_B),"\n",sep="")
		cat(msg)
		msg<-paste(">Input sTDER of DNA Methlation Intensity File is: ",filetail(tcgaPackage_B_se),"\n",sep="")
		cat(msg)
		msg<-paste(">Input Beads Number of DNA Methlation Intensity File is: ",filetail(tcgaPackage_B_n),"\n",sep="")
		cat(msg)
		msg<-paste(">Input Neg Control Red Intensity File is: ",filetail(tcgaPackage_R_ctr),"\n",sep="")
		cat(msg)
		msg<-paste(">Input Neg Control Grn Intensity File is: ",filetail(tcgaPackage_G_ctr),"\n",sep="")
		cat(msg)
		msg<-paste(">Input Detection P value File is: ",filetail(tcgaPackage_pvalue_fn),"\n",sep="")
		cat(msg)
		msg<-paste(">Input DNA Methlation Beta Value File is: ",filetail(tcgaPackage_beta_fn),"\n",sep="")
		cat(msg)
		msg<-paste(">Input the Name of the Package is: ",filetail(tcgaPackage_name),"\n",sep="")
		cat(msg)
		msg<-paste(">The output folder is: ",tcgaPackage_outputDir,"\n",sep="")
		cat(msg)
	}
	
	tdir <- tempdir()
	if(!is.null(tcgaPackage_outputDir)){
		tdir <- tcgaPackage_outputDir;
	}
	setwd(tdir)
	wdir = tcgaPackage_name
	if(!file.exists(file.path(tdir,wdir)))dir.create(wdir)
	pref6<-paste(tdir,wdir,sep="/");
	if(!is.null(txt)){
		msg<-paste(">Generating the TCGA Packaging Files in Folder ",pref6,date(),"\n",sep="")
		cat(msg)
	}

	sampleIDa<-packInfinium.2(sig_A,sig_A_se,sig_A_n,sig_B,sig_B_se,sig_B_n,pvalue_fn,beta_fn,
			ctr_R_fn,ctr_G_fn,pref6,tcgaPackage_name,txt,readme_fn)#isTCGA=isTCGA,sampleCode)
	sampleCode<-NULL
	if(!is.null(arraymapping)){
		sampleInfo<-extractSampleInfo(arraymapping)
		sampleCode<-sampleInfo$sampleCode
		if(sum(!is.element(sampleIDa,sampleCode))>0) trimSampleData(sampleIDa,sampleCode,pref6)
	}
	if(isTCGA==T ){
		if(old_scheme==TRUE){
			if(!is.null(txt)){
				msg<-paste(">Done! TCGA Packaging Files have been generate in ",tdir,wdir,"\n",sep="")
				cat(msg)	
			}
			
			if(!is.null(txt)){
				cat(paste(">Work on data compression now ...",date(),"\n",sep=""))
			}
			compressDataPackage.2(tdir,tcgaPackage_name);
			if(!is.null(txt)){
				msg<-paste(">The TCGA Package has been compressed in folder ",tdir,date(),"\n",sep="")
				cat(msg)
				msg<-paste(">Start to deposite the package...",date(),"\n")
				cat(msg)
			}
			#depositePkg(tdir)
			
		}
		if(new_scheme==TRUE & packaging==TRUE){
			#todo: retrieve the series_numbers from db/repository
			type_pkg<-strsplit(strsplit(tcgaPackage_name,"_")[[1]][2],"\\.")[[1]][1]
			t1=unlist(strsplit(tcgaPackage_name,"\\."))
			pref5 <- paste(t1[1],".",t1[2],".",t1[3],sep="")
			pref4 <- paste(pref5,".",t1[4],sep="")
			arch_numb = paste(t1[4],".",t1[5],".",t1[6],sep="")
			arch_numb_manifest<- paste("1.",t1[4],".0",sep="")
			#create level folder
			lvl_1_fdname <- paste(pref5,".Level_1.",arch_numb,sep="")
			lvl_2_fdname <- paste(pref5,".Level_2.",arch_numb,sep="")
			lvl_3_fdname <- paste(pref5,".Level_3.",arch_numb,sep="")
			pkg_folder<-file.path(tcgaPackage_outdir,pref4)
			if(file.exists(pkg_folder)){
				system(paste("rm -r ",pkg_folder,sep=""))
			}
			if(!file.exists(pkg_folder))dir.create(pkg_folder)
			setwd(pkg_folder)
			if(!file.exists(lvl_1_fdname))dir.create(lvl_1_fdname)
			if(!file.exists(lvl_2_fdname))dir.create(lvl_2_fdname)
			if(!file.exists(lvl_3_fdname))dir.create(lvl_3_fdname)
			
			#mv data files needed for new packaging
			pref6<-paste(tcgaPackage_outdir,tcgaPackage_name,sep="/")
			old_scheme_datas_dir <-pref6
			setwd(old_scheme_datas_dir)
			flist<-list.files(pattern="lvl-1")
			destination_fd <-paste(pkg_folder,"/",lvl_1_fdname,sep="")
			file.copy(flist,destination_fd,overwrite=TRUE,recursive=TRUE) 
			destination_fd <-paste(pkg_folder,"/",lvl_2_fdname,sep="")
			flist<-list.files(pattern="lvl-2")
			file.copy(flist,destination_fd,overwrite=TRUE,recursive=TRUE)
			destination_fd<-paste(pkg_folder,"/",lvl_3_fdname,sep="")
			flist<-list.files(pattern="lvl-3")
			file.copy(flist,destination_fd,overwrite=TRUE,recursive=TRUE)
			
			#create mage-tab files from sample file and update it
			manifest_fdname <- paste(pref5,".mage-tab.",arch_numb_manifest,sep="")
			manifest_dir<-file.path(pkg_folder,manifest_fdname)
			if(!file.exists(manifest_dir))dir.create(manifest_dir)
			mage_tab_fn <- paste(pref4,".sdrf.txt",sep="")
			adf_fn<-paste(pref4,".adf.txt",sep="")
			#		toAppend<-F
			#		if(toAppend){
			#			getCurrentManifest(manifest_dir,mage_tab_fn,type_pkg)
			#		}
			sampleIDa<-getSampleID(file.path(pkg_folder,lvl_1_fdname))
			create_Mage_TAB_SDRF.2(pref4,pref5,sampleIDa,manifest_dir,mage_tab_fn,arch_numb,adf_fn)
			
			create_IDF_file(pref4,manifest_dir,type_pkg)
			
			create_ADF_file(adf_fn,manifest_dir)
			data_dir<-file.path(tcgaPackage_outdir,tcgaPackage_name)
			if(!is.null(arraymapping)){
				create_Level_Description_File.2(pkg_folder,lvl_1_fdname,lvl_2_fdname,lvl_3_fdname,arraymapping)
			}else{
				create_Level_Description_File(data_dir,pkg_folder,lvl_1_fdname,lvl_2_fdname,lvl_3_fdname)
			}
			
			wdir<-pkg_folder
			#createManifestByLevel(pkg_folder)
			createManifestByLevel.2a(pkg_folder,lvl_1_fdname)
			createManifestByLevel.2a(pkg_folder,lvl_2_fdname)
			createManifestByLevel.2a(pkg_folder,lvl_3_fdname)
			createManifestByLevel.2a(pkg_folder,manifest_fdname)
			#if(packaging==TRUE){
			# compress into packages
			setwd(wdir)
			#pack lvl_1-3 and mage files
			compressDataPackage.2(pkg_folder,lvl_1_fdname)
			compressDataPackage.2(pkg_folder,lvl_2_fdname)
			compressDataPackage.2(pkg_folder,lvl_3_fdname)
			compressDataPackage.2(pkg_folder,manifest_fdname)
			#			validateInfiniumPkg(pkg_folder,tcgaPackage_name)
			#pkg_validate(pkg_folder)
			
		}
	}else if(isTCGA!=F &packaging==T){
		outPath<-tcgaPackage_outdir
		datPath<-file.path(tcgaPackage_outdir,tcgaPackage_name)
		packagingArrays.2(dataPath,outPath,inc=F,ext=".txt")
	}
#	runQCvalidation(data.dir,bvFn=beta_fn,ctrRedFn=ctr_R_fn,ctrGrnFn=ctr_G_fn)
	
	#tkconfigure(tt,cursor="arrow")
	
	if(exists("tcgaPackage_A"))rm("tcgaPackage_A",envir = .GlobalEnv)
	if(exists("tcgaPackage_B"))rm("tcgaPackage_B",envir = .GlobalEnv)
	if(exists("tcgaPackage_A_se"))rm("tcgaPackage_A_se",envir=.GlobalEnv)
	if(exists("tcgaPackage_B_se"))rm("tcgaPackage_B_se",envir=.GlobalEnv)
	if(exists("tcgaPackage_R_ctr"))rm("tcgaPackage_R_ctr",envir=.GlobalEnv)
	if(exists("tcgaPackage_G_ctr"))rm("tcgaPackage_G_ctr",envir=.GlobalEnv)
	if(exists("tcgaPackage_pvalue_fn"))rm("tcgaPackage_pvalue_fn",envir=.GlobalEnv)
	if(exists("tcgaPackage_beta_fn"))rm("tcgaPackage_beta_fn",envir=.GlobalEnv)
	if(exists("tcgaPackage_A_n"))rm("tcgaPackage_A_n",envir=.GlobalEnv)
	if(exists("tcgaPackage_B_n"))rm("tcgaPackage_B_n",envir=.GlobalEnv)
	if(exists("tcgaPackage_name"))rm("tcgaPackage_name",envir=.GlobalEnv)
	if(exists("tcgaPackage_outputDir"))rm("tcgaPackage_outputDir",envir=.GlobalEnv)
	return (pref6)
}
trimSampleData_test<-function(){
	outDir<-"C:\\temp\\jhu-usc.edu_GBM.HumanMethylation27.1.0.0"
	sampleIDs<-c("TCGA-02-2470-01A-01D-0788-05","TCGA-06-2563-01A-01D-0788-05","TCGA-06-2565-01A-01D-0788-05")
	pkgSampleIDs<-c("TCGA-06-2565-01A-01D-0788-05","TCGA-14-0790-01B-01D-0788-05")
	trimSampleData(sampleIDs,pkgSampleIDs,outDir)
}
trimSampleData<-function(sampleIDs,pkgSampleIDs,outDir){
	datFns<-list.files(outDir,".txt")
	sample.rm<-sampleIDs[!is.element(sampleIDs,pkgSampleIDs)]
	if(length(sample.rm)==0)return()
	for(i in 1:length(sample.rm)){
		datFn.rm<-datFns[grep(sample.rm[i],datFns)]
		for(fn in datFn.rm){
			file.remove(file.path(outDir,fn))
		}
	}
}
createDataPackage_test<-function(){
	datDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\TCGA Batch 49 Data Package (jhu-usc.edu_UCEC.HumanMethylation27.1.0.0)"
	tcgaPackage_A<-file.path(datDir,"TCGA Batch 49 unmethylated signal intensity.txt")
	tcgaPackage_A_se<-file.path(datDir,"TCGA Batch 49 unmethylated bead stderr.txt")
	tcgaPackage_A_n<-file.path(datDir,"TCGA Batch 49 average number of unmethylated beads.txt")
	tcgaPackage_B<-file.path(datDir,"TCGA batch 49 methylated signal intensity.txt")
	tcgaPackage_B_se<-file.path(datDir,"TCGA Batch 49 methylated bead stderr.txt")
	tcgaPackage_B_n<-file.path(datDir,"TCGA Batch 49 average number of methylated beads.txt")
	tcgaPackage_pvalue_fn<-file.path(datDir,"TCGA Batch 49 Detection P-value.txt")
	tcgaPackage_beta_fn<-file.path(datDir,"TCGA Batch 49 beta values (level 2).txt")
	tcgaPackage_R_ctr<-file.path(datDir,"TCGA Batch 49 negative control probe signal_red.txt")
	tcgaPackage_G_ctr<-file.path(datDir,"TCGA Batch 49 negative control probe signal_green.txt")
	tcgaPackage_outputDir<-"c:\\temp"
	tcgaPackage_name<-"jhu-usc.edu_UCEC.HumanMethylation27.12.0.0"
	txt=NULL
	tcgaPackage_Descrip_fn<-file.path(datDir,"readme.txt")
	createDataPackage(txt,new_scheme=T,auto=T)
}

createDataPackage<-function(txt=NULL,old_scheme=F,new_scheme=F,packaging=TRUE,tt=NULL,auto=F){
	if(auto==F) createDataPackageDialog("Create TCGA Data Package",tt)
	if(!exists("tcgaPackage_A")) return()
	if(!is.null(tt))tkfocus(tt)
	#tkconfigure(tt,cursor="watch")
	if(!is.null(txt)){
		msg<-paste("> Starting ..., on ",date(),"\n",sep="")
		tkinsert(txt,"end",msg)
	}
	sig_A <- tcgaPackage_A
	sig_A_se <- tcgaPackage_A_se
	sig_B <- tcgaPackage_B
	sig_B_se<- tcgaPackage_B_se
	ctr_R_fn <- tcgaPackage_R_ctr
	ctr_G_fn <- tcgaPackage_G_ctr
	pvalue_fn <- tcgaPackage_pvalue_fn
	beta_fn <- tcgaPackage_beta_fn
	sig_A_n <-tcgaPackage_A_n
	sig_B_n <-tcgaPackage_B_n
	tcgaPackage_outdir<-tcgaPackage_outputDir
	readme_fn<-NULL
	if(exists("tcgaPackage_Descrip_fn")) readme_fn<-tcgaPackage_Descrip_fn
	data.dir<-tclvalue(tclfile.dir(sig_A))
	if(!is.null(txt)){
		msg<-paste(">Input DNA Un-Methlation Signal Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_A)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input STDER of DNA Un-Methlation Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_A_se)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input Beads Number of DNA Un-Methlation Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_A_n)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input DNA Methlation Signal Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_B)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input sTDER of DNA Methlation Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_B_se)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input Beads Number of DNA Methlation Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_B_n)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input Neg Control Red Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_R_ctr)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input Neg Control Grn Intensity File is: ",tclvalue(tclfile.tail(tcgaPackage_G_ctr)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input Detection P value File is: ",tclvalue(tclfile.tail(tcgaPackage_pvalue_fn)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input DNA Methlation Beta Value File is: ",tclvalue(tclfile.tail(tcgaPackage_beta_fn)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">Input the Name of the Package is: ",tclvalue(tclfile.tail(tcgaPackage_name)),"\n",sep="")
		tkinsert(txt,"end",msg)
		msg<-paste(">The output folder is: ",tcgaPackage_outputDir,"\n",sep="")
		tkinsert(txt,"end",msg)
	}
	
	tdir <- tempdir()
	if(!is.null(tcgaPackage_outputDir)){
		tdir <- tcgaPackage_outdir;
	}
	setwd(tdir)
	wdir = tcgaPackage_name
	dir.create(wdir)
	pref6<-paste(tdir,wdir,sep="/");
	if(!is.null(txt)){
		msg<-paste(">Generating the TCGA Packaging Files in Folder ",pref6,date(),"\n",sep="")
		tkinsert(txt,"end",msg)
	}
	sampleIDa<-packInfinium.2(sig_A,sig_A_se,sig_A_n,sig_B,sig_B_se,sig_B_n,pvalue_fn,beta_fn,
			ctr_R_fn,ctr_G_fn,pref6,tcgaPackage_name,txt,readme_fn)
	if(old_scheme==TRUE){
		if(!is.null(txt)){
			msg<-paste(">Done! TCGA Packaging Files have been generate in ",tdir,wdir,"\n",sep="")
			tkinsert(txt,"end",msg)	
		}
		if(packaging==TRUE){
			if(!is.null(txt)){
				tkinsert(txt,"end",paste(">Work on data compression now ...",date(),"\n",sep=""))
			}
			compressDataPackage(tdir,tcgaPackage_name);
			if(!is.null(txt)){
				msg<-paste(">The TCGA Package has been compressed in folder ",tdir,date(),"\n",sep="")
				tkinsert(txt,"end",msg)
				msg<-paste(">Start to deposite the package...",date(),"\n")
				tkinsert(txt,"end",msg)
			}
			#depositePkg(tdir)
		}
	}
	if(new_scheme==TRUE){
		#todo: retrieve the series_numbers from db/repository
		type_pkg<-strsplit(strsplit(tcgaPackage_name,"_")[[1]][2],"\\.")[[1]][1]
		t1=unlist(strsplit(tcgaPackage_name,"\\."))
		pref5 <- paste(t1[1],".",t1[2],".",t1[3],sep="")
		pref4 <- paste(pref5,".",t1[4],sep="")
		arch_numb = paste(t1[4],".",t1[5],".",t1[6],sep="")
		arch_numb_manifest<- paste("1.",t1[4],".0",sep="")
		#create level folder
		lvl_1_fdname <- paste(pref5,".Level_1.",arch_numb,sep="")
		lvl_2_fdname <- paste(pref5,".Level_2.",arch_numb,sep="")
		lvl_3_fdname <- paste(pref5,".Level_3.",arch_numb,sep="")
		pkg_folder<-file.path(tcgaPackage_outdir,pref4)
		if(file.exists(pkg_folder)){
			system(paste("rm -r ",pkg_folder,sep=""))
		}
		dir.create(pkg_folder)
		setwd(pkg_folder)
		dir.create(lvl_1_fdname)
		dir.create(lvl_2_fdname)
		dir.create(lvl_3_fdname)
		
		#mv data files needed for new packaging
		pref6<-paste(tcgaPackage_outdir,tcgaPackage_name,sep="/")
		old_scheme_datas_dir <-pref6
		setwd(old_scheme_datas_dir)
		flist<-list.files(pattern="lvl-1")
		destination_fd <-paste(pkg_folder,"/",lvl_1_fdname,sep="")
		file.copy(flist,destination_fd,overwrite=TRUE,recursive=TRUE) 
		destination_fd <-paste(pkg_folder,"/",lvl_2_fdname,sep="")
		flist<-list.files(pattern="lvl-2")
		file.copy(flist,destination_fd,overwrite=TRUE,recursive=TRUE)
		destination_fd<-paste(pkg_folder,"/",lvl_3_fdname,sep="")
		flist<-list.files(pattern="lvl-3")
		file.copy(flist,destination_fd,overwrite=TRUE,recursive=TRUE)
		
		#create mage-tab files from sample file and update it
		manifest_fdname <- paste(pref5,".mage-tab.",arch_numb_manifest,sep="")
		manifest_dir<-file.path(pkg_folder,manifest_fdname)
		dir.create(manifest_dir)
		mage_tab_fn <- paste(pref4,".sdrf.txt",sep="")
		adf_fn<-paste(pref4,".adf.txt",sep="")
		toAppend<-F
		if(toAppend){
			getCurrentManifest(manifest_dir,mage_tab_fn,type_pkg)
		}
		create_Mage_TAB_SDRF(pref4,pref5,sampleIDa,manifest_dir,mage_tab_fn,arch_numb,adf_fn,toAppend)
	
		create_IDF_file(pref4,manifest_dir,type_pkg)
		
		create_ADF_file(adf_fn,manifest_dir)
		data_dir<-file.path(tcgaPackage_outdir,tcgaPackage_name)
		create_Level_Description_File(data_dir,pkg_folder,lvl_1_fdname,lvl_2_fdname,lvl_3_fdname)
		wdir<-pkg_folder
		#createManifestByLevel(pkg_folder)
		createManifestByLevel.2(pkg_folder,lvl_1_fdname)
		createManifestByLevel.2(pkg_folder,lvl_2_fdname)
		createManifestByLevel.2(pkg_folder,lvl_3_fdname)
		createManifestByLevel.2(pkg_folder,manifest_fdname)
		if(packaging==TRUE){
			# compress into packages
			setwd(wdir)
			#pack lvl_1-3 and mage files
			compressDataPackage(pkg_folder,lvl_1_fdname)
			compressDataPackage(pkg_folder,lvl_2_fdname)
			compressDataPackage(pkg_folder,lvl_3_fdname)
			compressDataPackage(pkg_folder,manifest_fdname)
			#depositePkg(pkg_folder)
#			validateInfiniumPkg(pkg_folder,tcgaPackage_name)
			pkg_validate(pkg_folder)
			validatePkg(wdir,txt=txt)
		}
	}
#	runQCvalidation(data.dir,bvFn=beta_fn,ctrRedFn=ctr_R_fn,ctrGrnFn=ctr_G_fn)
	
	#tkconfigure(tt,cursor="arrow")
	
	if(exists("tcgaPackage_A"))rm("tcgaPackage_A",envir = .GlobalEnv)
	if(exists("tcgaPackage_B"))rm("tcgaPackage_B",envir = .GlobalEnv)
	if(exists("tcgaPackage_A_se"))rm("tcgaPackage_A_se",envir=.GlobalEnv)
	if(exists("tcgaPackage_B_se"))rm("tcgaPackage_B_se",envir=.GlobalEnv)
	if(exists("tcgaPackage_R_ctr"))rm("tcgaPackage_R_ctr",envir=.GlobalEnv)
	if(exists("tcgaPackage_G_ctr"))rm("tcgaPackage_G_ctr",envir=.GlobalEnv)
	if(exists("tcgaPackage_pvalue_fn"))rm("tcgaPackage_pvalue_fn",envir=.GlobalEnv)
	if(exists("tcgaPackage_beta_fn"))rm("tcgaPackage_beta_fn",envir=.GlobalEnv)
	if(exists("tcgaPackage_A_n"))rm("tcgaPackage_A_n",envir=.GlobalEnv)
	if(exists("tcgaPackage_B_n"))rm("tcgaPackage_B_n",envir=.GlobalEnv)
	if(exists("tcgaPackage_name"))rm("tcgaPackage_name",envir=.GlobalEnv)
	if(exists("tcgaPackage_outputDir"))rm("tcgaPackage_outputDir",envir=.GlobalEnv)
	return (pref6)
}

getCurrentManifest<-function(manifest_dir,manifest_fn,type_pkg="GBM"){
	fn<-paste(system.file("data",package="rapid"),"/",type_pkg,"_mage_tab.txt",sep="")
	if(!file.exists(fn)){
		fn<-paste("http://epimatrix.usc.edu:8080/data/",type_pkg,"_mage_tab.txt",sep="")
	}
	dest_fn<-file.path(manifest_dir,manifest_fn)
	system(paste("rm ",dest_fn,sep=""))
	file.copy(fn,dest_fn)
}
create_IDF_file_test<-function(){
	fn<-"jhu_usc.edu_OV.HumanMethylation27"
	mdir<-"c:\\temp"
	create_IDF_file(fn,mdir,"OV",platform="meth27k")
	
	fn<-"jhu_usc.edu_OV.HumanMethylation450"
	create_IDF_file(fn,mdir,"OV",platform="meth450k")
}
create_IDF_file<-function(fn,manifest_dir,cancer_type=NULL,platform="meth27k"){
	idf_fn <- paste(fn,".idf.txt",sep="")
	fp<-file.path(manifest_dir,idf_fn)
	fl.name<-" Using Illumina Infinium Human DNA Methylation 27 platform (HumanMethylation27)\n"
	pl.name<-"HumanMethylation27";pl.sn<-"27"
	if(platform=="meth450k"){
		fl.name<-" Using Illumina Infinium Human DNA Methylation 450 platform (HumanMethylation450)\n"
		pl.name<-"HumanMethylation450";pl.sn<-"450"
	}
	part.1<-paste("Investigation Title\tTCGA Analysis of DNA Methylation for ",cancer_type,fl.name,sep="")				
	
	part.1.1<-paste("Experimental Design\tdisease_state_design",				
			"Experimental Design Term Source REF\tMGED Ontology",			
			"Experimental Factor Type\tdisease",	 			
			"Experimental Factor Type Term Source REF\tMGED Ontology",			
			"\n",
			"Person Last Name\tLaird",	
			"Person First Name\tPeter",		
			"Person Mid Initials\tW",	
			"Person Email\tplaird@usc.edu",			
			"Person Phone\t323.442.7890",		
			"Person Address\tUSC Epigenome Center, University of Southern California, CA 90033, USA",				
			"Person Affiliation\tUniversity of Southern California",			
			"Person Roles\tsubmitter",
			"\n",
			"Quality Control Types\treal_time_PCR_quality_control",			
			"Quality Control Types Term Source REF\tMGED Ontology",			
			"Replicate Type\tbioassay_replicate_reduction",	
			"Replicate Type Term Source REF\tMGED Ontology",
			sep="\n")
	part.2<-paste("Date of Experiment",date(),sep="\t")
	part.3<-paste("Public Release Date",date(),sep="\t")
	part.4<-paste("Experiment Description\tTCGA Analysis of DNA Methylation Using Illumina Infinium Human DNA Methylation ",pl.sn," platform",sep="")				
	if(!is.null(cancer_type)){
		part.4<-paste("Experiment Description\tTCGA Analysis of DNA Methylation for ",cancer_type," Using Illumina Infinium Human DNA Methylation ",pl.sn," platform\n",sep="")
	}
	
	part.4.1<-paste("\nProtocol Name\tjhu-usc.edu:labeling:",pl.name,":01\tjhu-usc.edu:hybridization:",pl.name,":01\tjhu-usc.edu:image_acquisition:",pl.name,":01\tjhu-usc.edu:feature_extraction:",pl.name,":01\tjhu-usc.edu:within_bioassay_data_set_function:",pl.name,":01",
			"\nProtocol Type\tlabeling\thybridization\tscan\tfeature_extraction\tnormalization",
			"\nProtocol Term Source REF\tMGED Ontology\tMGED Ontology\tMGED Ontology\tMGED Ontology\tMGED Ontology",
			"\nProtocol Description\tIllumina Infinium Human DNA Methylation ",pl.sn," Labeled Extract\tIllumina Infinium Human DNA Methylation ",pl.sn," Hybridization Protocol\tIllumina Infinium Human DNA Methylation ",pl.sn," Scan Protocol\tIllumina Infinium Human DNA Methylation ",pl.sn," Feature Extraction Protocol\tIllumina Infinium Human DNA Methylation ",pl.sn," Data Transformation",
			"\nProtocol Parameters\t\n",		
			 sep="")
	sdrf_fn<-paste(fn,".sdrf.txt",sep="")
	part.5<-paste("SDRF Files",sdrf_fn,sep="\t")
	part.6<-paste("Term Source Name\tMGED Ontology\tcaArray\tBCR",
			"Term Source File\thttp://mged.sourceforge.net/ontologies/MGEDontology.php\thttp://caarraydb.nci.nih.gov/\thttp://www.tgen.org",		
			"Term Source Version\t1.3.0.1\t2007-01\t2007-01	",
			sep="\n")
	dat<-paste(part.1,part.1.1,part.2,part.3,part.4,part.4.1,part.5,part.6,sep="\n")
	write(dat,file=fp)
}

create_IDF_file.1<-function(fn,manifest_dir,cancer_type=NULL){
	idf_fn <- paste(fn,".idf.txt",sep="")
	fp<-file.path(manifest_dir,idf_fn)
	part.1<-paste("Investigation Title\tTCGA Analysis of DNA Methylation for ",cancer_type,"  Using Illumina Infinium Human DNA Methylation 27 platform (HumanMethylation27)\n",sep="")				

part.1.1<-"Experimental Design\tdisease_state_design				
Experimental Design Term Source REF\tMGED Ontology				
Experimental Factor Type\tdisease	 			
Experimental Factor Type Term Source REF\tMGED Ontology				
					
Person Last Name\tLaird				
Person First Name\tPeter				
Person Mid Initials\tW				
Person Email\tplaird@usc.edu				
Person Phone\t323.442.7890				
Person Address\tUSC Epigenome Center, University of Southern California, CA 90033, USA				
Person Affiliation\tUniversity of Southern California				
Person Roles\tsubmitter				
					
Quality Control Types\treal_time_PCR_quality_control				
Quality Control Types Term Source REF\tMGED Ontology				
Replicate Type\tbioassay_replicate_reduction				
Replicate Type Term Source REF\tMGED Ontology"
	part.2<-paste("Date of Experiment",date(),sep="\t")
	part.3<-paste("Public Release Date",date(),sep="\t")
	part.4<-"Experiment Description\tTCGA Analysis of DNA Methylation Using Illumina Infinium Human DNA Methylation 27 platform"				
	if(!is.null(cancer_type)){
		part.4<-paste("Experiment Description\tTCGA Analysis of DNA Methylation for ",cancer_type," Using Illumina Infinium Human DNA Methylation 27 platform\n",sep="")
	}
	part.4.1<-"\n					
Protocol Name\tjhu-usc.edu:labeling:HumanMethylation27:01\tjhu-usc.edu:hybridization:HumanMethylation27:01\tjhu-usc.edu:image_acquisition:HumanMethylation27:01\tjhu-usc.edu:feature_extraction:HumanMethylation27:01\tjhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01
Protocol Type\tlabeling\thybridization\tscan\tfeature_extraction\tnormalization
Protocol Term Source REF\tMGED Ontology\tMGED Ontology\tMGED Ontology\tMGED Ontology\tMGED Ontology
Protocol Description\tIllumina Infinium Human DNA Methylation 27 Labeled Extract\tIllumina Infinium Human DNA Methylation 27 Hybridization Protocol\tIllumina Infinium Human DNA Methylation 27 Scan Protocol\tIllumina Infinium Human DNA Methylation 27 Feature Extraction Protocol\tIllumina Infinium Human DNA Methylation 27 Data Transformation
Protocol Parameters\t\t		
"
	sdrf_fn<-paste(fn,".sdrf.txt",sep="")
	part.5<-paste("SDRF Files",sdrf_fn,sep="\t")
	part.6<-"Term Source Name\tMGED Ontology\tcaArray\tBCR		
Term Source File\thttp://mged.sourceforge.net/ontologies/MGEDontology.php\thttp://caarraydb.nci.nih.gov/\thttp://www.tgen.org		
Term Source Version\t1.3.0.1\t2007-01\t2007-01	"
	dat<-paste(part.1,part.1.1,part.2,part.3,part.4,part.4.1,part.5,part.6,sep="\n")
	write(dat,file=fp)
}
create_ADF_file_run<-function(){
	library(tcltk)
	fn<-"jhu-usc.edu_LUAD.HumanMethylation27.1.adf.txt"
	mdir<-"C:\\tcga\\LUAD\\jhu-usc.edu_LUAD.HumanMethylation27.mage-tab.1.3.0"
	
	fn<-"jhu-usc.edu_LUSC.HumanMethylation27.2.adf.txt"
	mdir<-"C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.5.0"
	create_ADF_file(fn,mdir)
	pkgFolder<-tclvalue(tclfile.dir(mdir))
	lvl_fd<-tclvalue(tclfile.tail(mdir))
	createManifestByLevel.2(pkgFolder,lvl_fd)
	compressDataPackage(pkgFolder,lvl_fd)
	
	fdir<-"C:\\feipan\\manifests\\humanMeth450k\\"
	fn<-"HumanMeth450.adf.1.0.txt"
	HumanMethylation450.adf<-read.delim(file=file.path(fdir,fn),sep="\t")
	save(HumanMethylation450.adf,file=file.path(fdir,"HumanMethylation450.adf.rdata"))
}
create_ADF_file<-function(fn,manifest_dir,platform="meth27k"){
	dat<-NULL
	if(platform=="meth27k"){
		data(HumanMethylation27.adf)
		dat<-HumanMethylation27.adf
	}else if(platform=="meth450k"){
		data(HumanMethylation450.adf)
		dat<-HumanMethylation450.adf
	}else{
		stop("Unknown platform\n")
	}
	write.table(dat,file=file.path(manifest_dir,fn),sep="\t",row.names=F,quote=F)
}
create_ADF_file.1<-function(fn,manifest_dir){
	data(HumanMethylation27.adf)
	dat<-HumanMethylation27.adf
	write.table(dat,file=file.path(manifest_dir,fn),sep="\t",row.names=F,quote=F)
}
create_Level_Description_File_test<-function(){
	data_dir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\TCGA Batch 49 Data Package (jhu-usc.edu_UCEC.HumanMethylation27.1.0.0)"
	create_Level_Description_File(data_dir,"c:\\temp","","test","")
}
create_Level_Description_File<-function(data_dir,pkg_folder,fn1,fn2,fn3){
	nn<-"DESCRIPTION.txt"
	fp<-file.path(data_dir,nn)
	if(!file.exists(fp)){
		cat("Description file is not available...\n")
		return()
	}
	dat<-readLines(fp)
	dat.0<-""
	ind1<-grep("LEVEL 1",dat,ignore.case=T)
	dat.1<-""
	if(length(ind1)>0){
		ind1<-ind1[length(ind1)]
		dat.1<-dat[ind1]
		ind0<-1:(ind1-1)
		dat.0<-dat[ind0]
	}
	dat.2<-""
	ind2<-grep("LEVEL 2",dat,ignore.case=T)
	if(length(ind2)>0)dat.2<-dat[ind2]
	dat.3<-""
	ind3<-grep("LEVEL 3",dat,ignore.case=T)
	if(length(ind3)>0){
		ind3<-ind3[length(ind3)]
		#dat.3<-dat[ind3[length(ind3)]]
		dat.3<-dat[ind3]
	}
	dat.dat<-date()
	if(ind3<length(dat))dat.date<-dat[(ind3+1):length(dat)]
	lvl.1<-c(dat.0,dat.1,dat.date)#,collapse="\n")
	lvl.2<-c(dat.0,dat.2,dat.date)#,collapse="\n")
	lvl.3<-c(dat.0,dat.3,dat.date)#,collapse="\n")
	write(lvl.1,file=file.path(pkg_folder,fn1,nn))
	write(lvl.2,file=file.path(pkg_folder,fn2,nn))
	write(lvl.3,file=file.path(pkg_folder,fn3,nn))
}
#create_Level_Description_File<-function(data_dir,pkg_folder,fn1,fn2,fn3){
#	nn<-"DESCRIPTION.txt"
#	fp<-file.path(data_dir,nn)
#	if(!file.exists(fp)){
#		cat("Description file is not available...\n")
#		return()
#	}
#	dat<-readLines(fp)
#	ind1<-grep("LEVEL 1",dat,ignore.case=T)
#	dat.1<-dat[ind1]
#	dat.2<-dat[grep("LEVEL 2",dat,ignore.case=T)]
#	ind3<-grep("LEVEL 3",dat,ignore.case=T)
#	ind3<-ind3[length(ind3)]
#	#dat.3<-dat[ind3[length(ind3)]]
#	dat.3<-dat[ind3]
#	ind0<-1:(ind1-1)
#	dat.0<-dat[ind0]
#	dat.date<-dat[(ind3+1):length(dat)]
#	lvl.1<-c(dat.0,dat.1,dat.date)#,collapse="\n")
#	lvl.2<-c(dat.0,dat.2,dat.date)#,collapse="\n")
#	lvl.3<-c(dat.0,dat.3,dat.date)#,collapse="\n")
#	write(lvl.1,file=file.path(pkg_folder,fn1,nn))
#	write(lvl.2,file=file.path(pkg_folder,fn2,nn))
#	write(lvl.3,file=file.path(pkg_folder,fn3,nn))
#}

runQCvalidation<-function(data.dir,mDataFileName=NULL,
		neg_ctr_red=NULL,neg_ctr_grn=NULL,bvFn=NULL,ctrRedFn=NULL,ctrGrnFn=NULL){
	setwd(data.dir)
	dat<-NULL
	if(is.null(mDataFileName=NULL)){
		setwd(data.dir)
		flist<-list.files(pattern=".rdata")
		if(length(flist)!=0) dat<-print(load(file=flist[1]))
		dat<-get(dat)
	}else{
		dat<-print(load(file=mDataFileName))
		dat<-get(dat)
	}
	
	bv<-NULL
	if(is.null(bvFn)){
		bv<-getBeta(dat)
	}else{
		bv<-readDataFile.2(bvFn)
	}
	readNegCtrFn<-function(fn){
		dat<-readDataFile.2(fn,isNum=F,rowName=NULL)
		ind<-grep("NEG",dat[,1],ignore.case=T)
		dat<-dat[ind,-1]
		return(dat)
	}
	neg_ctr_red<-NULL
	if(is.null(ctrRedFn)){
		neg_ctr_red<-getNegCtrRed(dat)
	}else{
		neg_ctr_red<-readNegCtrFn(ctrRedFn)
	}
	neg_ctr_grn<-NULL
	if(is.null(ctrGrnFn)){
		neg_ctr_grn<-getNegCtrGrn(dat)
	}else{
		neg_ctr_grn<-readNegCtrFn(ctrGrnFn)
	}
	naRatio<-colSums(apply(bv,2,is.na))/nrow(bv)
	if(any(naRatio>0.1)){
		warning("There is a sample with more than 10% of NAs among the beta values.\n")
	}
	X11()
	barplot(naRatio,main="Percentage of NAs among samples")
	png(filenames="naRatio.png")
	barplot(naRatio,main="Percentage of NAs among samples")
	dev.off()
	
	X11()
	par(mfrow=c(2,1))
	boxplot(neg_ctr_red)
	boxplot(neg_ctr_grn)
	png(filenames="Ctr_plot.png",height=480,width=480)
	par(mfrow=c(2,1))
	boxplot(neg_ctr_red,col="red",main="")
	boxplot(neg_ctr_grn,col="green",main="")
	dev.off()
}

sampleID<-function(indir,sig_A_fileName,header1=TRUE,delim = ","){
	setwd(indir);
	header1=header1;
	
	A<-read.table(sig_A,sep=delim,header=header1,row.names=1)
	A = A[order(row.names(A)),]; #sort rows
	A = A[,order(names(A))]; #sort cols
	ProbeSize = dim(A)[1];
	print( ProbeSize);
	SampleSize = dim(A)[2];
	print( SampleSize);
	sid = names(A);
	sid = gsub("(\\.)", "-", sid)
}

create_Mage_TAB_SDRF.2_test<-function(){
	lvlDir<-"C:\\temp\\tcgaPkg\\repos\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0\\jhu-usc.edu_STAD.HumanMethylation27.1\\jhu-usc.edu_STAD.HumanMethylation27.Level_1.1.0.0"
	sampleID<-getSampleID(lvlDir)
	pref4<-"jhu-usc.edu_STAD.HumanMethylation27.1"
	pref5<-"jhu-usc.edu_STAD.HumanMethylation27"
	manifest_dir<-"C:\\temp\\tcgaPkg\\repos\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0\\bk"
	mage_tab_fn<-file.path(manifest_dir,"jhu-usc.edu_STAD.HumanMethylation27.1.sdrf.txt")
	arch_numb<-"1.0.0"
	adf_fn<-"jhu-usc.edu_STAD.HumanMethylation27.1.adf.txt"
	create_Mage_TAB_SDRF.2(pref4,pref5,sampleID,manifest_dir,mage_tab_fn,arch_numb,adf_fn)
}
create_Mage_TAB_SDRF.2<-function(pref4,pref5,sampleID,manifest_dir,mage_tab_fn,arch_numb,adf_fn,toAppend=F){  
	#file.append
	setwd(manifest_dir)
	if(toAppend==FALSE){
		hd1<-"Extract Name\tProtocol REF\tLabeled Extract Name\tLabel\tTerm Source REF\tProtocol REF\tHybridization Name\tArray Design File\tTerm Source REF\tProtocol REF\tScan Name\tProtocol REF\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]"
		write(hd1,mage_tab_fn,sep="",append=F)
	}
	for(i in 1:length(sampleID)){
		sidc = i;
		tcga_id = sampleID[i];	
		lvl1_fn = paste(pref4,".lvl-1.",tcga_id,".txt",sep="");
		lvl2_fn = paste(pref4,".lvl-2.",tcga_id,".txt",sep="");
		lvl3_fn = paste(pref4,".lvl-3.",tcga_id,".txt",sep="");
		lvl1_arch_fn = paste(pref5,".Level_1.",arch_numb,sep="")
		lvl2_arch_fn = paste(pref5,".Level_2.",arch_numb,sep="")
		lvl3_arch_fn = paste(pref5,".Level_3.",arch_numb,sep="")
		hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation27:01",tcga_id,"biotin",
				"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation27:01",
				tcga_id,adf_fn,"caArray",
				"jhu-usc.edu:image_acquisition:HumanMethylation27:01",tcga_id,
				"jhu-usc.edu:feature_extraction:HumanMethylation27:01",
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
				tcga_id,lvl1_fn,"Level 1","DNA-Methylation","yes",lvl1_arch_fn,
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
				tcga_id,lvl2_fn,"Level 2","DNA-Methylation","yes",lvl2_arch_fn,
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",tcga_id,
				lvl3_fn,"Level 3","DNA-Methylation","yes",lvl3_arch_fn,sep="\t"
		);
		write(hd2,mage_tab_fn,sep="",append=TRUE);
	}
}
create_Mage_TAB_SDRF.1_test<-function(){
	pref<-"jhu-usc.edu_COAD.HumanMethylation450.1"
	pkgPath<-"C:\\temp\\IDAT\\meth450k\\tcga\\COAD"
	sampleID<-getSampleID(file.path(pkgPath,"jhu-usc.edu_COAD.HumanMethylation450.Level_1.1.0.0"))
	mPath<-file.path(pkgPath,"jhu-usc.edu_COAD.HumanMethylation450.mage-tab.1.0.0")
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth450"
	create_Mage_TAB_SDRF.1(pref,sampleID,mPath,arrayPath=arrayPath,platform="meth450k")
}
create_Mage_TAB_SDRF.1<-function(pref4,sampleID,manifest_dir,arch_numb_lvl1="1.0.0",arch_numb_lvl2="1.0.0",arch_numb_lvl3="1.0.0",arrayPath=NULL,platform="meth27k"){  
	sdrf_tab_fn<-file.path(manifest_dir,paste(pref4,".sdrf.txt",sep=""))
	pl.name<-"HumanMethylation27";if(platform=="meth450k")pl.name<-"HumanMethylation450"
	hd1<-"Extract Name\tProtocol REF\tLabeled Extract Name\tLabel\tTerm Source REF\tProtocol REF\tHybridization Name\tArray Design File\tTerm Source REF\tProtocol REF\tScan Name\tProtocol REF\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]"
	plate_id<-NULL;barcode<-NULL;wellposition<-NULL
	if(platform=="meth450k"){
		hd1<-"Extract Name\tProtocol REF\tLabeled Extract Name\tLabel\tTerm Source REF\tProtocol REF\tHybridization Name\tArray Design File\tTerm Source REF\tProtocol REF\tScan Name\tProtocol REF\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tComment [Plate ID]\tComment [Barcode]\tComment [Well Position]"
		if(is.null(arrayPath))arrayPath<-"/auto/uec-02/shared/production/methylation/meth450k/arraymapping"
		samp.map<-readSampleMapping(arrayPath)
		ind<-is.element(samp.map$sampleID,sampleID)
		if(sum(ind)!=length(sampleID))stop("samples are missing from mappings\n")
		samp<-samp.map[ind,"sampleID"]
		plate_id<-samp.map[ind,"plateLIMSID"];names(plate_id)<-samp
		barcode<-samp.map[ind,"barcode2"];names(barcode)<-samp
		wellposition<-samp.map[ind,"plateposition"];names(wellposition)<-samp
	}
	write(hd1,sdrf_tab_fn,sep="",append=F)
	
	adf_fn = paste(pref4,".adf.txt",sep="");
	pref5<-paste(strsplit(pref4,pl.name)[[1]][1],pl.name,sep="")
	for(i in 1:length(sampleID)){
		sidc = i;
		tcga_id = sampleID[i];	
		lvl1_fn = paste(pref4,".lvl-1.",tcga_id,".txt",sep="");
		lvl2_fn = paste(pref4,".lvl-2.",tcga_id,".txt",sep="");
		lvl1_arch_fn = paste(pref5,".Level_1",arch_numb_lvl1,sep="")
		lvl2_arch_fn = paste(pref5,".Level_2",arch_numb_lvl2,sep="")
		lvl3_fn = paste(pref4,".lvl-3.",tcga_id,".txt",sep="");
		lvl3_arch_fn = paste(pref5,".Level_3",arch_numb_lvl3,sep="")
		hd2<-NULL
		if(platform=="meth450k")hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation450:01",tcga_id,"biotin",
				"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation450:01",
				tcga_id,adf_fn,"caArray",
				"jhu-usc.edu:image_acquisition:HumanMethylation450:01",tcga_id,
				"jhu-usc.edu:feature_extraction:HumanMethylation450:01",
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation450:01",
				tcga_id,lvl1_fn,"Level 1","DNA-Methylation","yes",lvl1_arch_fn,
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation450:01",
				tcga_id,lvl2_fn,"Level 2","DNA-Methylation","yes",lvl2_arch_fn,
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation450:01",tcga_id,
				lvl3_fn,"Level 3","DNA-Methylation","yes",lvl3_arch_fn,plate_id[tcga_id],barcode[tcga_id],wellposition[tcga_id],sep="\t")
		if(platform=="meth27k"){
			hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation27:01",tcga_id,"biotin",
					"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation27:01",
					tcga_id,adf_fn,"caArray",
					"jhu-usc.edu:image_acquisition:HumanMethylation27:01",tcga_id,
					"jhu-usc.edu:feature_extraction:HumanMethylation27:01",
					"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
					tcga_id,lvl1_fn,"Level 1","DNA-Methylation","yes",lvl1_arch_fn,
					"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
					tcga_id,lvl2_fn,"Level 2","DNA-Methylation","yes",lvl2_arch_fn,
					"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",tcga_id,
					lvl3_fn,"Level 3","DNA-Methylation","yes",lvl3_arch_fn,sep="\t")
		}
		
		write(hd2,sdrf_tab_fn,sep="",append=TRUE);
	}
}

#create_Mage_TAB_SDRF.1<-function(pref4,sampleID,manifest_dir,arch_numb_lvl1,arch_numb_lvl2,arch_numb_lvl3,platform="meth27k"){  
#	sdrf_tab_fn<-file.path(manifest_dir,paste(pref4,".sdrf.txt",sep=""))
#	pl.name<-"HumanMethylation27";if(platform=="meth450k")pl.name<-"HumanMethylation450"
#	hd1<-"Extract Name\tProtocol REF\tLabeled Extract Name\tLabel\tTerm Source REF\tProtocol REF\tHybridization Name\tArray Design File\tTerm Source REF\tProtocol REF\tScan Name\tProtocol REF\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]"
#	#if(platform=="meth450k")hd1<-"Extract Name\tProtocol REF\tLabeled Extract Name\tLabel\tTerm Source REF\tProtocol REF\tHybridization Name\tArray Design File\tTerm Source REF\tProtocol REF\tScan Name\tProtocol REF\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]"
#	write(hd1,sdrf_tab_fn,sep="",append=F)
#	
#	adf_fn = paste(pref4,".adf.txt",sep="");
#	pref5<-paste(strsplit(pref4,pl.name)[[1]][1],pl.name,sep="")
#	for(i in 1:length(sampleID)){
#		sidc = i;
#		tcga_id = sampleID[i];	
#		lvl1_fn = paste(pref4,".lvl-1.",tcga_id,".txt",sep="");
#		lvl2_fn = paste(pref4,".lvl-2.",tcga_id,".txt",sep="");
#		lvl1_arch_fn = paste(pref5,".Level_1",arch_numb_lvl1,sep="")
#		lvl2_arch_fn = paste(pref5,".Level_2",arch_numb_lvl2,sep="")
#		lvl3_fn = paste(pref4,".lvl-3.",tcga_id,".txt",sep="");
#		lvl3_arch_fn = paste(pref5,".Level_3",arch_numb_lvl3,sep="")
#		hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation450:01",tcga_id,"biotin",
#				"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation450:01",
#				tcga_id,adf_fn,"caArray",
#				"jhu-usc.edu:image_acquisition:HumanMethylation450:01",tcga_id,
#				"jhu-usc.edu:feature_extraction:HumanMethylation450:01",
#				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation450:01",
#				tcga_id,lvl1_fn,"Level 1","DNA-Methylation","yes",lvl1_arch_fn,
#				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation450:01",
#				tcga_id,lvl2_fn,"Level 2","DNA-Methylation","yes",lvl2_arch_fn,
#				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation450:01",tcga_id,
#				lvl3_fn,"Level 3","DNA-Methylation","yes",lvl3_arch_fn,sep="\t")
#		if(platform=="meth27k"){
#			hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation27:01",tcga_id,"biotin",
#					"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation27:01",
#					tcga_id,adf_fn,"caArray",
#					"jhu-usc.edu:image_acquisition:HumanMethylation27:01",tcga_id,
#					"jhu-usc.edu:feature_extraction:HumanMethylation27:01",
#					"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
#					tcga_id,lvl1_fn,"Level 1","DNA-Methylation","yes",lvl1_arch_fn,
#					"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
#					tcga_id,lvl2_fn,"Level 2","DNA-Methylation","yes",lvl2_arch_fn,
#					"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",tcga_id,
#					lvl3_fn,"Level 3","DNA-Methylation","yes",lvl3_arch_fn,sep="\t")
#		}
#		
#		write(hd2,sdrf_tab_fn,sep="",append=TRUE);
#	}
#}

create_Mage_TAB_SDRF<-function(pref4,pref5,sampleID,manifest_dir,mage_tab_fn,arch_numb,adf_fn,toAppend=F){  
	#file.append
	setwd(manifest_dir)
	if(toAppend==FALSE){
		hd1<-"Extract Name\tProtocol REF\tLabeled Extract Name\tLabel\tTerm Source REF\tProtocol REF\tHybridization Name\tArray Design File\tTerm Source REF\tProtocol REF\tScan Name\tProtocol REF\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]\tProtocol REF\tNormalization Name\tDerived Array Data Matrix File\tComment [TCGA Data Level]\tComment [TCGA Data Type]\tComment [TCGA Include for Analysis]\tComment [TCGA Archive Name]"
		write(hd1,mage_tab_fn,sep="",append=F)
	}
	adf_fn<-adf_fn
	#adf_fn = paste(pref4,".adf.txt",sep="");
	for(i in 1:length(sampleID)){
		sidc = i;
		tcga_id = sampleID[i];	
		lvl1_fn = paste(pref4,".lvl-1.",tcga_id,".txt",sep="");
		lvl2_fn = paste(pref4,".lvl-2.",tcga_id,".txt",sep="");
		lvl3_fn = paste(pref4,".lvl-3.",tcga_id,".txt",sep="");
		lvl1_arch_fn = paste(pref5,".Level_1.",arch_numb,sep="")
		lvl2_arch_fn = paste(pref5,".Level_2.",arch_numb,sep="")
		lvl3_arch_fn = paste(pref5,".Level_3.",arch_numb,sep="")
		hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation27:01",tcga_id,"biotin",
				"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation27:01",
				tcga_id,adf_fn,"caArray",
				"jhu-usc.edu:image_acquisition:HumanMethylation27:01",tcga_id,
				"jhu-usc.edu:feature_extraction:HumanMethylation27:01",
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
				tcga_id,lvl1_fn,"Level 1","DNA-Methylation","yes",lvl1_arch_fn,
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
				tcga_id,lvl2_fn,"Level 2","DNA-Methylation","yes",lvl2_arch_fn,
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",tcga_id,
				lvl3_fn,"Level 3","DNA-Methylation","yes",lvl3_arch_fn,sep="\t"
		);
		write(hd2,mage_tab_fn,sep="",append=TRUE);
	}
}
createDataPackgeNewScheme<-function(txt){
	createDataPackage(txt,old_scheme=FALSE,new_scheme=TRUE,packaging=TRUE)
	
}
###############
# note: id of ctr data start with "NEG"
###################
packInfinium.2_test<-function(){
	datDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\TCGA Batch 49 Data Package (jhu-usc.edu_UCEC.HumanMethylation27.1.0.0)"
	sig_A<-file.path(datDir,"TCGA Batch 49 unmethylated signal intensity.txt")
	sig_A_se<-file.path(datDir,"TCGA Batch 49 unmethylated bead stderr.txt")
	sig_A_n<-file.path(datDir,"TCGA Batch 49 average number of unmethylated beads.txt")
	sig_B<-file.path(datDir,"TCGA batch 49 methylated signal intensity.txt")
	sig_B_se<-file.path(datDir,"TCGA Batch 49 methylated bead stderr.txt")
	sig_B_n<-file.path(datDir,"TCGA Batch 49 average number of methylated beads.txt")
	pvalue_fn<-file.path(datDir,"TCGA Batch 49 Detection P-value.txt")
	beta_fn<-file.path(datDir,"TCGA Batch 49 beta values (level 2).txt")
	ctr_R_fn<-file.path(datDir,"TCGA Batch 49 negative control probe signal_red.txt")
	ctr_G_fn<-file.path(datDir,"TCGA Batch 49 negative control probe signal_green.txt")
	outdir<-"c:\\temp\\GBM"
	tcgaPackage_name<-"jhu-usc.edu_GBM.HumanMethylation27.2.0.0"
	txt=NULL
	readme_fn<-file.path(datDir,"readme.txt")
	packInfinium.2(sig_A,sig_A_se,sig_A_n,sig_B,sig_B_se,sig_B_n,pvalue_fn,beta_fn,ctr_R_fn,ctr_G_fn,outdir,tcgaPackage_name,txt,readme_fn)	
}
packInfinium.2 <-function(sig_A,sig_A_se,sig_A_n,sig_B,sig_B_se,sig_B_n,pvalue_fn,beta_fn,
		ctr_R_fn,ctr_G_fn,outdir,tcgaPackage_name,txt=NULL,readme_fn=NULL,toSave=T){
	# create prefs using tcgaPackage_name
	t1=unlist(strsplit(tcgaPackage_name,"\\."))
	pref5 <- paste(t1[1],".",t1[2],".",t1[3],sep="")
	pref4 <- paste(pref5,".",t1[4],sep="")
	pref <- paste(pref4,".lvl-1.",sep="")
	pref2<-paste(pref4,".lvl-2.",sep="")
	pref3<-paste(pref4,".lvl-3.",sep="")
	arch_numb = paste(t1[4],".",t1[5],".",t1[6],sep="")
	
	#outdir<-file.path(outdir,tcgaPackage_name)
	if(!file.exists(outdir))dir.create(outdir)
	setwd(outdir)
	header1=TRUE;
	rv<-processLevel1Data(sig_A,sig_A_n,sig_A_se,sig_B,sig_B_n,sig_B_se,ctr_R_fn,ctr_G_fn,pvalue_fn,pref,toSave)
	sid<-rv$sid
	pid<-rv$pid
	A<-rv$A
	B<-rv$B
	Bv<-processLevel2Data(beta_fn,A,B,sid,pid,pref2)
	processLevel3Data(Bv,sid,pid,pref3)
	create_Manifest(outdir)
	#create_SDRF(pref4,sid,outdir)
	if(!is.null(readme_fn)){
		file.copy(readme_fn,file.path(outdir,"DESCRIPTION.TXT"))
	}
	if(!is.null(txt)){
		msg<-paste("> Done with the level data processing ",date(),"\n",sep="")
		tkinsert(txt,"end",msg)
	}
	return(sid)
}
processLevel3Data<-function(Bv,sid,pid,pref3){
	data(lvl3mask)
	lvl3mask = lvl3mask[order(row.names(lvl3mask)),]; #sort rows
	pid1 = row.names(lvl3mask);
	data(HumanMethylation27.adf)
	row.names(HumanMethylation27.adf)<-HumanMethylation27.adf[,1]
	HumanMethylation27.adf<-HumanMethylation27.adf[pid1,]
	if(sum(pid!=pid1)>0 ) stop(paste("row or col names of A do not match lvl3mask, pls check ",sig_A,"\n"));  
	
	lvl3mks<-as.data.frame(matrix(lvl3mask[,1],nrow=nrow(Bv),ncol=ncol(Bv),byrow=F))
	Bv3<-ifelse(lvl3mks==0,1,NA)*Bv
	for(i in 1:length(sid)){
		tcga_id = sid[i];
		fn = paste(pref3,tcga_id,".txt",sep="");
		hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
		hd2= paste("Composite Element REF", "Beta_Value", "Gene_Symbol", "Chromosome", "Genomic_Coordinate",sep="\t");
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		dat<-data.frame(pid,Bv3[,i],HumanMethylation27.adf[,"SYMBOL"],HumanMethylation27.adf[,"Chr"],HumanMethylation27.adf[,"MapInfo"]) #lvl3mask[,2],lvl3mask[,3],lvl3mask[,4])
		write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
	}
}
#processLevel3Data<-function(Bv,sid,pid,pref3){
#	data(lvl3mask)
#	lvl3mask = lvl3mask[order(row.names(lvl3mask)),]; #sort rows
#	pid1 = row.names(lvl3mask);
#	if(sum(pid!=pid1)>0 ) stop(paste("row or col names of A do not match lvl3mask, pls check ",sig_A,"\n"));  
#	
#	lvl3mks<-as.data.frame(matrix(lvl3mask[,1],nrow=nrow(Bv),ncol=ncol(Bv),byrow=F))
#	Bv3<-ifelse(lvl3mks==0,1,NA)*Bv
#	for(i in 1:length(sid)){
#		tcga_id = sid[i];
#		fn = paste(pref3,tcga_id,".txt",sep="");
#		hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
#		hd2= paste("Composite Element REF", "Beta_Value", "Gene_Symbol", "Chromosome", "Genomic_Coordinate",sep="\t");
#		write(hd1,fn,sep="");
#		write(hd2,fn,sep="",append=TRUE);
#		dat<-data.frame(pid,Bv3[,i],lvl3mask[,2],lvl3mask[,3],lvl3mask[,4])
#		write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
#	}
#}
processLevel2Data<-function(beta_fn,A,B,sid,pid,pref2){
	header1<-TRUE
	ProbeSize<-length(pid)
	SampleSize<-length(sid)
	Bv<-readDataFile.2(beta_fn,header1=header1)
	if(  ProbeSize !=   dim(Bv)[1] || SampleSize != dim(Bv)[2])
	{
		stop (paste("dimension of Bv does not match with that of A, pls check",beta_fn,"\n"));
	}
	Bv = Bv[order(row.names(Bv)),];
	Bv = Bv[,order(names(Bv))];
	sid1 = names(Bv);
	pid1 = row.names(Bv);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Bv ",beta_fn,"\n"));  
	
	
	for(i in 1:length(sid)){
		tcga_id = sid[i];
		fn = paste(pref2,tcga_id,".txt",sep="");
		hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,sep="\t");
		hd2= paste("Composite Element REF", "Beta_Value", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)",sep="\t");
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		dat<-data.frame(pid,Bv[,i],B[,i],A[,i])
		write.table(dat,fn,sep="\t",col.names=F,row.names=F,quote=F,append=T)
	}  
#	if(!is.null(txt)){
#		msg<-paste("> Finished processing the level-2 data Files...",date(),"\n",sep="")
#		tkinsert(txt,"end",msg)
#		tkinsert(txt,"end","> Working on the level-3 data Files.\n")
#	}
	return(Bv)
}
getnegCtrData_test<-function(){
	load(file="C:\\temp\\IDAT\\meth450k\\processed\\6042308166\\6042308166_idat.rda")
	load(file="C:\\temp\\IDAT\\meth450k\\processed\\6042308117\\6042308117_idat.rda")
	ndat<-getNegCtrData(idat,"meth450k")
	dim(ndat$R) #614  12
	ndat.m<-mean(ndat$R[,"6042308117_R01C01"]) #121.4853
	ndat2<-getNegCtrData.1.1(idat,"meth450k")
	ndat2.m<-mean(ndat2$R[,"6042308117_R01C01"]) #121.4853
	ndat1<-getNegCtrData.1(idat,"meth450k")
	ndat1.m<-mean(ndat1$R[,"6042308117_R01C01"]) #121.4853
	
	ndat.stderr<-sd(ndat$R[,"6042308117_R01C01"])/sqrt(614) #1.160359
#	6042308117	R01C01	TCGA-B0-5402-01A-01D-1500-05a	82	Kidney renal clear cell carcinoma	KIRC	1018
	
	dat<-read.csv(file="C:\\temp\\IDAT\\meth450k\\processed\\6042308117\\Control_Signal_Intensity_Red.csv")
	dat.m<-mean(dat[,"X6042308117_R01C01"]) #121.485
	
	idat@assayData$methylated[1,"6042308117_R01C01"] #1427
	idat@assayData$methylated.N[1,"6042308117_R01C01"] #18
	idat@assayData$methylated.SD[1,"6042308117_R01C01"]/sqrt(18) #83.6743
	
	idat@assayData$unmethylated[1,"6042308117_R01C01"] #873
	idat@assayData$unmethylated.N[1,"6042308117_R01C01"] #18
	idat@assayData$unmethylated.SD[1,"6042308117_R01C01"]/sqrt(18) #99.23065
	#meth27k
	load(file="C:\\temp\\test3\\meth27k\\processed\\5543207015\\5543207015_idat.rda")
	ndat<-getNegCtrData(idat,"meth27k")
}
getNegCtrData<-function(idat,platform="meth450k"){
	if(platform=="meth450k")data(NegCtlCode450)
	else if(platform=="meth27k")data(NegCtlCode)
	else stop("unkown platform\n")
	ctl_code<-ctl_code[,1]
	fdat<-featureData(idat@QC)@data$Address
	cdat.m<-idat@QC@assayData$methylated
	cdat.u<-idat@QC@assayData$unmethylated
	ind<-is.element(fdat,ctl_code)
	cdat.neg.address<-fdat[ind]
	cdat.neg.m<-cdat.m[ind,]
	cdat.neg.u<-cdat.u[ind,]
	cdat.neg.R<-cdat.neg.u
	cdat.neg.G<-cdat.neg.m
	return(list(R=cdat.neg.R,G=cdat.neg.G,Address=cdat.neg.address))
}
getNegCtrData.1.1<-function(idat,platform="meth450k"){
	if(platform=="meth450k")data(NegCtlCode450)
	else if(platform=="meth27k")data(NegCtlCode)
	else stop("unkown platform\n")
	ctl_code<-ctl_code[,1]
	fdat<-featureData(idat@QC)@data$Address
	cdat.m<-idat@QC@assayData$methylated
	cdat.u<-idat@QC@assayData$unmethylated
	ind<-is.element(fdat,ctl_code)
#	ctr_R<-negctls.stderr(idat,"Cy5")
#	ctr_G<-negctls.stderr(idat,"Cy3")
#	ctr_R<-negctls.SD(idat,"Cy5")
#	ctr_G<-negctls.SD(idat,"Cy3")
	ctr_R<-negctls(idat,"Cy5")
	ctr_G<-negctls(idat,"Cy3")
	cdat.neg.R<-ctr_R
	cdat.neg.G<-ctr_G
	return(list(R=cdat.neg.R,G=cdat.neg.G))
}

getNegCtrData.1<-function(idat,platform="meth450k"){
	if(platform=="meth450k")data(NegCtlCode450)
	else if(platform=="meth27k")data(NegCtlCode)
	else stop("unkown platform\n")
	ctl_code<-ctl_code[,1]
	fdat<-featureData(idat@QC)@data$Address
	cdat.m<-idat@QC@assayData$methylated
	cdat.u<-idat@QC@assayData$unmethylated
	ind<-is.element(fdat,ctl_code)
	cdat.neg.m<-cdat.m[ind,]
	cdat.neg.u<-cdat.u[ind,]
	cdat.neg.R<-cdat.neg.u
	cdat.neg.G<-cdat.neg.m
	return(list(R=cdat.neg.R,G=cdat.neg.G))
}
savePvalues<-function(mdat,outFn){
	pv<-NULL
	if(class(mdat)=="MethyLumiSet")pv<-mdat@assayData$pvals
	else if(class(mdat)=="methData")pv<-getPvalue(mdat)
	else cat("Unknown data class")
	write.csv(pv,file=outFn,quote=F)
}
getPvalues<-function(mdat){
	pv<-NULL
	if(class(mdat)=="MethyLumiSet")pv<-mdat@assayData$pvals
	else if(class(mdat)=="methData")pv<-getPvalue(mdat)
	else cat("Unknown data class")
	return(pv)
}
#######
# #i.e., Cy3/green is methylated, Cy5/red is unmethylated.  I haven't got around to normalizing out the dye bias for any of them yet.
######
processLevel1Data.2_test<-function(){
	#meth27k
	datFn<-"C:\\temp\\test\\meth27k\\tcga\\STAD\\jhu-usc.edu_STAD.HumanMethylation27.1.1.0\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0\\48.rdata"
	outPath<-"C:\\temp\\test\\meth27k\\tcga\\test"
	mdat<-get(load(file=datFn))
	pref<-"jhu-usc.edu_STAD.HumanMethylation27.1."
	processLevel1Data.2(mdat,pref,outPath,platform="meth27k")
	
	#meth450k
	datFn<-"C:\\temp\\IDAT\\meth450k\\processed\\6042308117\\6042308117_idat.rda"
	outPath<-"C:\\temp\\IDAT\\meth450k\\tcga\\test"
	mdat<-get(load(file=datFn))
	Ae<-mdat@assayData$unmethylated.SD/sqrt(mdat@assayData$unmethylated.N)
	Ae[1:7,"6042308117_R01C01"]
#	cg00000029 cg00000108 cg00000109 cg00000165 cg00000236 cg00000289 cg00000292 
#	99.23065  130.91830  122.46049  175.32337   13.22876   75.63493  200.44991

	Ae2<-unmethylated.SE(mdat)
	Ae2[1:7,"6042308117_R01C01"]
	
#	Ae3<-unmethylated.SD(mdat)/sqrt(unmethylated.N(mdat))
#	Ae3[1:7,"6042308117_R01C01"]
	
	Be<-mdat@assayData$methylated.SD/sqrt(mdat@assayData$methylated.N)
	Be[1:7,"6042308117_R01C01"]
#	cg00000029 cg00000108 cg00000109 cg00000165 cg00000236 cg00000289 cg00000292 
#	83.6743   190.6853   145.8943   107.7063   199.1873   111.7152   227.3943
	pref<-"jhu-usc.edu_COAD.HumanMethylation450.1.lvl-1."
	processLevel1Data.2(mdat,pref,outPath,platform="meth450k")
}
processLevel1Data.2<-function(mdat,pref,outPath,platform="meth450k"){
	A<-NULL;An<-NULL;B<-NULL;Bn<-NULL;Pv<-NULL;ctr_G_avg<-NULL;ctr_R_avg<-NULL;ctr_G_stderr<-NULL;ctr_R_stderr<-NULL
	if(class(mdat)=="MethyLumiSet"){
		A<-mdat@assayData$unmethylated
		An<-mdat@assayData$unmethylated.N
		B<-mdat@assayData$methylated
		Bn<-mdat@assayData$methylated.N
		Pv<-mdat@assayData$pvals
		Ae<-mdat@assayData$unmethylated.SD/sqrt(An)
		Be<-mdat@assayData$methylated.SD/sqrt(Bn)
		negCtr<-getNegCtrData(mdat,platform)	
		ctr_G<-negCtr$G
		ctr_R<-negCtr$R
	}else{
		A<-getU(mdat)
		An<-getUn(mdat)
		Ae<-getUe(mdat)
		B<-getM(mdat)
		Bn<-getMn(mdat)
		Be<-getMe(mdat)
		Pv<-getPvalue(mdat)
		negdat<-getNegData(mdat)
		ctr_G<-sapply(negdat,function(x)x$G)
		ctr_R<-sapply(negdat,function(x)x$R)
	}
	ctr_G_avg<-apply(ctr_G,2,mean,na.rm=T)
	ctr_R_avg<-apply(ctr_R,2,mean,na.rm=T)
	ctr_G_stderr<-apply(ctr_G,2,function(x)sd(x)/sqrt(length(x)))
	ctr_R_stderr<-apply(ctr_R,2,function(x)sd(x)/sqrt(length(x)))
	#check
	pid<-row.names(A)
	if(!all(pid==row.names(An) & pid==row.names(B) & pid==row.names(Bn) & pid==row.names(Pv)))stop("check the row names of the mdat of processing level-1 data... \n")
	sid<-getSampleID(mdat)
	cancerType<-strsplit(strsplit(pref,"edu_")[[1]][2],"\\.")[[1]][1]
	if(is.na(cancerType)) stop("cancer type is unknown, check process level-1 data...\n")
	setwd(outPath);len<-length(pid)
	for(i in 1:length(sid)){
		tcga_id = sid[i];
		fn = paste(pref,tcga_id,".txt",sep="");
		dat<-NULL;hd1<-NULL;hd2<-NULL
		if(platform=="meth450k"){
			hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
			hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
			dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
		}else {
			hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
			hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
			dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
			if(cancerType=="GBM"){
				hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
				hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR", "Detection_P_Value",sep="\t");
				dat<-data.frame(pid,B[,i],A[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
			}
		}
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
	}
}
#processLevel1Data.2<-function(mdat,pref,outPath,platform="meth450k"){
#	A<-NULL;An<-NULL;B<-NULL;Bn<-NULL;Pv<-NULL;ctr_G_avg<-NULL;ctr_R_avg<-NULL;ctr_G_stderr<-NULL;ctr_R_stderr<-NULL
#	if(class(mdat)=="MethyLumiSet"){
#		A<-mdat@assayData$methylated
#		An<-mdat@assayData$methylated.N
#		B<-mdat@assayData$unmethylated
#		Bn<-mdat@assayData$unmethylated.N
#		Pv<-mdat@assayData$pvals
#		Ae<-mdat@assayData$methylated.SD/sqrt(An)
#		Be<-mdat@assayData$unmethylated.SD/sqrt(Bn)
#		negCtr<-getNegCtrData(mdat,platform)	
#		ctr_G<-negCtr$G
#		ctr_R<-negCtr$R
#	}else{
#		A<-getM(mdat)
#		An<-getMn(mdat)
#		Ae<-getMe(mdat)
#		B<-getU(mdat)
#		Bn<-getUn(mdat)
#		Be<-getUe(mdat)
#		Pv<-getPvalue(mdat)
#		negdat<-getNegData(mdat)
#		ctr_G<-sapply(negdat,function(x)x$G)
#		ctr_R<-sapply(negdat,function(x)x$R)
#	}
#	ctr_G_avg<-apply(ctr_G,2,mean,na.rm=T)
#	ctr_R_avg<-apply(ctr_R,2,mean,na.rm=T)
#	ctr_G_stderr<-apply(ctr_G,2,function(x)sd(x)/sqrt(length(x)))
#	ctr_R_stderr<-apply(ctr_R,2,function(x)sd(x)/sqrt(length(x)))
#	#check
#	pid<-row.names(A)
#	if(!all(pid==row.names(An) & pid==row.names(B) & pid==row.names(Bn) & pid==row.names(Pv)))stop("check the row names of the mdat of processing level-1 data... \n")
#	sid<-getSampleID(mdat)
#	cancerType<-strsplit(strsplit(pref,"edu_")[[1]][2],"\\.")[[1]][1]
#	if(is.na(cancerType)) stop("cancer type is unknown, check process level-1 data...\n")
#	setwd(outPath);len<-length(pid)
#	for(i in 1:length(sid)){
#		tcga_id = sid[i];
#		fn = paste(pref,tcga_id,".txt",sep="");
#		dat<-NULL;hd1<-NULL;hd2<-NULL
#		if(platform=="meth450k"){
#			hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
#			hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
#			dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
#		}else {
#			hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
#			hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
#			dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
#			if(cancerType=="GBM"){
#				hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
#				hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR", "Detection_P_Value",sep="\t");
#				dat<-data.frame(pid,B[,i],A[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
#			}
#		}
#		write(hd1,fn,sep="");
#		write(hd2,fn,sep="",append=TRUE);
#		write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
#	}
#}
processLevel1Data.2.1<-function(mdat,pref,outPath,platform="meth450k"){
	A<-NULL;An<-NULL;B<-NULL;Bn<-NULL;Pv<-NULL;ctr_G_avg<-NULL;ctr_R_avg<-NULL;ctr_G_stderr<-NULL;ctr_R_stderr<-NULL
	if(class(mdat)=="MethyLumiSet"){
		A<-mdat@assayData$methylated
		An<-mdat@assayData$methylated.N
		B<-mdat@assayData$unmethylated
		Bn<-mdat@assayData$unmethylated.N
		Pv<-mdat@assayData$pvals
		Ae<-mdat@assayData$methylated.SD/sqrt(An)
		Be<-mdat@assayData$unmethylated.SD/sqrt(Bn)
#		Ae<-negctls.stderr(mdat,"Cy5")
#		Be<-negctls.stderr(mdat,"Cy3")
		negCtr<-getNegCtrData(mdat,platform)	
		ctr_G<-negCtr$G
		ctr_R<-negCtr$R
	}else{
		A<-getM(mdat)
		An<-getMn(mdat)
		Ae<-getMe(mdat)
		B<-getU(mdat)
		Bn<-getUn(mdat)
		Be<-getUe(mdat)
		Pv<-getPvalue(mdat)
		negdat<-getNegData(mdat)
		ctr_G<-sapply(negdat,function(x)x$G)
		ctr_R<-sapply(negdat,function(x)x$R)
	}
	ctr_G_avg<-apply(ctr_G,2,mean,na.rm=T)
	ctr_R_avg<-apply(ctr_R,2,mean,na.rm=T)
	ctr_G_stderr<-apply(ctr_G,2,function(x)sd(x)/sqrt(length(x)))
	ctr_R_stderr<-apply(ctr_R,2,function(x)sd(x)/sqrt(length(x)))
	#check
	pid<-row.names(A)
	if(!all(pid==row.names(An) & pid==row.names(B) & pid==row.names(Bn) & pid==row.names(Pv)))stop("check the row names of the mdat of processing level-1 data... \n")
	sid<-getSampleID(mdat)
	cancerType<-strsplit(strsplit(pref,"edu_")[[1]][2],"\\.")[[1]][1]
	if(is.na(cancerType)) stop("cancer type is unknown, check process level-1 data...\n")
	setwd(outPath);len<-length(pid)
	for(i in 1:length(sid)){
		tcga_id = sid[i];
		fn = paste(pref,tcga_id,".txt",sep="");
		dat<-NULL;hd1<-NULL;hd2<-NULL
		if(platform=="meth450k"){
			hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
			hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
			dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
		}else {
			hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
			hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
			dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
			if(cancerType=="GBM"){
				hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
				hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR", "Detection_P_Value",sep="\t");
				dat<-data.frame(pid,B[,i],A[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
			}
		}
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
	}
}

#processLevel1Data_test<-function(){
#	setwd("c:\\temp\\test1")
#	mData<-NULL
#	cData<-NULL
#	datDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\infinium 72_80_82 processed data\\infinium 080"
#	sig_A<-file.path(datDir,"infinium 080 SIGNAL_A.csv")
#	sig_A_n<-file.path(datDir,"infinium 080 AVG_NBEADS_A.csv")
#	sig_A_se<-file.path(datDir,"infinium 080 BEAD_STDERR_A.csv")
#	sig_B<-file.path(datDir,"infinium 080 SIGNAL_B.csv")
#	sig_B_n<-file.path(datDir,"infinium 080 AVG_NBEADS_B.csv")
#	sig_B_se<-file.path(datDir,"infinium 080 BEAD_STDERR_B.csv")
#	ctr_R_fn<-file.path(datDir,"infinium 080 CONTROL PROBE PROFILE SIGNAL_RED.csv")
#	ctr_G_fn<-file.path(datDir,"infinium 080 CONTROL PROBE PROFILE SIGNAL_GREEN.csv")
#	pvalue_fn<-file.path(datDir,"DetectionPValues.csv")
#	pref<-"jhu-usc.edu_LUSC.HumanMethylation27.1"
#	dat<-processLevel1Data(sig_A,sig_A_n,sig_A_se,sig_B,sig_B_n,sig_B_se,ctr_R_fn,ctr_G_fn,pvalue_fn,pref,TrimName=".")
#	
#	pvalue_fn<-file.path(datDir,"DetectionPValues_ztest.csv")
#	pref<-NULL
#	
#	datDir<-"c:\\temp\\test2\\meth27k\\batches\\48\\jhu-usc.edu_STAD.HumanMethylation27.48.0.0"
#	sig_A<-file.path(datDir,"UnMethylation_Signal_Intensity.csv")
#	sig_A_n<-file.path(datDir,"UnMethylation_Signal_Intensity_NBeads.csv")
#	sig_B<-file.path(datDir,"Methylation_Signal_Intensity.csv")
#	sig_B_n<-file.path(datDir,"Methylation_Signal_Intensity_NBeads.csv")
#	pvalue_fn<-file.path(datDir,"Pvalue.csv")
#	dat<-processLevel1Data.2(sig_B,sig_A,pvalue_fn,sig_B_n,sig_A_n,pref=pref,outPath="c:\\temp",toSave=T,isTCGA=F)
#	
#}
#processLevel1Data.2<-function(M,U,Pv,Mn=NULL,Un=NULL,Mse=NULL,Use=NULL,Ctr.R=NULL,Ctr.G=NULL,Ctr.M=NULL,Ctr.U=NULL,Ctr.N=NULL,toSave=F,TrimName=NULL,isTCGA=T,pref=NULL,outPath=NULL,dataType="IDAT"){
#	if(is.null(Mn)) Mn<-""; if(is.null(Un)) Un<-"";if(is.null(Mse)) Mse<-""; if(is.null(Use)) Use<-""; if(is.null(Ctr.R)) Ctr.R<-""; if(is.null(Ctr.G)) Ctr.G<-""
#	dat<-processLevel1Data(U,Un,Use,M,Mn,Mse,Ctr.R,Ctr.G,Pv,pref,toSave,TrimName,outPath,dataType,isTCGA)
#	if(dataType=="IDAT"){
#		M.sid<-names(dat@assayData$methylated)
#		if(!is.null(Ctr.M) & !is.null(Ctr.U)){
#			if(file.exists(Ctr.M)& file.exists(Ctr.U)){
#				dat.ctr.m<-readDataFile.2(Ctr.M)
#				dat.ctr.u<-readDataFile.2(Ctr.U)
#				dat.ctr.nb<-readDataFile.2(Ctr.NB)
#				dat.ctr.bn<-readDataFile.2(Ctr.BN)
#				if(!all(M.sid==names(dat.ctr.m)&M.sid==names(dat.ctr.u))) stop("The sids of M don't match those of Ctr.M or Ctr.U\n")
#				dat@QC<-new("MethyLumiQC",methylated=as.matrix(dat.ctr.m),unmethylated=as.matrix(dat.ctr.u),NBeads=as.matrix(dat.ctr.nb),BNeads=as.matrix(dat.ctr.bn))
#			}
#		}
#	}
#	return(dat)
#}
########
# note: the cols of GBM level-1 data is different from others 
########
processLevel1Data_test<-function(){
	datFns<-processedCSVFileNames()
	sig_A<-datFns["U"];sig_A_se<-datFns["Use"];sig_A_n<-datFns["Un"]
	sig_B<-datFns["M"];sig_B_se<-datFns["Mse"];sig_B_n<-datFns["Mn"]
	ctr_R_fn<-datFns["Rctr"];ctr_G_fn<-datFns["Gctr"];pvalue_fn<-datFns["Pv"]
	setwd("C:\\temp\\test\\meth27k\\tcga\\STAD\\jhu-usc.edu_STAD.HumanMethylation27.1.1.0\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0")
	pref<-"jhu-usc.edu_STAD.HumanMethylation27.1."
	outDir<-"c:\\temp\\jhu-usc.edu_STAD.HumanMethylation27.Level_1.1.0.0"
	mdat<-processLevel1Data(sig_A,sig_A_n,sig_A_se,sig_B,sig_B_n,sig_B_se,ctr_R_fn,ctr_G_fn,pvalue_fn,pref,outdir=outDir)
	
	setwd("C:\\temp\\IDAT\\meth450k\\processed\\6026818104")
	pref<-"jhu-usc.edu_STAD.HumanMethylation450.1."
	outDir<-"C:\\temp\\IDAT\\meth450k\\tcga\\test"
}
processLevel1Data<-function(sig_A,sig_A_n,sig_A_se,sig_B,sig_B_n,sig_B_se,ctr_R_fn,ctr_G_fn,pvalue_fn,pref=NULL,toSave=F,TrimName=NULL,outdir=NULL,dataType="IDAT",isTCGA=T){
	header1<-TRUE
	trimName<-function(TrimName,sid){
		if(!is.null(TrimName))sid<-sapply(sid,function(x)strsplit(x,"\\.")[[1]][1])
		return (sid)
	}
	A<-readDataFile.2(sig_A,header1=header1)
	A = A[order(row.names(A)),]; #sort rows
	A = A[,order(names(A))]; #sort cols
	ProbeSize = dim(A)[1];
	print( ProbeSize);
	SampleSize = dim(A)[2];
	print( SampleSize);
	sid = names(A);
	sid = trimName(TrimName,sid)
	pid = row.names(A);
	
	An<-NULL
	if(file.exists(sig_A_n)){
		An<-readDataFile.2(sig_A_n,header1=header1)
		if(  ProbeSize !=   dim(An)[1] || SampleSize != dim(An)[2])
		{
			stop (paste("dimension of An does not match with that of A, pls check ",sig_A_n,"\n"));
		}
		An = An[order(row.names(An)),];
		An = An[,order(names(An))];
		sid1 = names(An);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(An);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match An, pls check ",sig_A_n,"\n"));
	}
	
	Ae<-NULL
	if(file.exists(sig_A_se)){
		cat(sig_A_se);cat("\n")
		Ae<-readDataFile.2(sig_A_se,header1=header1)
		if(  ProbeSize !=   dim(Ae)[1] || SampleSize != dim(Ae)[2])
		{
			stop (paste("dimension of Ae does not match with that of A, pls check ",sig_A_se,"\n"));
		}
		Ae = Ae[order(row.names(Ae)),];
		Ae = Ae[,order(names(Ae))];
		sid1 = names(Ae);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(Ae);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Ae, pls check ",sig_A_se,"\n"));  
	}
	
	B<-readDataFile.2(sig_B,header1=header1)
	if(  ProbeSize !=   dim(B)[1] || SampleSize != dim(B)[2])
	{
		stop (paste("dimension of B does not match with that of A, pls check ",sig_B,"\n"));
	}
	B = B[order(row.names(B)),];
	B = B[,order(names(B))];
	sid1 = names(B);
	sid1 = trimName(TrimName,sid1)
	pid1 = row.names(B);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match ",sig_B,"\n"));
	
	Bn<-NULL
	if(file.exists(sig_B_n)){
		Bn<-readDataFile.2(sig_B_n,header1=header1)
		if(  ProbeSize !=   dim(Bn)[1] || SampleSize != dim(Bn)[2])
		{
			stop (paste("dimension of B does not match with that of A, pls check ",sig_B_n,"\n"));
		}
		Bn = Bn[order(row.names(Bn)),];
		Bn = Bn[,order(names(Bn))];
		sid1 = names(Bn);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(Bn);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Bn, pls check ",sig_B_n,"\n"));
	}
	
	Be<-NULL
	if(file.exists(sig_B_se)){
		Be<-readDataFile.2(sig_B_se,header1=header1)
		if(  ProbeSize !=   dim(Be)[1] || SampleSize != dim(Be)[2])
		{
			stop (paste("dimension of Be does not match with that of A,pls check",sig_B_se,"\n"));
		}
		Be = Be[order(row.names(Be)),];
		Be = Be[,order(names(Be))];
		sid1 = names(Be);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(Be);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Be, pls check",sig_B_se,"\n"));  
	}
	
	ctr_R<-NULL
	if(file.exists(ctr_R_fn)){
		ctr_R<-readDataFile.2(ctr_R_fn,header1=header1,rowName=NULL,isNum=F)
		ctr_R0<-ctr_R
		ind<-grep("NEG",ctr_R[,1],ignore.case=T)
		ctr_R<-ctr_R[ind,-1]
		ctr_R = ctr_R[,order(names(ctr_R))];
		sid1 = names(ctr_R);
		#sid1 = substr(t,1,nchar(t)-nchar(".Signal_Red"));
		#names(ctr_R) = sid1;
		sid1 = trimName(TrimName,sid1)
		if(sum(sid!=sid1)>0 ) stop(paste("row or col names of A do not match ctr_R",ctr_R_fn,"\n"));
		ctr_R_avg = apply(ctr_R,2,function(x)mean(as.numeric(x),na.rm=T));
		ctr_R_stderr = apply(ctr_R,2,function(x)sd(as.numeric(x),na.rm=T))/sqrt(length(ind));
	}
	
	ctr_G<-NULL
	if(file.exists(ctr_G_fn)){
		ctr_G<-readDataFile.2(ctr_G_fn,header1=header1,rowName=NULL,isNum=F)
		ctr_G0<-ctr_G
		ind<-grep("NEG",ctr_G[,1],ignore.case=T)
		ctr_G<-ctr_G[ind,-1]
		ctr_G = ctr_G[,order(names(ctr_G))]; 
		sid1 = names(ctr_G);
		sid1 = trimName(TrimName,sid1)
		if(sum(sid!=sid1)>0 ) stop(paste("row or col names of A do not match ctr_G,",ctr_G_fn,"\n"));
		ctr_G_avg = apply(ctr_G,2,function(x)mean(as.numeric(x),na.rm=T));
		ctr_G_stderr = apply(ctr_G,2,function(x)sd(as.numeric(x),na.rm=T))/sqrt(length(ind));
	}
	
	Pv<-readDataFile.2(pvalue_fn,header1=header1)
	if(  ProbeSize !=   dim(Pv)[1] || SampleSize != dim(Pv)[2])
	{
		stop (paste("dimension of Pv does not match with that of A, pls check ",pvalue_fn,"\n"));
	}
	Pv = Pv[order(row.names(Pv)),];
	Pv = Pv[,order(names(Pv))];
	sid1 = names(Pv);
	sid1 = trimName(TrimName,sid1)
	pid1 = row.names(Pv);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Pv",pvalue_fn,"\n"));      
	
	if(isTCGA==T){
		sid = gsub("(\\.)", "-", sid)
		len<-length(pid)
		if(!is.null(pref)){
			cancerType<-strsplit(strsplit(pref,"edu_")[[1]][2],"\\.")[[1]][1]
			if(is.na(cancerType)) cancerType<-"Unknown"
			for(i in 1:length(sid)){
				tcga_id = sid[i];
				fn = paste(pref,tcga_id,".txt",sep="");
				if(!is.null(outdir))fn<-file.path(outdir,fn)
				dat<-NULL;hd1<-NULL;hd2<-NULL
				if(!file.exists(sig_A_se)){
					hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
					hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","Detection_P_Value",sep="\t");
					dat<-data.frame(pid,B[,i],Bn[,i],A[,i],An[,i],Pv[,i])
					if(cancerType=="GBM"){
						hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,sep="\t");
						hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)", "Detection_P_Value",sep="\t");
						dat<-data.frame(pid,B[,i],A[,i],Pv[,i])
					}
				}else {
					hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
					hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
					dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
					if(cancerType=="GBM"){
						hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
						hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR", "Detection_P_Value",sep="\t");
						dat<-data.frame(pid,B[,i],A[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
					}
				}
				write(hd1,fn,sep="");
				write(hd2,fn,sep="",append=TRUE);
				write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
			}
		}else{
			stop("The pref for tcga level-1 data is null")
		}
	}
	mData<-list(sid=sid,pid=pid,A=A,B=B)
	if(!is.null(dataType)){
		Bv<-B/(A+B)
		if(dataType!="IDAT"){
			if(is.null(Bn)|is.null(An)|is.null(Be)|is.null(Ae)) stop("The data Bn, An, Be, or Ae is missing\n")
			require(Biobase)
			mData<-new("methData",M=as.matrix(B),Mn=as.matrix(Bn),Me=as.matrix(Be),
					U=as.matrix(A),Un=as.matrix(An),Ue=as.matrix(Ae),BetaValue=as.matrix(Bv),Pvalue=as.matrix(Pv))
			#class(mData)<-"methData"
			if(!is.null(ctr_G0)&!is.null(ctr_R0)){
				cData<-list()
				if(!all(ctr_G0[,1]==ctr_R0[,1]))stop("row names of the ctr_R and ctr_G donot match\n")
				for(i in 1:ncol(ctr_G0)){
					cData<-c(cData,list(data.frame(type=ctr_G0[,1],Grn=ctr_G0[,i],Red=ctr_R0[,i])))
				}
				names(cData)<-sid
				cData<<-cData
				setCData(mData)<-cData
			}
			if(toSave==T)save(mData,file="mset.rdata")
		}else{
			require(methylumi)
			mData<-new("MethyLumiSet",methylated=as.matrix(B),unmethylated=as.matrix(A),
					betas=as.matrix(Bv),methylated.N=as.matrix(Bn),unmethylated.N=as.matrix(An),
					pvals=as.matrix(Pv))
			if(toSave==T)save(mData,file="idat.rdata")
		}
	}
	return(mData)
}

processLevel1Data.1<-function(sig_A,sig_A_n,sig_A_se,sig_B,sig_B_n,sig_B_se,ctr_R_fn,ctr_G_fn,pvalue_fn,pref=NULL,toSave=F,TrimName=NULL,outdir=NULL,dataType="IDAT",isTCGA=T){
	header1<-TRUE
	trimName<-function(TrimName,sid){
		if(!is.null(TrimName))sid<-sapply(sid,function(x)strsplit(x,"\\.")[[1]][1])
		return (sid)
	}
	A<-readDataFile.2(sig_A,header1=header1)
	A = A[order(row.names(A)),]; #sort rows
	A = A[,order(names(A))]; #sort cols
	ProbeSize = dim(A)[1];
	print( ProbeSize);
	SampleSize = dim(A)[2];
	print( SampleSize);
	sid = names(A);
	sid = trimName(TrimName,sid)
	pid = row.names(A);
	
	An<-NULL
	if(file.exists(sig_A_n)){
		An<-readDataFile.2(sig_A_n,header1=header1)
		if(  ProbeSize !=   dim(An)[1] || SampleSize != dim(An)[2])
		{
			stop (paste("dimension of An does not match with that of A, pls check ",sig_A_n,"\n"));
		}
		An = An[order(row.names(An)),];
		An = An[,order(names(An))];
		sid1 = names(An);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(An);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match An, pls check ",sig_A_n,"\n"));
	}
	
	Ae<-NULL
	if(file.exists(sig_A_se)){
		cat(sig_A_se);cat("\n")
		Ae<-readDataFile.2(sig_A_se,header1=header1)
		if(  ProbeSize !=   dim(Ae)[1] || SampleSize != dim(Ae)[2])
		{
			stop (paste("dimension of Ae does not match with that of A, pls check ",sig_A_se,"\n"));
		}
		Ae = Ae[order(row.names(Ae)),];
		Ae = Ae[,order(names(Ae))];
		sid1 = names(Ae);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(Ae);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Ae, pls check ",sig_A_se,"\n"));  
	}
	
	B<-readDataFile.2(sig_B,header1=header1)
	if(  ProbeSize !=   dim(B)[1] || SampleSize != dim(B)[2])
	{
		stop (paste("dimension of B does not match with that of A, pls check ",sig_B,"\n"));
	}
	B = B[order(row.names(B)),];
	B = B[,order(names(B))];
	sid1 = names(B);
	sid1 = trimName(TrimName,sid1)
	pid1 = row.names(B);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match ",sig_B,"\n"));
	
	Bn<-NULL
	if(file.exists(sig_B_n)){
		Bn<-readDataFile.2(sig_B_n,header1=header1)
		if(  ProbeSize !=   dim(Bn)[1] || SampleSize != dim(Bn)[2])
		{
			stop (paste("dimension of B does not match with that of A, pls check ",sig_B_n,"\n"));
		}
		Bn = Bn[order(row.names(Bn)),];
		Bn = Bn[,order(names(Bn))];
		sid1 = names(Bn);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(Bn);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Bn, pls check ",sig_B_n,"\n"));
	}
	
	Be<-NULL
	if(file.exists(sig_B_se)){
		Be<-readDataFile.2(sig_B_se,header1=header1)
		if(  ProbeSize !=   dim(Be)[1] || SampleSize != dim(Be)[2])
		{
			stop (paste("dimension of Be does not match with that of A,pls check",sig_B_se,"\n"));
		}
		Be = Be[order(row.names(Be)),];
		Be = Be[,order(names(Be))];
		sid1 = names(Be);
		sid1 = trimName(TrimName,sid1)
		pid1 = row.names(Be);
		if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Be, pls check",sig_B_se,"\n"));  
	}
	
	ctr_R<-NULL
	if(file.exists(ctr_R_fn)){
		ctr_R<-readDataFile.2(ctr_R_fn,header1=header1,rowName=NULL,isNum=F)
		ctr_R0<-ctr_R
		ind<-grep("NEG",ctr_R[,1],ignore.case=T)
		ctr_R<-ctr_R[ind,-1]
		ctr_R = ctr_R[,order(names(ctr_R))];
		sid1 = names(ctr_R);
		#sid1 = substr(t,1,nchar(t)-nchar(".Signal_Red"));
		#names(ctr_R) = sid1;
		sid1 = trimName(TrimName,sid1)
		if(sum(sid!=sid1)>0 ) stop(paste("row or col names of A do not match ctr_R",ctr_R_fn,"\n"));
		ctr_R_avg = apply(ctr_R,2,function(x)mean(as.numeric(x),na.rm=T));
		ctr_R_stderr = apply(ctr_R,2,function(x)sd(as.numeric(x),na.rm=T))/sqrt(length(ind));
	}
	
	ctr_G<-NULL
	if(file.exists(ctr_G_fn)){
		ctr_G<-readDataFile.2(ctr_G_fn,header1=header1,rowName=NULL,isNum=F)
		ctr_G0<-ctr_G
		ind<-grep("NEG",ctr_G[,1],ignore.case=T)
		ctr_G<-ctr_G[ind,-1]
		ctr_G = ctr_G[,order(names(ctr_G))]; 
		sid1 = names(ctr_G);
		sid1 = trimName(TrimName,sid1)
		if(sum(sid!=sid1)>0 ) stop(paste("row or col names of A do not match ctr_G,",ctr_G_fn,"\n"));
		ctr_G_avg = apply(ctr_G,2,function(x)mean(as.numeric(x),na.rm=T));
		ctr_G_stderr = apply(ctr_G,2,function(x)sd(as.numeric(x),na.rm=T))/sqrt(length(ind));
	}
	
	Pv<-readDataFile.2(pvalue_fn,header1=header1)
	if(  ProbeSize !=   dim(Pv)[1] || SampleSize != dim(Pv)[2])
	{
		stop (paste("dimension of Pv does not match with that of A, pls check ",pvalue_fn,"\n"));
	}
	Pv = Pv[order(row.names(Pv)),];
	Pv = Pv[,order(names(Pv))];
	sid1 = names(Pv);
	sid1 = trimName(TrimName,sid1)
	pid1 = row.names(Pv);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop(paste("row or col names of A do not match Pv",pvalue_fn,"\n"));      
	
	if(isTCGA==T){
		sid = gsub("(\\.)", "-", sid)
		len<-length(pid)
		if(!is.null(pref)){
			cancerType<-strsplit(strsplit(pref,"edu_")[[1]][2],"\\.")[[1]][1]
			if(is.na(cancerType)) cancerType<-"Unknown"
			for(i in 1:length(sid)){
				tcga_id = sid[i];
				fn = paste(pref,tcga_id,".txt",sep="");
				if(!is.null(outdir))fn<-file.path(outdir,fn)
				hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
				hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
				dat<-NULL
				if(!file.exists(sig_A_se)){
					hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
					hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","Detection_P_Value",sep="\t");
					dat<-data.frame(pid,B[,i],Bn[,i],A[,i],An[,i],Pv[,i])
					if(cancerType=="GBM"){
						hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,sep="\t");
						hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)", "Detection_P_Value",sep="\t");
						dat<-data.frame(pid,B[,i],A[,i],Pv[,i])
					}
				}else {
					dat<-data.frame(pid,B[,i],Bn[,i],Be[,i],A[,i],An[,i],Ae[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
					if(cancerType=="GBM"){
						hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
						hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR", "Detection_P_Value",sep="\t");
						dat<-data.frame(pid,B[,i],A[,i],rep(ctr_G_avg[i],len),rep(ctr_G_stderr[i],len),rep(ctr_R_avg[i],len),rep(ctr_R_stderr[i],len),Pv[,i])
					}
				}
				write(hd1,fn,sep="");
				write(hd2,fn,sep="",append=TRUE);
				write.table(dat,fn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
			}
		}else{
			stop("The pref for tcga level-1 data is null")
		}
	}
	mData<-list(sid=sid,pid=pid,A=A,B=B)
	if(!is.null(dataType)){
		Bv<-B/(A+B)
		if(dataType!="IDAT"){
			if(is.null(Bn)|is.null(An)|is.null(Be)|is.null(Ae)) stop("The data Bn, An, Be, or Ae is missing\n")
			require(Biobase)
			mData<-new("methData",M=as.matrix(B),Mn=as.matrix(Bn),Me=as.matrix(Be),
					U=as.matrix(A),Un=as.matrix(An),Ue=as.matrix(Ae),BetaValue=as.matrix(Bv),Pvalue=as.matrix(Pv))
			#class(mData)<-"methData"
			if(!is.null(ctr_G0)&!is.null(ctr_R0)){
				cData<-list()
				if(!all(ctr_G0[,1]==ctr_R0[,1]))stop("row names of the ctr_R and ctr_G donot match\n")
				for(i in 1:ncol(ctr_G0)){
					cData<-c(cData,list(data.frame(type=ctr_G0[,1],Grn=ctr_G0[,i],Red=ctr_R0[,i])))
				}
				names(cData)<-sid
				cData<<-cData
				setCData(mData)<-cData
			}
			if(toSave==T)save(mData,file="mset.rdata")
		}else{
			require(methylumIDAT)
			mData<-new("MethyLumiSet",methylated=as.matrix(B),unmethylated=as.matrix(A),
					betas=as.matrix(Bv),methylated.N=as.matrix(Bn),unmethylated.N=as.matrix(An),
					pvals=as.matrix(Pv))
			if(toSave==T)save(mData,file="idat.rdata")
		}
	}
	return(mData)
}




packInfinium_test<-function(){
	datDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\TCGA Batch 49 Data Package (jhu-usc.edu_UCEC.HumanMethylation27.1.0.0)"
	sig_A<-file.path(datDir,"TCGA Batch 49 unmethylated signal intensity.txt")
	sig_A_se<-file.path(datDir,"TCGA Batch 49 unmethylated bead stderr.txt")
	sig_A_n<-file.path(datDir,"TCGA Batch 49 average number of unmethylated beads.txt")
	sig_B<-file.path(datDir,"TCGA batch 49 methylated signal intensity.txt")
	sig_B_se<-file.path(datDir,"TCGA Batch 49 methylated bead stderr.txt")
	sig_B_n<-file.path(datDir,"TCGA Batch 49 average number of methylated beads.txt")
	pvalue_fn<-file.path(datDir,"TCGA Batch 49 Detection P-value.txt")
	beta_fn<-file.path(datDir,"TCGA Batch 49 beta values (level 2).txt")
	ctr_R_fn<-file.path(datDir,"TCGA Batch 49 negative control probe signal_red.txt")
	ctr_G_fn<-file.path(datDir,"TCGA Batch 49 negative control probe signal_green.txt")
	outdir<-"c:\\temp"
	tcgaPackage_name<-"jhu-usc.edu_UCEC.HumanMethylation27.1.0.0a"
	txt=NULL
	readme_fn<-file.path(datDir,"DESCRIPTION Level 1 Batch 49.txt")
	packInfinium(sig_A,sig_A_se,sig_A_n,sig_B,sig_B_se,sig_B_n,pvalue_fn,beta_fn,ctr_R_fn,ctr_G_fn,outdir,tcgaPackage_name,txt,readme_fn)	
}

packInfinium <-function(sig_A,sig_A_se,sig_A_n,sig_B,sig_B_se,sig_B_n,pvalue_fn,beta_fn,
		ctr_R_fn,ctr_G_fn,outdir,tcgaPackage_name,txt=NULL,readme_fn=NULL,isTCGA=T,sampleCode=NULL,pcut=0.05){
	delim = ",";
	header1=TRUE;
	
	pref5<-tcgaPackage_name
	pref4<-tcgaPackage_name
	if(isTCGA==T){
		t1=unlist(strsplit(tcgaPackage_name,"\\."))
		pref5 <- paste(t1[1],".",t1[2],".",t1[3],sep="")
		pref4 <- paste(pref5,".",t1[4],sep="")
		arch_numb = paste(t1[4],".",t1[5],".",t1[6],sep="")
	}
	pref <- paste(pref4,".lvl-1.",sep="")
	pref2<-paste(pref4,".lvl-2.",sep="")
	pref3<-paste(pref4,".lvl-3.",sep="")
	arch_numb<-"1.0.0"
	
	A<-readDataFile.2(sig_A,header1=header1)
	A = A[order(row.names(A)),]; #sort rows
	A = A[,order(names(A))]; #sort cols
	ProbeSize = dim(A)[1];
	print( ProbeSize);
	SampleSize = dim(A)[2];
	print( SampleSize);
	sid = names(A);
	#sid = substr(t,1,nchar(t)-9);
	#names(A) = sid;
	pid = row.names(A);
	
	An<-readDataFile.2(sig_A_n,header1=header1)
	if(  ProbeSize !=   dim(An)[1] || SampleSize != dim(An)[2])
	{
		stop ("dimension of An does not match with that of A");
	}
	An = An[order(row.names(An)),];
	An = An[,order(names(An))];
	sid1 = names(An);
	#sid1 = substr(t,1,nchar(t)-13);
	#names(An) = sid1;
	pid1 = row.names(An);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match An");
	
	Ae<-readDataFile.2(sig_A_se,header1=header1)
	if(  ProbeSize !=   dim(Ae)[1] || SampleSize != dim(Ae)[2])
	{
		stop ("dimension of Ae does not match with that of A");
	}
	Ae = Ae[order(row.names(Ae)),];
	Ae = Ae[,order(names(Ae))];
	sid1 = names(Ae);
	#sid1 = substr(t,1,nchar(t)-14);
	#names(Ae) = sid1;
	pid1 = row.names(Ae);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match Ae");  
	
	
	B<-readDataFile.2(sig_B,header1=header1)
	if(  ProbeSize !=   dim(B)[1] || SampleSize != dim(B)[2])
	{
		stop ("dimension of B does not match with that of A");
	}
	B = B[order(row.names(B)),];
	B = B[,order(names(B))];
	sid1 = names(B);
	#sid1 = substr(t,1,nchar(t)-9);
	#names(B) = sid1;
	pid1 = row.names(B);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match B");
	
	Bn<-readDataFile.2(sig_B_n,header1=header1)
	if(  ProbeSize !=   dim(Bn)[1] || SampleSize != dim(Bn)[2])
	{
		stop ("dimension of B does not match with that of A");
	}
	Bn = Bn[order(row.names(Bn)),];
	Bn = Bn[,order(names(Bn))];
	sid1 = names(Bn);
	#sid1 = substr(t,1,nchar(t)-13);
	#names(Bn) = sid1;
	pid1 = row.names(Bn);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match Bn");
	
	Be<-readDataFile.2(sig_B_se,header1=header1)
	if(  ProbeSize !=   dim(Be)[1] || SampleSize != dim(Be)[2])
	{
		stop ("dimension of Be does not match with that of A");
	}
	Be = Be[order(row.names(Be)),];
	Be = Be[,order(names(Be))];
	sid1 = names(Be);
	#sid1 = substr(t,1,nchar(t)-14);
	#names(Be) = sid1;
	pid1 = row.names(Be);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match Be");  
	
	Bv<-readDataFile.2(beta_fn,header1=header1)
	if(  ProbeSize !=   dim(Bv)[1] || SampleSize != dim(Bv)[2])
	{
		stop ("dimension of Bv does not match with that of A");
	}
	Bv = Bv[order(row.names(Bv)),];
	Bv = Bv[,order(names(Bv))];
	sid1 = names(Bv);
	pid1 = row.names(Bv);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match Bv");  
	
	Pv<-readDataFile.2(pvalue_fn,header1=header1)
	if(  ProbeSize !=   dim(Pv)[1] || SampleSize != dim(Pv)[2])
	{
		stop ("dimension of Pv does not match with that of A");
	}
	Pv = Pv[order(row.names(Pv)),];
	Pv = Pv[,order(names(Pv))];
	sid1 = names(Pv);
	pid1 = row.names(Pv);
	if(sum(sid!=sid1)>0 ||sum(pid!=pid1)) stop("row or col names of A do not match Pv");      
	
	ctr_R<-readDataFile.2(ctr_R_fn,header1=header1,rowName=NULL,isNum=F)
	ind<-grep("NEG",ctr_R[,1],ignore.case=T)
	ctr_R<-ctr_R[ind,-1]
	ctr_R = ctr_R[,order(names(ctr_R))]; #sort cols
	sid1 = names(ctr_R);
	#sid1 = substr(t,1,nchar(t)-nchar(".Signal_Red"));
	#names(ctr_R) = sid1;
	if(sum(sid!=sid1)>0 ) stop("row or col names of A do not match ctr_R");
	ctr_R_avg = apply(ctr_R,2,function(x)mean(as.numeric(x),na.rm=T));
	ctr_R_stderr = apply(ctr_R,2,function(x)sd(as.numeric(x),na.rm=T))/sqrt(16);
	
	
	ctr_G<-readDataFile.2(ctr_G_fn,header1=header1,rowName=NULL,isNum=F)
	ind<-grep("NEG",ctr_G[,1],ignore.case=T)
	ctr_G<-ctr_G[ind,-1]
	ctr_G = ctr_G[,order(names(ctr_G))]; #sort cols
	sid1 = names(ctr_G);
	#sid1 = substr(t,1,nchar(t)-nchar(".Signal_grn"));
	#names(ctr_G) = sid1;
	if(sum(sid!=sid1)>0 ) stop("row or col names of A do not match ctr_G");
	ctr_G_avg = apply(ctr_G,2,function(x)mean(as.numeric(x),na.rm=T));
	ctr_G_stderr = apply(ctr_G,2,function(x)sd(as.numeric(x),na.rm=T))/sqrt(16);
	
	data(lvl3mask)
	lvl3mask = lvl3mask[order(row.names(lvl3mask)),]; #sort rows
	pid1 = row.names(lvl3mask);
	if(sum(sid!=sid1)>0 ) stop("row or col names of A do not match lvl3mask");  
	
	sid = gsub("(\\.)", "-", sid)
#	if(!is.null(sampleCode)){
#		sid1 = sapply(sid,function(x)substr(x,2,nchar(sid)))
#		sid1 = sampleCode[sid];
#		sid<-ifelse(is.na(sid1,sid,sid1))
#	}
	if(!is.null(txt)){
		msg<-paste("> Finishing Reading and Processing All the Data Files ",date(),"\n",sep="")
		cat(msg)
		cat("> Working on the generating level files\n")
	}
	setwd(outdir);
	cat(paste("The number of samples is",length(na.omit(sid)),"\n"))
	#level 1  
	for(i in 1:length(sid)){
		#if(!is.null(sampleCode)) sidc = sampleCode[i,1];
		sidc = i;
		if(is.na(sid[i]))next
		tcga_id = sid[i];
		fn = paste(pref,tcga_id,".txt",sep="");
		hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
		hd2= paste("Composite Element REF", "Methylated_Signal_Intensity (M)", "M_Number_Beads","M_STDERR","Un-Methylated_Signal_Intensity (U)", "U_Number_Beads","U_STDERR","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_Avg_Intensity","Negative_Control_Red_STDERR","Detection_P_Value",sep="\t");
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		for( j in 1:length(pid)){
			rst = paste(pid[j],B[j,sidc],Bn[j,sidc],Be[j,sidc],A[j,sidc],An[j,sidc],Ae[j,sidc],ctr_G_avg[i],ctr_G_stderr[i],ctr_R_avg[i],ctr_R_stderr[i],Pv[j,sidc],sep="\t")
			write(rst,fn,sep="",append=TRUE);
		}
	}
	
	if(!is.null(txt)){
		msg<-paste("> Finishing processing the level-1 data files...",date(),"\n",sep="")
		cat(msg)
		cat("> Working on level-2 data files. \n")
	}
	
	#level 2
	for(i in 1:length(sid)){
		#tcga_id = sampleCode1[i,4];
		sidc = i;
		if(is.na(sid[i]))next
		tcga_id = sid[i];
		fn = paste(pref2,tcga_id,".txt",sep="");
		hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,sep="\t");
		hd2= paste("Composite Element REF", "Beta_Value", "Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)",sep="\t");
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		for( j in 1:length(pid)){
			if(is.na(Pv[j,sidc])){
				rst = paste(pid[j],"NA",B[j,sidc],A[j,sidc],sep="\t")
			}else if(Pv[j,sidc]<pcut){
				rst = paste(pid[j],Bv[j,sidc],B[j,sidc],A[j,sidc],sep="\t")
			} else{
				rst = paste(pid[j],"NA",B[j,sidc],A[j,sidc],sep="\t")
			}
			write(rst,fn,sep="",append=TRUE);
		}
	}  
	if(!is.null(txt)){
		msg<-paste("> Finishing processing the level-2 data Files...",date(),"\n",sep="")
		cat(msg)
		cat("> Working on the level-3 data Files.\n")
	}
	#level 3           
	for(i in 1:length(sid)){
		sidc = i;
		if(is.na(sid[i]))next
		tcga_id = sid[i];
		fn = paste(pref3,tcga_id,".txt",sep="");
		hd1= paste("Hybridization REF",tcga_id,tcga_id,tcga_id,tcga_id,sep="\t");
		hd2= paste("Composite Element REF", "Beta_Value", "Gene_Symbol", "Chromosome", "Genomic_Coordinate",sep="\t");
		write(hd1,fn,sep="");
		write(hd2,fn,sep="",append=TRUE);
		for( j in 1:length(pid)){
			if(is.na(Pv[j,sidc])){
				rst = paste(pid[j],"NA",lvl3mask[[2]][j],lvl3mask[[3]][j],lvl3mask[[5]][j],sep="\t")
			}else if(Pv[j,sidc]<pcut & lvl3mask[[1]][j] == 0){
				rst = paste(pid[j],Bv[j,sidc],lvl3mask[[2]][j],lvl3mask[[3]][j],lvl3mask[[5]][j],sep="\t");
			} else{
				rst = paste(pid[j],"NA",lvl3mask[[2]][j],lvl3mask[[3]][j],lvl3mask[[5]][j],sep="\t");
			}
			write(rst,fn,sep="",append=TRUE);
		}
	}    
	sid<-na.omit(sid)
	create_Manifest(outdir)
	create_SDRF(pref4,sid,outdir)
	if(!is.null(readme_fn)){
		file.copy(readme_fn,file.path(outdir,"DESCRIPTION.TXT"))
	}
	if(!is.null(txt)){
		msg<-paste("> Done with the level-3 data processing ",date(),"\n",sep="")
		cat(msg)
	}
	mdata<-new("methData",M=as.matrix(A),Mn=as.matrix(An),Me=as.matrix(Ae),
			U=as.matrix(B),Un=as.matrix(Bn),Ue=as.matrix(Be),
			Beta=as.matrix(Bv),Pvalue=as.matrix(Pv))
	class(mdata)<-"methData"
	#fn<-"methData"
	fn<-file.path(outdir,paste("methData",".rdata",sep=""))
	if(file.exists(fn))fn<-file.path(outdir,paste("methData_",unclass(Sys.time()),".rdata",sep=""))
	save(mdata,file=fn)
	return(sid)
}


create_Manifest<-function(wkdir){
	fn = "MANIFEST.txt";
	setwd(wkdir);
	flist = list.files();
	write(flist[1],fn,sep="");
	for(i in 2:length(flist)){
		write(flist[i],fn,append=TRUE);
	}
}
create_SDRF_complete_run<-function(){
	data.dir<-"c:\\tcga\\OV"
	SDRF_pkg_name<-"jhu-usc.edu_OV.HumanMethylation27.2.sdrf.txt"
	create_SDRF_complete(SDRF_pkg_name,data.dir)
	
	data.dir<-"c:\\tcga\\LUSC"
	pkg_name<-"jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt"
	create_SDRF_complete(pkg_name,data.dir)
}
create_SDRF_complete<-function(pkg_name,data.dir=NULL){
	if(is.null(data.dir)) data.dir<-"c:\\tcga\\OV"
	setwd(data.dir)
	dlist<-list.files(pattern="Level_1")
	ind<-grep("tar",dlist)
	dlist<-dlist[ind]
	dlist<-dlist[-grep("gz",dlist)]
	#ind1<-grep(".md5",dlist)
	#dlist<-dlist[-ind1]
	sid.all<-c()
	pref4.all<-c()
	pref5.all<-c()
	arch_numb.all<-c()
	for(i in 1:length(dlist)){
		setwd(data.dir)
		#system(paste("gzip -d ",dlist[i],sep=""))
		#fn<-substr(dlist[i],1,(nchar(dlist[i])-3))
		fn<-dlist[i]
		system(paste("tar -xvf ",fn,sep=""))
		fn1<-substr(fn,1,(nchar(fn)-3))
		setwd(file.path(data.dir,fn1))
		flist<-list.files(pattern="lvl-1")
		sid<-sapply(flist,function(x)strsplit(x,"lvl-1")[[1]][2])
		sid<-sapply(sid,function(x)strsplit(x,"\\.")[[1]][2])
		sid.all<-c(sid.all,sid)
		np<-unlist(strsplit(dlist[i],"\\.Level_1\\."))
		arch_numb<-substr(np[2],1,(nchar(np[2])-4))
		pref5<-np[1]
		pref4<-paste(np[1],strsplit(arch_numb,"\\.")[[1]][1],sep=".")
		arch_numb.all<-c(arch_numb.all,rep(arch_numb,length(flist)))
		pref5.all<-c(pref5.all,rep(pref5,length(flist)))
		pref4.all<-c(pref4.all,rep(pref4,length(flist)))
	}
	#create_SDRF(pkg_name,sid.all,data.dir)
	adf_fn<-paste(pref4.all,".adf.txt",sep="")
	create_Mage_TAB_SDRF.2(pref4.all,pref5.all,sid.all,data.dir,pkg_name,arch_numb.all,adf_fn)
}

##################
# SDRF of Old Scheme
#################
create_SDRF<-function(pref4,sampleID,outdir){
	setwd(outdir)
	hd1= paste("Extract Name","Protocol REF","Labeled Extract Name",
			"Label","Term Source REF","Protocol REF","Hybridization Name",
			"Array Design File","Term Source REF","Protocol REF","Scan Name",
			"Protocol REF","Protocol REF","Normalization Name",
			"Derived Array Data Matrix File","Comment [TCGA Data Level]",
			"Protocol REF","Normalization Name","Derived Array Data Matrix File",
			"Comment [TCGA Data Level]","Protocol REF","Normalization Name",
			"Derived Array Data Matrix File","Comment [TCGA Data Level]",sep="\t");
	sdrf_fn = paste(pref4,".sdrf.txt",sep="");
	write(hd1,sdrf_fn,sep="");
	adf_fn = paste(pref4,".adf.txt",sep="");
	
	for(i in 1:length(sampleID)){
		sidc = i;
		tcga_id = sampleID[i];	
		lvl1_fn = paste(pref4,".lvl-1.",tcga_id,".txt",sep="");
		lvl2_fn = paste(pref4,".lvl-2.",tcga_id,".txt",sep="");
		lvl3_fn = paste(pref4,".lvl-3.",tcga_id,".txt",sep="");
		hd2= paste(tcga_id,"jhu-usc.edu:labeling:HumanMethylation27:01",tcga_id,"biotin",
				"MGED Ontology","jhu-usc.edu:hybridization:HumanMethylation27:01",
				tcga_id,adf_fn,"caArray",
				"jhu-usc.edu:image_acquisition:HumanMethylation27:01",tcga_id,
				"jhu-usc.edu:feature_extraction:HumanMethylation27:01",
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
				tcga_id,lvl1_fn,"Level 1","jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",
				tcga_id,lvl2_fn,"Level 2",
				"jhu-usc.edu:within_bioassay_data_set_function:HumanMethylation27:01",tcga_id,
				lvl3_fn,"Level 3",sep="\t"
		);
		write(hd2,sdrf_fn,sep="",append=TRUE);
	}
}
#####################
# 05/03/2010 - Release 3.1
# https://wiki.nci.nih.gov/display/TCGA/DCC+Archive+Validator+version+3
# https://wiki.nci.nih.gov/download/attachments/21695888/validator3.zip?version=12
######################
validatePkg_test<-function(){
	pkgPath<-"C:\\temp\\jhu-usc.edu_UCEC.HumanMethylation27.1"
	validatePkg(pkgPath)
}
validatePkg_test.2<-function(){
	pkgPath<-"/home/feipan/temp/jhu-usc.edu_OV.HumanMethylation27.15"
	pkgPath<-"C:\\temp\\test3\\meth450k\\batches\\1"
	validatePkg(pkgPath,package="rapid.pro")
}
validatePkg<-function(pkgPath,validatorPath=NULL,javaPath=NULL,txt=NULL,package="rapid"){
	msg<-paste(">Start to run QC validator...",date(),"\n")
	cat(msg)
	if(!is.null(txt)){
		tkinsert(txt,"end",msg)
	}
	#if(is.null(validatorPath))validatorPath<-file.path(system.file(package="methPipe"),"validator3")#"c:\\tcga\\validator3"
	if(is.null(validatorPath)){
		validatorPath<-system.file("validator3",package=package)
	}
	setwd(validatorPath)
	fn<-file.path(pkgPath,"qc_validator.txt")
	if(R.Version()$os=="mingw32"){
		runbat<-"java -showversion -Xms1024M -Xmx1024M -classpath .;gov;conf;lib/opencsv.jar;lib/ant.jar;lib/log4j.jar;lib/serializer.jar;lib/xml-apis.jar;lib/xercesImpl.jar;lib/xalan.jar;lib/acegi-security-1.0.4.jar;lib/antlr-2.7.6.jar;lib/asm.jar;lib/axis.jar;lib/caGrid-CQL-cql.1.0-1.2.jar;lib/castor-1.0.2.jar;lib/cglib-2.1.3.jar;lib/cog-jglobus.jar;lib/commons-codec-1.3.jar;lib/commons-collections-3.2.jar;lib/commons-discovery-0.2.jar;lib/commons-logging-1.1.jar;lib/hibernate3.jar;lib/jaxrpc.jar;lib/log4j-1.2.14.jar;lib/sdk-client-framework.jar;lib/sdk-grid-remoting.jar;lib/sdk-security.jar;lib/spring.jar;lib/tcgadccws-beans.jar;lib/xercesImpl.jar;lib/postgresql.jar gov/nih/nci/ncicb/tcga/dcc/qclive/soundcheck/Soundcheck %*"
		if(!is.null(javaPath))runbat<-file.path(javaPath,runbat)
		cmd<-paste(runbat," \"",pkgPath,"\" > \"",fn,"\"",sep="")
		shell(cmd)
	}else{
		runbat<-paste(javaPath,"java -showversion -Xms1024M -Xmx1024M -classpath ",validatorPath,":.:gov:conf:lib/opencsv.jar:lib/ant.jar:lib/log4j.jar:lib/serializer.jar:lib/xml-apis.jar:lib/xercesImpl.jar:lib/xalan.jar:lib/acegi-security-1.0.4.jar:lib/antlr-2.7.6.jar:lib/asm.jar:lib/axis.jar:lib/caGrid-CQL-cql.1.0-1.2.jar:lib/castor-1.0.2.jar:lib/cglib-2.1.3.jar:lib/cog-jglobus.jar:lib/commons-codec-1.3.jar:lib/commons-collections-3.2.jar:lib/commons-discovery-0.2.jar:lib/commons-logging-1.1.jar:lib/hibernate3.jar:lib/jaxrpc.jar:lib/log4j-1.2.14.jar:lib/sdk-client-framework.jar:lib/sdk-grid-remoting.jar:lib/sdk-security.jar:lib/spring.jar:lib/tcgadccws-beans.jar:lib/xercesImpl.jar:lib/postgresql.jar gov/nih/nci/ncicb/tcga/dcc/qclive/soundcheck/Soundcheck ",sep="")
		if(!is.null(javaPath))runbat<-file.path(javaPath,runbat)
		cmd<-paste(runbat," ",pkgPath," > ",fn,sep="")
		system(cmd,wait=T)
	}
	qc.rst<-readLines(fn)
	check<-"Validation passed with no errors or warnings."
	if(qc.rst[length(qc.rst)]!=check){
		msg<-paste(">There are some errors in QC Validation, more details are in ",fn,"\n")
		cat(msg)
		if(!is.null(txt)) tkinsert(txt,"end",msg)
	}else{
		msg<-">Done with running QC validator without errors\n"
		cat(msg)
		if(!is.null(txt))tkinsert(txt,"end",msg)
	}
}
validateInfiniumPkg<-function(pkg.dir,pkg_name=NULL){
	#validator.dir<-paste(system.file("data",package="methPipe"),"/validator3",sep="")
	validator.dir<-"c:\\tcga\\validator3"
	setwd(validator.dir)
	#pfile<-file.path(validator.dir,"validate.bat")
	runbat<-readLines("validate.bat")
	zz<-file(file.path(validator.dir,"run1.bat"),"w")
	#cat("cd ",validator.dir,"\n",file=zz)
	timestamp<-unclass(Sys.time())
	if(!is.null(pkg_name)) {
		fn<-paste("script.out.",pkg_name,timestamp,".txt",sep="")
	}
	else {
		fn<-paste("script.out",timestamp,".txt",sep="")
	}
	command<-paste(runbat," ",pkg.dir,">",fn,sep="")
	cat(command,"\n",file=zz)
	close(zz)
	shell(file.path(validator.dir,"run1.bat"))
	shell(file.path(validator.dir,fn))
	
}






###############
# May 13, 2010
###############
depositePkg<-function(pkgFolder){
	repos<-"feipan@epimatrix.usc.edu:/tcga/data"
	setwd(pkgFolder)
	flist.md5<-list.files(pattern=".md5")
	flist.gz<-list.files(pattern=".gz")
	flist<-c(flist.md5,flist.gz)
	flist.name<-paste(flist,collapse="/n")
	wdir<-"c:\\temp" #tempdir()
	#fn.manifest<-updateManifest()
	#flist<-c(flist,fn.manifest)
	scopy(flist,repos)
}
updateManifest<-function(toDB=T){
	fn<-"MANIFEST.TXT"
	download.file(paste(repos,fn,sep="/"),destfile=wdir)
	fn.manifest<-file.path(wdir,fn)
	zz<-file(fn.manifest)
	cat(flist.name,file=zz,append=T)
	close(zz)
	if(toDB==T){
		cat("to do...\n")
	}
	return(fn.manifest)
}
scopy<-function(flist,repos){
	#repos<-"feipan@epimatrix.usc.edu:/home/feipan/apache-tomcat-6.0.20/webapps/ROOT/tcga/data"
	wdir<-"c:\\temp"#tempdir()
	fn<-file.path(wdir,"run.bat")
	zz<-file(fn,"w")
	flists<-paste(flist,collapse=" ")
	cat(paste("c:/cygwin/bin/scp ",flists," ",repos,"\n"),file=zz)
	close(zz)
	shell(fn)
}
downloadRepos<-function(pgk){
	repos<-"http://epimatrix.usc.edu:8080/tcga/data"
	if(is.null(wdir)){
		wdir<-"c:\\temp" #tempdir()
	}
	fn.dest<-file.path(wdir,pkg_name)
	fn.repos<-paste(repos,pkg_name,sep="/")
	download.file(fn.repos,destfile=fn.dest)
	return(fn.dest)
}
loadPkgFromRepos<-function(pkg_name,txt=NULL,wdir=NULL){
	fn.dest<-downloadRepos(pkg_name)
	msg<-paste("Data package ",pkg_name," are downloaded into ",fn.dest,"\n",sep="")
	cat(msg)
	if(!is.null(txt)){
		tkinsert(txt,"end",msg)
	}
}
viewDataRepos<-function(pkg_type){
	fn<-downloadRepos(pkg_type)
	dat<-read.table(fn,sep="\t")
	ind<-dat[1,]==pkg_type
	dat<-dat[ind,]
	data.entry(dat)
}

################################
run_merge_SDRF_files<-function(){
	#COAD
	pkg_folders<-c("C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.1\\jhu-usc.edu_COAD.HumanMethylation27.mage-tab.1.0.0\\jhu-usc.edu_COAD.HumanMethylation27.1.sdrf.txt",
					"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.2\\jhu-usc.edu_COAD.HumanMethylation27.mage-tab.1.1.0\\jhu-usc.edu_COAD.HumanMethylation27.2.sdrf.txt",
					"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.3\\jhu-usc.edu_COAD.HumanMethylation27.mage-tab.1.3.0\\jhu-usc.edu_COAD.HumanMethylation27.3.sdrf.txt",
					"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.4\\jhu-usc.edu_COAD.HumanMethylation27.mage-tab.1.4.0\\jhu-usc.edu_COAD.HumanMethylation27.4.sdrf.txt",
					"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.5\\jhu-usc.edu_COAD.HumanMethylation27.mage-tab.1.5.0\\jhu-usc.edu_COAD.HumanMethylation27.5.sdrf.txt")	
	fn<-"c:\\tcga\\COAD\\jhu-usc.edu_COAD.HumanMethylation27.5.sdrf.txt"
	merge_SDRF_files(pkg_folders,fn)
	#READ
	pkg_folders<-c("C:\\tcga\\jhu-usc.edu_READ.HumanMethylation27.1\\jhu-usc.edu_READ.HumanMethylation27.mage-tab.1.0.0\\jhu-usc.edu_READ.HumanMethylation27.1.sdrf.txt",
			"C:\\tcga\\jhu-usc.edu_READ.HumanMethylation27.2\\jhu-usc.edu_READ.HumanMethylation27.mage-tab.1.1.0\\jhu-usc.edu_READ.HumanMethylation27.2.sdrf.txt",
			"C:\\tcga\\jhu-usc.edu_READ.HumanMethylation27.3\\jhu-usc.edu_READ.HumanMethylation27.mage-tab.1.3.0\\jhu-usc.edu_READ.HumanMethylation27.3.sdrf.txt",
			"C:\\tcga\\jhu-usc.edu_READ.HumanMethylation27.4\\jhu-usc.edu_READ.HumanMethylation27.mage-tab.1.4.0\\jhu-usc.edu_READ.HumanMethylation27.4.sdrf.txt",
			"C:\\tcga\\jhu-usc.edu_READ.HumanMethylation27.5\\jhu-usc.edu_READ.HumanMethylation27.mage-tab.1.5.0\\jhu-usc.edu_READ.HumanMethylation27.5.sdrf.txt")
	fn<-"c:\\tcga\\jhu-usc.edu_READ.HumanMethylation27.5.sdrf.txt"
	merge_SDRF_files(pkg_folders,fn)
	# GBM
	pkg_folders<-c("C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.0.0\\jhu-usc.edu_GBM.HumanMethylation27.1.sdrf.txt",
			"C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.7.0\\jhu-usc.edu_GBM.HumanMethylation27.7.sdrf.txt",
			"C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.6.0\\jhu-usc.edu_GBM.HumanMethylation27.6.sdrf.txt",
			"C:\\tcga\\jhu-usc.edu_GBM.HumanMethylation27.8\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.8.0\\jhu-usc.edu_GBM.HumanMethylation27.8.sdrf.txt")
	fn<-"c:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.8.sdrf.txt"
	merge_SDRF_files(pkg_folders,fn)
	#LUSC
	# update to level_3.2.3
	createManifestByLevel.2("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.3.0")
	compressDataPackage("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.3.0")
	# update sdrf
	fn<-"C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.2.0\\jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt"
	sdrf<-readLines(fn)
	sdrf1<-gsub("Level_3.2.2.0","Level_3.2.3.0",sdrf)
	write(sdrf1,file=fn)
	createManifestByLevel.2("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.2.0")
	compressDataPackage("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.2.0")
	# remove old 2.1
	fn<-"C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.7.0\\jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt"
	sdrf<-readLines(fn)
	ind<-grep("Level_1.2.1.0",sdrf)
	sdrf1<-sdrf[-ind]
	write(sdrf1,file=fn)
	
	pkg_folders<-c("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.2.0\\jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt",
			"C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.7.0\\jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt",
			"C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.3\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.3.0\\jhu-usc.edu_LUSC.HumanMethylation27.3.sdrf.txt")
	fn<-"c:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt"
	merge_SDRF_files(pkg_folders,fn,outdir="C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.7.0")
	
	createManifestByLevel.2("C:\\tcga\\LUSC","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.7.0")
	compressDataPackage("c:\\tcga\\LUSC","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.7.0")
}
merge_Packages_run<-function(){
	cur_pkgs<-"c:\\tcga\\LUSC"
	new_pkg<-"c:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.3"
	merge_Packages(cur_pkgs,new_pkg,inc=F)
	new_pkg<-"c:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2"
	
	
	cur_pkgs<-"c:\\tcga\\COAD"
	new_pkg<-"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.5"
	new_pkg<-"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.6"
	
	
	cur_pkgs<-"c:\\tcga\\KIRC"
	new_pkg<-"C:\\tcga\\jhu-usc.edu_KIRC.HumanMethylation27.1"
	cur_pkgs<-"c:\\tcga\\LUAD"
	new_pkg<-"C:\\tcga\\jhu-usc.edu_LUAD.HumanMethylation27.1"

	pkg_validate(new_pkg)
	merge_Packages(cur_pkgs,new_pkg)
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.1.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.1.0")

	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.3.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.3.0")
	new_pkg<-"C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.2"
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.1.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.1.0")
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.4.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.4.0")
	new_pkg<-"C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1"
	
	createManifestByLevel.2("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.4.0")
	compressDataPackage("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.4.0")
	createManifestByLevel.2("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.2.0")
	compressDataPackage("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.2.0")
	
	createManifestByLevel.2("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.3","jhu-usc.edu_LUSC.HumanMethylation27.Level_1.3.1.0")
	compressDataPackage("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.3","jhu-usc.edu_LUSC.HumanMethylation27.Level_1.3.1.0")
	createManifestByLevel.2("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.3","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.3.0")
	compressDataPackage("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.3","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.3.0")
}
createMD5SUM<-function(fn,fdir=NULL){
	if(is.null(fdir))fdir<-filedir(fn)
	cdir<-getwd()
	setwd(fdir)
	if(R.Version()$os=="mingW32"){
		md5sum<-file.path(system.file("Rtools",package="rapid","md5sum"))
		shell(paste(md5sum," *.* > ",fn),sep="")
	}else{
		system(paste("md5sum *.* > ",fn))
	}
	setwd(cdir)
}
uncompress<-function(fn,fDir=NULL,package="rapid"){
	rst<-NULL
	cdir<-getwd()
	if(!is.null(fDir))setwd(fDir)
	if(R.Version()$os=="mingw32"){
		tar<-file.path(system.file("Rtools",package=package),"tar")
		rst<-system(paste(tar," -xzf ",fn,sep=""))
	}else{
		rst<-system(paste("tar -xzf",fn))
	}
	setwd(cdir)
	return(rst)
}
compressData<-function(datDir,datType=".csv",package="rapid.pro"){
	datFns<-paste(list.files(datDir,patt=datType),collapse=" ")
	setwd(datDir);tar<-"tar";gzip<-"gzip";md5sum<-"md5sum"
	if(R.Version()$os=="mingw32"){
		tar<-file.path(system.file("Rtools",package=package),tar)
		gzip<-file.path(system.file("Rtools",package=package),gzip)
		md5sum<-file.path(system.file("Rtools",package=package),md5sum)
	}
	datName<-filetail(datDir)
	system(paste(tar," -cf ",datName,".tar ",datFns,sep=""))
	system(paste(gzip," -c ",datName,".tar > ",datName,".tar.gz",sep=""))
	system(paste(md5sum,datName,".tar.gz > ",datName,".tar.gz.md5",sep=""))
}
merge_Packages.2_test<-function(){
	cur_pkgs<-"C:\\temp\\STAD"
	new_pkg<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\jhu-usc.edu_STAD.HumanMethylation27.1"
	merge_Packages.2(cur_pkgs,new_pkg)
}
#######
# added error checking/msg outputs based on merge_Packages()
######
merge_Packages.2<-function(cur_pkgs,new_pkg,inc=T){
	setwd(cur_pkgs)
	mage_dir<-list.files(cur_pkgs,pattern="mage-tab")
	new_pkg_fn<-list.files(new_pkg,pattern="tar")
	if(length(mage_dir)>=1){
		mage_fn<-mage_dir[grep("tar.gz$",mage_dir)]
		if(length(mage_fn)!=1)stop("Mage file is missing or non-unique,please validate the data repository\n")
		uncompress(mage_fn)
		mage_dir<-gsub(".tar.gz","",mage_fn)
		mage_dir.new<-list.files(new_pkg,pattern="mage-tab")
		mage_dir.new<-mage_dir.new[grep("tar.gz$",mage_dir.new)]
		if(length(mage_dir.new)!=1) stop("Mage file is missing or non-unique, please validate the new data package\n")
		uncompress(mage_dir.new,new_pkg)
		mage_dir.new<-gsub(".tar.gz","",mage_dir.new)
		sdrf_fn<-list.files(file.path(cur_pkgs,mage_dir),pattern="sdrf")
		sdrf_fn.cur<-file.path(cur_pkgs,mage_dir,sdrf_fn)
		sdrf_fn.new<-file.path(new_pkg,mage_dir.new,list.files(file.path(new_pkg,mage_dir.new),pattern="sdrf"))
		update_SDRF_files.2(sdrf_fn.cur,sdrf_fn.new)
		# create new magtab
		t1<-strsplit(mage_dir,"\\.")[[1]]
		t2<-as.numeric(t1[6])
		if(inc==T) t2<-t2+1
		t1[6]<-t2
		magetab_fn<-paste(t1,collapse=".")
		file.rename(mage_dir,magetab_fn)
		mage_fn_new<-file.path(cur_pkgs,magetab_fn)
		createManifestByLevel.2(cur_pkgs,magetab_fn)
		compressDataPackage(cur_pkgs,magetab_fn)
		
		#bk old pkgs and magtab
		setwd(cur_pkgs)
		if(!file.exists("bk")) dir.create("bk")
		file.copy(paste(mage_dir,".tar.gz",sep=""),paste("bk/",mage_dir,".tar.gz",sep=""))
		file.copy(paste(mage_dir,".tar.gz.md5",sep=""),paste("bk/",mage_dir,".tar.gz.md5",sep=""))
		t2<-strsplit(new_pkg_fn[1],"\\.")[[1]][5]
		for(i in 1:3){
			fn<-list.files(cur_pkgs,paste("Level_",i,".",t2,sep=""))
			fn<-fn[grep("tar",fn)]
			for(f1 in fn){
				file.copy(f1,file.path("bk",f1))
				file.remove(f1)
			}
		}
		# rm old magtab
		if(inc==T){
			file.remove(file.path(cur_pkgs,paste(mage_dir,".tar.gz",sep="")))
			file.remove(file.path(cur_pkgs,paste(mage_dir,".tar.gz.md5",sep="")))
		}
		new_pkg_fn<-new_pkg_fn[-grep("mage",new_pkg_fn)] #note: for old repos,don't trans mage file
	}
	#trans new pkgs
	for(fn in new_pkg_fn) file.copy(file.path(new_pkg,fn),file.path(cur_pkgs,fn))
}
#####
#
####
	merge_Packages<-function(cur_pkgs,new_pkg,inc=T){
		setwd(cur_pkgs)
		mage_dir<-list.files(cur_pkgs,pattern="mage-tab")
		new_pkg_fn<-list.files(new_pkg,pattern="tar")
		if(length(mage_dir)>=1){
			mage_dir<-mage_dir[-grep("tar",mage_dir)]
			mage_dir.new<-list.files(new_pkg,pattern="mage-tab")
			mage_dir.new<-mage_dir.new[-grep("tar",mage_dir.new)]
			sdrf_fn<-list.files(file.path(cur_pkgs,mage_dir),pattern="sdrf")
			sdrf_fn.cur<-file.path(cur_pkgs,mage_dir,sdrf_fn)
			sdrf_fn.new<-file.path(new_pkg,mage_dir.new,list.files(file.path(new_pkg,mage_dir.new),pattern="sdrf"))
			#file.copy(sdrf_fn.cur,paste(file.path(cur_pkgs,sdrf_fn),"_bk",sep=""))
			update_SDRF_files.2(sdrf_fn.cur,sdrf_fn.new)
			# create new magtab
			t1<-strsplit(mage_dir,"\\.")[[1]]
			t2<-as.numeric(t1[6])
			if(inc==T) t2<-t2+1
			t1[6]<-t2
			magetab_fn<-paste(t1,collapse=".")
			file.rename(mage_dir,magetab_fn)
			mage_fn_new<-file.path(cur_pkgs,magetab_fn)
			createManifestByLevel.2(cur_pkgs,magetab_fn)
			compressDataPackage(cur_pkgs,magetab_fn)
			
			#new_pkg_fn<-list.files(new_pkg,pattern="tar")
			#bk old pkgs and magtab
			setwd(cur_pkgs)
			if(!file.exists("bk")) dir.create("bk")
			file.copy(paste(mage_dir,".tar.gz",sep=""),paste("bk/",mage_dir,".tar.gz",sep=""))
			file.copy(paste(mage_dir,".tar.gz.md5",sep=""),paste("bk/",mage_dir,".tar.gz.md5",sep=""))
			t2<-strsplit(new_pkg_fn[1],"\\.")[[1]][5]
			for(i in 1:3){
				fn<-list.files(cur_pkgs,paste("Level_",i,".",t2,sep=""))
				fn<-fn[grep("tar",fn)]
				for(f1 in fn){
					file.copy(f1,file.path("bk",f1))
					file.remove(f1)
				}
			}
			new_pkg_fn<-new_pkg_fn[-grep("mage",new_pkg_fn)]
			# rm old magtab
			if(inc==T){
				file.remove(file.path(cur_pkgs,paste(mage_dir,".tar.gz",sep="")))
				file.remove(file.path(cur_pkgs,paste(mage_dir,".tar.gz.md5",sep="")))
			}
		}
		#trans new pkgs
		for(fn in new_pkg_fn) file.copy(file.path(new_pkg,fn),file.path(cur_pkgs,fn))
	}
	
update_SDRF_files.2_test<-function(){
	src_sdrf<-"C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.16.0\\jhu-usc.edu_GBM.HumanMethylation27.8.sdrf.txt"
	new_sdrf<-"C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.7\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.7.0\\jhu-usc.edu_GBM.HumanMethylation27.7.sdrf.txt"
	fn<-"c:\\temp\\gbm.sdrf.txt"
	update_SDRF_files.2(src_sdrf,new_sdrf,fn)
}
update_SDRF_files.2<-function(src_sdrf,new_sdrf,fn=NULL){
	dat.src<-read.delim(file=src_sdrf,sep="\t",header=F,stringsAsFactors=F)
	dat.new<-read.delim(file=new_sdrf,sep="\t",header=F,stringsAsFactors=F)
	if(ncol(dat.src)>ncol(dat.new)){
		len<-ncol(dat.src)-ncol(dat.new)
		dat.new2<-matrix(NA,nrow=nrow(dat.new),ncol=len)
		dat.new<-data.frame(dat.new,dat.new2)
	}
	dat.src<-apply(dat.src,1,function(x)paste(x,collapse="\t"))
	dat.new<-apply(dat.new,1,function(x)paste(x,collapse="\t"))
	dat.new<-dat.new[-1]
	dat.new1<-strsplit(dat.new[1],"\t")[[1]]
	sid.new<-dat.new1[length(dat.new1)]
	sid<-paste("Level_1.",strsplit(sid.new,"\\.")[[1]][5],sep="")
	ind<-grep(sid,dat.src)
	if(length(ind)>0) dat.src<-dat.src[-ind]
	
	dat.src<-c(dat.src,dat.new)
	if(is.null(fn)) fn<-src_sdrf
	write(dat.src,file=fn,sep="\n")
}
update_SDRF_files<-function(src_sdrf,new_sdrf,fn=NULL){
	dat.src<-readLines(src_sdrf)
	dat.new<-readLines(new_sdrf)
	dat.new<-dat.new[-1]
	dat.new1<-strsplit(dat.new[1],"\t")[[1]]
	sid.new<-dat.new1[length(dat.new1)]
	sid<-paste("Level_1.",strsplit(sid.new,"\\.")[[1]][5],sep="")
	ind<-grep(sid,dat.src)
	if(length(ind)>0) dat.src<-dat.src[-ind]
	
	dat.src<-c(dat.src,dat.new)
	if(is.null(fn)) fn<-src_sdrf
	write(dat.src,file=fn,sep="\n")
}
merge_SDRF_files<-function(pkg_folders,fn,outdir=NULL){
	if(is.null(outdir))outdir<-"c:\\tcga"
	setwd(outdir)
	dat.all<-NULL
	for(i in 1:length(pkg_folders)){
		dat<-read.table(file=pkg_folders[i],header=F,sep="\t");
		if(is.null(dat.all)){
			dat.all<-dat
		}else{
			dat<-dat[-1,]
			dat.all<-rbind(dat.all,dat)
		}
	}
	write.table(dat.all,file=fn,sep="\t",quote=F,row.names=F,col.names=F)
}
mergePkgUEC<-function(txt=NULL){
	uploadUECRepos(txt)
}
##################
# new data package folder, eg, C:\tcga\repos\jhu-usc.edu_GBM.HumanMethylation27.2
# current data package folder, eg, c:\tcga\GBM
##################
mergeDataPackages.2<-function(txt=NULL,auto=F){
	if(auto==F){
		dlg<-startDialog("Merge Data Packages")
		dlg1<-tkfrm(dlg)
		addTextEntryWidget(dlg1,"Select the new data package folder: ",isFolder=T,name="textEntry1")
		addTextEntryWidget(dlg1,"Select the local data repository folder:",isFolder=T,name="textEntry2")
		addTextEntryWidget(dlg1,"Increase the serial number of mage-tab archive:","YES",withSelectButton=F,name="textEntry3")
		tkgrid(tklabel(dlg,text="  "))
		tkaddfrm(dlg,dlg1)
		endDialog(dlg,c("textEntry1","textEntry2","textEntry3"),pad=T)
	}
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to merge data packages from ",reValue[1]," to ",reValue[2],"\t",date(),"\n"))
	new_pkg<-reValue[1]
	if(!file.exists(new_pkg)) stop("selected file does not exist\n")
	src_pkgs<-reValue[2]
	inc<-F
	if(reValue[3]=="YES") inc<-T
	merge_Packages.2(src_pkgs,new_pkg,inc)
	#tcgaPackage_folder<<-src_pkgs
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Finished. ",date(),"\n"))
}
mergeDataPackages<-function(txt=NULL){
	dlg<-startDialog("Merge Data Packages")
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the new data package folder: ",isFolder=T,name="textEntry1")
	addTextEntryWidget(dlg1,"Select the local data repository folder:",isFolder=T,name="textEntry2")
	addTextEntryWidget(dlg1,"Increase the serial number of mage-tab archive:","YES",withSelectButton=F,name="textEntry3")
	tkgrid(tklabel(dlg,text="  "))
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("textEntry1","textEntry2","textEntry3"),pad=T)
	if(is.null(reValue))return()
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to merge data packages from ",reValue[1]," to ",reValue[2],"\t",date(),"\n"))
	new_pkg<-reValue[1]
	if(!file.exists(new_pkg)) stop("selected file does not exist\n")
	src_pkgs<-reValue[2]
	inc<-F
	if(reValue[3]=="YES") inc<-T
	merge_Packages(src_pkgs,new_pkg,inc)
	tcgaPackage_folder<<-src_pkgs
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Finished. ",date(),"\n"))
}
GBM.6_lvl3_0227<-function(){
	setwd("C:\\tcga\\jhu-usc.edu_GBM.HumanMethylation27.6.0.0")
	lvl2<-read.delim("jhu-usc.edu_GBM.HumanMethylation27.6.lvl-2.TCGA-07-0227-20A-01D-0595-05.txt",sep="\t",header=T,skip=1)
	lvl3<-read.delim("jhu-usc.edu_GBM.HumanMethylation27.6.lvl-3.TCGA-14-1458-01A-01D-0595-05.txt",sep="\t",header=T,skip=1)
	lvl3.mask<-ifelse(is.na(lvl3[,2]),NA,1)
	lvl3.dat<-lvl2[,2]*lvl3.mask
	lvl3[,2]<-lvl3.dat
	write.table(lvl3,file="jhu-usc.edu_GBM.HumanMethylation27.6.lvl-3.TCGA-07-0227-20A-01D-0595-05.txt",sep="\t",row.names=F,quote=F)

}
GBM.7_sdrf<-function(){
	setwd("C:\\tcga\\jhu-usc.edu_GBM.HumanMethylation27.7\\jhu-usc.edu_GBM.HumanMethylation27.Level_1.7.0.0")
	flist<-list.files(pattern=".txt")
	flist<-flist[-49]
	sid<-sapply(flist,function(x)strsplit(x,"lvl-1")[[1]][2])
	sids<-sapply(sid,function(x)strsplit(x,"\\.")[[1]][2])
	create_Mage_TAB_SDRF(pkg_folder,manifest_fd)
}
GBM.8_lvl_1<-function(){
	setwd("C:\\tcga\\jhu-usc.edu_GBM.HumanMethylation27.8\\jhu-usc.edu_GBM.HumanMethylation27.Level_1.8.0.0")
	flist<-list.files(pattern=".txt")
	#flist<-flist[-c("DESCRIPTION.txt","MANIFEST.txt")]
	flist<-flist[c(-1,-32)]
	for(i in 1:length(flist)){
		dat<-read.delim(flist[i],header=T,sep="\t",check.names=F)
		dat<-dat[,c(-3,-4,-6,-7)]
		write.table(dat,file=flist[i],sep="\t",quote=F,row.names=F)
	}
}

update_lvl3_mask<-function(){
	data.dir<-"c:\\tcga"
	setwd(data.dir)
	lvl3msk.fn<-"level3_mask_May25.csv"
	lvl3msk<-read.delim(file=lvl3msk.fn,header=T,row.names=1,sep=",",as.is=T)
	library(mAnnot)
	db<-getData()
	gs<-as.character(humanMeth27k$Symbol)
	names(gs)<-humanMeth27k[,1]
	lvl3msk.new<-merge(lvl3msk,gs,by.x=0,by.y=0)
	lvl3msk.new$SYMBOL <-lvl3msk.new$y
	write.table(lvl3msk.new,file="level3_mask1.csv",quote=F,row.names=F,sep=",")
}
create_lvl1_data_pkg<-function(srcFolder,pkgFolder,descriptFn=NULL,pkgName,toRemove=T){
	pkgFolder<-file.path(pkgFolder,pkgName)
	if(!file.exists(pkgFolder)) dir.create(pkgFolder)
	flists<-list.files(srcFolder,pattern=".txt")
	flists<-flists[grep("lvl-1",flists)]
	if(!is.null(descriptFn)) {
			if(file.exists(descriptFn)){
			options(warn=-1)
			write(readLines(descriptFn),file.path(pkgFolder,"DESCRIPTION.txt"))
			options(warn=1)
		}
	}
	for(fn in flists){
		dat<-readLines(file.path(srcFolder,fn))
		write(dat,file.path(pkgFolder,fn))
		if(toRemove==T) file.remove(file.path(srcFolder,fn))
	}
}

create_lvl2_data_pkg.2<-function(lvl1Folder,lvl2Folder,descriptFn,pvalue_fn=NULL,threshold=0.05){
	if(!file.exists(lvl2Folder)) dir.create(lvl2Folder)
	if(!is.null(pvalue_fn) ){
		create_lvl2_data_pkg(lvl1Folder,lvl2Folder,pvalue_fn,threshold)
	}else{
		flists<-list.files(lvl1Folder,pattern=".txt")
		flists<-flists[grep("usc.edu",flists)]
		flists<-flists[grep("lvl-2",flists)]
		for(fn in flists){
			dat<-readLines(file.path(lvl1Folder,fn))
			write(dat,file.path(lvl2Folder,fn))
		}
	}
	if(!is.null(descriptFn)){
		if(file.exists(descriptFn)){
			options(warn=-1)
			write(readLines(descriptFn),file.path(lvl2Folder,"DESCRIPTION.txt"))
			options(warn=1)
		}
	}
}
create_lvl2_data_pkg_test<-function(){
	lvl1Folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\KIRC\\jhu-usc.edu_KIRC.HumanMethylation450.Level_1.70.0.0"
	lvl2Folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\KIRC\\jhu-usc.edu_KIRC.HumanMethylation450.Level_2.70.0.0"
	mdat<-get(load(file="C:\\temp\\IDAT\\meth450k\\processed\\5613914085\\5613914085_idat.rda"))
	pvalue<-getPvalues(mdat)
	create_lvl2_data_pkg.2(lvl1Folder,lvl2Folder,pvalue)
}
create_lvl2_data_pkg.2<-function(lvl1Folder,lvl2Folder,pvalue,threshold=0.05){
	pvalue<-as.data.frame(pvalue)
	index<-row.names(pvalue)
	nn<-names(pvalue)
	flists<-list.files(lvl1Folder,pattern=".txt")
	flists<-flists[grep("usc.edu",flists)]
	if(!file.exists(lvl2Folder)) dir.create(lvl2Folder)
	for( fn in flists){
		cat(fn,"\n")
		sid<-strsplit(fn,"lvl-1")[[1]][2]
		sid<-strsplit(sid,"\\.")[[1]][2]
		hd1<-paste("Hybridization REF",sid,sid,sid,sep="\t")
		hd2<-c("Composite Element REF\tBeta_Value\tMethylated_Signal_Intensity (M)\tUn-Methylated_Signal_Intensity (U)")
		if(sum(nn==sid)==0){
			stop(paste("Pvalue Files does not contain the sample ",sid,"\n"))
		}
		pv<-pvalue[,sid]
		lvl_2_mask<-ifelse(pv<threshold,1,NA) #checked 
		dat.lvl1<-read.delim(file.path(lvl1Folder,fn),sep="\t",header=F,stringsAsFactors=F,as.is=T)
		hd<-(dat.lvl1[2,])
		dat.lvl1<-dat.lvl1[c(-1,-2),]
		dat.lvl1<-dat.lvl1[index,] #sorting
		
		M<-dat.lvl1[,grep("\\(M\\)",hd)]
		U<-dat.lvl1[,grep("\\(U\\)",hd)]
		beta1<-M/(M+U)*lvl_2_mask
		dat.lvl2<-data.frame(rownames(dat.lvl1),beta1,M,U)
		fn_lvl2<-gsub("lvl-1","lvl-2",fn)
		write(hd1,file=file.path(lvl2Folder,fn_lvl2))
		write(hd2,file=file.path(lvl2Folder,fn_lvl2),append=T)
		write.table(dat.lvl2,file=file.path(lvl2Folder,fn_lvl2),quote=F,row.names=F,col.names=F,append=T,sep="\t")
	}
}
create_lvl2_data_pkg_test<-function(){
	pvalue_fn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\TCGA Batch 38 Data Package\\TCGA Batch 38 P-values.xls"
	lvl1Folder<-"C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.8\\jhu-usc.edu_GBM.HumanMethylation27.Level_1.8.0.0"
	lvl2Folder<-"c:\\temp\\test"
	create_lvl2_data_pkg(lvl1Folder,pvalue_fn,lvl2Folder)
}
create_lvl2_data_pkg<-function(lvl1Folder,lvl2Folder,pvalue_fn,threshold=0.05){
	pvalue<-readDataFile.2(pvalue_fn)
	index<-row.names(pvalue)
	nn<-names(pvalue)
	nn<-gsub("\\.","-",nn);names(pvalue)<-nn 
	flists<-list.files(lvl1Folder,pattern=".txt")
	flists<-flists[grep("usc.edu",flists)]
	if(!file.exists(lvl2Folder)) dir.create(lvl2Folder)
	for( fn in flists){
		cat(fn,"\n")
		sid<-strsplit(fn,"lvl-1")[[1]][2]
		sid<-strsplit(sid,"\\.")[[1]][2]
		hd1<-paste("Hybridization REF",sid,sid,sid,sep="\t")
		hd2<-c("Composite Element REF\tBeta_Value\tMethylated_Signal_Intensity (M)\tUn-Methylated_Signal_Intensity (U)")
		if(sum(nn==sid)==0){
			stop(paste("Pvalue Files does not contain the sample ",sid,"\n"))
		}
		pv<-pvalue[,sid]
		lvl_2_mask<-ifelse(pv<threshold,1,NA) #checked 
		dat.lvl1<-readDataFile.2(file.path(lvl1Folder,fn),header1=F,isNum=F)
		hd<-(dat.lvl1[2,])
		dat.lvl1<-dat.lvl1[c(-1,-2),]
		dat.lvl1<-dat.lvl1[index,] #sorting
		
		M<-round(as.numeric(dat.lvl1[,grep("\\(M\\)",hd)])) #add rounding on 04/04/2011
		#M<-as.numeric(dat.lvl1[,1])
		U<-round(as.numeric(dat.lvl1[,grep("\\(U\\)",hd)]))
		#U<-as.numeric(dat.lvl1[,4])
		beta1<-M/(M+U)*lvl_2_mask
		dat.lvl2<-data.frame(rownames(dat.lvl1),beta1,M,U)
		fn_lvl2<-gsub("lvl-1","lvl-2",fn)
		write(hd1,file=file.path(lvl2Folder,fn_lvl2))
		write(hd2,file=file.path(lvl2Folder,fn_lvl2),append=T)
		write.table(dat.lvl2,file=file.path(lvl2Folder,fn_lvl2),quote=F,row.names=F,col.names=F,append=T,sep="\t")
	}
}
create_lvl3_data.2_test<-function(){
	lvl2Folder<-"C:\\temp\\test\\meth27k\\tcga\\STAD\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0\\jhu-usc.edu_STAD.HumanMethylation27.Level_2.1.0.0"
	lvl3Folder<-"C:\\temp\\test\\meth27k\\tcga\\STAD\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0\\jhu-usc.edu_STAD.HumanMethylation27.Level_3.1.0.0"
	dat<-create_lvl3_data.2(lvl2Folder,lvl3Folder,platform="meth27k")
	
	lvl2Folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0\\jhu-usc.edu_LAML.HumanMethylation450.Level_2.1.0.0"
	lvl3Folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0\\jhu-usc.edu_LAML.HumanMethylation450.Level_3.1.0.0"
	dat<-create_lvl3_data.2(lvl2Folder,lvl3Folder,platform="meth450k")
	
	lvl2Folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\COAD\\jhu-usc.edu_COAD.HumanMethylation450.Level_2.1.0.0"
	lvl3Folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\COAD\\jhu-usc.edu_COAD.HumanMethylation450.Level_3.1.0.0"
	dat<-create_lvl3_data.2(lvl2Folder,lvl3Folder,platform="meth450k")
}
create_lvl3_data.2<-function(lvl2Folder,lvl3Folder,platform="meth27k"){
	if(!file.exists(lvl3Folder))dir.create(lvl3Folder)
	lvl3mask<-NULL;HumanMethylation.adf<-NULL
	if(platform=="meth27k"){
		lvl3mask<-get(data(lvl3mask))
		HumanMethylation.adf<-get(data(HumanMethylation27.adf))
	}
	else if(platform=="meth450k"){
		lvl3mask<-get(data(meth450lvl3mask))
		HumanMethylation.adf<-get(data(HumanMethylation450.adf))[,c("ILMNID","CHR","GENESYMBOL","MAPINFO","UCSC_REFGENE_NAME")]
		names(HumanMethylation.adf)<-c("IlmnID","Chr","SYMBOL","MapInfo","RefgeneUCSC")
	}
	else stop("unknon platform from create lvl3 data\n")
	
	ind<-row.names(lvl3mask)
	row.names(HumanMethylation.adf)<-HumanMethylation.adf[,1]
	HumanMethylation.adf<-HumanMethylation.adf[ind,]
	flist<-list.files(lvl2Folder)
	flist<-flist[grep("usc.edu",flist)]
	flist<-flist[grep("lvl-2",flist)]
	hd2<-"Composite Element REF\tChromosome\tGene_Symbol\tGenomic_Coordinate\tBeta_Value"
	dat.all<-NULL
	for(fn in flist){
		cat(fn,"\n")
		dat<-read.table(file=file.path(lvl2Folder,fn),header=F,sep="\t",as.is=T)
		hd1<-dat[1,]
		sid<-as.character(hd1[1,2])
		hd1<-paste("Hybridization REF",sid,sid,sid,sid,sep="\t")
		dat<-dat[c(-1,-2),]
		row.names(dat)<-dat[,1]
		dat<-dat[ind,]
		dat.lvl3<-ifelse(lvl3mask$mask_lvl3==0,dat[,2],NA)
		if(platform=="meth27k"){
			#dat.lvl3<-data.frame(pid=dat[,1],chr=HumanMethylation.adf$Chr,gs=HumanMethylation.adf$SYMBOL,coord=HumanMethylation.adf$MapInfo,Beta_Value=dat.lvl3)
			dat.lvl3<-data.frame(pid=dat[,1],Beta_Value=dat.lvl3,gs=HumanMethylation.adf$SYMBOL,chr=HumanMethylation.adf$Chr,coord=HumanMethylation.adf$MapInfo)
		}else{
			dat.lvl3<-data.frame(pid=dat[,1],chr=HumanMethylation.adf$Chr,gs=HumanMethylation.adf$SYMBOL,coord=HumanMethylation.adf$MapInfo,refgene=HumanMethylation.adf$RefgeneUCSC,Beta_Value=dat.lvl3)
			hd1<-paste("Hybridization REF",sid,sid,sid,sid,sid,sep="\t")
			hd2<-"Composite Element REF\tChromosome\tGene_Symbol\tGenomic_Coordinate\tRefgene_Name_UCSC\tBeta_Value"
		}
		fn_lvl3<-gsub("lvl-2","lvl-3",fn)
		write(hd1,file=file.path(lvl3Folder,fn_lvl3))
		write(hd2,file=file.path(lvl3Folder,fn_lvl3),append=T)
		write.table(dat.lvl3,file=file.path(lvl3Folder,fn_lvl3),row.names=F,col.names=F,quote=F,append=T,sep="\t")
		if(is.null(dat.all))dat.all<-data.frame(dat.lvl3)
		else dat.all<-data.frame(dat.all,dat.lvl3[,1])
	}
	return(dat.all)
}

create_lvl3_data.2.1<-function(lvl2Folder,lvl3Folder,platform="meth27k"){
	if(!file.exists(lvl3Folder))dir.create(lvl3Folder)
	lvl3mask<-NULL;HumanMethylation.adf<-NULL
	if(platform=="meth27k"){
		lvl3mask<-get(data(lvl3mask))
		HumanMethylation.adf<-get(data(HumanMethylation27.adf))
	}
	else if(platform=="meth450k"){
		lvl3mask<-get(data(meth450lvl3mask))
		HumanMethylation.adf<-get(data(HumanMethylation450.adf))[,c("ILMNID","CHR","GENESYMBOL","MAPINFO")]
		names(HumanMethylation.adf)<-c("IlmnID","Chr","SYMBOL","MapInfo")
	}
	else stop("unknon platform from create lvl3 data\n")
	
	ind<-row.names(lvl3mask)
	row.names(HumanMethylation.adf)<-HumanMethylation.adf[,1]
	HumanMethylation.adf<-HumanMethylation.adf[ind,]
	flist<-list.files(lvl2Folder)
	flist<-flist[grep("usc.edu",flist)]
	flist<-flist[grep("lvl-2",flist)]
	hd2<-"Composite Element REF\tChromosome\tGene_Symbol\tGenomic_Coordinate\tBeta_Value"
	dat<-NULL
	for(fn in flist){
		cat(fn,"\n")
		dat<-read.table(file=file.path(lvl2Folder,fn),header=F,sep="\t",as.is=T)
		hd1<-dat[1,]
		sid<-as.character(hd1[1,2])
		hd1<-paste("Hybridization REF",sid,sid,sid,sid,sep="\t")
		dat<-dat[c(-1,-2),]
		row.names(dat)<-dat[,1]
		dat<-dat[ind,]
		dat.lvl3<-ifelse(lvl3mask$mask_lvl3==0,dat[,2],NA)
		dat.lvl3<-data.frame(pid=dat[,1],chr=HumanMethylation.adf$Chr,gs=HumanMethylation.adf$SYMBOL,coord=HumanMethylation.adf$MapInfo,Beta_Value=dat.lvl3)
		fn_lvl3<-gsub("lvl-2","lvl-3",fn)
		write(hd1,file=file.path(lvl3Folder,fn_lvl3))
		write(hd2,file=file.path(lvl3Folder,fn_lvl3),append=T)
		write.table(dat.lvl3,file=file.path(lvl3Folder,fn_lvl3),row.names=F,col.names=F,quote=F,append=T,sep="\t")
		if(is.null(dat))dat<-data.frame(dat.lvl3)
		else dat<-data.frame(dat,dat.lvl3)
	}
	return(dat)
}


create_lvl3_data<-function(lvl2Folder,lvl3Folder){
	require(methPipe)
	print(data(lvl3mask))
	ind<-order(row.names(lvl3mask))
	flist<-list.files(lvl2Folder)
	flist<-flist[grep("usc.edu",flist)]
	flist<-flist[grep("lvl-2",flist)]
	hd2<-"Composite Element REF\tBeta_Value\tGene_Symbol\tChromosome\tGenomic_Coordinate"
	for(fn in flist){
		cat(fn,"\n")
		dat<-read.table(file=file.path(lvl2Folder,fn),header=F,sep="\t",as.is=T)
		hd1<-dat[1,]
		sid<-as.character(hd1[1,2])
		hd1<-paste("Hybridization REF",sid,sid,sid,sid,sep="\t")
		dat<-dat[c(-1,-2),]
		dat<-dat[ind,]
		dat.lvl3<-as.numeric(ifelse(lvl3mask$mask_lvl3==0,dat[,2],NA))
		dat.lvl3<-data.frame(pid=dat[,1],Beta_Value=dat.lvl3,gs=lvl3mask$SYMBOL,chr=lvl3mask$Chr,coord=lvl3mask$MapInfo)
		#names(dat.lvl3)<-hd2
		fn_lvl3<-gsub("lvl-2","lvl-3",fn)
		write(hd1,file=file.path(lvl3Folder,fn_lvl3))
		write(hd2,file=file.path(lvl3Folder,fn_lvl3),append=T)
		write.table(dat.lvl3,file=file.path(lvl3Folder,fn_lvl3),row.names=F,col.names=F,quote=F,append=T,sep="\t")
	}
}
update_lvl3_data_run<-function(){
	#READ
	dataFolder.READ<-c("")
	update_lvl3_data(dataFolder.READ)
	#GBM
	dataFolder.GBM<-c("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.6\\jhu-usc.edu_GBM.HumanMethylation27.Level_3.6.0.0")
	dataFolder.GBM<-c("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.8\\jhu-usc.edu_GBM.HumanMethylation27.Level_3.8.0.0")
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.9.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.9.0")
	dataFolder.GBM<-c("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1\\jhu-usc.edu_GBM.HumanMethylation27.Level_3.1.2.0")
	create_lvl3_data("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1\\jhu-usc.edu_GBM.HumanMethylation27.Level_2.1.2.0","C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1\\jhu-usc.edu_GBM.HumanMethylation27.Level_3.1.3.0")
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1","jhu-usc.edu_GBM.HumanMethylation27.Level_3.1.3.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1","jhu-usc.edu_GBM.HumanMethylation27.Level_3.1.3.0")
	pkg_validate("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1")
	merge_Packages("c:\\tcga\\GBM","C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.1")
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.2","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.2","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.3","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.3","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.4","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.4","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.5","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.5","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.10.0")
	
	update_lvl3_data(dataFolder.GBM)
	#LUSC
	dataFolder.LUSC<-c("C:\\tcga\\jhu-usc.edu_LUSC.HumanMethylation27.2\\jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.0.0")
	update_lvl3_data(dataFolder.LUSC)
	dataFolder.OV<-c("C:\\tcga\\jhu-usc.edu_OV.HumanMethylation27.10\\jhu-usc.edu_OV.HumanMethylation27.Level_3.10.0.0",
			"C:\\tcga\\jhu-usc.edu_OV.HumanMethylation27.10\\jhu-usc.edu_OV.HumanMethylation27.Level_3.10.0.0")
	#OV
	dataFolder.OV<-c("C:\\tcga\\jhu-usc.edu_OV.HumanMethylation27.11\\jhu-usc.edu_OV.HumanMethylation27.Level_3.11.0.0")
	dataFolder.OV<-c("C:\\tcga\\repos\\jhu-usc.edu_OV.HumanMethylation27.12\\jhu-usc.edu_OV.HumanMethylation27.Level_3.12.1.0")
	update_lvl3_data(dataFolder.OV)
	#LUSC
	dataFolder.LUSC<-c("C:\\tcga\\LUSC\\bk\\jhu-usc.edu_LUSC.HumanMethylation27.1\\jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.2.0")
	update_lvl3_data(dataFolder.LUSC)
	#COAD
	dataFolder<-c("C:\\tcga\\repos\\jhu-usc.edu_COAD.HumanMethylation27.2\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.2.1.0",
			"C:\\tcga\\repos\\jhu-usc.edu_COAD.HumanMethylation27.5\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.5.1.0")
	update_lvl3_data(dataFolder)
}
update_lvl3_data<-function(dataFolder=NULL){
	require(mAnnot)
	db<-getData()
	gs<-as.character(humanMeth27k$Symbol)
	names(gs)<-humanMeth27k[,1]
	if(is.null(dataFolder)){
	dataFolder<-c("C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.1\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.1.0.0",
			"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.2\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.2.0.0",
			"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.3\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.3.0.0",
			"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.4\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.4.0.0",
			"C:\\tcga\\jhu-usc.edu_COAD.HumanMethylation27.5\\jhu-usc.edu_COAD.HumanMethylation27.Level_3.5.0.0"
			)
		}
	for(i in 1:length(dataFolder)){
		setwd(dataFolder[i])
		flist<-list.files(pattern="lvl-3");
		for(j in 1:length(flist)){
			dat<-read.delim(file=flist[j],header=F,sep="\t",row.names=1,as.is=T)
			header1<-dat[1,]
			header2<-dat[2,]
			dat<-dat[c(-1,-2),]
			ind<-names(gs)
			dat<-dat[ind,]
			dat$V3<-gs
			#dat[ind,3]<-gs
			write.table(header1,file=flist[j],row.names=T,sep="\t",col.names=F,quote=F)
			write.table(header2,file=flist[j],row.names=T,sep="\t",append=T,col.names=F,quote=F)
			write.table(dat,file=flist[j],row.names=T,sep="\t",append=T,col.names=F,quote=F)
		}
	}
	require(tcltk)
	for(i in 1:length(dataFolder)){
		fd<-tclvalue(tclfile.tail(dataFolder[i]))
		pkg_folder<-tclvalue(tclfile.dir(dataFolder[i]))
		createManifestByLevel.2(pkg_folder,fd)
		compressDataPackage(pkg_folder,fd)
	}
}

create_IDF_file_run<-function(){
	fn<-"jhu-usc.edu_KIRC.HumanMethylation27.1.0.0"
	md<-"c:\\temp"
	ct<-"Kidney Renal Cell Carcinoma"
	create_IDF_file(fn,md,ct)
	fn<-"jhu-usc.edu_LUAD.HumanMethylation27.1.0.0"
	ct<-"Lung Adenocarcinoma"
	create_IDF_file(fn,md,ct)
}

##############
# June 9
#############
pkg_lvl_1_filter_run<-function(){
	sourceDir<-"C:\\tcga\\jhu-usc.edu_OV.HumanMethylation27.9.0.0"
	destDir<-"C:\\tcga\\jhu-usc.edu_OV.HumanMethylation27.9\\jhu-usc.edu_OV.HumanMethylation27.Level_1.9.0.0"
	pkg_lvl_1_filter(sourceDir,destDir)
	
	sourceDir<-"C:\\tcga\\GBM\\va\\jhu-usc.edu_GBM.HumanMethylaiton27.8.0.0"
	destDir<-"C:\\tcga\\GBM\\va\\jhu-usc.edu_GBM.HumanMethylation27.Level_1.8.0.0"
	destDir<-"C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.7\\jhu-usc.edu_GBM.HumanMethylation27.Level_1.7.0.0"
	pkg_lvl_1_filter(destDir)
	update_pkg_compression(destDir)
}
update_pkg_compression<-function(dir1){
	require(tcltk)
	pkgFolder<-tclvalue(tclfile.dir(dir1))
	lvl<-tclvalue(tclfile.tail(dir1))
	createManifestByLevel.2(pkgFolder,lvl)
	compressDataPackage(pkgFolder,lvl)
}
pkg_lvl_1_filter<-function(sourceDir, destDir=NULL){
	if(is.null(destDir)) destDir=sourceDir
	setwd(sourceDir)
	flist<-list.files(pattern="lvl-1")
	for(i in 1:length(flist)){
		dat<-read.delim(file=flist[i],sep="\t",header=F,as.is=T,row.names=1)
		names(dat)<-dat[2,]
#		col.new<-c("U_Number_Beads", "Negative_Control_Grn_STDERR", 
#				"Negative_Control_Red_STDERR", "U_STDERR", "M_Number_Beads", 
#				"Un-Methylated_Signal_Intensity (U)", "M_STDERR", 
#				"Negative_Control_Grn_Avg_Intensity", "Methylated_Signal_Intensity (M)", 
#				"Negative_Control_Red_Avg_Intensity", "Detection_P_Value")
		col.new<-c("Methylated_Signal_Intensity (M)","Un-Methylated_Signal_Intensity (U)","Detection_P_Value","Negative_Control_Red_Avg_Intensity","Negative_Control_Grn_Avg_Intensity","Negative_Control_Grn_STDERR","Negative_Control_Red_STDERR")
		dat.new<-dat[,col.new]
		write.table(dat.new,file=file.path(destDir,flist[i]),row.names=T,col.names=F,quote=F,sep="\t")
	}
}

#################
# June 10
################
pkg_validate_run<-function(){
	pkgFolder<-"C:\\tcga\\jhu-usc.edu_KIRC.HumanMethylation27.1"
	pkgFolder<-"C:\\tcga\\repos\\jhu-usc.edu_OV.HumanMethylation27.9"
	pkgFolder<-"C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.8"
	pkgFolder<-"C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.6"
	pkgFolder<-"C:\\tcga\\repos\\jhu-usc.edu_KIRC.HumanMethylation27.1"
	pkg_validate(pkgFolder)
}
pkg_validate<-function(pkgFolder){
	setwd(pkgFolder)
	#idf
	dlist<-list.files(pattern="mage-tab")
	dlist<-dlist[-grep("tar",dlist)]
	sid<-NULL
	for(i in 1:length(dlist)){
		setwd(file.path(pkgFolder,dlist[i]))
		pkgType<-strsplit(strsplit(dlist[i],"_")[[1]][2],"\\.")[[1]][1]
		flist<-list.files(pattern="idf")
		idf<-readLines(flist)
		sdrf.fn<-list.files(pattern="sdrf")
		idf.sdrf<-idf[grep("SDRF Files",idf)]
		isdrf<-strsplit(idf.sdrf,"\t")[[1]][2]
		cat(paste("SDRF Files in IDF files is ",isdrf," \n",sep=""))
		if(isdrf!=sdrf.fn){
			cat("sdrf")
			stop("")
		}
		idf.ov<-grep("ovarian",idf)
		if(length(idf.ov)!=0){
			cat("It's a ovarian data package\n")
			if(pkgType!="OV"){
				stop("it's not a OV pkg\n");
			}
		}
		
		idf.type<-grep(pkgType,idf)
		if(length(idf.type)==0){
			cat(paste(pkgType,"is missing in idf file\n"),sep="")
			stop("")
		}
		#adf
		flist<-list.files(pattern="adf")
		adf<-read.delim(flist,sep="\t",header=T,row.names=1)
		if(adf["cg00763679",1]!="SEPT2"){
			stop("cg00763679\n")
		}
		if(adf["cg00720072",1]!="MARCH5"){
			stop("cg00720072\n")
		}
		if(nrow(adf)!=27578){
			stop("number of adf \n")
		}
		#sdrf
		sdrf<-read.delim(sdrf.fn,sep="\t",skip=1,header=F)
		sid<-sdrf[,1]
		cat(paste("number of total sid in sdrf is: ",length(sid),"\n",sep=""))
	}
	checkDP<-function(lvl,dir1,sid.1){
		#DESCRIPTION
		dp<-readLines("DESCRIPTION.txt")
#		dp1<-dp[grep["HumanMethylation27",dp]]
#		if(!is.null(dp1)){
#			pkn<-strsplit(dp1,"archive")[[1]][2]
#			cat(paste("pkg name in description is: ",pkn,"\n",sep=""))
#			arch.num<-strsplit(dir1,lvl)[[1]][2]
#			arch.num.1<-strsplit(dp[1],"HumanMethylation27")[[1]][2]
#			if(arch.num!=arch.num.1){
#				stop("archive number of pkg does not match the archive number described in description file\n")
#			}
#		}
		s0227<-0
		sidl<-NULL
		#ind<-grep("TCGA-07-0227-20A",dp)
		ind<-grep("normal",dp)
		if(length(ind)!=0){
			sidl<-dp[ind]
			s0227<-1
			sidl<-strsplit(sidl,"normal")[[1]][1] #"TCGA-07-0227-20A")[[1]][1]
		}else{
			sidl<-dp[grep("archive contains",dp)]
			sidl<-strsplit(sidl,"Batch")[[1]][1]
		}
		
		sidl<-unlist(strsplit(sidl," "))
		sid.num<-c()
		for(i in 1:length(sidl)){
			options(warn=-1)
			sid.n<-as.numeric(sidl[i])
			options(warn=1)
			if(!is.na(sid.n) & sidl[i]==as.character(sid.n)){
				sid.num<-c(sid.num,sid.n)
			}
		}
		sid.total<-sum(sid.num)+s0227
		if(sid.total!=length(sid.1)){
			stop(paste("sid numbers in description of ",lvl,"is ",length(sid.1),", does not match the total number sids ",sid.total,".\n",sep=""))
		}	
	}
	checkLevel<-function(lvl){
		lvl.fn<-paste("lvl-",strsplit(lvl,"_")[[1]][2],sep="")
		setwd(pkgFolder)
		dlist<-list.files(pattern=lvl)
		dlist<-dlist[-grep("tar",dlist)]
		for(i in 1:length(dlist)){
			setwd(file.path(pkgFolder,dlist[i]))
			flist<-list.files(pattern="lvl")
			sid.1<-sapply(flist,function(x)strsplit(strsplit(x,lvl.fn)[[1]][2],"\\.")[[1]][2])
			if(length(sid[sid.1])!=length(sid.1)){
				stop(paste("sid in ",lvl," is not all included in sdrf sids\n",sep=""))
			}
			dat<-readLines(flist[1])
			if(length(dat)!=27580){
				stop(paste("rnow in ",lvl," is not 27580\n",sep=""))
			}
			if(lvl=="Level_3"){
				dat<-read.delim(flist[1],header=T,row.name=1,sep="\t")
				if(dat["cg00720072",2]!="MARCH5"){
					stop("cg00720072 in lvl3 is not MARCH5\n")
				}
			}
			if(file.exists("DESCRIPTION.txt"))checkDP(lvl,dlist[i],sid.1)
		}
	}
	#lvl_1
	checkLevel("Level_1")
	#lvl_2
	checkLevel("Level_2")
	#lvl_3
	checkLevel("Level_3")
	cat("> post-validation checking is done.\n")
}
rename_pkg_files<-function(){
	pkgFolder<-"C:\\tcga\\repos\\jhu-usc.edu_KIRC.HumanMethylation27.1.0.0"
	setwd(pkgFolder)
	flist<-list.files(pattern="lvl")
	for(i in 1:length(flist)){
		dat<-readLines(flist[i])
		dat<-sapply(dat,function(x)paste(x,"\n",sep=""))
		fn<-gsub("KIRC","KIRP",flist[i])
		zz<-file(fn)
		cat(dat,file=zz)
		close(zz)
	}
}

#################
# Sep 17, 2010
#################
pkg_Level3_data_run<-function(){
	outdir<-"c:\\tcga\\repos\\lvlJune18"
	data.dir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\UPDATED LEVEL 3 AND README FOR TCGA GBM-OV DATA PACKAGES"
	setwd(data.dir)
	dlist<-list.files()
	for(i in 1:length(dlist)){
		setwd(file.path(data.dir,dlist[i]))
		fn<-list.files(pattern=".csv")
		pkgName<-substr(fn,1,(nchar(fn)-4))
		pkg_Level3_data(fn,outdir,pkgName,ftype="csv")
		setwd(file.path(data.dir,dlist[i]))
		fn2<-list.files(pattern=".txt")
		descript<-readLines(fn2)
		ind<-c(grep("LEVEL 1",descript),grep("LEVEL 2",descript))
		descript<-descript[-ind]
		fn.descript<-file.path(outdir,pkgName,"DESCRIPTION.txt")
		write.table(data.frame(descript),fn.descript,row.names=F,quote=F,col.names=F)
	}
	for(i in 1:length(dlist)){
		setwd(file.path(data.dir,dlist[i]))
		fn<-list.files(pattern=".csv")
		pkgName<-substr(fn,1,(nchar(fn)-4))
		createManifestByLevel.2(outdir,pkgName)
		compressDataPackage(outdir,pkgName)
	}
}

pkg_Level3_data<-function(fn,outdir,pkgName,ttype=NULL,version=NULL,ftype=""){
	require(gdata)
	dat<-NULL
	if(ftype=="csv"){
		dat<-read.delim(fn,header=T,as.is=T,row.names=1,sep=",")
	}else{
		dat<-read.xls(fn,header=T,as.is=T,check.names=T,skip=0,row.names=1)
	}
	dat<-dat[-1,]
	names(dat)<-gsub("\\.","-",names(dat))
	cat(paste("The size of the file is: ",nrow(dat),"x",ncol(dat),"\n"))
	gs<-dat[,1]
	chr<-dat[,2]
	coord<-dat[,3]
	dat<-dat[,c(-1,-2,-3)]
	setwd(outdir)
	dir.create(pkgName)
	setwd(pkgName)
	sid<-names(dat)
	ttype<-strsplit(strsplit(pkgName,"_")[[1]][2],"\\.")[[1]][1]
	sn<-strsplit(strsplit(pkgName,"_")[[1]][3],"\\.")[[1]][2]
	fileNames<-paste("jhu-usc.edu_",ttype,".HumanMethylation27.",sn,".lvl-3.",sid,".txt",sep="")
	hd2<-c("Composite Element REF","Beta_Value","Gene_Symbol","Chromosome","Genomic_Coordinate")
	for(i in 1:ncol(dat)){
		dat.lvl3<-data.frame(row.names(dat), dat[,i],gs,chr,coord)
		header<-c("Hybridization REF",sid[i],sid[i],sid[i],sid[i])
		write.table(t(data.frame(header)),file=fileNames[i],sep="\t",col.names=F,row.names=F,quote=F)
		write.table(t(data.frame(hd2)),file=fileNames[i],sep="\t",col.names=F,row.names=F,quote=F,append=T)
		write.table(dat.lvl3,file=fileNames[i],sep="\t",col.names=F,row.names=F,quote=F,append=T)
	}
}

update_Mage_tab_file_run<-function(){
	update_Mage_tab_file("C:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.9.0\\jhu-usc.edu_GBM.HumanMethylation27.8.sdrf.txt","jhu-usc.edu_GBM.HumanMethylation27.Level_3.6.0.0","jhu-usc.edu_GBM.HumanMethylation27.Level_3.6.1.0")
	createManifestByLevel.2("c:\\tcga\\GBM","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.9.0")
	compressDataPackage("c:\\tcga\\GBM","jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.9.0")
	
	update_Mage_tab_file("C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.6.0\\jhu-usc.edu_LUSC.HumanMethylation27.2.sdrf.txt","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.2.0","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.3.0")
	createManifestByLevel.2("c:\\tcga\\LUSC","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.6.0")
	compressDataPackage("c:\\tcga\\LUSC","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.6.0")
	for(i in 7:8){
		update_Mage_tab_file("c:\\tcga\\OV\\jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.3.0\\jhu-usc.edu_OV.HumanMethylation27.2.sdrf.txt",paste("jhu-usc.edu_OV.HumanMethylation27.Level_3.",i,".1.0",sep=""),paste("jhu-usc.edu_OV.HumanMethylation27.Level_3.",i,".2.0",sep=""))
	}
	for(i in 9:11){
		update_Mage_tab_file("c:\\tcga\\OV\\jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.3.0\\jhu-usc.edu_OV.HumanMethylation27.2.sdrf.txt",paste("jhu-usc.edu_OV.HumanMethylation27.Level_3.",i,".0.0",sep=""),paste("jhu-usc.edu_OV.HumanMethylation27.Level_3.",i,".1.0",sep=""))
	}
	createManifestByLevel.2("c:\\tcga\\OV","jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.3.0")
	compressDataPackage("c:\\tcga\\OV","jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.3.0")
}
update_Mage_tab_file<-function(mfn,pkg_old,pkg_new){
	dat<-read.delim(mfn,header=F,sep="\t")
	dat<-apply(dat,1,function(x)gsub(pkg_old,pkg_new,x))
	write.table(t(dat),file=mfn,row.names=F,col.names=F,sep="\t",quote=F)
}
gsub_files_run<-function(){
	gsub_files("Beta Value","Beta_Value","C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1\\jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.3.0")
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.3.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.3.0")
	createManifestByLevel.2("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.1.0")
	compressDataPackage("C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1","jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.1.0")
	
	gsub_files("Beta_Value","Beta Value","C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.3.0")
	gsub_files("Beta_Value","Beta Value","C:\\tcga\\LUSC\\jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.1.0")
	pkg<-"jhu-usc.edu_LUSC.HumanMethylation27.Level_3.2.2.0"
	pkg<-"jhu-usc.edu_LUSC.HumanMethylation27.Level_3.1.3.0"
	pkgFolder<-"c:\\tcga\\LUSC"

	pkg<-"jhu-usc.edu_LUSC.HumanMethylation27.mage-tab.1.6.0"
	
	
	#LUSC
	pkgFolder<-"C:\\tcga\\repos\\jhu-usc.edu_LUSC.HumanMethylation27.1"
	pkg<-"jhu-usc.edu_LUSC.HumanMethylation27.Level_2.1.3.0"
	pkg<-"jhu-usc.edu_LUSC.HumanMethylation27.Level_1.1.3.0"
	
	#GBM
	pkgFolder<-"C:\\tcga\\GBM\\"
	
	gsub_files("Beta Value","Beta_Value",paste(pkgFolder,pkg,sep=""))
	createManifestByLevel.2(pkgFolder,pkg)
	compressDataPackage(pkgFolder,pkg)
	
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_3.6.0.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_2.6.0.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_1.6.0.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_3.8.0.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_2.8.0.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_1.8.0.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.Level_1.7.1.0"
	pkg<-"jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.9.0"

	#OV
	pkgFolder<-"C:\\tcga\\OV\\test\\"
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.3.0"
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.Level_3.7.2.0"
	gsub_files("-563-","-0563-","C:\\tcga\\OV\\test\\jhu-usc.edu_OV.HumanMethylation27.Level_3.7.2.0")
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.Level_3.11.1.0"
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.Level_3.10.0.0"
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.Level_3.9.0.0"
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.Level_3.8.2.0"
	pkg<-"jhu-usc.edu_OV.HumanMethylation27.Level_3.7.2.0"
	
}
gsub_files<-function(src,target,folder){
	setwd(folder)
	flist<-list.files()
	for(i in 1:length(flist)){
		dat<-readLines(flist[i])
		dat.new<-gsub(src,target,dat)
		dat.new<-paste(dat.new,"\n",sep="")
		zz<-file(flist[i])
		cat(dat.new,file=zz,sep="")
		close(zz)
	}
}
####################
# June 25
######################
rename_files_run<-function(){
	folder<-"C:\\tcga\\OV\\test\\jhu-usc.edu_OV.HumanMethylation27.Level_3.7.2.0"
	rename_files(folder,"563","0563")
}
rename_files<-function(folder,src,target){
	setwd(folder)
	flist<-list.files()
	for(i in 1:length(flist)){
		name.new<-gsub(src,target,flist[i])
		file.rename(flist[i],name.new)
	}
}

###########################
#########################
ViewPkgManifest<-function(txt=NULL){
	dlg<-startDialog("Package Manifest")
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the Package Manifest:","c:/tcga/package.txt",isFolder=F,name=pkgManifest)
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("pkgManifest"))
	if(is.null(reValue))return()
	dat<-read.table(file=reValue[1],sep="\t",header=F)
	openTableView(dat)
}
openTableView_test<-function(){
	dat<-matrix(1:9,nrow=3)
	openTableView(dat)
}
openTableView<-function(dat=NULL){
	tclRequire("Tktable")
	datCol<-ncol(dat)
	datRow<-nrow(dat)
	datVar<-NULL
	for(i in 0:(datCol-1)){
		for(j in 0:(datRow-1)){
			.Tcl(paste("set datVar(",i,",",j,") ",dat[i+1,j+1],sep=""))
		}
	}
	t1<-startDialog("Package Manifest")
	tkgrid(tklabel(t1,text="Package Manifest"))
	tlable<-tkwidget(t1,"table",variable="datVar",cols=datCol,rows=datRow,titlerows="1",colwidth="25",selectmode="extended",background="white")
	tkgrid(tlable)
	endDialog(t1,pad=F,pack=T)
}
openTableView.2<-function(dat=NULL,maxRow=25){
	tclRequire("Tktable")
	datCol<-ncol(dat)
	datRow<-nrow(dat)
	if(datRow>(maxRow-1)) { datRow<-maxRow }
	else { maxRow<-datRow }
	datVar<-NULL
	setDatVar<-function(curRowPos=0){
		dat1<-dat[(curRowPos+1):(curRowPos+maxRow),]
		dat1[1,]<-dat[1,]
		for(i in 0:(datCol-1)){
			for(j in curRowPos:(curRowPos+maxRow)){
				.Tcl(paste("set datVar(",i,",",j,") ",dat1[i+1,j+1],sep=""))
			}
		}
	}
	setDatVar()
	t1<-startDialog("Package Manifest")
	tkgrid(tklabel(t1,text=" "),tklabel(t1,text="Package Manifest"))
	tlable<-tkwidget(t1,"table",variable="datVar",cols=datCol,rows=datRow,titlerows="1",colwidth="25",selectmode="extended",background="white")
	tkgrid(tklabel(t1,text=" "),tlable,tklabel(t1,text=" "))
	tkgrid(tklabel(t1,text=" "))
	nextPage<-function(){
		curRowPos<-curRowPos + maxRow
		if(curRowPos>nrow(dat)) curRowPos<-nrow(dat)
		setDatVar(curRowPos)
	}
	prePage<-function(){
		curRowPos<-curRowPos - maxRow
		if(curRowRow<0) curRowPos<-0
		setDatVar(curRowPos)
	}
	dlg1<-tkfrm(t1)
	nextButton<-tkbutton(dlg1,text="  Next  ",command=nextPage)
	preButton<-tkbutton(dlg1,text="Previous",command=prePage)
	tkgrid(nextButton,preButton)
	tkaddfrm(t1,dlg1)
	tkgrid(tklabel(t1,text=" "))
}
UpdatePkgManifest<-function(txt=NULL){
	if(!is.null(txt)) tkinsert(txt,"end",">Start to update the package manifest\n")
	dlg<-startDialog("Update Package Manifest")
	tkgrid(tklabel(dlg,text=" "))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the Package Folder:","",name="pkgFolder")
	addTextEntryWidget(dlg1,"Select the Package Manifest:","c:/tcga/package.txt",isFolder=F,name="pkgManifest")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("pkgFolder","pkgManifest"))
	pkgFolder<-reValue[1]
	fn<-reValue[2]
	create_pkg_manifest(pkgFolder,txt,fn)
	if(!is.null(txt)) tkinsert(txt,"end",">Finished updating manifest")
}

###
# Nov 29, 2010
###
createBatchPkgs_test<-function(){
	library(rapid.pro);require(Biobase)
	platemapFn<-"c:\\tcga\\others\\arraymapping\\platemap.txt"
	batchPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data\\batches"
	arrayPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out"
	createBatchPkgs(platemapFn,batchPath,arrayPath)
	
	batchPath<-"c:\\temp\\test\\meth27k\\batches"
	procPath<-"c:\\temp\\test\\meth27k\\processed"
	platemapFn<-"c:\\temp\\test\\meth27k\\arraymapping\\batch_01.csv"
	createBatchPkgs(batchPath=batchPath,procPath=procPath,platemapFn=platemapFn,isTCGA=F)
	
	procPath<-"c:\\temp\\test2\\meth27k\\processed"
	batchPath<-"c:\\temp\\test2\\meth27k\\batches2"
	createBatchPkgs(batchPath=batchPath,procPath=procPath,platemapFn=platemapFn,dataType="M-Set")
	
	platemapFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\tcga73_ITE47\\platemap.txt"
	batchPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\tcga73_ITE47\\batches"
	procPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\tcga73_ITE47\\processed"
}
createBatchPkgs_test2<-function(){
	batchPath<-"/home/uec-02/shared/production/methylation/meth450k/batches"
	procPath<-"/home/uec-02/shared/production/methylation/meth450k/processed"
	platemapFn<-"/home/uec-02/shared/production/methylation/meth450k/arraymapping/platemap2.txt"
	createBatchPkgs(batchPath=batchPath,procPath,platemapFn,isTCGA=T)
	
	batchPath<-"/home/feipan/pipeline/meth27k/batches"
	procPath<-"/home/feipan/pipeline/meth27k/processed"
	platemapFn<-"/home/feipan/pipeline/meth27k/arraymapping/platemap.txt"
	createBatchPkgs(batchPath,procPath,platemapFn)
	createBatchPkgs(batchPath,procPath,platemapFn,isTCGA=F)
	
	batchPath<-"C:\\temp\\IDAT\\meth450k\\batches"
	procPath<-"C:\\temp\\IDAT\\meth450k\\processed"
	platemapFn<-"C:\\temp\\IDAT\\meth450k\\arraymapping\\platemap.txt"
	platemapFn<-"C:\\temp\\IDAT\\meth450k\\arraymapping\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv"
	createBatchPkgs(batchPath,procPath,platemapFn,inc=T)
	createBatchPkgs(batchPath,procPath,platemapFn,inc=F)
}
createBatchPkgs<-function(batchPath,procPath,platemapFn,arrayPath=NULL,toSave=T,inc=T,isTCGA=T,sn=NULL,platform="meth27k"){
	if(!file.exists(platemapFn)) return()
	platemap<-readPlateMap(platemapFn)
	batches<-split(platemap,platemap$Batch_Number)
	sn2<-sn;batch.proc<-c();lvl_sn<-NULL
	for(batch in batches){
		if(inc==F)cat("working on batch ",batch$Batch_Number[1],"\n")
		chips<-unique(batch$chip_id)
		chips.exist<-c();mdat<-NULL
		for(chip in chips){
			if(file.exists(file.path(procPath,chip))) {
				idatFn<-list.files(file.path(procPath,chip),patt=".rda")[1] 
				if(file.exists(file.path(procPath,chip,idatFn)))chips.exist<-c(chips.exist,chip)
				else cat(paste("The array ",chip, " from batch ",batch$Batch_Number[1]," does not contain the processed idat/mdat data file.\n"))
			}else cat(paste("The array ",chip," from batch",batch$Batch_Number[1],"is missing\n"))
		}
		
		if(length(chips.exist)>0){
			batch.n<-batch$Batch_Number[1]
			if(is.null(sn2)) sn<-batch.n
			batchPath1<-file.path(batchPath,sn)
			if(!file.exists(batchPath1)) dir.create(batchPath1)
			batchPath2<-batchPath1
			if(length(unique(batch$cancer_Type))>1) cat(paste("Multiple cancer types for the batch ",batch.n,"..check.\n"))
			if(isTCGA==T) {
				if(!is.null(sn2))sn<-strsplit(sn,"\\.")[[1]][4]
				cancerType<-unique(batch$cancer_Type); if(length(cancerType)>1)stop(paste("The TCGA batch ",batch.n," has multiple cancer type: ",paste(cancerType,collapse=",")),"\n",sep="")
				pl.name<-".HumanMethylation27.";if(platform=="meth450k")pl.name<-".HumanMethylation450."
				batchPath2<-file.path(batchPath1,paste("jhu-usc.edu_",cancerType,pl.name,sn,".0.0",sep="")); 
				if(!file.exists(batchPath2))dir.create(batchPath2)
				if(!is.null(batch$sn_lvl1)& !is.null(batch$sn_lvl2)& !is.null(batch$sn_lvl3)) lvl_sn<-list(lvl.1=batch$sn_lvl1,lvl.2=batch$sn_lvl2,lvl.3=batch$sn_lvl3)
			}
			if(inc==T){idatFn<-list.files(batchPath2,patt=".rda");if(length(idatFn)>0)next}
			else {unlink(batchPath2,T);dir.create(batchPath2)}
			for(i in 1:length(chips.exist)){
				chip<-chips.exist[i]
				cat("process array",chip,"\n")
				dataPath<-file.path(procPath,chip)
				mdatFN<-list.files(dataPath,patt=".rda");if(length(mdatFN)!=1)stop("There are multiple mdat/idat files\n")
				mdat2<-get(load(file=file.path(dataPath,mdatFN)))
				if(is.null(mdat)) mdat<-mdat2
				else mdat<-mergeDataSet(mdat2,mdat)
			}
			if(toSave==T){
				save(mdat,file=file.path(batchPath2,paste(batch.n,".rdata",sep="")))	
			}
			if(!is.null(arrayPath)){
				samp<-readSampleMapping(arrayPath)
				if(class(mdat)=="MethyLumiSet") mdat<-mapSampleIDAT(mdat,samp)
				else mdat<-renameSampleWithMap(mdat,samp)
			}
			saveBatchCSV.2(mdat,batchPath2,isTCGA,batch$sampleID)
			datFns<-processedCSVFileNames()
			packingBatchPkg(batchPath2,batchPath1,sn,datFns["U"],datFns["Use"],datFns["Un"],datFns["M"],datFns["Mse"],datFns["Mn"],datFns["Rctr"],datFns["Gctr"],datFns["Pv"],datFns["Bv"],platform=platform,isTCGA=isTCGA,sn=lvl_sn)	
			batch.proc<-c(batch.proc,batch.n)
		}
	}
	return(batch.proc)
}

createBatchPkgs.1<-function(batchPath,procPath,platemapFn,dataType="TXT",toSave=T,inc=T,isTCGA=T,sn=NULL,platform="meth27k"){
	if(!file.exists(platemapFn)) return()
	platemap<-readPlateMap(platemapFn)
	batches<-split(platemap,platemap$Batch_Number)
	sn2<-sn;batch.proc<-c();lvl_sn<-NULL
	for(batch in batches){
		if(inc==F)cat("working on batch ",batch$Batch_Number[1],"\n")
		chips<-unique(batch$chip_id)
		chips.exist<-c();mdat<-NULL
		for(chip in chips){
			if(file.exists(file.path(procPath,chip))) {
				idatFn<-list.files(file.path(procPath,chip),patt=".rda")[1] 
				if(file.exists(file.path(procPath,chip,idatFn)))chips.exist<-c(chips.exist,chip)
				else cat(paste("The array ",chip, " from batch ",batch$Batch_Number[1]," does not contain the processed idat/mdat data file.\n"))
			}else cat(paste("The array ",chip," from batch",batch$Batch_Number[1],"is missing\n"))
		}
		
		if(length(chips.exist)>0){
			batch.n<-batch$Batch_Number[1]
			if(is.null(sn2)) sn<-batch.n
			batchPath1<-file.path(batchPath,sn)
			if(!file.exists(batchPath1)) dir.create(batchPath1)
			batchPath2<-batchPath1
			if(length(unique(batch$cancer_Type))>1) cat(paste("Multiple cancer types for the batch ",batch.n,"..check.\n"))
			if(isTCGA==T) {
				if(!is.null(sn2))sn<-strsplit(sn,"\\.")[[1]][4]
				cancerType<-unique(batch$cancer_Type); if(length(cancerType)>1)stop(paste("The TCGA batch ",batch.n," has multiple cancer type: ",paste(cancerType,collapse=",")),"\n",sep="")
				pl.name<-".HumanMethylation27.";if(platform=="meth450k")pl.name<-".HumanMethylation450."
				batchPath2<-file.path(batchPath1,paste("jhu-usc.edu_",cancerType,pl.name,sn,".0.0",sep="")); 
				if(!file.exists(batchPath2))dir.create(batchPath2)
				if(!is.null(batch$sn_lvl1)& !is.null(batch$sn_lvl2)& !is.null(batch$sn_lvl3)) lvl_sn<-list(lvl.1=batch$sn_lvl1,lvl.2=batch$sn_lvl2,lvl.3=batch$sn_lvl3)
			}
			if(inc==T){idatFn<-list.files(batchPath2,patt=".rda");if(length(idatFn)>0)next}
			else {unlink(batchPath2,T);dir.create(batchPath2)}
			for(i in 1:length(chips.exist)){
				chip<-chips.exist[i]
				cat("process array",chip,"\n")
				dataPath<-file.path(procPath,chip)
				mdatFN<-list.files(dataPath,patt=".rda");if(length(mdatFN)!=1)stop("There are multiple mdat/idat files\n")
				mdat2<-get(load(file=file.path(dataPath,mdatFN)))
				if(is.null(mdat)) mdat<-mdat2
				else mdat<-mergeDataSet(mdat,mdat2)
			}
			if(toSave==T){
				save(mdat,file=file.path(batchPath2,paste(batch.n,".rdata",sep="")))	
			}
			saveBatchCSV.2(mdat,batchPath2,isTCGA,batch$sampleID)
			datFns<-processedCSVFileNames()
			packingBatchPkg(batchPath2,batchPath1,sn,datFns["U"],datFns["Use"],datFns["Un"],datFns["M"],datFns["Mse"],datFns["Mn"],datFns["Rctr"],datFns["Gctr"],datFns["Pv"],datFns["Bv"],platform=platform,isTCGA=isTCGA,sn=lvl_sn)	
			batch.proc<-c(batch.proc,batch.n)
		}
	}
	return(batch.proc)
}

updateBatches_test<-function(){
	batchPath<-"C:\\temp\\IDAT\\meth450k\\batches"
	tcgaPath<-"C:\\temp\\IDAT\\meth450k\\tcga"
	arrayPath<-"c:\\temp\\IDAT\\meth450k\\arraymapping"
	ar<-c(5775446078,5640277011)
	updateBatches(ar,arrayPath,batchPath,tcgaPath)
}
updateBatches<-function(ar,arrayPath,batchPath=NULL,tcgaPath=NULL){
	if(length(ar)<1|!file.exists(file.path(arrayPath,"sample_mapping.txt")))return()
	plate.batch<-c()
	if(!is.null(batchPath)){
		platemapFn<-file.path(arrayPath,"platemap.txt")
		if(file.exists(platemapFn)){
			map<-readPlateMap(platemapFn)
			pmap<-merge(map,data.frame(ar),by.x="chip_id",by.y=1)
			plate.batch<-unique(pmap$Batch_Number)
			for(batch in plate.batch){
				batch2<-file.path(batchPath,batch);
				if(file.exists(batch2))unlink(batch2,T)}
		}
	}
	if(!is.null(tcgaPath)&length(plate.batch)>0){
		packagemapFn<-file.path(arrayPath,"packagemap.txt")
		if(file.exists(packagemapFn)){
			map<-readPackageMap(packagemapFn)
			pmap<-merge(map,data.frame(plate.batch),by.x="Batch_Number",by.y=1)
			pkgs<-unique(pmap$Package_lvl.1)
			for(pkg in pkgs){
				pkg1<-gsub(".Level_1","",pkg)
				cancerType<-strsplit(strsplit(pkg1,"edu_")[[1]][2],"\\.")[[1]][1]
				pkg2<-file.path(tcgaPath,cancerType,pkg1)
				if(file.exists(pkg2))unlink(pkg2,T)
			}
		}
	}
}
getNegControl_test<-function(){
	load("C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\5543207013_mdat.rdata")
	negR<-getNegControl(mdata,"red")
	negG<-getNegControl(mdata,"red")
}
getNegControl<-function(cData,channel){
	ctrNeg<-NULL
	if(class(cData)=="MethyLumiQC"){
		data(NegCtlCode)
		ctl_code<-ctl_code[,1]
		fdat<-featureData(idat@QC)@data$Address
		cdat.m<-cData@assayData$methylated
		cdat.u<-cData@assayData$unmethylated
		ind<-is.element(fdat,ctl_code)
		cdat.neg.m<-rowMeans(cdat.m[ind,],na.rm=T)
		cdat.neg.u<-rowMeans(cdat.u[ind,],na.rm=T)
		ctrNeg<-list(M=cdat.neg.m,U=cdt.neg.u)
	}else{
		cNegData<-getNegData(cData)
		if(channel=="red"){
			for(ctr in cNegData){
				if(is.null(ctrNeg))ctrNeg<-data.frame(ctr$R)
				else ctrNeg<-cbind(ctrNeg,data.frame(ctr$R))
			}
		}else{
			for(ctr in cNegData){
				if(is.null(ctrNeg))ctrNeg<-data.frame(ctr$G)
				else ctrNeg<-cbind(ctrNeg,data.frame(ctr$G))
			}
		}
		names(ctrNeg)<-names(cNegData)
	}
	rn<-paste("NEGATIVE_",row.names(ctrNeg),sep="")
	row.names(ctrNeg)<-rn
	return(ctrNeg)
}
getIDATctrData_test<-function(){
	require(Biobase)
	load(file="c:\\temp\\IDAT\\processed\\5640277011_idat.rda")
	cdat<-getIDATctrData(idat)
}
getIDATctrData<-function(idat){
	cData<-list()
	idat.qc<-idat@QC
	if(!is.null(idat.qc)){
		ctr.m<-idat.qc@assayData$methylated
		ctr.u<-idat.qc@assayData$unmethylated
		ctr.n<-idat.qc@assayData$NBeads
		ctr.annot<-featureData(idat.qc)@data
		for(i in 1:ncol(ctr.m)){
			dat<-data.frame(M=ctr.m[,i],U=ctr.u[,i],NBeads=ctr.n[,i],ctr.annot)
			cData<-c(cData,list(dat))
		}
	}
	return(cData)
}
saveBatchCSV.2_test<-function(){
	#meth27k
	print(load(file="c:\\temp\\test\\meth27k\\processed\\5543207015\\mdat.rdata"))
	saveBatchCSV.2(mData,outPath="c:\\temp\\test",T)
	print(load(file="c:\\temp\\test\\meth27k\\batches\\batch_01\\batch_01.rdata"))
	saveBatchCSV.2(mdat,outPath="c:\\temp\\test",T)
	
	#meth450k
	print(load(file="c:\\temp\\IDAT\\meth450k\\processed\\6042308117\\6042308117_idat.rda"))
	saveBatchCSV.2(idat,"c:\\temp\\IDAT\\meth450k\\processed\\6042308117\\",isTCGA=F)
	print(load(file="C:\\temp\\IDAT\\meth450k\\batches\\batch_test\\batch_1003.rdata"))
	saveBatchCSV.2(mdat,"C:\\temp\\IDAT\\meth450k\\batches\\batch_test",isTCGA=F)
}
saveBatchCSV.2<-function(dat,outPath,isTCGA=T,sampleID=NULL,toFilter=T){
	require(Biobase)
	if(toFilter==T)dat<-filterDataSet(dat,isTCGA,sampleID)
	if(class(dat)=="MethyLumiSet"){
		if(toFilter==T){
			if(!is.null(dat@QC)) dat@QC<-filterDataSet(dat@QC,isTCGA,sampleID)
		}
		header2<-ifelse(isTCGA==T,F,T)
		saveIDATcsv(dat,outPath,with.header2=header2)
	}else if(class(dat)=="methData"){
		if(toFilter==T)dat<-filterMdatQCData(dat,isTCGA,sampleID)
		sampleID<-getSampID(dat)
		if(length(sampleID)>0){
			negData<-getNegData(dat)
			if(!all(names(negData)==sampleID)) stop("sample names mismatch\n") 
			saveMDAT2CSV(dat,outPath)
			saveNegData2CSV(dat,outPath)
		}
	}else{
		cat("Unknown data type from saveBatchCSV\n")
		return()
	}
	savePhenoDataCSV(dat,outPath)
	saveBetaLevel3CSV(dat,outPath)
}
saveBatchCSV.2.1<-function(dat,outPath,isTCGA=T,sampleID=NULL,toFilter=T){
	require(Biobase)
	if(toFilter==T)dat<-filterDataSet(dat,isTCGA,sampleID)
	if(class(dat)=="MethyLumiSet"){
		if(toFilter==T){
			if(!is.null(dat@QC)) dat@QC<-filterDataSet(dat@QC,isTCGA,sampleID)
		}
		header2<-ifelse(isTCGA==T,F,T)
		saveIDATcsv(dat,outPath,with.header2=header2)
	}else if(class(dat)=="methData"){
		sampleID<-getSampID(dat)
		if(length(sampleID)>0){
			negData<-getNegData(dat)
			if(!all(names(negData)==sampleID)) stop("sample names mismatch\n") 
			saveMDAT2CSV(dat,outPath)
			saveNegData2CSV(negData,outPath)
		}
	}else{
		cat("Unknown data type from saveBatchCSV\n")
		return()
	}
	savePhenoDataCSV(dat,outPath)
}
saveMDAT2CSV_test<-function(){
	outPath<-"C:\\temp\\test\\meth27k\\processed\\4841860025"
	print(load(file=file.path(outPath,"mdat.rdata")))
	saveMDAT2CSV(mData,outPath)
	saveMDAT2CSV(mData,"c:\\temp",T)
}
saveMDAT2CSV<-function(mdat,outPath,with.header2=F){
	datFns<-processedCSVFileNames()
	bv<-getBeta(mdat);pv<-getPvalue(mdat);M<-getM(mdat);U<-getU(mdat);Mn<-getMn(mdat);Un<-getUn(mdat);Me<-getMe(mdat);Ue<-getUe(mdat)
	if(with.header2==T){
		pdat<-as(phenoData(mdat),"data.frame")
		well_pos<-as.character(pdat$barcodes)
		if(!is.null(well_pos)){
			well_pos<-t(well_pos)
			bv<-rbind(well_pos,as.matrix(bv))
			M<-rbind(well_pos,as.matrix(M))
			U<-rbind(well_pos,as.matrix(U))
			if(!is.null(Mn))Mn<-rbind(well_pos,as.matrix(Mn))
			if(!is.null(Un))Un<-rbind(well_pos,as.matrix(Un))
			if(!is.null(Me))Me<-rbind(well_pos,as.matrix(Me))
			if(!is.null(Ue))Ue<-rbind(well_pos,as.matrix(Ue))
			pv<-rbind(well_pos,as.matrix(pv))
		}
	}
	write.csv(bv,file=file.path(outPath,datFns["Bv"]),quote=F)
	write.csv(pv,file=file.path(outPath,datFns["Pv"]),quote=F)
	write.csv(M,file=file.path(outPath,datFns["M"]),quote=F)
	write.csv(U,file=file.path(outPath,datFns["U"]),quote=F)
	if(!is.null(Mn))write.csv(Mn,file=file.path(outPath,datFns["Mn"]),quote=F)
	if(!is.null(Un))write.csv(Un,file=file.path(outPath,datFns["Un"]),quote=F)
	if(!is.null(Me))write.csv(Me,file=file.path(outPath,datFns["Mse"]),quote=F)
	if(!is.null(Ue))write.csv(Ue,file=file.path(outPath,datFns["Use"]),quote=F)
}
saveMDAT2CSV.1.2<-function(mdat,outPath,with.header2=F){
	datFns<-processedCSVFileNames()
	bv<-getBeta(mdat);pv<-getPvalue(mdat);M<-getM(mdat);U<-getU(mdat);Mn<-getMn(mdat);Un<-getUn(mdat);Me<-getMe(mdat);Ue<-getUe(mdat)
	if(with.header2==T){
		pdat<-as(phenoData(mdat),"data.frame")
		well_pos<-as.character(pdat$barcodes)
		if(!is.null(well_pos)){
			well_pos<-t(well_pos)
			bv<-rbind(well_position=well_pos,bv)
			M<-rbind(well_position=well_pos,M)
			U<-rbind(well_position=well_pos,U)
			if(!is.null(Mn))Mn<-rbind(well_position=well_pos,Mn)
			if(!is.null(Un))Un<-rbind(well_position=well_pos,Un)
			if(!is.null(Me))Me<-rbind(well_position=well_pos,Me)
			if(!is.null(Ue))Ue<-rbind(well_position=well_pos,Ue)
			pv<-rbind(well_position=well_pos,pv)
		}
	}
	write.csv(bv,file=file.path(outPath,datFns["Bv"]),quote=F)
	write.csv(pv,file=file.path(outPath,datFns["Pv"]),quote=F)
	write.csv(M,file=file.path(outPath,datFns["M"]),quote=F)
	write.csv(U,file=file.path(outPath,datFns["U"]),quote=F)
	if(!is.null(Mn))write.csv(Mn,file=file.path(outPath,datFns["Mn"]),quote=F)
	if(!is.null(Un))write.csv(Un,file=file.path(outPath,datFns["Un"]),quote=F)
	if(!is.null(Me))write.csv(Me,file=file.path(outPath,datFns["Mse"]),quote=F)
	if(!is.null(Ue))write.csv(Ue,file=file.path(outPath,datFns["Use"]),quote=F)
}

saveMDAT2CSV.1<-function(mdat,outPath){
	datFns<-processedCSVFileNames()
	bv<-getBeta(mdat);pv<-getPvalue(mdat);M<-getM(mdat);U<-getU(mdat);Mn<-getMn(mdat);Un<-getUn(mdat);Me<-getMe(mdat);Ue<-getUe(mdat)
	write.csv(bv,file=file.path(outPath,datFns["Bv"]),quote=F)
	write.csv(pv,file=file.path(outPath,datFns["Pv"]),quote=F)
	write.csv(M,file=file.path(outPath,datFns["M"]),quote=F)
	write.csv(U,file=file.path(outPath,datFns["U"]),quote=F)
	if(!is.null(Mn))write.csv(Mn,file=file.path(outPath,datFns["Mn"]),quote=F)
	if(!is.null(Un))write.csv(Un,file=file.path(outPath,datFns["Un"]),quote=F)
	if(!is.null(Me))write.csv(Me,file=file.path(outPath,datFns["Mse"]),quote=F)
	if(!is.null(Ue))write.csv(Ue,file=file.path(outPath,datFns["Use"]),quote=F)
}
saveNegData2CSV_test<-function(){
	outPath<-"C:\\temp\\test\\meth27k\\processed\\4841860025"
	print(load(file=file.path(outPath,"mdat.rdata")))
	saveNegData2CSV(mData,outPath)
	saveNegData2CSV(mData,"c:\\temp",T)
}
#saveNegData2CSV<-function(mdat,outPath,with.header2=F){
#	if(length(negdat)<1)return()
#	negdat<-getNegData(mdat)
#	datFns<-processedCSVFileNames()
#	dat.R<-data.frame(negdat[[1]]$R);dat.G<-data.frame(negdat[[1]]$G)
#	if(length(negdat)>=2){
#		for(i in 2:length(negdat)){
#			dat.R<-data.frame(dat.R,negdat[[i]]$R)
#			dat.G<-data.frame(dat.G,negdat[[i]]$G)
#		}
#	}
#	if(with.header2==T){
#		sample.names<-names(negdat)
#		pdat<-as(phenoData(mdat),"data.frame")
#		well_pos<-as.character(pdat$barcodes)
#		if(!is.null(well_pos)){
#			well_pos<-t(well_pos)
#			dat.R<-rbind(well_pos,as.matrix(dat.R))
#			dat.G<-rbind(well_pos,as.matrix(dat.G))
#		}
#	}
#	len<-nrow(dat.R)
#	row.names(dat.R)<-paste(row.names(dat.R),1:len,sep="");names(dat.R)<-names(negdat)
#	row.names(dat.G)<-paste(row.names(dat.G),1:len,sep="");names(dat.G)<-names(negdat)
#	write.csv(dat.R,file=file.path(outPath,datFns["Rctr"]),quote=F)
#	write.csv(dat.G,file=file.path(outPath,datFns["Gctr"]),quote=F)
#}

saveNegData2CSV<-function(mdat,outPath,with.header2=F){
	negdat<-getNegData(mdat)
	if(length(negdat)<1)return()
	datFns<-processedCSVFileNames()
	dat.R<-data.frame(negdat[[1]]$R);dat.G<-data.frame(negdat[[1]]$G)
	if(length(negdat)>=2){
		for(i in 2:length(negdat)){
			dat.R<-data.frame(dat.R,negdat[[i]]$R)
			dat.G<-data.frame(dat.G,negdat[[i]]$G)
		}
	}
	len<-nrow(dat.R)
	row.names(dat.R)<-paste("NEGATIVE.",1:len,sep="");names(dat.R)<-names(negdat)
	row.names(dat.G)<-paste("NEGATIVE.",1:len,sep="");names(dat.G)<-names(negdat)
	if(with.header2==T){
		sample.names<-names(negdat)
		pdat<-as(phenoData(mdat),"data.frame")
		well_pos<-as.character(pdat$barcodes)
		if(!is.null(well_pos)){
			well_pos<-t(well_pos)
			dat.R<-rbind(well_pos,as.matrix(dat.R))
			dat.G<-rbind(well_pos,as.matrix(dat.G))
		}
	}
	write.csv(dat.R,file=file.path(outPath,datFns["Rctr"]),quote=F)
	write.csv(dat.G,file=file.path(outPath,datFns["Gctr"]),quote=F)
}

saveNegData2CSV.1<-function(negdat,outPath){
	if(length(negdat)<1)return()
	datFns<-processedCSVFileNames()
	dat.R<-data.frame(negdat[[1]]$R);dat.G<-data.frame(negdat[[1]]$G)
	if(length(negdat)>=2){
		for(i in 2:length(negdat)){
				dat.R<-data.frame(dat.R,negdat[[i]]$R)
				dat.G<-data.frame(dat.G,negdat[[i]]$G)
		}
	}
	len<-nrow(dat.R)
	row.names(dat.R)<-paste("NEGATIVE.",1:len,sep="");names(dat.R)<-names(negdat)
	row.names(dat.G)<-paste("NEGATIVE.",1:len,sep="");names(dat.G)<-names(negdat)
	write.csv(dat.R,file=file.path(outPath,datFns["Rctr"]),quote=F)
	write.csv(dat.G,file=file.path(outPath,datFns["Gctr"]),quote=F)
}
filterMdatQCData<-function(mdat,isTCGA=T,sampleID=NULL){
	if(is.null(mdat@QC))stop("QC data is not available, from filterMdatQCData\n")
	cdat<-getCData(mdat)
	negdat<-getNegData(mdat)
	if(isTCGA==T){
		ind<-grep("TCGA",names(cdat))
		cdat<-cdat[ind]
		negdat<-negdat[ind]
	}
	if(!is.null(sampleID)){
		sid<-sampleID[!is.na(sampleID)]
		if(length(sid)>0){
			ind<-is.element(names(cdat),sid)
			cdat<-cdat[ind]
			negdat<-negdat[ind]
		}
	}
	setCData(mdat)<-cdat
	setNegData(mdat)<-negdat
	return(mdat)
}
filterDataSet_test<-function(){
	print(load(file="c:\\temp\\test3\\meth27k\\processed\\4841860025\\4841860025_idat.rda"))
	idat<-fileterDataSet(idat,T)
	idat2<-filterDataSet(idat,F)
	sampleID<-c("TCGA-19-1791-01A-01D-0595-05","TCGA-19-0957-01C-01D-0595-05",NA,"TCGA-0227")
	idat2<-filterDataSet(idat,T,sampleID)
}
filterDataSet<-function(dat,isTCGA=T,sampleID=NULL){
	elemNames<-assayDataElementNames(dat)
	for(elemName in elemNames){
		dat1<-assayDataElement(dat,elemName)
		if(isTCGA==T){
			ind<-grepl("TCGA",dimnames(dat1)[[2]])
			dat1<-dat1[,ind]
		}
		if(!is.null(sampleID)){
			sid<-sampleID[!is.na(sampleID)]
			if(length(sid)>0){
				ind<-is.element(dimnames(dat1)[[2]],sid)
				dat1<-dat1[,ind]
				sid.missing<-sid[!is.element(sid,dimnames(dat1)[[2]])]
				if(length(sid.missing)>0) cat("The following mapped samples are missing:",paste(sid.missing,collapse=","),"\n");t
			}
		}
		dat<-assayDataElementReplace(dat,elemName,dat1)
	}
	return(dat)
}
filterDataSet.1<-function(dat,isTCGA=T){
	elemNames<-assayDataElementNames(dat)
	for(elemName in elemNames){
		dat1<-assayDataElement(dat,elemName)
		ind<-grep("TCGA",dimnames(dat1)[[2]])
		if(length(ind)>0){
			if(isTCGA==T) dat1<-dat1[,ind]
			else  dat1<-dat1[,-ind]
		}else if(isTCGA==T) {
			ind<-1:ncol(dat1)
			dat1<-dat1[,-ind]
		}
		
		dat<-assayDataElementReplace(dat,elemName,dat1)
	}
	return(dat)
}
saveBatchCSV<-function(dat,datPath,isTCGA=T,pcut=0.05){
	datFns<-processedCSVFileNames()
	for(i in 1:length(dat)){
		dat1<-dat[[i]]
		if(!is.null(dat1)) {
			#row.names(dat1)<-dat1[,1]
			ind<-grep("TCGA",names(dat[[i]]))
			if(isTCGA==T){
				if(length(ind)>0){
					dat1<-dat1[,ind]
					write.table(dat1,file=file.path(datPath,datFns[names(dat)[i]]),sep=",",row.names=T,quote=F)	
				}
			}else {
				if(length(ind)<ncol(dat1)){
					if(length(ind)>0)dat1<-dat1[,-ind]
					write.table(dat1,file=file.path(datPath,datFns[names(dat)[i]]),sep=",",row.names=T,quote=F)
				}
			}
		}	
	}
	if(isTCGA==F){
		# create betavalue_lvl2 data
		bv<-dat[["Bv"]];pv<-dat[["Pv"]];#row.names(bv)<-bv[,1];row.names(pv)<-pv[,1];bv<-bv[,-1];pv<-pv[,-1]
		pv<-pv[row.names(bv),];pv<-pv[,order(names(pv))];bv<-bv[,order(names(bv))]
		ind<-grep("TCGA",names(bv))
		if(length(ind)>0){
			bv<-bv[,-ind];pv<-pv[,-ind]
		}
		if(ncol(bv)>0){
			if(!all(names(pv)==names(bv))) {
				bv.nm<-gsub("Beta$","",names(bv));pv.nm<-gsub("Pvalue$","",names(pv))
				if(!all(bv.nm==pv.nm))stop("col names of Bv and Pv don't match\n")
			}
			if(!all(row.names(pv)==row.names(bv))) stop("row names of Bv and Pv don't match\n")
			bv.mask<-ifelse(pv<pcut,1,NA);bv2<-bv*bv.mask
			names(bv2)<-names(bv);row.names(bv2)<-row.names(bv)
			write.table(bv2,file=file.path(datPath,"BetaValues(lvl-2).csv"),sep=",",row.names=T,quote=F)
		}
	}
}

readPlateMap_test<-function(){
	plateFn<-"c:\\tcga\\others\\arraymapping\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	platemap<-readPlateMap(plateFn)
	plateFn<-"c:\\tcga\\others\\arraymapping\\meth450\\jhu-usc.edu_HNSC.HumanMethylation450.1.0.0.csv"
	platemap<-readPlateMap(plateFn)
	plateFn<-"c:\\tcga\\others\\arraymapping\\meth450\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv"
	platemap<-readPlateMap(plateFn)
}
readPlateMap<-function(platemapFn,sep="\t"){
	platemap<-NULL
	if(length(grep(".csv",filetail(platemapFn)))>=1)platemap<-read.delim(file=platemapFn,sep=",",header=T,stringsAsFactors=F,as.is=T)
	else platemap<-read.delim(file=platemapFn,sep="\t",header=T,as.is=T,stringsAsFactors=F)
	pm.name<-strsplit(filetail(platemapFn),"\\.")[[1]][1]
	ind<-grep("batch",tolower(names(platemap)))
	if(length(ind)==1)batch<-platemap[,ind]
	else if(length(ind)==0) batch<-rep(pm.name,length=nrow(platemap))
	else stop("There are more one batch field, stopped.\n")
	ind<-grep("chip_id|Infinium.Barcode",names(platemap))
	if(length(ind)!=1)stop("Array ID is unknown, from readPlateMap\n ")
	chipBarcode<-platemap[,ind]
	if(length(grep("_",chipBarcode[1]))>0)chipBarcode<-sapply(chipBarcode,function(x)strsplit(x,"_")[[1]][1])
	cancerType<-NA
	ind<-grep("abbreviation",tolower(names(platemap)))
	if(length(ind)>0)cancerType<-platemap[,ind]
	sampleID<-NA
	ind<-grep("sample|Sample_ID",tolower(names(platemap)))
	if(length(ind)>0)sampleID<-platemap[,ind]
	platemap<-data.frame(chip_id=chipBarcode,Batch_Number=batch,cancer_Type=cancerType,sampleID=sampleID)
	return(platemap)
}
readPlateMap.1.1<-function(platemapFn,sep="\t"){
	platemap<-NULL
	if(length(grep(".csv",filetail(platemapFn)))>=1)platemap<-read.delim(file=platemapFn,sep=",",header=T,as.is=T)
	else platemap<-read.delim(file=platemapFn,sep="\t",header=T,as.is=T)
	pm.name<-strsplit(filetail(platemapFn),"\\.")[[1]][1]
	ind<-grep("batch",tolower(names(platemap)))
	if(length(ind)==1)batch<-platemap[,ind]
	else if(length(ind)==0) batch<-rep(pm.name,length=nrow(platemap))
	else stop("There are more one batch field, stopped.\n")
	ind<-grep("chip_id|Infinium.Barcode",names(platemap))
	if(length(ind)!=1)stop("Array ID is unknown, from readPlateMap\n ")
	chipBarcode<-platemap[,ind]
	if(length(grep("_",chipBarcode[1]))>0)chipBarcode<-sapply(chipBarcode,function(x)strsplit(x,"_")[[1]][1])
	cancerType<-NA
	ind<-grep("abbreviation",tolower(names(platemap)))
	if(length(ind)>0)cancerType<-platemap[,ind]
	platemap<-data.frame(chip_id=chipBarcode,Batch_Number=batch,cancer_Type=cancerType)
	return(platemap)
}
readPlateMap.1<-function(platemapFn,sep="\t"){
	platemap<-NULL
	if(length(grep(".csv",filetail(platemapFn)))>=1)platemap<-read.delim(file=platemapFn,sep=",",header=T,as.is=T)
	else platemap<-read.delim(file=platemapFn,sep="\t",header=T,as.is=T)
	pm.name<-strsplit(filetail(platemapFn),"\\.")[[1]][1]
	ind<-grep("batch",tolower(names(platemap)))
	if(length(ind)==1)batch<-platemap[,ind]
	else if(length(ind)==0) batch<-rep(pm.name,length=nrow(platemap))
	else stop("There are more one batch field, stopped.\n")
	chipBarcode<-platemap[,grep("chip_id|Infinium.Barcode",names(platemap))]
	if(length(grep("_",chipBarcode[1]))>0)chipBarcode<-sapply(chipBarcode,function(x)strsplit(x,"_")[[1]][1])
	cancerType<-NA
	ind<-grep("cancer_type|abbreviation",tolower(names(platemap)))
	if(length(ind)>0)cancerType<-platemap[,ind]
	platemap<-data.frame(chip_id=chipBarcode,Batch_Number=batch,cancer_Type=cancerType)
	return(platemap)
}
updatePlateSampleMap<-function(plate.mapping,sample.mapping="sample_mapping.txt",arrayPath=NULL,toUpdate=T,platform="meth450k")
{
	parsePlateSampleMap(plate.mapping,sample.mapping,arrayPath,toUpdate,platform)		
}
parsePlateSampleMap_test<-function(){
	plate.mapping<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\zack\\mapping.xml"
	plate.mapping<-"c:\\temp\\mapping.xml"
	parsePlateSampleMap(plate.mapping,toUpdate=F)
	parsePlateSampleMap(plate.mapping)
}
parsePlateSampleMap<-function(plate.mapping,sample.mapping="sample_mapping.txt",arrayPath=NULL,toUpdate=T,platform="meth450k"){
	map<-readLines(plate.mapping)[2]
	map.samp<-strsplit(map,"<mapping ")[[1]][-1]
	map.samp.n<-sapply(map.samp,function(x)length(strsplit(x,"=")[[1]]))
	map.samp<-map.samp[map.samp.n==17]
	map.all<-sapply(map.samp,function(x){
				samp<-gsub("/>","",x);
				fields<-strsplit(samp,"=")[[1]];
				dat<-sapply(fields,function(y)strsplit(y,"\"")[[1]][2])[-1];
				dat.name<-sapply(fields,function(y)gsub(" ","",strsplit(y,"\"")[[1]][3]));
				dat.name[1]<-names(dat.name)[1];dat.name<-dat.name[-length(dat.name)];names(dat)<-dat.name
				return(dat)
			})
	map.all<-t(map.all)
	if(is.null(arrayPath))arrayPath<-filedir(plate.mapping)
	write.table(map.all,file=file.path(arrayPath,sample.mapping),row.names=F,sep="\t",quote=F)
	if(toUpdate==T)map.all<-updateSampleMap(arrayPath,ext=T,platform=platform)
	return(map.all)
}

updateSampleMap_test<-function(){
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth27"
	updateSampleMap(arrayPath,platform="meth27k")
	arraypath<-"C:\\tcga\\others\\arraymapping\\meth450"
	updateSampleMap(arrayPath)
	
	updateSampleMap("c:\\temp",sample.mapping="mapping.txt",ext=T)
	updateSampleMap("c:\\temp",sample.mapping="mapping.txt",ext=T,platform="meth27k")
}
updateSampleMap<-function(arrayPath,sample.mapping="sample_mapping.txt",ext=F,show.msg=F,platform="meth450k"){
	if(ext==F){
		map<-readSampleMapping(arrayPath)
		if(nrow(map)<6)stop("Pls check sampple mappings...\n  ")
	}
	else {
		map<-read.delim(file=file.path(arrayPath,sample.mapping),sep="\t",stringsAsFactors=F)
		if(is.null(map$beadserial)|is.null(map$beadposition)|is.null(map$name)|is.null(map$batch)|is.null(map$diseaseabr)|is.null(map$plateposition))stop("check sample mapping data\n")
		map$plate_id<-map$beadserial
		map$flow_cell<-sapply(map$beadposition,function(x)strsplit(as.character(x),":")[[1]][1])
		map$sampleID<-map$name
		map$Batch_Number<-map$batch
		map$abbreviation<-map$diseaseabr
		map$plateposition<-sapply(map$plateposition,function(x)gsub(":","",as.character(x))[[1]])
		map$cancer<-map$tissue
	}
	if(platform=="meth450k")map$flow_cell<-sapply(map$flow_cell,function(x) slots.27k.to.450k(x))
	map$barcode2<-paste(map$plate_id,map$flow_cell,sep="_")
	barcode.dup<-map$barcode2[duplicated(map$barcode2)]
	if(length(barcode.dup)>0){
		cat("The following barcodes are not unique:",paste(barcode.dup,sep=","),"\n")
		#map<-map[!is.element(map$barcode,barcode.dup),] #remove all
		map<-map[!duplicated(map$barcode2),]  #keep one
	}
	plates<-unique(map$plate_id)
	for(pl in plates){
		map1<-map[map$plate_id==pl,]
		sid.dup<-map1$sampleID[duplicated(map1$sampleID)]
		if(length(sid.dup)>0){
			if(show.msg==T)cat("The sample IDs in array",pl," are not unique\n")
			ind<-is.element(map1$sampleID,sid.dup)
			flow_cell<-paste(map1$sampleID,map1$flow_cell,sep="_")
			map$sampleID[map$plate_id==pl]<-ifelse(ind,flow_cell,map1$sampleID)
		}
	}
	if(is.null(arrayPath))arrayPath<-"c:\\temp"
	dn<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation")
	map<-map[,c(dn,names(map)[!is.element(names(map),dn)])]
	map<-map[order(map$barcode2),]
	write.table(map,file=file.path(arrayPath,"sample_mapping.txt"),sep="\t",quote=F,row.names=F,col.names=T)
}

updateSampleMap.1<-function(arrayPath,sample.mapping="sample_mapping.txt",ext=F,show.msg=F,platform="meth450k"){
	if(ext==F){
		map<-readSampleMapping(arrayPath)
		if(nrow(map)<6)stop("Pls check sampple mappings...\n  ")
	}
	else {
		map<-read.delim(file=file.path(arrayPath,sample.mapping),sep="\t",stringsAsFactors=F)
		if(is.null(map$beadchipserial)|is.null(map$beadchipposition)|is.null(map$name)|is.null(map$batch)|is.null(map$diseaseabr)|is.null(map$plateposition))stop("check sample mapping data\n")
		map$plate_id<-map$beadchipserial
		map$flow_cell<-sapply(map$beadchipposition,function(x)strsplit(as.character(x),":")[[1]][1])
		map$sampleID<-map$name
		map$Batch_Number<-map$batch
		map$abbreviation<-map$diseaseabr
		map$plateposition<-sapply(map$plateposition,function(x)gsub(":","",as.character(x))[[1]])
		map$cancer<-map$tissue
	}
	if(platform=="meth450k")map$flow_cell<-sapply(map$flow_cell,function(x) slots.27k.to.450k(x))
	map$barcode<-paste(map$plate_id,map$flow_cell,sep="_")
	barcode.dup<-map$barcode[duplicated(map$barcode)]
	if(length(barcode.dup)>0){
		cat("The following barcodes are not unique:",paste(barcode.dup,sep=","),"\n")
		map<-map[!is.element(map$barcode,barcode.dup),]
	}
	plates<-unique(map$plate_id)
	for(pl in plates){
		map1<-map[map$plate_id==pl,]
		sid.dup<-map1$sampleID[duplicated(map1$sampleID)]
		if(length(sid.dup)>0){
			if(show.msg==T)cat("The sample IDs in array",pl," are not unique\n")
			ind<-is.element(map1$sampleID,sid.dup)
			flow_cell<-paste(map1$sampleID,map1$flow_cell,sep="_")
			map$sampleID[map$plate_id==pl]<-ifelse(ind,flow_cell,map1$sampleID)
		}
	}
	if(is.null(arrayPath))arrayPath<-"c:\\temp"
	dn<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation")
	map<-map[,c(dn,names(map)[!is.element(names(map),dn)])]
	write.table(map,file=file.path(arrayPath,"sample_mapping.txt"),sep="\t",quote=F,row.names=F,col.names=T)
}
updateSampleMap450_test<-function(){
	arrayPath<-"c:\\tcga\\others\\arraymapping\\meth450"
	updateSampleMap450(arrayPath)
}
updateSampleMap450<-function(arrayPath,sample.mapping="sample_mapping.txt"){
	sm<-readSampleMapping(arrayPath)
	pos<-sm$flow_cell
	pos<-sapply(pos,function(x)gsub("A","R01C01",x))
	pos<-sapply(pos,function(x)gsub("B","R02C01",x))
	pos<-sapply(pos,function(x)gsub("^C","R03C01",x))
	pos<-sapply(pos,function(x)gsub("D","R04C01",x))
	pos<-sapply(pos,function(x)gsub("E","R05C01",x))
	pos<-sapply(pos,function(x)gsub("F","R06C01",x))
	pos<-sapply(pos,function(x)gsub("G","R01C02",x))
	pos<-sapply(pos,function(x)gsub("H","R02C02",x))
	pos<-sapply(pos,function(x)gsub("I","R03C02",x))
	pos<-sapply(pos,function(x)gsub("J","R04C02",x))
	pos<-sapply(pos,function(x)gsub("K","R05C02",x))
	pos<-sapply(pos,function(x)gsub("L","R06C02",x))
	sm$flow_cell<-pos;sm<-sm[,c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation")]
	write.table(sm,file=file.path(arrayPath,sample.mapping),sep="\t",quote=F,row.names=F,col.names=F)
}
##############
 slots.27k.to.450k <- function(slots) {
  rs = paste('R0', 1:6, sep='')
  slotses = c(paste(rs, 'C01', sep=''), paste(rs, 'C02', sep=''))
  names(slotses) = toupper(letters[1:length(slotses)])
  return(slotses[toupper(slots)])
}
#>>>>>        A        B        C        D        E        F
#>>>>> "R01C01" "R02C01" "R03C01" "R04C01" "R05C01" "R06C01"
#>>>>>        G        H        I        J        K        L
#>>>>> "R01C02" "R02C02" "R03C02" "R04C02" "R05C02" "R06C02"
##############
createDataSet<-function(batchDir,outDir,platemapFn){
	pmap<-read.delim(file=platemapFn,sep="\t",header=T,as.is=T)
	pmap.cancers<-split(pmap,pmap$Cancer_Type)
	dat<-NULL
	for(pmap.cancer in pmap.cancers){
		batches<-unique(pmap.cancer$Batch_Number)
		cancer<-pmap$Cancer_Type[1]
		for(batch in batches){
			datFn<-list.files(file.path(batchDir,batch),pattern=".rda")
			dat1<-NULL
			if(file.exists(datFn)) dat1<-get(print(load(datFn)))
			else cat("data File is not available, checked.\n");next()
			if(is.null(dat)){
				dat<-dat1
			}else{
				dat<-mergeIDAT(dat,dat1)
			}
		}
		if(!file.exists(file.path(outDir,cancer))) dir.create(file.path(outDir,cancer))
		dat<-filterIDat(dat,pmap.cancer)
		save(dat,file=file.path(outDir,paste(cancer,"_idat.rda"),sep=""))
	}
}
mergeDataSet<-function(dat1,dat2){
	dat<-NULL
	if(class(dat1)=="MethyLumiSet"&class(dat2)=="MethyLumiSet"){
		dat<-mergeIDAT.2(dat1,dat2)
	}else if(class(dat1)=="methData" & class(dat2)=="methData"){
		dat<-mergeMDAT(dat1,dat2)
	}else{
		dat<-mergeIMDAT(dat1,dat2)
	}
	return(dat)
}
mergeDataSet.1<-function(dat1,dat2){
	dat<-NULL
	if(class(dat1)=="MethyLumiSet"&class(dat2)=="MethyLumiSet"){
		dat<-mergeIDAT.2(dat1,dat2)
	}else if(class(dat1)=="methData" & class(dat2)=="methData"){
		dat<-mergeMDAT(dat1,dat2)
	}
	return(dat)
}
mergeIMDAT_test<-function(){
	print(load(file="C:\\temp\\test3\\meth27k\\processed\\5775446062_idat.rda"))
	mergeIMDAT(idat,mdat)
}
mergeIMDAT<-function(idat1,idat2){
	require(methylumi)
	if(class(idat2)=="MethyLumiSet"){
		idat<-idat1;idat1<-idat2;idat2<-idat
	}
	idat1<-idat2mdat(idat1)
	idat<-mergeMDAT(idat1,idat2)
	return(idat)
}
idat2mdat_test<-function(){
	print(load(file="C:\\temp\\test\\meth27k\\processed\\5543207015\\mdat.rdata"))
	print(load(file="C:\\temp\\test3\\meth27k\\processed\\5775446062_idat.rda"))
	mdat<-idat2mdat(idat)
}
idat2mdat<-function(idat,platform="meth27k"){
	betas<-idat@assayData$betas
	pvalue<-idat@assayData$pvals
	methylated<-idat@assayData$methylated
	methylated.N<-idat@assayData$methylated.N
	methylated.SD<-idat@assayData$methylated.SD
	methylated.se<-methylated.SD/sqrt(methylated.N)
	unmethylated<-idat@assayData$unmethylated
	unmethylated.N<-idat@assayData$unmethylated.N
	unmethylated.SD<-idat@assayData$unmethylated.SD
	unmethylated.se<-unmethylated.SD/sqrt(unmethylated.N)
	mdat<-new("methData",BetaValue=as.matrix(betas),Pvalue=as.matrix(pvalue),M=as.matrix(methylated),U=as.matrix(unmethylated),
			Mnumber=as.matrix(methylated.N),Unumber=as.matrix(unmethylated.N),Mstderr=as.matrix(methylated.se),Ustderr=as.matrix(unmethylated.se))
	phenoData(mdat)<-phenoData(idat)
	negData<-getNegCtrData(idat,platform)
	setNegData(mdat)<-negData
	return(mdat)
}
idat2mdat.1<-function(idat,platform="meth27k"){
	betas<-idat@assayData$betas
	pvalue<-idat@assayData$pvals
	methylated<-idat@assayData$methylated
	methylated.N<-idat@assayData$methylated.N
	methylated.SD<-idat@assayData$methylated.SD
	methylated.se<-methylated.SD/sqrt(methylated.N)
	unmethylated<-idat@assayData$unmethylated
	unmethylated.N<-idat@assayData$unmethylated.N
	unmethylated.SD<-idat@assayData$unmethylated.SD
	unmethylated.se<-unmethylated.SD/sqrt(unmethylated.N)
	mdat<-new("methData",BetaValue=as.matrix(betas),Pvalue=as.matrix(pvalue),M=as.matrix(methylated),U=as.matrix(unmethylated),
			Mnumber=as.matrix(methylated.N),Unumber=as.matrix(unmethylated.N),Mstderr=as.matrix(methylated.se),Ustderr=as.matrix(unmethylated.se))
	phenoData(mdat)<-phenoData(idat)
	negData<-getNegCtrData(idat,platform)
	setNegData(mdat)<-negData
	return(mdat)
}
mdat2idat<-function(idat1){
	betas<-getBetaValue(idat1)
	pvalue<-getPvalue(idat1)
	methylated<-getM(idat1)
	unmethylated<-getU(idat1)
	methylated.n<-getMn(idat1)
	unmethylated.n<-getUn(idat1)
	methylated.sd<-getMse(idat1)*sqrt(nrow(betas))
	unmethylated.sd<-getUse(idat1)*sqrt(nrow(betas))
	idat1<-new("MethyLumiSet",betas=as.matrix(betas),pvals=as.matrix(pvalue),methylated=as.matrix(methylated),
			unmethylated=as.matrix(unmethylated),methylated.N=as.matrix(methylated.n),unmethylated.N=as.matrix(unmethylated.n),
			methylated.SD=as.matrix(methylated.sd),unmethylated.SD=as.matrix(unmethylated.sd))
}
mergeIDAT.2_test<-function(){
	load(file="c:\\temp\\test3\\meth27k\\processed\\5471637013\\5471637013_idat.rda");idat1<-idat
	load(file="c:\\temp\\test3\\meth27k\\processed\\4841860025\\4841860025_idat.rda");idat2<-idat
	idat<-mergeIDAT.2(idat1,idat2)
	dim(idat@assayData$betas)
	idat<-mergeIDAT.2(idat1,idat2)
	
	load(file="C:\\temp\\IDAT\\meth450k\\processed\\6026818104\\6026818104_idat.rda");idat1<-idat;
	load(file="C:\\temp\\IDAT\\meth450k\\processed\\6055424097\\6055424097_idat.rda");idat2<-idat
	idat<-mergeIDAT.2(idat1,idat2)
	dim(idat@QC@assayData$methylated)
	dim(idat@QC@assayData$unmethylated)
	dim(idat@assayData$methylated.SD)
	dim(idat1@assayData$methylated.SD)
	pdat<-as(phenoData(idat),"data.frame")
	pdat$barcodes
	pdat$sampleID
	saveIDATcsv(idat,"c:\\temp\\test",T)
}
mergeIDAT.2<-function(idat1,idat2){
	require(methylumi)
	pdat1<-phenoData(idat1);pdat2<-phenoData(idat2)
	fdat1<-featureData(idat1);fdat2<-featureData(idat2)
	qc1<-idat1@QC@assayData;qc2<-idat2@QC@assayData
	methylated.ctr<-merge(qc1$methylated,qc2$methylated,by.x=0,by.y=0);row.names(methylated.ctr)<-methylated.ctr[,1];methylated.ctr<-methylated.ctr[,-1]
	idat.qc<-assayDataElementReplace(idat1@QC,"methylated",methylated.ctr)
	idat1<-idat1@assayData;idat2<-idat2@assayData
	betas<-merge(idat1$betas,idat2$betas,by.x=0,by.y=0);row.names(betas)<-betas[,1];betas<-betas[,-1]
	methylated<-merge(idat1$methylated,idat2$methylated,by.x=0,by.y=0);row.names(methylated)<-methylated[,1];methylated<-methylated[,-1]
	methylated.N<-merge(idat1$methylated.N,idat2$methylated.N,by.x=0,by.y=0);row.names(methylated.N)<-methylated.N[,1];methylated.N<-methylated.N[,-1]
	methylated.SD<-merge(idat1$methylated.SD,idat2$methylated.SD,by.x=0,by.y=0);row.names(methylated.SD)<-methylated.SD[,1];methylated.SD<-methylated.SD[,-1]
	unmethylated<-merge(idat1$unmethylated,idat2$unmethylated,by.x=0,by.y=0);row.names(unmethylated)<-unmethylated[,1];unmethylated<-unmethylated[,-1]
	unmethylated.N<-merge(idat1$unmethylated.N,idat2$unmethylated.N,by.x=0,by.y=0);row.names(unmethylated.N)<-unmethylated.N[,1];unmethylated.N<-unmethylated.N[,-1]
	unmethylated.SD<-merge(idat1$unmethylated.SD,idat2$unmethylated.SD,by.x=0,by.y=0);row.names(unmethylated.SD)<-unmethylated.SD[,1];unmethylated.SD<-unmethylated.SD[,-1]
	pvalue<-merge(idat1$pvals,idat2$pvals,by.x=0,by.y=0);row.names(pvalue)<-pvalue[,1];pvalue<-pvalue[,-1]
	idat<-new("MethyLumiSet",betas=as.matrix(betas),pvals=as.matrix(pvalue),methylated=as.matrix(methylated),
			methylated.N=as.matrix(methylated.N),unmethylated=as.matrix(unmethylated),unmethylated.N=as.matrix(unmethylated.N),methylated.SD=as.matrix(methylated.SD),unmethylated.SD=as.matrix(unmethylated.SD))
	NBeads<-merge(qc1$NBeads,qc2$NBeads,by.x=0,by.y=0);row.names(NBeads)<-NBeads[,1];NBeads<-NBeads[,-1]
	unmethylated<-merge(qc1$unmethylated,qc2$unmethylated,by.x=0,by.y=0);row.names(unmethylated)<-unmethylated[,1];unmethylated<-unmethylated[,-1]
	idat.qc<-assayDataElementReplace(idat.qc,"unmethylated",unmethylated)
	idat.qc<-assayDataElementReplace(idat.qc,"NBeads",NBeads)
	QCdata(idat)<-idat.qc
	#phenoData(idat)<-mergePhenoData(pdat1,pdat2)
	#featureData(idat)<-mergeFeatureData(fdat1,fdat2)
	return(idat)
}

mergeIDAT.2.1<-function(idat1,idat2){
	require(methylumIDAT)
	pdat1<-phenoData(idat1);pdat2<-phenoData(idat2)
	fdat1<-featureData(idat1);fdat2<-featureData(idat2)
	qc1<-idat1@QC@assayData;qc2<-idat2@QC@assayData
	idat1<-idat1@assayData;idat2<-idat2@assayData
	betas<-merge(idat1$betas,idat2$betas,by.x=0,by.y=0);row.names(betas)<-betas[,1];betas<-betas[,-1]
	methylated<-merge(idat1$methylated,idat2$methylated,by.x=0,by.y=0);row.names(methylated)<-methylated[,1];methylated<-methylated[,-1]
	methylated.N<-merge(idat1$methylated.N,idat2$methylated.N,by.x=0,by.y=0);row.names(methylated.N)<-methylated.N[,1];methylated.N<-methylated.N[,-1]
	unmethylated<-merge(idat1$unmethylated,idat2$unmethylated,by.x=0,by.y=0);row.names(unmethylated)<-unmethylated[,1];unmethylated<-unmethylated[,-1]
	unmethylated.N<-merge(idat1$unmethylated.N,idat2$unmethylated.N,by.x=0,by.y=0);row.names(unmethylated.N)<-unmethylated.N[,1];unmethylated.N<-unmethylated.N[,-1]
	pvalue<-merge(idat1$pvals,idat2$pvals,by.x=0,by.y=0);row.names(pvalue)<-pvalue[,1];pvalue<-pvalue[,-1]
	idat1<-assayDataElementReplace(idat@QC,"methylated",methylated)
	idat<-new("MethyLumiSet",betas=as.matrix(betas),pvals=as.matrix(pvalue),methylated=as.matrix(methylated),
			methylated.N=as.matrix(methylated.N),unmethylated=as.matrix(unmethylated),unmethylated.N=as.matrix(unmethylated.N))
	methylated<-merge(qc1$methylated,qc2$methylated,by.x=0,by.y=0);row.names(methylated)<-methylated[,1];methylated<-methylated[,-1]
	NBeads<-merge(qc1$NBeads,qc2$NBeads,by.x=0,by.y=0);row.names(NBeads)<-NBeads[,1];NBeads<-NBeads[,-1]
	unmethylated<-merge(qc1$unmethylated,qc2$unmethylated,by.x=0,by.y=0);row.names(unmethylated)<-unmethylated[,1];unmethylated<-unmethylated[,-1]
	idat1<-assayDataElementReplace(idat1,"unmethylated",unmethylated)
	idat1<-assayDataElementReplace(idat1,"NBeads",NBeads)
	QCdata(idat)<-idat1
	if(ncol(pdat1@data)>0){
		phenoData(idat)<-pdat1
	}
	if(ncol(fdat1@data)>0) featureData(idat)<-fdat1
	return(idat)
}

mergeIDAT_test<-function(){
	load(file="c:\\temp\\test3\\meth27k\\processed\\5543207013\\5543207013_idat.rda");idat1<-idat
	load(file="c:\\temp\\test3\\meth27k\\processed\\5543207015\\5543207015_idat.rda");idat2<-idat
	idat<-mergeIDAT(idat1,idat2)
	dim(idat@assayData$betas)
	savePhenoDataCSV(idat,outPath="c:\\temp")
	
	load(file="C:\\temp\\IDAT\\meth450k\\processed\\6026818104\\6026818104_idat.rda")
	idat1<-idat;idat2<-idat
}
mergeIDAT<-function(idat1,idat2){
	require(methylumi)
	pdat1<-phenoData(idat1);pdat2<-phenoData(idat2)
	fdat1<-featureData(idat1);fdat2<-featureData(idat2)
	idat1<-idat1@assayData;idat2<-idat2@assayData
	betas<-merge(idat1$betas,idat2$betas,by.x=0,by.y=0);row.names(betas)<-betas[,1];betas<-betas[,-1]
	methylated<-merge(idat1$methylated,idat2$methylated,by.x=0,by.y=0);row.names(methylated)<-methylated[,1];methylated<-methylated[,-1]
	methylated.N<-merge(idat1$methylated.N,idat2$methylated.N,by.x=0,by.y=0);row.names(methylated.N)<-methylated.N[,1];methylated.N<-methylated.N[,-1]
	methylated.SD<-merge(idat1$methylated.SD,idat2$methylated.SD,by.x=0,by.y=0);row.names(methylated.SD)<-methylated.SD[,1];methylated.SD<-methylated.SD[,-1]
	unmethylated<-merge(idat1$unmethylated,idat2$unmethylated,by.x=0,by.y=0);row.names(unmethylated)<-unmethylated[,1];unmethylated<-unmethylated[,-1]
	unmethylated.N<-merge(idat1$unmethylated.N,idat2$unmethylated.N,by.x=0,by.y=0);row.names(unmethylated.N)<-unmethylated.N[,1];unmethylated.N<-unmethylated.N[,-1]
	unmethylated.SD<-merge(idat1$unmethylated.SD,idat2$unmethylated.SD,by.x=0,by.y=0);row.names(unmethylated.SD)<-unmethylated.SD[,1];unmethylated.SD<-unmethylated.SD[,-1]
	pvalue<-merge(idat1$pvals,idat2$pvals,by.x=0,by.y=0);row.names(pvalue)<-pvalue[,1];pvalue<-pvalue[,-1]
	idat<-new("MethyLumiSet",betas=as.matrix(betas),pvals=as.matrix(pvalue),methylated=as.matrix(methylated),
			methylated.N=as.matrix(methylated.N),unmethylated=as.matrix(unmethylated),
			unmethylated.N=as.matrix(unmethylated.N),methylated.SD=as.matrix(methylated.SD),unmethylated.SD=as.matrix(unmethylated.SD))
	phenoData(idat)<-mergePhenoData(pdat1,pdat2)
	featureData(idat)<-mergeFeatureData(fdat1,fdat2)
	return(idat)
}

mergeIDAT.1<-function(idat1,idat2){
	require(methylumIDAT)
	pdat1<-phenoData(idat1);pdat2<-phenoData(idat2)
	fdat1<-featureData(idat1);fdat2<-featureData(idat2)
	idat1<-idat1@assayData;idat2<-idat2@assayData
	betas<-merge(idat1$betas,idat2$betas,by.x=0,by.y=0);row.names(betas)<-betas[,1];betas<-betas[,-1]
	methylated<-merge(idat1$methylated,idat2$methylated,by.x=0,by.y=0);row.names(methylated)<-methylated[,1];methylated<-methylated[,-1]
	methylated.N<-merge(idat1$methylated.N,idat2$methylated.N,by.x=0,by.y=0);row.names(methylated.N)<-methylated.N[,1];methylated.N<-methylated.N[,-1]
	unmethylated<-merge(idat1$unmethylated,idat2$unmethylated,by.x=0,by.y=0);row.names(unmethylated)<-unmethylated[,1];unmethylated<-unmethylated[,-1]
	unmethylated.N<-merge(idat1$unmethylated.N,idat2$unmethylated.N,by.x=0,by.y=0);row.names(unmethylated.N)<-unmethylated.N[,1];unmethylated.N<-unmethylated.N[,-1]
	pvalue<-merge(idat1$pvals,idat2$pvals,by.x=0,by.y=0);row.names(pvalue)<-pvalue[,1];pvalue<-pvalue[,-1]
	idat<-new("MethyLumiSet",betas=as.matrix(betas),pvals=as.matrix(pvalue),methylated=as.matrix(methylated),
			methylated.N=as.matrix(methylated.N),unmethylated=as.matrix(unmethylated),unmethylated.N=as.matrix(unmethylated.N))
	phenoData(idat)<-mergePhenoData(pdat1,pdat2)
	featureData(idat)<-mergeFeatureData(fdat1,fdat2)
	return(idat)
}

mergePhenoData_test<-function(){
	idat1<-get(load("c:\\temp\\IDAT\\meth450k\\processed\\6042308117\\6042308117_idat.rda"))
	idat2<-get(load("c:\\temp\\IDAT\\processed\\5775446072\\5775446072_idat.rda"))
	pdat1<-phenoData(idat1);pdat2<-phenoData(idat2)
	pheno<-mergePhenoData(pdat1,pdat2)
	write.csv(pheno@data,file="c:\\temp\\MetaData.csv",quote=F,row.names=T)
}
mergePhenoData<-function(pdat1,pdat2){
	pheno<-pdat1
	if(ncol(pdat1@data)>0|ncol(pdat2@data)>0){
		pdat1<-pdat1@data;pdat2<-pdat2@data
		pnames<-unique(c(names(pdat1),names(pdat2)))
		pdat1<-merge(pnames,t(pdat1),by.x=1,by.y=0,all.x=T)
		pdat2<-merge(pnames,t(pdat2),by.x=1,by.y=0,all.x=T)
		pdat<-merge(pdat1,pdat2,by.x=1,by.y=1)
		row.names(pdat)<-pdat[,1]
		dat<-as.data.frame(t(pdat[,-1]))
		pheno<-new("AnnotatedDataFrame",data=dat)
		varMetadata(pheno)<-data.frame(rn=names(dat),labelDescription=names(dat),row.names=1)
	}
	return(pheno)
}
mergePhenoData.1<-function(pdat1,pdat2){
	pheno<-pdat1
	if(ncol(pdat1@data)>0|ncol(pdat2@data)>0){
		pdat1<-pdat1@data;pdat2<-pdat2@data
		pnames<-unique(c(names(pdat1),names(pdat2)))
		pdat1<-merge(pnames,t(pdat1),by.x=1,by.y=0,all.x=T)
		pdat2<-merge(pnames,t(pdat2),by.x=1,by.y=0,all.x=T)
		pdat<-merge(pdat1,pdat2,by.x=1,by.y=1)
		row.names(pdat)<-pdat[,1]
		pheno<-new("AnnotatedDataFrame",data=as.data.frame(t(pdat[,-1])))
	}
	return(pheno)
}
mergeFeatureData_test<-function(){
	idat1<-get(load("c:\\temp\\IDAT\\processed\\5775446078\\5775446078_idat.rda"))
	idat2<-get(load("c:\\temp\\IDAT\\processed\\5640277011\\5640277011_idat.rda"))
	fdat1<-featureData(idat1);fdat2<-featureData(idat2)
	fdat<-mergeFeatureData(fdat1,fdat2)
	
	mdat1<-get(load("C:\\temp\\test\\meth27k\\processed\\4841860025\\mdat.rdata"))
	mdat2<-get(load("c:\\temp\\test\\meth27k\\processed\\5543207015\\mdat.rdata"))
	fdat1<-featureData(mdat1);fdat2<-featureData(mdat2)
	fdat<-mergeFeatureData(fdat1,fdat2)
}
mergeFeatureData<-function(fdat1,fdat2){
	fdat<-fdat1
	if(ncol(fdat1@data)>0|ncol(fdat2@data)>0){
		fdat1<-fdat1@data;fdat2<-fdat2@data
		fdat<-merge(fdat1,fdat2,by.x=0,by.y=0)
		fdat<-new("AnnotatedDataFrame",data=fdat)
	}
	return(fdat)
}
saveBetaLevel3CSV_test<-function(){
	print(load("c:\\temp\\IDAT\\meth450k\\processed\\5775446078\\5775446078_idat.rda"))
	saveBetaLevel3CSV(idat,outPath="c:\\temp")
	print(load("C:\\temp\\test\\meth27k\\processed\\5543207015\\mdat.rdata"))
	saveBetaLevel3CSV(mData,"c:\\temp","bv3.csv",platform="meth27k")
}
saveBetaLevel3CSV<-function(dat,outPath=NULL,datFn="BetaValue.lvl3.csv",platform="meth450k"){
	if(!is.null(outPath))datFn<-file.path(outPath,datFn)
	bv<-NULL;lvl3mask<-NULL;
	if(platform=="meth27k"){
		data(lvl3mask)
		lvl3mask<-lvl3mask
	}
	else {
		data(meth450lvl3mask)
		lvl3mask<-meth450lvl3mask
	}
	if(class(dat)=="MethyLumiSet")bv<-dat@assayData$betas
	else if(class(dat)=="methData")bv<-getBeta(dat)
	else {
		cat("unknown class of dat\n")
		return()
	}
	bv<-bv[row.names(lvl3mask),]
	bv.lvl3<-apply(bv,2,function(x)ifelse(lvl3mask$mask_lvl3==1,NA,x))
	write.csv(bv.lvl3,file=datFn,row.names=F,quote=F)
}

savePhenoDataCSV_test<-function(){
	print(load("C:\\temp\\test\\meth27k\\processed\\4841860025\\mdat.rdata"))
	savePhenoDataCSV(mData,"C:\\temp\\test\\meth27k\\processed\\4841860025")
	load("c:\\temp\\IDAT\\processed\\5775446078\\5775446078_idat.rda")
	savePhenoDataCSV(idat,"c:\\temp\\IDAT\\processed\\5775446078")
}
savePhenoDataCSV<-function(dat,outPath=NULL,datFn=NULL){
	if(is.null(datFn))datFn<-"MetaData.csv"
	if(!is.null(outPath)) datFn<-file.path(outPath,datFn)
	pheno<-phenoData(dat)
	pdat<-pheno@data;
	pdat<-pdat[,c("barcodes","plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation")]
	names(pdat)<-c("Barcodes","Array_ID","Well_Position","Sample_ID","Batch_Number","Cancer_Name","Cancer_Abbreviation")
	write.csv(pdat,file=datFn,quote=F,row.names=F)
}
savePhenoDataCSV.1<-function(dat,outPath=NULL,datFn=NULL){
	if(is.null(datFn))datFn<-"MetaData.csv"
	if(is.null(outPath)) outPath<-"c:/temp"
	datFn<-file.path(outPath,datFn)
	pheno<-phenoData(dat)
	write.csv(pheno@data,file=datFn,quote=F,row.names=T)
}
mergeMDAT_test<-function(){
	library(rapid.pro)
	library(Biobase)
	load("c:\\temp\\test\\meth27k\\processed\\5543207013\\mdat.rdata");mdat1<-mData
	load("c:\\temp\\test\\meth27k\\processed\\5543207013\\mdat.rdata");mdat2<-mData
	mdat<-mergeMDAT(mdat1,mdat2)
	saveBatchCSV.2(mdat,"c:\\temp\\test\\tmp")
	dim(getBeta(mdat))
}
mergeMDAT<-function(mdat1,mdat2){
	require(Biobase)
	pdat1<-phenoData(mdat1);pdat2<-phenoData(mdat2)
	fdat1<-featureData(mdat1);fdat2<-featureData(mdat2)
	mname1<-c("BetaValue","M","Mnumber","Mstderr","Pvalue","U","Unumber","Ustderr") #assayDataElementNames(mdat1)
	mname2<-mname1 #assayDataElementNames(mdat2)
	if(length(mname1)!=length(mname2)) cat("The number of assayData elements is not the same\n")
	mnames<-mname1
	if(length(mname1)>length(mname2)){
		mnames<-manme2
	}
	nc<-getCol(mdat1)+getCol(mdat2);nr<-getRow(mdat1);init<-matrix(NA,nrow=nc,ncol=nr)
	mdat<-new("methData",BetaValue=init,Pvalue=init,M=init,U=init)
	for(mn in mnames){
		dat1<-as.data.frame(assayDataElement(mdat1,mn))
		dat2<-as.data.frame(assayDataElement(mdat2,mn))
		dat2<-dat2[row.names(dat1),]
		dat<-as.matrix(cbind(dat1,dat2))
		mdat<-assayDataElementReplace(mdat,mn,dat)
	}
	phenoData(mdat)<-mergePhenoData(pdat1,pdat2)
	featureData(mdat)<-mergeFeatureData(fdat1,fdat2)
	cneg1<-getNegData(mdat1)
	cneg2<-getNegData(mdat2)
	if(length(cneg1)>0 &length(cneg2)>0){
		cneg<-c(cneg1,cneg2)
		setNegData(mdat)<-cneg
	}
	cdata1<-getCData(mdat1);cdata2<-getCData(mdat2)
	if(length(cdata1)>0 & length(cdata2)>0){
		cdata<-c(cdata1,cdata2)
		setCData(mdat)<-cdata
	}
	return(mdat)
}
mergeMDAT.1<-function(mdat1,mdat2){
	require(Biobase)
	mname1<-c("BetaValue","M","Mnumber","Mstderr","Pvalue","U","Unumber","Ustderr") #assayDataElementNames(mdat1)
	mname2<-mname1 #assayDataElementNames(mdat2)
	if(length(mname1)!=length(mname2)) cat("The number of assayData elements is not the same\n")
	mnames<-mname1
	if(length(mname1)>length(mname2)){
		mnames<-manme2
	}
	nc<-getCol(mdat1)+getCol(mdat2);nr<-getRow(mdat1);init<-matrix(NA,nrow=nc,ncol=nr)
	mdat<-new("methData",BetaValue=init,Pvalue=init,M=init,U=init)
	for(mn in mnames){
		dat1<-as.data.frame(assayDataElement(mdat1,mn))
		dat2<-as.data.frame(assayDataElement(mdat2,mn))
		dat2<-dat2[row.names(dat1),]
		dat<-as.matrix(cbind(dat1,dat2))
		mdat<-assayDataElementReplace(mdat,mn,dat)
	}
	cneg1<-getNegData(mdat1)
	cneg2<-getNegData(mdat2)
	if(length(cneg1)>0 &length(cneg2)>0){
		cneg<-c(cneg1,cneg2)
		setNegData(mdat)<-cneg
	}
	cdata1<-getCData(mdat1);cdata2<-getCData(mdat2)
	if(length(cdata1)>0 & length(cdata2)>0){
		cdata<-c(cdata1,cdata2)
		setCData(mdat)<-cdata
	}
	return(mdat)
}
processedCSVFileNames<-function(){
	csvFN<-c("Methylation_Signal_Intensity.csv","Methylation_Signal_Intensity_NBeads.csv","Methylation_Signal_Intensity_STDERR.csv","UnMethylation_Signal_Intensity.csv","UnMethylation_Signal_Intensity_NBeads.csv","UnMethylation_Signal_Intensity_STDERR.csv","BetaValue.csv","Pvalue.csv","Control_Signal_Intensity_Grn.csv","Control_Signal_Intensity_Red.csv")
	tcgaFn<-c("tcgaPackage_B","tcgaPackage_B_n","tcgaPackage_B_se","tcgaPackage_A","tcgaPackage_A_n","tcgaPackage_B_se","tcgaPackage_beta_fn","tcgaPackage_pvalue_fn","tcgaPackage_G_ctr","tcgaPackage_R_ctr")
	name1<-c("M","Mn","Mse","U","Un","Use","Bv","Pv","Gctr","Rctr")
	names(csvFN)<-name1
	return(csvFN)
}
#packingBatchPkg.2_test<-function(){
#	datPath<-"C:/temp/IDAT/meth450k/batches/25/jhu-usc.edu_LAML.HumanMethylation27.25.0.0/25.rdata"
#	outPath<-"c:\\temp\\IDAT\\meth450k\\batches\\test"
#	mdat<-get(load(datPath))
#	packingBatchPkg.2(mdat,outPath,"LAML","25","meth450k")
#}
#packingBatchPkg.2<-function(mdat,outPath,cancerType,batch,platform="meth27k",sn=NULL,isTCGA=T){
#	beta.lvl3<-NULL
#	pl.name<-".HumanMethylation27."; if(platform=="meth450k") pl.name<-".HumanMethylation450."
#	if(isTCGA==T){
#		if(is.null(sn))sn<-list(lvl.1="0.0",lvl.2="0.0",lvl.3="0.0")
#		else{
#			sn1<-paste(strsplit(sn$lvl.1[1],"\\.")[[1]][2:3],collapse=".");sn2<-paste(strsplit(sn$lvl.2[1],"\\.")[[1]][2:3],collapse=".");sn3<-paste(strsplit(sn$lvl.3[1],"\\.")[[1]][2:3],collapse=".")
#			sn<-list(lvl.1=sn1,lvl.2=sn2,lvl.3=sn3)
#		}
#		pkgName<-paste("jhu-usc.edu_",cancerType,pl.name,batch,".0.0",sep="")
#		pref<-paste(paste(strsplit(pkgName,"\\.")[[1]][1:4],collapse="."),".lvl-1.",sep="")
#		pkg1Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_1.",batch,".",sn$lvl.1,sep="")
#		if(!file.exists(file.path(outPath,pkg1Name))) dir.create(file.path(outPath,pkg1Name));
#		processLevel1Data.2(mdat,pref,file.path(outPath,pkg1Name),platform)
#		createManifestByLevel.2(file.path(outPath,pkg1Name));compressDataPackage(file.path(outPath,pkg1Name));
#		pkg2Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_2.",batch,".",sn$lvl.2,sep="")
#		pvalue<-getPvalues(mdat)
#		create_lvl2_data_pkg(file.path(outPath,pkg1Name),file.path(outPath,pkg2Name),pvalue);createManifestByLevel.2(file.path(outPath,pkg2Name));compressDataPackage(file.path(outPath,pkg2Name))
#		pkg3Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_3.",batch,".",sn$lvl.3,sep="")
#		beta.lvl3<-create_lvl3_data.2(file.path(outPath,pkg2Name),file.path(outPath,pkg3Name),platform);createManifestByLevel.2(file.path(outPath,pkg3Name));compressDataPackage(file.path(outPath,pkg3Name))
#	}else{
#		calBetaValue2(mdat)
#		packagingArray(datPath,datPath)
#	}
#	return(beta.lvl3)
#}
packingBatchPkg.2_test<-function(){
	datFn<-"C:\\temp\\IDAT\\meth450k\\processed\\5613914085\\5613914085_idat.rda"
	mdat<-get(load(datFn))
	outPath<-"C:\\temp\\IDAT\\meth450k\\tcga\\KIRC"
	packingBatchPkg.2(mdat,outPath,batch="70",cancerType="KIRC","meth450k")
}
packingBatchPkg.2<-function(mdat,outPath,batch,cancerType,platform="meth27k",sn=NULL,isTCGA=T){
	beta.lvl3<-NULL;
	pl.name<-".HumanMethylation27."; if(platform=="meth450k") pl.name<-".HumanMethylation450."
	if(isTCGA==T){
		if(is.null(sn))sn<-list(lvl.1="0.0",lvl.2="0.0",lvl.3="0.0")
		else{
			sn1<-paste(strsplit(sn$lvl.1[1],"\\.")[[1]][2:3],collapse=".");sn2<-paste(strsplit(sn$lvl.2[1],"\\.")[[1]][2:3],collapse=".");sn3<-paste(strsplit(sn$lvl.3[1],"\\.")[[1]][2:3],collapse=".")
			sn<-list(lvl.1=sn1,lvl.2=sn2,lvl.3=sn3)
		}
		pkgName<-paste("jhu-usc.edu_",cancerType,pl.name,batch,".0.0",sep="")
		pref<-paste(paste(strsplit(pkgName,"\\.")[[1]][1:4],collapse="."),".lvl-1.",sep="")
		pkg1Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_1.",batch,".",sn$lvl.1,sep="")
		if(!file.exists(file.path(outPath,pkg1Name))) dir.create(file.path(outPath,pkg1Name));
		processLevel1Data.2(mdat,pref,file.path(outPath,pkg1Name),platform)
		createManifestByLevel.2(file.path(outPath,pkg1Name));compressDataPackage(file.path(outPath,pkg1Name));
		pkg2Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_2.",batch,".",sn$lvl.2,sep="")
		pvalueFn<-file.path(outPath,"Pvalues.csv");savePvalues(mdat,pvalueFn)#pvalue<-getPvalues(mdat)
		create_lvl2_data_pkg(file.path(outPath,pkg1Name),file.path(outPath,pkg2Name),pvalueFn);
		createManifestByLevel.2(file.path(outPath,pkg2Name));compressDataPackage(file.path(outPath,pkg2Name))
		pkg3Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_3.",batch,".",sn$lvl.3,sep="")
		beta.lvl3<-create_lvl3_data.2(file.path(outPath,pkg2Name),file.path(outPath,pkg3Name),platform);
		createManifestByLevel.2(file.path(outPath,pkg3Name));compressDataPackage(file.path(outPath,pkg3Name))
	}else{
		calBetaValue2(mdat)
		packagingArray(outPath,outPath)
	}
	return(beta.lvl3)
}

packingBatchPkg_test<-function(){
	datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data\\batches\\20\\jhu-usc.edu.HumanMethylation27.20.0.0"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data\\batches\\20"
	datPath<-"C:\\temp\\test2\\meth27k\\processed\\5543207015"
	outPath<-"c:\\temp\\test3"

	batch<-"20"
	datPath<-"C:\\temp\\test3\\meth27k\\batches\\20\\jhu-usc.edu_GBM.HumanMethylation27.20.0.0"
	outPath<-"C:\\temp\\test3\\meth27k\\batches\\20"
	sigA_Fn<-"UnMethylation_Signal_Intensity.csv"
	sigAN_Fn<-"UnMethylation_Signal_Intensity_NBeads.csv"
	sigASE_Fn<-"UnMethylation_Signal_Intensity_STDERR.csv"
	sigB_Fn<-"Methylation_Signal_Intensity.csv"
	sigBSE_Fn<-"Methylation_Signal_Intensity_STDERR.csv"
	sigBN_Fn<-"Methylation_Signal_Intensity_NBeads.csv"
	ctrRed_Fn<-"Control_Signal_Intensity_Red.csv"
	ctrGrn_Fn<-"Control_Signal_Intensity_Grn.csv"
	pv_Fn<-"Pvalue.csv"
	bv_Fn<-"BetaValue.csv"
	dat<-packingBatchPkg(datPath,outPath,batch,sigA_Fn,sigASE_Fn,sigAN_Fn,sigB_Fn,sigBSE_Fn,sigBN_Fn,ctrRed_Fn,ctrGrn_Fn,pv_Fn,bv_Fn)
	
	batch<-"1"
	datPath<-"C:\\temp\\test3\\meth450k\\batches\\1\\jhu-usc.edu_GBM.HumanMethylation450.1.0.0"
	outPath<-"C:\\temp\\test3\\meth450k\\batches\\1"
	dat<-packingBatchPkg(datPath,outPath,batch,sigA_Fn,sigASE_Fn,sigAN_Fn,sigB_Fn,sigBSE_Fn,sigBN_Fn,ctrRed_Fn,ctrGrn_Fn,pv_Fn,bv_Fn,platform="meth450k")
	
	batch<-"96"
	datPath<-"C:\\temp\\IDAT\\batches\\jhu_usc.edu_OV.HumanMethylation450.1.0.0"
	outPath<-"C:\\temp\\IDAT\\batches"
	
	batch<-"96"
	datPath<-"/auto/uec-02/shared/production/methylation/meth450k/batches/96/jhu_usc.edu_OV.HumanMethylation450.96.0.0"
	outPath<-"/auto/uec-02/shared/production/methylation/meth450k/batches/96"
	dat<-packingBatchPkg(datPath,outPath,batch,sigA_Fn,sigASE_Fn,sigAN_Fn,sigB_Fn,sigBSE_Fn,sigBN_Fn,ctrRed_Fn,ctrGrn_Fn,pv_Fn,bv_Fn,platform="meth450k")
	
}
packingBatchPkg<-function(datPath,outPath,batch,sigA_Fn,sigASE_Fn,sigAN_Fn,sigB_Fn,sigBSE_Fn,sigBN_Fn,ctrRed_Fn,ctrGrn_Fn,pv_Fn,bv_Fn,platform="meth27k",dataType=NULL,sn=NULL,isTCGA=T){
	if(!is.null(outPath)){
		sigA_Fn<-file.path(datPath,sigA_Fn)
		sigASE_Fn<-file.path(datPath,sigASE_Fn)
		sigAN_Fn<-file.path(datPath,sigAN_Fn)
		sigB_Fn<-file.path(datPath,sigB_Fn)
		sigBSE_Fn<-file.path(datPath,sigBSE_Fn)
		sigBN_Fn<-file.path(datPath,sigBN_Fn)
		ctrRed_Fn<-file.path(datPath,ctrRed_Fn)
		ctrGrn_Fn<-file.path(datPath,ctrGrn_Fn)
		bv_Fn<-file.path(datPath,bv_Fn)
		pv_Fn<-file.path(datPath,pv_Fn)
	}
	beta.lvl3<-NULL;cancerType<-strsplit(strsplit(filetail(datPath),"edu_")[[1]][2],"\\.")[[1]][1]
	if(!file.exists(sigA_Fn))return(beta.lvl3)
	pl.name<-".HumanMethylation27."; if(platform=="meth450k") pl.name<-".HumanMethylation450."
	if(isTCGA==T){
		if(is.null(sn))sn<-list(lvl.1="0.0",lvl.2="0.0",lvl.3="0.0")
		else{
			sn1<-paste(strsplit(sn$lvl.1[1],"\\.")[[1]][2:3],collapse=".");sn2<-paste(strsplit(sn$lvl.2[1],"\\.")[[1]][2:3],collapse=".");sn3<-paste(strsplit(sn$lvl.3[1],"\\.")[[1]][2:3],collapse=".")
			sn<-list(lvl.1=sn1,lvl.2=sn2,lvl.3=sn3)
		}
		pkgName<-paste("jhu-usc.edu_",cancerType,pl.name,batch,".0.0",sep="")
		pref<-paste(paste(strsplit(pkgName,"\\.")[[1]][1:4],collapse="."),".lvl-1.",sep="")
		pkg1Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_1.",batch,".",sn$lvl.1,sep="")
		if(!file.exists(file.path(outPath,pkg1Name))) dir.create(file.path(outPath,pkg1Name));
		processLevel1Data(sigA_Fn,sigAN_Fn,sigASE_Fn,sigB_Fn,sigBN_Fn,sigBSE_Fn,ctrRed_Fn,ctrGrn_Fn,pv_Fn,pref,outdir=file.path(outPath,pkg1Name),dataType=dataType)
		createManifestByLevel.2(file.path(outPath,pkg1Name));compressDataPackage(file.path(outPath,pkg1Name));
		pkg2Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_2.",batch,".",sn$lvl.2,sep="")
		pvalueFn<-file.path(outPath,pkgName,"Pvalue.csv")
		create_lvl2_data_pkg(file.path(outPath,pkg1Name),file.path(outPath,pkg2Name),pvalue_fn=pvalueFn);createManifestByLevel.2(file.path(outPath,pkg2Name));compressDataPackage(file.path(outPath,pkg2Name))
		pkg3Name<-paste("jhu-usc.edu_",cancerType,pl.name,"Level_3.",batch,".",sn$lvl.3,sep="")
		beta.lvl3<-create_lvl3_data.2(file.path(outPath,pkg2Name),file.path(outPath,pkg3Name),platform);createManifestByLevel.2(file.path(outPath,pkg3Name));compressDataPackage(file.path(outPath,pkg3Name))
	}else{
		calBetaValue2(betaFn=bv_Fn,pvalueFn=pv_Fn)
		packagingArray(datPath,datPath)
	}
	return(beta.lvl3)
}

####################
# ADF NOv22,2010 
######################
update_HumanMeth27k.ADF<-function(){
	library(mAnnot)
	getData()
	geneInfo<-data.frame(ilmnid=humanMeth27k$ILmnID,gid=humanMeth27k$GID_Update,gs=as.character(humanMeth27k$Symbol),stringsAsFactors=F)
	row.names(geneInfo)<-geneInfo$ilmnid
	str(geneInfo)
	library(methPipe)
	data(HumanMethylation27.adf)
	names(HumanMethylation27.adf)
	ind<-HumanMethylation27.adf$IlmnID
	geneInfo<-geneInfo[ind,]
	table(geneInfo$gs=="")
	HumanMethylation27.adf$Gene_ID<-geneInfo$gid
	HumanMethylation27.adf$SYMBOL<-geneInfo$gs
	table(is.na(HumanMethylation27.adf$Gene_ID))
	data(lvl3mask)
	names(lvl3mask)
	lvl3mask<-lvl3mask[ind,]
	table(lvl3mask$SYMBOL==HumanMethylation27.adf$SYMBOL)
#	TRUE 
#	27578 
	save(HumanMethylation27.adf,file=file.path("c:\\tcga\\others","HumanMethylation27.adf.rdata"))
	write.table(HumanMethylation27.adf,file=file.path("c:\\tcga\\others","HumanMethylation27.adf.txt"),sep="\t",row.names=F,quote=F)
}
summarry_updating_ADF<-function(){
	load(file=file.path("c:\\tcga\\others\\","HumanMethylation27.adf.rdata"))
	adf2<-HumanMethylation27.adf
	names(adf2)
	load(file=file.path("c:\\tcga\\others","HumanMethylation27.adf.v1.rdata"))
	adf1<-HumanMethylation27.adf
	row.names(adf1)<-adf1$IlmnID
	adf1<-adf1[adf2$IlmnID,]
	all(adf1$IlmnID==adf2$IlmnID)
#	[1] TRUE
	adf1$Gene_ID<-gsub("GeneID:","",adf1$Gene_ID)
	table(adf1$Gene_ID==adf2$Gene_ID)
#	FALSE  TRUE 
#	111 27458
	table(adf1$SYMBOL==adf2$SYMBOL)
#	FALSE  TRUE 
#	234 27344 
	adf<-data.frame(adf1[,c("IlmnID","Gene_ID","SYMBOL")],adf2[,c("Gene_ID","SYMBOL")])
	names(adf)<-c("IlmnID","Gene_ID","SYMBOL","Gene_ID.new","SYMBOL.new")
	adf$Is_GID_Same<-adf$Gene_ID==adf$Gene_ID.new
	table(adf$Is_GID_Same)
	adf$Is_SYMBL_Same<-adf$SYMBOL==adf$SYMBOL.new
	table(adf$Is_SYMBL_Same)
	adf<-adf[order(adf$Is_SYMBL_Same,decreasing=T),]
	write.csv(adf,file="c:\\tcga\\others\\adf_comp.csv")
	
	data(lvl3mask)
	names(lvl3mask)
	lvl3mask<-lvl3mask[adf2$IlmnID,]
	table(lvl3mask$SYMBOL==adf2$SYMBOL)
#	TRUE 
#	27578 
}

# "Tue Feb 08 10:52:10 2011"
updatePkgADF_test<-function(){
	load(file="c:\\tcga\\others\\HumanMethylation27.adf.rdata")
	ADFpkg<-"C:\\tcga\\BRCA\\jhu-usc.edu_BRCA.HumanMethylation27.mage-tab.1.2.0"
	updatePkgADF(ADFpkg,HumanMethylation27.adf)
	
	ADFpkg<-"c:\\tcga\\GBM\\jhu-usc.edu_GBM.HumanMethylation27.mage-tab.1.18.0"
	updatePkgADF(ADFpkg,HumanMethylation27.adf)
	
	ADFpkg<-"c:\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation27.mage-tab.1.2.0"
	updatePkgADF(ADFpkg,HumanMethylation27.adf)
	
	ADFpkg<-"c:\\tcga\\READ\\jhu-usc.edu_READ.HumanMethylation27.mage-tab.1.11.0"
	updatePkgADF(ADFpkg,HumanMethylation27.adf)
	
	ADFpkg<-"C:\\tcga\\OV\\jhu-usc.edu_OV.HumanMethylation27.mage-tab.1.12.0"
	updatePkgADF(ADFpkg,HumanMethylation27.adf)
}
updatePkgADF<-function(ADFpkg,adf=NULL,ver="v2"){
	if(is.null(adf)) adf<-data(HumanMethylation27.adf)
	AdfFn<-list.files(ADFpkg,".adf.txt")
	AdfFn2<-paste(paste(strsplit(AdfFn,"\\.")[[1]][1:3],collapse="."),ver,"adf.txt",sep=".")
	file.remove(file.path(ADFpkg,AdfFn))
	write.table(adf,file=file.path(ADFpkg,AdfFn2),sep="\t",quote=F,row.names=F)
}
createADFmeth450<-function(){
	amFn<-"infinium 450 manifest.csv";wdir<-"C:\\feipan\\manifests\\humanMeth450k"
	manifest<-read.csv(file=file.path(wdir,amFn),row.names=1,stringsAsFactors=F,as.is=T)
	names(manifest);dim(manifest)
	adf.meth450<-manifest[,c("ILMNID","SOURCESEQ","ALLELEA_PROBESEQ","ALLELEB_PROBESEQ","NEXT_BASE","COLOR_CHANNEL","INFINIUM_DESIGN_TYPE","GENOME_BUILD","CHR","MAPINFO","CHROMOSOME_36","COORDINATE_36","STRAND","UCSC_REFGENE_NAME","UCSC_REFGENE_ACCESSION")]
	dim(adf.meth450)
	write.table(adf.meth450,file=file.path(wdir,"HumanMeth450.adf.1.0.txt"),sep="\t",row.names=F,quote=F)
}
##################
#merged
#################
#######################
readArrayMaps_test<-function(){
	amDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\arraymapping"
	dat<-readArrayMaps(amDir)
#	[1] "Plate"                      "BeadChip#"                 
#	[3] "Barcode Terminus"           "Well Position"             
#	[5] "Well Position"              "Infinium Barcode"          
#	[7] "Biospecimen Barcode Side"   "Biospecimen Barcode Bottom"
#	[9] "Tissue Type"                "Histology"                 
#	[11] "TCGA BATCH"                 "Sample ID"                 
#	[13] "Detected Genes (0.01)"      "Detected Genes (0.05)"     
#	[15] "Signal Average GRN"         "Signal Average RED"        
#	[17] "Signal P05 GRN"             "Signal P05 RED"            
#	[19] "Signal P25 GRN"             "Signal P25 RED"            
#	[21] "Signal P50 GRN"             "Signal P50 RED"            
#	[23] "Signal P75 GRN"             "Signal P75 RED"            
#	[25] "Signal P95 GRN"             "Signal P95 RED"            
#	[27] "# OF DROPOUTS"              "% DROPOUTS"  
}
readArrayMaps<-function(amDir){
	amFn<-list.files(amDir,pattern=".csv",recursive=T)
	arrayMappingInfo<-NULL
	for(i in 1:length(amFn)){
		am1<-read.delim(file=file.path(amDir,amFn[i]),sep=",",head=T,as.is=T,check.names=F)
		if(is.null(arrayMappingInfo)){
			arrayMappingInfo<-am1
		}else{
			arrayMappingInfo<-rbind(arrayMappingInfo,am1)
		}
	}
	return(arrayMappingInfo)
}

extractSampleInfo_test<-function(){
	amFn<-"c:\\tcga\\arraymapping\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	samInfo<-extractSampleInfo(amFn)
}
#extractSampleInfo2<-function(amFn,sep=","){
#	am<-read.delim(file=amFn,sep=sep,head=T,as.is=T,check.names=F)
#	plate<-unique(am$Plate)
#	tcgaBatch<-unique(am$"Batch_Number")
#	sampleInfo<-list(Batch_Number=tcgaBatch,Sample.N=nrow(am))
#	return(sampleInfo)
#}
extractSampleInfo<-function(amFn,sep=","){
	am<-read.delim(file=amFn,sep=sep,head=T,as.is=T,check.names=F)
	plate<-unique(am$Plate)
	chipBarcode<-unique(sapply(am$"Infinium Barcode",function(x)strsplit(x,"_")[[1]][1]))
	tcgaBatch<-unique(am$"TCGA BATCH")
	cancerType<-unique(am$Histology)
	cancerType.n<-table(am$Histology)
	tcgaSampleID<-am$"Biospecimen Barcode Side"
	sampleID<-am$"Sample ID"
	sampleCode<-tcgaSampleID
	names(sampleCode)<-sampleID
	sampleInfo<-list(chipBarCode=chipBarcode,sampleCode=sampleCode,sampleID=sampleID,tcgaSampleID=tcgaSampleID,cancerType=cancerType,cancerType.n=cancerType.n,tcgaBatch=tcgaBatch,plate=plate,sampleInfo=am)
	return(sampleInfo)
}
createDescription.2_test<-function(){
	arrayMapFn<-"C:\\tcga\\others\\arraymapping\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	descript<-createDescription.2(arrayMapFn)
	arrayMapFn<-"C:\\tcga\\others\\arraymapping\\jhu-usc.edu_HNSC.HumanMethylation450.1.0.0.csv"
	descript<-createDescription.2(arrayMapFn,platform="meth450k")
}
createDescription.2<-function(arrayMapFn=NULL,pkgMap=NULL,batch=NULL,pkgSamp.N=NULL,platform="meth27k"){
	sampleInfo<-NULL
	if(!is.null(arrayMapFn)){
		sampInfo<-readPlateMap(arrayMapFn)
	}else if(!is.null(pkgMap)){
		sampInfo<-readPackageMap(pkgMap)
	}
	if(is.null(pkgSamp.N))pkgSamp.N<-nrow(sampInfo)
	if(is.null(batch))batch<-unique(sampInfo$Batch_Number)
	if(length(batch)>1) batch<-paste(batch,collapse=",")
	
	date1<-paste(strsplit(date()," ")[[1]][c(2,3,5)],collapse=" ")
	header<-paste("The data archive contains The Cancer Genome Atlas (TCGA) analysis of DNA methylation profilings using the IIllumina Infinium Human DNA Methylation27 platform. The Infinium platform analyzes up to 27,578 CpG dinucleotides spanning the entire set of 14,495 Consensus Coding DNA Sequence (CCDS) genes. DNA samples were received, bisulfite converted and the methylation profiling was evaluated using IIllumina Infinium Human DNA Methylation27 technology.\n",
			"This archive contains Infinium-based DNA methylation data for ",pkgSamp.N," samples from Batch ",batch,".\n",sep="")
	description_lvl_1<-paste(header, "LEVEL 1 data contain the non-background corrected signal intensities of the methylated (M) and unmethylated (U) probes and the mean negative control cy5 (red) and cy3 (green) signal intensities. We also provide a detection p-value for each data point. The Detection p-values provide an indication of DNA methylation measurement quality for each locus and are calculated based on the difference in signal intensity of each probe compared to the set of negative control probes. Specifically, the p-value is calculated using a Z-test by comparing the methylated and unmethylated signal intensities to the mean(red) or mean(green) of the 16 negative control probes on the array. The choice of red or green is determined by the nucleotide immediately upstream of the targeted CpG site. The color channel for each probe is listed in the manifest as well as Level 3 data files. Measurements for which the minimum detection p-value is less than 0.05 for M and U are considered to have a signal intensity significantly above background. We also include the number of replicate beads for methylated and unmethylated bead types as well as the standard error of methylated and unmethylated signal intensities. Similar values are also provided for the negative control probes.\n",date1,"\n",sep="")
	description_lvl_2<-paste(header,"LEVEL 2 data files contain the beta value calculations for each probe and sample, calculated as: Beta = M/(M+U), using non-background corrected data. In this formula, M and U represent the mean signal intensities for replicate methylated (M) and unmethylated (U) probes on the array. Data points with a detection p-value >= 0.05 are masked as \"NA\", and represent beta values with non-significant detection of DNA methylation compared to background. Please note that we use a slightly different formula for calculating the beta value than Illumina BeadStudio or GenomeStudio software.\n",date1,"\n",sep="")
	description_lvl_3<-paste(header,"LEVEL 3 data contain beta value calculations, gene IDs and genomic coordinates for each probe on the array. In addition, we have masked data for probes that contain known single nucleotide polymorphisms (SNPs) after comparison to the dbSNP database (Build 130). In addition, we have masked data for probes that contain repetitive element DNA sequences that cover the targeted CpG dinucleotide in each 50 bp probe sequence. We have also masked probes that are not uniquely aligned to the human genome (build 36) at 20 nucleotides at the 3' terminus of the probe sequence, as well as those that span known regions of insertions and deletions (indells) in the human genome. Data points from probes containing SNPs, repetitive elements, other non-unique sequences and/or indells are masked with an \"NA\" descriptor.\n",date1,"\n",sep="")
	if(platform=="meth450k"){
		header<-paste("The data archive contains The Cancer Genome Atlas (TCGA) analysis of DNA methylation profilings using the IIllumina Infinium Human DNA Methylation450 platform. The Infinium platform analyzes up to 485,577 CpG dinucleotides. DNA samples were received, bisulfite converted and the methylation profiling was evaluated using IIllumina Infinium Human DNA Methylation450 technology.\n",
				"This archive contains Infinium-based DNA methylation data for ",pkgSamp.N," samples from Batch ",batch,".\n",sep="")
		description_lvl_1<-paste(header, "LEVEL 1 data contain the non-background corrected signal intensities of the methylated (M) and unmethylated (U) probes, and the number of methylated and unmethylated beads. We also provide a detection p-value for each data point. The Detection p-values provide an indication of DNA methylation measurement quality for each locus and are calculated based on the difference in signal intensity of each probe compared to the set of negative control probes. Specifically, the p-value is calculated by comparing the methylated and unmethylated signal intensities to the mean signal intensity of the corresponding negative control probes on the array. Measurements for which the minimum detection p-value is less than 0.05 for M and U are considered to have a signal intensity significantly above background.\n",date1,"\n",sep="")
		description_lvl_2<-paste(header,"LEVEL 2 data files contain the beta value calculations for each probe and sample, calculated as: Beta = M/(M+U), using non-background corrected data. In this formula, M and U represent the mean signal intensities for replicate methylated (M) and unmethylated (U) probes on the array. Data points with a detection p-value >= 0.05 are masked as \"NA\", and represent beta values with non-significant detection of DNA methylation compared to background. Please note that we use a slightly different formula for calculating the beta value than Illumina GenomeStudio software.\n",date1,"\n",sep="")
		description_lvl_3<-paste(header,"LEVEL 3 data contain beta value calculations, gene symbols, geneIDs and genomic coordinates for each probe on the array. In addition, we also have masked data for probes that contain known single nucleotide polymorphisms (SNPs) after comparison to the dbSNP database (Build 131). In addition, we have masked data for probes that contain repetitive element DNA sequences that cover the targeted CpG dinucleotide in each 50 bp probe sequence. We have also masked probes that are not uniquely aligned to the human genome (build 37) of each 50 bp probe sequence, as well as those that span known regions of insertions and deletions (indells) in the human genome. Data points from probes containing SNPs, repetitive elements, other non-unique sequences and/or indells are masked with an \"NA\" descriptor.\n",date1,"\n",sep="")
	}
	description<-c(lvl_1=description_lvl_1,lvl_2=description_lvl_2,lvl_3=description_lvl_3)
	description<-c(lvl_1=description_lvl_1,lvl_2=description_lvl_2,lvl_3=description_lvl_3)
	return(description)
}

createDescription.2.1<-function(arrayMapFn=NULL,pkgMap=NULL,batch=NULL,pkgSamp.N=NULL,platform="meth27k"){
	sampleInfo<-NULL
	if(!is.null(arrayMapFn)){
		sampInfo<-readPlateMap(arrayMapFn)
	}else if(!is.null(pkgMap)){
		sampInfo<-readPackageMap(pkgMap)
	}
	if(is.null(pkgSamp.N))pkgSamp.N<-nrow(sampInfo)
	if(is.null(batch))batch<-unique(sampInfo$Batch_Number)
	if(length(batch)>1) batch<-paste(batch,collapse=",")
	
	date1<-paste(strsplit(date()," ")[[1]][c(2,3,5)],collapse=" ")
	header<-paste("The data archive contains The Cancer Genome Atlas (TCGA) analysis of DNA methylation profilings using the IIllumina Infinium Human DNA Methylation27 platform. The Infinium platform analyzes up to 27,578 CpG dinucleotides spanning the entire set of 14,495 Consensus Coding DNA Sequence (CCDS) genes. DNA samples were received, bisulfite converted and the methylation profiling was evaluated using IIllumina Infinium Human DNA Methylation27 technology.\n",
			"This archive contains Infinium-based DNA methylation data for ",pkgSamp.N," samples from Batch ",batch,".\n",sep="")
	description_lvl_1<-paste(header, "LEVEL 1 data contain the non-background corrected signal intensities of the methylated (M) and unmethylated (U) probes and the mean negative control cy5 (red) and cy3 (green) signal intensities. We also provide a detection p-value for each data point. The Detection p-values provide an indication of DNA methylation measurement quality for each locus and are calculated based on the difference in signal intensity of each probe compared to the set of negative control probes. Specifically, the p-value is calculated using a Z-test by comparing the methylated and unmethylated signal intensities to the mean(red) or mean(green) of the 16 negative control probes on the array. The choice of red or green is determined by the nucleotide immediately upstream of the targeted CpG site. The color channel for each probe is listed in the manifest as well as Level 3 data files. Measurements for which the minimum detection p-value is less than 0.05 for M and U are considered to have a signal intensity significantly above background. We also include the number of replicate beads for methylated and unmethylated bead types as well as the standard error of methylated and unmethylated signal intensities. Similar values are also provided for the negative control probes.\n",date1,"\n",sep="")
	description_lvl_2<-paste(header,"LEVEL 2 data files contain the beta value calculations for each probe and sample, calculated as: Beta = M/(M+U), using non-background corrected data. In this formula, M and U represent the mean signal intensities for replicate methylated (M) and unmethylated (U) probes on the array. Data points with a detection p-value >= 0.05 are masked as \"NA\", and represent beta values with non-significant detection of DNA methylation compared to background. Please note that we use a slightly different formula for calculating the beta value than Illumina BeadStudio or GenomeStudio software.\n",date1,"\n",sep="")
	description_lvl_3<-paste(header,"LEVEL 3 data contain beta value calculations, gene IDs and genomic coordinates for each probe on the array. In addition, we have masked data for probes that contain known single nucleotide polymorphisms (SNPs) after comparison to the dbSNP database (Build 130). In addition, we have masked data for probes that contain repetitive element DNA sequences that cover the targeted CpG dinucleotide in each 50 bp probe sequence. We have also masked probes that are not uniquely aligned to the human genome (build 36) at 20 nucleotides at the 3' terminus of the probe sequence, as well as those that span known regions of insertions and deletions (indells) in the human genome. Data points from probes containing SNPs, repetitive elements, other non-unique sequences and/or indells are masked with an \"NA\" descriptor.\n",date1,"\n",sep="")
	if(platform=="meth450k"){
		header<-paste("The data archive contains The Cancer Genome Atlas (TCGA) analysis of DNA methylation profilings using the IIllumina Infinium Human DNA Methylation450 platform. The Infinium platform analyzes up to 482,421 CpG dinucleotides. DNA samples were received, bisulfite converted and the methylation profiling was evaluated using IIllumina Infinium Human DNA Methylation450 technology.\n",
				"This archive contains Infinium-based DNA methylation data for ",pkgSamp.N," samples from Batch ",batch,".\n",sep="")
		description_lvl_1<-paste(header, "LEVEL 1 data contain the non-background corrected signal intensities of the methylated (M) and unmethylated (U) probes and the mean negative control cy5 (red) and cy3 (green) signal intensities. We also provide a detection p-value for each data point. The Detection p-values provide an indication of DNA methylation measurement quality for each locus and are calculated based on the difference in signal intensity of each probe compared to the set of negative control probes. Specifically, the p-value is calculated by comparing the methylated and unmethylated signal intensities to the mean(red) or mean(green) of the negative control probes on the array. The choice of red or green is determined by the nucleotide immediately upstream of the targeted CpG site. The color channel for each probe is listed in the manifest as well as Level 3 data files. Measurements for which the minimum detection p-value is less than 0.05 for M and U are considered to have a signal intensity significantly above background.\n",date1,"\n",sep="")
		description_lvl_2<-paste(header,"LEVEL 2 data files contain the beta value calculations for each probe and sample, calculated as: Beta = M/(M+U), using non-background corrected data. In this formula, M and U represent the mean signal intensities for replicate methylated (M) and unmethylated (U) probes on the array. Data points with a detection p-value >= 0.05 are masked as \"NA\", and represent beta values with non-significant detection of DNA methylation compared to background. Please note that we use a slightly different formula for calculating the beta value than Illumina BeadStudio or GenomeStudio software.\n",date1,"\n",sep="")
		description_lvl_3<-paste(header,"LEVEL 3 data contain beta value calculations, gene IDs and genomic coordinates for each probe on the array. In addition, we have masked data for probes that contain known single nucleotide polymorphisms (SNPs) after comparison to the dbSNP database (Build 131). In addition, we have masked data for probes that contain repetitive element DNA sequences that cover the targeted CpG dinucleotide in each 50 bp probe sequence. We have also masked probes that are not uniquely aligned to the human genome (build 37) of each 50 bp probe sequence, as well as those that span known regions of insertions and deletions (indells) in the human genome. Data points from probes containing SNPs, repetitive elements, other non-unique sequences and/or indells are masked with an \"NA\" descriptor.\n",date1,"\n",sep="")
	}
	description<-c(lvl_1=description_lvl_1,lvl_2=description_lvl_2,lvl_3=description_lvl_3)
	description<-c(lvl_1=description_lvl_1,lvl_2=description_lvl_2,lvl_3=description_lvl_3)
	return(description)
}



createDescription<-function(amFn){
	sampInfo<-extractSampleInfo(amFn)
	d1<-sampInfo$cancerType.n[order(sampInfo$cancerType.n,decreasing=T)]
	d2<-paste(d1,names(d1),collapse=", ")
	batch<-paste(sampInfo$tcgaBatch,collapse=",")
	date1<-paste(strsplit(date()," ")[[1]][c(2,3,5)],collapse=" ")
	header<-paste("The data archive contains The Cancer Genome Atlas (TCGA) analysis of DNA methylation profilings using the IIllumina Infinium Human DNA Methylation27 platform. The Infinium platform analyzes up to 27,578 CpG dinucleotides spanning the entire set of 14,495 Consensus Coding DNA Sequence (CCDS) genes. DNA samples were received, bisulfite converted and the methylation profiling was evaluated using IIllumina Infinium Human DNA Methylation27 technology.\n",
			"This archive contains Infinium-based DNA methylation data for ",d2," from Batch ",batch,".\n",sep="")
	description_lvl_1<-paste(header, "LEVEL 1 data contain the non-background corrected signal intensities of the methylated (M) and unmethylated (U) probes and the mean negative control cy5 (red) and cy3 (green) signal intensities. We also provide a detection p-value for each data point. The Detection p-values provide an indication of DNA methylation measurement quality for each locus and are calculated based on the difference in signal intensity of each probe compared to the set of negative control probes. Specifically, the p-value is calculated using a Z-test by comparing the methylated and unmethylated signal intensities to the mean(red) or mean(green) of the 16 negative control probes on the array. The choice of red or green is determined by the nucleotide immediately upstream of the targeted CpG site. The color channel for each probe is listed in the manifest as well as Level 3 data files. Measurements for which the minimum detection p-value is less than 0.05 for M and U are considered to have a signal intensity significantly above background. We also include the number of replicate beads for methylated and unmethylated bead types as well as the standard error of methylated and unmethylated signal intensities. Similar values are also provided for the negative control probes.\n",date1,"\n",sep="")
	description_lvl_2<-paste(header,"LEVEL 2 data files contain the beta value calculations for each probe and sample, calculated as: Beta = M/(M+U), using non-background corrected data. In this formula, M and U represent the mean signal intensities for replicate methylated (M) and unmethylated (U) probes on the array. Data points with a detection p-value > 0.05 are masked as \"NA\", and represent beta values with non-significant detection of DNA methylation compared to background. Please note that we use a slightly different formula for calculating the beta value than Illumina BeadStudio or GenomeStudio software.\n",date1,"\n",sep="")
	description_lvl_3<-paste(header,"LEVEL 3 data contain beta value calculations, gene IDs and genomic coordinates for each probe on the array. In addition, we have masked data for probes that contain known single nucleotide polymorphisms (SNPs) after comparison to the dbSNP database (Build 130). In addition, we have masked data for probes that contain repetitive element DNA sequences that cover the targeted CpG dinucleotide in each 50 bp probe sequence.We have also masked probes that are not uniquely aligned to the human genome (build 36) at 20 nucleotides at the 3' terminus of the probe sequence, as well as those that span known regions of insertions and deletions (indells) in the human genome. Data points from probes containing SNPs, repetitive elements, other non-unique sequences and/or indells are masked with an \"NA\" descriptor.\n",date1,"\n",sep="")
	description<-c(lvl_1=description_lvl_1,lvl_2=description_lvl_2,lvl_3=description_lvl_3)
	return(description)
}
createPkgDescription_test<-function(){
	pkgPath<-"C:\\temp\\jhu-usc.edu_STAD.HumanMethylation27.1"
	arraymapping<-"c:\\tcga\\others\\arraymapping\\bk\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	createPkgDescription(pkgPath,arraymapping)
	
	pkgMapFn<-"C:\\tcga\\others\\arraymapping\\packagemap.txt"
	packmap<-read.delim(file=pkgMapFn,sep="\t",as.is=T,stringsAsFactors=F)
	packmap<-packmap[packmap$Package_lvl.1=="jhu-usc.edu_STAD.HumanMethylation27.Level_1.1.0.0",]
	createPkgDescription(pkgPath,packageMap=packmap)
	
	pkgPath<-"C:\\temp\\IDAT\\tcga\\OV\\jhu-usc.edu_OV.HumanMethylation450.1.0.0"
	arraymapping<-"c:\\tcga\\others\\arraymapping\\bk\\jhu-usc.edu_OV.HumanMethylation450.1.0.0.csv"
	createPkgDescription(pkgPath,arraymapping,platform="meth450k")
	
	packageMapFn<-"C:\\tcga\\others\\arraymapping\\meth450\\packagemap.txt"
	packmaps<-readPackageMap(packageMapFn,platform="meth450k")
	pkgPath<-"C:\\temp\\IDAT\\meth450k\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0"
	createPkgDescription(pkgPath,packageMap=packmaps,platform="meth450k")
	createPkgDescription(pkgPath,batch="25",platform="meth450k")
	
	pkgPath<-"C:\\temp\\IDAT\\meth450k\\tcga\\COAD"
	createPkgDescription(pkgPath,batch="76",platform="meth450k")
}
createPkgDescription<-function(pkgPath,arraymapping=NULL,packageMap=NULL,batch=NULL,platform="meth27k"){
	pkgs<-list.files(pkgPath,patt=".tar.gz")
	pkgs<-pkgs[-grep(".md5",pkgs)]
	if(length(pkgs)<1){
		cat(paste("There is no data package file in the package folder",pkgPath,"\n"))
		return()
	}
	pkg1<-pkgs[grep("Level_1",pkgs)];pkg2<-pkgs[grep("Level_2",pkgs)];pkg3<-pkgs[grep("Level_3",pkgs)]
	pkg1Name<-gsub(".tar.gz","",pkg1);if(!file.exists(file.path(pkgPath,pkg1Name)))uncompress(pkg1,pkgPath)
	pkg2Name<-gsub(".tar.gz","",pkg2);if(!file.exists(file.path(pkgPath,pkg2Name)))uncompress(pkg2,pkgPath)
	pkg3Name<-gsub(".tar.gz","",pkg3);if(!file.exists(file.path(pkgPath,pkg3Name)))uncompress(pkg3,pkgPath)
	des<-NULL;fn<-"DESCRIPTION.txt"
	datFn<-list.files(file.path(pkgPath,pkg1Name))
	pkgSamp.N<-length(grep("jhu-usc",datFn))
	if(!is.null(packageMap))des<-createDescription.2(pkgMap=packageMap,pkgSamp.N=pkgSamp.N,platform=platform)
	else if(!is.null(batch))des<-createDescription.2(batch=batch,pkgSamp.N=pkgSamp.N,platform=platform)
	else des<-createDescription.2(arraymapping,pkgSamp.N=pkgSamp.N,platform=platform)
	if(!is.null(pkg1Name)){
		write(des["lvl_1"],file=file.path(pkgPath,pkg1Name,fn))
		createManifestByLevel.2(file.path(pkgPath,pkg1Name))
		compressDataPackage(file.path(pkgPath,pkg1Name))
	}
	if(!is.null(pkg2Name)){
		write(des["lvl_2"],file=file.path(pkgPath,pkg2Name,fn))
		createManifestByLevel.2(file.path(pkgPath,pkg2Name))
		compressDataPackage(file.path(pkgPath,pkg2Name))
	}
	if(!is.null(pkg3Name)){
		write(des["lvl_3"],file=file.path(pkgPath,pkg3Name,fn))
		createManifestByLevel.2(file.path(pkgPath,pkg3Name))
		compressDataPackage(file.path(pkgPath,pkg3Name))
	}
}

createPkgDescription.1<-function(pkgPath,arraymapping,packageMap=NULL,platform="meth27k"){
	pkgs<-list.files(pkgPath,patt=".tar.gz")
	pkgs<-pkgs[-grep(".md5",pkgs)]
	if(length(pkgs)<1){
		cat(paste("There is no data package file in the package folder",pkgPath,"\n"))
		return()
	}
	pkg1<-pkgs[grep("Level_1",pkgs)];pkg2<-pkgs[grep("Level_2",pkgs)];pkg3<-pkgs[grep("Level_3",pkgs)]
	pkg1Name<-gsub(".tar.gz","",pkg1);if(!file.exists(file.path(pkgPath,pkg1Name)))uncompress(pkg1,pkgPath)
	pkg2Name<-gsub(".tar.gz","",pkg2);if(!file.exists(file.path(pkgPath,pkg2Name)))uncompress(pkg2,pkgPath)
	pkg3Name<-gsub(".tar.gz","",pkg3);if(!file.exists(file.path(pkgPath,pkg3Name)))uncompress(pkg3,pkgPath)
	if(!is.null(packageMap))create_Level_Description_File.2(pkgPath,pkg1Name,pkg2Name,pkg3Name,pkgMap=packageMap,platform=platform)
	else create_Level_Description_File.2(pkgPath,pkg1Name,pkg2Name,pkg3Name,arraymapping,platform=platform)
}

create_Level_Description_File.2_test<-function(){
	am<-"c:\\tcga\\arraymapping\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	pkg_folder<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\jhu-usc.edu_STAD.HumanMethylation27.1"
	create_Level_Description_File.2(pkg_folder,f1,f2,f3,am)
	
	am<-"c:\\tcga\\others\\arraymapping\\meth450\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv"
	pkg_folder<-"C:\\temp\\IDAT\\meth450k\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0"
	f1<-"jhu-usc.edu_LAML.HumanMethylation450.Level_1.1.0.0"
	f2<-"jhu-usc.edu_LAML.HumanMethylation450.Level_2.1.0.0"
	f3<-"jhu-usc.edu_LAML.HumanMethylation450.Level_3.1.0.0"
	create_Level_Description_File.2(pkg_folder,f1,f2,f3,am,platform="meth450k")
}
create_Level_Description_File.2<-function(pkg_folder,lvl_1_fd,lvl_2_fd,lvl_3_fd,arraymapping,pkgMap=NULL,platform="meth27k"){
	des<-NULL
	datFn<-list.files(file.path(pkg_folder,lvl_1_fd))
	pkgSamp.N<-length(grep("jhu-usc",datFn))
	if(!is.null(pkgMap))des<-createDescription.2(pkgMap=pkgMap,pkgSamp.N=pkgSamp.N,platform=platform)
	else des<-createDescription.2(arraymapping,pkgSamp.N=pkgSamp.N,platform=platform)
	fn<-"DESCRIPTION.txt"
	if(!is.null(lvl_1_fd)){
		write(des["lvl_1"],file=file.path(pkg_folder,lvl_1_fd,fn))
		createManifestByLevel.2(file.path(pkg_folder,lvl_1_fd))
		compressDataPackage(file.path(pkg_folder,lvl_1_fd))
	}
	if(!is.null(lvl_2_fd)){
		write(des["lvl_2"],file=file.path(pkg_folder,lvl_2_fd,fn))
		createManifestByLevel.2(file.path(pkg_folder,lvl_2_fd))
		compressDataPackage(file.path(pkg_folder,lvl_2_fd))
	}
	if(!is.null(lvl_3_fd)){
		write(des["lvl_3"],file=file.path(pkg_folder,lvl_3_fd,fn))
		createManifestByLevel.2(file.path(pkg_folder,lvl_3_fd))
		compressDataPackage(file.path(pkg_folder,lvl_3_fd))
	}
}
create_Level_Description_File.2.1<-function(pkg_folder,lvl_1_fd,lvl_2_fd,lvl_3_fd,arraymapping,pkgMap=NULL,platform="meth27k"){
	des<-NULL
	if(!is.null(pkgMap))des<-createDescription.2(pkgMap=pkgMap,platform=platform)
	else des<-createDescription.2(arraymapping,platform=platform)
	fn<-"DESCRIPTION.txt"
	if(!is.null(lvl_1_fd)){
		write(des["lvl_1"],file=file.path(pkg_folder,lvl_1_fd,fn))
		createManifestByLevel.2(file.path(pkg_folder,lvl_1_fd))
		compressDataPackage(file.path(pkg_folder,lvl_1_fd))
	}
	if(!is.null(lvl_2_fd)){
		write(des["lvl_2"],file=file.path(pkg_folder,lvl_2_fd,fn))
		createManifestByLevel.2(file.path(pkg_folder,lvl_2_fd))
		compressDataPackage(file.path(pkg_folder,lvl_2_fd))
	}
	if(!is.null(lvl_3_fd)){
		write(des["lvl_3"],file=file.path(pkg_folder,lvl_3_fd,fn))
		createManifestByLevel.2(file.path(pkg_folder,lvl_3_fd))
		compressDataPackage(file.path(pkg_folder,lvl_3_fd))
	}
}
#create_Level_Description_File.2<-function(pkg_folder,lvl_1_fd,lvl_2_fd,lvl_3_fd,arraymapping,pkgMap=NULL,platform="meth27k"){
#	des<-NULL
#	if(!is.null(pkgMap))des<-createDescription.2(pkgMap=pkgMap,platform=platform)
#	else des<-createDescription.2(arraymapping,platform=platform)
#	fn<-"DESCRIPTION.txt"
#	write(des["lvl_1"],file=file.path(pkg_folder,lvl_1_fd,fn))
#	write(des["lvl_2"],file=file.path(pkg_folder,lvl_2_fd,fn))
#	write(des["lvl_3"],file=file.path(pkg_folder,lvl_3_fd,fn))
#}
createManifestByLevel.2a_test<-function(){
	pkg_folder<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\5543207013\\jhu-usc.edu_STAD.HumanMethylation27.1\\jhu-usc.edu_STAD.HumanMethylation27.mage-tab.1.1.0"
	createManifestByLevel.2a(pkg_folder)
}
createManifestByLevel.2a<-function(pkg_folder,lvl_folder=NULL){
	if(R.Version()$os=="mingw32"){
		createManifestByLevel.2(pkg_folder,lvl_folder)
	}else{
		setwd(pkg_folder)
		if(!is.null(lvl_folder))setwd(file.path(pkg_folder,lvl_folder))
		cmd<-"md5sum *.* > MANIFEST.txt"
		system(cmd)
	}
}
compressDataPackage.2_test<-function(){
	pkg_folder<-"c:\\temp\\4698"
	compressDataPackage.2(pkg_folder)
	pkg_folder<-"/auto/uec-02/shared/production/methylation/meth27k/3435323"
	compressDataPackage.2(pkg_folder)
	pkg_folder<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\5543207013\\jhu-usc.edu_STAD.HumanMethylation27.1\\jhu-usc.edu_STAD.HumanMethylation27.mage-tab.1.1.0"
	compressDataPackage.2(pkg_folder)
}
#####
# rapid.pro
######
compressDataPackage.2<-function(pkg_folder,lvl_fdname=NULL){
	if(is.null(lvl_fdname)){
		lvl_fdname<-filetail(pkg_folder)
		pkg_folder<-filedir(pkg_folder)
	}
	setwd(pkg_folder)
	tar<-"tar"
	gzip<-"gzip"
	md5sum<-"md5sum"
	if(R.Version()$os=="mingw32"){
		tool<-system.file("Rtools",package="rapid.pro")
		tar<-file.path(tool,"tar")
		gzip<-file.path(tool,"gzip")
		md5sum<-file.path(tool,"md5sum")
	}
	command <- paste(tar," -cvf ",lvl_fdname,".tar ",lvl_fdname,sep="")
	system(command,wait=T)
	command <- paste(gzip," -f ",lvl_fdname,".tar ",sep="")
	system(command,wait=T)
	command <- paste(md5sum," ",lvl_fdname,".tar.gz>",lvl_fdname,".tar.gz.md5",sep="")
	if(R.Version()$os=="mingw32"){
		shell(command)
	}else{
		system(command)
	}
}
compressTCGAPkg<-function(pkgPath){
	pkgs<-list.files(pkgPath,patt=".Level|.mage-tab")
	pkgs<-pkgs[!grepl(".tar|.rda|.txt|.csv",pkgs)]
	for(pkg in pkgs){
		createManifestByLevel.2(file.path(pkgPath,pkg))
		compressDataPackage.2(file.path(pkgPath,pkg))
	}
}
########
#
########
updateMagepackages_test<-function(){
	sampleFn<-"c:\\temp\\sampleInfo.txt"
	sampleFn<-"C:\\temp\\IDAT\\meth450k\\arraymapping\\samplePlateInfo.txt"
	magePkg<-"C:\\temp\\IDAT\\tcga\\LAML\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0\\jhu-usc.edu_LAML.HumanMethylation450.mage-tab.1.0.0"
	updateMagePackages(magePkg,sampleFn)
}
updateMagePackages<-function(magePkg,sampleFn){
	sdrfn<-list.files(magePkg,patt="sdrf")
	sdrf<-read.delim(file=file.path(magePkg,sdrfn),sep="\t",check.names=F,stringsAsFactors=F)
	samp<-read.delim(file=sampleFn,sep="\t",check.names=F,stringsAsFactors=F)
	samp.name<-names(samp)
	names(samp)<-paste("Comment [",samp.name,"]",sep="")
	sdrf2<-merge(sdrf,samp,by.x=1,by.y=1,all.x=T)
	write.table(sdrf2,file=file.path(magePkg,sdrfn),sep="\t",row.names=F,quote=F)
	createManifestByLevel.2(magePkg)
	compressDataPackage(magePkg)
}

createPlateMap_test<-function(){
	#meth450
	outPath<-"c:\\tcga\\others\\arraymapping\\meth450"
	outPath<-"c:\\temp"
	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\meth450k\\1018 (TCGA-82).csv"
	outFn<-"plate_1018.csv"

	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\meth450k\\091 (TCGA-68).csv"
	outFn<-"plate_091.csv"

	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\meth450k\\090 (TCGA-63 TCGA-81 re-do.csv"
	outFn<-"plate_090.csv"

	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\meth450k\\1026 (TCGA-70)re-do.csv"
	outFn<-"plate_1026.csv"
	pl<-createPlateMap(datFn,outPath,outFn)
	pl<-createPlateMap(datFn,outPath)
	
	#meth27
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k"
	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k\\073 (TCGA-63, TCGA-61).csv"
	outFn<-"plate_073.csv"
	
	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k\\076 (TCGA-72, TCGA-61).csv"
	outFn<-"plate_076.csv"
	
	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k\\079 (TCGA-73, TCGA-74, TCGA-47 Normals).csv"
	outFn<-"plate_079.csv"

	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k\\080 (TCGA-68).csv"
	outFn<-"plate_080.csv"

	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k\\094 (TCGA-82).csv"
	outFn<-"plate_094.csv"
	
	datFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\27k\\082 (TCGA-76, TCGA-67, UCSF-36).csv"
	outFn<-"plate_082.csv"
	pl<-createPlateMap.2(datFn,outPath,outFn)
	
	outPath<-"c:\\temp"

	createPlateMap.2<-function(datFn,outPath,outFn=NULL,am=T){
		plate<-read.delim(datFn,stringsAsFactors=F,as.is=T,sep=",")
		plate<-plate[!is.na(plate$Plate),];dim(plate); 
		dat<-plate[,c(3,4,12,16,15,17,1,6)]
		plate<-plate[,c(15,4,3,11,14,13)]
		names(plate)<-c("Batch_Number","chip_id","well_position","Sample_ID","cancer","abbreviation")
		plate$chip_id<-sapply(plate$chip_id,function(x)strsplit(x,"_")[[1]][1])
		if(!is.null(outFn))write.csv(plate,file=file.path(outPath,outFn),quote=F,row.names=F)
		if(am==T){
			names(dat)<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation","plateLIMSID","plateposition")
			write.table(dat,file=file.path(outPath,"sample_mapping.txt"),quote=F,row.names=F,sep="\t")
		}
		return(unique(plate$chip_id))
	}
	
	createPlateMap<-function(datFn,outPath,outFn=NULL,am=T){
		plate<-read.delim(datFn,stringsAsFactors=F,as.is=T,sep=",")
		plate<-plate[!is.na(plate$Plate),];dim(plate); 
		if(!is.null(plate$Disease.Abbreviation))plate<-plate[plate$Disease.Abbreviation=="KIRC",]
		table(plate$TCGA.BATCH); 
		dat<-plate[,c(3,4,12,16,15,17,1,6)]
		plate<-plate[,c(16,3,4,12,15,17)]
		names(plate)<-c("Batch_Number","chip_id","well_position","Sample_ID","cancer","abbreviation")
		plate$abbreviation="KIRC"
		if(!is.null(outFn))write.csv(plate,file=file.path(outPath,outFn),quote=F,row.names=F)
		if(am==T){
			names(dat)<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation","plateLIMSID","plateposition")
			dat$abbreviation="KIRC"
			write.table(dat,file=file.path(outPath,"sample_mapping.txt"),quote=F,row.names=F,sep="\t")
		}
		#return(unique(plate$chip_id))
		return(plate)
	}

#	createPlateMap.090<-function(datFn,outPath,outFn=NULL,am=T){
#		plate<-read.delim(datFn,stringsAsFactors=F,as.is=T,sep=",")
#		plate<-plate[!is.na(plate$Plate),];dim(plate); 
#		if(!is.null(plate$Disease.Abbreviation))plate<-plate[plate$Disease.Abbreviation=="KIRC",]
#		table(plate$TCGA.BATCH); 
#		dat<-plate[,c(3,4,12,16,15,17,1,6)]
#		plate<-plate[,c(16,3,4,12,15,17)]
#		names(plate)<-c("Batch_Number","chip_id","well_position","Sample_ID","cancer","abbreviation")
#		plate$abbreviation="KIRC"
#		if(!is.null(outFn))write.csv(plate,file=file.path(outPath,outFn),quote=F,row.names=F)
#		if(am==T){
#			names(dat)<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation","plateLIMSID","plateposition")
#			write.table(dat,file=file.path(outPath,"sample_mapping.txt"),quote=F,row.names=F,sep="\t")
#		}
#		#return(unique(plate$chip_id))
#		return(plate)
#	}
	
}