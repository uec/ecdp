###############
# Meth27 Ext Table
###############
createMeth27ExtTable<-function(){
	con<-dbConnect(dbDriver("SQLite"),dbname="c:\\tcga\\others\\manifestDB.sqlite")
	library(mAnnot)
	dat<-getData()
	meth27.ext<-humanMeth27k[,c("ILmnID","IlmnStrand","AlleleA_ProbeSeq","AlleleB_ProbeSeq","TopGenomicSeq","Next_Base","TSS_Coordinate",
					"Gene_Strand","Gene_ID","Symbol","Other Aliases","Accession","GID",
					"Annotation","Product","Distance_to_TSS","CPG_ISLAND","CPG_ISLAND_LOCATIONS",
					"MIR_CPG_ISLAND","MIR_NAMES","Ploidy","Species","Source","SourceStrand","SourceVersion")]
	sqliteWriteTable(con,"HumanMethylation27ext",meth27.ext,append=T)
	dbDisconnect(con)
}

##############
# OMA Basic and Ext Table
##############
createOMAtables<-function(dbname=NULL){
	if(is.null(dbname)) dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname=dbname)
	library(mAnnot)
	fn<-c("IlmnID","Chr","CpG_Coordinate","SourceSeq","GenomeBuild")
	getData("OMA02")
	oma02<-OMA02Manifest[,c("Probe_ID","Chromosome","CpG_Coordinate","Input_Sequence")]
	oma02<-data.frame(oma02,rep("36",nrow(OMA02Manifest)))
	names(oma02)<-fn
	sqliteWriteTable(con,"GoldenGateOMA02",oma02,append=T)
	dbListTables(con)
	
	getData("OMA03")
	oma03<-OMA03Manifest[,c("Probe_ID","Chromosome","CpG_Coordinate","Input_Sequence")]
	oma03<-data.frame(oma03,rep("36",nrow(OMA03Manifest)))
	names(oma03)<-fn
	sqliteWriteTable(con,"GoldenGateOMA03",oma03,append=T)
	
	getData("OMA04")
	oma04<-OMA04Manifest[,c("TargetID","Chr","CpG_Coordinate","Sequence","Genome_Build_Version")]
	names(oma04)<-fn
	sqliteWriteTable(con,"GoldenGateOMA04",oma04,append=T)
	
	dbDisconnect(con)
}
createOMAExtTables<-function(dbname=NULL){
	if(is.null(dbname)) dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname=dbname)
	getData("OMA02")
	om02<-OMA02Manifest[,c("Probe_ID","Gid","Accession","Symbol","Gene_ID","RefSeq","Dist_to_TSS",
					"CpG_island","Synonym","Annotation","Product")]
	sqliteWriteTable(con,"GoldenGateOMA02ext",oma02,append=T)
	dbListTables(con)
	
	getData("OMA03")
	oma03<-OMA03Manifest[,c("Probe_ID","Gid","Accession","Symbol","Gene_ID","RefSeq","Dist_to_TSS","CpG_island","Synonym","Annotation","Product")]
	sqliteWriteTable(con,"GoldenGateOMA03ext",oma03,append=T)
	dbListTables(con)
	
	getData("OMA04")
	oma04<-OMA04Manifest[,c("Probe_ID","Source","RefSeq","Ploidy","Species","Customer_Strand","Customer_Annotation",
					"Final_Score","Failure_Codes","Validation_Class","Validation_Bin","App_Version","Search_Key","CpG_Island",
					"ILMN_Designed_Strand","TSS_Coordinate","CpG_Offset","Gene_Strand","Gene_ID","Synonym","Accession","GID",
					"Annotation","Product")]
	sqliteWriteTable(con,"GoldenGateOMA04ext",oma04,append=T)
	dbDisconnect(con)
}
createMethyLightTables<-function(dbname=NULL){
	if(is.null(dbname)) dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname=dbname)
	getData("methyLight")
	MethyLightManifest$mapInfo<-MethyLightManifest[,"start_genome_coord_blat_aligned"]+(MethyLightManifest[,"end_genome_coord_blat_aligned"]-MethyLightManifest[,"start_genome_coord_blat_aligned"])/2
	ml<-MethyLightManifest[,c("Reaction Number","Chr_blat_aligned","mapInfo","Probe Oligo Sequence")]
	ml<-data.frame(ml,rep("36",nrow(ml)))
	names(ml)<-c("Probe_ID","Chr","MapInfo","SourceSeq","GenomeBuild")
	sqliteWriteTable(con,"MethyLightManifest",ml,append=T)
	dbDisconnect(con)
}

