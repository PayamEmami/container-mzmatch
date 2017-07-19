#!/usr/bin/env Rscript

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

# Taking the command line arguments
args <- commandArgs(trailingOnly = TRUE)

if(length(args)==0)stop("No file has been specified! Please select a file for dilution filtering!\n")
require(mzmatch.R)
mzmatch.init(memorysize=16000,version.1=FALSE)
require(xcms)
dataFiles<-NA
output<-NA
rt<-15
mz<-5
for(arg in args)
{
  argCase<-strsplit(x = arg,split = "=")[[1]][1]
  value<-strsplit(x = arg,split = "=")[[1]][2]
  if(argCase=="input")
  {
      input=as.character(value)
  if(file.info(input)$isdir & !is.na(file.info(input)$isdir))
  {
    dataFiles<-list.files(input,full.names = T)
    
  }else
  {
   
     dataFiles<-sapply(strsplit(x = input,split = "\\;|,| |\\||\\t"),function(x){x})
    
  }
  }
  if(argCase=="rt")
  {
    rt=as.numeric(value)
  }
  if(argCase=="mz")
  {
    mz=as.numeric(value)
  }
  
  if(argCase=="output")
  {
    output=as.character(value)
  }
}

if(any(is.na(dataFiles)) | is.na(output)) stop("Input and output need to be specified!\n")


for(inputPeakML in dataFiles)
{
inputXCMS<-PeakML.xcms.read(inputPeakML,version.1 = F)


listOfExtentions<-c("mzml","featurexml")
inputExtention<-"mzml"
lnFlag<-T
for(i in 1:1)
{
  if(!file.exists(inputXCMS@filepaths[i]))
  {
  
    tobeLinked<-tools::file_path_sans_ext(inputXCMS@filepaths[i])
    extention<-tools::file_ext(inputXCMS@filepaths[i])
    if(file.exists(tobeLinked) & (tolower(extention)%in%listOfExtentions))
    {
      system(paste("ln -s ",tobeLinked," ",inputXCMS@filepaths[i]))
      
      
    }else
    {
      lnFlag<-F
    }

  }else if(!tools::file_ext(inputXCMS@filepaths[i])%in%listOfExtentions)
  {
    system(paste("ln -s ",inputXCMS@filepaths[i]," ",inputXCMS@filepaths[i],".",inputExtention,sep=""))
    inputXCMS@filepaths[i]<-paste(inputXCMS@filepaths[i],".",inputExtention,sep="")
  }
}

}
mzmatch.ipeak.Combine(i=paste(dataFiles,collapse=","), v=T, rtwindow=rt, 
   o=output, combination="set", ppm=mz)


