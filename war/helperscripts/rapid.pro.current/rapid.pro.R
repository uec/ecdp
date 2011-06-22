# TODO: Add comment
# 
# Author: feipan
#
# R(-based) Automated Pipeline for DNA-methylation (RAPiD) Pro 
###############################################################################

rapid.pro <-function(rawPath=NULL,procPath=NULL,pkgPath=NULL,arrayPath=NULL,batchPath=NULL,tcgaPath=NULL,reposPath=NULL,bp.method="filter.min",qc.plot=T,toMscan=F,toPkg=F,platform="meth27k",inc=T,update=F,plateMapFn=NULL,packageMapFn=NULL,negCtrCode=NULL,summaryParam=c("z-score"),datDir=NULL,toSubmit=F,dataType="TXT"){
	if(is.null(datDir))datDir<-"/auto/uec-02/shared/production/methylation/"
	if(!file.exists(file.path(datDir,platform))) dir.create(file.path(datDir,platform))
	if(is.null(rawPath)) rawPath<-file.path(datDir,platform,"raw")
	if(is.null(procPath)) procPath<-file.path(datDir,platform,"processed")
	if(is.null(pkgPath)) pkgPath<-file.path(datDir,platform,"packaged")
	if(is.null(arrayPath)) arrayPath<-file.path(datDir,platform,"arraymapping")
	if(is.null(tcgaPath)) tcgaPath<-file.path(datDir,platform,"tcga")
	if(is.null(batchPath)) batchPath<-file.path(datDir,platform,"batches")
	if(is.null(reposPath)) reposPath<-file.path(datDir,platform,"repository")
	if(is.null(plateMapFn)) plateMapFn<-file.path(arrayPath,"platemap.txt") 
	if(is.null(packageMapFn)) packageMapFn<-file.path(arrayPath,"packagemap.txt")
	if(!file.exists(rawPath)) dir.create(rawPath)
	if(!file.exists(procPath)) dir.create(procPath)
	if(!file.exists(pkgPath)) dir.create(pkgPath)
	if(!file.exists(arrayPath)) dir.create(arrayPath)
	if(!file.exists(batchPath)) dir.create(batchPath)
	data.chips<-list.files(rawPath)
	processed.chips<-list.files(procPath)
	if(inc==T){
		data.chips<-data.chips[!is.element(data.chips,processed.chips)]
		if(update==T)updateRawArrays(procPath,arrayPath,pkgPath,batchPath,tcgaPath,rawPath,platform)
		updateBatches(data.chips,arrayPath,batchPath,tcgaPath)
	}
	for(chip in data.chips){
		if(!file.exists(file.path(procPath,chip))) dir.create(file.path(procPath,chip))
		if(!file.exists(file.path(pkgPath,chip)))  dir.create(file.path(pkgPath,chip))
		mData<-procRawArray(file.path(rawPath,chip),procPath=file.path(procPath,chip),bp.method=bp.method,negCtrCode=negCtrCode,summaryParam=summaryParam,dataType=dataType,platform=platform)
		createQCplot(mData,file.path(pkgPath,chip))
		packagingArray(file.path(pkgPath,chip),file.path(procPath,chip))
	}
	createBatchPkgs(batchPath,procPath,plateMapFn,platform=platform,inc=inc)
	packagingMappedArrays(procPath,tcgaPath,batchPath,arrayPath,reposPath,platform)
	createTCGAPkgs(tcgaPath,batchPath,reposPath,packageMapFn,inc=inc)
	if(toSubmit==T) submitTCGAPkgs(tcgaPath)
	cat(paste(">Done...",date(),"\n"))
}

rapid.pro_Test<-function(){
	rawPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data"
	datDir<-"c:\\temp\\test"
	rapid.pro(rawPath,datDir=datDir,inc=T)
	
	datDir<-"c:\\temp\\test"
	rapid.pro(datDir=datDir,inc=T)
	
	datDir<-"c:\\temp\\test3"
	rapid.pro(datDir=datDir,inc=F,dataType="IDAT")
	#meth450
	datDir<-"c:\\temp\\IDAT"
	rapid.pro(datDir=datDir,inc=T,dataType="IDAT",platform="meth450k")
}

rapid.pro_test2<-function(){
	outDir<-"c:\\temp\\test2"
	arrayPath<-"c:\\tcga\\others\\arraymapping"
	rapid.pro(datDir=outDir,arrayPath=arrayPath,inc=F)
	
	outDir<-"c:\\temp\\test4"
	rawPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data\\raw"
	rapid.pro(datDir=outDir,arrayPath=arrayPath,inc=F,summaryParam="z-score",dataType="TXT")
	rapid.pro(datDir=outDir,arrayPath=arrayPath,inc=F,summaryParam="z-score",dataType="all")

	outDir<-"c:\\temp\\test3"
	rawPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data"
	rapid.pro(rawPath=rawPath,datDir=outDir,arrayPath=arrayPath,inc=F)
}
#########
#
##########
readSampleMapping_test<-function(){
	arrayPath<-"c:\\tcga\\others\\arraymapping\\meth450"
	smp<-readSampleMapping(arrayPath)
	table(smp$Batch_Number,smp$abbreviation)
	
}
readSampleMapping<-function(arrayPath,smpFn="sample_mapping.txt",archive=T,ignore.duplate=T){
	smp<-NULL
	#smp.name<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation")
	if(!is.null(arrayPath)){
		smpFn<-file.path(arrayPath,smpFn)
		if(!file.exists(smpFn)){
			cat(smpFn);cat("\n")
			cat("Sample Mapping Data is not available, checked.\n")
			return()
		}else{
			smp<-read.delim(file=smpFn,sep="\t",header=T,as.is=T,stringsAsFactors=F)
			#names(smp)<-smp.name
			smp.id<-paste(smp[,1],smp[,2],sep="_")
			
			if(sum(duplicated(smp.id))!=0 &ignore.duplate==F){
				smp.id.barcode<-paste(unique(smp.id[duplicated(smp.id)]),collapse=",")
				cat(paste("The following plate barcodes in the sample mappings are duplicated: ",smp.id.barcode,"\n",sep=""))
			}
			ind2<-!duplicated(smp.id)
			smp<-smp[ind2,]
			smp.id<-smp.id[ind2]
			
			ind<-grepl("TCGA",smp[,3])
			smp.tcga<-smp.id[ind]
			smp2<-smp[ind,3]
			if(sum(duplicated(smp.tcga))!=0){
				smp.tcga<-paste(unique(smp2[duplicated(smp2)]),collapse=",")
				warning(paste("The following TCGA samples in the sample mappings are duplicated:",smp.tcga,"\n"))
			}
			ind1<-!duplicated(smp[,3])
			smp<-smp[ind1,]
			rownames(smp)<-smp.id[ind1]
		}
		if(archive==T){
			archivePath<-file.path(arrayPath,"archive")
			if(!file.exists(archivePath))dir.create(archivePath)
			file.copy(smpFn,file.path(archivePath,"sample_mapping.bk.txt"),overwrite=T)
		}
	}
	return(smp)
}

readSampleMapping.1<-function(arrayPath,smpFn="sample_mapping.txt",ignore.duplate=T){
	smp<-NULL
	smp.name<-c("plate_id","flow_cell","sampleID","Batch_Number","cancer","abbreviation")
	if(!is.null(arrayPath)){
		smpFn<-file.path(arrayPath,smpFn)
		if(!file.exists(smpFn)){
			cat(smpFn);cat("\n")
			cat("Sample Mapping Data is not available, checked.\n")
		}else{
			smp<-read.delim(file=smpFn,sep="\t",header=F,as.is=T)
			names(smp)<-smp.name
			smp.id<-paste(smp[,1],smp[,2],sep="_")
			
			if(sum(duplicated(smp.id))!=0 &ignore.duplate==F){
				smp.id.barcode<-paste(unique(smp.id[duplicated(smp.id)]),collapse=",")
				cat(paste("The following plate barcodes in the sample mappings are duplicated: ",smp.id.barcode,"\n",sep=""))
			}
			ind2<-!duplicated(smp.id)
			smp<-smp[ind2,]
			smp.id<-smp.id[ind2]
			
			ind<-grepl("TCGA",smp[,3])
			smp.tcga<-smp.id[ind]
			smp2<-smp[ind,3]
			if(sum(duplicated(smp.tcga))!=0){
				smp.tcga<-paste(unique(smp2[duplicated(smp2)]),collapse=",")
				warning(paste("The following TCGA samples in the sample mappings are duplicated:",smp.tcga,"\n"))
			}
			ind1<-!duplicated(smp[,3])
			smp<-smp[ind1,]
			rownames(smp)<-smp.id[ind1]
		}
	}
	return(smp)
}

createTCGApkgs<-function(datPath,pkgPath,arrayPath,inc=T){
	packagingMappedArrays(datPath,pkgPath,arrayPath,inc)
}
packagingMappedArrays_test<-function(){
	library(rapid.pro)
	procPath<-"C:\\temp\\test\\meth27k\\processed"
	arrayPath<-"C:\\temp\\test\\meth27k\\arraymapping"
	tcgaPath<-"c:\\temp\\test\\meth27k\\tcga"
	batchPath<-"c:\\temp\\test\\meth27k\\batches"
	packagingMappedArrays(procPath,tcgaPath,batchPath,arrayPath,platform="meth27k")
	
	procPath<-"/auto/uec-02/shared/production/methylation/meth450k/processed"
	arrayPath<-"/auto/uec-02/shared/production/methylation/meth450k/arraymapping"
	tcgaPath<-"/auto/uec-02/shared/production/methylation/meth450k/tcga"
	batchPath<-"/auto/uec-02/shared/production/methylation/meth450k/batches"
	packagingMappedArrays(procPath,tcgaPath,batchPath,arrayPath,platform="meth450k")
	
	procPath<-"c:/temp/IDAT/meth450k/processed"
	arrayPath<-"c:/temp/IDAT/meth450k/arraymapping"
	tcgaPath<-"c:/temp/IDAT/meth450k/"
	batchPath<-"c:/temp/IDAT/meth450k/batches"
	packagingMappedArrays(procPath,tcgaPath,batchPath,arrayPath,platform="meth450k")
	
	procPath<-"/home/feipan/pipeline/meth450k/processed"
	arrayPath<-"/home/feipan/pipeline/meth450k/arraymapping"
	tcgaPath<-"/home/feipan/pipeline/meth450k/tcga"
	batchPath<-"/home/feipan/pipeline/meth450k/batches"
	packagingMappedArrays(procPath,tcgaPath,batchPath,arrayPath,platform="meth450k")
	
	arrayMapFn<-"jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv"
	packagingMappedArrays(procPath,tcgaPath,batchPath,arrayPath,arrayMapFn=arrayMapFn,platform="meth450k")
}
packagingMappedArrays<-function(procPath,tcgaPath,batchPath,arrayPath,reposPath=NULL,arrayMapFn=NULL,platform="meth27k"){
	if(is.null(arrayMapFn))arrayMapFn<-list.files(arrayPath,pattern=".csv")
	for(fn in arrayMapFn){
		am<-file.path(arrayPath,fn)
		isTCGA<-F
		sn<-gsub(".csv","",fn)
		if(substr(fn,1,7)=="jhu-usc") {
			isTCGA<-T;cancerType<-strsplit(strsplit(fn,"edu_")[[1]][[2]],"\\.")[[1]][[1]]
			tcgaPath<-file.path(tcgaPath,cancerType);if(!file.exists(tcgaPath))dir.create(tcgaPath)
			batch<-createBatchPkgs(tcgaPath,procPath,platemapFn=am,arrayPath,isTCGA=isTCGA,sn=sn,platform=platform)
			createPkgDescription(file.path(tcgaPath,sn),am,platform=platform)
			createMagePkg(file.path(tcgaPath,sn),arrayPath,platform=platform)
			validatePkg(file.path(tcgaPath,sn),system.file("validator3",package="rapid.pro"))
			if(!is.null(reposPath))mergeTCGAPkg.2(file.path(tcgaPath,sn),reposPath)
			mergePackageMap(fn,platform=platform)
		}else{
			batch<-createBatchPkgs(batchPath,procPath,platemapFn=am,isTCGA=isTCGA,sn=sn)
		}
	}
}
packagingMappedArrays.1<-function(procPath,tcgaPath,batchPath,arrayPath,reposPath=NULL,arrayMapFn=NULL,platform="meth27k"){
	if(is.null(arrayMapFn))arrayMapFn<-list.files(arrayPath,pattern=".csv")
	for(fn in arrayMapFn){
		am<-file.path(arrayPath,fn)
		isTCGA<-F
		sn<-gsub(".csv","",fn)
		if(substr(fn,1,7)=="jhu-usc") {
			isTCGA<-T;cancerType<-strsplit(strsplit(fn,"edu_")[[1]][[2]],"\\.")[[1]][[1]]
			tcgaPath<-file.path(tcgaPath,cancerType);if(!file.exists(tcgaPath))dir.create(tcgaPath)
			batch<-createBatchPkgs(tcgaPath,procPath,platemapFn=am,isTCGA=isTCGA,sn=sn,platform=platform)
			createPkgDescription(file.path(tcgaPath,sn),am,platform=platform)
			createMagePkg(file.path(tcgaPath,sn),arrayPath,platform=platform)
			validatePkg(file.path(tcgaPath,sn),system.file("validator3",package="rapid.pro"))
			if(!is.null(reposPath))mergeTCGAPkg.2(file.path(tcgaPath,sn),reposPath)
			mergePackageMap(fn,platform=platform)
		}else{
			batch<-createBatchPkgs(batchPath,procPath,platemapFn=am,isTCGA=isTCGA,sn=sn)
		}
	}
}

##################
#
#################
packagingMappedArrays_test<-function(){
	arrayPath<-"c:\\tcga\\others\\arraymapping"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out"
	pkgPath<-"c:\\temp\\pkg2"
	packagingMappedArrays.1(outPath,pkgPath,arrayPath,inc=F)
}
packagingMappedArrays_test2<-function(){
	arrayPath<-"/auto/uec-02/shared/production/methylation/meth27k/arraymapping"
	outPath<-"/auto/uec-02/shared/production/methylation/meth27k/processed"
	pkgPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga"
	packagingMappedArrays.1(procPath,pkgPath,arrayPath,F)
}

packagingMappedArrays.1<-function(outPath,pkgPath,arrayPath,inc=T){
	if(!is.null(arrayPath)){
		setwd(arrayPath)
		amFn<-gsub(".csv","",list.files(pattern=".csv"))
		pkgRepos<-file.path(pkgPath,"repos")
		if(!file.exists(pkgRepos))dir.create(pkgRepos)
		if(inc==T){
			pkgFn<-c(list.files(pkgPath),list.files(pkgRepos))
			amFn<-amFn[!is.element(amFn,pkgFn)]
		}
		for(fn in amFn){
			am<-file.path(arrayPath,paste(fn,".csv",sep=""))
			df.pkg<-file.path(pkgPath,fn)
			isTCGA<-F
			if(substr(fn,1,7)=="jhu-usc") {
				isTCGA<-T
				df.pkg<-file.path(pkgPath,"repos",fn)
			}
			if(!file.exists(df.pkg)) dir.create(df.pkg)
			createPkg.2(outPath,df.pkg,pkgname=fn,arraymapping=am,isTCGA=isTCGA)
			fn1<-paste(strsplit(fn,"\\.")[[1]][1:4],collapse=".")
			validatePkg(file.path(df.pkg,fn1),system.file("validator3",package="rapid.pro"))
			if(isTCGA==T)mergeTCGAPkg.2(pkgPath,df.pkg)
		}
	}
}

readPackageMap_test<-function(){
	packageMapFn<-"c:\\tcga\\others\\arraymapping\\packagemap.txt"
	mp<-readPackageMap(packageMapFn)
	packageMapFn<-"C:\\tcga\\others\\arraymapping\\meth450\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv" 
	mp<-readPackageMap(packageMapFn)
}
readPackageMap<-function(packageMapFn,sep="\t",platform="meth450k"){
	if(!file.exists(packageMapFn))return()
	if(file.ext(packageMapFn)=="csv") sep=","
	packmaps<-read.delim(file=packageMapFn,sep=sep,as.is=T,stringsAsFactors=F)
	platform.name<-ifelse(platform=="meth450k","HumanMethylation450","HumanMethylation27")
	if(is.null(packmaps$Package_lvl.1))packmaps$Package_lvl.1<-paste("jhu-usc.edu_",packmaps$abbreviation,".",platform.name,".Level_1.",packmaps$sn_lvl1,sep="")
	if(is.null(packmaps$Package_lvl.2))packmaps$Package_lvl.2<-paste("jhu-usc.edu_",packmaps$abbreviation,".",platform.name,".Level_2.",packmaps$sn_lvl2,sep="")
	if(is.null(packmaps$Package_lvl.3))packmaps$Package_lvl.3<-paste("jhu-usc.edu_",packmaps$abbreviation,".",platform.name,".Level_3.",packmaps$sn_lvl3,sep="")
	if(is.null(packmaps$Sample_ID))stop("From read package map, Sample_ID is not available\n")
	return(packmaps)
}
##################
# 
############################
createTCGAPkgs_test<-function(){
	tcgaPath<-"c:\\temp\\test2\\meth27k\\tcga"
	batchPath<-"c:\\temp\\test2\\meth27k\\batches"
	packageMapFn<-"c:\\tcga\\others\\arraymapping\\packagemap.txt"
	
	tcgaPath<-"C:\\temp\\IDAT\\meth450k\\tcga"
	batchPath<-"C:\\temp\\IDAT\\meth450k\\batches"
	packageMapFn<-"C:\\tcga\\others\\arraymapping\\meth450\\jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv"
	packageMapFn<-"C:\\tcga\\others\\arraymapping\\meth450\\packagemap.txt"
	createTCGAPkgs(tcgaPath,batchPath,packageMapFn=packageMapFn,inc=F)
	createTCGAPkgs(tcgaPath,batchPath,packageMapFn=packageMapFn,inc=T)
	
	tcgaPath<-"/auto/uec-02/shared/production/methylation/meth450k/tcga"
	batchPath<-"/auto/uec-02/shared/production/methylation/meth450k/batches"
	packageMapFn<-"/auto/uec-02/shared/production/methylation/meth450k/arraymapping/packagemap.txt"
	createTCGAPkgs(tcgaPath,batchPath,packageMapFn=packageMapFn,inc=T)
}
createTCGAPkgs<-function(tcgaPath,batchPath,reposPath=NULL,packageMapFn,inc=T,platform="meth450k"){
	if(!file.exists(packageMapFn))return()
	packmaps<-readPackageMap(packageMapFn,platform=platform)
	package<-unique(packmaps$Package_lvl.1)
	for(i in 1:length(package)){
		sample.exists<-F;sn<-strsplit(package[i],"\\.")[[1]][5]
		packmap<-packmaps[packmaps$Package_lvl.1==package[i],]
		pkgName<-gsub("Level_1.","",packmap$Package_lvl.1[1])
		pkgName.cancerType<-strsplit(strsplit(pkgName,"edu_")[[1]][2],"\\.")[[1]][[1]]
		tcgaPath2<-file.path(tcgaPath,pkgName.cancerType)
		if(!file.exists(tcgaPath2))dir.create(tcgaPath2)
		pkgPath<-file.path(tcgaPath2,pkgName)
		if(file.exists(pkgPath)) {
			if(inc==T) {
				cat("The data package ",pkgName," already exists, ... check.\n");
				next
			}else{
				dir.remove(pkgPath)
				dir.create(pkgPath)
			}
		}else dir.create(pkgPath)
		pkg1Path<-file.path(pkgPath,packmap$Package_lvl.1[1])
		if(!file.exists(pkg1Path)) dir.create(pkg1Path,T)
		pkg2Path<-file.path(pkgPath,packmap$Package_lvl.2[1])
		if(!file.exists(pkg2Path)) dir.create(pkg2Path,T)
		pkg3Path<-file.path(pkgPath,packmap$Package_lvl.3[1])
		if(!file.exists(pkg3Path)) dir.create(pkg3Path,T)
		batches<-unique(packmap$Batch_Number);batch<-NULL
		for(batch in batches){
			cat("working on",batch,"\n")
			datPath<-file.path(batchPath,batch)
			if(!file.exists(datPath)){
				cat("The data batch ",batch," is missing for generating package ",pkgName,"\n")
				next()
			}
			datPkg1<-list.files(datPath,"Level_1");datPkg1<-file.path(datPath,datPkg1[-grep(".tar",datPkg1)])
			datPkg2<-list.files(datPath,"Level_2");datPkg2<-file.path(datPath,datPkg2[-grep(".tar",datPkg2)])
			datPkg3<-list.files(datPath,"Level_3");datPkg3<-file.path(datPath,datPkg3[-grep(".tar",datPkg3)])
			samples<-packmap[packmap$Batch_Number==batch,"Sample_ID"]
			for(sid in samples){
				cat("on sample",sid,"\n")
				sidFn<-list.files(datPkg1,patt=sid)
				if(length(sidFn)==0)cat(paste("The level-1 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else if(length(sidFn)>1) stop(paste("There are multiple lvl-1 data files for sample",sid,":",paste(sidFn,collapse=","),"\n"))
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg1,sidFn),file.path(pkg1Path,sidFn.new));
					sample.exists<-T
				}
				sidFn<-list.files(datPkg2,patt=sid)
				if(length(sidFn)==0)cat(paste("The level-2 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else if(length(sidFn)>1) stop(paste("There are multiple lvl-2 data files for samle",sid,":",paste(sidFn,collapse=","),"\n"))
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg2,sidFn),file.path(pkg2Path,sidFn.new))
				}
				sidFn<-list.files(datPkg3,patt=sid); 
				if(length(sidFn)>1)stop(paste("There are multiple lvl-3 data files for sample ",sid,": ",paste(sidFn,collapse=","),"\n"))
				else if(length(sidFn)==0)cat(paste("The level-3 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg3,sidFn),file.path(pkg3Path,sidFn.new))
				}
			}
		}
		if(sample.exists==T){
			createManifestByLevel.2(pkg1Path);compressDataPackage.2(pkg1Path)
			createManifestByLevel.2(pkg2Path);compressDataPackage.2(pkg2Path)
			createManifestByLevel.2(pkg3Path);compressDataPackage.2(pkg3Path)
			createPkgDescription(pkgPath,batch=batch)
			createMagePkg(pkgPath)
			validatePkg(pkgPath,package="rapid.pro")
			if(!is.null(reposPath))mergeTCGAPkg.2(pkgPath,reposPath)
		}else dir.remove(pkgPath)
		if(length(list.files(tcgaPath2))<1)dir.remove(tcgaPath2)
	}
}

createTCGAPkgs.1.2<-function(tcgaPath,batchPath,reposPath=NULL,packageMapFn,inc=T,platform="meth450k"){
	if(!file.exists(packageMapFn))return()
	packmaps<-readPackageMap(packageMapFn,platform=platform)
	package<-unique(packmaps$Package_lvl.1)
	for(i in 1:length(package)){
		sample.exists<-F;sn<-strsplit(package[i],"\\.")[[1]][5]
		packmap<-packmaps[packmaps$Package_lvl.1==package[i],]
		pkgName<-gsub("Level_1.","",packmap$Package_lvl.1[1])
		pkgName.cancerType<-strsplit(strsplit(pkgName,"edu_")[[1]][2],"\\.")[[1]][[1]]
		tcgaPath2<-file.path(tcgaPath,pkgName.cancerType)
		if(!file.exists(tcgaPath2))dir.create(tcgaPath2)
		pkgPath<-file.path(tcgaPath2,pkgName)
		if(file.exists(pkgPath)) {
			if(inc==T) stop("The data package ",pkgName," already exists, ... check.\n")
		}else dir.create(pkgPath)
		pkg1Path<-file.path(pkgPath,packmap$Package_lvl.1[1])
		if(!file.exists(pkg1Path)) dir.create(pkg1Path,T)
		pkg2Path<-file.path(pkgPath,packmap$Package_lvl.2[1])
		if(!file.exists(pkg2Path)) dir.create(pkg2Path,T)
		pkg3Path<-file.path(pkgPath,packmap$Package_lvl.3[1])
		if(!file.exists(pkg3Path)) dir.create(pkg3Path,T)
		batches<-unique(packmap$Batch_Number)
		for(batch in batches){
			cat("working on",batch,"\n")
			datPath<-file.path(batchPath,batch)
			if(!file.exists(datPath)){
				cat("The data batch ",batch," is missing for generating package ",pkgName,"\n")
				next()
			}
			datPkg1<-list.files(datPath,"Level_1");datPkg1<-file.path(datPath,datPkg1[-grep(".tar",datPkg1)])
			datPkg2<-list.files(datPath,"Level_2");datPkg2<-file.path(datPath,datPkg2[-grep(".tar",datPkg2)])
			datPkg3<-list.files(datPath,"Level_3");datPkg3<-file.path(datPath,datPkg3[-grep(".tar",datPkg3)])
			samples<-packmap[packmap$Batch_Number==batch,"Sample_ID"]
			for(sid in samples){
				cat("on sample",sid,"\n")
				sidFn<-list.files(datPkg1,patt=sid)
				if(length(sidFn)==0)cat(paste("The level-1 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else if(length(sidFn)>1) stop(paste("There are multiple lvl-1 data files for sample",sid,":",paste(sidFn,collapse=","),"\n"))
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg1,sidFn),file.path(pkg1Path,sidFn.new));
					sample.exists<-T
				}
				sidFn<-list.files(datPkg2,patt=sid)
				if(length(sidFn)==0)cat(paste("The level-2 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else if(length(sidFn)>1) stop(paste("There are multiple lvl-2 data files for samle",sid,":",paste(sidFn,collapse=","),"\n"))
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg2,sidFn),file.path(pkg2Path,sidFn.new))
				}
				sidFn<-list.files(datPkg3,patt=sid); 
				if(length(sidFn)>1)stop(paste("There are multiple lvl-3 data files for sample ",sid,": ",paste(sidFn,collapse=","),"\n"))
				else if(length(sidFn)==0)cat(paste("The level-3 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg3,sidFn),file.path(pkg3Path,sidFn.new))
				}
			}
		}
		if(sample.exists==T){
			createPkgDescription(pkgPath,packageMap=packmap)
			createManifestByLevel.2(pkg1Path);compressDataPackage.2(pkg1Path)
			createManifestByLevel.2(pkg2Path);compressDataPackage.2(pkg2Path)
			createManifestByLevel.2(pkg3Path);compressDataPackage.2(pkg3Path)
			createMagePkg(pkgPath)
			validatePkg(pkgPath,package="rapid.pro")
			if(!is.null(reposPath))mergeTCGAPkg.2(pkgPath,reposPath)
		}
	}
}

