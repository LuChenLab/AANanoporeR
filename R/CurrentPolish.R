#' @name CurrentPolish
#' @title Read and polish raw current
#' @import data.table
#' @importFrom readABF readABF
#' @param file The path of .ABF file.
#' @param TimeStart,TimeEnd The start and end of signal time (s) of ABF file.
#' @param voltage The expement voltage.
#' @export

CurrentPolish <- function(file, TimeStart, TimeEnd, voltage = 50, MaxCurrent = 130) {
  abf <- readABF::readABF(file)
  abf <- data.table::as.data.table(as.data.frame(abf))
  colnames(abf) <- c("Time", "pA", "mV")
  abf <- abf[Time > TimeStart * 60 & Time < TimeEnd * 60, ]

  abf <- abf[round(mV) == voltage, ]
  abf <- abf[pA > 0 & pA <= MaxCurrent, ]
  abf$Sm <- KBins2(sig = abf$pA, pen.value = 1 - 1e-16, minseglen1 = 1, minseglen2 = 1)
  return(abf)
}