##############
# HumanMeth450
###########
createHumanMeth450Table<-function(){
	library(IlluminaHumanMethylation450k.db)
#	org.Hs.eg.db_2.4.6
	probe_Code<-IlluminaHumanMethylation450k_getProbes()
	str(probe_Code)
	dat2<-probe_Code[[2]]
	dat2[dat2$Probe_ID=="cg02004872",]
#	Probe_ID        M        U
#	53 cg02004872 25785404 25785404
	CpG_Coordinate.36<-toTable(IlluminaHumanMethylation450kCPG36)
	pid<-CpG_Coordinate.36[,1]
	dim(CpG_Coordinate.36)
#	[1] 485577      2
	length(unique(CpG_Coordinate.36$Probe_ID))
#	[1] 485577
	CpG_Coordinate.37<-toTable(IlluminaHumanMethylation450kCPG37)
	names(CpG_Coordinate.37)
#	[1] "Probe_ID"      "Coordinate_37"
	row.names(CpG_Coordinate.37)<-CpG_Coordinate.37$Probe_ID
	CpG_Coordinate.37<-CpG_Coordinate.37[pid,]
	
	Chr<-toTable(IlluminaHumanMethylation450kCHR36)
	row.names(Chr)<-Chr$Probe_ID
	Chr<-Chr[pid,]
	Channel<-toTable(IlluminaHumanMethylation450kCOLORCHANNEL)
	names(Channel)
	row.names(Channel)<-Channel$Probe_ID
	Channel<-Channel[pid,]
	meth450<-data.frame(IlmnID=pid,Chr,CpG_Coordinate.36,CpG_Coordinate.37,Channel)
	meth450<-meth450[,c("IlmnID","Chromosome_36","Coordinate_36","Coordinate_37","Color_Channel")]
	#names(meth450)<-c("")
	con<-dbCon()
	dbWrite(con,meth450,"HumanMethylation450")
	dbDisconnect(con)
}
#########
# Entrez Gene Annot
##########
createEntrezGeneTable<-function(dbname=NULL,wdir=NULL){
	if(is.null(dbname))dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname=dbname)
	datSrc<-"ftp://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz"
	if(is.null(wdir)) wdir<-"c:\\temp"
	download.file(datSrc,destfile=file.path(wdir,"gene_info.gz"))
	ungzip(file.path(wdir,"gene_info.gz"))
	file.rename(file.path(wdir,"gene_info"),file.path(wdir,"dat.txt"))
	readGeneInfo2(wdir)
	dat<-read.table(file=file.path(wdir,"out.txt"),sep="\t",header=F,as.is=T,stringsAsFactors=F)
	names(dat)<-c("GeneID","Symbol")
	datSrc2<-"ftp://ftp.ncbi.nih.gov/gene/DATA/gene_history.gz"
	download.file(datSrc2,destfile=file.path(wdir,"gene_history.gz"))
	ungzip(file.path(wdir,"gene_history.gz"))
	dat2<-read.table(file=file.path(wdir,"gene_history"),sep="\t",header=F,skip=1,as.is=T)
	names(dat2)<-c("tax_id", "GeneID", "Discontinued_GeneID", "Discontinued_Symbol", "Discontinue_Date")
	ind<-dat2$tax_id=="9606"
	dat2<-dat2[ind,]
	sqliteWriteTable(con,"EntrezGene",dat)
	dbDisconnect(con)
}
createEntrezGeneTable.2<-function(dbname=NULL,wdir=NULL){
	if(is.null(dbname))dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname=dbname)
	datSrc<-"ftp://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz"
	if(is.null(wdir)) wdir<-"c:\\temp"
	download.file(datSrc,destfile=file.path(wdir,"gene_info.gz"))
	ungzip(file.path(wdir,"gene_info.gz"))
	dat<-readLines(file.path(wdir,"gene_info"))
	dat2<-dat[grep("9606",dat)]
	dat<-as.data.frame(t(sapply(dat2,function(x)strsplit(x,"\t")[[1]])))
	names(dat)<-c("taxID","GeneID","Symbol","LocusTag","Synonyms","dbXrefs","Chromosome","MapLocation","Description","Type","Nomenclature","Name","Status","OtherDesignations","ModificationDate")
	dat<-dat[,-1]
	table(dat$Type)
	sqliteWriteTable(con,"EntrezGene",dat)
	dbDisconnect(con)
}
createEntrezGeneHistoryTable<-function(){
	con<-dbCon()
	datSrc2<-"ftp://ftp.ncbi.nih.gov/gene/DATA/gene_history.gz"
	download.file(datSrc2,destfile=file.path(wdir,"gene_history.gz"))
	ungzip(file.path(wdir,"gene_history.gz"))
	dat2<-read.table(file=file.path(wdir,"gene_history"),sep="\t",header=F,skip=1,as.is=T)
	names(dat2)<-c("tax_id", "GeneID", "Discontinued_GeneID", "Discontinued_Symbol", "Discontinue_Date")
	ind<-dat2$tax_id=="9606"
	dat2<-dat2[ind,-1]
	sqliteWriteTable(con,"EntrezGeneHistory",dat2)
	dbDisconnect(con)
}
################
# RefSeq Annot
#################

