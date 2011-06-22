# TODO: Add comment
# 
# Author: feipan
###############################################################################



#############################
#
#############################
RepositoryAdd_test<-function(){
	tcga<-"c:\\tcga"
	repos<-"c:\\temp\\repos"
	fdir<-c("OV","GBM")
	RepositoryAdd(tcga,repos)
}
RepositoryAdd<-function(tcga,repos,fdir=NULL){
	if(is.null(fdir))fdir<-list.files(tcga)
	setwd(repos)
	for(fd in fdir){
		if(fd!="repos")
		{
			fd<-file.path(tcga,fd)
			pkgs<-list.files(fd,pattern="gz",recursive=T,full.names=T)
			for(fn in pkgs){
				fn1<-filetail(fn)
				if(!file.exists(fn1))file.copy(fn,file.path(repos,fn1))
			}
		}
	}
}
RepositoryManifest<-function(tcga){
	fdir<-list.files(tcga)
	#fdir<-fdir[-which(fdir=="repos")]
	for(fd in fdir){
		setwd(file.path(tcga,fd))
		if(R.Version()$os=="mingw32"){
			md5<-file.path(system.file("Rtools",package="rapid"),"md5sum")
			shell(paste(md5," -t *.gz* > MD5"))
		}else{
			system("md5sum *.gz* > MD5")
		}
	}
}
uploadFiles_test<-function(){
	host<-"epinexus.usc.edu"
	repos<-"/home/feipan/test"
	localFns<-c("c:\\temp\\auc_test.txt","c:\\temp\\t1.txt")
	user<-"feipan"
	uploadFiles(localFns,host,repos,user)
}
uploadFiles<-function(localFns,host,repos,user,isFolder=F,package="rapid"){
	rst<-NULL
	cdir<-getwd()
	host<-paste(user,"@",host,":",repos,sep="")
	scp<-"scp"
	if(R.Version()$os=="mingw32"){
		scp<-file.path(system.file("Rtools",package=package),"bin/scp")
	}
	for(fn in localFns){
		setwd(filedir(fn))
		fn<-filetail(fn)
		rst<-system(paste(scp,fn,host,sep=" "),invisible=F)
	}
	setwd(cdir)
	return(rst)
}
uploadFiles.2<-function(localFns,host,repos,user,isfolder=F,identityFn=NULL){
	host<-paste(user,"@",host,":",repos,sep="")
	for(fn in localFns){
		if(!is.null(identityFn)) system(paste("scp ",fn,host,"-i ",identityFn,sep=" "),invisible=F)
		else system(paste("scp",fn,host,sep=" "),invisible=F)
	}
}
###########
# Upload files in the same folder
# note: -3joj.txt 
##########
uploadFiles.2_test<-function(){
	localFns<-choose.files()
	uploadFiles.2(localFns,host="epinexus.usc.edu",repos="/home/feipan/test",user="feipan")
}
uploadFiles.2<-function(localFns,host,repos,user,isFolder=F){
	host<-paste(user,"@",host,":",repos,sep="")
	scp<-"scp"
	if(R.Version()$os=="mingw32"){
		scp<-file.path(system.file("Rtools",package="rapid"),"bin/scp")
	}
	datDir<-filedir(localFns[1])
	setwd(datDir)
	localFns<-sapply(localFns,function(x)filetail(x))
	fn<-paste(localFns,collapse=" ")
	system(paste(scp,fn,host,sep=" "),invisible=F)
}
downloadFiles_test<-function(){
	host<-"epinexus.usc.edu"
	repos<-"/home/feipan/test"
	localDir<-"c:\\temp"
	user<-"feipan"
	downloadFiles(localDir,host,repos,user,isFolder=T)
}
downloadFiles<-function(localDir,host="hpc-epc.usc.edu",repos="/home/uec-02/shared/production/methylation/meth27k/tcga",
		user="feipan",isFolder=F,Fn=NULL){
	rst<-NULL
	cdir<-getwd()
	if(!is.null(Fn)) repos<-file.path(repos,Fn)
	host<-paste(user,"@",host,":",repos,sep="")
	scp<-"scp"
	if(R.Version()$os=="mingw32"){
		scp<-file.path(system.file("Rtools",package="rapid"),"bin/scp")
	}
	setwd(localDir)
	if(isFolder==F) rst<-system(paste(scp,host,".",sep=" "),invisible=F)
	else rst<-system(paste(scp,"-r",host,"."),invisible=F)
	setwd(cdir)
	return(rst)
}
createLocalRepos_test<-function(){
	reValue<-c("c:/temp/.","GBM")
	createLocalRepos()
}
createLocalRepos.2<-function(txt=NULL,host="hpc-uec.usc.edu",repos="/home/uec-02/shared/production/methylation/meth27k/tcga",inter=T){
	if(inter==T)createLocalReposDlg()
	if(is.null(reValue)) return()
	if(!is.null(txt))tkinsert(txt,"end",paste(">Start to create local data repository...",date(),"\n"))
	reposDir<-reValue[1]
	cancerType<-reValue[2]
	reValue<<-NULL
	downloadFiles(reposDir,host,repos,isFolder=T,Fn=cancerType)
	if(!is.null(txt)) tkinsert(txt,"end",paste("> Finished creating local repository at ",reposDir,"\n"))
}
createLocalRepos<-function(txt=NULL,host="hpc-uec.usc.edu",repos="/home/uec-02/shared/production/methylation/meth27k/tcga",inter=T){
	if(inter==T)createLocalReposDlg()
	if(is.null(reValue)) return()
	if(!is.null(txt))tkinsert(txt,"end",">Start to create local data repository\n")
	tcgaRepos<-paste(host,repos,sep=":")
	reposDir<-reValue[1]
	cancerType<-reValue[2]
	scp<-"scp"
	if(R.Version()$os=="mingw32"){
		rt<-system.file("Rtools",package="rapid")
		if(file.exists(rt)){
			scp<-file.path(rt,"bin/scp")
		}
	}
	tcgaRepos<-file.path(tcgaRepos,toupper(cancerType))
	rst<-system(paste(scp," -r ",tcgaRepos," ",reposDir),invisible=F)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",paste("> Finished creating local repository at ",reposDir,"\n"))
}
createLocalReposDlg<-function(){
	dlg<-startDialog("Create Local Data Repository")
	tkgrid(tklabel(dlg,text=""))
	dlg1<-tkfrm(dlg)
	addTextEntryWidget(dlg1,"Select the data repository folder:","",isFolder=T,name="reposDir")
	addTextEntryWidget(dlg1,"Type in the type of cancer:","GBM",isFolder=F,name="cancerType")
	tkaddfrm(dlg,dlg1)
	endDialog(dlg,c("reposDir","cancerType"))
}

