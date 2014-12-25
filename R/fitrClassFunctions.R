#' print function for class "fitr"
#'
#' prints description of data and selected 'best' fits
#'
#' @param object of class "fitr"
#' @keywords fitr
#' @export
print.fitr <- function(fitr){
  
  datasum <- plyr::ldply(fitr$fits,plyr::summarize,minT=min(nTime,na.rm=TRUE),maxT=max(nTime,na.rm=TRUE))
  failN <- dim(fitr$bestfits[fitr$bestfits$comment != "ok",c(1,11)])[1]
  failPercent <- signif(dim(fitr$bestfits[fitr$bestfits$comment != "ok",c(1,11)])[1]/length(datasum$ID)*100,digits=3)

  if (length(datasum$ID)>20) {
    IDs <- paste0(paste0(head(datasum$ID,5),collapse=", ")," .. ",paste0(tail(datasum$ID,5),collapse=", "))
  } else {
    IDs <- paste0(datasum$ID,collapse=", ")
  }

  cat("an object of class 'fitr'","\n")
  cat("\n")

  cat("$data","\n")
  cat("\t",length(datasum$ID)," growthcurves with ",min(datasum$minT,na.rm=TRUE), " to ", max(datasum$maxT,na.rm=TRUE), " timepoints",sep="")
  cat("\n")
  cat("\t","No valid fit for ",failN, " out of ",length(datasum$ID)," (",failPercent,"%) curves.",sep="")
  cat("\n")

  cat("\t","Growthcurve IDs: ",IDs,"\n",sep="")
  cat("\n")

  cat("$parameter:","\n")
  print(fitr$parameter)
  cat("\n")

  cat("$bestfits:","\n")
  print(fitr$bestfits[,1:12])
  cat("\n")
  cat("failed fits","\n")
  print(fitr$bestfits[fitr$bestfits$comment != "ok",c(1,14)])
  print(attr(fitr$bestfits,"error codes"))
  cat("\n")

  cat("$fits:","\n")
  cat("\t", "list of all fits for each growthcurve")
  cat("\n")

}

#' plot function for class "fitr"
#'
#' plots data and selected 'best' fits, a wrapper for \code{\link{plot_fitr}}
#'
#' @param object of class "fitr"
#' @keywords fitr
#' @export
plot.fitr <- function(fitr,interactive=TRUE,select=FALSE,sample_size=5,save=FALSE){

  plot_fitr(bestfit=fitr$bestfits,
          fits=fitr$fits,
          data=fitr$data$data,
          od_name=fitr$parameter$od_name,
          time_name=fitr$parameter$time_name,
          interactive=interactive,
          select=select,
          sample_size=sample_size,
          save=save)

}
#' write function for class "fitr"
#'
#' writes contents of fitr object in a 3 .csv files, *_summary.csv, *_fits.csv and *_data.csv
#'
#' @param object of class "fitr"
#' @param basefile base file name (not including .csv)
#' @param description data.frame containing description of your curves, must contain ID column with unique ID for each curve.
#' @param ... arguments passed to \code{\link{write.csv}}
#' @keywords fitr
#' @export
write.fitr <- function(fitr,basefile=paste0(format(Sys.time(), "%Y%m%d"),"fitR"),description=FALSE,sep=";"){
  
  datasum <- plyr::ldply(fitr$fits,plyr::summarize,minT=min(nTime,na.rm=TRUE),maxT=max(nTime,na.rm=TRUE))
  failN <- dim(fitr$bestfits[fitr$bestfits$comment != "ok",c(1,11)])[1]
  failPercent <- signif(dim(fitr$bestfits[fitr$bestfits$comment != "ok",c(1,11)])[1]/length(datasum$ID)*100,digits=3)

  sumtext1 <- paste(length(datasum$ID)," growthcurves with ",min(datasum$minT,na.rm=TRUE), " to ", max(datasum$maxT,na.rm=TRUE), " timepoints",sep="")
  sumtext2 <- paste("No valid fit for ",failN, " out of ",length(datasum$ID)," (",failPercent,"%) curves.",sep="")

  write.table(paste0("growthcurves fitted with fitR v.",packageVersion("fitr")),paste0(basefile,"_summary.csv"),row.names=FALSE,col.names=FALSE,sep=sep)
  write.table(sumtext1,paste0(basefile,"_summary.csv"),row.names=FALSE,col.names=FALSE,append=TRUE,sep=sep)
  write.table(sumtext2,paste0(basefile,"_summary.csv"),row.names=FALSE,col.names=FALSE,append=TRUE,sep=sep)
  write.table("$bestfits",paste0(basefile,"_summary.csv"),row.names=FALSE,col.names=FALSE,append=TRUE,sep=sep)
  if (description==FALSE){
    write.table(fitr$bestfits,paste0(basefile,"_summary.csv"),append=TRUE,row.names=FALSE,sep=sep)
  } else {
  write.table(merge(description,fitr$bestfits,by=c("ID")),paste0(basefile,"_summary.csv"),append=TRUE,row.names=FALSE,sep=sep)
  }
  write.table(ldply(fitr$fits,data.frame),paste0(basefile,"_fits.csv"),row.names=FALSE,sep=sep)

  write.table(fitr$data,paste0(basefile,"_data.csv"),row.names=FALSE,sep=sep)

}
