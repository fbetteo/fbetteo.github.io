
source("libraries.r")
source("functions/generic.r")


# read --------------------------------------------------------------------

raw_salaries <- readRDS("data/working/raw_salaries.RDS")


# clean -------------------------------------------------------------------


# sum(Salario) by season for players with more than one team
totales <- raw_salaries %>%
  group_by(season, player) %>%
  summarise(salary_tot = sum(salary, na.rm = TRUE))

# keep team with min(Salario) by season for  players with more than one team 
equipo_final <- raw_salaries %>%
  group_by(season, player) %>%
  summarise(minimo = min(salary,na.rm = TRUE)) %>% 
  inner_join(x =., y=raw_salaries,
             by = c("season"="season", "player"="player", "minimo"="salary")) %>%
  # keep random obs when min(salary) is repeated by player (7 obs) 
  distinct(season,player, minimo,.keep_all = TRUE) %>% 
  select(-minimo)

# clean salaries
salaries_clean <- totales %>%
  inner_join(x = ., y = equipo_final,
             by = c("season"="season", "player"="player")) %>%
  rename(., salary = salary_tot) %>%
  ungroup() %>% 
  # keep 2nd year of season as season
  mutate(season = str_sub(season,1,4) %>% as.numeric() %>% "+"(1)) %>%
  # remove NA
  dplyr::filter(complete.cases(.))



# save --------------------------------------------------------------------

rdsinpath(salaries_clean, "data/working/")