createTCGAPkgs.1<-function(tcgaPath,batchPath,reposPath=NULL,packageMapFn,inc=T){
	if(!file.exists(packageMapFn))return()
	packmaps<-read.delim(file=packageMapFn,sep="\t",as.is=T,stringsAsFactors=F)
	package<-unique(packmaps$Package_lvl.1)
	for(i in 1:length(package)){
		sample.exists<-F;sn<-strsplit(package[i],"\\.")[[1]][5]
		packmap<-packmaps[packmaps$Package_lvl.1==package[i],]
		pkgName<-gsub("Level_1.","",packmap$Package_lvl.1[1])
		pkgName.cancerType<-strsplit(strsplit(pkgName,"edu_")[[1]][2],"\\.")[[1]][[1]]
		tcgaPath2<-file.path(tcgaPath,pkgName.cancerType)
		if(!file.exists(tcgaPath2))dir.create(tcgaPath2)
		pkgPath<-file.path(tcgaPath2,pkgName)
		if(file.exists(pkgPath)) {
			if(inc==T) stop("The data package ",pkgName," already exists, ... check.\n")
		}else dir.create(pkgPath)
		pkg1Path<-file.path(pkgPath,packmap$Package_lvl.1[1])
		if(!file.exists(pkg1Path)) dir.create(pkg1Path,T)
		pkg2Path<-file.path(pkgPath,packmap$Package_lvl.2[1])
		if(!file.exists(pkg2Path)) dir.create(pkg2Path,T)
		pkg3Path<-file.path(pkgPath,packmap$Package_lvl.3[1])
		if(!file.exists(pkg3Path)) dir.create(pkg3Path,T)
		batches<-unique(packmap$Batch_Number)
		for(batch in batches){
			cat("working on",batch,"\n")
			datPath<-file.path(batchPath,batch)
			if(!file.exists(datPath)){
				cat("The data batch ",batch," is missing for generating package ",pkgName,"\n")
				next()
			}
			datPkg1<-list.files(datPath,"Level_1");datPkg1<-file.path(datPath,datPkg1[-grep(".tar",datPkg1)])
			datPkg2<-list.files(datPath,"Level_2");datPkg2<-file.path(datPath,datPkg2[-grep(".tar",datPkg2)])
			datPkg3<-list.files(datPath,"Level_3");datPkg3<-file.path(datPath,datPkg3[-grep(".tar",datPkg3)])
			samples<-packmap[packmap$Batch_Number==batch,"Sample_ID"]
			for(sid in samples){
				cat("on sample",sid,"\n")
				sidFn<-list.files(datPkg1,patt=sid)
				if(length(sidFn)==0)cat(paste("The level-1 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else if(length(sidFn)>1) stop(paste("There are multiple lvl-1 data files for sample",sid,":",paste(sidFn,collapse=","),"\n"))
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg1,sidFn),file.path(pkg1Path,sidFn.new));
					sample.exists<-T
				}
				sidFn<-list.files(datPkg2,patt=sid)
				if(length(sidFn)==0)cat(paste("The level-2 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else if(length(sidFn)>1) stop(paste("There are multiple lvl-2 data files for samle",sid,":",paste(sidFn,collapse=","),"\n"))
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg2,sidFn),file.path(pkg2Path,sidFn.new))
				}
				sidFn<-list.files(datPkg3,patt=sid); 
				if(length(sidFn)>1)stop(paste("There are multiple lvl-3 data files for sample ",sid,": ",paste(sidFn,collapse=","),"\n"))
				else if(length(sidFn)==0)cat(paste("The level-3 data of sample ",sid," is not found in batch ",batch,"\n")) 
				else {
					sidFn.new<-gsub(paste("\\.",batch,"\\.",sep=""),paste("\\.",sn,"\\.",sep=""),sidFn)
					file.copy(file.path(datPkg3,sidFn),file.path(pkg3Path,sidFn.new))
				}
			}
		}
		if(sample.exists==T){
			#createPkgDescription(pkgPath,packageMap=packmap)
			createManifestByLevel.2(pkg1Path);compressDataPackage.2(pkg1Path)
			createManifestByLevel.2(pkg2Path);compressDataPackage.2(pkg2Path)
			createManifestByLevel.2(pkg3Path);compressDataPackage.2(pkg3Path)
			createMagePkg(pkgPath)
			validatePkg(pkgPath,package="rapid.pro")
			if(!is.null(reposPath))mergeTCGAPkg.2(pkgPath,reposPath)
		}
	}
}


###################################

###################################
createQCplot_test<-function(){
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\5324215005_out2\\filter.min"
	print(load(file=file.path(outPath,"mData_5324215005.rdata")))
	print(load(file=file.path(outPath,"cData_5324215005.rdata")))
	
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp"
	setwd(outPath)
	load(file="mData.rdata")
	load(file="cData.rdata")
	createQCplot(mData,cData,outPath)
	
	load(file="c:\\temp\\test2\\meth27k\\processed\\5543207015\\5543207015_idat.rda")
	createQCplot(mData=idat,outPath="c:\\temp\\test2")
	
	load(file="c:\\temp\\IDAT\\processed\\5640277011_idat.rda")
	createQCplot(mData=idat,outPath="c:\\temp\\IDAT")
}
createQCplot<-function(mData=NULL,outPath,gtype="png"){
	if(!is.null(mData)){
		if(!file.exists(outPath))dir.create(outPath)
		if(gtype=="png")if(class(try(png(),T))=="try-error")gtype="pdf"
		probePlot(mData,data.dir=outPath,gtype=gtype)
		plotFailureRate(mData,outDir=outPath,gtype=gtype)
		controlPlot(mData,outDir=outPath,gtype=gtype)
	}
}
createQCplots<-function(procPath,pkgPath,gtype="png"){
	require(Biobase)
	arrays<-list.files(procPath)
	for(ar in arrays){
		mdatFn<-list.files(file.path(procPath,ar),pattern=".rda",full.names=TRUE)
		if(length(mdatFn)!=1) cat(paste("The MDAT is missing from array:",ar,"\n"))
		else{
			mdat<-get(load(mdatFn))
			if(!file.exists(file.path(pkgPath,ar)))dir.create(file.path(pkgPath,ar))
			createQCplot(mdat,file.path(pkgPath,ar))
			cat(paste("Finished QC array:",ar,"\n"))
		}
	}
}
createPkg_test<-function(){
	outPath<-"C:\\temp\\4698_out\\123"
	createPkg(outPath,outPath)
	datPath<-outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\5543207013"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out"
	am<-"c:\\tcga\\arraymapping\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	createPkg(datPath,outPath,arraymapping=am,pkgname="jhu-usc.edu_STAD.HumanMethylation27.1.0.0")
}
createPkg.2_test<-function(){
	am<-"c:\\tcga\\arraymapping\\jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv"
	datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp"
	createPkg.2(datPath,outPath,pkgname="jhu-usc.edu_STAD.HumanMethylation27.1.0.0",arraymapping=am)
}

createPkg.2<-function(outPath,pkgPath,arraymapping,pkgname=NULL,isTCGA=T){
	if(is.null(pkgname)) pkgname<-gsub(".csv","",filetail(arraymapping))
	sampleInfo<-extractSampleInfo(arraymapping)
	chip.exist<-c()
	for(chip in sampleInfo$chipBarCode){
		outPath1<-file.path(outPath,chip)
		if(file.exists(outPath1)){
			chip.exist<-c(chip.exist,outPath1)
		}else{
			msg<-paste("Chip ",chip,"is missing\n")
			cat(msg)
			#log(msg)
		}
	}
	chip.n<-length(chip.exist)
	if(chip.n>=1){
		if(chip.n>=2){
			for(i in 1:(chip.n-1)){
				outPath1<-chip.exist[i]
				createPkg(outPath1,pkgPath,pkgname,arraymapping,packaging=F,isTCGA=isTCGA)
			}
		}
		createPkg(chip.exist[chip.n],pkgPath,pkgname,arraymapping,isTCGA=isTCGA)
	}

}

createPkg<-function(outPath,pkgPath,pkgname=NULL,arraymapping=NULL,packaging=TRUE,isTCGA=T){
	if(is.null(pkgname)) pkgname<-filetail(outPath)
	assign("tcgaPackage_A",file.path(outPath,"UnMethylation_Signal_Intensity.csv"),env=.GlobalEnv)
	assign("tcgaPackage_A_se",file.path(outPath,"UnMethylation_Signal_Intensity_STDERR.csv"),env=.GlobalEnv)
	assign("tcgaPackage_A_n",file.path(outPath,"UnMethylation_Signal_Intensity_NBeads.csv"),env=.GlobalEnv)
	assign("tcgaPackage_B",file.path(outPath,"Methylation_Signal_Intensity.csv"),env=.GlobalEnv)
	assign("tcgaPackage_B_se",file.path(outPath,"Methylation_Signal_Intensity_STDERR.csv"),env=.GlobalEnv)
	assign("tcgaPackage_B_n",file.path(outPath,"Methylation_Signal_Intensity_NBeads.csv"),env=.GlobalEnv)
	assign("tcgaPackage_R_ctr",file.path(outPath,"Control_Signal_Intensity_Red.csv"),env=.GlobalEnv)
	assign("tcgaPackage_G_ctr",file.path(outPath,"Control_Signal_Intensity_Grn.csv"),env=.GlobalEnv)
	assign("tcgaPackage_pvalue_fn",file.path(outPath,"Pvalue.csv"),env=.GlobalEnv)
	assign("tcgaPackage_beta_fn",file.path(outPath,"BetaValue.csv"),env=.GlobalEnv)
	assign("tcgaPackage_outputDir",pkgPath,env=.GlobalEnv)
	assign("tcgaPackage_name",pkgname,env=.GlobalEnv)
	createDataPackage.2(txt=NULL,old_scheme=FALSE,new_scheme=TRUE,packaging,auto=T,pkgname=pkgname,isTCGA,arraymapping)
}
################
#
################
packagingArray_test<-function(){
	outPath<-"C:\\temp\\test2\\meth27k\\packaged\\5543207013"
	datPath<-"C:\\temp\\test2\\meth27k\\processed\\5543207013"
	packagingArray(outPath,datPath)
}
packagingArray<-function(outPath,datPath,ext=".csv"){
	df<-filetail(datPath)
	setwd(datPath)
	fns<-list.files(datPath,pattern=paste(ext,"|.png",sep=""))
	if(length(fns)<1){
		cat(paste("> There is no data files in the processed array folder:",df,"\n"))
		return()
	}
	fn<-paste(fns,collapse=" ")
	if(!file.exists(outPath))dir.create(outPath)
	tar<-"tar";md5sum<-"md5sum";mv<-"mv";rm<-"rm"
	if(R.Version()$os=="mingw32") {
		toolPath<-system.file("Rtools",package="rapid.pro")
		if(toolPath==""){
			cat("Rtools are not available. checked\n")
		}else{
			tar<-file.path(toolPath,"tar")
			gzip<-file.path(toolPath,"gzip")
			md5sum<-file.path(toolPath,"md5sum")
			mv<-file.path(toolPath,"mv")
			rm<-file.path(toolPath,"rm")
		}
	}
	dfz<-paste(df,".tar.gz",sep="")
	command<-paste(tar," -czf ",dfz,fn,sep=" ")
	dfz1<-paste(dfz,".md5",sep="")
	command3<-paste(md5sum," ", dfz," > ",dfz1,sep="")
	if(R.Version()$os=="mingw32"){
		shell(command)
		shell(command3)
		if(datPath!=outPath){
			system(paste(mv," ",dfz," \"",file.path(outPath,dfz),"\"",sep=""))
			system(paste(mv," ",dfz1," \"",file.path(outPath,dfz1),"\"",sep=""))
		}
	}else{
		system(command)
		system(command3)
		if(datPath!=outPath){
			system(paste("mv ",dfz," ",file.path(outPath,dfz),sep=""))
			system(paste("mv ",dfz1," ",file.path(outPath,dfz1),sep=""))
		}
	}
}
packagingArray.1<-function(outPath,datPath,ext=".csv"){
	df<-filetail(datPath)
	setwd(datPath)
	fns<-list.files(datPath,pattern=paste(ext,"|.png",sep=""))
	if(length(fns)<1){
		cat(paste("> There is no data files in the processed array folder:",df,"\n"))
		return()
	}
	fn<-paste(fns,collapse=" ")
	if(!file.exists(outPath))dir.create(outPath)
	tar<-"tar";md5sum<-"md5sum";mv<-"mv";rm<-"rm"
	if(R.Version()$os=="mingw32") {
		toolPath<-system.file("Rtools",package="rapid.pro")
		if(toolPath==""){
			cat("Rtools are not available. checked\n")
		}else{
			tar<-file.path(toolPath,"tar")
			gzip<-file.path(toolPath,"gzip")
			md5sum<-file.path(toolPath,"md5sum")
			mv<-file.path(toolPath,"mv")
			rm<-file.path(toolPath,"rm")
		}
	}
	dfz<-paste(df,".tar.gz",sep="")
	command<-paste(tar," -czf ",dfz,fn,sep=" ")
	dfz1<-paste(dfz,".md5",sep="")
	command3<-paste(md5sum," ", dfz," > ",dfz1,sep="")
	if(R.Version()$os=="mingw32"){
		shell(command)
		shell(command3)
		system(paste(mv," ",dfz," \"",file.path(outPath,dfz),"\"",sep=""))
		system(paste(mv," ",dfz1," \"",file.path(outPath,dfz1),"\"",sep=""))
	}else{
		system(command)
		system(command3)
		system(paste("mv ",dfz," ",file.path(outPath,dfz),sep=""))
		system(paste("mv ",dfz1," ",file.path(outPath,dfz1),sep=""))
	}
}

packagingArrays_test<-function(){
	datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out"
	packagingArrays(datPath,outPath,inc=F)
	datPath<-"C:\\temp\\pkg\\stad.HumanMethylation"
	outPath<-"C:\\temp\\pkg1"
	packagingArrays(datPath,outPath,inc=F,ext=".txt")
}
packagingArrays_test<-function(){
	datPath<-"/auto/uec-02/shared/production/methylation/meth27k/processed"
	outPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/pkg"
	packagingArrays(datPath,outPath)
}

packagingArrays<-function(outPath,datPath,inc=T,ext=".csv"){
	outFolder<-list.files(outPath)
	dataFolder<-list.files(datPath)
	if(inc==T) dataFolder<-dataFolder[!is.element(dataFolder,outFolder)]
	for(df in dataFolder){
		setwd(file.path(datPath,df))
		fns<-list.files(file.path(datPath,df),pattern=paste(ext,"|.png",sep=""))
		if(length(fns)<1){
			cat(paste("> There is no data files in the processed array folder:",df,"\n"))
			next
		}
		fn<-paste(fns,collapse=" ")
		if(!file.exists(file.path(outPath,df)))dir.create(file.path(outPath,df))
		tar<-"tar";md5sum<-"md5sum";mv<-"mv";rm<-"rm"
		if(R.Version()$os=="mingw32") {
			toolPath<-system.file("Rtools",package="rapid.pro")
			if(toolPath==""){
				cat("Rtools are not available. checked\n")
			}else{
				tar<-file.path(toolPath,"tar")
				md5sum<-file.path(toolPath,"md5sum")
				mv<-file.path(toolPath,"mv")
				rm<-file.path(toolPath,"rm")
			}
		}
		dfz<-paste(df,".tar.gz",sep="")
		command<-paste(tar," -czf ",dfz,fn,sep=" ")
		dfz1<-paste(dfz,".md5",sep="")
		command3<-paste(md5sum," ", dfz," > ",dfz1,sep="")
		if(R.Version()$os=="mingw32"){
			shell(command)
			shell(command3)
			system(paste(mv," ",dfz," \"",file.path(outPath,df,dfz),"\"",sep=""))
			system(paste(mv," ",dfz1," \"",file.path(outPath,df,dfz1),"\"",sep=""))
		}else{
			system(command)
			system(command3)
			system(paste("mv ",dfz," ",file.path(outPath,df,dfz),sep=""))
			system(paste("mv ",dfz1," ",file.path(outPath,df,dfz1),sep=""))
		}
	}
}

packagingArrays.1<-function(datPath,outPath,inc=T,ext=".csv"){
	dataFolder<-list.files(datPath)
	outFolder<-list.files(outPath)
	if(inc==T) dataFolder<-dataFolder[!is.element(dataFolder,outFolder)]
	for(df in dataFolder){
		setwd(file.path(datPath,df))
		if(!file.exists(file.path(outPath,df)))dir.create(file.path(outPath,df))
		fn<-paste(list.files(file.path(datPath,df),pattern=paste(ext,"|.png",sep="")),collapse=" ")
		#fn<-paste(list.files(file.path(datPath,df),pattern=".csv|.png"),collapse=" ")
		command<-paste("tar -cf ",df,".tar ",fn,sep="")
		dfz<-paste(df,".tar.gz",sep="")
		command2<-paste("gzip -c ",df,".tar > ",dfz,sep="")
		if(R.Version()$os=="mingw32"){
			shell(command)
			shell(command2)
			system(paste("mv ",dfz," \"",file.path(outPath,df,dfz),"\"",sep=""))
		}else{
			system(command)
			system(command2)
			system(paste("mv ",dfz," ",file.path(outPath,df,dfz),sep=""))
		}
		system(paste("rm ",df,".tar",sep=""))
	}
}
###################


negctls.stderr_test<-function(){
	library(methylumi)
	setwd("C:\\temp\\IDAT\\meth450k\\processed\\6026818104")
	load("6026818104_idat.rda")
	load("5640277004_idat.rda")
	neg<-negctls.stderr(idat)
	nsd<-negctls.SD(idat)
	
	methylated.STDERR<-idat@QC@assayData$methylated.SD/sqrt(idat@QC@assayData$NBeads)
	unmethylated.STDERR<-idat@assayData$unmethylated.SD/sqrt(idat@assayData$unmethylated.N)
	dim(methylated.STDERR)
#	[1] 850  11
	ind<-grep("Neg",dimnames(methylated.STDERR)[[1]])
	length(ind)
#	[1] 614
	head(methylated.STDERR[ind,c("5640277004_R02C01","5640277004_R03C01")])
#	5640277004_R02C01 5640277004_R03C01
#	Negative.1          29.18975          29.96331
#	Negative.2          15.88395          18.65546
#	Negative.3          15.50340          23.21858
#	Negative.4          23.20000          20.95983
#	Negative.5          21.89989          19.24501
#	Negative.6          28.99530          16.27764
	
	methylated.STDERR2<-negctls.stderr(idat,"Cy3")
	unmethylated.STDERR2<-negctls.stderr(idat,"Cy5")
	head(methylated.STDERR2[,c("5640277004_R02C01","5640277004_R03C01")])
#	5640277004_R02C01 5640277004_R03C01
#	Negative.1          29.18975          29.96331
#	Negative.2          15.88395          18.65546
#	Negative.3          15.50340          23.21858
#	Negative.4          23.20000          20.95983
#	Negative.5          21.89989          19.24501
#	Negative.6          28.99530          16.27764
	
#	5640277004_R02C01 5640277004_R03C01
#	BS Conversion I-U5 15700381          43.55778          41.00000
	
#	TargetID,ProbeID,5640277004_R02C01.BEAD_STDERR_B,5640277004_R03C01.BEAD_STDERR_B
#	BISULFITE CONVERSION I,15700381,     43.55778,         41
}

###################################

