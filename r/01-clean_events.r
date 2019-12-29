# transform raw_events (disciplinary, injuries, legal, personal) and save clean_events

source("libraries.r")
source("functions/generic.r")
source("functions/clean.r")


# notas -------------------------------------------------------------------

# temporada se considera de octubre a septiembre
  # (eg season=2017 es 2016-17 y va desde 10-2016 hasta 09-2017)

# read --------------------------------------------------------------------

types = c(
  "Injuries"
  , "Personal"
  , "Disciplinary"
  , "Legal"
) %>% tolower()

events = map(types, function(t) readRDS("data/working/raw_" %+% t %+% ".rds")) %>% 
  setNames(types) %>% 
  map(clean_events)
list2env(events, envir=.GlobalEnv)

# injuries --------------------------------------------------------------------

inj_clean = injuries %>% 
  # remove acquired 
  dplyr::filter(is.na(acquired) | acquired=="") %>% 
  select(-acquired) %>% 
  # remove relinquished without data
  dplyr::filter(!(is.na(relinquished) | relinquished=="")) %>% 
  rename(player=relinquished) %>%
  # create causa y status
  mutate(cause = str_split(notes, pattern=" \\(", n=2, simplify=T)[,1]) %>% 
  mutate(status = str_split(notes, pattern=" \\(", n=2, simplify=T)[,2] %>% 
           str_remove_all("\\)") %>% 
           str_remove(" \\(.+$")) %>% 
  # by season-player
  # (tot, dnp, dtd, out, other, cause_rest, cause_other)
  group_by(player, season) %>% 
  summarise(
    tot = n()
    , dnp = sum(status %in% "DNP")
    , dtd = sum(status %in% "DTD")
    , out = sum(status %in% c("out for season","out indefinitely"))
    , other = tot-dnp-dtd-out
    , cause_rest = sum(cause %in% "rest")
    , cause_other = sum(!cause %in% "rest")
  ) %>% 
  rename_at(vars(-season,-player), function(n) "inj_" %+% n) %>% 
  ungroup()



# personal --------------------------------------------------------------------

pers_clean = personal %>%
  # remove acquired
  dplyr::filter(is.na(acquired) | acquired=="") %>% 
  select(-acquired) %>% 
  # remove relinquished without data
  dplyr::filter(!(is.na(relinquished) | relinquished=="")) %>% 
  rename(player = relinquished) %>% 
  # personal by player-season
  group_by(player, season) %>% 
  summarise(tot = n()) %>% 
  rename_at(vars(-season,-player), function(n) "pers_" %+% n) %>% 
  ungroup()


# disciplinary -----------------------------------------------------------------

disc_clean = disciplinary %>%
  # remove acquired
  dplyr::filter(is.na(acquired) | acquired=="") %>% 
  select(-acquired) %>%
  # remove relinquished without data
  dplyr::filter(!(is.na(relinquished) | relinquished=="")) %>% 
  rename(player = relinquished) %>% 
  # by season-player
  # (tot, susps, fines, other)
  group_by(player, season) %>% 
  summarise(
    tot = n()
    , susps = sum(str_detect(notes, "suspended|placed on"))
    , fines = sum(str_detect(notes,"fine"))
    , other = tot-susps-fines
  ) %>% 
  rename_at(vars(-season,-player), function(n) "disc_" %+% n) %>% 
  ungroup()



# legal --------------------------------------------------------------------

legal_clean = legal %>%
  # remove acquired
  dplyr::filter(is.na(acquired) | acquired=="") %>% 
  select(-acquired) %>% 
  # remove relinquished without data
  dplyr::filter(!(is.na(relinquished) | relinquished=="")) %>% 
  rename(player = relinquished) %>% 
  # legal by player-season
  # (tot)
  group_by(player, season) %>% 
  summarise(tot = n()) %>% 
  rename_at(vars(-season,-player), function(n) "leg_" %+% n) %>% 
  ungroup()


# full join ---------------------------------------------------------------

events_clean = 
  # get all players-season combos
  expand.grid(
    player = c(inj_clean$player, disc_clean$player, pers_clean$player,
               legal_clean$player) %>% unique()
    ,season = seq(min(inj_clean$season), max(inj_clean$season), 1)
    , stringsAsFactors=F
  ) %>% as_tibble() %>% 
  # joins
  full_join(inj_clean, by=c("player","season")) %>% 
  full_join(disc_clean, by=c("player","season")) %>% 
  full_join(pers_clean, by=c("player","season")) %>% 
  full_join(legal_clean, by=c("player","season")) %>% 
  # replace NA with 0
  replace(is.na(.), 0) %>% 
  # cumulated sums by player
  group_by(player) %>% arrange(season) %>% 
  mutate_at(vars(-player, -season), list(cum=cumsum)) %>% 
  ungroup() %>% 
  # remove names with mistakes (nchar<=2)
  dplyr::filter(nchar(player)>2)

# save clean -------------------------------------------------------------------

rdsinpath(events_clean, path="data/working/")

