# extract salaries from zip and save as raw tibbles
# source of zip file:
  # https://data.world/makeovermonday/2018w29-historical-nba-team-spending-against-the-cap

source("libraries.r")
source("functions/generic.r")

# create local data dir
dir.create("data/working/")
dir.create("data/raw/")

# zip file in data/raw
zip_sal = "data/raw/makeovermonday-2018w29-historical-nba-team-spending-against-the-cap.zip"
# to see files of zip:
# unzip(zip_sal, list=T)
# csv to get
csv_sal = "makeovermonday-2018w29-historical-nba-team-spending-against-the-cap/data/player_salaries.csv" 
# connect to file
file_sal = unz(zip_sal, csv_sal, open="rb")
# get raw tibble of salaries
raw_salaries = read_delim(file_sal, delim=",", col_types=cols())

# save as rds
rdsinpath(raw_salaries, "data/working/")