###################################
procRawArray_test<-function(){
	chips<-c("4841860025","5471637013","5543207013","5543207015")
	for(chip in chips){
		dataPath<-file.path("/home/feipan/pipeline/meth27k/raw",chip)
		procPath<-file.path("/home/feipan/pipeline/meth27k/processed",chip)
		if(file.exists(file.path(procPath))) unlink(file.path(procPath),T);dir.create(file.path(procPath))
		samp<-readSampleMapping("/home/feipan/pipeline/meth27k/arraymapping")
		idat<-procRawArray(dataPath,procPath,dataType="TXT",sample.mapping=samp)
	}
}
procRawArray_test.1<-function(){
	chips<-c("4841860025")#,"5471637013","5543207013","5543207015")
	dataPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data"
	procPath<-"c:\\temp\\test\\meth27k\\processed"
	mdat<-procRawArray(file.path(dataPath,chip),file.path(procPath,chip),arrayPath)
	
	chip<-"5543207015"
	dataType<-"IDAT"
	#dataPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data"
	dataPath<-"C:\\temp\\test3\\meth27k\\raw"
	procPath<-"c:\\temp\\test3\\meth27k\\processed"
	arrayPath<-"c:\\tcga\\others\\arraymapping\\meth27"
	idat<-procRawArray(file.path(dataPath,chip),file.path(procPath,chip),arrayPath,dataType="IDAT")
}
procRawArray_test.2<-function(){
	library(methylumIDAT)
	dataPath<-"/home/uec-02/shared/production/methylation/meth27k/raw/5543207015"
	outPath<-"/home/uec-02/shared/production/methylation/meth27k/other"
	samp<-"/home/uec-02/shared/production/methylation/meth27k/arraymapping"
	setwd(dataPath)
	barcodes<-unique(gsub('_(Red|Grn).idat','',list.files(dataPath,patt='idat')))
	idat<-methylumIDAT(barcodes,parallel=F)
	
	#450k
	arrayPath<-"c:\\tcga\\others\\arraymapping\\meth450"
	idat<-procRawArray(dataPath="c:\\temp\\IDAT\\meth450k\\raw\\6055424097",
			"c:\\temp\\IDAT\\meth450k\\processed\\6055424097",arrayPath,platform="meth450k")
	idat<-procRawArray(dataPath="c:\\temp\\IDAT\\meth450k\\raw\\6026818104",
			procPath="c:\\temp\\IDAT\\meth450k\\processed\\6026818104",arrayPath,platform="meth450k")
	idat<-procRawArray(dataPath="c:\\temp\\IDAT\\meth450k\\raw\\6055432001",
			"c:\\temp\\IDAT\\meth450k\\processed\\6055432001","c:\\temp\\IDAT\\meth450k\\arraymapping",platform="meth450k")
	
	dataPath<-"/home/uec-02/shared/production/methylation/meth450k/raw/6042316106"
	outPath<-"/home/uec-02/shared/production/methylation/meth450k/processed/6042316106"
	arrayPath<-"/home/uec-02/shared/production/methylation/meth450k/arraymapping"
}
procRawArray<-function(dataPath,procPath,arrayPath=NULL,fname=NULL,txtWin=NULL,is.sepOut=T,toSave=T,bp.method="filter.min",sample.mapping=NULL,negCtrCode=NULL,summaryParam=c("z-score"),dataType="TXT",platform="meth27k"){
	if(is.null(sample.mapping))sample.mapping<-readSampleMapping(arrayPath)
	if(!file.exists(procPath))dir.create(procPath)
	mData<-NULL;p.method<-summaryParam[1]
	ar<-filetail(dataPath);cat("Start to process array ",ar,"\n")
	if(platform=="meth27k"&dataType!="IDAT"){
		if(class(try(mData<-procMethTxtData(dataPath,procPath,fname,txtWin,is.sepOut,toSave,bp.method,sample.mapping,negCtrCode,summaryParam)))=="try-error"){
			mData<-NULL
		}
	}
	if(platform=="meth450k"|is.null(mData)|dataType=="IDAT"){
		require(methylumi)
		if(platform=="meth450k") require(IlluminaHumanMethylation450k.db)
		else require(IlluminaHumanMethylation27k.db)
		setwd(dataPath);
		barcodes<-getBarcodes(dataPath)
		if(length(barcodes)<1){
			cat(paste("There is no IDAT data files in array",dataPath,"\n"))
			return()
		}
		idat<-methylumIDAT(barcodes,parallel=F,n.sd=T)
		if(!is.null(sample.mapping)) idat<-mapSampleIDAT(idat,sample.mapping)
		if(p.method!="IDAT"){
			pvalue<-calPvalueIDAT(idat,p.method=p.method,platform=platform)
			idat<-assayDataElementReplace(idat,"pvals",pvalue)
		}
		attr(idat,"p.method")<-p.method
		attr(idat,"date.create")<-date()
		if(toSave==T){
			save(idat,file=file.path(procPath,paste(filetail(dataPath),"_idat.rda",sep="")))
			if(!is.null(sample.mapping))savePhenoDataCSV(idat,procPath)
			saveIDATcsv(idat,procPath)
			mData<-idat
		}
	}
	cat("Finished processing array ",ar,"\n")
	return(mData)
}
procRawArray.1<-function(dataPath,procPath,arrayPath=NULL,fname=NULL,txtWin=NULL,is.sepOut=T,toSave=T,bp.method="filter.min",sample.mapping=NULL,negCtrCode=NULL,summaryParam=c("z-score"),dataType="TXT",platform="meth27k"){
	if(is.null(sample.mapping))sample.mapping<-readSampleMapping(arrayPath)
	if(!file.exists(procPath))dir.create(procPath)
	mData<-NULL;p.method<-summaryParam[1]
	ar<-filetail(dataPath);cat("Start to process array ",ar,"\n")
	if(platform=="meth27k"&dataType!="IDAT"){
		if(class(try(mData<-procMethTxtData(dataPath,procPath,fname,txtWin,is.sepOut,toSave,bp.method,sample.mapping,negCtrCode,summaryParam)))=="try-error"){
			mData<-NULL
		}
	}
	if(platform=="meth450k"|is.null(mData)|dataType=="IDAT"){
		require(methylumIDAT)
		setwd(dataPath)
		barcodes<-unique(gsub('_(Red|Grn).idat','',list.files(dataPath,patt='idat')))
		if(length(barcodes)<1){
			cat(paste("There is no IDAT data files in array",dataPath,"\n"))
			return()
		}
		idat<-methylumIDAT(barcodes,parallel=F,n.sd=T)
		if(!is.null(sample.mapping)) idat<-mapSampleIDAT(idat,sample.mapping)
		if(p.method!="IDAT"){
			pvalue<-calPvalueIDAT(idat,p.method=p.method,platform=platform)
			idat<-assayDataElementReplace(idat,"pvals",pvalue)
		}
		attr(idat,"p.method")<-p.method
		attr(idat,"date.create")<-date()
		if(toSave==T){
			save(idat,file=file.path(procPath,paste(filetail(dataPath),"_idat.rda",sep="")))
			if(!is.null(sample.mapping))savePhenoDataCSV(idat,procPath)
			saveIDATcsv(idat,procPath)
			mData<-idat
		}
	}
	cat("Finished processing array ",ar,"\n")
	return(mData)
}
procRawArrays_test<-function(){
	datPath<-"C:\\temp\\test\\meth27k\\raw"
	procPath<-"C:\\temp\\test\\meth27k\\processed"
	procRawArrays(datPath,procPath)
	
	datPath<-"C:\\temp\\IDAT\\raw"
	procPath<-"C:\\temp\\IDAT\\raw"
	procRawArrays(datPath,procPath,platform="meth450k")
}
procRawArrays<-function(datPath,procPath,platform="meth27k"){
	ams<-list.files(datPath)
	for(am in ams){
		procRawArray(file.path(datPath,am),file.path(procPath,am),platform=platform)
	}
}
processRawArrays<-function(rawPath=NULL,procPath=NULL,inc=F,parellel=T,scriptPath=NULL,scriptFn="procRawArray.R",Rscript=NULL,nodes=7){
	if(is.null(rawPath))rawPath<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	if(is.null(procPath))procPath<-"/auto/uec-02/shared/production/methylation/meth27k/processed"
	if(is.null(scriptPath))scriptPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/scripts"
	if(is.null(Rscript)) Rscript<-"/auto/uec-00/shared/production/software/R/bin/Rscript"
	arrays<-list.files(rawPath)
	arrays.processed<-list.files(procPath)
	if(inc==T) arrays<-arrays[!is.element(arrays,arrays.processed)]
	nodes.n<-length(arrays)
	if(parellel==T)nodes.n<-floor(length(arrays)/nodes)
	else nodes<--1
	jobPath<-file.path(scriptPath,"batch");if(!file.exists(jobPath))dir.create(jobPath)
	for(i in 1:(nodes+1)){
		ar.start<-(i-1)*nodes.n+1
		ar.end<-i*nodes.n; ar.end<-ifelse(ar.end>length(arrays),length(arrays),ar.end)
		arrays.batch<-arrays[ar.start:ar.end]
		arrays.batch<-paste("arrays<-c(\"",paste(arrays.batch,collapse="\",\""),"\")",sep="")
		script<-paste(arrays.batch,paste(readLines(file.path(scriptPath,scriptFn)),collapse="\n"),sep="\n")
		job.script<-file.path(jobPath,paste("run.",i,".R",sep=""));
		zz<-file(job.script,"w");cat(script,file=zz);close(zz)
		job.n<-file.path(jobPath,paste("run.",i,".sh",sep=""))
		zz<-file(job.n,"w");cat(paste(Rscript,job.script,sep=" "),file=zz);close(zz)
		system(paste("chmod +x",job.n))
		system(paste("qsub -q laird -l walltime=10:00:00 -N MethPipeline -l nodes=1:ppn=4",job.n),wait=F)
	}
}
########
##i.e., Cy3/green is methylated, Cy5/red is unmethylated.  I haven't got around to normalizing out the dye bias for any of them yet.
##########
saveIDATcsv_test<-function(){
	load(file="c:\\temp\\IDAT\\meth450k\\processed\\6042308166\\6042308166_idat.rda")
	saveIDATcsv(idat,"c:\\temp\\IDAT\\meth450k\\processed\\6042308166")
	print(load(file="c:\\temp\\IDAT\\meth450k\\processed\\6026818104\\6026818104_idat.rda"))
	saveIDATcsv(idat,procPath="c:\\temp\\IDAT\\meth450k\\processed\\6026818104")
	saveIDATcsv(idat,procPath="c:\\temp\\IDAT\\test",T)
	idat<-get(load(file="C:\\temp\\IDAT\\meth450k\\batches\\batch_test\\batch_dan03.rdata"))
	saveIDATcsv(idat,procPath="C:\\temp\\IDAT\\meth450k\\batches\\batch_test\\")
	saveIDATcsv(idat,procPath="C:\\temp\\IDAT\\meth450k\\batches\\batch_test\\",T)
}
saveIDATcsv.1<-function(idat,procPath,with.header2=F,limit="neg",pvalue.lvl2=0.05){
	if(is.null(idat))return()
	require(Biobase)
	betas<-idat@assayData$betas
	methylated<-idat@assayData$methylated
	unmethylated<-idat@assayData$unmethylated
	methylated.N<-idat@assayData$methylated.N
	unmethylated.N<-idat@assayData$unmethylated.N
	#methylated.STDERR<-idat@assayData$methylated.SD/sqrt(methylated.N)
	#unmethylated.STDERR<-idat@assayData$unmethylated.SD/sqrt(unmethylated.N)
	methylated.STDERR<-negctls.stderr(idat,"Cy3")
	unmethylated.STDERR<-negctls.stderr(idat,"Cy5")
	pvals<-idat@assayData$pvals
	sample.names<-dimnames(betas)[[2]]
	if(!all(dimnames(betas)[[2]]==dimnames(pvals)[[2]] & dimnames(betas)[[2]]==dimnames(methylated)[[2]] & dimnames(betas)[[2]]==dimnames(unmethylated)[[2]] & dimnames(betas)[[2]]==dimnames(methylated.N)[[2]] & dimnames(betas)[[2]]==dimnames(unmethylated.N)[[2]] & dimnames(methylated.STDERR)[[2]]==dimnames(betas)[[2]] & dimnames(betas)[[2]]==dimnames(unmethylated.STDERR)[[2]]))stop("Row names of M,U, M.n, U.n don't match.\n")
	if(!all(dimnames(betas)[[1]]==dimnames(pvals)[[1]] & dimnames(betas)[[1]]==dimnames(methylated)[[1]] & dimnames(betas)[[1]]==dimnames(unmethylated)[[1]] & dimnames(betas)[[1]]==dimnames(methylated.N)[[1]] & dimnames(betas)[[1]]==dimnames(unmethylated.N)[[1]] & dimnames(methylated.STDERR)[[1]]==dimnames(betas)[[1]] & dimnames(betas)[[1]]==dimnames(unmethylated.STDERR)[[1]]))stop("Col names of M,U, M.n, U.n don't match.\n")
	mask_lvl2<-ifelse(pvals<pvalue.lvl2,1,NA)
	betas.lvl2<-betas*mask_lvl2;names(betas.lvl2)<-names(betas)
	ctr.methylated<-NULL;ctr.unmethylated<-NULL;ctr.nbeads<-NULL
	if(!is.null(idat@QC)){
		ctr.methylated<-idat@QC@assayData$methylated
		ctr.unmethylated<-idat@QC@assayData$unmethylated
		ctr.nbeads<-idat@QC@assayData$NBeads
		if(!all(dimnames(ctr.methylated)[[2]]==dimnames(betas)[[2]] & dimnames(ctr.unmethylated)[[2]]==dimnames(betas)[[2]] & dimnames(ctr.nbeads)[[2]]==dimnames(betas)[[2]]))stop("check the col names of the QC data\n")
		if(!all(dimnames(ctr.methylated)[[1]]==dimnames(ctr.unmethylated)[[1]] & dimnames(ctr.unmethylated)[[1]]==dimnames(ctr.nbeads)[[1]]))stop("check the row names of the QC data\n")
		if(limit=="neg"){
			ord.m<-grep("negative",tolower(dimnames(ctr.methylated)[[1]]));len<-length(ord.m)
			ctr.methylated<-ctr.methylated[ord.m,];dimnames(ctr.methylated)[[1]]<-paste("NEGATIVE",1:len,sep=".")
			ord.u<-grep("negative",tolower(dimnames(ctr.unmethylated)[[1]]))
			ctr.unmethylated<-ctr.unmethylated[ord.u,];dimnames(ctr.unmethylated)[[1]]<-paste("NEGATIVE",1:len,sep=".")
			ord.nbeads<-grep("negative",tolower(dimnames(ctr.nbeads)[[1]]))
			ctr.nbeads<-ctr.nbeads[ord.nbeads,];dimnames(ctr.nbeads)[[1]]<-paste("NEGATIVE",1:len,sep=".")
		}
	}
	if(with.header2==T){
		pdat<-as(phenoData(idat),"data.frame")
		well_pos<-as.character(pdat$barcodes)
		if(!is.null(well_pos)){
			well_pos<-t(well_pos)
			betas<-rbind(well_position=well_pos,betas);
			betas.lvl2<-rbind(well_position=well_pos,betas.lvl2);
			methylated<-rbind(well_position=well_pos,methylated);
			unmethylated<-rbind(well_position=well_pos,unmethylated)
			methylated.N<-rbind(well_position=well_pos,methylated.N)
			unmethylated.N<-rbind(well_position=well_pos,unmethylated.N)
			pvals<-rbind(well_position=well_pos,pvals)
			methylated.STDERR<-rbind(well_position=well_pos,as.matrix(methylated.STDERR))
			unmethylated.STDERR<-rbind(well_position=well_pos,as.matrix(unmethylated.STDERR))
			if(!is.null(idat@QC)){
				#well_pos<-as.data.frame(well_pos);names(well_pos)<-dimnames(ctr.methylated)[[2]]
				ctr.methylated<-rbind(well_position=well_pos,as.matrix(ctr.methylated))
				ctr.unmethylated<-rbind(well_position=well_pos,as.matrix(ctr.unmethylated))
				ctr.nbeads<-rbind(well_position=well_pos,as.matrix(ctr.nbeads))
			}
		}
	}
	setwd(procPath)
	Fn<-processedCSVFileNames()
	write.csv(betas,file=Fn["Bv"],quote=F)
	write.csv(betas.lvl2,file="BetaValue.lvl2.csv",quote=F)
	write.csv(methylated,file=Fn["M"],quote=F)
	write.csv(unmethylated,file=Fn["U"],quote=F)
	write.csv(methylated.N,file=Fn["Mn"],quote=F)
	write.csv(unmethylated.N,file=Fn["Un"],quote=F)
	write.csv(methylated.STDERR,file=Fn["Mse"],quote=F)
	write.csv(unmethylated.STDERR,file=Fn["Use"],quote=F)
	write.csv(pvals,file=Fn["Pv"],quote=F)
	if(!is.null(idat@QC)){
		write.csv(ctr.methylated,file=Fn["Gctr"],quote=F)
		write.csv(ctr.unmethylated,file=Fn["Rctr"],quote=F)
		write.csv(ctr.nbeads,file="Control_Signal_Intensity_NBeads.csv",quote=F)
	}
}

saveIDATcsv<-function(idat,procPath,with.header2=F,limit="neg",pvalue.lvl2=0.05){
	if(is.null(idat))return()
	require(Biobase)
	betas<-idat@assayData$betas
	methylated<-idat@assayData$methylated
	unmethylated<-idat@assayData$unmethylated
	methylated.N<-idat@assayData$methylated.N
	unmethylated.N<-idat@assayData$unmethylated.N
	methylated.STDERR<-idat@assayData$methylated.SD/sqrt(methylated.N)
	unmethylated.STDERR<-idat@assayData$unmethylated.SD/sqrt(unmethylated.N)
	pvals<-idat@assayData$pvals
	sample.names<-dimnames(betas)[[2]]
	if(!all(dimnames(betas)[[2]]==dimnames(pvals)[[2]] & dimnames(betas)[[2]]==dimnames(methylated)[[2]] & dimnames(betas)[[2]]==dimnames(unmethylated)[[2]] & dimnames(betas)[[2]]==dimnames(methylated.N)[[2]] & dimnames(betas)[[2]]==dimnames(unmethylated.N)[[2]] & dimnames(methylated.STDERR)[[2]]==dimnames(betas)[[2]] & dimnames(betas)[[2]]==dimnames(unmethylated.STDERR)[[2]]))stop("Row names of M,U, M.n, U.n don't match.\n")
	if(!all(dimnames(betas)[[1]]==dimnames(pvals)[[1]] & dimnames(betas)[[1]]==dimnames(methylated)[[1]] & dimnames(betas)[[1]]==dimnames(unmethylated)[[1]] & dimnames(betas)[[1]]==dimnames(methylated.N)[[1]] & dimnames(betas)[[1]]==dimnames(unmethylated.N)[[1]] & dimnames(methylated.STDERR)[[1]]==dimnames(betas)[[1]] & dimnames(betas)[[1]]==dimnames(unmethylated.STDERR)[[1]]))stop("Col names of M,U, M.n, U.n don't match.\n")
	mask_lvl2<-ifelse(pvals<pvalue.lvl2,1,NA)
	betas.lvl2<-betas*mask_lvl2;names(betas.lvl2)<-names(betas)
	ctr.methylated<-NULL;ctr.unmethylated<-NULL;ctr.nbeads<-NULL
	if(!is.null(idat@QC)){
		ctr.methylated<-idat@QC@assayData$methylated
		ctr.unmethylated<-idat@QC@assayData$unmethylated
		ctr.nbeads<-idat@QC@assayData$NBeads
		if(!all(dimnames(ctr.methylated)[[2]]==dimnames(betas)[[2]] & dimnames(ctr.unmethylated)[[2]]==dimnames(betas)[[2]] & dimnames(ctr.nbeads)[[2]]==dimnames(betas)[[2]]))stop("check the col names of the QC data\n")
		if(!all(dimnames(ctr.methylated)[[1]]==dimnames(ctr.unmethylated)[[1]] & dimnames(ctr.unmethylated)[[1]]==dimnames(ctr.nbeads)[[1]]))stop("check the row names of the QC data\n")
		if(limit=="neg"){
			ord.m<-grep("negative",tolower(dimnames(ctr.methylated)[[1]]));len<-length(ord.m)
			ctr.methylated<-ctr.methylated[ord.m,];dimnames(ctr.methylated)[[1]]<-paste("NEGATIVE",1:len,sep=".")
			ord.u<-grep("negative",tolower(dimnames(ctr.unmethylated)[[1]]))
			ctr.unmethylated<-ctr.unmethylated[ord.u,];dimnames(ctr.unmethylated)[[1]]<-paste("NEGATIVE",1:len,sep=".")
			ord.nbeads<-grep("negative",tolower(dimnames(ctr.nbeads)[[1]]))
			ctr.nbeads<-ctr.nbeads[ord.nbeads,];dimnames(ctr.nbeads)[[1]]<-paste("NEGATIVE",1:len,sep=".")
		}
	}
	if(with.header2==T){
		pdat<-as(phenoData(idat),"data.frame")
		well_pos<-as.character(pdat$barcodes)
		if(!is.null(well_pos)){
			well_pos<-t(well_pos)
			betas<-rbind(well_position=well_pos,betas);
			betas.lvl2<-rbind(well_position=well_pos,betas.lvl2);
			methylated<-rbind(well_position=well_pos,methylated);
			unmethylated<-rbind(well_position=well_pos,unmethylated)
			methylated.N<-rbind(well_position=well_pos,methylated.N)
			unmethylated.N<-rbind(well_position=well_pos,unmethylated.N)
			pvals<-rbind(well_position=well_pos,pvals)
			methylated.STDERR<-rbind(well_position=well_pos,as.matrix(methylated.STDERR))
			unmethylated.STDERR<-rbind(well_position=well_pos,as.matrix(unmethylated.STDERR))
			if(!is.null(idat@QC)){
				#well_pos<-as.data.frame(well_pos);names(well_pos)<-dimnames(ctr.methylated)[[2]]
				ctr.methylated<-rbind(well_position=well_pos,as.matrix(ctr.methylated))
				ctr.unmethylated<-rbind(well_position=well_pos,as.matrix(ctr.unmethylated))
				ctr.nbeads<-rbind(well_position=well_pos,as.matrix(ctr.nbeads))
			}
		}
	}
	setwd(procPath)
	Fn<-processedCSVFileNames()
	write.csv(betas,file=Fn["Bv"],quote=F)
	write.csv(betas.lvl2,file="BetaValue.lvl2.csv",quote=F)
	write.csv(methylated,file=Fn["M"],quote=F)
	write.csv(unmethylated,file=Fn["U"],quote=F)
	write.csv(methylated.N,file=Fn["Mn"],quote=F)
	write.csv(unmethylated.N,file=Fn["Un"],quote=F)
	write.csv(methylated.STDERR,file=Fn["Mse"],quote=F)
	write.csv(unmethylated.STDERR,file=Fn["Use"],quote=F)
	write.csv(pvals,file=Fn["Pv"],quote=F)
	if(!is.null(idat@QC)){
		write.csv(ctr.methylated,file=Fn["Gctr"],quote=F)
		write.csv(ctr.unmethylated,file=Fn["Rctr"],quote=F)
		write.csv(ctr.nbeads,file="Control_Signal_Intensity_NBeads.csv",quote=F)
	}
}



calBetaValue2_test<-function(){
	betaFn<-"C:\\temp\\test\\meth27k\\batches\\batch_01\\BetaValue.csv"
	pValueFn<-"C:\\temp\\test\\meth27k\\batches\\batch_01\\Palue.csv"
	calBetaValue2(betaFn=betas,pvalueFn=pvals)
	
	idatFn<-"C:\\temp\\IDAT\\processed\\5775446078_idat.rda"
	idatFn<-"c:\\temp\\test\\meth27k\\processed\\5471637013\\mdat.rdata"
	idat<-get(print(load(idatFn)))
	idat<-calBetaValue2(idat)
	betas<-"c:\\temp\\IDAT\\processed\\BetaValue.csv"
	betas2<-"c:\\temp\\IDAT\\processed\\BetaValue.lvl2.csv"
	compareDataFile(betas,betas2)
	pvals<-"c:\\temp\\IDAT\\processed\\Pvalue.csv"
	calBetaValue2(betaFn=betas,pvalueFn=pvals)
}
calBetaValue2<-function(idat=NULL,betaFn=NULL,pvalueFn=NULL,outPath=NULL,pvalue.lvl2=0.05){
	betas<-NULL;pvals<-NULL
	if(is.null(betaFn)){
		if(is.null(idat)) return()
		if(class(idat)=="MethyLumiSet"){
			methylated<-idat@assayData$methylated
			unmethylated<-idat@assayData$unmethylated
			betas<-methylated/(methylated+unmethylated) #betas<-idat@assayData$betas
			pvals<-idat@assayData$pvals
		}else if(class(idat)=="methData"){
			betas<-getBeta(idat)
			pvals<-getPvalue(idat)
		}
		if(is.null(outPath))outPath<-gFileDir
	}else{
		if(!file.exists(betaFn)|!file.exists(pvalueFn))return()
		betas<-readDataFile.2(betaFn)
		pvals<-readDataFile.2(pvalueFn)
		if(is.null(outPath))outPath<-filedir(betaFn)
	}
	if(!all(dimnames(betas)[[2]]==dimnames(pvals)[[2]]))stop("Row names of M,U, M.n, U.n don't match.\n")
	if(!all(dimnames(betas)[[1]]==dimnames(pvals)[[1]] ))stop("Col names of M,U, M.n, U.n don't match.\n")
	mask_lvl2<-ifelse(pvals<pvalue.lvl2,1,NA)
	betas.lvl2<-betas*mask_lvl2;names(betas.lvl2)<-names(betas)
	write.csv(betas.lvl2,file=file.path(outPath,"BetaValue.lvl2.csv"),quote=F)
	if(is.null(betaFn)){
		write.csv(betas,file=file.path(outPath,"BetaValue.csv"),quote=F)
		idat<-assayDataElementReplace(idat,"betas",betas)
	}
	return(idat)
}

calBetaValue2.1.1<-function(idat,betaFn=NULL,pvalueFn=NULL,outPath=NULL,pvalue.lvl2=0.05){
	betas<-NULL;pvals<-NULL
	if(is.null(betaFn)){
		if(is.null(idat)) return()
		methylated<-idat@assayData$methylated
		unmethylated<-idat@assayData$unmethylated
		betas<-methylated/(methylated+unmethylated) #betas<-idat@assayData$betas
		pvals<-idat@assayData$pvals
	}else{
		if(!file.exists(betaFn)|!file.exists(pvalueFn))return()
		betas<-readDataFile.2(betaFn)
		pvals<-readDataFile.2(pvalueFn)
	}
	if(!all(dimnames(betas)[[2]]==dimnames(pvals)[[2]]))stop("Row names of M,U, M.n, U.n don't match.\n")
	if(!all(dimnames(betas)[[1]]==dimnames(pvals)[[1]] ))stop("Col names of M,U, M.n, U.n don't match.\n")
	mask_lvl2<-ifelse(pvals<pvalue.lvl2,1,NA)
	betas.lvl2<-betas*mask_lvl2;names(betas.lvl2)<-names(betas)
	if(is.null(outPath))outPath<-filedir(idatFn)
	write.csv(betas.lvl2,file=file.path(outPath,"BetaValue.lvl2.csv"),quote=F)
	if(is.null(betaFn)){
		write.csv(betas,file=file.path(outPath,"BetaValue.csv"),quote=F)
		idat<-assayDataElementReplace(idat,"betas",betas)
	}
	return(idat)
}

calBetaValue2.1<-function(idat,outPath=NULL,pvalue.lvl2=0.05){
	if(!is.null(idat))return()
	#betas<-idat@assayData$betas
	methylated<-idat@assayData$methylated
	unmethylated<-idat@assayData$unmethylated
	betas<-methylated/(methylated+unmethylated)
	pvals<-idat@assayData$pvals
	if(!all(dimnames(betas)[[2]]==dimnames(pvals)[[2]]))stop("Row names of M,U, M.n, U.n don't match.\n")
	if(!all(dimnames(betas)[[1]]==dimnames(pvals)[[1]] ))stop("Col names of M,U, M.n, U.n don't match.\n")
	mask_lvl2<-ifelse(pvals<pvalue.lvl2,1,NA)
	betas.lvl2<-betas*mask_lvl2;names(betas.lvl2)<-names(betas)
	if(is.null(outPath))outPath<-filedir(idatFn)
	write.csv(betas,file=file.path(outPath,"BetaValue.csv"),quote=F)
	write.csv(betas.lvl2,file=file.path(outPath,"BetaValue.lvl2.csv"),quote=F)
	idat<-assayDataElementReplace(idat,"betas",betas)
	return(idat)
}
####################
# pheno$barcode from data name, pheno$barcodes from sample map
####################
mapPhenoData_test<-function(){
	library(methylumIDAT)
	load(file="c:\\temp\\IDAT\\meth450k\\processed\\6042308117\\6042308117_idat.rda")
	sample.mapping<-readSampleMapping("c:\\tcga\\others\\arraymapping\\meth450")
	pheno<-phenoData(idat)
	pheno2<-mapPhenoData(pheno,sample.mapping)
}
mapPhenoData<-function(pheno,sample.mapping){
	dat <- as(pheno, "data.frame")
	sample.mapping$barcodes<-row.names(sample.mapping)
	dat1<-data.frame(barcode=row.names(dat),rn=row.names(dat),row.names="rn",stringsAsFactors=F)
	ind<-!is.element(names(dat),names(sample.mapping))
	if(sum(ind)>1) dat1<-dat[,ind]
	dat2 <- merge(sample.mapping,dat1, by.x = 0, by.y = 0, all.y = T)[,-1]
	dat2$barcodes<-ifelse(is.na(dat2$barcodes),dat1$barcode,dat2$barcodes)
	row.names(dat2)<-dat2$barcodes
	pheno <- new("AnnotatedDataFrame", data = dat2)
	return(pheno)
}

mapPhenoData.1<-function(pheno,sample.mapping){
	dat <- as(pheno, "data.frame")
	dat1<-data.frame(barcode=as.character(dat$barcode),rn=dat$barcode,row.names="rn",stringsAsFactors=F)
	sample.mapping$barcodes<-row.names(sample.mapping)
	ind<-!is.element(names(dat),names(sample.mapping))
	if(sum(ind)>1) dat1<-dat[,ind]
	dat2 <- merge(sample.mapping,dat1, by.x = 0, by.y = 0, all.y = T)[,-1]
	dat2$barcodes<-ifelse(is.na(dat2$barcodes),dat1$barcode,dat2$barcodes)
	row.names(dat2)<-dat2$barcodes
	pheno <- new("AnnotatedDataFrame", data = dat2)
	return(pheno)
}


mapSampleIDAT_test<-function(){
	library(methylumIDAT)
	load(file="C:\\Documents and Settings\\feipan\\Desktop\\people\\tim\\5543207015.rdata")
	load(file="c:\\temp\\IDAT\\processed\\5775446078\\5775446078_idat.rda")
	sample.mapping<-readSampleMapping("c:\\tcga\\others\\arraymapping\\meth450")
	idat<-mapSampleIDAT(idat,sample.mapping)
	savePhenoDataCSV(idat,"c:\\temp")
	saveIDATcsv(idat,"c:\\temp")
	
	fn<-"c:\\temp\\test3\\meth27k\\processed\\5543207013\\5543207013_idat.rda"
	print(load(file=fn))
	sample.mapping<-readSampleMapping("c:\\tcga\\others\\arraymapping\\meth27")
	idat<-mapSampleIDAT(idat,sample.mapping)
	save(idat,file=fn)
}
mapSampleIDAT<-function(idat,sample.mapping){
	am<-sample.mapping
	mn<-row.names(am);am<-am[,"sampleID"];names(am)<-mn
	bv<-as.data.frame(idat@assayData$betas);bv.mn<-names(bv)
	names(bv)<-ifelse(is.na(am[names(bv)]),names(bv),am[names(bv)])
	am<-names(bv);names(am)<-bv.mn
	methylated<-idat@assayData$methylated;dimnames(methylated)[[2]]<-am[dimnames(methylated)[[2]]]
	unmethylated<-idat@assayData$unmethylated;dimnames(unmethylated)[[2]]<-am[dimnames(unmethylated)[[2]]]
	pvals<-idat@assayData$pvals; dimnames(pvals)[[2]]<-am[dimnames(pvals)[[2]]]
	methylated.N<-idat@assayData$methylated.N; dimnames(methylated.N)[[2]]<-am[dimnames(methylated.N)[[2]]]
	unmethylated.N<-idat@assayData$unmethylated.N;dimnames(unmethylated.N)[[2]]<-am[dimnames(unmethylated.N)[[2]]]
	methylated.SD<-idat@assayData$methylated.SD; dimnames(methylated.SD)[[2]]<-am[dimnames(methylated.SD)[[2]]]
	unmethylated.SD<-idat@assayData$unmethylated.SD; dimnames(unmethylated.SD)[[2]]<-am[dimnames(unmethylated.SD)[[2]]]
	pheno<-phenoData(idat);pheno<-mapPhenoData(pheno,sample.mapping)
	idat.new<-new("MethyLumiSet",betas=as.matrix(bv),methylated=as.matrix(methylated),unmethylated=as.matrix(unmethylated),methylated.N=as.matrix(methylated.N),unmethylated.N=as.matrix(unmethylated.N),pvals=as.matrix(pvals),methylated.SD=as.matrix(methylated.SD),unmethylated.SD=as.matrix(unmethylated.SD))
	phenoData(idat.new)<-pheno
	qc<-idat@QC
	if(!is.null(qc)){
		ctr_m<-qc@assayData$methylated;dimnames(ctr_m)[[2]]<-am[dimnames(ctr_m)[[2]]]
		ctr_u<-qc@assayData$unmethylated;dimnames(ctr_u)[[2]]<-am[dimnames(ctr_u)[[2]]]
		ctr_n<-qc@assayData$NBeads;dimnames(ctr_n)[[2]]<-am[dimnames(ctr_n)[[2]]]
		#ctr_bn<-qc@assayData$BNeads;dimnames(ctr_bn)[[2]]<-am[dimnames(ctr_bn)[[2]]]
		qc<-assayDataElementReplace(qc,"methylated",ctr_m)
		qc<-assayDataElementReplace(qc,"unmethylated",ctr_u)
		qc<-assayDataElementReplace(qc,"NBeads",ctr_n)
		#qc<-assayDataElementReplace(qc,"BNeads",ctr_bn)
		idat.new@QC<-qc
	}
	attr(idat.new,"barcode.beta")<-bv.mn
	return(idat.new)
}

