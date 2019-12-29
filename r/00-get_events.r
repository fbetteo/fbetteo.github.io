# scrape events from prosportstransactions and save raw tibbles

source("libraries.r")
source("functions/generic.r")
source("functions/getdata.r")

# first date
begin_date = "1990-01-01"

# types of events (see function)
types = c(
  "Injuries"
  , "Personal"
  , "Disciplinary"
  , "Legal"
  # , "IL"
)

# create local data dir
dir.create("data/working/")
dir.create("data/raw/")

# scrape events as raw tibbles
raw_events = map(types, function(t) scrape_events(item=t, begin_date=begin_date))
# set names to save
names(raw_events) = "raw_" %+% tolower(types)

# save as rds
walk2(raw_events, names(raw_events),
      function(t,n) saveRDS(t, file="data/working/"%+%n%+%".rds"))
