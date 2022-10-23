#' @name SignalExtract
#' @title Extract signal from polished current
#' @import data.table
#' @importFrom S4Vectors Rle runLength
#' @param object The result of function `CurrentPolish`.
#' @param L0Min,L0Max,L1Min,L1ax The default range of L0 and L1 signal level.
#' @param MinDwellTime The minimum dwell time for signal filtering.
#' @export

SignalExtract <- function(object, L0Min = NA, L0Max = NA, L1Min = NA, L1Max = NA, MinDwellTime = 0.00075) {
  if(anyNA(c(L0Min, L0Max, L1Min, L1Max))) stop()
  # BUB
  object[Sm <= L0Max & Sm >= L0Min, L := "B"] # baseline
  object[Sm < L1Max, L := "U"] # U shape
  object[is.na(L), L := "O"] # Other

  BUB <- BUB_Sig(Mat = object)
  BUB <- BUB[mapply(function(x) max(x$Sm), BUB) <= L0Max]

  # Baseline length filtering
  BL_Sum <- mapply(BUB, FUN = function(x) sum(S4Vectors::runLength(S4Vectors::Rle(x[, L == "B"]))[S4Vectors::runValue(S4Vectors::Rle(x[, L == "B"])) == TRUE]))
  BL_Min <- mapply(BUB, FUN = function(x) min(S4Vectors::runLength(S4Vectors::Rle(x[, L == "B"]))[S4Vectors::runValue(S4Vectors::Rle(x[, L == "B"])) == TRUE]))
  BUB <- BUB[BL_Sum >= 500 & BL_Min >= 50]

  # Time filtering
  Wid <- mapply(BUB, FUN = function(x) x[L == "U", diff(range(Time))])
  BUB <- BUB[Wid >= MinDwellTime]
  return(BUB)
}



#' @import ggplot2
#' @export
SigPlot <- function(x) {
  ggplot() +
    geom_line(data = x, aes(x = Time, y = pA)) +
    geom_line(data = x, aes(x = Time, y = Sm), colour = "red") +
    theme_bw(base_size = 15) +
    labs(y = "Current (pA)")
}