#todo: check md5sum
updateLocalRepos_test<-function(){
	reValue<-c("C:\\temp\\COAD_test","COAD")
	updateLocalRepos(txt=NULL)
}
updateLocalRepos<-function(txt=NULL,host="hpc-uec.usc.edu",repos="/home/uec-02/shared/production/methylation/meth27k/tcga",auto=F){
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to update the local data repository...",date(),"\n"))
	if(auto==F)createLocalReposDlg()
	if(is.null(reValue))return()
	localDir<-reValue[1]
	remoteDir<-reValue[2]
	localPkgs<-list.files(localDir,"gz")
	if(file.exists(file.path(localDir,"MD5"))) {
		md5.local<-read.delim(file=file.path(localDir,"MD5"),sep=" ",header=F)
		localPkgs<-md5.local[,3]
	}
	localDir1<-file.path(localDir,"bk")
	if(!file.exists(localDir1)) dir.create(localDir1)
	downloadFiles(localDir1,host=host,repos=repos,Fn=file.path(remoteDir,"MD5"),isFolder=F)
	md5<-read.delim(file=file.path(localDir1,"MD5"),sep=" ",header=F)
	remPkgs<-md5[,3]
	newPkgs<-remPkgs[!is.element(remPkgs,localPkgs)]
	if(length(newPkgs)>0){
		msg<-paste(">The following new data package(s) will be downloaded:\n",paste(newPkgs,collapse="\n"),"Please validate local data repository\n",sep="")
		cat(msg)
		if(!is.null(txt))tkinsert(txt,"end",msg)
	}
	newPkgs<-c(newPkgs,"MD5")
	for(pkg in newPkgs){
		downloadFiles(localDir,host=host,repos=repos,Fn=file.path(remoteDir,pkg),isFolder=F)
	}
	reValue<<-NULL
	if(!is.null(txt))tkinsert(txt,"end",">Finished updating the local data repository\n")
}