mapSampleIDAT.1<-function(idat,sample.mapping){
	am<-sample.mapping
	mn<-row.names(am);am<-am[,"sampleID"];names(am)<-mn
	bv<-as.data.frame(idat@assayData$betas);bv.mn<-names(bv)
	names(bv)<-ifelse(is.na(am[names(bv)]),names(bv),am[names(bv)])
	am<-names(bv);names(am)<-bv.mn
	methylated<-idat@assayData$methylated;dimnames(methylated)[[2]]<-am[dimnames(methylated)[[2]]]
	unmethylated<-idat@assayData$unmethylated;dimnames(unmethylated)[[2]]<-am[dimnames(unmethylated)[[2]]]
	pvals<-idat@assayData$pvals; dimnames(pvals)[[2]]<-am[dimnames(pvals)[[2]]]
	methylated.N<-idat@assayData$methylated.N; dimnames(methylated.N)[[2]]<-am[dimnames(methylated.N)[[2]]]
	unmethylated.N<-idat@assayData$unmethylated.N;dimnames(unmethylated.N)[[2]]<-am[dimnames(unmethylated.N)[[2]]]
	methylated.SD<-idat@assayData$methylated.SD; dimnames(methylated.SD)[[2]]<-am[dimnames(methylated.SD)[[2]]]
	unmethylated.SD<-idat@assayData$unmethylated.SD; dimnames(unmethylated.SD)[[2]]<-am[dimnames(unmethylated.SD)[[2]]]
	pheno<-phenoData(idat);pheno<-mapPhenoData(pheno,sample.mapping)
	idat.new<-new("MethyLumiSet",betas=as.matrix(bv),methylated=as.matrix(methylated),unmethylated=as.matrix(unmethylated),methylated.N=as.matrix(methylated.N),unmethylated.N=as.matrix(unmethylated.N),pvals=as.matrix(pvals),methylated.SD=as.matrix(methylated.SD),unmethylated.SD=as.matrix(unmethylated.SD))
	phenoData(idat.new)<-pheno
	qc<-idat@QC
	if(!is.null(qc)){
		ctr_m<-qc@assayData$methylated;dimnames(ctr_m)[[2]]<-am[dimnames(ctr_m)[[2]]]
		ctr_u<-qc@assayData$unmethylated;dimnames(ctr_u)[[2]]<-am[dimnames(ctr_u)[[2]]]
		ctr_n<-qc@assayData$NBeads;dimnames(ctr_n)[[2]]<-am[dimnames(ctr_n)[[2]]]
		#idat.new@QC<-new("MethyLumiQC",methylated=ctr_m,unmethylated=ctr_u,NBeads=ctr_n)
		qc<-assayDataElementReplace(qc,"methylated",ctr_m)
		qc<-assayDataElementReplace(qc,"unmethylated",ctr_u)
		qc<-assayDataElementReplace(qc,"BNeads",ctr_n)
		idat.new@QC<-qc
	}
	attr(idat.new,"barcode.beta")<-bv.mn
	return(idat.new)
}

procMethTxtData_test<-function(){
	datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\5324215005"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\5324215005_out2"
	mdat<-procMethTxtData(datPath,outPath,bp.method="filter.min")
	readMethTxt(datPath,outPath,bp.method=NULL)
	
	datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data\\5471637013"
	outPath<-"C:\\temp\\test\\meth27k\\processed\\5471637013"
	
	datPath<-"C:\\temp\\test\\meth27k\\raw\\4841860025"
	outPath<-"C:\\temp\\test\\meth27k\\processed\\4841860025"
	am<-readSampleMapping("c:\\tcga\\others\\arraymapping\\meth27")
	mdat<-procMethTxtData(datPath,outPath,sample.mapping=am)
}
procMethTxtData_test2<-function(){
	datPath<-"/home/uec-02/shared/production/methylation/meth27k/raw/5543207013"
	outPath<-"/home/uec-02/shared/production/methylation/meth27k/other/5543207013"
	am<-readSampleMapping("/home/uec-02/shared/production/methylation/meth27k/arraymapping")
	procMethTxtData(datPath,outPath,sample.mapping=am)
}
procMethTxtData<-function(dataDirectory,repDir=NULL,fname=NULL,txtWin=NULL,is.sepOut=T,toSave=T,bp.method="filter.min",sample.mapping=NULL,negCtrCode=NULL,summaryParam=c("z-score")){
	if(!is.null(txtWin)){cat("start running...",date(),"\n")}
	pvalue.method<-"z-test" #DEC
	if(!is.null(summaryParam))pvalue.method<-summaryParam[1] 
	rawDatFn<-readRawTxtData(dataDirectory)
	if(length(rawDatFn)<1){cat(paste("There is no raw txt data in the array:"),filetail(dataDirectory),"\n");return(NULL)}
	mData<-processRawTxtData.2(rawDatFn,txtWin,bp.method,pvalue.method=pvalue.method,negCtrCode=negCtrCode)
	if(toSave==TRUE){
		if(is.null(fname))fname<-""
		if(is.null(repDir)) repDir <-gFileDir
		mData<-renameSampleWithMap(mData,sample.mapping)
		if(is.sepOut==TRUE) {
			saveMDAT2CSV(mData,repDir)
			saveNegData2CSV(mData,repDir)
			savePhenoDataCSV(mData,repDir)
		}
		attr(mData,"p.method")<-pvalue.method
		save(mData,file=file.path(repDir,paste("mdat",fname,".rdata",sep="")))
	}
	return(mData)
}
updateRawArrays2_test<-function(){
	rawPath<-"C:\\temp\\IDAT\\meth450k\\raw"
	pkgPath<-"C:\\temp\\IDAT\\meth450k\\packaged"
	updateRawArrays2(procPath,arrayPath,rawPath,pkgPath,show.msg=T,platform="meth450k")
}
updateRawArrays2<-function(procPath,arrayPath,rawPath=NULL,pkgPath=NULL,batchPath=NULL,tcgaPath=NULL,show.msg=F,toUpdate=F,platform="meth450k"){
	require(Biobase)
	if(!file.exists(file.path(arrayPath,"sample_mapping.txt")))return()
	ams<-list.files(procPath)
	sample.mapping<-readSampleMapping(arrayPath)
	mData<-NULL;array.updated<-c()
	updateRawArray1<-function(rawPath,pkgPath,show.msg,toUpdate){
		p.method<-attr(mData,"p.method")
		sampleID<-getSampleID(mData)
		if(class(mData)=="methData")mData<-renameSampleWithMap(mData,sample.mapping)
		else if(class(mData)=="MethyLumiSet")mData<-mapSampleIDAT(mData,sample.mapping)
		sampleID.new<-getSampleID(mData)
		if(!all(sampleID==sampleID.new)|toUpdate==T){
			cat("updating array",am,"\n");
			outPath<-file.path(procPath,am)
			if(class(mData)=="methData"){
				saveMDAT2CSV(mData,outPath)
				saveNegData2CSV(mData,outPath)
				attr(mData,"p.method")<-p.method
				save(mData,file=file.path(outPath,"mdat.rdata"))
			}else if(class(mData)=="MethyLumiSet"){
				idat<-mData
				save(idat,file=file.path(outPath,paste(filetail(am),"_idat.rda",sep="")))
				saveIDATcsv(idat,outPath)
			}
			savePhenoDataCSV(mData,outPath)
			if(!is.null(pkgPath))packagingArray(outPath,pkgPath)
			array.updated<-c(array.updated,am)
		}
		return(array.updated)
	}
	for(am in ams){
		dat<-NULL;update<-F
		ar<-list.files(file.path(procPath,am),patt=".rda",full.name=T)
		if(length(ar)>1) {cat("multiple datasets found in array",am,"\n");next}
		else if(length(ar)<1) {
			cat("no dataset found in array",am,"\n");
			update<-T
		}else{
			if(show.msg==T)cat("on data from array",am,"\n");
			mData<-get(load(file=ar))
		}
	
		pkgPath2<-file.path(pkgPath,am)
		rawPath2<-file.path(rawPath,am)
		procPath2<-file.path(procPath,am)
		if(update==T|class(try(array.upated<-updateRawArray1(rawPath2,pkgPath2,show.msg,toUpdate),T))=="try-error"){
			cat(rawPath2,"\n")
			mdat<-procRawArray(rawPath2,procPath2,arrayPath,platform=platform)
			createQCplot(mdat,pkgPath2)
			packagingArray(pkgPath2,procPath2)
		}
	}
	
	if(length(array.updated)>0){
		updateBatches(array.updated,arrayPath,batchPath,tcgaPath)
	}
	cat("Done with updating array data.\n")
}
updateRawArray_test<-function(){
	procPath<-"C:\\temp\\test\\meth27k\\processed"
	arrayPath<-"C:\\temp\\test\\meth27k\\arraymapping"
	updateRawArrays(procPath,arrayPath,show.msg=T,toUpdate=T)
	updateRawArrays(procPath,arrayPath,show.msg=T)
	
	updateRawArrays(procPath,arrayPath)
	procPath<-"c:\\temp\\test3\\meth27k\\processed_IDAT"
	updateRawArrays(procPath,arrayPath,toUpdate=T)
	#meth450
	procPath<-"C:\\temp\\IDAT\\meth450k\\processed"
	arrayPath<-"C:\\temp\\IDAT\\meth450k\\arraymapping"
	rawPath<-"c:\\temp\\IDAT\\meth450k\\raw"
	updateRawArrays(procPath,arrayPath,rawPath=rawPath,show.msg=T,platform="meth450k")
	updateRawArrays(procPath,arrayPath,show.msg=T,toUpdate=T)
}
updateRawArrays<-function(procPath,arrayPath,pkgPath=NULL,batchPath=NULL,tcgaPath=NULL,rawPath=NULL,platform="meth450k",show.msg=F,toUpdate=F){
	require(Biobase)
	if(!file.exists(file.path(arrayPath,"sample_mapping.txt")))return()
	ams<-list.files(procPath)
	sample.mapping<-readSampleMapping(arrayPath)
	mData<-NULL;array.updated<-c()
	for(am in ams){
		dat<-NULL
		ar<-list.files(file.path(procPath,am),patt=".rda",full.name=T)
		if(length(ar)>1) {cat("multiple datasets found in array",am,"\n");next}
		else if(length(ar)<1) {
			cat("no dataset found in array",am,",start to process ",am,"\n")
			mdat<-procRawArray(file.path(rawPath,am),file.path(procPath,am),arrayPath,platform=platform)
			createQCplot(mdat,file.path(pkgPath,am))
			packagingArray(file.path(pkgPath,am),file.path(procPath,am))
			next
		}
		else{
			if(show.msg==T)cat("on data from array",am,"\n");
			mData<-get(load(file=ar))
		}
		p.method<-attr(mData,"p.method")
		sampleID<-getSampleID(mData)
		if(class(mData)=="methData")mData<-renameSampleWithMap(mData,sample.mapping)
		else if(class(mData)=="MethyLumiSet")mData<-mapSampleIDAT(mData,sample.mapping)
		sampleID.new<-getSampleID(mData)
		if(!all(sampleID==sampleID.new)|toUpdate==T){
			cat("updating array",am,"\n");
			outPath<-file.path(procPath,am)
			if(class(mData)=="methData"){
				saveMDAT2CSV(mData,outPath)
				saveNegData2CSV(mData,outPath)
				attr(mData,"p.method")<-p.method
				save(mData,file=file.path(outPath,"mdat.rdata"))
			}else if(class(mData)=="MethyLumiSet"){
				idat<-mData
				save(idat,file=file.path(outPath,paste(filetail(am),"_idat.rda",sep="")))
				saveIDATcsv(idat,outPath)
			}
			savePhenoDataCSV(mData,outPath)
			if(!is.null(pkgPath))packagingArray(outPath,file.path(pkgPath,am))
			array.updated<-c(array.updated,am)
		}
	}
	if(length(array.updated)>0){
		updateBatches(array.updated,arrayPath,batchPath,tcgaPath)
	}
	cat("Done with updating array data.\n")
}
updateRawArrays.1<-function(procPath,arrayPath,pkgPath=NULL,batchPath=NULL,tcgaPath=NULL,show.msg=F,toUpdate=F){
	require(Biobase)
	if(!file.exists(file.path(arrayPath,"sample_mapping.txt")))return()
	ams<-list.files(procPath)
	sample.mapping<-readSampleMapping(arrayPath)
	mData<-NULL;array.updated<-c()
	for(am in ams){
		dat<-NULL
		ar<-list.files(file.path(procPath,am),patt=".rda",full.name=T)
		if(length(ar)>1) {cat("multiple datasets found in array",am,"\n");next}
		else if(length(ar)<1) {cat("no dataset found in array",am,"\n");next}
		else{
			if(show.msg==T)cat("on data from array",am,"\n");
			mData<-get(load(file=ar))
		}
		p.method<-attr(mData,"p.method")
		sampleID<-getSampleID(mData)
		if(class(mData)=="methData")mData<-renameSampleWithMap(mData,sample.mapping)
		else if(class(mData)=="MethyLumiSet")mData<-mapSampleIDAT(mData,sample.mapping)
		sampleID.new<-getSampleID(mData)
		if(!all(sampleID==sampleID.new)|toUpdate==T){
			cat("updating array",am,"\n");
			outPath<-file.path(procPath,am)
			if(class(mData)=="methData"){
				saveMDAT2CSV(mData,outPath)
				saveNegData2CSV(mData,outPath)
				attr(mData,"p.method")<-p.method
				save(mData,file=file.path(outPath,"mdat.rdata"))
			}else if(class(mData)=="MethyLumiSet"){
				idat<-mData
				save(idat,file=file.path(outPath,paste(filetail(am),"_idat.rda",sep="")))
				saveIDATcsv(idat,outPath)
			}
			savePhenoDataCSV(mData,outPath)
			if(!is.null(pkgPath))packagingArray(outPath,file.path(pkgPath,am))
			array.updated<-c(array.updated,am)
		}
	}
	if(length(array.updated)>0){
		updateBatches(array.updated,arrayPath,batchPath,tcgaPath)
	}
	cat("Done with updating array data.\n")
}

getSampleID<-function(dat){
	sampID<-NULL
	if(class(dat)=="MethyLumiSet"){
		require(methylumi)
		sampID<-dimnames(dat@assayData$betas)[[2]]
	}else if(class(dat)=="methData"){
		sampID<-getSampID(dat) #sampID<-dimnames(dat@assayData$BetaValue)[[2]]
	}else{
		flist<-list.files(dat,pattern="lvl-1")
		sid<-sapply(flist,function(x)strsplit(x,"lvl-1")[[1]][2])
		sampID<-sapply(sid,function(x)strsplit(x,"\\.")[[1]][2])
	}
	return(sampID)
}
getSampleID.1<-function(dataFolder){
	setwd(dataFolder)
	flist<-list.files(pattern="lvl-1")
	sid<-sapply(flist,function(x)strsplit(x,"lvl-1")[[1]][2])
	sid<-sapply(sid,function(x)strsplit(x,"\\.")[[1]][2])
}
readRawTxtData<-function(dataDirectory){
	rawDataFileNames <- c();
	setwd(dataDirectory);
	flist = list.files(pattern="*_[A-L].txt",
			recursive=T);
	if(length(flist)<1){
		cat(paste("There is no TXT data files in the array folder:",filetail(dataDirectory),"\n"))
	}else{
		for(i in 1:length(flist)){
			flist_cur = unlist(strsplit(
							filetail(flist[i]),
							"\\."))[1];
			fidNames = flist_cur;
			if(fidNames!="Metrices"){
				rawDataFileNames<-c(rawDataFileNames,file.path(dataDirectory,flist[i]))
			}
		}
	}
	return(rawDataFileNames)
}


readCtrTxtData<-function(fn,txtWin=NULL){
	ctrData<-list();
	data(ilmn_code)
	if(!exists("ilmn_code"))ilmn_code<-readIlmnCode()
	for(i in 1:length(fn)){
		fn.cur<-filetail(fn[i])
		if(fn.cur=="Metrices.txt") next
		prefix<-unlist(strsplit(fn.cur,"\\."))[[1]]
		fdata<-read.delim(file=fn[i],sep="\t",header=T,as.is=T)
		ctrData.tmp<-merge(ilmn_ctr_code,fdata,by.x=1,by.y=1,all.x=TRUE)
		rn<-paste(ctrData.tmp$type,ctrData.tmp$color,ctrData.tmp$name,ctrData.tmp$code,1:nrow(ctrData.tmp),sep="_")
		row.names(ctrData.tmp)<-rn #1:nrow(ctrData.tmp)#ctrData.tmp$code
		nm<-c(names(ctrData),prefix)
		#ctrData.tmp<-as.matrix(ctrData.tmp[,c(-1,-2,-3,-4)])
		ctrData<-c(ctrData,list(ctrData.tmp))
		names(ctrData)<-nm
	}
	return(ctrData)
}
bp_test<-function(){
	dat<-rnorm(20)
	bp1<-bp(dat,bp.method="filter.min")
	str(bp1)
	bp2<-bp(dat,bp.method="filter.max")
	str(bp2)
	bp3<-bp(dat,bp.method="filter.outlier")
	str(bp3)
	bp4<-bp(dat)
	str(bp4)
	dat<-rnorm(3)
	dat<-rnorm(7)
}

#bp<-function(dat,bp.method=NULL,n.cut=10,n.min=3){
bp<-function(dat,bp.method=NULL,n.cut=10,n.min=0){
	dat.avg<-NULL
	dat.err<-NULL
	dat.n<-length(dat)
	dat.n1<-dat.n
	if(dat.n<=n.min){
		dat.avg<-NA
		dat.err<-NA
	}else if(dat.n<=n.cut |is.null(bp.method)){
		dat.avg<-mean(dat,na.rm=T)
		dat.err<-sd(dat,na.rm=T)/sqrt(dat.n)
	}else if(!is.null(bp.method)){
		if(bp.method=="filter.min"){
			dat.min<-dat[-which.min(dat)]
			dat.avg<-mean(dat.min,na.rm=T)
			dat.err<-sd(dat.min,na.rm=T)/sqrt(dat.n-1)
			dat.n1<-dat.n-1
		}else if(bp.method=="filter.max"){
			dat.max<-dat[-which.max(dat)]
			dat.avg<-mean(dat.max,na.rm=T)
			dat.err<-sd(dat.max,na.rm=T)/sqrt(dat.n-1)
			dat.n1<-dat.n-1
		}else if(bp.method=="filter.outlier"){
			dat.avg<-mean(dat,na.rm=T)
			dat.std<-sd(dat,na.rm=T)
			dat.err<-dat.std/sqrt(dat.n)
			dat.n1<-dat.n
			ind<-dat>(dat.avg+3*dat.std)|dat<(dat.avg-3*dat.std)
			if(sum(ind)>0){
				dat.out<-dat[-ind]
				dat.avg<-mean(dat.out,na.rm=T)
				dat.n1<-dat.n-length(ind)
				dat.err<-sd(dat.out,na.rm=T)/sqrt(dat.n1)
			}
		}else{
			cat(paste("The method of",bp.method,"is unknown\n"))
			stop()
		}
	}
	return(c(avg=dat.avg,err=dat.err,num=dat.n,num.after=dat.n1))
}

##########################
#
# optimized: 10/22/2010
#########################
processRawTxtData.2_test<-function(){
	rawDatFn<-c("C:\\temp\\test\\meth27k\\raw\\4841860025\\4841860025_A.txt",
			"C:\\temp\\test\\meth27k\\raw\\4841860025\\4841860025_C.txt")
	rawDatFn<-list.files("C:\\Documents and Settings\\feipan\\Desktop\\people\\test_data\\5543207013",
			patt=".txt",full.names=T)
	rawDatFn<-rawDatFn[-grep("Metrics",rawDatFn)]
	mdata<-processRawTxtData.2(rawDatFn)
	save(mdata,file="c:\\temp\\5543207013_mdat.rdata")
}
processRawTxtData.2<-function(rawDatFn,txtWin=NULL,bp.method=NULL,pvalue.method="z-score",negCtrCode=NULL){
	mdata = data.frame(id=1:27578);
	mdata = mdata[-1];
	data(ilmn_code) # ilmn_code, 27578x5
	data(ilmnCtrCode) #ilmn_ctr_code, dim() 143x4
	data(NegCtlCode) #ctl_code
	rownames(mdata) <- ilmn_code$IlmnID
	rownames(ilmn_code) <- ilmn_code$IlmnID
	if(!is.null(negCtrCode)) ctr_code<-negCtrCode
	ctrData<-list();ctrNegData<-list()
	
	for(i in 1:length(rawDatFn)){
		if(filetail(rawDatFn[i])=="Metrices.txt" |filetail(rawDatFn[i])=="Metrics.txt") next
		fdata=try(read.delim(rawDatFn[i],header=TRUE,sep="\t",as.is=T),T)
		if(class(fdata)=="try-error"){
			if(!is.null(txtWin)) tkinsert(txtWin,"end",fdata)
			cat(paste("There is an error when reading the raw data file ",rawDatFn[i],":",fdata,",skipped.\n"))
			cat("Continue to process the next data file\n")
			next
		}
		fdataGrn.all<-tapply(fdata$Grn,fdata$Code,bp,bp.method)
		fdataGrn<- as.data.frame(t(sapply(fdataGrn.all,as.numeric))) #data.frame(Grn_Avg=fdataGrn.all$avg,Grn_num=fdataGrn.all$num,Grn_err=fdataGrn.all$err,Grn_num2=fdataGrn.all$num.after)
		names(fdataGrn)<-c("Grn_Avg","Grn_ERR","Grn_numb","Grn_Num2")
		fdataRed.all<-tapply(fdata$Red,fdata$Code,bp,bp.method)
		fdataRed<-as.data.frame(t(sapply(fdataRed.all,as.numeric)))#data.frame(Red_Avg=fdataRed.all$avg,Red_num=fdataRed.all$num,Red_err=fdataRed.all$err,Red_num2=fdataRed.all$num.after)
		names(fdataRed)<-c("Red_Avg","Red_ERR","Red_numb","Red_Num2")
		
		meth_U_Grn = merge(fdataGrn,ilmn_code,by.x=0,by.y="AddressA_ID",all.y=T); #could generate warnings if there is missing data
		meth_U_Red = merge(fdataRed,ilmn_code,by.x=0,by.y="AddressA_ID",all.y=T);
		meth_U_Grn<-meth_U_Grn[order(meth_U_Grn$IlmnID),]
		meth_U_Red<-meth_U_Red[order(meth_U_Red$IlmnID),]
		U = ifelse(meth_U_Grn$Color_Channel=="Red",meth_U_Red$Red_Avg,meth_U_Grn$Grn_Avg);
		U.number=ifelse(meth_U_Grn$Color_Channel=="Red",meth_U_Red$Red_numb,meth_U_Grn$Grn_numb)
		names(U)<-meth_U_Grn$IlmnID
		names(U.number)<-meth_U_Grn$IlmnID
		U.number2=ifelse(meth_U_Grn$Color_Channel=="Red",meth_U_Red$Red_Num2,meth_U_Grn$Grn_Num2)
		names(U.number2)<-meth_U_Grn$IlmnID
		U.STDERR=ifelse(meth_U_Grn$Color_Channel=="Red",meth_U_Red$Red_ERR,meth_U_Grn$Grn_ERR)
		names(U.STDERR)<-meth_U_Grn$IlmnID
		U.sorted <- U
		
		meth_M_Grn = merge(fdataGrn,ilmn_code,by.x=0,by.y="AddressB_ID",all.y=T)
		meth_M_Red = merge(fdataRed,ilmn_code,by.x=0,by.y="AddressB_ID",all.y=T)
		meth_M_Grn <-meth_M_Grn[order(meth_M_Grn$IlmnID),]
		meth_M_Red <-meth_M_Red[order(meth_M_Red$IlmnID),]
		M = ifelse(meth_M_Grn$Color_Channel=="Red",meth_M_Red$Red_Avg,meth_M_Grn$Grn_Avg)
		M.number = ifelse(meth_M_Grn$Color_Channel=="Red",meth_M_Red$Red_numb,meth_M_Grn$Grn_numb)
		names(M)<-meth_M_Grn$IlmnID
		names(M.number)<-meth_M_Grn$IlmnID
		M.number2=ifelse(meth_M_Grn$Color_Channel=="Red",meth_M_Red$Red_Num2,meth_M_Grn$Grn_Num2)
		names(M.number2)<-meth_M_Grn$IlmnID
		M.STDERR=ifelse(meth_M_Grn$Color_Channel=="Red",meth_M_Red$Red_ERR,meth_M_Grn$Grn_ERR)
		names(M.STDERR)<-meth_M_Grn$IlmnID
		M.sorted <-M
		
		betaValue = round(M.sorted)/(round(M.sorted)+round(U.sorted)); #add rounding on 04/04/2011, digit=0 by default #betaValue = M.sorted/(M.sorted+U.sorted);
		#betaValue = round(betaValue,digits = 4);
		
		meth_ctl_Red = merge(fdataRed,ctl_code,by.x=0,by.y=1)
		ctl_red_mean= mean(meth_ctl_Red$Red_Avg);
		ctl_red_sd= sd(meth_ctl_Red$Red_Avg);
		ctl_red_ster = ctl_red_sd/sqrt(length(meth_ctl_Red$Red_Avg)); #4; Dec/2010
		
		meth_ctl_Grn = merge(fdataGrn,ctl_code,by.x=0,by.y=1);
		ctl_grn_mean= mean(meth_ctl_Grn$Grn_Avg);
		ctl_grn_sd= sd(meth_ctl_Grn$Grn_Avg);
		ctl_grn_ster = ctl_grn_sd/sqrt(length(meth_ctl_Grn$Grn_Avg)) #4;
		
		ctr_avg = ifelse(meth_M_Red$Color_Channel=="Red",ctl_red_mean,ctl_grn_mean);
		ctr_sd = ifelse(meth_M_Red$Color_Channel=="Red",ctl_red_sd,ctl_grn_sd);
		# cal p value
		t = M.sorted>U.sorted;
		AB = t*M.sorted+(!t)*U.sorted;
		pValue.red = calpvalue(matrix(AB),meth_ctl_Red$Red_Avg,pvalue.method)
		pValue.grn = calpvalue(matrix(AB),meth_ctl_Grn$Grn_Avg,pvalue.method)
		pValue = ifelse(meth_M_Red$Color_Channel=="Red",pValue.red,pValue.grn)
		
		flist_cur<-filetail(rawDatFn[i])
		prefix = unlist(strsplit(flist_cur,"\\."))[1];
		
		tt=data.frame(M=M.sorted,U=U.sorted,Beta=betaValue,Pvalue=pValue,
				M_STDERR=M.STDERR,U_STDERR=U.STDERR,
				M_number=M.number,U_number=U.number,
				M_number2=M.number2,U_number2=U.number2)
		names(tt)=paste(prefix,names(tt),sep="_")
		
		mdata<-data.frame(mdata,tt)
		
		#start the ctrData
		ctrData.tmp<-merge(ilmn_ctr_code,fdata,by.x=1,by.y=1,all.x=TRUE)
		nm<-c(names(ctrData),prefix)
		ctrData<-c(ctrData,list(ctrData.tmp))#,Neg_R=meth_ctl_Red$Red_Avg,Neg_G=meth_ctl_Grn$Grn_Avg))
		names(ctrData)<-nm
		row.names(meth_ctl_Grn)<-meth_ctl_Grn[,1];meth_ctl_Grn<-meth_ctl_Grn[as.character(ctl_code[,1]),];
		row.names(meth_ctl_Red)<-meth_ctl_Red[,1];meth_ctl_Red<-meth_ctl_Red[as.character(ctl_code[,1]),]
		ctrNegData<-c(ctrNegData,list(data.frame(R=meth_ctl_Red$Red_Avg,G=meth_ctl_Grn$Grn_Avg,Address=ctl_code[,1])))
		names(ctrNegData)<-nm
#		#end of ctrData
		cat("Finished ",flist_cur,"\n")
		if(!is.null(txtWin))
			cat(">finished",flist_cur,"\n",sep=" ")
	}
	gg<-names(mdata)
	require(Biobase)
	mData<-new("methData",M=as.matrix(mdata[,gg[grep("M$",gg)]]),
			U=as.matrix(mdata[,gg[grep("U$",gg)]]),
			BetaValue=as.matrix(mdata[,gg[grep("Beta$",gg)]]),
			Pvalue=as.matrix(mdata[,gg[grep("Pvalue$",gg)]]),
			Mstderr=as.matrix(mdata[,gg[grep("M_STDERR$",gg)]]),
			Ustderr=as.matrix(mdata[,gg[grep("U_STDERR$",gg)]]),
			Mnumber=as.matrix(mdata[,gg[grep("M_number$",gg)]]),
			Unumber=as.matrix(mdata[,gg[grep("U_number$",gg)]]),
			Mnumber2=as.matrix(mdata[,gg[grep("M_number2$",gg)]]),
			Unumber2=as.matrix(mdata[,gg[grep("U_number2$",gg)]]));
	#featureData(mData)<-new("AnnotatedDataFrame",data=ilmn_code)
	#phenoData(mData)<-createPhenoData(ctrData)
	rm(mdata)
	attr(mData,"class")<-"methData"
	attr(mData,"date")<-date()
	cData<<-ctrData
	setCData(mData)<-ctrData; setNegData(mData)<-ctrNegData
	return (mData)
}