createRefGeneTable<-function(dbname=NULL,wdir=NULL){
	refGene<-downloadRefSeq(wdir)
	if(is.null(dbname)) dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname=dbname)
	sqliteWriteTable(con,"RefGene",refGene)
	dbDisconnect(con)
}

downloadRefSeq<-function(wdir,build=NULL,update=T){
	datURL<-"ftp://hgdownload.cse.ucsc.edu/goldenPath/hg18/database/refGene.txt.gz"
	if(!is.null(build)) datURL<-paste("ftp://hgdownload.cse.ucsc.edu/goldenPath/",build,"/database/refGene.txt.gz",sep="")
	if(is.null(wdir)) wdir<-"c:\\temp"
	if(update==T){
		download.file(datURL,destfile=file.path(wdir,"refGene.txt.gz"))
		ungzip(file.path(wdir,"refGene.txt.gz"))
	}
	refGene<-read.table(file=file.path(wdir,"refGene.txt"),sep="\t",header=F,as.is=T,stringsAsFactors=F)
	refGene<-data.frame(refGene,rep(build,nrow(refGene)))
	refGene<-refGene[,-1]
	names(refGene)<-c("Name","Chrom","Strand","TxStart","TxEnd","CdsStart","CdsEnd","ExonCount","ExonStarts","ExonEnds","Id","Name2","CdsStartStat","CdsEndStat","ExonFrames","GenomeBuild")
	return(refGene)
}
updateRefGeneTable<-function(){
	con<-dbCon()
	refGene<-downloadRefSeq("C:\\feipan\\database\\ucsc\\hg18","hg18")
	dbWrite(con,refGene,"RefGene")
	refGene<-downloadRefSeq("C:\\feipan\\database\\ucsc\\hg19","hg19")
	dbAppend(con,refGene,"RefGene")
	dbDisconnect(con)
}


###############
# Polycomb
# Mon Feb 07 09:50:42 2011
###############
createPolycombOccupancyTable<-function(){
	datSrcFn<-"C:\\feipan\\database\\literature\\polycomb_Lee_Cell.125.2006\\PIIS0092867406003849.mmc10.csv"
	dat<-read.csv(file=datSrcFn,sep=",",skip=1,header=T,check.names=F)
	names(dat)<-c("EntrezGene_ID","Gene_Name","Suz12","Eed","H3K27me3")
	suz12<-dat[,c(1,2,3)];suz12$PolyComb<-rep("Suz12",nrow(suz12));names(suz12)[3]<-"Occupancy"
	suz12$Occupancy<-ifelse(suz12$Occupancy==1,"YES","NO");table(suz12$Occupancy)
	eed<-dat[,c(1,2,4)];eed$PolyComb<-rep("Eed",nrow(eed));names(eed)[3]<-"Occupancy"
	eed$Occupancy<-ifelse(eed$Occupancy==1,"YES","NO");table(eed$Occupancy)
	h3k27<-dat[,c(1,2,5)];h3k27$PolyComb<-rep("H3K27me3",nrow(h3k27));names(h3k27)[3]<-"Occupancy"
	h3k27$Occupancy<-ifelse(h3k27$Occupancy==1,"YES","NO");table(h3k27$Occupancy)
	polycomb<-rbind(suz12,eed)
	polycomb<-rbind(polycomb,h3k27)
	names(polycomb)
	con<-dbCon()
	dbWrite(con,polycomb,"PolycombOccupancy")
	dbDisconnect(con)
}