ViewUecRepository<-function(txtWin){
	link<-"http://epinexus.usc.edu/MPL"
	if(R.Version()$os=="mingw32"){
		shell.exec(link)
	}else{
		system(link)
	}
}
uploadUECRepos_test<-function(){
	reValue<-c("C:\\temp\\COAD_test\\jhu-usc.edu_COAD.HumanMethylation27.Level_2.4.10.0.tar.gz","COAD","feipan")
	uploadUECRepos(txt=NULL)
}
uploadUECRepos<-function(txt=NULL,host="hpc-uec.usc.edu",repos="/home/uec-02/shared/production/methylation/meth27k",auto=F){
	if(auto==F)uploadReposDlg.2()
	if(is.null(reValue)) return()
	pkgs<-reValue[1]
	pkgs<-strsplit(gsub("[{|}]","",pkgs)," ")[[1]]
	rmDir<-reValue[2]
	user<-reValue[3]
	if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to upload the following data packages to HPC-UEC repository: \n",paste(pkgs,collapse="\n"),"\n",sep=""))
	
	localDir<-filedir(pkgs[1])
	localDir1<-file.path(localDir,"bk")
	if(!file.exists(localDir1)) dir.create(localDir1)
	downloadFiles(localDir1,host,Fn=file.path(rmDir,"MD5"),user=user)
	md5<-read.table(file.path(localDir1,"MD5"),sep=" ",head=F)
	pkgFns<-sapply(pkgs,function(x)filetail(x))
	pkg.exists<-pkgs[is.element(pkgFns,md5[,3])]
	if(length(pkg.exists)>0){
		msg<-paste(">The following data packages already exists, please update local data repository first:\n",paste(pkg.exists,collapse="\n"),"\n",sep="")
		cat(msg)
		if(!is.null(txt))tkinsert(txt,"end",msg)
		return()
	}
	dat<-data.frame(c1=rep("",length(pkgs)),c2=rep("",length(pkgs)),pkgFns)
	write.table(dat,file=file.path(localDir,"MD5"),append=T,row.names=F,col.names=F,sep=" ",quote=F)
	pkgs<-c(file.path(localDir,"MD5"),pkgs)
	rmDir<-file.path(repos,"tcga",rmDir)
	rst<-uploadFiles.2(pkgs,host,repos=rmDir,user=user,isFolder=F)
	reValue<<-NULL
	if(!is.null(txt)) tkinsert(txt,"end",">Finished uploading data packages")
}
uploadReposDlg.2<-function(){
	dlg<-startDialog("Upload Data Packages")
	tkgrid(tklabel(dlg,text=""))
	frm<-tkfrm(dlg)
	addTextEntryWidget(frm,"Select the local data packages:","",isFolder=F,fileType="any",name="localDir")
	addTextEntryWidget(frm,"Type in the remote data folder:","GBM",isFolder=F,withSelectButton=F,name="rmDir")
	addTextEntryWidget(frm,"Type in the account name:","feipan",withSelectButton=F,name="user")
	tkaddfrm(dlg,frm)
	endDialog(dlg,c("localDir","rmDir","user"))
}
uploadReposDlg<-function(){
	dlg<-startDialog("Upload Data Packages")
	tkgrid(tklabel(dlg,text=""))
	frm<-tkfrm(dlg)
	addTextEntryWidget(frm,"Select the local data repository folder:","c:/tcga",isFolder=T,name="localDir")
	addTextEntryWidget(frm,"Type in the remote data folder:","GBM",isFolder=F,withSelectButton=F,name="rmDir")
	addTextEntryWidget(frm,"Type in the account name:","feipan",withSelectButton=F,name="user")
	tkaddfrm(dlg,frm)
	endDialog(dlg,c("localDir","rmDir","user"))
}
viewTcgaDCC<-function(txt){
	link<-"http://tcga-data.nci.nih.gov/tcga/"
	if(R.Version()$os=="mingw32"){
		shell.exec(link)
	}else{
		system(link)
	}
}
submitTcgaDcc<-function(txt=NULL){
	pkgs<-choose.files()
	if(pkgs==""|length(pkgs)==0)return()
	rv<-tkmessageBox(message="Are you sure to continue?",type="yesno")
	if(tclvalue(rv)=="no") return()
	else{
		if(!is.null(txt)) tkinsert(txt,"end",paste(">Start to submit the following data package(s) to DCC:",paste(pkgs,collapse="\n"),"\n",sep=""))
		uploadFiles(pkgs,host="cbioftp2.nci.nih.gov",repos="",user="jmhi")
		if(!is.null(txt)) tkinsert(txt,"end",">Finished submitting data packages\n")
	}
}
openSampleDB<-function(txt){
	shell.exec("http://epinexus.usc.edu/mdb/index.jsp")
}
RepositoryValidate_run<-function(){
	javaPath<-"/auto/uec-00/shared/production/software/java/1.6.0_21/bin/"
	tcga<-""
	validatorPath<-""
	RepositoryValidate(tcga,validatorPath,javaPath)
}
RepositoryValidate<-function(tcga,validatorPath,javaPath){
	fdir<-list.files(tcga)
	fdir<-fdir[-which(fdir=="repos")]
	for(fd in fdir){
		fd<-file.path(tcga,fd)
		validatePkg(fd,validatorPath,javaPath)
		setwd(fd)
		fdr<-list.files(fd,pattern="jhu-usc")
		fdr<-fdr[-grep("gz",fdr)]
		for(f1 in fdr){
			system(paste("rm -r ",f1))
		}
	}
}