saveCtrData2CSV_test<-function(){
	load(file=file.path("C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\4207113144","cData.rdata"))
	am<-readSampleMapping("c:\\tcga\\arraymapping")
	outDir<-"c:\\temp\\4207113144"
	saveCtrData2CSV.3(cData,outDir,am)
	saveCtrData2CSV.3a(cData,outDir,verbose=F)
}
saveCtrData2CSV.3a<-function(cData=NULL,outDir,sample.mapping=NULL,bp.method="filter.min",verbose=F){
	setwd(outDir)
	data(ilmnCtrCode)
	row.names(ilmn_ctr_code)<-ilmn_ctr_code$code
	dat.grn<-NULL
	dat.red<-NULL
	for(i in 1:length(cData)){
		cdat<-split(cData[[i]][,c("code","Red","Grn")],as.factor(cData[[i]]$type))
		grn<-c();grn.name<-c();grn.code<-c()
		red<-c();red.name<-c();red.code<-c()
		for(j in 1:length(cdat)){
			grn.avg<-tapply(cdat[[j]]$Grn,cdat[[j]]$code,function(x){rs=bp(x,bp.method);rs[[1]]})
			grn<-c(grn,grn.avg)
			grn.code<-c(grn.code,names(grn.avg))
			grn.name<-c(grn.name,rep(names(cdat)[j],length(grn.avg)))
			red.avg<-tapply(cdat[[j]]$Red,cdat[[j]]$code,function(x){rs=bp(x,bp.method);rs[[1]]})
			red<-c(red,red.avg)
			red.code<-c(red.code,names(red.avg))
			red.name<-c(red.name,rep(names(cdat)[j],length(red.avg)))
		}
		names(grn)<-grn.name
		names(red)<-red.name
		if(is.null(dat.grn)) dat.grn<-data.frame(grn)
		else dat.grn<-data.frame(dat.grn,grn)
		if(is.null(dat.red)) dat.red<-data.frame(red)
		else dat.red<-data.frame(dat.red,red)
	}
	dat.nm<-names(cData)
	if(!is.null(sample.mapping)){
		sid<-sample.mapping[dat.nm,]$sampleID
		dat.nm<-ifelse(is.na(sid),dat.nm,sid)
	}
	names(dat.red)<-dat.nm
	names(dat.grn)<-dat.nm
	ctr.dat<-dat.red/(dat.red+dat.grn)
	ctr_signal_red<-data.frame(ilmn_ctr_code[red.code,],dat.red,check.names=F)
	ctr_signal_grn<-data.frame(ilmn_ctr_code[grn.code,],dat.grn,check.names=F)
	if(verbose==F){
		data(NegCtlCode)
		ctr_signal_red<-merge(ctr_signal_red,ctl_code,by.x=1,by.y=1)[,c(-3,-4)]
		ctr_signal_grn<-merge(ctr_signal_grn,ctl_code,by.x=1,by.y=1)[,c(-3,-4)]
	}
	write.csv(ctr_signal_red[,-1],file="Control_Signal_Intensity_Red.csv",row.names=F,quote=F)
	write.csv(ctr_signal_grn[,-1],file="Control_Signal_Intensity_Grn.csv",row.names=F,quote=F)
	#write.csv(data.frame(ilmn_ctr_code[grn.code,-1],ctr.dat,check.names=F),file="Control_Value.csv",row.names=F,quote=F)
}
saveCtrData2CSV.3<-function(cData=NULL,outDir,sample.mapping=NULL,bp.method="filter.min"){
	setwd(outDir)
	data(ilmnCtrCode)
	row.names(ilmn_ctr_code)<-ilmn_ctr_code$code
	dat.grn<-NULL
	dat.red<-NULL
	for(i in 1:length(cData)){
		cdat<-split(cData[[i]][,c("code","Red","Grn")],as.factor(cData[[i]]$type))
		grn<-c();grn.name<-c();grn.code<-c()
		red<-c();red.name<-c();red.code<-c()
		for(j in 1:length(cdat)){
			grn.avg<-tapply(cdat[[j]]$Grn,cdat[[j]]$code,function(x){rs=bp(x,bp.method);rs[[1]]})
			grn<-c(grn,grn.avg)
			grn.code<-c(grn.code,names(grn.avg))
			grn.name<-c(grn.name,rep(names(cdat)[j],length(grn.avg)))
			red.avg<-tapply(cdat[[j]]$Red,cdat[[j]]$code,function(x){rs=bp(x,bp.method);rs[[1]]})
			red<-c(red,red.avg)
			red.code<-c(red.code,names(red.avg))
			red.name<-c(red.name,rep(names(cdat)[j],length(red.avg)))
		}
		names(grn)<-grn.name
		names(red)<-red.name
		if(is.null(dat.grn)) dat.grn<-data.frame(grn)
		else dat.grn<-data.frame(dat.grn,grn)
		if(is.null(dat.red)) dat.red<-data.frame(red)
		else dat.red<-data.frame(dat.red,red)
	}
	dat.nm<-names(cData)
	if(!is.null(sample.mapping)){
		sid<-sample.mapping[dat.nm,]$sampleID
		dat.nm<-ifelse(is.na(sid),dat.nm,sid)
	}
	names(dat.red)<-dat.nm
	names(dat.grn)<-dat.nm
	ctr.dat<-dat.red/(dat.red+dat.grn)
	write.csv(data.frame(ilmn_ctr_code[red.code,-1],dat.red,check.names=F),file="Control_Signal_Intensity_Red.csv",row.names=F,quote=F)
	write.csv(data.frame(ilmn_ctr_code[grn.code,-1],dat.grn,check.names=F),file="Control_Signal_Intensity_Grn.csv",row.names=F,quote=F)
	#write.csv(data.frame(ilmn_ctr_code[grn.code,-1],ctr.dat,check.names=F),file="Control_Value.csv",row.names=F,quote=F)
}
saveCtrData2CSV.2a<-function(cData=NULL,outDir,sample.mapping=NULL,bp.method="filter.min"){
	setwd(outDir)
	dat.grn<-NULL
	dat.red<-NULL
	for(i in 1:length(cData)){
		cdat<-split(cData[[i]][,c("code","Red","Grn")],as.factor(cData[[i]]$type))
		grn<-c();grn.name<-c()
		red<-c();red.name<-c()
		for(j in 1:length(cdat)){
			grn.avg<-tapply(cdat[[j]]$Grn,cdat[[j]]$code,function(x){rs=bp(x,bp.method);rs[[1]]})
			grn<-c(grn,grn.avg)
			grn.name<-c(grn.name,rep(names(cdat)[j],length(grn.avg)))
			red.avg<-tapply(cdat[[j]]$Red,cdat[[j]]$code,function(x){rs=bp(x,bp.method);rs[[1]]})
			red<-c(red,red.avg)
			red.name<-c(red.name,rep(names(cdat)[j],length(red.avg)))
		}
		names(grn)<-grn.name
		names(red)<-red.name
		if(is.null(dat.grn)) dat.grn<-data.frame(grn)
		else dat.grn<-data.frame(dat.grn,grn)
		if(is.null(dat.red)) dat.red<-data.frame(red)
		else dat.red<-data.frame(dat.red,red)
	}
	dat.nm<-names(cData)
	if(!is.null(sample.mapping)){
		sid<-sample.mapping[dat.nm,]$sampleID
		dat.nm<-ifelse(is.na(sid),dat.nm,sid)
	}
	names(dat.red)<-dat.nm
	names(dat.grn)<-dat.nm
	write.csv(data.frame(name=red.name,dat.red,check.names=F),file="Control_Signal_Intensity_Red.csv",row.names=F,quote=F)
	write.csv(data.frame(name=grn.name,dat.grn,check.names=F),file="Control_Signal_Intensity_Grn.csv",row.names=F,quote=F)
}
saveCtrData2CSV.2<-function(cData=NULL,outDir,sample.mapping=NULL){
	setwd(outDir)
	dat.grn<-NULL
	dat.red<-NULL
	for(i in 1:length(cData)){
		cdat<-split(cData[[i]][,c("code","Red","Grn")],as.factor(cData[[i]]$type))
		grn<-c();grn.name<-c()
		red<-c();red.name<-c()
		for(j in 1:length(cdat)){
			grn.avg<-tapply(cdat[[j]]$Grn,cdat[[j]]$code,mean)
			grn<-c(grn,grn.avg)
			grn.name<-c(grn.name,rep(names(cdat)[j],length(grn.avg)))
			red.avg<-tapply(cdat[[j]]$Red,cdat[[j]]$code,mean)
			red<-c(red,red.avg)
			red.name<-c(red.name,rep(names(cdat)[j],length(red.avg)))
		}
		names(grn)<-grn.name
		names(red)<-red.name
		if(is.null(dat.grn)) dat.grn<-data.frame(grn)
		else dat.grn<-data.frame(dat.grn,grn)
		if(is.null(dat.red)) dat.red<-data.frame(red)
		else dat.red<-data.frame(dat.red,red)
	}
	dat.nm<-names(cData)
	if(!is.null(sample.mapping)){
		sid<-sample.mapping[dat.nm,]$sampleID
		dat.nm<-ifelse(is.na(sid),dat.nm,sid)
	}
	names(dat.red)<-dat.nm
	names(dat.grn)<-dat.nm
	write.csv(data.frame(name=red.name,dat.red,check.names=F),file="Control_Signal_Intensity_Red.csv",row.names=F,quote=F)
	write.csv(data.frame(name=grn.name,dat.grn,check.names=F),file="Control_Signal_Intensity_Grn.csv",row.names=F,quote=F)
}
saveCtrData2CSV<-function(cData=NULL,outDir,sample.mapping=NULL){
	setwd(outDir)
	dat.grn<-NULL
	dat.red<-NULL
	for(i in 1:length(cData)){
		cdat<-split(cData[[i]][,c("code","Red","Grn")],as.factor(cData[[i]]$type))
		grn<-c();grn.name<-c()
		red<-c();red.name<-c()
		for(j in 1:length(cdat)){
			grn.avg<-tapply(cdat[[j]]$Grn,cdat[[j]]$code,mean)
			grn<-c(grn,grn.avg)
			grn.name<-c(grn.name,rep(names(cdat)[j],length(grn.avg)))
			red.avg<-tapply(cdat[[j]]$Red,cdat[[j]]$code,mean)
			red<-c(red,red.avg)
			red.name<-c(red.name,rep(names(cdat)[j],length(red.avg)))
		}
		names(grn)<-grn.name
		names(red)<-red.name
		if(is.null(dat.grn)) dat.grn<-data.frame(grn)
		else dat.grn<-data.frame(dat.grn,grn)
		if(is.null(dat.red)) dat.red<-data.frame(red)
		else dat.red<-data.frame(dat.red,red)
	}
	names(dat.red)<-names(cData)
	names(dat.grn)<-names(cData)
	write.csv(data.frame(name=red.name,dat.red),file="Control_Signal_Intensity_Red.csv",row.names=F,quote=F)
	write.csv(data.frame(name=grn.name,dat.grn),file="Control_Signal_Intensity_Grn.csv",row.names=F,quote=F)
}
saveProcessedTxtData.2a_test<-function(){
	load(file=file.path("C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\testing_out\\4207113144","mData.rdata"))
	am<-readSampleMapping("c:\\tcga\\arraymapping")
	outDir<-"c:\\temp\\4207113144"
	saveProcessedTxtData.2a(mData,outDir,sample.mapping=am)
}
renameSampleWithMap_test<-function(){
	print(load(file="C:\\temp\\test\\meth27k\\processed\\5543207013\\mdat.rdata"))
	print(load(file="C:\\temp\\test\\meth27k\\processed\\4841860025\\mdat.rdata"))
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth27"
	sample.mapping<-readSampleMapping(arrayPath)
	mdat<-renameSampleWithMap(mData,sample.mapping)
	savePhenoDataCSV(mdat,"C:\\temp")
}
renameSampleWithMap<-function(mData,sample.mapping){
	elems<-assayDataElementNames(mData)
	rename<-function(dat){
		if(class(dat)=="matrix")dat<-as.data.frame(dat)
		dat.n<-sapply(names(dat),function(x){
					str<-strsplit(x,"_")[[1]];
					ifelse(length(str)>1,paste(str[1:2],collapse="_"),str)
				})
		if(!is.null(sample.mapping)) {
			dat.n1<-gsub("^X","",dat.n)
			sid<-sample.mapping[dat.n1,]$sampleID
			dat.n<-ifelse(is.na(sid),dat.n1,sid)
		}
		names(dat)<-dat.n
		return(dat)
	}
	for(elem in elems){
		dat<-as.data.frame(assayDataElement(mData,elem))
		dat<-rename(dat)
		mData<-assayDataElementReplace(mData,elem,dat)
	}
	
	pheno<-phenoData(mData);
	dat<-as(pheno,"data.frame")
	row.names(dat)<-sapply(row.names(dat),function(x){
				x<-gsub("^X","",x)
				str<-strsplit(x,"_")[[1]];
				ifelse(length(str)>1,paste(str[1:2],collapse="_"),str)
			})
	dat1<-data.frame(barcode=row.names(dat),stringsAsFactors=F)
	row.names(dat1)<-row.names(dat)
	sample.mapping$barcodes<-row.names(sample.mapping)
	ind<-!is.element(names(dat),names(sample.mapping))
	if(sum(ind)>1) dat1<-dat[,ind]
	dat2 <- merge(sample.mapping,dat1, by.x = 0, by.y = 0, all.y = T)[,-1]
	dat2$barcodes<-ifelse(is.na(dat2$barcodes),dat1$barcode,dat2$barcodes)
	row.names(dat2)<-dat2$barcodes
	phenoData(mData)<-new("AnnotatedDataFrame",data=dat2)
	
	setCData(mData)<-rename(getCData(mData))
	setNegData(mData)<-rename(getNegData(mData))
	return(mData)
}

renameSampleWithMap.1.2<-function(mData,sample.mapping){
	elems<-assayDataElementNames(mData)
	rename<-function(dat){
		if(class(dat)=="matrix")dat<-as.data.frame(dat)
		dat.n<-sapply(names(dat),function(x){
					str<-strsplit(x,"_")[[1]];
					ifelse(length(str)>1,paste(str[1:2],collapse="_"),str)
				})
		if(!is.null(sample.mapping)) {
			dat.n1<-gsub("^X","",dat.n)
			sid<-sample.mapping[dat.n1,]$sampleID
			dat.n<-ifelse(is.na(sid),dat.n1,sid)
		}
		names(dat)<-dat.n
		return(dat)
	}
	for(elem in elems){
		dat<-as.data.frame(assayDataElement(mData,elem))
		dat<-rename(dat)
		mData<-assayDataElementReplace(mData,elem,dat)
	}
	
	pheno<-phenoData(mData);
	dat<-as(pheno,"data.frame")
	row.names(dat)<-sapply(row.names(dat),function(x){
				x<-gsub("^X","",x)
				str<-strsplit(x,"_")[[1]];
				ifelse(length(str)>1,paste(str[1:2],collapse="_"),str)
			})
	ind<-is.element(row.names(sample.mapping),row.names(dat))
	dat.samp<-sample.mapping[ind,]
	dat.samp$barcodes<-row.names(dat.samp)
	dat<-merge(dat.samp,dat,by.y=0,by.x="barcodes",all.y=T)
	row.names(dat)<-dat$barcodes
	phenoData(mData)<-new("AnnotatedDataFrame",data=dat)
	
	setCData(mData)<-rename(getCData(mData))
	setNegData(mData)<-rename(getNegData(mData))
	return(mData)
}
renameSampleWithMap.1.1<-function(mData,sample.mapping){
	elems<-assayDataElementNames(mData)
	rename<-function(dat){
		if(class(dat)=="matrix")dat<-as.data.frame(dat)
		dat.n<-sapply(names(dat),function(x){
					str<-strsplit(x,"_")[[1]];
					ifelse(length(str)>1,paste(str[1:2],collapse="_"),str)
				})
		if(!is.null(sample.mapping)) {
			dat.n1<-gsub("^X","",dat.n)
			sid<-sample.mapping[dat.n1,]$sampleID
			dat.n<-ifelse(is.na(sid),dat.n1,sid)
		}
		names(dat)<-dat.n
		return(dat)
	}
	for(elem in elems){
		dat<-as.data.frame(assayDataElement(mData,elem))
		dat<-rename(dat)
		mData<-assayDataElementReplace(mData,elem,dat)
	}
	pheno<-phenoData(mData);
	dat<-as(pheno,"data.frame")
	dat<-t(rename(t(dat)))
	ind<-is.element(sample.mapping$sampleID,row.names(dat))
	dat.samp<-sample.mapping[ind,]
	dat<-merge(dat,dat.samp,by.x=0,by.y="sampleID",all.x=T)
	phenoData(mData)<-new("AnnotatedDataFrame",data=dat)
	
	setCData(mData)<-rename(getCData(mData))
	setNegData(mData)<-rename(getNegData(mData))
	return(mData)
}
renameSampleWithMap.1<-function(mData,sample.mapping){
	elems<-assayDataElementNames(mData)
	rename<-function(dat){
		dat.n<-sapply(names(dat),function(x){
					str<-strsplit(x,"_")[[1]];
					ifelse(length(str)>1,paste(str[1:2],collapse="_"),str)
				})
		if(!is.null(sample.mapping)) {
			dat.n1<-gsub("^X","",dat.n)
			sid<-sample.mapping[dat.n1,]$sampleID
			dat.n<-ifelse(is.na(sid),dat.n1,sid)
		}
		names(dat)<-dat.n
		return(dat)
	}
	for(elem in elems){
		dat<-as.data.frame(assayDataElement(mData,elem))
		dat<-rename(dat)
		mData<-assayDataElementReplace(mData,elem,dat)
	}
	setCData(mData)<-rename(getCData(mData))
	setNegData(mData)<-rename(getNegData(mData))
	return(mData)
}

#saveProcessedTxtData.2a<-function(mData,outDir,fname="",sample.mapping=NULL,withStamp=F){
#	setwd(outDir)
#	timestamp<-""
#	if(withStamp==T) timestamp<-as.numeric(Sys.time())
#	fn_beta<-paste(fname,"BetaValue",timestamp,".csv",sep="")
#	fn_Pvalue<-paste(fname,"Pvalue",timestamp,".csv",sep="")
#	fn_Intensity<-paste(fname,"Signal_Inensities",timestamp,".csv",sep="")
#	fn_M<-paste(fname,"Methylation_Signal_Intensity",timestamp,".csv",sep="")
#	fn_U<-paste(fname,"UnMethylation_Signal_Intensity",timestamp,".csv",sep="")
#	fn_Mnum<-paste(fname,"Methylation_Signal_Intensity_NBeads",timestamp,".csv",sep="")
#	fn_Unum<-paste(fname,"UnMethylation_Signal_Intensity_NBeads",timestamp,".csv",sep="")
#	fn_Mstderr<-paste(fname,"Methylation_Signal_Intensity_STDERR",timestamp,".csv",sep="")
#	fn_Ustderr<-paste(fname,"UnMethylation_Signal_Intensity_STDERR",timestamp,".csv",sep="")
#	rename<-function(dat){
#		dat<-as.data.frame(dat)
#		dat.n<-sapply(names(dat),function(x)paste(strsplit(x,"_")[[1]][1:2],collapse="_"))
#		if(!is.null(sample.mapping)) {
#			dat.n1<-gsub("^X","",dat.n)
#			sid<-sample.mapping[dat.n1,]$sampleID
#			dat.n<-ifelse(is.na(sid),dat.n,sid)
#		}
#		names(dat)<-dat.n
#		return(dat)
#	}
#	bv<-rename(getBeta(mData))
#	write.csv(bv,file=fn_beta,row.names=T,quote=F)
#	pv<-rename(getPvalue(mData))
#	write.csv(pv,file=fn_Pvalue,row.names=T,quote=F)
#	M<-rename(getM(mData))
#	write.csv(M,file=fn_M,row.names=T,quote=F)
#	U<-rename(getU(mData))
#	write.csv(U,file=fn_U,row.names=T,quote=F)
#	Mn<-rename(mData@assayData$Mnumber)
#	write.csv(Mn,file=fn_Mnum,row.names=T,quote=F)
#	Un<-rename(mData@assayData$Unumber)
#	write.csv(Un,file=fn_Unum,row.names=T,quote=F)
#	Mse<-rename(mData@assayData$Mstderr)
#	write.csv(Mse,file=fn_Mstderr,row.names=T,quote=F)
#	Use<-rename(mData@assayData$Ustderr)
#	write.csv(Use,file=fn_Ustderr,row.names=T,quote=F)
#}
#saveProcessedTxtData.2<-function(mData,outDir,fname="",withStamp=F){
#	setwd(outDir)
#	timestamp<-""
#	if(withStamp==T) timestamp<-as.numeric(Sys.time())
#	fn_beta<-paste(fname,"BetaValue",timestamp,".csv",sep="")
#	fn_Pvalue<-paste(fname,"Pvalue",timestamp,".csv",sep="")
#	fn_Intensity<-paste(fname,"Singal_Inensities",timestamp,".csv",sep="")
#	fn_M<-paste(fname,"Methylation_Singal_Intensity",timestamp,".csv",sep="")
#	fn_U<-paste(fname,"UnMethylation_Singal_Intensity",timestamp,".csv",sep="")
#	#fn_pheno<-paste(fname,"_Pheno.csv",sep="")
#	write.table(getBeta(mData),file=fn_beta,sep=",",row.names=T,quote=F)
#	write.table(getPvalue(mData),file=fn_Pvalue,sep=",",row.names=T,quote=F)
#	write.table(getM(mData),file=fn_M,sep=",",row.names=T,quote=F)
#	write.table(getU(mData),file=fn_U,sep=",",row.names=T,quote=F)
#	#write.table(getPhenoData(mData),file=fn_pheno,sep=",",row.names=T,quote=F)
#}
##############################
runBatchCVS_test<-function(){
	datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\5324215005"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\5324215005_out2\\CSV"
	runBatchCVS(wdir=datPath,outdir=outPath)
}
runBatchCVS<-function(txtWin=NULL,toSave=T,wdir=NULL,outdir=NULL,toStamp=F){
	if(is.null(wdir)) wdir <- choose.dir() # tclvalue(tkchooseDirectory())
	if(!is.null(txtWin)) cat("> The data file folder selected is ",wdir,"\n > Start to process the CSV raw data files...\n")
	dat<-readRawMethCSV(wdir,txtWin);
	if(toSave==T){
		if(is.null(outdir)) outdir<-gFileDir
		setwd(outdir)
		timestamp<-"";
		if(toStamp==T) timestamp<-as.numeric(Sys.time())
		beta_fn<-paste("BetaValue",timestamp,".csv",sep="")
		pvalue_fn<-paste("DetectionPvalues",timestamp,".csv",sep="")
		signal_fn_M<-paste("SingalIntensity_M",timestamp,".csv",sep="")
		signal_fn_M_se<-paste("SignalIntensity_M_se",timestamp,".csv",sep="")
		signal_fn_U<-paste("SignalIntensity_U",timestamp,".csv",sep="")
		signal_fn_U_se<-paste("SignalIntensity_U_se",timestamp,".csv",sep="")
		avg_bead_num_A<-paste("AvgBeadsNum_U",timestamp,".csv",sep="")
		avg_bead_num_B<-paste("AvgBeadsNum_M",timestamp,".csv",sep="")
		ctr_fn_red<-paste("CtrIntensity_Red",timestamp,".csv",sep="")
		ctr_fn_grn<-paste("CtrIntensity_Grn",timestamp,".csv",sep="")
		M_Dev_fn<-paste("SignalIntensity_M_Dev",timestamp,".csv",sep="")
		U_Dev_fn<-paste("SignalIntensity_U_Dev",timestamp,".csv",sep="")
		write.table(getBeta(dat),file=beta_fn,sep=",",row.names=T,col.names=T,quote=F)
		write.table(getPvalue(dat),file=pvalue_fn,sep=",",row.names=T,col.names=T,quote=F)
		write.table(getM(dat),file=signal_fn_M,sep=",",row.names=T,col.names=T,quote=F)
		write.table(getU(dat),file=signal_fn_U,sep=",",row.names=T,col.names=T,quote=F)
		write.table(dat@assayData$M_Dev,file=M_Dev_fn,sep=",",row.names=T,col.names=T,quote=F)
		write.table(dat@assayData$U_Dev,file=U_Dev_fn,sep=",",row.names=T,col.names=T,quote=F)
		if(!is.null(txtWin)) cat(">Done! Please check out the output files ",beta_fn," ",pvalue_fn," and ",signal_fn," at ",outdir,"\n")
	}
}

