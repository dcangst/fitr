#' print function for class "fitr"
#'
#' prints description of data and selected 'best' fits
#'
#' @param object of class "fitr"
#' @keywords fitr
#' @export
print.fitr <- function(fitr){
  
  datasum <- plyr::ldply(fitr$fits,summarize,minT=min(nTime,na.rm=TRUE),maxT=max(nTime,na.rm=TRUE))
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
  print(fitr$bestfits[,1:10])
  cat("\n")
  cat("failed fits","\n")
  print(fitr$bestfits[fitr$bestfits$comment != "ok",c(1,11)])
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
plot.fitr <- function(fitr,interactive=TRUE,select=FALSE,sample_size=5){

  plot_fitr(bestfit=fitr$bestfits,
          fits=fitr$fits,
          data=fitr$data,
          od_name=fitr$parameter$od_name,
          time_name=fitr$parameter$time_name,
          interactive=interactive,
          select=select,
          sample_size=sample_size)

}