RepositoryCL_test<-function(){
	tcga<-"/auto/uec-02/shared/production/methylation/OMA002/tcga"
	RepositoryCL(tcga)
	tcga<-"/auto/uec-02/shared/production/methylation/OMA003/tcga"
	RepositoryCL(tcga)
	tcga<-"/auto/uec-02/shared/production/methylation/meth27k/tcga"
	RepositoryCL(tcga)
}
RepositoryCL<-function(tcga){
	pkgFD<-list.files(tcga)
	pkgFD<-pkgFD[-which(pkgFD=="repos")]
	repos<-list.files(file.path(tcga,"repos"),pattern="gz")
	cat(length(repos),"\n")
	pkgs.all<-c()
	for(fd in pkgFD){
		fd<-file.path(tcga,fd)
		pkgs<-list.files(fd,pattern="gz")
		pkgs.all<-c(pkgs.all,pkgs)
	}
	setwd(file.path(tcga,"repos"))
	for(fn in pkgs.all){
		if(file.exists(fn)) file.remove(fn)
	}
	repos<-list.files(file.path(tcga,"repos"),pattern="gz")
	cat(length(repos),"\n")
}
###############################
# Nov 18
##############################

#############
# platemap.txt
#############
create_plate_manifest_test<-function(){
	arrayMapFn<-"c:\\tcga\\others\\arraymapping\\sample_mapping.txt"
	ar<-read.delim(file=arrayMapFn,sep="\t",header=F)
	ind<-substr(ar[,3],1,4)=="TCGA"
	ar.tcga<-ar[ind,]
	dim(ar.tcga)
#	[1] 1385    3
	table(duplicated(ar.tcga[,3]))
#	FALSE  TRUE 
#	1267   118
	ar.tcga.unique<-ar.tcga[!duplicated(ar.tcga[,3]),]
	dim(ar.tcga.unique)
#	[1] 1267    3
	fn<-"c:\\tcga\\platemap.txt"
	packageMapFn<-"c:\\tcga\\packagemap.txt"
	pl<-create_plate_manifest(packageMapFn,arrayMapFn,fn)
	dim(pl) #[1] 1159   11
	length(unique(pl[,1]))
	
	ind<-is.element(ar.tcga.unique[,3],unique(pl[,1]))
	head(ar.tcga.unique[ind,])
	ar.tcga.unique.ex<-ar.tcga.unique[!ind,]
	dim(ar.tcga.unique.ex)
	head(ar.tcga.unique.ex)

	unique(ar.tcga.unique.ex[,1])
	ar.tcga.unique.ex[ar.tcga.unique.ex[,1]=="4841860026",]
#	3077 4841860026  G TCGA-30-1869-01A-01D-0652-05
}
create_plate_manifest<-function(batchManifestFn,arrayMapFn,fn=NULL){
	bm<-read.delim(file=batchManifestFn,sep="\t")
	ar<-read.delim(file=arrayMapFn,sep="\t",header=F)
	names(ar)<-c("chip_id","array","sample")
	pl<-merge(ar,bm,by.x=3,by.y=2)
	if(!is.null(fn)) write.table(pl,file=fn,sep="\t",row.names=F,quote=F)
	return(pl)
}
###########
# packagemap.txt 
# note: as batch.txt before
############
create_batch_manifest_test<-function(){
	tcgaRepos<-"c:\\tcga"
	bmFn<-"c:\\tcga\\packagemap.txt" 
	
	manifestFn<-"c:\\tcga\\package.txt"
	fdir<-c("BRCA","COAD","GBM","KIRC","KIRP","LAML","LUAD","LUSC","OV","READ","STAD","UCEC")
	pm<-create_batch_manifest(manifestFn,tcgaRepos,bmFn,fdir)
	dim(pm) #2491  9
	batchManifestFn<-"c:\\tcga\\packagemap.txt"
	pm<-read.delim(file=batchManifestFn,sep="\t",as.is=T,stringsAsFactors=F)
	pm.dup<-pm[duplicated(pm[,"Sample_ID"]),]
	dim(pm.dup)
#	[1] 5 9
	ind<-is.element(pm[,2],pm.dup[,2])
	pm2<-pm[ind,c(1,2)]
	
	fdir<-c("BRCA","COAD","GBM","KIRC","KIRP","LAML","LUAD","LUSC","OV","READ","GBM_OMA002","GBM_OMA003","STAD","UCEC")
	bmFn<-"c:\\tcga\\batch.txt"
	batchManifest<-create_batch_manifest.1(manifestFn,tcgaRepos,bmFn,fdir)
	dim(batchManifest)	#3027
}