readRawMethCSV<-function(dataDirectory,txt=NULL){
	#cat("start reading Raw Meth CSV")
	data(ilmn_code) #readIlmnCode()
	fidNames = c();
	setwd(dataDirectory);
	flist = list.files(pattern=".csv",
			recursive=T);
	Mn <- data.frame(id=1:27578);Mn<-Mn[,-1]
	Un <- data.frame(id=1:27578);Un<-Un[,-1]
	Pvalue <- data.frame(id=1:27578); Pvalue<-Pvalue[,-1]
	Mn_Dev<-data.frame(id=1:27578);Mn_Dev<-Mn_Dev[,-1]
	Un_Dev<-data.frame(id=1:27578);Un_Dev<-Un_Dev[,-1]
	ord.U = order(ilmn_code$IlmnID);
	ord = ilmn_code$IlmnID[ord.U]
	for(i in 1:length(flist)){
		flist_cur = unlist(strsplit(filetail(flist[i]),"\\."))[1];
		fidNames = c(fidNames,flist_cur);
		
		fdata=read.table(flist[i],header=TRUE,sep=",")
		meth_U = merge(fdata,ilmn_code,by.x=1,by.y="AddressA_ID",all.y=T)
		U = ifelse(meth_U$Color_Channel=="Red",meth_U$Mean.RED,meth_U$Mean.GRN) 
		U_Dev = ifelse(meth_U$Color_Channel=="Red",meth_U$Dev.RED,meth_U$Dev.GRN)
		U.sorted = U[order(meth_U$IlmnID)]
		Un <- data.frame(Un,U.sorted)
		Un_Dev<-data.frame(Un_Dev,U_Dev[order(meth_U$IlmnID)])
		
		meth_M = merge(fdata,ilmn_code,by.x=1,by.y="AddressB_ID",all.y=T)
		M = ifelse(meth_M$Color_Channel=="Red",meth_M$Mean.RED,meth_M$Mean.GRN)
		M_Dev=ifelse(meth_M$Color_Channel=="Red",meth_M$Dev.RED,meth_M$Dev.GRN)
		M.sorted = M[order(meth_M$IlmnID)]
		Mn <- data.frame(Mn,M.sorted)
		Mn_Dev<-data.frame(Mn_Dev,M_Dev[order(meth_M$IlmnID)])
		
		ctl_code <- data.frame(ctl_code=c(460494,540577,430114,1660097,1940364,610692,670750,1500059,1500398,1770019,1500167,50110,1990692,610706,360079,1190458));
		meth_ctl = merge(fdata,ctl_code,by.x=1,by.y=1)
		ctl_red_mean= mean(meth_ctl$Mean.RED);
		ctl_red_sd= sd(meth_ctl$Mean.RED);
		ctl_grn_mean= mean(meth_ctl$Mean.GRN);
		ctl_grn_sd= sd(meth_ctl$Mean.GRN);
		ctr_avg = ifelse(meth_M$Color_Channel=="Red",ctl_red_mean,ctl_grn_mean);
		ctr_sd = ifelse(meth_M$Color_Channel=="Red",ctl_red_sd,ctl_grn_sd);
		ctr_se = ifelse(meth_M$Color_Channel=="Red",ctl_red_sd/4,ctl_grn_sd/4)
		#AB = (M.sorted+U.sorted)/2;         #use max
		AB = ifelse(M.sorted>U.sorted,M.sorted,U.sorted)#max(M.sorted,U.sorted);
		# cal p 1-pnorm(z)
		z_score = (AB-ctr_avg)/ctr_se;
		pv = pnorm(as.matrix(z_score),lower.tail=FALSE)[,1];
		Pvalue <- data.frame(Pvalue,pv)
	}
	rownames(Mn)<-ilmn_code$IlmnID
	rownames(Un)<-ilmn_code$IlmnID
	colnames(Mn)<-fidNames
	colnames(Un)<-fidNames
	rownames(Mn_Dev)<-ilmn_code$IlmnID
	rownames(Un_Dev)<-ilmn_code$IlmnID
	colnames(Mn_Dev)<-fidNames
	colnames(Un_Dev)<-fidNames
	betaValue = Mn/(Mn+Un);
	rownames(Pvalue)<-rownames(betaValue)
	colnames(Pvalue)<-fidNames
	require(Biobase)
	mData<-new("methData",M=as.matrix(Mn),U=as.matrix(Un),Beta=as.matrix(betaValue),
			M_Dev=as.matrix(Mn_Dev),U_Dev=as.matrix(Un_Dev),Pvalue=as.matrix(Pvalue))
	featureData(mData)<-new("AnnotatedDataFrame",data=ilmn_code)
	return(mData)
}

#####################################
# util
#########################
filetail<-function(fileName){
	fn<-gsub("\\\\","/",fileName)
	fn<-unlist(strsplit(fn,"/"))
	return(fn[length(fn)])
}
filedir<-function(fileName){
	fn<-filetail(fileName)
	return(gsub(fn,"",fileName))
}
file.ext<-function(fileName){
	fn<-strsplit(filetail(fileName),"\\.")[[1]]
	return(tolower(fn[length(fn)]))
}
################
pdist<-function(){
	dat<-seq(1,100,by=0.1)
	pv<-pnorm(as.matrix(dat),lower.tail=F)[,1]
	X11()
	par(mfrow=c(1,2))
	plot(pv)
	plot(density(pv),col=3)
	dat2<-seq(37.51,37.52,by=0.00001)
	pv2<-pnorm(as.matrix(dat2),lower.tail=F)[,1]
	pv2.min<-min(pv2[pv2!=0])
	pv2.min
}


rapid.mc<-function(datPath=NULL,figPath=NULL,outFn=NULL){
	require(aroma.light)
	require(R.utils)
	if(is.null(datPath)){
		datPath<-"c:\\temp\\4207113144_test"
	}
	if(is.null(figPath)){
		figPath<-"c:\\temp\\results"
	}
	if(is.null(outFn)){
		outFn<-"Dat.out.rda"
	}
	dat.all<-load_beadlevel_scan_data(datPath)
	pre_calibration_plot(dat.all$datRG,figPath)
	dat.mc<-run_multiScan_calibration(dat.all$datRG,dat.all$datControls)
	dm<-post_calibration_plot(dat.mc$datRG,figPath)
	dat<-save_calibrated_data(dm,dat.mc$datRG,dat.mc$datControls,figPath,datFn=outFn)
	saveToCSVFiles(dat,dat.mc$datControls,datPath)
}

rapid_Test<-function(datPath=NULL){
	if(is.null(datPath))datPath<-"C:\\temp\\4207113144"
	outDir<-"c:\\temp"
	rapid(datPath,fromTXT=T,fromCSV=F,outDir=outDir)
}

rapid_Test.2<-function(datPath=NULL){
	if(is.null(datPath))datPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\5324215005\\"#"C:\\temp\\4828606022"
	outPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\5324215005_out\\CSV"
	md1<-runBatchCVS(wdir=datPath,outdir=outPath)
}



#####################
mergeTCGAPkg.2a<-function(pkgPath,pkgRepos){
	pkgPath.tcga<-file.path(pkgPath)
	pkgname<-filetail(pkgRepos)
	pkg.type<-strsplit(strsplit(pkgname,"_")[[1]][2],"\\.")[[1]][1]
	targetFolder<-file.path(file.path(pkgPath.tcga,pkg.type))
	cleanPkgRepos(pkgRepos)
	reValue<-c(pkgPath,tcga,targetFolder,"Yes")
	assign("reValue",reValue,env = .GlobalEnv)
	mergeDataPackages.2()
	assign("reValue",NULL,env = .GlobalEnv)
}


mergeTCGAPkg.2<-function(pkgPath,pkgRepos){
	pkgPath.tcga<-file.path(pkgPath)
	pkgname<-filetail(pkgRepos)
	pkg.type<-strsplit(strsplit(pkgname,"_")[[1]][2],"\\.")[[1]][1]
	targetFolder<-file.path(file.path(pkgPath.tcga,pkg.type))
	if(!file.exists(targetFolder)) dir.create(targetFolder)
	pkgname2<-paste(strsplit(pkgname,"\\.")[[1]][1:4],collapse=".")
	pkgPath2<-file.path(pkgRepos,pkgname2)
	updateSN.2(pkgPath2,targetFolder)
	merge_Packages.2(targetFolder,pkgPath2)
}
mergeTCGAPkg_test<-function(){
	pkgPath<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\temp\\jhu-usc.edu_STAD.HumanMethylation27.1"
	pkgRepos<-"c:\\tcga"
	mergeTCGAPkg(pkgPath,pkgRepos)
}
mergeTCGAPkg<-function(pkgPath,pkgRepos){
	pkgname<-filetail(pkgPath)
	pkg.type<-strsplit(strsplit(pkgname,"_")[[1]][2],"\\.")[[1]][1]
	targetFolder<-file.path(file.path(pkgPath,pkg.type))
	if(!file.exists(targetFolder)) dir.create(targetFolder)
	updateSN(pkgPath,targetFolder)
	setwd(pkgPath)
	pkgFns<-list.files(pattern=".gz")
	for(fn in pkgFns){
		system(paste("cp ",fn," ",file.path(targetFolder,fn)))
	}
}
############################
#
############################
updateSN.2<-function(pkgPath,pkgRepos){
	pkgFns<-list.files(path=pkgRepos,pattern=".gz$")
	if(length(pkgFns)<1)return()
	mageFn<-gsub(".tar.gz","",pkgFns[grep("mage-tab",pkgFns)])
	wdir<-file.path(pkgRepos,mageFn)
	if(!file.exists(wdir))uncompress(paste(mageFn,".tar.gz",sep=""),pkgRepos)
	setwd(wdir)
	sdrfFn<-list.files(pattern="sdrf")
	sdrf<-readLines(sdrfFn)
	incSN<-function(sn){
		paste((as.numeric(strsplit(sn,"\\.")[[1]])+c(0,1,0)),collapse=".")
	}
	pkgFns<-list.files(path=pkgPath,pattern=".gz$")
	pkgName<-filetail(pkgPath)
	pkg.cur<-strsplit(sdrf[grep(pkgName,sdrf)][1],"\t")[[1]]
	pkg.cur.lvl1<-pkg.cur[grep(".Level_1",pkg.cur)]
	pkg.cur.sn.lvl1<-strsplit(pkg.cur.lvl1,"Level_1.")[[1]][2]
	pkgName.new.lvl1<-paste(pkgName,".Level_1.",incSN(pkg.cur.sn.lvl1),sep="")
	pkg.cur.lvl2<-pkg.cur[grep(".Level_2",pkg.cur)]
	pkg.cur.sn.lvl2<-strsplit(pkg.cur.lvl2,"Level_2.")[[1]][2]
	pkgName.new.lvl2<-paste(pkgName,".Level_2.",incSN(pkg.cur.sn.lvl2),sep="")
	pkg.cur.lvl3<-pkg.cur[grep(".Level_3",pkg.cur)]
	pkg.cur.sn.lvl3<-strsplit(pkg.cur.lvl3,"Level_3.")[[1]][2]
	pkgName.new.lvl3<-paste(pkgName,".Level_3.",incSN(pkg.cur.sn.lvl3),sep="")
	
	
	createMD5SUM<-function(pkg){
		if(R.Version()$os=="mingw32"){
			md5sum<-system.file("Rtools",package="rapid.pro")
			cmd<-paste(file.path(md5sum,"md5sum")," ",pkg," > ",pkg,".md5",sep="")
			shell(cmd)
		}else{
			cmd<-paste("md5sum ",pkg," > ",pkg,".md5",sep="")
			system(cmd)
		}
	}
	setwd(pkgPath)
	pkgFn.lvl1<-pkgFns[grep("Level_1",pkgFns)]
	file.rename(pkgFn.lvl1,paste(pkgName.new.lvl1,".tar.gz",sep=""))
	createMD5SUM(paste(pkgName.new.lvl1,".tar.gz",sep=""))
	file.rename(paste(pkgFn.lvl1,".md5",sep=""),paste(pkgName.new.lvl1,".tar.gz.md5",sep=""))
	pkgFn.lvl2<-pkgFns[grep("Level_2",pkgFns)]
	file.rename(pkgFn.lvl2,paste(pkgName.new.lvl2,".tar.gz",sep=""))
	createMD5SUM(paste(pkgName.new.lvl2,".tar.gz",sep=""))
	file.rename(paste(pkgFn.lvl2,".md5",sep=""),paste(pkgName.new.lvl2,".tar.gz.md5",sep=""))
	pkgFn.lvl3<-pkgFns[grep("Level_3",pkgFns)]
	file.rename(pkgFn.lvl3,paste(pkgName.new.lvl3,".tar.gz",sep=""))
	createMD5SUM(paste(pkgName.new.lvl3,".tar.gz",sep=""))
	file.rename(paste(pkgFn.lvl3,".md5",sep=""),paste(pkgName.new.lvl3,".tar.gz.md5",sep=""))
	pkgNMs<-data.frame(pkg_old=c(pkgFn.lvl1,pkgFn.lvl2,pkgFn.lvl3),pkg_new=c(pkgName.new.lvl1,pkgName.new.lvl2,pkgName.new.lvl3))
	updateMagePkg(pkgNMs,pkgPath)
	return(pkgNMs)
}
updateMagePkg_test<-function(){
	pkgNMs<-data.frame(c("jhu-usc.edu_STAD.HumanMethylation27.1.Level_1.1.0.0.tar.gz"),c("jhu-usc.edu_STAD.HumanMethylation27.1.Level_1.1.1.0"))
	pkgPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga/repos/jhu-usc.edu_STAD.HumanMethylation27.1.0.0/jhu-usc.edu_STAD.HumanMethylation27.1"
	updateMagePkg(pkgNMs,pkgPath)
}
updateMagePkg<-function(pkgNMs,pkgPath){
	pkgFns<-list.files(pkgPath,".gz$")
	magePkg<-pkgFns[grep("mage",pkgFns)]
	mageTabDir<-gsub(".tar.gz","",magePkg)
	if(!file.exists(file.path(pkgPath,mageTabDir))) uncompress(magePkg,pkgPath)
	sdrfFn<-list.files(file.path(pkgPath,mageTabDir),".sdrf")
	sdrf<-readLines(file.path(pkgPath,mageTabDir,sdrfFn))
	for(i in 1:nrow(pkgNMs)) sdrf<-gsub(gsub(".tar.gz","",pkgNMs[i,1]),pkgNMs[i,2],sdrf)
	write(sdrf,file=file.path(pkgPath,mageTabDir,sdrfFn))
	compressDataPackage.2(mageTabDir,pkgPath)
}
updateSN_test<-function(){
	pkgPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga/repos/jhu-usc.edu_STAD.HumanMethylation27.1.0.0/jhu-usc.edu_STAD.HumanMethylation27.1"
	pkgRepos<-"/auto/uec-02/shared/production/methylation/meth27k/tcga/STAD_bk"
	updateSN(pkgPath,pkgRepos)
}
updateSN<-function(pkgPath,pkgRepos){
	pkgFns<-list.files(path=pkgRepos,pattern=".gz$")
	if(length(pkgFns)<1)return()
	mageFn<-gsub(".tar.gz","",pkgFns[grep("mage-tab",pkgFns)])
	wdir<-file.path(pkgRepos,mageFn)
	if(!file.exists(wdir))uncompress(paste(mageFn,".tar.gz",sep=""),pkgRepos)
	setwd(wdir)
	sdrfFn<-list.files(pattern="sdrf")
	sdrf<-readLines(sdrfFn)
	incSN<-function(sn){
		paste((as.numeric(strsplit(sn,"\\.")[[1]])+c(0,1,0)),collapse=".")
	}
	pkgFns<-list.files(path=pkgPath,pattern=".gz$")
	pkgName<-filetail(pkgPath)
	pkg.cur<-strsplit(sdrf[grep(pkgName,sdrf)][1],"\t")[[1]]
	pkg.cur.lvl1<-pkg.cur[grep(".Level_1",pkg.cur)]
	pkg.cur.sn.lvl1<-strsplit(pkg.cur.lvl1,"Level_1.")[[1]][2]
	pkgName.new.lvl1<-paste(pkgName,".Level_1.",incSN(pkg.cur.sn.lvl1),sep="")
	pkg.cur.lvl2<-pkg.cur[grep(".Level_2",pkg.cur)]
	pkg.cur.sn.lvl2<-strsplit(pkg.cur.lvl2,"Level_2.")[[1]][2]
	pkgName.new.lvl2<-paste(pkgName,".Level_2.",incSN(pkg.cur.sn.lvl2),sep="")
	pkg.cur.lvl3<-pkg.cur[grep(".Level_3",pkg.cur)]
	pkg.cur.sn.lvl3<-strsplit(pkg.cur.lvl3,"Level_3.")[[1]][2]
	pkgName.new.lvl3<-paste(pkgName,".Level_3.",incSN(pkg.cur.sn.lvl3),sep="")
	

	createMD5SUM<-function(pkg){
		if(R.Version()$os=="mingw32"){
			md5sum<-system.file("Rtools",package="rapid.pro")
			cmd<-paste(file.path(md5sum,"md5sum")," ",pkg," > ",pkg,".md5",sep="")
			shell(cmd)
		}else{
			cmd<-paste("md5sum ",pkg," > ",pkg,".md5",sep="")
			system(cmd)
		}
	}
	setwd(pkgPath)
	pkgFn.lvl1<-pkgFns[grep("Level_1",pkgFns)]
	file.rename(pkgFn.lvl1,paste(pkgName.new.lvl1,".tar.gz",sep=""))
	createMD5SUM(paste(pkgName.new.lvl1,".tar.gz",sep=""))
	file.rename(paste(pkgFn.lvl1,".md5",sep=""),paste(pkgName.new.lvl1,".tar.gz.md5",sep=""))
	pkgFn.lvl2<-pkgFns[grep("Level_2",pkgFns)]
	file.rename(pkgFn.lvl2,paste(pkgName.new.lvl2,".tar.gz",sep=""))
	createMD5SUM(paste(pkgName.new.lvl2,".tar.gz",sep=""))
	file.rename(paste(pkgFn.lvl2,".md5",sep=""),paste(pkgName.new.lvl2,".tar.gz.md5",sep=""))
	pkgFn.lvl3<-pkgFns[grep("Level_3",pkgFns)]
	file.rename(pkgFn.lvl3,paste(pkgName.new.lvl3,".tar.gz",sep=""))
	createMD5SUM(paste(pkgName.new.lvl3,".tar.gz",sep=""))
	file.rename(paste(pkgFn.lvl3,".md5",sep=""),paste(pkgName.new.lvl3,".tar.gz.md5",sep=""))
	merge_Packages(pkgFns,pkgRepos)
}

########################
# Update the MD5
#######################
cleanPkgRepos_test<-function(){
	pkgRepos<-"c:/temp/KIRP"
	bkRepos<-"c:/temp"
	cleanPkgRepos(pkgRepos,bkRepos)
}
cleanPkgRepos<-function(pkgRepos,bkRepos=NULL){
	pkgs<-list.files(pkgRepos,pattern=".gz")
	pkgs.pr<-sapply(pkgs,function(x)paste(strsplit(as.character(x),"\\.")[[1]][1:5],collapse="."))
	pkgs.s2<-sapply(pkgs,function(x)paste(strsplit(as.character(x),"\\.")[[1]][6]))
	pkgs.dup<-duplicated(pkgs.pr)
	if(sum(pkgs.dup)>=1){
		md5<-readLines(file.path(pkgRepos,"MD5"))
		for(i in 1:sum(pkgs.dup)){
			index<-which(pkgs.dup==T)
			ind<-which(pkgs.pr==pkgs.pr[index[i]])
			pkgs.pr1<-names(pkgs.pr[ind])
			pkgs.sm<-pkgs.pr1[!is.element(as.numeric(pkgs.s2[ind]),max(as.numeric(pkgs.s2[ind])))]
			for(pkg.sm in pkgs.sm){
				if(!is.null(bkRepos))system(paste("mv ",file.path(pkgRepos,pkg.sm)," ",file.path(bkRepos,pkg.sm)))
				ind2<-grep(pkg.sm,md5)
				if(length(ind2>0))md5<-md5[-ind2]
			}
		}
		write(md5,file.path(pkgRepos,"MD5"))
	}
}

addRawData<-function(datPath,outPath){
	rawFn<-list.files(datPath,pattern="^[0-9].*[0-9]$",recursive=T)
	rawFn
	cat(paste(length(rawFn),"\n"))
	index<-c()
	for(i in 1:length(rawFn)){
		if(file.info(rawFn[i])$isdir==T){
			index<-c(index,i)
		}
	}
	cat(paste(length(index),"\n"))
	for(ind in index){
		if(file.exists(file.path(outPath,rawFn[ind]))){
			cat(paste(rawFn[ind]," already exists, skip\n"))
		}else{
			file.copy(file.path(datPath,rawFn[ind]),file.path(outPath,rawFn[ind]))
		}
	}

}
mvRawData_run<-function(){
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw0/r2"
	arrays<-unique(checkRawData(srcDir))
	mvRawData(arrays,srcDir,targetDir)
	
}
mvRawData_run2<-function(){
	#qsub chRawData.sh
	#/other/MethPipeline.o9915709 
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	arrays.toFix<-c("4308918008", "4308918009", "4308918010", "4308918016", "4308918017", "4308918018", "4308918025", "4308918026", "4308918038", "4308918060", "4321207005", "4321207027", "4321207042")
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw0/r3"
	mvRawData(arrays.toFix,srcDir,targetDir)
}
mvRawData<-function(srcDir,targetDir,toMove=F){
	array.new<-c()
	datFolders<-list.files(srcDir)
	for(df in datFolders){
		arrays<-list.files(file.path(srcDir,df),pattern="^[0-9]")
		if(length(arrays)==0){
			cat("Array folder",df,"has no array in root\n")
		}else{
			for(ar in arrays){
				if(file.exists(file.path(targetDir,ar))){
					cat(paste("array",ar," exists\n"))
					next;
					array.new<-c(array.new,ar)
				}
				if(toMove==T)system(paste("mv '",file.path(srcDir,ar),"' '",file.path(targetDir,ar),"'",sep=""))
			}
		}
	}
	return(array.new)
}
mvRawData.1<-function(arrays,srcDir,targetDir){
	for(ar in arrays){
		if(file.exists(file.path(targetDir,ar))){
			cat(paste("array",ar," exists\n"))
			next;
		}
		system(paste("mv '",file.path(srcDir,ar),"' '",file.path(targetDir,ar),"'",sep=""))
	}
}
checkRawData_test<-function(){
	datPath<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	ar<-checkRawData(datPath)
	ar1<-sapply(ar,function(x)strsplit(x,"_")[[1]][1])
	unique(ar1)
	length(unique(ar1))
}
checkRawData.2<-function(datpath){
	array.def<-c()
	arrays<-list.files(datPath)
	for(ar in arrays){
		rawFns<-list.files(file.path(datPath,ar),pattern=".txt")
		for (fn in rawFns){
			if(fn!="Metrics.txt"){
				cat(paste("on ",fn,"\n"))
				dat1<-try(read.table(file.path(datPath,ar,fn),header=T,sep="\t"),T)
				if(class(dat1)=="try-error"){
					cat(dat1)
					array.def<-c(array.def,fn)
					next
				}
				dat<-names(dat1)
				ind<-is.element(c("Code","Grn","Red"),dat)
				if(sum(ind)!=3){
					array.def<-c(array.def,fn)
					cat(paste(fn,"\n"))
				}
			}
		}
	}
	return(array.def)
}
checkRawData<-function(datpath){
	array.def<-c()
	arrays<-list.files(datPath)
	for(ar in arrays){
		rawFns<-list.files(file.path(datPath,ar),pattern=".txt")
		for (fn in rawFns){
			if(fn!="Metrics.txt"){
				dat1<-readLines(file.path(datPath,ar,fn),n=1)
				dat<-strsplit(dat1,"\t")[[1]]
				ind<-is.element(c("Code","Grn","Red"),dat)
				if(sum(ind)!=3){
					array.def<-c(array.def,fn)
					cat(paste(fn,"\n"))
				}
			}
		}
	}
	return(array.def)
}
scpRawData.2_test<-function(){
	srcDir<-"Y:/ilmn_infinium/manual_data/Meth450_Manual_Check"
	targetDir<-"feipan@epimatrix.usc.edu:/home/feipan/pipeline/meth450/raw"
	scpRawData.2(srcDir,targetDir)
}
scpRawData.2<-function(srcDir,targetDir,dataType="idat"){
	pkgs<-list.files(srcDir)
	for(pkg in pkgs){
		p1<-file.path(srcDir,pkg)
		p2<-file.path(targetDir,pkg)
		fns<-list.files(p1,patt=dataType)
		for(fn in fns) system(paste("scp",file.path(p1,fn),file.path(p2,fn)))
	}
}
scpRawData_test<-function(){
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw1"
	scpRawData(srcDir,targetDir)
	srcDir2<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw2"
	scpRawData(srcDir2,targetDir)
	
	pkgs<-c("6042308164","6042308103","6042308152","6042308135","6042308166","6042308104","6042308129","6042308144")
	targetDir<-"/home/feipan/pipeline/meth450k/raw/"
	srcDir<-"feipan@hpc-uec.usc.edu:/auto/uec-02/shared/production/methylation/meth450k/raw"
	scpRawData(srcDir,targetDir=targetDir,pkgs=pkgs,fileType="idat")
}
scpRawData<-function(srcDir=NULL,targetDir,pkgs=NULL,fileType=NULL){
	if(!is.null(srcDir))pkgs<-list.files(srcDir)
	pkgs.new<-c()
	for(pkg in pkgs){
		if(!file.exists(file.path(targetDir,pkg))) pkgs.new<-c(pkgs.new,pkg)
	}
	cat(length(pkgs.new))
	cat("\n")
	for(pkg in pkgs.new){
		p1<-file.path(srcDir,pkg)
		p2<-file.path(targetDir,pkg)
		if(is.null(fileType)){
			system(paste("scp -r ",p1," ",p2,sep=""))
		}else{
			dir.create(p2)
			system(paste("scp ",p1,"/*.",fileType," ",p2,sep=""))
		}
	}
}
scpRawData.1<-function(srcDir,targetDir){
	pkgs<-list.files(srcDir)
	pkgs.new<-c()
	for(pkg in pkgs){
		if(!file.exists(file.path(targetDir,pkg))) pkgs.new<-c(pkgs.new,pkg)
	}
	cat(length(pkgs.new))
	cat("\n")
	for(pkg in pkgs.new){
		p1<-file.path(srcDir,pkg)
		p2<-file.path(targetDir,pkg)
		system(paste("scp -r ",p1," ",p2,sep=""))
	}
}
addRawData.2_test<-function(){
	datPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/infinium methylation plates 37-67/"
	outPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw1"
	addRawData.2(datPath,outPath)
	
	datPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/Infinium Methylation Raw Data 081201"
	outPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw2"
}
addRawData.2<-function(datPath,outPath){
	plates<-list.files(datPath,pattern="INFINIUM",ignore.case=T)#,recursive=T)
	plates
	cat(paste(length(plates),"\n"))
	index<-c()
	for(plate in plates){
		plateFD<-file.path(datPath,plate)
		if(file.info(plateFD)$isdir==T){
			rawFn<-list.files(plateFD,pattern="^[0-9]")
			if(length(rawFn)>0){
			for(i in 1:length(rawFn)){
					rawFn1<-file.path(plateFD,rawFn[i])
					if(file.info(rawFn1)$isdir==T){
						index<-c(index,rawFn1)
					}
				}
			}
		}
	}
	
	cat(paste(length(index),"\n"))
	#index<-gsub("\\ ","\\\\ ",index)
	for(ind in index){
		if(file.exists(file.path(outPath,filetail(ind)))){
			cat(paste(ind," already exists, skip\n"))
		}else{
			#file.copy(file.path(datPath,ind),file.path(outPath,ind))
			system(paste("cp -r '",ind,"' ",file.path(outPath,filetail(ind)),sep=""))
		}
	}
}
########################
#
########################
readDataFile.2<-function(fileName,checkName=F,rowName=1,isNum=T,header1=T,sep=NULL,skip=0,toDetail=F){
	fext<-unlist(strsplit(fileName,"\\."))
	fext<-fext[length(fext)]
	dat<-NULL
	if(fext=="csv"){
		if(is.null(sep)){
			sep = ","
		}
		dat<-read.delim(fileName,as.is=T,check.names=checkName,sep=sep,row.names=rowName,header=header1,skip=skip)
	}else if(fext=="xls" | fext=="xlsx"){
		require(gdata)
		dat<-read.xls(fileName,as.is=T,
				check.names=checkName,row.names=rowName,header=header1,skip=skip)
		
	}else if(fext=="txt"){
		if(is.null(sep)){
			sep = "\t"
		}
		dat<-read.delim(fileName,as.is=T,
				check.names=checkName,sep=sep,row.names=rowName,header=header1,skip=skip)
	}
	cName<-names(dat)
	if(nchar(dat[1,1])==0 | nchar(row.names(dat)[1])==0){
		dat<-dat[-1,]
	}
	if(isNum){ 
		options(warn=-1)
		dat<-t(apply(dat,1,as.numeric))
		options(warn=1)
	}
	dat<-as.data.frame(dat)
	names(dat)<-cName
	dim.info<-paste(nrow(dat),"x",ncol(dat),sep="")
	content.info<-sum(is.na(dat))
	#fileName1<-tclvalue(tclfile.tail(fileName))
	fileName1<-filetail(fileName)
	cat(paste("The dim of the file ",fileName1," is ",dim.info, "with NAs:  ",content.info,"\n"))
	if(toDetail==TRUE){
		content.detail<-colSums(is.na(dat))
		cat(paste("The Nas per col are: \t",names(dat),"\t",content.detail,"\n",sep=""))
	}
	return(dat)
}

