#!/usr/bin/env Rscript

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

# Taking the command line arguments
args <- commandArgs(trailingOnly = TRUE)

if(length(args)==0)stop("No file has been specified! Please select a file for dilution filtering!\n")
require(mzmatch.R)
mzmatch.init(memorysize=16000,version.1=FALSE)
require(xcms)
inputPeakML<-NA
output<-NA
dilutionTrend<-NA
pvalueCutoff<-0.10
for(arg in args)
{
  argCase<-strsplit(x = arg,split = "=")[[1]][1]
  value<-strsplit(x = arg,split = "=")[[1]][2]
  if(argCase=="input")
  {
    inputPeakML=as.character(value)
  }
  if(argCase=="dilution")
  {
    dilutionTrend=strsplit(split = ",",x = as.character(value),fixed = T)[[1]]
  }
  if(argCase=="pvalue")
  {
    pvalueCutoff=as.numeric(value)
  }
  
  if(argCase=="output")
  {
    output=as.character(value)
  }
}

if(is.na(inputPeakML) | is.na(output) | any(is.na(dilutionTrend))) stop("All input, output and dilution need to be specified!\n")

inputXCMS<-PeakML.xcms.read(inputPeakML,version.1 = T)


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

valid<-F
PeakML.DilutionTrendFilter(filename=inputPeakML,
                            ionisation="detect", Rawpath=NULL, trendSets=dilutionTrend,
                            p.value.thr=pvalueCutoff, outputfile=output)