create_batch_manifest<-function(manifestFn,tcgaRepos,bmFn=NULL,fdir=NULL){
	manifest<-read.delim(file=manifestFn,sep="\t",as.is=T)
	if(is.null(fdir)){
		fdir<-list.files(tcgaRepos)
		fdir<-fdir[-which(fdir=="repos")]
	}
	batchManifest<-NULL
	for(fd in fdir){
		cat(fd,"\n")
		mage<-list.files(file.path(tcgaRepos,fd),"mage")
		magePkg<-mage[grep("tar.gz$",mage)];
		uncompress(magePkg,file.path(tcgaRepos,fd))
		mageDir<-gsub(".tar.gz","",magePkg)#mage[-grep("tar",mage)]
		sdrfFn<-list.files(file.path(tcgaRepos,fd,mageDir),"sdrf",full.name=T)
		sdrf<-read.delim(file=sdrfFn,sep="\t",as.is=T,check.names=F)
		sdrf<-sdrf[,c(1,grep("TCGA Archive Name",names(sdrf)))]#sdrf<-sdrf[,c(1,19,26,33)]
		names(sdrf)<-c("Sample_ID","Package-lvl-1","Package-lvl-2","Package-lvl-3")
		if(is.null(batchManifest)) {
			batchManifest<-merge(sdrf,manifest,by.x=2,by.y=1);
			if(nrow(sdrf)!=nrow(batchManifest)) cat(paste(fd,",check."))
			batchManifest<-batchManifest[!duplicated(batchManifest[,2]),]
		}else{
			batchManifest1<-merge(sdrf,manifest,by.x=2,by.y=1)
			if(nrow(sdrf)!=nrow(batchManifest1)) cat(paste(fd,",check."))
			batchManifest1<-batchManifest1[!duplicated(batchManifest1[,2]),]
			batchManifest<-rbind(batchManifest,batchManifest1)
		}
	}
	if(!is.null(bmFn)) write.table(batchManifest,file=bmFn,sep="\t",row.names=F,quote=F)
	return(batchManifest)
}

create_batch_manifest.1<-function(manifestFn,tcgaRepos,bmFn=NULL,fdir=NULL){
	manifest<-read.delim(file=manifestFn,sep="\t",as.is=T)
	if(is.null(fdir)){
		fdir<-list.files(tcgaRepos)
		fdir<-fdir[-which(fdir=="repos")]
	}
	batchManifest<-NULL
	for(fd in fdir){
		cat(fd,"\n")
		mage<-list.files(file.path(tcgaRepos,fd),"mage")
		magePkg<-mage[grep("tar.gz$",mage)];
		uncompress(magePkg,file.path(tcgaRepos,fd))
		mageDir<-gsub(".tar.gz","",magePkg)#mage[-grep("tar",mage)]
		sdrfFn<-list.files(file.path(tcgaRepos,fd,mageDir),"sdrf",full.name=T)
		sdrf<-read.delim(file=sdrfFn,sep="\t",as.is=T)
		sdrf<-sdrf[,c(1,19)]
		if(is.null(batchManifest)) {
			batchManifest<-merge(sdrf,manifest,by.x=2,by.y=1);
			if(nrow(sdrf)!=nrow(batchManifest)) cat(paste(fd,",check."))
			batchManifest<-batchManifest[!duplicated(batchManifest[,2]),]
		}else{
			batchManifest1<-merge(sdrf,manifest,by.x=2,by.y=1)
			if(nrow(sdrf)!=nrow(batchManifest1)) cat(paste(fd,",check."))
			batchManifest1<-batchManifest1[!duplicated(batchManifest1[,2]),]
			batchManifest<-rbind(batchManifest,batchManifest1)
		}
	}
	batchManifest<-batchManifest[,-1]
	nm<-names(batchManifest)
	nm[1]<-"sample_id"
	names(batchManifest)<-nm
	if(!is.null(bmFn)) write.table(batchManifest,file=bmFn,sep="\t",row.names=F,quote=F)
	return(batchManifest)
}
#from lvl-1 only
batch_manifest.2_test<-function(){
	#	bmFn<-"c:\\tcga\\batch2.txt"
#	manifestFn<-"c:\\tcga\\package.txt"
#	#fdir<-c("BRCA","COAD","GBM","KIRC","LAML","LUAD","LUSC","OV","READ")
#	batchManifest<-create_batch_manifest.2(manifestFn,tcgaRepos,bmFn,fdir)
#	dim(batchManifest)
	##	[1] 1740    6 //meth27
#	table(duplicated(batchManifest[,1]))
#	batchManifest[duplicated(batchManifest[,1]),]
}
create_batch_manifest.2<-function(manifestFn,tcgaRepos,bmFn=NULL,fdir=NULL){
	if(is.null(fdir)){
		fdir<-list.files(tcgaRepos)
		fdir<-fdir[-which(fdir=="repos")]
	}
	manifest<-read.delim(file=manifestFn,sep="\t",as.is=T)
	manifest<-manifest[grep("Level_1",manifest[,1]),]
	batchManifest<-NULL
	for(fd in fdir){
		cat(fd,"\n")
		manifest2<-manifest[grep(fd,manifest[,1]),]
		if(nrow(manifest2)<1){
			cat(paste(fd," is missing....\n"))
			next;
		}
		for(i in 1:nrow(manifest2)){
			sampleDir<-file.path(tcgaRepos,fd,manifest2[i,1])
			sampleIDs<-getSampleID(sampleDir)
			#batchManifest1<-data.frame(sampleIDs,as.data.frame(matrix(manifest2[i,],nrow=length(sampleIDs),ncol=ncol(manifest2))))
			temp<-data.frame(sampleIDs=as.character(sampleIDs),pkg=manifest2[i,1])
			batchManifest1<-merge(temp,manifest2[i,],by.x=2,by.y=1)
			if(is.null(batchManifest)){
				batchManifest<-batchManifest1
			}else{
				batchManifest<-rbind(batchManifest,batchManifest1)
			}
		}
	}
	if(!is.null(bmFn)) write.table(batchManifest,file=bmFn,sep="\t",row.names=F,quote=F)
	return(batchManifest)
}
#####################
# package.txt
#####################
create_pkg_manifest.2_test<-function(){
	pkgFolders<-"c:\\tcga"
	create_pkg_manifest.2(pkgFolders,"c:\\tcga\\package.txt")
	package<-read.delim(file="c:\\tcga\\package.txt",sep="\t") 
	dim(package);length(unique(package$Batch_Number)) #59
	package<-package[grep("Level_1",package$PkgName),];
}