##############
#
#############
findRawArrays_test<-function(){
	datPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/infinium methylation plates 37-67"
	raw1<-findRawArrays(datPath)

	datPath<-"/auto/uec-02/shared/production/methylation/meth27k/other/Infinium Methylation Raw Data 081201"
	raw2<-findRawArrays(datPath)
	length(raw2)
#	[1] 314
	length(unique(raw2))
#	[1] 180
	unique(raw2)
raw2<-raw2[order(raw2)]
raw2.dup<-raw2[duplicated(raw2)]
length(raw2.dup)
#134
raw2.dup2<-raw2[is.element(raw2,raw2.dup)]
}
findRawArrays<-function(datPath){
	ArrayFns<-list.files(datPath,pattern="^[0-9]*",recursive=T)
	Arrays1<-sapply(ArrayFns,function(x)filedir(x))
	Arrays2<-unique(Arrays1)
	Arrays<-sapply(Arrays2,function(x)filetail(x))
	length(Arrays)
	length(unique(Arrays))
	ind<-grep("^[0-9]",Arrays)
	rst<-Arrays[ind]
	ind1<-grep("\\.",rst)
	if(length(ind1)>0)rst<-rst[-ind1]
	ind2<-grep("\\ ",rst)
	if(length(ind2)>0)rst<-rst[-ind2]
	return(rst)
}
addRawArrays_run<-function(){
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/infinium methylation plates 37-67"
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw1"
	
	raw1Arrays<-findRawArrays(srcDir)
	for(i in 1:length(raw1Arrays)){
		ar<-raw1Arrays[i]
		ArraysPath<-names(ar)
		if(!file.exists(file.path(targetDir,ar))){
			system(paste("scp -r '",file.path(srcDir,ArraysPath),"' ",file.path(targetDir,ar),sep=""))
			cat(paste(ar,"\t",ArraysPath,"\n"))
		}
	}
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/Infinium Methylation Raw Data 081201"
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/raw2"
	
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/Infinium Methylation Raw Data 081201"
	
	targetDir<-"/auto/uec-02/shared/production/methylation/meth27k/raw"
	srcDir<-"/auto/uec-02/shared/production/methylation/meth27k/other/infinium methylation plates 37-67"
}
saveAsMethylumiData<-function(mData){
	require(methylumi)
	dat<-mData@assayData
	mldat<-new("methylumiSet",Avg_NBEADS=dat$Mn,BEAD_STDERR=dat$Me,betas=dat$BetaValue,pvals=dat$Pvalue,methylated=dat$M,unmethylated=dat$U)
}

#############
# "Thu Jan 06 14:11:23 2011"
#############
updateMeth27ADF<-function(){
	library(rapid.db)
	library(AnnotationDbi)
	outDir<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\feipan\\TCGA"
	data(HumanMethylation27.adf)
	data(meth27ENTREZID)
	data(meth27GENESYMBOL)
	if(!all(Lkeys(meth27ENTREZID)==Lkeys(meth27GENESYMBOL)))stop()
	dat<-data.frame(ilmnID=Lkeys(meth27ENTREZID),gid=Rkeys(meth27ENTREZID),gs=Rkeys(meth27GENESYMBOL),stringsAsFactors=F,row.names=1)
	#check before udpates
	table(HumanMethylation27.adf$SYMBOL==dat[HumanMethylation27.adf$IlmnID,2])
#	FALSE  TRUE 
#	324 27254
	table(HumanMethylation27.adf$Gene_ID==dat[HumanMethylation27.adf$IlmnID,1])
	table(is.na(HumanMethylation27.adf$Gene_ID))
#	FALSE  TRUE 
#	27569     9
	#updates
	HumanMethylation27.adf$SYMBOL<-dat[HumanMethylation27.adf$IlmnID,2]
	HumanMethylation27.adf$Gene_ID<-dat[HumanMethylation27.adf$IlmnID,1]
	#check after udpates
	table(is.na(HumanMethylation27.adf$Gene_ID))
#	FALSE 
#	27578 
	table(HumanMethylation27.adf$SYMBOL==dat[HumanMethylation27.adf$IlmnID,2])
#	TRUE 
#	27578
	attr(HumanMethylation27.adf,"date")<-date()
	save(HumanMethylation27.adf,file=file.path(outDir,"HumanMethylation27.adf.rdata"))
	write.csv(HumanMethylation27.adf,file=file.path(outDir,"HumanMethylation.adf.csv"))
}

#########################
#
#########################
updateLevel3Pkgs_test<-function(){
	tcgaPath<-"c:\\temp\\tcga"
	wdir<-"c:\\temp\\test1"
	updateLevel3Pkgs.2(tcgaPath,wdir)
}
updateLevel3Pkgs_test.2<-function(){
	tcgaPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga"
	wdir<-"/auto/uec-02/shared/tmp/meth"
	updateLevel3Pkgs(tcgaPath,wdir)
}
updateLevel3Pkgs<-function(tcgaPath,wdir=NULL){
	if(is.null(wdir))wdir<-tempdir()
	cancerDir<-list.files(tcgaPath)
	cancerDir<-cancerDir[-grep("repos",cancerDir)]
	for(i in 1:length(cancerDir)){
		curDir<-file.path(tcgaPath,cancerDir[i])
		pkgName<-list.files(curDir,".gz$")
		pkgName_1<-pkgName[grep("Level_1",pkgName)]
		pkgNameSN<-sapply(pkgName_1,function(x)strsplit(x,"\\.")[[1]][5])
		for(j in 1:length(pkgNameSN)){
			cDir<-file.path(wdir,paste("jhu-usc.edu_",cancerDir[i],".HumanMethylation27.",j,sep=""))
			if(!file.exists(cDir))dir.create(cDir)
			pkg1<-pkgName[grep(paste("Level_2",j,sep="."),pkgName)]
			pkg3<-pkgName[grep(paste("Level_3",j,sep="."),pkgName)]
			file.copy(file.path(tcgaPath,cancerDir[i],pkg1),file.path(cDir,pkg1))
			uncompress(pkg1,cDir)
			file.copy(file.path(tcgaPath,cancerDir[i],pkg3),file.path(cDir,pkg3))
			uncompress(pkg3,cDir)
			pkg3Dir<-gsub(".tar.gz","",pkg3)
			descriptionFn<-file.path(cDir,pkg3Dir,"DESCRIPTION.txt")
			pkg2<-file.path(cDir,gsub(".tar.gz","",pkg1))
			ver<-as.numeric(strsplit(pkg3,"\\.")[[1]][6])
			pkg3Dir<-paste("jhu-usc.edu_",cancerDir[i],".HumanMethylation27.Level_3.",j,".",(ver+1),".0",sep="")
			pkg3Dir<-file.path(cDir,pkg3Dir)
			reValue<-c(pkg2,pkg3Dir,"NO","",descriptionFn)
			assign("reValue",reValue,env=.GlobalEnv)
			updateLvl3Pkg(NULL,TRUE)
		}
	}
}
mergeUpdatedPkgs_test<-function(){
	pkgDir<-"C:\\temp\\jhu-usc.edu_BRCA.HumanMethylation27.2"
	tcgaPath<-"C:\\temp\\BRCA"
	mergeUpdatedPkgs(pkgDir,tcgaPath)
}
mergeUpdatedPkgs<-function(pkgDir,tcgaPath){
	reValue<-c(pkgDir,tcgaPath,"YES")
	assign("reValue",reValue,env=.GlobalEnv)
	mergeDataPackages.2(NULL,T)
	validatePkg(tcgaPath)
}
updateLevel3Pkgs.2_test<-function(){
	tcgaPath<-"/auto/uec-02/shared/production/methylation/meth27k/tcga"
	wdir<-"/auto/uec-02/shared/tmp/repos"
	updateLevel3Pkgs.2(tcgaPath,wdir)
}

updateLevel3Pkgs.2<-function(tcgaPath,wdir=NULL,verbose=F){
	if(is.null(wdir))wdir<-tempdir()
	cancerDir<-list.files(tcgaPath)
	cancerDir<-cancerDir[-grep("repos",cancerDir)]
	for(i in 1:length(cancerDir)){
		curDir<-file.path(tcgaPath,cancerDir[i])
		extractTCGAPkgs(curDir,wdir)
		pkgName<-list.files(curDir,".gz$")
		pkgName_1<-pkgName[grep("Level_1",pkgName)]
		pkgNameSN<-sapply(pkgName_1,function(x)strsplit(x,"\\.")[[1]][5])
		for(j in 1:length(pkgNameSN)){
			cDir<-file.path(wdir,paste("jhu-usc.edu_",cancerDir[i],".HumanMethylation27.",j,sep=""))
			if(verbose==T) cat(paste("work on ",cDir,"\n",sep=""))
			if(!file.exists(cDir)) dir.create(cDir)
			pkg1<-pkgName[grep(paste("Level_2",j,sep="."),pkgName)]
			pkg3<-pkgName[grep(paste("Level_3",j,sep="."),pkgName)]
			file.copy(file.path(tcgaPath,cancerDir[i],pkg1),file.path(cDir,pkg1))
			uncompress(pkg1,cDir)
			file.copy(file.path(tcgaPath,cancerDir[i],pkg3),file.path(cDir,pkg3))
			uncompress(pkg3,cDir)
			pkg3Dir<-gsub(".tar.gz","",pkg3)
			descriptionFn<-file.path(cDir,pkg3Dir,"DESCRIPTION.txt")
			if(!file.exists(descriptionFn)) descriptionFn<-""
			pkg2<-file.path(cDir,gsub(".tar.gz","",pkg1))
			pkg3Dir<-file.path(cDir,pkg3Dir)
			magePkg<-pkgName[grep("mage",pkgName)]
			if(length(magePkg)>1){cat(paste("Mage Pkg is not unique at ",cDir,"\n"));next}
			mageDir<-file.path(cDir,gsub(".tar.gz","",magePkg))
			if(!file.exists(mageDir))uncompress(magePkg,cDir)
			reValue<-c(pkg2,pkg3Dir,"YES",mageDir,descriptionFn)
			assign("reValue",reValue,env=.GlobalEnv)
			updateLvl3Pkg(NULL,TRUE)
			if(!file.exists(file.path(cDir,"bk")))dir.create(file.path(cDir,"bk"))
			file.copy(file.path(cDir,pkg3),file.path(cDir,"bk",pkg3))
			file.remove(file.path(cDir,pkg3))
			validatePkg(cDir,package="rapid.pro")
		}
	}
}

######################
#
#######################
extractTCGAPkgs_test<-function(){
	tcgaPath<-"C:\\temp\\tcga\\COAD"
	outPath<-"C:\\temp\\test"
	extractTCGAPkgs(tcgaPath,outPath)
}
extractTCGAPkgs<-function(tcgaPath,outPath){
	Pkgs<-list.files(tcgaPath,".gz")
	ind<-grep("mage",Pkgs)
	magePkgs<-Pkgs[ind]
	magePkg<-magePkgs[-grep(".md5",magePkgs)]
	Pkgs<-Pkgs[-ind]
	Sn<-sapply(Pkgs,function(x)strsplit(x,"\\.")[[1]][5])
	Sn.unique<-unique(Sn)
	for(sn in Sn.unique){
		Pkg.cur<-Pkgs[Sn==sn]
		curDir<-file.path(outPath,paste(strsplit(Pkg.cur[1],"\\.")[[1]][c(1:3,5)],collapse="."))
		if(!file.exists(curDir)) dir.create(curDir)
		for(pkg in Pkg.cur) file.copy(file.path(tcgaPath,pkg),file.path(curDir,pkg))
		file.copy(file.path(tcgaPath,magePkg),file.path(curDir,magePkg))
		uncompress(magePkg,curDir)
		sdrfFN<-list.files(curDir,pattern=".sdrf",recursive=T)
		sdrf<-readLines(file.path(curDir,sdrfFN))
		Pkg.cur<-Pkg.cur[-grep(".md5",Pkg.cur)]
		pkg_lvl1<-gsub(".tar.gz","",Pkg.cur[grep("Level_1",Pkg.cur)])
		sdrf<-sdrf[c(1,grep(pkg_lvl1,sdrf))]
		write(sdrf,file=file.path(curDir,sdrfFN))
		magePkg1<-gsub(".tar.gz","",magePkg)
		createManifestByLevel.2(curDir,magePkg1)
		compressDataPackage(curDir,magePkg1)
		validatePkg(curDir,package="rapid.pro")
	}
}

################
# 
#################
clearTCGARepos_test<-function(){
	tcgaPath<-"c:\\tcga\\BRCA"
	bkPath<-"c:\\temp"
	clearTCGARepos(tcgaPath,bkPath)
}
clearTCGARepos<-function(tcgaPath,bkPath,toValidate=F){
	pkgs.all<-list.files(tcgaPath)
	pkgs.new<-c()
	ind<-grep("[gz|MD5|validator]",pkgs.all)
	pkg<-pkgs.all[ind]
	pkg.dir<-pkgs.all[-ind]
	for(fd in pkg.dir){
		system(paste("mv -f ",file.path(tcgaPath,fd),file.path(bkPath,fd)))
	}
	pkg2<-pkgs.all[grep("gz$",pkgs.all)]
	sn<-sapply(pkg2,function(x)paste(strsplit(x,"\\.")[[1]][1:5],collapse="."))
	sn.2<-sapply(pkg2,function(x)strsplit(x,"\\.")[[1]][6])
	sn.dup<-duplicated(sn)
	if(sum(sn.dup)>0){
		sn.dup<-sn[sn.dup]
		for(sn1 in sn.dup){
			ind<-which(sn==sn1)
			sn.2<-sn.2[ind]
			ind.max<-max(sn.2)==sn.2
			sn.2a<-sn.2[!ind.max]
			p1<-file.path(tcgaPath,names(sn.2[ind.max]))
			pkgs.new<-c(pkgs.new,p1,paste(p1,".md5",sep=""))
			for(f in names(sn.2a)){
				system(paste("mv ",file.path(tcgaPath,f),file.path(bkPath,f)))
				system(paste("mv ",file.path(tcgaPath,paste(f,".md5",sep="")),file.path(bkPath,paste(f,".md5",sep=""))))
			}
		}
	}
	if(toValidate==T)validatePkg(tcgaPath,package="rapid.pro")
	return(pkgs.new)
}

##############
#
############
dir.remove<-function(cdir){
	system(paste("rm -r",cdir))
}
loadAutoConfig<-function(configFn){
	config<-read.table(file=configFn,sep=",",header=F,as.is=T)
	param<-config[,2]
	names(param)<-config[,1]
	return(param)
}
validatePkg_test<-function(){
	df.pkg<-"C:\\tcga\\repos\\jhu-usc.edu_GBM.HumanMethylation27.2"
	validatePkg(df.pkg,system.file("validator3",package="rapid.pro"))
}

#############
#
#############
createBatchPkgMap_test<-function(){
	outDir<-"C:\\tcga\\others\\arraymapping\\meth450"
	batch_1009<-c(5771955082,5771955042,5771955084,5771955030,5771955046,5771955069,5771955068,5771955072)
	batch_1010<-c(5775446071,5775446078,5775446072,5775446014,5775446017,5775446018,5775446018,5775446062,5775446070)
	batch_1011<-c(5775041065,5775041084,5775041088,5775041007,5775041086,5775041068,5775041070,5775041064)
	batch_1003<-c(5772325046,5772325047,5772325048,5772325052,5772325054,5772325055,5772325056,5772325058)
	batch_1004<-c(5775446032,5775446016,5775446038,5775446021,5775446015,5775446019,5775446036,5775446020)
	batch_1006<-c(5775446049,5775446051,5775446068,5775041002,5775041001,5775041003,5772325076,5772325077)
	createBatchPkgMap(batch_1009,"batch_1009",outDir)
	createBatchPkgMap(batch_1010,"batch_1010",outDir)
	createBatchPkgMap(batch_1011,"batch_1011",outDir)
	createBatchPkgMap(batch_1003,"batch_1003",outDir)
	createBatchPkgMap(batch_1004,"batch_1004",outDir)
	createBatchPkgMap(batch_1006,"batch_1006",outDir)
}
createBatchPkgMap<-function(batchArrays,bm,outDir=NULL,bmFn=NULL){
	if(is.null(outDir))outDir<-getwd()
	if(is.null(bmFn))bmFn<-file.path(outDir,paste(bm,".csv",sep=""))
	dat<-data.frame(chip_id=batchArrays,Batch_Number=rep(bm,length(batchArrays)))
	write.csv(dat,file=bmFn,row.names=F,quote=F)
}
createSnMap_test<-function(){
	pkgMapFn<-"C:\\tcga\\others\\arraymapping\\bk\\packagemap.txt"
	outPath<-"C:\\tcga\\others\\arraymapping\\meth27"
	createSnMap(pkgMapFn,outPath)
}
createSnMap<-function(pkgMapFn,outPath){
	sn<-read.delim(file=pkgMapFn,sep="\t",stringsAsFactors=F)
	batches<-split(sn,sn$Batch_Number)
	dat<-NULL;bn<-NULL
	for(batch in batches){
		bn<-unique(batch$Batch_Number)
		lvl1<-strsplit(batch$Package_lvl.1[1],"Level_1.")[[1]][2]
		lvl2<-strsplit(batch$Package_lvl.2[1],"Level_2.")[[1]][2]
		lvl3<-strsplit(batch$Package_lvl.3[1],"Level_3.")[[1]][2]
		abbreviation<-unique(batch$Cancer_Type)
		dat1<-data.frame(Batch_Number=bn,sn_lvl1=lvl1,sn_lvl2=lvl2,sn_lvl3=lvl3,abreviation=abreviation)
		if(is.null(bn))dat<-dat1
		else dat<-rbind(dat1,dat)
	}
	dat<-dat[order(dat$Batch_Number),]
	write.table(dat,file=file.path(outPath,"sn.txt"),sep="\t",row.names=F,quote=F)
}
##########
# output: jhu-usc.edu_cancer.HumanMethylation450.1.0.0.csv,...
##########
createTCGAPkgMap_test<-function(){
	arrayPath<-"c:\\tcga\\others\\arraymapping\\meth27"
	#createTCGAPkgMap(arrayPath,platform="meth27k")
	pkgMapFn<-"C:\\tcga\\others\\arraymapping\\bk\\packagemap.txt"
	createTCGAPkgMap(arrayPath,packageMapFn=pkgMapFn,outPath=NULL,platform="meth27k")
	
	arrayPath<-"c:\\tcga\\others\\arraymapping\\meth450"
	createTCGAPkgMap(arrayPath,platform="meth450k",outPath="c:\\temp")
}
createTCGAPkgMap<-function(arrayPath,snFn=NULL,packageMapFn=NULL,outPath=NULL,min.sample=5,platform="meth450k"){
	platform.name<-"HumanMethylation450"
	if(platform=="meth27k") platform.name<-"HumanMethylation27"
	samp<-readSampleMapping(arrayPath)
	sample.tcga<-!is.na(samp$Batch_Number)& samp$abbreviation!=""& grepl("TCGA",toupper(samp$sampleID))
	samp<-samp[sample.tcga,]
	if(!is.null(packageMapFn)){
		samp<-samp[,c("plate_id","flow_cell","sampleID","cancer")]
		packages<-read.delim(file=packageMapFn,sep="\t",stringsAsFactors=F)[,c("Batch_Number","Sample_ID","Cancer_Type")]
		samp<-merge(samp,packages,by.x="sampleID",by.y="Sample_ID")[,c("sampleID","plate_id","flow_cell","Cancer_Type","Batch_Number")]
		names(samp)<-c("Sample_ID","chip_id","well_position","cancer","Batch_Number")
	}
	if(is.null(outPath)) outPath<-arrayPath
	if(!is.null(snFn)){
		sn<-read.table(file=snFn,sep="\t",header=T,stringsAsFactors=F)
		samp<-merge(samp,sn,by.x="Batch_Number",by.y="Batch_Number")
	}
	samp.batches<-split(samp,samp$Batch_Number)
	batches<-names(samp.batches)
	for(batch in batches){
		samp1<-samp.batches[[batch]]
		if(nrow(samp1)<min.sample)next
		if(length(unique(samp1$abbreviation))>1)cat("The batch",batch,"contains multiple abbreviation\n")
		samps<-split(samp1,samp1$abbreviation)
		for(samp1 in samps){
			pkg.name<-paste("jhu-usc.edu_",samp1$abbreviation[1],".",platform.name,".",batch,".csv",sep="")
			if(!is.null(snFn)){
				sn1<-sn[sn$Batch_Number==batch,]
				samp1<-merge(samp1,sn1,by.x="Batch_Number",by.y="Batch_Number")
				pkg.name<-paste("jhu-usc.edu_",sn1$abbreviation,".",platform.name,".",sn1$sn_lvl1,".csv",sep="")
			}
			write.table(samp1,file=file.path(outPath,pkg.name),sep=",",row.names=F,quote=F)
		}
	}
}

createTCGAPkgMap.1<-function(arrayPath,snFn=NULL,packageMapFn=NULL,outPath=NULL,min.sample=5,platform="meth450k"){
	platform.name<-"HumanMethylation450"
	if(platform=="meth27k") platform.name<-"HumanMethylation27"
	samp<-readSampleMapping(arrayPath)
	sample.tcga<-!is.na(samp$Batch_Number)& samp$abbreviation!=""& grepl("TCGA",toupper(samp$sampleID))
	samp<-samp[sample.tcga,]
	if(!is.null(packageMapFn)){
		samp<-samp[,c("plate_id","flow_cell","sampleID","cancer")]
		packages<-read.delim(file=packageMapFn,sep="\t",stringsAsFactors=F)[,c("Batch_Number","Sample_ID","Cancer_Type")]
		samp<-merge(samp,packages,by.x="sampleID",by.y="Sample_ID")[,c("sampleID","plate_id","flow_cell","Cancer_Type","Batch_Number")]
		names(samp)<-c("Sample_ID","chip_id","well_position","cancer","Batch_Number")
	}
	if(is.null(outPath)) outPath<-arrayPath
	if(is.null(snFn))snFn<-file.path(arrayPath,"sn.txt")
	sn<-read.table(file=snFn,sep="\t",header=T,stringsAsFactors=F)
	samp<-merge(samp,sn,by.x="Batch_Number",by.y="Batch_Number")
	samp.batches<-split(samp,samp$Batch_Number)
	batches<-names(samp.batches)
	for(batch in batches){
		samp1<-samp.batches[[batch]]
		if(nrow(samp1)<min.sample)next
		sn1<-sn[sn$Batch_Number==batch,]
		samp1<-merge(samp1,sn1,by.x="Batch_Number",by.y="Batch_Number")
		pkg.name<-paste("jhu-usc.edu_",sn1$abbreviation,".",platform.name,".",sn1$sn_lvl1,".csv",sep="")
		write.table(samp1,file=file.path(outPath,pkg.name),sep=",",row.names=F,quote=F)
	}
}



