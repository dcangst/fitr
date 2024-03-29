% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lFitFunctions.R
\name{gcfit}
\alias{gcfit}
\title{Estimate growth rate from growth curve}
\usage{
gcfit(
  data,
  w_size,
  od_name,
  time_name,
  trafo = "log",
  logBase = 2,
  growthCheck = "none",
  blankSD = NA
)
}
\arguments{
\item{data}{long-form data frame with growth data.}

\item{w_size}{size of sliding window (number of datapoints).}

\item{od_name}{name of column containing OD values.}

\item{time_name}{name of column containing times (in units after start of experiment).}

\item{trafo}{Data transformation, one of \code{"logNN0"} (for log(N/N0) transformation),
\code{"log"} or \code{"none"}.}

\item{logBase}{Base for logarithmitic transformation if trafo != "none", defaults to 2.}

\item{growthCheck}{Check whether there was growth at all. One of \code{"none"} (no Check),
\code{"sd2"} (Growth only if difference between minimal and maximal OD is larger than twice
the standard deviation of the blanks).}

\item{blankSD}{standard deviation of blanks appropriate to this curve, required if
\code{"growthCheck"} = \code{"sd2"}}
}
\description{
fits a a linear model over a sliding window to growth data. Outputs all fits as a \code{data.frame}
}
\section{Output}{

   \code{data.frame} of with all fits for all possible windows
}

\keyword{fitr,}
\keyword{growthcurve}
