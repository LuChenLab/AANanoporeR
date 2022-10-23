#' @name LevelIdentify
#' @title Signal level identify
#'
#' @importFrom testthat %>%
#' @import data.table
#' @import plotly
#' @param object The result of function `CurrentPolish`.
#' @param L0Min,L0Max,L1Min,L1ax The default range of L0 and L1 signal level.
#'
#' @export

LevelIdentify <- function(object, L0Min = NA, L0Max = NA, L1Min = NA, L1Max = NA) {
  if(anyNA(c(L0Min, L0Max))) {
    print("We need identify the baseline from data.")
    pA <- object[, pA]
    pADen <- do.call(rbind, lapply(1:10/4, function(i) {
      d <- density(pA, adjust = i, n = 1024)
      data.table::data.table(x = d$x, y = d$y, adjust = i)
    }))

    tx <- highlight_key(pADen)
    widgets <- bscols(
      widths = c(12),
      filter_select("adjust", "Adjust", tx, ~ adjust, multiple = F)
    )
    print(bscols(widths = c(2, 8), widgets, plot_ly(tx, x = ~ x, y = ~ y, showlegend = FALSE) %>%
                   add_lines(color = ~ adjust, colors = "black", showlegend = FALSE)))

    # askYesNo(msg = "Record the range of base lines and continue?")

    adjust <- readline("The adjust: ")
    adjust <- as.numeric(adjust)

    L0Min <- readline("The minimum of baseline(pA): ")
    L0Min <- as.numeric(L0Min)

    L0Max <- readline("The maximum of baseline(pA): ")
    L0Max <- as.numeric(L0Max)

    DenSm <- density(object[, pA], adjust = adjust)

    L0 <- c(L0Min, L0Max)
    L0Min <- abf[pA > L0Min & pA < L0Max, median(Sm)] * 0.9

    plot(DenSm, xlab = "Current (pA)", main = "density of current")
    abline(v = L0, lty = 2, col = 2)
    abline(v = L0Min, lty = 2, col = 3)
    askYesNo(msg = "Continue?")
  }

  if(anyNA(c(L1Min, L1Max))) {
    print("Now, we need identify the L1 from data.")
    pA <- abf[Sm < max(L0) * 0.9 & Sm > 50, pA]

    pADen <- do.call(rbind, lapply(1:10/10, function(i) {
      d <- density(pA, adjust = i, n = 1024)
      data.table(x = d$x, y = d$y, adjust = i)
    }))

    pADen$x2 <- abf[pA > L0Min & pA < L0Max, median(Sm)] * c(1 - L1min)
    pADen$x3 <- abf[pA > L0Min & pA < L0Max, median(Sm)] * c(1 - L1max)
    tx <- highlight_key(pADen)
    widgets <- bscols(
      widths = c(12),
      filter_select("adjust", "Adjust", tx, ~ adjust, multiple = F)
    )

    print(bscols(widths = c(2, 8), widgets, plot_ly(tx, x = ~ x, y = ~ y, showlegend = FALSE) %>%
                   add_lines(color = ~ adjust, colors = "black", showlegend = FALSE) %>%
                   add_lines(x = ~ x2) %>%
                   add_lines(x = ~ x3)))

    pd <- select.list(choices = c("YES", "NO"), title = "The theoretical value is OK?")
    if(pd == "YES") {
      L1Min <- abf[pA > L0Min & pA < L0Max, median(Sm)] * c(1 - L1max)
      L1Max <- abf[pA > L0Min & pA < L0Max, median(Sm)] * c(1 - L1min)
    } else {
      L1Min <- readline("The minimum of L1(pA): ")
      L1Min <- as.numeric(L1Min)

      L1Max <- readline("The maximum of L1(pA): ")
      L1Max <- as.numeric(L1Max)
    }
  }
  res <- data.table(L0Min = L0Min, L0Max = L0Max, L1Min = L1Min, L1Max = L1Max)
  return(res)
}



