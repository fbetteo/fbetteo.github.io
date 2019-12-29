# Get partial effects from model

source("libraries.r")
source("functions/generic.r")

source("functions/gam.r")


# notes -------------------------------------------------------------------

# Calculate effect on Y and the confidence interval
# Currently two functions but "partial effect" may be deprecated
# 'Confidence Gam' seems to get to the same point much easier.

# We only get effects of smoothed predictors!!!  :(

# read model and feature descriptions ------------------------------------------

desc = read_csv("resources/vardesc.csv", col_types=cols())

library(mgcv)
fit0 <- readRDS("data/working/fit0.rds")



# get effects -------------------------------------------------------------

# parameter: num vars to show
num_vars = 8

# Variables a obtener el efecto parcial
vars_to_model <- (fit0$formula %>% str_split("\\+"))[[3]] %>% str_squish() %>%
  str_match("s\\((.+)\\)") %>% "["(,2) %>% "["(!is.na(.))

# names of top significant predictors (removing some of them)
signif_vars = fit0 %>% tidy() %>%
  dplyr::filter(!term %in% c(
    "s(season_t1)"
    ,"s(disc_tot_cum)"
    ,"s(inj_out_cum)"
  )) %>%
  arrange(p.value) %>% head(num_vars) %$% term %>%
  str_match("s\\((.+)\\)") %>% "["(,2)

library(gratia)
effects <- map(vars_to_model, .f=confidence_gam, modelo=fit0) %>%
  bind_rows() %>%
  mutate(x=value
        , lower=lower/1e6
        , upper=upper/1e6
        , y=est/1e6) %>%
  select(-value, -est) %>%
  # keep signif_vars
  dplyr::filter(variable %in% signif_vars) %>%
  # merge with descriptions
  left_join(desc, by=c("variable")) %>%
  # replace variable with description
  mutate(variable = coalesce(description,variable)) %>%
  arrange(variable, x)


# save effects.csv --------------------------------------------------------

# rdsinpath(data_to_js, path="data/working/")
# write.csv(data_to_js, "data_to_js.csv", row.names = FALSE)
write.csv(effects, "site/data/effects.csv", row.names = FALSE)



# OLD ---------------------------------------------------------------------

# check
# confidence_gam("pts_cum3_per48", fit0)

## CHECKS (BORRAR)
# par(mfrow = c(1,3))
# walk(.x = vars_to_model, .f = partial_effect, modelo = fitchart)

# partial_effect("k", fitchart)
# partial_effect("pts_cum3_per48", fit0)

# plot(fit0)
################
