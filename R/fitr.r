#' fitr.
#' A package containing tools for estimation of maximum growthrates from many growthcurves.
#' 
#' \code{\link{gcfit}}
#' \code{\link{pickfit}}
#' \code{\link{plot_fitr}}
#' \code{\link{d_gcfit}}
#' \code{\link{print.fitr}}
#' \code{\link{plot.fitr}}
#'
#' @name fitr
#' @docType package
#' @import plyr
NULL

#' One growth curve
#' 
#' A dataset containing one growth curve
#''
#' \itemize{
#'   \item ID. unique ID of growth curve  
#'   \item Row. Row position on 96 well plate
#'   \item Col. Column position on 96 well plate 
#'   \item Strain. bacterial strain descriptor
#'   \item Rep. Replicate
#'   \item ara. conc. of Arabinos
#'   \item tet. conc. of tetracycline
#'   \item OD. Optical density measurement
#'   \item time. time of measurement (min. after start of experiment)
#'   \item ODred. blank corrected OD measurements
#' }
#' 
#' @docType data
#' @keywords datasets, fitr
#' @name growthDataOne
#' @usage data(growthDataOne)
#' @format A data frame with 97 rows and 10 variables
NULL

#' Five growth curve
#' 
#' A dataset containing five growth curve
#''
#' \itemize{
#'   \item ID. unique ID of growth curve  
#'   \item Row. Row position on 96 well plate
#'   \item Col. Column position on 96 well plate 
#'   \item Strain. bacterial strain descriptor
#'   \item Rep. Replicate
#'   \item ara. conc. of Arabinos
#'   \item tet. conc. of tetracycline
#'   \item OD. Optical density measurement
#'   \item time. time of measurement (min. after start of experiment)
#'   \item ODred. blank corrected OD measurements
#' }
#' 
#' @docType data
#' @keywords datasets, fitr
#' @name growthDataFive
#' @usage data(growthDataFive)
#' @format A data frame with 485 rows and 10 variables
NULL