#create_pkg_manifest.2a<-function(reposPath,pkgFolder=NULL,pkgManifestFn=NULL,txt=NULL){
#	if(is.null(pkgFolder)){
#		pkgFolder<-list.files(reposPath)
#		pkgFolder<-pkgFolder[-which(pkgFolder=="repos")]
#	}
#	create_pkg_manifest(file.path(reposPath,pkgFolder[1]),txt,fn=pkgManifestFn,toUpdate=F,toAppend=F)
#	for(pkg in pkgFolder[-1]){
#		create_pkg_manifest(file.path(reposPath,pkg),txt,fn=pkgManifestFn,toUpdate=F,toAppend=T)
#	}
#}
create_pkg_manifest.2<-function(pkgFolders,txt=NULL,fn=NULL){
	pkgFolder<-list.files(pkgFolders)
	pkgFolder<-pkgFolder[-which(pkgFolder=="repos")|pkgFolder=="others"]
	pkgFolder<-pkgFolder[-grep(".txt",pkgFolder)]
	create_pkg_manifest(file.path(pkgFolders,pkgFolder[1]),txt,fn=NULL,toUpdate=F,toAppend=F)
	for(pkg in pkgFolder[-1]){
		cat(pkg);cat("\n")
		create_pkg_manifest(file.path(pkgFolders,pkg),txt,fn=NULL,toUpdate=F,toAppend=T)
	}
}
create_pkg_manifest_test<-function(){
	create_pkg_manifest("c:\\tcga\\GBM","c:\\tcga\\package_GMB.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\READ","c:\\tcga\\package_READ.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\COAD","c:\\tcga\\package_COAD.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\BRCA","c:\\tcga\\package_BRCA.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\KIRC","c:\\tcga\\package_KIRC.txt",toAppend=F) #
	create_pkg_manifest("c:\\tcga\\LAML","c:\\tcga\\package_LAML.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\LUAD","c:\\tcga\\package_LUAD",toAppend=F)
	create_pkg_manifest("c:\\tcga\\LUSC","c:\\tcga\\package_LUSC",toAppend=F)
	create_pkg_manifest("c:\\tcga\\GBM_OMA002")
	create_pkg_manifest("c:\\tcga\\GBM_OMA003")
	create_pkg_manifest("c:\\tcga\\OV","c:\\tcga\\package_OV.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\STAD","c:\\tcga\\package_STAD.txt",toAppend=F)
	create_pkg_manifest("c:\\tcga\\UCEC","c:\\tcga\\package_UCEC.txt",toAppend=F)
}