createTCGAPlateMap_test<-function(){
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth450"
	platemap<-createPlateMap(arrayPath)
	table(platemap$Batch_Number,platemap$abbreviation)
}
createTCGAPlateMap<-function(arrayPath,filter.batch=T,show.missing.batch=F){
	samp<-readSampleMapping(arrayPath)
	ind<-grepl("TCGA",samp$sampleID)
	platemap<-samp[ind,c(1,4,6,5,2,3)]
	names(platemap)<-c("chip_id","Batch_Number","abbreviation","cancer","well_position","sample")
	platemap$Batch_Number<-as.numeric(platemap$Batch_Number)
	ind<-is.na(platemap$Batch_Number)|platemap$Batch_Number==""
	if(sum(ind)>0){
		sids<-paste(platemap$sample[ind],collapse=",")
		if(show.missing.batch==T)cat("The TCGA Batch Numbers of the following samples are missing:",sids,"\n")
	}
	if(filter.batch==T)platemap<-platemap[!ind,]
	ind<-is.na(platemap$abbreviation)|platemap$abbreviation==""
	if(sum(ind)>0){
		sids<-paste(platemap$sample[ind],collapse=",")
		cat("The Disease abbreviations of the following TCGA samples are missing:",sids,"\n")
	}
	platemap<-platemap[!ind,]
	plate.abbreviation.N<-tapply(platemap$abbreviation,platemap$Batch_Number,function(x)length(unique(x)))
	abbrev.dup<-names(plate.abbreviation.N[plate.abbreviation.N>1])
	cat("The following TCGA batches contain multiple abbreviations: ",paste(abbrev.dup,collapse=","),"\n")
	platemap<-platemap[!is.element(platemap$Batch_Number,abbrev.dup),]
	write.table(platemap,file=file.path(arrayPath,"platemap.txt"),sep="\t",row.names=F,quote=F)
	return(platemap)
}
createTCGAPlateMap.1<-function(arrayPath,filter.batch=T,show.missing.batch=F){
	samp<-readSampleMapping(arrayPath)
	ind<-grepl("TCGA",samp$sampleID)
	platemap<-samp[ind,c(1,4,6,5,2,3)]
	names(platemap)<-c("chip_id","Batch_Number","abbreviation","cancer","well_position","sample")
	platemap$Batch_Number<-as.numeric(platemap$Batch_Number)
	ind<-is.na(platemap$Batch_Number)|platemap$Batch_Number==""
	if(sum(ind)>0){
		sids<-paste(platemap$sample[ind],collapse=",")
		if(show.missing.batch==T)cat("The TCGA Batch Numbers of the following samples are missing:",sids,"\n")
	}
	if(filter.batch==T)platemap<-platemap[!ind,]
	ind<-is.na(platemap$abbreviation)|platemap$abbreviation==""
	if(sum(ind)>0){
		sids<-paste(platemap$sample[ind],collapse=",")
		cat("The Disease abbreviations of the following TCGA samples are missing:",sids,"\n")
	}
	write.table(platemap,file=file.path(arrayPath,"platemap.txt"),sep="\t",row.names=F,quote=F)
	return(platemap)
}

createPlateMap<-function(arrayPath){
	amFn<-file.path(arrayPath,"sample_mapping.txt")
	samp<-read.delim(file=amFn,sep="\t",header=F)
	platmap<-samp[!is.na(samp[,4]),c(1,4,6,5,2,3)]
	names(platmap)<-c("chip_id","Batch_Number","abbreviation","cancer","bn","sample")
	write.table(platmap,file=file.path(arrayPath,"platemap.txt"),sep="\t",row.names=F,quote=F)
}
####################
# output: packagemap.txt
####################
createPackageMap_test<-function(){
	plateMapFn<-"c:\\tcga\\others\\arraymapping\\platemap.txt"
	createPackageMap(plateMapFn)
}
createPackageMap<-function(plateMapFn,sn=NULL,platform="meth450k"){
	platform.name<-"HumanMethylation450"
	if(platform=="meth27k") platform.name<-"HumanMethylation27"
	platemap<-read.delim(file=plateMapFn,sep="\t",header=T,stringsAsFactors=F)
	platemap<-platemap[order(platemap$abbreviation,decreasing=T),]
	sample.total<-tapply(platemap$sample,platemap$Batch_Number,length)
	sample.tcga<-tapply(platemap$sample,platemap$Batch_Number,function(x)length(grep("TCGA",x)))
	packmap<-platemap[!duplicated(platemap$Batch_Number),c("Batch_Number","abbreviation")]
	packmap$sample_total<-sample.total[as.character(packmap$Batch_Number)]
	packmap$sample_tcga<-sample.tcga[as.character(packmap$Batch_Number)]
	arrayPath<-filedir(plateMapFn)
	if(is.null(sn))sn<-file.path(arrayPath,"sn.txt")
	if(!file.exists(sn))return()
	else sn<-read.delim(file=sn,sep="\t",header=T,stringsAsFactors=F)
	packmap<-merge(packmap,sn[,1:4],by.x="Batch_Number",by.y="Batch_Number")
	packmap$Package_lvl.1<-paste("jhu-usc.edu_",packmap$abbreviation,".",platform.name,".Level_1.",packmap$lvl1,sep="")
	packmap$Package_lvl.2<-paste("jhu-usc.edu_",packmap$abbreviation,".",platform.name,".Level_2.",packmap$lvl2,sep="")
	packmap$Package_lvl.3<-paste("jhu-usc.edu_",packmap$abbreviation,".",platform.name,".Level_3.",packmap$lvl3,sep="")
	packmap<-packmap[,c("Package_lvl.1","Package_lvl.2","Package_lvl.3","Batch_Number","abbreviation","sample_total","sample_tcga")]
	plate_sample.tcga<-platemap[grep("TCGA",platemap$sample),c("Batch_Number","sample")]
	names(plate_sample.tcga)<-c("Batch_Number","Sample_ID")
	packmap<-merge(packmap,plate_sample.tcga,by.x="Batch_Number",by.y=1)
	write.table(packmap,file=file.path(arrayPath,"packagemap.txt"),sep="\t",row.names=F,quote=F)
}

createPackageMap.1<-function(plateMapFn,sn=NULL,platform="meth450k"){
	platform.name<-"HumanMethylation450"
	if(platform=="meth27k") platform.name<-"HumanMethylation27"
	platemap<-read.delim(file=plateMapFn,sep="\t",header=T,stringsAsFactors=F)
	platemap<-platemap[order(platemap$abbreviation,decreasing=T),]
	sample.total<-tapply(platemap$sample,platemap$Batch_Number,length)
	sample.tcga<-tapply(platemap$sample,platemap$Batch_Number,function(x)length(grep("TCGA",x)))
	packmap<-platemap[!duplicated(platemap$Batch_Number),c("Batch_Number","abbreviation")]
	packmap$sample_total<-sample.total[as.character(packmap$Batch_Number)]
	packmap$sample_tcga<-sample.tcga[as.character(packmap$Batch_Number)]
	arrayPath<-filedir(plateMapFn)
	if(is.null(sn))sn<-file.path(arrayPath,"sn.txt")
	if(!file.exists(sn))return()
	else sn<-read.delim(file=sn,sep="\t",header=T,stringsAsFactors=F)
	packmap<-merge(packmap,sn[,1:4],by.x="Batch_Number",by.y="Batch_Number")
	packmap$Package_lvl.1<-paste("jhu-usc.edu_",packmap$abbreviation,".",platform.name,".Level_1.",packmap$lvl1,sep="")
	packmap$Package_lvl.2<-paste("jhu-usc.edu_",packmap$abbreviation,".",platform.name,".Level_2.",packmap$lvl2,sep="")
	packmap$Package_lvl.3<-paste("jhu-usc.edu_",packmap$abbreviation,".",platform.name,".Level_3.",packmap$lvl3,sep="")
	packmap<-packmap[,c("Package_lvl.1","Package_lvl.2","Package_lvl.3","Batch_Number","abbreviation","sample_total","sample_tcga")]
	write.table(packmap,file=file.path(arrayPath,"packagemap.txt"),sep="\t",row.names=F,quote=F)
}
mergePackageMap_test<-function(){
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth450"
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_LAML.HumanMethylation450.1.0.0.csv")
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_COAD.HumanMethylation450.1.0.0.csv")
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_READ.HumanMethylation450.1.0.0.csv")
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_HNSC.HumanMethylation450.1.0.0.csv")
	mergePackageMap(pkgMapFn,arrayPath)
	
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth27"
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_BRCA.HumanMethylation27.2.0.0.csv")
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_STAD.HumanMethylation27.1.0.0.csv")
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_STAD.HumanMethylation27.2.0.0.csv")
	pkgMapFn<-file.path(arrayPath,"jhu-usc.edu_UCEC.HumanMethylation27.2.0.0.csv")
	mergePackageMap(pkgMapFn,arrayPath,platform="meth27k")
}
mergePackageMap<-function(pkgMapFn,arrayPath=NULL,sep=",",platform="meth450k"){
	if(is.null(arrayPath))arrayPath<-paste("/auto/uec-02/shared/production/methylation/",platform,"/arraymapping",sep="")
	pkgmapFn<-file.path(arrayPath,"packagemap.txt")
	if(file.ext(pkgMapFn)=="txt")sep<-"\t"
	pack<-read.delim(file=pkgMapFn,sep=sep,stringsAsFactors=F)
	pn<-"HumanMethylation450";if(platform=="meth27k")pn<-"HumanMethylation27"
	pack$sn_lvl1<-paste("jhu-usc.edu_",pack$abbreviation,".",pn,".Level_1.",pack$sn_lvl1,sep="")
	pack$sn_lvl2<-paste("jhu-usc.edu_",pack$abbreviation,".",pn,".Level_2.",pack$sn_lvl2,sep="")
	pack$sn_lvl3<-paste("jhu-usc.edu_",pack$abbreviation,".",pn,".Level_3.",pack$sn_lvl3,sep="")
	pack<-pack[,c("Batch_Number","sn_lvl1","sn_lvl2","sn_lvl3","abbreviation","Sample_ID")];
	names(pack)<-c("Batch_Number","Package_lvl.1","Package_lvl.2","Package_lvl.3","abbreviation","Sample_ID")
	batch<-unique(pack$Batch_Number)
	if(length(batch)>1){cat("There are multiple batches in the package map file",pkgMapFn,"\n")}
	if(file.exists(pkgmapFn)){
		map<-read.delim(file=pkgmapFn,sep="\t",stringsAsFactors=F)
		map<-map[!is.element(map$Batch_Number,batch),]
		pack<-rbind(map,pack)
	}
	write.table(pack,file=pkgmapFn,sep="\t",row.names=F,quote=F)
}

mergePackageMap.1<-function(pkgMapFn,arrayPath=NULL,sep=",",platform="meth450k"){
	if(is.null(arrayPath))arrayPath<-paste("/auto/uec-02/shared/production/methylation/",platform,"/arraymapping",sep="")
	pkgmapFn<-file.path(arrayPath,"packagemap.txt")
	if(!file.exists(pkgmapFn)){cat("Package Mapping File, packagemap.txt, does not exist\n");return()}
	map<-read.delim(file=pkgmapFn,sep="\t",stringsAsFactors=F)
	if(file.ext(pkgMapFn)=="txt")sep<-"\t"
	pack<-read.delim(file=pkgMapFn,sep=sep,stringsAsFactors=F)
	pn<-"HumanMethylation450";if(platform=="meth27k")pn<-"HumanMethylation27"
	pack$sn_lvl1<-paste("jhu-usc.edu_",pack$abbreviation,".",pn,".Level_1.",pack$sn_lvl1,sep="")
	pack$sn_lvl2<-paste("jhu-usc.edu_",pack$abbreviation,".",pn,".Level_2.",pack$sn_lvl2,sep="")
	pack$sn_lvl3<-paste("jhu-usc.edu_",pack$abbreviation,".",pn,".Level_3.",pack$sn_lvl3,sep="")
	pack<-pack[,c("Batch_Number","sn_lvl1","sn_lvl2","sn_lvl3","abbreviation","Sample_ID")];
	names(pack)<-c("Batch_Number","Package_lvl.1","Package_lvl.2","Package_lvl.3","abbreviation","Sample_ID")
	batch<-unique(pack$Batch_Number)
	if(length(batch)>1){cat("There are multiple batches in the package map file",pkgMapFn,"\n")}
	map<-map[!is.element(map$Batch_Number,batch),]
	map.merged<-rbind(map,pack)
	write.table(map.merged,file=pkgmapFn,sep="\t",row.names=F,quote=F)
}
checkTCGASample_test<-function(){
	sampleFn<-"C:\\Documents and Settings\\feipan\\Desktop\\people\\dan\\samplePlateInfo.txt"
	arrayPath<-"C:\\tcga\\others\\arraymapping\\meth450"
	rst<-checkTCGASample(arrayPath)
	rst<-checkTCGASample(arrayPath,sampleFn)
}
checkTCGASample<-function(arrayPath,sampleFn=NULL){
	rst<-NULL
	smap<-readSampleMapping(arrayPath)
	if(!is.null(sampleFn)){
		samp<-read.delim(file=sampleFn,sep="\t",stringsAsFactors=F)
		names(samp)<-c("plate","barcode","well_position","sampleID","batchNumber","abbrev")
		table(samp$batchNumber,samp$abbrev)
		samp.m<-merge(samp,smap,by.x="sampleID",by.y="sampleID")
		rst<-table(samp.m$Batch_Number,samp.m$abbreviation)
		samp.m[samp.m$abbrev=="AML",]
		unique(samp.m[samp.m$abbrev=="HNSC","plate_id"])
		samp.m[samp.m$abbreviation=="control cell line"&samp.m$Batch_Number==25,]
	}else{
		rst<-table(smap$Batch_Number,smap$abbreviation)
	}
	return(rst)
}
checkTCGASample.1<-function(sampleFn,arrayPath){
	smap<-readSampleMapping(arrayPath)
	samp<-read.delim(file=sampleFn,sep="\t",stringsAsFactors=F)
	names(samp)<-c("plate","barcode","well_position","sampleID","batchNumber","abbrev")
	table(samp$batchNumber,samp$abbrev)
	samp.m<-merge(samp,smap,by.x="sampleID",by.y="sampleID")
	table(samp.m$Batch_Number,samp.m$abbreviation)
#			COAD control cell line HNSC KIRC LAML LUAD READ
#	25   0    0                 2    0    0  194    0    0
#	41   0    1                 0    0    0    0    0    0
#	52   0    0                 0    0    0    0    3    0
#	58   0    0                 0    0    0    0    4    0
#	63   0    0                 0    0    2    0    0    0
#	67   0    0                 0    0    0    0    0   12
#	76   0   52                 0    0    0    0    0    0
#	83   1    0                 0   27    0    0    0    0
	samp.m[samp.m$abbrev=="AML",]
	unique(samp.m[samp.m$abbrev=="HNSC","plate_id"])
	samp.m[samp.m$abbreviation=="control cell line"&samp.m$Batch_Number==25,]
}

##################
#
##################
getArrayMappings_test<-function(){
	map<-getArrayMappings("c:\\temp","mapping.txt")
	
	#check
	map<-read.delim(file="c:\\temp\\mapping.txt",sep="\t",stringsAsFactors=F,as.is=T)
	map$barcode<-paste(map[,2],map[,3],sep="_")
	map2<-read.delim(file="C:\\Documents and Settings\\feipan\\Desktop\\people\\zack\\sample_mapping.txt",sep="\t",stringsAsFactors=F,as.is=T)
	map2$barcode<-paste(map2[,2],map2[,4],sep="_")
	map1<-map[is.element(map$barcode,map2$barcode),]
	map1<-map1[order(map1$barcode),]
	map2<-map2[order(map2$barcode),]
	table(map1$name==map2$name)
	table(map1$plateserial.plateserial==map2$plateserial)
	table(map1$plateposition==map2$plateposition)
	table(map1$diseaseabr==map2$diseaseabr)
}
getArrayMappings<-function(arrayPath=NULL,outFn="mapping.txt",map.url=NULL,userName="zack",passwd="genzack"){
	require(RCurl)
	require(XML)
	if(is.null(map.url)) map.url<-"http://epilims.usc.edu:8080/api/v1/processes?type=Hyb%20Multi%20BC2"
	map.top<-getURL(map.url,userpwd=paste(userName,":",passwd,sep=""))
	map.process<-xmlTreeParse(map.top)$doc[[1]]
	plate.map<-NULL
	for(i in 1:length(map.process)){
		fields<-xmlAttrs(map.process[[i]])
		process.url<-paste(fields["uri"],"?limsid=",fields["limsid"],sep="")
		map<-getPlateMap(process.url,show.msg=T)
		if(is.null(plate.map))plate.map<-map
		else plate.map<-rbind(plate.map,map)
	}
	if(!is.null(arrayPath))write.table(plate.map,file=file.path(arrayPath,outFn),sep="\t",row.names=F,quote=F)
	return(plate.map)
}
getArrayMappings.1.1<-function(arrayPath=NULL,outFn="mapping.txt",map.url=NULL,userName="zack",passwd="genzack"){
	require(RCurl)
	require(XML)
	if(is.null(map.url)) map.url<-"http://epilims.usc.edu:8080/api/v1/processes?type=Hyb%20Multi%20BC2"
	map.top<-getURL(map.url,userpwd=paste(userName,":",passwd,sep=""))
	map.process<-xmlTreeParse(map.top)$doc[[1]]
	process.url<-c()
	for(i in 1:length(map.process)){
		fields<-xmlAttrs(map.process[[i]])
		process.url<-c(process.url,paste(fields["uri"],"?limsid=",fields["limsid"],sep=""))
	}
	plate.map<-sapply(process.url,function(x)getPlateMap(x,show.msg=T))
	if(!is.null(arrayPath))write.table(plate.map,file=file.path(arrayPath,outFn),sep="\t",row.names=F,quote=F)
	return(plate.map)
}

getArrayMappings.1<-function(arrayPath=NULL,outFn="mapping.txt",map.url=NULL,userName="zack",passwd="genzack"){
	require(RCurl)
	require(XML)
	if(is.null(map.url)) map.url<-"http://epilims.usc.edu:8080/api/v1/processes?type=Hyb%20Multi%20BC2"
	map.top<-getURL(map.url,userpwd=paste(userName,":",passwd,sep=""))
	map.process<-xmlTreeParse(map.top)$doc[[1]]
	process<-sapply(map.process,function(x){
				fields<-xmlAttrs(x)
				dat<-paste(fields["uri"],"?limsid=",fields["limsid"],sep="")
				return(dat)
			})
	plate.map<-sapply(process,function(x)getPlateMap(x))
	if(!is.null(arrayPath))write.table(plate.map,file=file.path(arrayPath,outFn),sep="\t",row.names=F,quote=F)
}
##############
#http://epilims.usc.edu:8080/api/v1/processes/BC2-AHX-110511-122-844?limsid=BC2-AHX-110511-122-844
#   http://epilims.usc.edu:8080/api/v1/artifacts/WEI556A7279MS3?limsid=WEI556A7279MS3
#	    http://epilims.usc.edu:8080/api/v1/containers/27-7594" limsid="27-7594"
#	    http://epilims.usc.edu:8080/api/v1/samples/WEI556A7279?limsid=WEI556A7279
#   http://epilims.usc.edu:8080/api/v1/artifacts/WEI556A7279TP4?limsid=WEI556A7279TP4
#	    http://epilims.usc.edu:8080/api/v1/containers/27-7609?limsid=27-7609
###############
getPlateMap_test<-function(){
	process.url<-"http://epilims.usc.edu:8080/api/v1/processes/BC2-AHX-110420-122-835?limsid=BC2-AHX-110420-122-835"
	process.url<-"http://epilims.usc.edu:8080/api/v1/processes/TRP-AHX-110408-122-823?limsid=TRP-AHX-110408-122-823"
	process.url<-"http://epilims.usc.edu:8080/api/v1/processes/TRP-MBX-110408-122-816?limsid=TRP-MBX-110408-122-816"
	process.url<-"http://epilims.usc.edu:8080/api/v1/processes/TRP-DTM-110405-122-809?limsid=TRP-DTM-110405-122-809"
	process.url<-"http://epilims.usc.edu:8080/api/v1/processes/TRP-AHX-110408-122-811?limsid=TRP-AHX-110408-122-811"
	process.url<-"http://epilims.usc.edu:8080/api/v1/processes/BC2-AHX-110511-122-844?limsid=BC2-AHX-110511-122-844"
	map<-getPlateMap(process.url,show.msg=T)
}
getPlateMap<-function(process.url,userpwd="zack:genzack",show.msg=F){
	if(show.msg==T)cat("on processing ",process.url,"\n")
	map.top<-getURL(process.url,userpwd=userpwd)
	map<-xmlTreeParse(map.top)$doc[[1]]
	map.date_run<-xmlValue(map[[2]])
	map.inoutput<-map[grep("input-output-map",names(map))]
	xmlValue2<-function(xmlNode){
		value<-ifelse(!is.null(xmlNode),xmlValue(xmlNode),NA)
	}
	getSampleMap<-function(ur,show.msg=F){
		if(show.msg==T)cat("sample url: ",ur,"\n")
		xml<-xmlTreeParse(getURL(ur,userpwd=userpwd))$doc[[1]]
		samp.id<-xmlValue2(xml[["name"]])
		
		samp.type<-xml[["type"]]
		Batch_ID<-NA;Histology<-NA;Disease_Abbreviation<-NA
		if(!is.null(samp.type)){
			if(xmlAttrs(samp.type)["name"]=="TCGA Sample"){
				Batch_ID<-ifelse(length(samp.type)>0,xmlValue2(samp.type[[1]]),NA)
				Histology<-ifelse(length(samp.type)>1,xmlValue2(samp.type[[2]]),NA)
				Disease_Abbreviation<-ifelse(length(samp.type)>2,xmlValue2(samp.type[[3]]),NA)
			}
		}
		
		species.field<-5;gender.field<-6;tissue.field<-7
		if(!is.null(samp.type)){species.field<-6;gender.field<-7;tissue.field<-8}
		species<-xmlValue2(xml[[species.field]])
		gender<-xmlValue2(xml[[gender.field]])
		tissue<-xmlValue2(xml[[tissue.field]])
		return(c(name=samp.id,batch=Batch_ID,histology=Histology,diseaseabr=Disease_Abbreviation,species=species,gender=gender,tissue=tissue))
	}
	getPlateSerial<-function(ur){
		xml<-xmlTreeParse(getURL(ur,userpwd=userpwd))$doc[[1]]
		serial<-xmlValue2(xml[["name"]])
		return(c(plateserial=serial))
	}
	getBeadMap<-function(ur){
		xml<-xmlTreeParse(getURL(ur,userpwd=userpwd))$doc[[1]]
		serial<-xmlValue2(xml[["name"]])
		return(c(beadserial=serial))
	}
	plate.map<-sapply(map.inoutput,function(x){
				fields.in<-xmlAttrs(x[[1]])
				url.in<-paste(fields.in["uri"],"&limsid=",fields.in["limsid"],sep="")
				map.input<-xmlTreeParse(getURL(url.in,userpwd=userpwd))$doc[[1]]
				map.input.loc<-map.input["location"]
				plateposition<-xmlValue2((map.input.loc[[1]])[[2]])
				plateLIMSID<-xmlAttrs((map.input.loc[[1]])[[1]])["limsid"]
				map.plate.url<-xmlAttrs((map.input.loc[[1]])[[1]])["uri"]
				plateserial<-getPlateSerial(map.plate.url)
				
				fields.out<-xmlAttrs(x[[2]])
				url.out<-paste(fields.out["uri"],"&limsid=",fields.out["limsid"],sep="")
				map.output<-xmlTreeParse(getURL(url.out,userpwd=userpwd))$doc[[1]]
				map.output.loc<-map.output["location"]
				beadposition<-xmlValue2((map.output.loc[[1]])[[2]])
				beadLIMSID<-xmlAttrs((map.output.loc[[1]])[[1]])["limsid"]
				map.bead.url<-xmlAttrs((map.output.loc[[1]])[[1]])["uri"]
				beadserial<-getBeadMap(map.bead.url)
				map.output.samp<-map.output["sample"]
				map.output.samp.url<-xmlAttrs(map.output.samp[[1]])["uri"]
				map<-getSampleMap(map.output.samp.url)
				map<-c(map.date_run,beadserial,beadposition,beadLIMSID,plateserial,plateposition,plateLIMSID,map)
				names(map)<-c("date_run","beadserial","beadposition","beadLIMSID","plateserial","plateposition","plateLIMSID","name","batch","histology","diseaseabr","species","gender","tissue")
				return(map)
			})
	return(t(plate.map))
}

getPlateMap.1<-function(process.url,userpwd="zack:genzack",show.msg=F){
	if(show.msg==T)cat("on processing ",process.url,"\n")
	map.top<-getURL(process.url,userpwd=userpwd)
	map<-xmlTreeParse(map.top)$doc[[1]]
	map.date_run<-xmlValue(map[[2]])
	map.inoutput<-map[grep("input-output-map",names(map))]
	xmlValue2<-function(xmlNode){
		value<-ifelse(!is.null(xmlNode),xmlValue(xmlNode),NA)
	}
	getSampleMap<-function(ur){
		xml<-xmlTreeParse(getURL(ur,userpwd=userpwd))$doc[[1]]
		samp.id<-xmlValue2(xml[["name"]])
		samp.type<-xml[["type"]]
		Batch_ID<-xmlValue2(samp.type[[1]])
		Histology<-xmlValue2(samp.type[[2]])
		Disease_Abbreviation<-xmlValue2(samp.type[[3]])
		species<-xmlValue2(xml[[6]])
		gender<-xmlValue2(xml[[7]])
		tissue<-xmlValue2(xml[[8]])
		return(c(samp.id,Batch_ID,Histology,Disease_Abbreviation,species,gender,tissue))
	}
	getPlateSerial<-function(ur){
		xml<-xmlTreeParse(getURL(ur,userpwd=userpwd))$doc[[1]]
		serial<-xmlValue2(xml[["name"]])
		return(c(plateserial=serial))
	}
	getBeadMap<-function(ur){
		xml<-xmlTreeParse(getURL(ur,userpwd=userpwd))$doc[[1]]
		serial<-xmlValue2(xml[["name"]])
		return(c(beadserial=serial))
	}
	plate.map<-sapply(map.inoutput,function(x){
				fields.in<-xmlAttrs(x[[1]])
				url.in<-paste(fields.in["uri"],"&limsid=",fields.in["limsid"],sep="")
				map.input<-xmlTreeParse(getURL(url.in,userpwd=userpwd))$doc[[1]]
				map.input.loc<-map.input["location"]
				plateposition<-xmlValue2((map.input.loc[[1]])[[2]])
				plateLIMSID<-xmlAttrs((map.input.loc[[1]])[[1]])["limsid"]
				map.plate.url<-xmlAttrs((map.input.loc[[1]])[[1]])["uri"]
				plateserial<-getPlateSerial(map.plate.url)
				
				fields.out<-xmlAttrs(x[[2]])
				url.out<-paste(fields.out["uri"],"&limsid=",fields.out["limsid"],sep="")
				map.output<-xmlTreeParse(getURL(url.out,userpwd=userpwd))$doc[[1]]
				map.output.loc<-map.output["location"]
				beadposition<-xmlValue2((map.output.loc[[1]])[[2]])
				beadLIMSID<-xmlAttrs((map.output.loc[[1]])[[1]])["limsid"]
				map.bead.url<-xmlAttrs((map.output.loc[[1]])[[1]])["uri"]
				beadserial<-getBeadMap(map.bead.url)
				map.output.samp<-map.output["sample"]
				map.output.samp.url<-xmlAttrs(map.output.samp[[1]])["uri"]
				map<-getSampleMap(map.output.samp.url)
				map$plateposition<-plateposition;map$plateLIMSID<-plateLIMSID;map$plateserial<-plateserial
				map$beadposition<-beadposition;map$beadLIMSID<-beadLIMSID;map$beadserial<-beadserial
				map$date_run<-map.date_run;
				return(map)
			})
	return(t(plate.map))
}


