#' transform OD values
#'
#' internal function to transform od values
#'
#' @param data
#' @param od_colnr
#' @param time_colnr
#' @param trafo
#' @section Output:
#'    data.frame as input with new colum 'ODtrans'
#' @keywords fitr
.gcDataTrafo <- function(data,od_colnr,time_colnr,trafo){
  
  data <- data[with(data, order(data[,time_colnr])), ]

  if(trafo=="logNN0"){
    data$ODtrans <- log(data[,od_colnr]/data[1,od_colnr])
  } else if (trafo=="log"){
    data$ODtrans <- log(data[,od_colnr])
  } else if (trafo=="none"){
    data$ODtrans <- data[,od_colnr]
  } else {
    stop("invalid trafo argument!")
  }

  return(data)

}