create_pkg_manifest<-function(pkgFolder,fn=NULL,toUpdate=F,toAppend=T,txt=NULL){
	if(is.null(fn)) fn<-"c:\\tcga\\package.txt"
	pkgNames<-list.files(pkgFolder,pattern=".tar.gz")
	ind<-grep("md5",pkgNames);pkgNames<-pkgNames[-ind]
	ind<-grep("mage",pkgNames);pkgNames<-pkgNames[-ind]
	setwd(pkgFolder)
	sapply(pkgNames,function(x)uncompress(x))
	pkgNames<-gsub(".tar.gz","",pkgNames)
	pkg_info<-paste("PkgName","Batch_Number","Cancer_Type","Total_Sample_Number","Total_Ctr_Sample_Number","Ctr_Sample_Name",sep="\t")
	if(toAppend==T) pkg_info<-readLines(fn)
	pkg_info.all<-c()
	for(pkg in pkgNames){
		cat(pkg);cat("\n")
		pkgDir<-file.path(pkgFolder,pkg)
		pkgNumb<-sum(regexpr(pkg,pkg_info)>=1)
		if(pkgNumb>0){
			cat(paste("Package ", pkg," is already in the manifest\n"))
			if(toUpdate==F) stop()
		}
		fn0<-list.files(pkgDir)
		sample_number<-length(fn0)-2
		ctr_sample_number<-sum(regexpr("-20A-",fn0)>=1) #0227
		ctr_sample<-fn0[grep("-20A-",fn0)] #0227
		if(ctr_sample_number>1){
			ctr_sample<-paste(ctr_sample,collapse=";")
		}else if(ctr_sample_number==0){
			ctr_sample<-"None"
		}
		fn1<-file.path(pkgDir,"DESCRIPTION.txt")
		if(file.exists(fn1)){
			descript<-readLines(fn1)
			dat<-descript[grep("[B,b]atch",descript)]
			batch.sn<-NA
			if(!is.null(dat)){
				batch.sn<-strsplit(strsplit(tolower(dat),"batch ")[[1]][2],"\\.")[[1]][1]
				if(is.na(batch.sn)) batch.sn<-strsplit(strsplit(tolower(dat),"batches ")[[1]][2],"\\.")[[1]][1]
				batch.sn<-gsub(")","",batch.sn)
				if(length(batch.sn)>1) batch.sn<-paste(batch.sn,collapse=" or ")
			}else{
				cat(paste("batch info is not available for package ",pkg,"\n"))
			}
			cancer_type<-strsplit(strsplit(pkgDir,"edu_")[[1]][2],"\\.")[[1]][1]
		}
		pkg_info1<-paste(pkg,batch.sn,cancer_type,sample_number,ctr_sample_number,ctr_sample,sep="\t")
		pkg_info.all<-paste(pkg_info.all,pkg_info1,sep="\n")
	}
	if(toAppend==F) pkg_info.all<-paste(pkg_info,pkg_info.all,sep="")
	else pkg_info.all<-substr(pkg_info.all,2,nchar(pkg_info.all))
	write(pkg_info.all,file=fn,append=toAppend)
}

