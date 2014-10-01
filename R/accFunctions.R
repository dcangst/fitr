#' transform OD values
#'
#' internal function to transform od values. -Inf, NaN values are replaced with NA.
#'
#' @param data
#' @param od_colnr
#' @param time_colnr
#' @param trafo
#' @section Output:
#'    data.frame as input with new colum 'ODtrans'
#' @keywords fitr
.gcDataTrafo <- function(data,od_colnr,time_colnr,trafo,logBase=2){
  
  data <- data[with(data, order(data[,time_colnr])), ]

  if (trafo=="logNN0"){
    data$ODtrans <- log(data[,od_colnr]/data[1,od_colnr],logBase)
  } else if (trafo=="log"){
    data$ODtrans <- log(data[,od_colnr],logBase)
  } else if (trafo=="none"){
    data$ODtrans <- data[,od_colnr]
  } else {
    stop("invalid trafo argument!")
  }

  data$ODtrans[!is.finite(data$ODtrans)] <- NA

  return(data)

}
#' generate color gradient 
#'
#' with colors from blue(low) to red(high)
#' NA get the same color as the lowest value.
#'
#' @param x a numeric vector
#' @section Output:
#'    character vector with colors
#' @keywords fitr
.rgbColorGradient <- function(x){

  x <- x + abs(min(x,na.rm=TRUE))
  x[is.na(x)] <- 0

  color <- rgb((x-min(x, na.rm=TRUE))/(max(x, na.rm=TRUE)-min(x, na.rm=TRUE)),0,1-(x-min(x, na.rm=TRUE))/(max(x, na.rm=TRUE)-min(x, na.rm=TRUE)))
  return(color)

}