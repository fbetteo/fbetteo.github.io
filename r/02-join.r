# join tables by player-season (using salaries as base)
  # season already is last year of season (eg season=2016 es season 2015-16)
  # filter >=2008 season to make matching of names easier

source("libraries.r")
source("functions/generic.r")
source("functions/join.r")

# notas -------------------------------------------------------------------


# parameters --------------------------------------------------------------

first_season = 2008

# read --------------------------------------------------------------------

clean_files = list.files("data/working/", full.names=T) %>%
  "["(str_detect(.,"clean"))
walk(clean_files, objfromrds)


# filter and clean names ------------------------------------------------------

# keep obs since first_season (to make matching of names easier)
events_f = events_clean %>% dplyr::filter(season>=first_season) %>%
  mutate(
    player = player %>% tolower() %>% str_remove_all("[:punct:]") %>% str_squish()
  )
salaries_f = salaries_clean %>% dplyr::filter(season>=first_season) %>%
  mutate(
    player = player %>% tolower() %>% str_remove_all("[:punct:]") %>% str_squish()
  )
stats_f = stats_clean %>% dplyr::filter(season>=first_season) %>%
  mutate(
    player = player %>% tolower() %>% str_remove_all("[:punct:]") %>% str_squish()
  )


# match player names ------------------------------------------------------

# salaries and stats
nm_sal_stats = names_match(salaries_f$player, stats_f$player)
nm_stats_sal = names_match(stats_f$player, salaries_f$player)
# nm_sal_stats$partial
# nm_stats_sal$partial
# nm_sal_stats$no %>% head(20)
# nm_stats_sal$no %>% head(20)
match_df_sal_stat = nm_stats_sal$partial %>%
  rbind(tribble(
    ~names_a,              ~names_b,
    "jeffery taylor",      "jeff taylor",
    "viacheslav kravtsov", "sasha kravtsov",
    "sheldon mcclellan",   "sheldon mac"
  )) %>%
  rename(player_sal=names_b, player_sta=names_a)

# salaries and events
nm_sal_events = names_match(salaries_f$player, events_f$player)
nm_events_sal = names_match(events_f$player, salaries_f$player)
# nm_sal_events$partial
# nm_events_sal$partial
# nm_sal_events$no %>% head(20)
# nm_events_sal$no %>% head(20)
match_df_sal_events = nm_sal_events$partial %>%
  rbind(tribble(
    ~names_a,                      ~names_b,
    "metta world peace",          "metta world peace ron artest",
    "metta world peace",          "ron artest metta world peace",
    "gerald henderson",                    "gerald henderson a",
    "gerald henderson",                    "gerald henderson b",
    "mike dunleavy",                      "mike dunleavy jr",
    "mike dunleavy",                      "mike dunleavy sr",
    "jeff ayres",           "jeff ayres jeff pendergraph",
    "jeff ayres",           "jeff pendergraph jeff ayres",
    "glen rice",                          "glen rice jr",
    "glen rice",                          "glen rice sr",
    "john wall",                           "john wall a"
  )) %>%
  rename(player_sal=names_a, player_ev=names_b)
# there's two of dunleavy, rice, henderson (but never in the same year :) )


# join --------------------------------------------------------------------

# change conflictive names in stats
stats_join = stats_f %>%
  mutate(
    player_sal =
      match_df_sal_stat$player_sal[match(player, match_df_sal_stat$player_sta)]
    ) %>%
  mutate(player = coalesce(player_sal, player)) %>%
  select(-player_sal)

# change conflictive names in events
events_join = events_f %>%
  mutate(
    player_sal =
      match_df_sal_events$player_sal[match(player, match_df_sal_events$player_ev)]
  ) %>%
  mutate(player = coalesce(player_sal, player)) %>%
  select(-player_sal) %>%
  # remove duplicated player-season
  # (keep record with max sum across columns)
  mutate(sum_temp = apply(events_f %>% select(-player,-season), 1, sum)) %>%
  group_by(player, season) %>%
  dplyr::filter(sum_temp == max(sum_temp)) %>%
  ungroup() %>% select(-sum_temp) %>%
  # (random if tie)
  distinct(player, season, .keep_all=T)

# join
base = salaries_f %>%
  left_join(stats_join, by=c("player","season")) %>%
  left_join(events_join, by=c("player","season")) %>%
  # keep team of salary data / drop of stats data
  select(-tm)


# save --------------------------------------------------------------------

rdsinpath(base, "data/working/")