create_Suz12OccupancyAnnot<-function(dbname=NULL){
	library(mAnnot)
	humanMeth27k<-getPolycombInfo()
	suz12<-data.frame(IlmnID=humanMeth27k$IlmnID,Suz12_Occupancy=humanMeth27k$Suze12Occupancy,stringsAsFactors=F)
	suz12$Platform<-rep("Meth27",nrow(suz12))
	oma4<-getPolycombInfo("OMA04")
	dat<-data.frame(IlmnID=oma4$IlmnID,Suz12_Occupancy=oma4$Suze12Occupancy,stringsAsFactors=F)
	dat$Platform<-rep("OMA04",nrow(oma4))
	suz12<-rbind(suz12,dat)
	oma3<-getPolycombInfo("OMA03")
	dat<-data.frame(IlmnID=oma3$IlmnID,Suz12_Occupancy=oma3$Suze12Occupancy,stringsAsFactors=F)
	dat$Platform<-rep("OMA03",nrow(oma3))
	suz12<-rbind(suz12,dat)
	oma2<-getPolycombInfo("OMA02")
	dat<-data.frame(IlmnID=oma2$IlmnID,Suz12_Occupancy=oma2$Suze12Occupancy,stringsAsFactors=F)
	dat$Platform<-rep("OMA02",nrow(oma2))
	suz12<-rbind(suz12,dat)
	table(suz12$Platform)
#	Meth27  OMA02  OMA03  OMA04 
#	27578   1505   1498   1536 
	if(is.null(dbname))dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname)
	sqliteWriteTable(con,"Suz12Occupancy",suz12)
	dbDisconnect(con)
}
update_Suz12OccupancyAnnot<-function(){
	con<-dbCon()
	geneAnnot<-dbQuery(con,"EntrezGeneAnnot")
	suz12Annot<-dbQuery.2(con,"PolycombOccupancy","Polycomb","Suz12")
	annot<-merge(geneAnnot,suz12Annot,by.x=2,by.y=1,all.x=T)
	annot<-annot[,c("Probe_ID","Occupancy","Platform")]
	dbWrite(con,annot,"Suz12Occupancy")
	dbDisconnect(con)
}
validate_Suz12OccupancyAnnot<-function(){
	con<-dbCon()
	rst<-dbSendQuery(con,"Select * from Suz12Occupancy")
	dat<-fetch(rst,n=-1)
	names(dat)
	dim(dat)
	table(dat$Platform)
#	meth27  OMA02  OMA03  OMA04 
#	27578   1505   1498   1536
	table(dat[dat$Platform=="OMA02","Occupancy"]) #1133  232 
	table(dat[dat$Platform=="OMA03","Occupancy"]) #1168  138 
	table(dat[dat$Platform=="OMA04","Occupancy"]) #597 935
	table(dat[dat$Platform=="meth27","Occupancy"]) #23559  1924 
	dbClearResult(rst)
	dbDisconnect(con)
}
create_EedOccupancyAnnot<-function(dbname=NULL){
	library(mAnnot)
	platforms<-c("Meth27","OMA04","OMA02")
	Eed<-NULL
	for(pl in platforms){
		poly<-getPolycombInfo(pl)
		dat<-data.frame(IlmnID=poly$IlmnID,Eed_Occupancy=poly$EedOccupancy,stringsAsFactors=F)
		dat$Platform<-rep(pl,nrow(dat))
		if(is.null(Eed)) Eed<-dat
		else Eed<-rbind(Eed,dat)
	}
	table(Eed$Platform)
#	Meth27  OMA02  OMA04 
#	27578   1505   1536 
	writeToDB(Eed,"EedOccupancy")
}
update_EedOccupancyAnnot<-function(){
	con<-dbCon()
	geneAnnot<-dbQuery(con,"EntrezGeneAnnot")
	EedAnnot<-dbQuery.2(con,"PolycombOccupancy","Polycomb","Eed")
	annot<-merge(geneAnnot,EedAnnot,by.x=2,by.y=1,all.x=T)
	annot<-annot[,c("Probe_ID","Occupancy","Platform")]
	dbWrite(con,annot,"EedOccupancy")
	dbDisconnect(con)
}
validate_EedOccupancyAnnot<-function(){
	con<-dbCon()
	dat<-dbQuery(con,"EedOccupancy")
	dim(dat)
	table(dat$Platform)
#	meth27  OMA02  OMA03  OMA04 
#	27578   1505   1498   1536
	dbDisconnect(con)
}
create_H3K27me3OccupancyAnnot<-function(dbname=NULL,platforms=NULL){
	library(mAnnot)
	if(is.null(platforms)) platforms<-c("Meth27","OMA04","OMA03","OMA02")
	H3k27<-NULL
	for(pl in platforms){
		poly<-getPolycombInfo(pl)
		dat<-data.frame(IlmnID=poly$IlmnID,H3K27me3_Occupancy=poly$H3K27me3Occupancy,stringsAsFactors=F)
		dat$Platform<-rep(pl,nrow(dat))
		if(is.null(H3k27)) H3k27<-dat
		else H3k27<-rbind(H3k27,dat)
	}
	writeToDB(H3k27,"H3K27me3Occupancy")
}
update_H3K27me3OccupancyAnnot<-function(){
	con<-dbCon()
	geneAnnot<-dbQuery(con,"EntrezGeneAnnot")
	h3k27<-dbQuery.2(con,"PolycombOccupancy","Polycomb","H3K27me3")
	annot<-merge(geneAnnot,h3k27,by.x=2,by.y=1,all.x=T)
	annot<-annot[,c("Probe_ID","Occupancy","Platform")]
	dbWrite(con,annot,"H3K27me3Occupancy")
	dbDisconnect(con)
}
validate_H3K27me3Occupancy<-function(){
	con<-dbCont()
	dat<-dbQuery(con,"H3K27me3Occupancy")
	dim(dat)
	table(dat$Platform)
#	Meth27  OMA02  OMA03  OMA04 
#	27578   1505   1498   1536 
}


