#' @name FeatureExtract
#' @title Normalize and extract features for machine learning
#' @import data.table
#' @param x Identified amino acids signal, see also \code{SignalExtract}
#' @export

FeatureExtract <- function(x) {
  basemean <- x[L == "B", mean2(pA)]
  x[, pA := pA / basemean]
  dy <- round(density(x[L != "B", pA], from = 0, to = 1, n = 200, adjust = 1)$y, 3)
  names(dy) <- paste0("X", sprintf("%03d", 1:200))
  attr(dy, "AllTime") <- x[L != "B", diff(range(Time))] * 1000
  attr(dy, "DwellTime") <- x[Sm == x[L != "B", .N, Sm][which.max(N), Sm] & L != "B", diff(range(Time))] * 1000
  attr(dy, "SignalSD") <- x[L != "B", sd2(pA)]
  attr(dy, "Blockade") <- 1 - x[Sm == x[L != "B", .N, Sm][which.max(N), Sm] & L != "B", mean2(pA)]
  return(dy)
}
