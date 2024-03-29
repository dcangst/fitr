#' Estimate growth rate from growth curve
#'
#' fits a a linear model over a sliding window to growth data. Outputs all fits as a \code{data.frame}
#'
#' @name gcfit
#' @param data long-form data frame with growth data.
#' @param w_size size of sliding window (number of datapoints).
#' @param od_name name of column containing OD values.
#' @param time_name name of column containing times (in units after start of experiment).
#' @param trafo Data transformation, one of \code{"logNN0"} (for log(N/N0) transformation),
#'  \code{"log"} or \code{"none"}.
#' @param logBase Base for logarithmitic transformation if trafo != "none", defaults to 2.
#' @param growthCheck Check whether there was growth at all. One of \code{"none"} (no Check),
#'  \code{"sd2"} (Growth only if difference between minimal and maximal OD is larger than twice
#'  the standard deviation of the blanks).
#' @param blankSD standard deviation of blanks appropriate to this curve, required if
#'  \code{"growthCheck"} = \code{"sd2"}
#' @section Output:
#'    \code{data.frame} of with all fits for all possible windows
#' @keywords fitr, growthcurve
#' @export
gcfit <- function(data,
                  w_size,
                  od_name,
                  time_name,
                  trafo = "log",
                  logBase = 2,
                  growthCheck = "none",
                  blankSD = NA) {
  od_colnr <- which(colnames(data) == od_name)
  time_colnr <- which(colnames(data) == time_name)

  data <- .gcDataTrafo(data, od_colnr, time_colnr, trafo, logBase)

  ### check if enough points are available for fit.
  if (nrow(data) == w_size) {
    numfits <- 1
    okComment <- "ok, just one fit possible"
  } else if (nrow(data) < w_size) {
    numfits <- 1
    w_size <- nrow(data)
    okComment <- "no fits for w_size"
  } else {
    numfits <- (nrow(data) - w_size)
    okComment <- "ok"
  }

  filler <- rep(NA, numfits)

  fits <- data.frame(
    minT = filler,
    maxT = filler,
    numP = filler,
    nTime = filler,
    mumax = filler,
    intercept = filler,
    adj.r.sq = filler,
    dt = filler,
    maxOD = max(data[, od_colnr], na.rm = TRUE),
    minOD = min(data[, od_colnr], na.rm = TRUE),
    trafo = trafo,
    logBase = logBase,
    growth = TRUE,
    comment = filler
  )

  for (i in 1:numfits) {
    data_subset <- data[i:(i + w_size - 1), ]
    numP <- length(na.exclude(data_subset$ODtrans))

    if (numP < 3) {
      fits[i, ]$minT <- min(data_subset[, time_colnr], na.rm = TRUE)
      fits[i, ]$comment <- "< 3 valid points for fit!"
      next
    }
    fit <- lm(data_subset$ODtrans ~ data_subset[, time_colnr], singular.ok = TRUE, na.action = na.exclude)
    fits[i, ]$minT <- min(data_subset[, time_colnr], na.rm = TRUE) # minT
    fits[i, ]$maxT <- max(data_subset[, time_colnr], na.rm = TRUE) # minT
    fits[i, ]$numP <- numP
    fits[i, ]$nTime <- length(data[, time_colnr]) # number of timepoints in growthcurve
    fits[i, ]$mumax <- fit$coefficients[[2]] # mumax
    fits[i, ]$intercept <- fit$coefficients[[1]] # intercept
    fits[i, ]$adj.r.sq <- summary(fit)$adj.r.squared # adjusted R squared of fit
    fits[i, ]$dt <- log(2, logBase) / fit$coefficients[[2]] # dt
    fits[i, ]$comment <- okComment # comment
  }

  ### check for growth if desired

  if (growthCheck == "sd2") {
    if (is.numeric(blankSD) == FALSE) {
      stop("no / not numeric standard deviation for blanks provided.")
    }
    fits$growth <- max(data[, od_colnr], na.rm = TRUE) - abs(min(data[, od_colnr], na.rm = TRUE)) > 2 * blankSD
  }

  return(fits)
} # fn:gcfit

