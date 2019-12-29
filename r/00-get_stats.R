# extract seasonal stats from zip and save as raw tibbles
# source of zip file:
# https://www.kaggle.com/drgilermo/nba-players-stats

source("libraries.r")
source("functions/generic.r")

# create local data dir
dir.create("data/working/")
dir.create("data/raw/")

# zip file in data/raw
zip_sal = "data/raw/nba-players-stats.zip"
# to see files of zip:
# unzip(zip_sal, list=T)
# csv to get
csv_sal = "Seasons_Stats.csv" 
# connect to file
file_sal = unz(zip_sal, csv_sal, open="rb")
# get raw tibble of salaries
raw_stats = read_delim(file_sal, delim=",", col_types=cols())

# save as rds
rdsinpath(raw_stats, "data/working/")
