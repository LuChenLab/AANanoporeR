
#' @name Internal
#' @title Internal
#' @concept Internal
#' @import data.table
#' @importFrom changepoint cpt.mean nseg seg.len cpt.meanvar

KBins2 <- function(sig, minseglen1 = 100, minseglen2 = 10, pen.value = 1e-3) {
  ansmean1 <- suppressWarnings(changepoint::cpt.mean(sig, penalty = "MBIC", method = "PELT", minseglen = minseglen1))
  Tab1 <- data.table::data.table(P = sig, B1 = rep(seq_len(changepoint::nseg(ansmean1)), changepoint::seg.len(ansmean1)))
  Tab2 <- Tab1[, .(P = median(P)), by = "B1"]

  ansmean2 <- suppressWarnings(changepoint::cpt.meanvar(Tab2[, P], penalty = "Asymptotic", pen.value = pen.value, method = "PELT", minseglen = minseglen2))
  Tab2[, B := rep(seq_len(changepoint::nseg(ansmean2)), changepoint::seg.len(ansmean2))]
  res <- merge(Tab1, Tab2[, .(B1, B)], by = "B1")
  res[, B1 := NULL]
  res[, .(P = median(P), N = .N), "B"][, rep(P, N)]
}


#' @name Internal
#' @title Internal
#' @concept Internal
mean2 <- function(x, q1 = 0.25, q2 = 0.75) {
  q <- quantile(x, c(q1, q2))
  mean(x[x > min(q) & x < max(q)])
}

#' @name Internal
#' @title Internal
#' @concept Internal
sd2 <- function(x, q1 = 0.1, q2 = 0.9) {
  q <- quantile(x, c(q1, q2))
  sd(x[x > min(q) & x < max(q)])
}

#' @name Internal
#' @title Internal
#' @concept Internal
#' @import IRanges
#' @importFrom S4Vectors Rle mcols runValue
#' @importFrom IRanges IRanges start end width
BUB_Sig <- function(Mat, LB = 2000) {
  LRle <- S4Vectors::Rle(Mat[, L])
  LRg <- IRanges::IRanges(IRanges::start(LRle), IRanges::end(LRle))
  S4Vectors::mcols(LRg)$L <- S4Vectors::runValue(LRle)

  LRleVa <- paste0(S4Vectors::runValue(LRle), collapse = "")
  allcombn <- c("BUB", "BOUB", "BUOB", "BOUOB")

  BUB <- lapply(allcombn, function(x) gregexpr(x, LRleVa)[[1]])
  BUB <- BUB[!mapply(function(x) all(x == -1), BUB)]

  BUB <- lapply(BUB, function(x) {
    start <- as.numeric(x)
    steps <- unique(attr(x, "match.length"))
    lapply(start, function(x) {
      rgs <- LRg[x:(x + steps - 1)]

      if(IRanges::width(rgs)[1] > LB) {
        IRanges::start(rgs)[1] <- IRanges::end(rgs)[1] - LB
      }

      if(IRanges::width(rgs)[steps] > LB) {
        IRanges::end(rgs)[steps] <- IRanges::start(rgs)[steps] + LB
      }
      Mat[IRanges::start(range(rgs)):IRanges::end(range(rgs)), ]
    })
  })
  BUB <- do.call(c, BUB)

  Wid <- mapply(BUB, FUN = function(x) x[L == "U", diff(range(Time))])
  BUB <- BUB[Wid < quantile(Wid, 0.95) & Wid > quantile(Wid, 0.05)]
  BUB
}
