#' pick best fits
#'
#' pick the 'most valid' fit. This will be the fit with the highest mumax and an adjusted
#'  R squared above \code{RsqCutoff}
#'
#' @name pickfit
#' @param fits \code{data.frame} containing fits generated by \code{\link{gcfit}}
#' @param min_numP minimum number of points for fit
#' @param RsqCutoff Only fits with an adjusted R squared (see \code{\link{summary.lm}}) higher than the
#'  cutoff are considered. Defaults to 0.95.
#' @section Output:
#'    \code{data.frame} best fits.
#' @keywords fitr, growthcurve
#' @export
pickfit <- function(fits,
                    min_numP,
                    RsqCutoff = 0.95,
                    growthCheck = "none") {
  gc_comment <- ""

  fits_rsq <- fits[is.na(fits$adj.r.sq) == FALSE, ]
  if (dim(fits_rsq)[1] == 0) {
    gc_comment <- "a" # "no valid fits "
  }

  fits_numP <- fits_rsq[fits_rsq$numP >= min_numP, ]
  if (dim(fits_numP)[1] == 0) {
    gc_comment <- paste0(gc_comment, "b") # "no fits with",min_numP,"points")
  }

  fits_rsqC <- fits_numP[fits_numP$adj.r.sq >= RsqCutoff, ]
  if (dim(fits_rsqC)[1] == 0) {
    # "no fits with adj.r.sq >=",RsqCutoff," (max=",round(max(fits_numP$adj.r.sq,na.rm=TRUE),5),")")
    gc_comment <- paste0(gc_comment, "c")
  }

  if (growthCheck != "none") {
    fits_growthCheck <- fits_rsqC[fits_rsqC$growth == TRUE, ]
    if (dim(fits_growthCheck[1]) == 0) {
      gc_comment <- paste0(gc_comment, "d") # "no growth (growthCheck)"
    }
  } else {
    fits_growthCheck <- fits_rsqC
  }

  if (gc_comment != "") {
    best <- fits[1, ]
    best[] <- NA
    best$trafo <- fits[1, ]$trafo
    best$logBase <- fits[1, ]$logBase
    best$growth <- fits[1, ]$growth
    best$comment <- gc_comment
    if (grepl("d", gc_comment)) {
      best$mumax <- 0
    }
  } else {
    best <- fits_growthCheck[fits_growthCheck$mumax == max(fits_growthCheck$mumax, na.rm = TRUE), ]
  }

  if (dim(best)[1] > 1) {
    best <- best[1, ]
  }

  best <- .attrErrorCodes(best, min_numP, RsqCutoff, growthCheck)

  return(best)
} # fn:pickfit