#create_pkg_manifest<-function(pkgFolder,txt=NULL,fn=NULL,toUpdate=F,toAppend=T){
#	if(is.null(fn)) fn<-"c:\\tcga\\package.txt"
#	#mani<-read.delim(file=fn,sep="\t",header=T)
#	pkgNames<-list.files(pkgFolder,pattern="Level_")
#	ind<-grep("tar",pkgNames)
#	pkgNames<-pkgNames[-ind]
#	pkg_info<-paste("PkgName","Batch_Number","Cancer_Type","Total_Sample_Number","Total_Ctr_Sample_Number","Ctr_Sample_Name",sep="\t")
#	if(toAppend==T) pkg_info<-readLines(fn)
#	pkg_info.all<-c()
#	for(pkg in pkgNames){
#		pkgDir<-file.path(pkgFolder,pkg)
#		pkgNumb<-sum(regexpr(pkg,pkg_info)>=1)
#		if(pkgNumb>0){
#			cat(paste("Package ", pkg," is already in the manifest\n"))
#			if(toUpdate==F) stop()
#		}
#		fn0<-list.files(pkgDir)
#		sample_number<-length(fn0)-2
#		ctr_sample_number<-sum(regexpr("-20A-",fn0)>=1) #0227
#		ctr_sample<-fn0[grep("-20A-",fn0)] #0227
#		if(ctr_sample_number>1){
#			ctr_sample<-paste(ctr_sample,collapse=";")
#		}else if(ctr_sample_number==0){
#			ctr_sample<-"None"
#		}
#		fn1<-file.path(pkgDir,"DESCRIPTION.txt")
#		if(file.exists(fn1)){
#			descript<-readLines(fn1)
#			dat<-descript[grep("[B,b]atch",descript)]
#			batch.sn<-NA
#			if(!is.null(dat)){
#				batch.sn<-strsplit(strsplit(tolower(dat),"batch ")[[1]][2],"\\.")[[1]][1]
#				if(is.na(batch.sn)) batch.sn<-strsplit(strsplit(tolower(dat),"batches ")[[1]][2],"\\.")[[1]][1]
#				batch.sn<-gsub(")","",batch.sn)
#				#batch.sn<-sapply(strsplit(tolower(dat),"batch ")[[1]][-1],function(x)strsplit(x,"\\.| ")[[1]][1])
#				if(length(batch.sn)>1) batch.sn<-paste(batch.sn,collapse=" or ")
#			}
#			cancer_type<-strsplit(strsplit(pkgDir,"edu_")[[1]][2],"\\.")[[1]][1]
#		}
#		pkg_info1<-paste(pkg,batch.sn,cancer_type,sample_number,ctr_sample_number,ctr_sample,sep="\t")
#		pkg_info.all<-paste(pkg_info.all,pkg_info1,sep="\n")
#	}
#	if(toAppend==F) pkg_info.all<-paste(pkg_info,pkg_info.all,sep="")
#	else pkg_info.all<-substr(pkg_info.all,2,nchar(pkg_info.all))
#	write(pkg_info.all,file=fn,append=toAppend)
#}
############
# 
##############
update_plate_manifest_test<-function(){
	arraysFn<-"c:\\tcga\\others\\raw_manifest.txt"
	pkgManifestFn<-"c:\\tcga\\others\\package.txt"
	batchManifestFn<-"c:\\tcga\\others\\packagemap.txt"
	arrayMapFn<-"c:\\tcga\\others\\arraymapping\\sample_mapping.txt"
	reposPath<-"c:\\tcga"
	pkgFolder<-c("BRCA","COAD","GBM","KIRC","KIRP","LAML","LUAD","LUSC","OV","READ","STAD","UCEC")
	plateMapFn<-"c:\\tcga\\others\\platemap.txt"
	pm<-update_plate_manifest(reposPath,pkgFolder,pkgManifestFn,batchManifestFn,arrayMapFn,plateMapFn)
	dim(pm$bm)
#	[1] 2463    7
	names(pm$bm)
#	[1] "pkg"                     "sampleIDs"              
#	[3] "Batch_Number"            "Cancer_Type"            
#	[5] "Total_Sample_Number"     "Total_Ctr_Sample_Number"
#	[7] "Ctr_Sample_Name"        
	batchNumber<-unique(pm$bm[,"Batch_Number"])
	batchNumber[order(batchNumber)]
	
	length(unique(pm$bm[,"sampleIDs"]))
#	[1] 2458
	ind<-duplicated(pm$bm[,"sampleIDs"])
	sample.dup<-pm$bm[ind,"sampleIDs"]
	ind2<-is.element(pm$bm[,"sampleIDs"],sample.dup)
	sampl.dups<-pm$bm[ind2,1:7]
	sampl.dups[order(sampl.dups[,"sampleIDs"]),]
	
}
update_plate_manifest<-function(reposPath,pkgFolder,pkgManifestFn,arraysFn,batchManifestFn,arrayMapFn,plateMapFn,toValidate=T){
	if(toValidate==T){
		for(pkg in pkgFolder) validatePkg(file.path(reposPath,pkg))
	}
	create_pkg_manifest.2a(reposPath,pkgFolder,pkgManifestFn)
	bm<-create_batch_manifest.2(pkgManifestFn,reposPath,batchManifestFn,pkgFolder)
	plateMap<-create_plate_manifest(batchManifestFn,arrayMapFn,plateMapFn)
	return(list(plateMap=plateMap,bm=bm))
}
########
# "Wed Feb 16 15:25:26 2011"
########
update_OMA03_ADF<-function(){
	wdir<-"C:\\tcga\\GBM_OMA003\\jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.mage-tab.1.3.0"
	adfFn<-"jhu-usc.edu_GBM.IlluminaDNAMethylation_OMA003_CPI.v2.adf.txt"
	adf<-read.table(file=file.path(wdir,adfFn),sep="\t",header=T,check.names=F)
	library(mAnnot)
	oma03<-getMapInfo("OMA03")
	oma03<-oma03[,c("IlmnID","mapInfo")]
	adf.new<-merge(adf,oma03,by.x=1,by.y=1)
	names(adf.new)[7]<-"CpG_Coordinate"
	write.table(adf.new,file=file.path(wdir,adfFn),sep="\t",quote=F,row.names=F)
}
copyArrayIDAT<-function(srcDir,outDir,arrayBarcodes){
	for(barcode in arrayBarcodes){
		fidats<-list.files(file.path(srcDir,barcode),pattern="idat")
		if(!file.exists(file.path(outDir,barcode))) dir.create(file.path(outDir,barcode))
		for(fidat in fidats){
			cat(fidat);cat("\n")
			file.copy(file.path(srcDir,barcode,fidat),file.path(outDir,barcode,fidat))
		}
	}
}

##########
#
##########
submitTCGAPkgs<-function(tcgaPath){
	cancers<-list.files(tcgaPath)
	cancers<-cancers[-grep("repos",cancer)]
	for(cancer in cancers){
		pkgPath<-file.path(tcgaPath,cancer)
		pkgs.new<-clearTCGARepos(pkgPath,file.path(tcgaPath,"repos"))
		uploadFiles.2(pkgs.new,host="cbioftp2.nci.nih.gov",repos="",user="jhmi",identityFn)
	}
}
