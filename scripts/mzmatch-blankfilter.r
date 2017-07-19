#!/usr/bin/env Rscript

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

# Taking the command line arguments
args <- commandArgs(trailingOnly = TRUE)

if(length(args)==0)stop("No file has been specified! Please select a file for blankfiltering!\n")
require(mzmatch.R)
mzmatch.init(memorysize=16000,version.1=FALSE)
require(xcms)
inputPeakML<-NA
output<-NA
blankName<-""
for(arg in args)
{
  argCase<-strsplit(x = arg,split = "=")[[1]][1]
  value<-strsplit(x = arg,split = "=")[[1]][2]
  if(argCase=="input")
  {
    inputPeakML=as.character(value)
  }
  if(argCase=="blankname")
  {
    blankName=as.character(value)
  }
  if(argCase=="output")
  {
    output=as.character(value)
  }
}

if(is.na(inputPeakML) | is.na(output)) stop("Both input and output need to be specified!\n")


if(blankName=="") stop("Blank name needs to be specified!\n")

inputXCMS<-PeakML.xcms.read(inputPeakML,version.1 = F)


listOfExtentions<-c("mzml","featurexml")
inputExtention<-"mzml"
lnFlag<-T
for(i in 1:length(inputXCMS@filepaths))
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


PeakML.BlankFilter (filename=inputPeakML,
   ionisation="detect", 
   outputfile=output,
   BlankSample=blankName)