#' plot fits generated with gcfit and selected with pickfit
#'
#' plot all fits, or only a selection using the \code{select} argument.
#'
#' @name plot_fitr
#' @param bestfit \code{data.frame} with best fit generated by \code{\link{pickfit}}
#' @param fits \code{data.frame} containing fits generated by \code{\link{gcfit}}
#' @param data long-form data frame with growth data
#' @param od_name name of column containing OD values
#' @param time_name name of column containing times (in units after start of experiment)
#' @param select Either a vector containing IDs of a selection of fits to plot
#'  (IDs not found in \code{data} are quietly ignored), or one of \code{c("sample","sampleQ","failed")}.
#'  \code{"sample"} will draw an uniform sample of size \code{sample_size}.
#'  \code{"sampleQ"} will draw a total (rounded) of \code{sample_size} samples split over growthrate
#'  (mumax) sample quantiles. \code{"failed"} will display fits were no best fit could be selected.
#'  Defaults to \code{FALSE}, showing all fits.
#' @param sample_size Size of sample to draw, defaults to the arbitrary number of 5
#' @param interactive boolean; Should every plot be shown? Advance to next plot by clicking in plot area.
#' @section Output:
#'    none
#' @keywords fitr, growthcurve
#' @export
plot_fitr <- function(
    bestfit,
    fits,
    data,
    od_name,
    time_name, interactive = TRUE, select = FALSE, sample_size = 5, save = FALSE) {
  od_colnr <- which(colnames(data) == od_name)
  time_colnr <- which(colnames(data) == time_name)

  data <- data[with(data, order(data[, time_colnr])), ]

  ### single growth curve
  if (class(fits) == "data.frame") {
    fits <- list(fits)
    attr(fits, "split_labels") <- data.frame(ID = data$ID[1])
    bestfit$ID <- data$ID[1]
    data$ID <- data$ID[1]
    interactive <- FALSE
  }

  ### Selection
  if (is.logical(select)) {
    IDs <- sort(unique(data$ID))
  } else {
    if (select[1] == "sample") {
      cat("Selecting ", sample_size, " (", sample_size / length(bestfit$ID), "%) samples...", "\n", sep = "")
      samples <- sample(bestfit$ID, sample_size)
      cat("Selected IDs for plotting: ", paste0(samples, collapse = ", "), "\n", sep = "")
      data <- subset(data, ID %in% samples)
      bestfit <- subset(bestfit, ID %in% samples)
      IDs <- sort(unique(data$ID))
    } else if (select[1] == "failed") {
      failed <- subset(bestfit, comment != "ok")
      select <- sort(failed$ID)
      cat("Selecting failed fits... (", length(select), " of ", length(bestfit$ID), ", ",
        length(select) / length(bestfit$ID), "%)", "\n", sep = "")
      data <- subset(data, ID %in% select)
      bestfit <- subset(bestfit, ID %in% select)
      IDs <- sort(unique(data$ID))
    } else if (select[1] == "sampleQ") {
      quantiles <- boxplot.stats(bestfit$mumax)$stats
      minID <- na.omit(bestfit$ID[bestfit$mumax == quantiles[1]])
      maxID <- na.omit(bestfit$ID[bestfit$mumax == quantiles[5]])
      lowIDs <- sample(
        na.omit(bestfit$ID[bestfit$mumax > quantiles[1] & bestfit$mumax < quantiles[2]]),
        ceiling((sample_size - 2) / 3))
      meanIDs <- sample(
        na.omit(bestfit$ID[bestfit$mumax > quantiles[2] & bestfit$mumax < quantiles[4]]),
        ceiling((sample_size - 2) / 3))
      highIDs <- sample(
        na.omit(bestfit$ID[bestfit$mumax > quantiles[4] & bestfit$mumax < quantiles[5]]),
        ceiling((sample_size - 2) / 3))
      cat("Selected IDs for plotting: ", "\n", sep = "")
      cat("Min: ")
      cat(paste0(as.vector(minID), collapse = ", "), "\n")
      cat("low sample (below 1st quantile): ")
      cat(paste0(lowIDs, collapse = ", "), "\n")
      cat("mean sample (btw. 1st & 3rd quantile): ")
      cat(paste0(meanIDs, collapse = ", "), "\n")
      cat("high sample (above 3rd quantile): ")
      cat(paste0(highIDs, collapse = ", "), "\n")
      cat("Max: ")
      cat(paste0(as.vector(maxID), collapse = ", "), "\n")
      samples <- c(as.vector(minID), as.vector(lowIDs), as.vector(meanIDs), as.vector(highIDs), as.vector(maxID))
      data <- subset(data, ID %in% samples)
      bestfit <- subset(bestfit, ID %in% samples)
      IDs <- unique(data$ID)
    } else {
      cat("Selected IDs for plotting: ", paste0(select, collapse = ", "), "\n", sep = "")
      data <- subset(data, ID %in% select)
      bestfit <- subset(bestfit, ID %in% select)
      IDs <- sort(unique(data$ID))
    }
  }

  nFits <- dim(bestfit)[1]

  if (nFits != length(IDs)) {
    stop("unequal dimensions of data and fits")
  }

  data <- .gcDataTrafo(data, od_colnr, time_colnr, bestfit$trafo[1], bestfit$logBase[1])

  y_limits <- c(min(data$ODtrans, na.rm = TRUE), max(data$ODtrans, na.rm = TRUE))
  x_limits <- c(min(data[, time_colnr], na.rm = TRUE), max(data[, time_colnr], na.rm = TRUE))

  print(x_limits)
  print(y_limits)

  for (i in 1:nFits) {
    data_sub <- subset(data, ID == IDs[i])
    fits_sub <- fits[[as.numeric(rownames(subset(attr(fits, "split_labels"), ID == IDs[i])))]]
    bestfit_sub <- subset(bestfit, ID == IDs[i])

    yName <- paste0("log", bestfit_sub$logBase, " OD")

    if (interactive) {
      cat("Fit ", i, " of ", nFits, " (ID = ", IDs[i], "). ", bestfit_sub$comment,
      ". Click in plot area for next plot.", "\n", sep = "")
    }

    if (bestfit_sub$comment != "ok") {
      if (save) {
        pdf(paste0(IDs[i], ".pdf"))
      }
      par(mfrow = c(2, 1))
      plot(data_sub[, time_colnr], data_sub$ODtrans,
        xlab = "time", ylab = yName, type = "b", main = bestfit_sub$ID, ylim = y_limits, xlim = x_limits)
      legend("bottomright", legend = bestfit_sub$comment, xjust = 0.5, title = "no best Fit:", text.col = "red")
      plot(1, 1)
      if (save) {
        dev.off()
      }
      if (interactive) {
        locator(1)
      }
      next
    }

    pointcols <- as.numeric(!(data_sub[, time_colnr] >= bestfit_sub$minT & data_sub[, time_colnr] <= bestfit_sub$maxT))
    pointcols[pointcols == 0] <- 51
    if (save) {
      pdf(paste0(IDs[i], ".pdf"))
    }
    par(mfrow = c(2, 1))

    plot(data_sub[, time_colnr], data_sub$ODtrans,
      xlab = "time", ylab = yName, type = "b", main = bestfit_sub$ID,
      col = pointcols, ylim = y_limits, xlim = x_limits)
    abline(a = bestfit_sub$intercept, b = bestfit_sub$mumax, col = "red")

    printParams <- paste(
      c("intercept =", "mumax =", "dt =", "Pears. R ="),
      signif(c(bestfit_sub$intercept, bestfit_sub$mumax, bestfit_sub$dt, bestfit_sub$adj.r.sq), 4)
    )
    legend("bottomright", legend = printParams, xjust = 0.5, title = "Best Fit:")
    color <- .rgbColorGradient(fits_sub$adj.r.sq)
    plot(fits_sub$minT, fits_sub$mumax, col = color, xlab = "sliding window start point", ylab = "mumax")
    legend("topright", legend = "color: adj. R squared")
    points(bestfit_sub$minT, bestfit_sub$mumax, col = "blue", pch = 8, cex = 1.5)
    if (save) {
      dev.off()
    }
    if (interactive) {
      locator(1)
    }
  }
  cat("done.", "\n")
} #  fn:plot_fitr

