
# "usual" libraries and "proj" libraries ---------------------------------------
# usual libraries are not explicitely called
lib_usual <- c(
  "magrittr",
  "purrr",
  #"conflicted",
  "ggplot2",
  "dplyr",
  "stringr",
  "broom",
  "knitr",
  "readr",
  "kableExtra",
  "rmarkdown",
  "DT",
  "lubridate",
  "tidyr"
)
lib_proj <- c(
  "rvest"
  , "janitor"
  , "RcppRoll"
  , "gridExtra"
  , "energy"
  , "gratia"
  , "mgcv"
)

# no tocar ----------------------------------------------------------------
pack <- c(lib_usual, lib_proj)
for (i in seq_along(pack)) {
  if (!(pack[i] %in% installed.packages()[,1])) {
    install.packages(pack[i], quiet=T, verbose=F,
                     repos="http://cran.us.r-project.org")
  }
  if (pack[i] %in% lib_usual) library(pack[i],character.only=T
                                      , quietly=T,warn.conflicts=F,verbose=F
                                      )
}
rm(pack, lib_usual, lib_proj)
