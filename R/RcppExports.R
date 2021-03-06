# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

difference <- function(x, y) {
    .Call('_satelliteTools_difference', PACKAGE = 'satelliteTools', x, y)
}

isNA <- function(x) {
    .Call('_satelliteTools_isNA', PACKAGE = 'satelliteTools', x)
}

naOmit <- function(x) {
    .Call('_satelliteTools_naOmit', PACKAGE = 'satelliteTools', x)
}

whichMin <- function(x) {
    .Call('_satelliteTools_whichMin', PACKAGE = 'satelliteTools', x)
}

barometricFormula <- function(z, gp, ta, p) {
    .Call('_satelliteTools_barometricFormula', PACKAGE = 'satelliteTools', z, gp, ta, p)
}

run_barometricFormula <- function(a, b, dem, p) {
    .Call('_satelliteTools_run_barometricFormula', PACKAGE = 'satelliteTools', a, b, dem, p)
}

mSpecIndicesCPP <- function(blue, green, red, nir) {
    .Call('_satelliteTools_mSpecIndicesCPP', PACKAGE = 'satelliteTools', blue, green, red, nir)
}