#' Wrapper function for automated growth curve fitting
#'
#' @name d_gcfit
#' @param data long-form data frame with growth data, must contain column named ID with a unique ID for each curve.
#' @param w_size size of sliding window (number of datapoints considered)
#' @param od_name name of column containing OD values
#' @param time_name name of column containing times (in units after start of experiment)
#' @param trafo Data transformation, one of \code{"logNN0"} (for log(N/N0)), \code{"log"} or \code{"none"}.
#' @param logBase Base for logarithmitic transformation if trafo != "none", defaults to 2.
#' @param min_numP minimum number of points for fit to be acceptable, defaults to \code{"w_size"}
#' @param growthCheck Check whether there was growth at all.
#'  One of \code{"none"} (no Check),
#'  \code{"sd2"} (Growth only if difference between minimal and maximal OD is larger than
#'  twice the standard deviation of the blanks). Requires data of class \code{"fitr_data"}
#' @param RsqCutoff Only fits with a correlation coefficient higher than the cutoff are considered.
#'  Defaults to \code{0.95}.
#' @param parallel if \code{TRUE}, apply function in parallel, using parallel backend provided by
#'  \code{\link[foreach]{foreach}}.
#' @param progress name of the progress bar to use, see \code{\link[plyr]{create_progress_bar}}
#' @param ... additional parameters passed to ply functions.
#' @section Output:
#'    an object of class fitr.
#' @keywords fitr, growthcurve
#' @export
d_gcfit <- function(data, w_size, od_name, time_name,
  trafo = "log", logBase = 2, min_numP = w_size,
  growthCheck = "none", RsqCutoff = 0.95, parallel = FALSE, progress = "text", ...) {
  if (parallel) {
    doParallel::registerDoParallel()
  }

  if ("fitr_data" %in%  class(data)) {
    fits_list <- vector("list", length = dim(data$blanks)[1])
    split_labels_list <- vector("list", dim(data$blanks)[1])

    names(fits_list) <- data$blanks[, 1]
    group_colnr <- which(colnames(data$data) == colnames(data$blanks)[1])

    for (i in 1:dim(data$blanks)[1]) {
      cat(
        "fitting growth curves for",
        colnames(data$blanks)[1], i, "of", dim(data$blanks)[1],
        paste0("(", as.character(data$blanks[i, 1]), ")..."), "\n")
      flush.console()

      data_sub_group <- subset(data$data, data$data[, group_colnr] == data$blanks[i, 1])

      fits_list[[i]] <- plyr::dlply(
        data_sub_group, .(ID), gcfit, w_size = w_size, od_name = od_name,
          time_name = time_name, trafo = trafo, logBase = logBase, growthCheck = growthCheck,
          blankSD = data$blanks$blank_sd[i], .parallel = parallel, .progress = progress, ...)

      split_labels_list[[i]] <- attributes(fits_list[[i]])$split_labels
    }

    fits <- unlist(fits_list, recursive = FALSE)
    attr(fits, "split_labels") <- ldply(split_labels_list, data.frame)
    attr(fits, "split_type") <- "data.frame"
  } else {
    if (growthCheck != "none") {
      stop("growthCheck requires data of class fitr_data, generated with gcblanking()")
    }

    cat("fitting growth curves...", "\n")
    flush.console()
    fits <- plyr::dlply(data, .(ID), gcfit, w_size = w_size, od_name = od_name, time_name = time_name,
      trafo = trafo, logBase = logBase, .parallel = parallel, .progress = progress, ...)
  }

  cat("selecting best fits...", "\n")
  flush.console()
  best <- plyr::ldply(fits, pickfit, min_numP = min_numP, RsqCutoff = RsqCutoff, growthCheck = growthCheck,
    .progress = progress, ...)

  best <- .attrErrorCodes(best, min_numP, RsqCutoff, growthCheck)

  parameter <- data.frame(
    date = Sys.Date(),
    nFits = dim(best)[1],
    w_size,
    od_name,
    time_name,
    trafo,
    logBase,
    RsqCutoff,
    growthCheck,
    stringsAsFactors = FALSE
  )

  out <- list(data = data, fits = fits, bestfits = best, parameter = parameter)
  class(out) <- "fitr"

  return(out)
} # fn:d_gcfit


