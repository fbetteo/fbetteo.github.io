# get residuals from fitted GAM model

source("libraries.r")
source("functions/generic.r")

source("functions/gam.r")


# get model and model data --------------------------------------------------

library(mgcv)
fit0 <- readRDS("data/working/fit0.rds")
df_mod <- readRDS("data/working/df_mod.rds")


# get residuals -----------------------------------------------------------


residuals <- fit0 %>%
  broom::augment() %>%
  bind_cols(df_mod %>% select(player, team_t1, season_t1)) %>%
  mutate(fitted = .fitted/1e6,
         residual = .resid/1e6,
         actual = target/1e6,
         season = season_t1,
         team = team_t1) %>%
  # vars to export to csv
  select(
    player, team, season
    ,fitted, actual, residual, actual
  )

residuals_top <- residuals %>%
  arrange(desc(residual)) %>%
  head(10) %>%
  mutate(id = player %+% " (" %+% season %+% ")")

residuals_bottom <- residuals %>%
  arrange(residual) %>%
  head(10) %>%
  mutate(id = player %+% " (" %+% season %+% ")")


# save residuals.csv -----------------------------------------------------------

# write.csv(resid_to_js, "resid_to_js.csv", row.names = FALSE)
write.csv(residuals, "site/data/residuals.csv", row.names=FALSE)
write.csv(residuals_top, "site/data/residuals_top.csv", row.names=FALSE)
write.csv(residuals_bottom, "site/data/residuals_bottom.csv", row.names=FALSE)
