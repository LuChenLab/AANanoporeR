#' @name Predict
#' @title Predict the amino acids of signal
#' @param x Features of signal.
#' @param model Trained model.
#' @export

Predict <- function(x, model) {
  dat <- t(rbind(data.frame(x = x, row.names = names(x)),
                 data.frame(x = c(attr(x, "AllTime"), attr(x, "DwellTime"), attr(x, "SignalSD"), attr(x, "Blockade")),
                            row.names = c("AllTime", "DwellTime", "SignalSD", "Blockade"))))
  predict(model, dat, type = "prob")
}
