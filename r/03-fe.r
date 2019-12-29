# feature engineering (salaries and features)

source("libraries.r")
source("functions/generic.r")

# notas -------------------------------------------------------------------

# NAs remain because of no events, no 3p attempted, no ft attempted
# per48 y pergame calculado en stats_clean junto con stats acumuladas en last 3 seasons
# en seccion de drop features elegir que dropear!!!!


# read --------------------------------------------------------------------

req_files = list.files("data/working/", full.names=T) %>%
  "["(str_detect(.,"base|cpi|cap"))
walk(req_files, objfromrds)


# new/modified features ------------------------------------------------------------

base_fe = base %>%
  mutate(
    # cumulative legal/personal issues
    legpers_cum = leg_tot_cum + pers_tot_cum
    # cumulative injuries (not out-of-season)
    , inj_cum = inj_dnp_cum + inj_dtd_cum + inj_other_cum
    # team as factor
    ,team = as.factor(team)
  )


# drop features ----------------------------------------------------------------

# features to drop:
vars_drop = c(
  # Comb lineal de 2p y 3p
  "fg","fga"
  # too advanced
  ,"ows","dws","ws","ws_48","obpm","dbpm","bpm","vorp"
  # ,"per"
  # redundant injuries
  ,"inj_dnp_cum","inj_dtd_cum","inj_other_cum","inj_cause_other"
  ,"inj_cause_other_cum","inj_cause_rest","inj_dnp_cum","inj_dtd","inj_dtd_cum"
  ,"inj_other","inj_other_cum","inj_out","inj_tot","inj_tot_cum","inj_dnp"
  # redundant legal/personal
  ,"leg_tot_cum","pers_tot_cum","pers_tot","leg_tot"
  # redundant disciplinary
  ,"disc_fines","disc_other","disc_other_cum","disc_susps","disc_tot"
  # redundant stats (totals)
  ,"x3p","x3pa","x2p","x2pa","ft","fta","orb","drb","trb","ast","stl","blk"
  ,"tov","pf","pts","g","gs"
  # redundant stats (cumulated per48)
  ,c("x3p","x3pa","x2p","x2pa","ft","fta","orb","drb","trb","ast","stl","blk"
  ,"tov","pf","pts") %+% "_cum3_per48"
  # redundant stats (per48)
   ,c("x3p","x3pa","x2p","x2pa","ft","fta","orb","drb","trb","ast","stl","blk"
   ,"tov","pf","pts") %+% "_per48"
   # redundant stats (perg)
   # ,c("x3p","x3pa","x2p","x2pa","ft","fta","orb","drb","trb","ast","stl","blk"
   # ,"tov","pf","pts") %+% "_perg"
   # redundant stats (cumulated perg)
   ,c("x3p","x3pa","x2p","x2pa","ft","fta","orb","drb","trb","ast","stl","blk"
   ,"tov","pf","pts") %+% "_cum3_perg"
   # not useful (attempted)
   ,c('x3pa','x2pa','x3pa_per48','x2pa_per48','x3pa_perg','x2pa_perg'
   ,'x3pa_cum3_per48','x2pa_cum3_per48','x3pa_cum3_perg','x2pa_cum3_perg'
   ,'fta','fta_per48','fta_perg','fta_cum3_per48','fta_cum3_perg')
   # not useful (points - already in 2p and 3p)
   ,c('pts','pts_per48','pts_perg','pts_cum3_per48','pts_cum3_perg')
)

base_fe = base_fe %>% select(-vars_drop)


# salary ------------------------------------------------------------------

# parameter: seasons to forward salary
lead_seasons = 0
# w_2018: salary real en usd de 2018
# w_adjcap: salary real as a proportion of season cap
# w_adjmedian: salary real as a proportion of season median
# w_*_t1: salaries in t+1

base_fe <- base_fe %>%
  inner_join(x=., y=cpi, by=c("season"="year")) %>%
  inner_join(x=., y=raw_cap, by=c("season"="year")) %>%
  # adjust by cpi (usd of 2018)
  mutate(cpi = cpi/unique(cpi[.$season==2018])
         ,salary_cap_2018 = salary_cap/cpi
         ,w_2018 = salary/cpi) %>%
  # as a proportion of season cap and median
  mutate(w_adjcap = w_2018 / salary_cap_2018 * 100) %>%
  group_by(season) %>%
  # as a proportion of median
  mutate(w_adjmedian = w_2018 / median(w_2018) * 100) %>%
  ungroup() %>%
  select(-salary, -salary_cap, -salary_cap_2018, -cpi) %>%
  # salaries in next season (features in t, salary in t+1)
  arrange(player, season) %>% group_by(player) %>%
  mutate_at(vars(season, team, w_2018, w_adjcap, w_adjmedian)
            ,list(t1 = function(x) lead(x,lead_seasons))) %>%
  ungroup() %>%
  select(-c(w_2018, w_adjmedian, w_adjcap, season, team))


# filter rows -------------------------------------------------------------

# parameters: minimum minutes played - min salary_2018
min_mp = 400
min_sal = 1e6

base_mod = base_fe %>%
  # drop where w_t1 is.na (no salary data in last season)
  dplyr::filter(!is.na(w_2018_t1)) %>%
  # drop where pos is.na (it means dnp in season)
  dplyr::filter(!is.na(pos)) %>%
  # filter by minutes played
  dplyr::filter(mp > min_mp) %>%
  # filter by salary
  dplyr::filter(w_2018_t1 > min_sal) %>%
  # no NAs in any variable (chequear si conviene) %>%
  dplyr::filter(complete.cases(.))



# save --------------------------------------------------------------------

rdsinpath(base_mod, path="data/working/")


# other -------------------------------------------------------------------


# NAs remain because of no events, no 3p attempted, no ft attempted:

# i = base_mod %>% apply(1, function(x) any(is.na(x)))
# base_mod %>% dplyr::filter(i) %>% dim()
# base_mod %>% dplyr::filter(is.na(x3p_percent) | is.na(ft_percent) |
#                               is.na(inj_out_cum)) %>% dim()
