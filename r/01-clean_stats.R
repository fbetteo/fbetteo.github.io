# clean player-season stats:
  # keep players with >400 min
  # keep season >1990


# Notas:
# Year es year del final de la temporada. Ej year=2017 es season 2016-2017

# Parametros
mp_filter <- 1 # filtro de minutos jugados
primer_año <- 1991 # temporada 1990-1991


source("libraries.r")
source("functions/generic.r")


raw_stats <- readRDS("data/working/raw_stats.RDS")

# Basic
raw_stats2 <- raw_stats %>%
  janitor::clean_names() %>%  # kawabonga
  select(-c(x1, blanl, blank2)) %>%
  dplyr::filter(year >=  primer_año) %>%
  mutate_at(dplyr::vars(g:pts), as.numeric)

# Stats de toda la temporada para aquellos que cambian de equipo
# (keep only tm=="TOT" row)
# Cuando mergeamos ponemos el nombre del equipo que figura en Salary?
totales <- raw_stats2 %>%
  dplyr::filter(tm == "TOT")

multi_equipo <- raw_stats2 %>%
  group_by(year, player) %>%
  summarise(equipos = n()) %>%
  dplyr::filter(equipos > 1) %>%
  select(-equipos) %>%
  ungroup()

stats_clean <- raw_stats2 %>%
  anti_join(x = ., y = multi_equipo, by = c("year" = "year", "player" = "player")) %>%
  rbind.data.frame(., totales) %>%
  rename(season = year)

# Remuevo asterico de algunos nombres (Hall of Fame?)
stats_clean <- stats_clean %>%
  mutate(player2 = str_remove(player, "\\*")) %>%
  dplyr::filter(mp > mp_filter) %>%
  select(-player) %>%
  rename(player = player2)


# new stats ---------------------------------------------------------------

vars_cum = c("g", "gs", "mp", "x3p", "x3pa", "x2p", "x2pa",
         "ft","fta", "orb", "drb", "trb", "ast", "stl", "blk", "tov",
         "pf", "pts")

stats_clean = stats_clean %>%
  # per 48 minutes
  mutate_at(dplyr::vars(x3p,x3pa,x2p,x2pa,ft,fta,orb,drb,trb,ast,stl,blk,tov,pf,pts),
            list(per48 = function(x) x*(48/.$mp)
                 ,perg = function(x) x/.$g
            )) %>%
  # cumulative sums in last 3 seasons
  group_by(player) %>% arrange(player,-season) %>%
  mutate_at(vars_cum, list(
    cum1 = function(x) RcppRoll::roll_sum(x,1,align="left",fill=NA)
    ,cum2 = function(x) RcppRoll::roll_sum(x,2,align="left",fill=NA)
    ,cum3 = function(x) RcppRoll::roll_sum(x,3,align="left",fill=NA)
  )) %>%
  ungroup()
# replace NAs in cum3 (replace escalonado cum2-cum1)
for (v in (vars_cum)) {
  stats_clean[[v%+%"_cum3"]] = Reduce(coalesce, stats_clean[v%+%"_cum"%+%3:1])
}
# cum3 per48 + cum3 perg + seasons inactive cum
stats_clean = stats_clean %>%
  select(-ends_with("cum1")) %>%
  select(-ends_with("cum2")) %>%
  mutate_at(dplyr::vars(x3p_cum3,x3pa_cum3,x2p_cum3,x2pa_cum3,ft_cum3,fta_cum3,orb_cum3,
                 drb_cum3,trb_cum3,ast_cum3,stl_cum3,blk_cum3,tov_cum3,pf_cum3,
                 pts_cum3),
            list(per48 = function(x) x*(48/.$mp_cum3)
                ,perg = function(x) x/.$g_cum3)
            ) %>%
  # drop cum3 totals (except for g, gs, mp)
  select(-c(vars_cum[!vars_cum %in% c("g","gs","mp")] %+% "_cum3")) %>%
  # seasons inactive in league cumulative
  group_by(player) %>% arrange(player,season) %>%
  mutate(inactive = (season-dplyr::lag(season)>1) %>% replace_na(F)
         ,inactive_cum = cumsum(inactive)) %>%
  ungroup() %>% select(-inactive)


# save --------------------------------------------------------------------

rdsinpath(stats_clean, "data/working/")