##################################
# repeats Mask
#################################
download_rsmp_update<-function(build=NULL,outPath=NULL){
	if(is.null(outPath))outPath<-"C:\\feipan\\database\\ucsc\\hg19\\repeatMask"
	URL<-"ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/database"
	if(!is.null(build))URL<-paste("ftp://hgdownload.cse.ucsc.edu/goldenPath/",build,"/database",sep="")
	Fn<-c("rmsk.txt.gz","rmsk.sql")
	download_rsmp(URL,outPath,Fn)
}
download_rsmp<-function(URL=NULL,outPath,rsmpFns=NULL){
	if(is.null(URL)) URL<-"ftp://hgdownload.cse.ucsc.edu/goldenPath/hg18/database"
	if(is.null(rsmpFns))rsmpFns<-c("chr1_rmsk.txt.gz","chr2_rmsk.txt.gz","chr3_rmsk.txt.gz","chr4_rmsk.txt.gz",
			"chr5_rmsk.txt.gz","chr6_rmsk.txt.gz","chr7_rmsk.txt.gz","chr8_rmsk.txt.gz",
			"chr9_rmsk.txt.gz","chr10_rmsk.txt.gz","chr11_rmsk.txt.gz","chr12_rmsk.txt.gz",
			"chr13_rmsk.txt.gz","chr14_rmsk.txt.gz","chr15_rmsk.txt.gz","chr16_rmsk.txt.gz",
			"chr17_rmsk.txt.gz","chr18_rmsk.txt.gz","chr19_rmsk.txt.gz","chr20_rmsk.txt.gz",
			"chr21_rmsk.txt.gz","chr22_rmsk.txt.gz","chrX_rmsk.txt.gz","chrY_rmsk.txt")
	for(fn in rsmpFns){
		download.file(file.path(URL,fn),destfile=file.path(outPath,fn))
		ungzip(file.path(outPath,fn))
	}
}
prepare_rsmp<-function(datPath){
	rsmpFns<-list.files(datPath,pattern="rmsk.txt")
	rsmp.all<-NULL
	for(fn in rsmpFns){
		dat<-read.delim(file=file.path(datPath,fn),sep="\t",header=F,as.is=T)
		rsmp.chr<-dat[,c(12,6,7,8,11,13)]
		names(rsmp.chr)<-c("Class","Chr","start","end","Name","Family")
		rsmp.chr["mapInfo"]<-rsmp.chr$start+(rsmp.chr$end-rsmp.chr$start)/2
		if(is.null(rsmp.all)) rsmp.all<-rsmp.chr
		else rsmp.all<-rbind(rsmp.all,rsmp.chr)
	}
	save(rsmp.all,file=file.path(datPath,"rsmp.all.rdata"))
}
createRepeatMaskTable_test<-function(){
	load(file="c:\\feipan\\database\\ucsc\\rmsk\\rsmp.all.rdata")
	createRepeatMaskTable(rsmp.all,"hg18")
	
	datPath<-"c:\\feipan\\database\\ucsc\\hg19\\repeatMask"
	dat<-read.delim(file=file.path(datPath,"rmsk.txt"),header=F,sep="\t")
	dat<-dat[,c(12,6,7,8,11,13)]
	names(dat)<-c("Class","Chr","Start","End","Name","Family")
	createRepeatMaskTable(dat,"hg19",T)
}
createRepeatMaskTable<-function(dats,build,append=F){
	con<-dbCon()
	i<-1
	tableName<-"RepeatMask"
	for(dat in dats){
		dat$Build<-build[i]
		i<-i+1
		if(append==F)dbWrite(con,dat,tableName)
		else dbAppend(con,dat,tableName)
	}
	dbDisconnect(con)
}
################
# Utility
###############
createSQLiteDB<-function(){
	library(RSQLite)
	dbFile<-tempfile()
	db<-file.info(dbFile)
	con<-dbConnect(dbDriver("SQLite"),dbname=dbFile)
	library(mAnnot)
	getData()
	ilmn<-humanMeth27k[,c("ILmnID","Chr","MapInfo","AddressA_ID","AddressB_ID","SourceSeq","GenomeBuild")]
	sqliteWriteTable(con,"HumanMethylation27",ilmn)
	dbListTables(con)
	dbListFields(con,"HumanMethylaiton27")
	rs<-dbSendQuery(con,"Select * from HumanMethylation27")
	fetch(rs,n=10)
	dbDisconnect(con)
	dbUnloadDriver(con)
	file.copy(row.names(db),"c:\\temp\\manifestDB.sqlite")
}
dbWrite<-function(con,dat,tableName){
	if(dbExistsTable(con,tableName)) dbRemoveTable(con,tableName) 
	sqliteWriteTable(con,tableName,dat)
}
dbCon<-function(dbname=NULL){
	require(RSQLite)
	if(is.null(dbname)) dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname)
	return(con)
}
writeToDB<-function(dat,tableName){
	require(RSQLite)
	if(is.null(dbname)) dbname<-"c:\\tcga\\others\\manifestDB.sqlite"
	con<-dbConnect(dbDriver("SQLite"),dbname)
	if(dbExistsTable(con,tableName)) dbRemoveTable(con,tableName)
	sqliteWriteTable(con,tableName,dat)
	dbDisconnect(con)
}
dbQuery<-function(con,tableName,n=-1){
	query<-paste("select * from ",tableName)
	rst<-dbSendQuery(con,query)
	dat<-fetch(rst,n=n)
	dbClearResult(rst)
	return(dat[,-1])
}
dbQuery.2<-function(con,tableName,colName,colValue,n=-1){
	query<-paste("select * from ",tableName," where ",colName," ='",colValue,"';",sep="")
	rst<-dbSendQuery(con,query)
	dat<-fetch(rst,n=n)
	dbClearResult(rst)
	return(dat[,-1])
}
dbDump<-function(con,tableName,fileName,type="csv"){
	dat<-dbQuery(con,tableName)
	if(type=="csv")write.csv(dat,file=fileName,quote=F)
	else write.table(dat,file=fileName,sep="\t",quote=F,row.names=F)
}
dbAppend<-function(con,dat,tableName){
	dbInsert<-function(dat1){
		dat1<-paste(paste("'",dat1,"'",sep=""),collapse=",")
		query<-paste("insert into",tableName,"values (",dat1,");")
		rst<-dbSendQuery(con,query)
		dbClearResult(rst)
	}
	dat<-data.frame(row_names=row.names(dat),dat)
	apply(dat,1,dbInsert)
}
dbRemove<-function(tableName,colName,colValue){
	con<-dbCon()
	query<-paste("delete  from ",tableName," where ",colName," ='",colValue,"';",sep="")
	dbSendQuery(con,query)
	dbDisconnect(con)
}

