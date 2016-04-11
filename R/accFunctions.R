#' transform OD values
#'
#' internal function to transform od values. -Inf, NaN values are replaced with NA.
#'
#' @param data data
#' @param od_colnr col with OD values
#' @param time_colnr col with times
#' @param trafo which trafo to use
#' @param logBase which logbase (default: 2)
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

#' add attributes with error codes to data.frame
#'
#' 
#' @param best a data.frame from \code{\link{"pickfit"}}
#' @section Output:
#'    data.frame with attribute \code{"error codes"}
#' @keywords fitr
.attrErrorCodes <- function(best,min_numP,RsqCutoff,growthCheck){
  attr(best, "error codes") <- data.frame(code=c("a","b","c","d"),
                                            description=c("no valid fits",
                                                          paste("no fits with",min_numP,"points"),
                                                          paste("no fits with adj.r.sq >=",RsqCutoff),
                                                          paste("no growth (growthCheck=",growthCheck,")")                                                          
                                                          )
                                            )
  return(best)
}