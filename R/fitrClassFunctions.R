#' print function for class "fitr"
#'
#' prints description of data and best fits
#'
#' @param object of class "fitr"
#' @section Output:
#'    output description
#' @keywords keyword
#' @export
print.fitr <- function(fitr){
  
  datasum <- ldply(ffa$fits,summarize,minT=min(nTime),maxT=max(nTime))
  if (length(datasum$ID)>20) {
    IDs <- paste0(paste0(head(datasum$ID,5),collapse=", ")," .. ",paste0(tail(datasum$ID,5),collapse=", "))
  } else {
    IDs <- paste0(datasum$ID,collapse=", ")
  }

  cat("an object of class 'fitr'","\n")
  cat("\n")

  cat("$data","\n")
  cat("\t",length(datasum$ID),"growthcurves with ",min(datasum$minT), " to ", max(datasum$maxT), "timepoints")
  cat("\n")

  cat("\t","Growthcurve IDs: ",IDs,"\n")
  cat("\n")

  cat("$parameter:","\n")
  print(fitr$parameter)
  cat("\n")

  cat("$bestfits:","\n")
  print(fitr$bestfits)
  cat("\n")
  
  cat("$fits:","\n")
  cat("\t", "list of all fits for each growthcurve")
  cat("\n")

}

#' plot function for class "fitr"
#'
#' plots data and best fits
#'
#' @param object of class "fitr"
#' @section Output:
#'    output description
#' @keywords keyword
#' @export
plot.fitr <- function(fitr,interactive=TRUE,select=FALSE){

  plotfit(bestfit=fitr$bestfits,
          fits=fitr$fits,
          data=fitr$data,
          od_name=fitr$parameter$od_name,
          time_name=fitr$parameter$time_name,
          interactive=interactive,
          select=select)

}