# fit GAM model

source("libraries.r")
source("functions/generic.r")

source("functions/gam.r")

# notes -------------------------------------------------------------------

# loosely based on:
# https://miro.medium.com/max/754/1*snTXFElFuQLSFDnvZKJ6IA.png


# read data ---------------------------------------------------------------

base_mod <- readRDS("data/working/base_mod.rds")


# vars to model -----------------------------------------------------------

# target variable
df_mod = base_mod %>%
  rename(target = w_2018_t1)


# scope predictors (with enough variability to be smoothed)
vars_to_scope <- df_mod %>%
  select(age
    ,season_t1
    # ,ends_with("percent")
    ,ends_with("_perg")
    ,inj_out_cum
    ,disc_tot_cum
    # ,per
    ,f_tr
     ) %>%
  names()

# dummy predictors (without enough variability to be smoothed)
dummy_vars <- df_mod %>% select(inactive_cum) %>%
  names()


# model formula
form_mod = as.formula("target" %+% " ~ " %+%
              paste(dummy_vars, collapse=" + ") %+% " + " %+%
              paste0("s(",vars_to_scope,")", collapse=" + "))



# fit model ---------------------------------------------------------------

# fit
library(mgcv)
fit0 <- gam(form_mod , data = get("df_mod"), method = "REML")

# quality of fit
# summary(fit0)
# par(mfrow = c(2,2))
# mgcv::gam.check(fit0)


# save model and model data ---------------------------------------------------------------

saveRDS(fit0, "data/working/fit0.rds")
rdsinpath(df_mod, path="data/working/")


# OLD ---------------------------------------------------------------------


#tic("gaussian")
# fit0 <- mgcv::gam(formulas_var2 , data = get("base_mod"), method = "REML")
#toc(log = TRUE)


# EL BULTO
# tambien esta mgcv:: que dicen es mas detallada.
# install.packages("gam")
# install.packages("mgcv")
# install.packages("tictoc")


# NOT USED.
# Lo dejo por las duaas
# Esto es para libereria GAM
# necesitas una lista de formulas
# con las distintos Degrees of Freedom que querés probar
# lo hice cabeza

#scope_list <- function(x){
#
#  x <- as.formula(paste0("~1", "+",x,"+","s(",x,", df=3) + s(",x,", df = 4) + s(",x,", df = 5)" ))
#  return(x)
#}

# NOT USED.
# Lo dejo por las duaas
# Esto es para libereria GAM
# lista con formato

#scope_gam <- map(vars_to_scope,.f = scope_list) %>%
#  setNames(vars_to_scope)


# * MODEL *
# usé para GAM: https://medium.com/@muscovitebob/small-guide-to-the-step-gam-9769ef0e7a26
# para MGCV: https://people.maths.bris.ac.uk/~sw15190/mgcv/tampere/mgcv.pdf
# https://multithreaded.stitchfix.com/blog/2015/07/30/gam/

# otros modelos sin mucho exito
# tic("gamma")
# fit0 <- mgcv::gam(formulas_var2, data = df_mod_na_min, family = Gamma)
# toc(log = TRUE)
# ?gam
#
# tic("invgaussian")
# fit2 <- mgcv::gam(formulas_var2, data = df_mod_na_min, family = inverse.gaussian)
# toc()
#
#
# tic("fitbam")
# fitbam <-  mgcv::bam(formulas_var2, data = df_mod_na, family = gaussian)
# toc()
#
#
# tic("baminvgaussian")
# fitbam2 <- mgcv::bam(formulas_var2, data = df_mod_na, family = inverse.gaussian)
# toc()
#