#' Function for blanking OD data & flagging growth/no growth
#'
#' @name d_gcfit
#' @param data long-form data frame with growth data, must contain column named ID with a unique ID for each curve.
#' @param group name of grouping variable (e.g. plates for which blanks must be seperate), a factor.
#' @param od_name name of column containing OD values
#' @param bl_col name of column containing well description, e.g. "strain"
#' @param bl_name which wells are blanks?, e.g. "bl"
#' @param cutoff discard values <= cutoff
#' @section Output:
#'    long-form data frame with additional columns od_name_bl (blanked OD values) and QCgrowth (logical)
#' @keywords fitr, growthcurve, blanking
#' @export
gcblanking <- function(data, group, od_name, bl_col, bl_name, cutoff = 0) {
  group_colnr <- which(colnames(data) == group)
  od_colnr <- which(colnames(data) == od_name)
  bl_colnr <- which(colnames(data) == bl_col)

  data$newODcolumn <- NA

  blanks <- data.frame(group = levels(data[, group_colnr]), blank = NA, blank_sd = NA)

  groups <- levels(data[, group_colnr])
  curves <- levels(data$ID)

  for (i in 1:length(groups)) {
    blanks$blank[i] <- mean(data[data[, group_colnr] == groups[i] & data[, bl_colnr] == bl_name, od_colnr])
    blanks$blank_sd[i] <- sd(data[data[, group_colnr] == groups[i] & data[, bl_colnr] == bl_name, od_colnr])

    data[data[, group_colnr] == groups[i], ]$newODcolumn <- data[data[, group_colnr] == groups[i], od_colnr] -
      blanks$blank[i]
  }

  data$newODcolumn[data$newODcolumn <= 0] <- NA

  names(data)[names(data) == "newODcolumn"] <- paste0(od_name, "_bl")
  ODbl_colnr <- which(colnames(data) == paste0(od_name, "_bl"))

  names(blanks)[names(blanks) == "group"] <- group

  data_good <- subset(data, data[, bl_colnr] != bl_name & data[, ODbl_colnr] > cutoff)
  data_cutoff <- subset(data, data[, bl_colnr] != bl_name & data[, ODbl_colnr] <= cutoff)
  data_blanks <- subset(data, data[, bl_colnr] == bl_name)


  dataOut <- list(data = data_good, data_blanks = data_blanks, data_cutoff = data_cutoff, blanks = blanks)
  class(dataOut) <- "fitr_data"
  return(dataOut)
} # fn:gcblanking
