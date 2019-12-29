# upload CPI data
# source of CPI file:
# https://fred.stlouisfed.org/series/CPIAUCSL#0
# Edits: Index scale 1990-01-01 = 100, freq = annualy, method = avg. Download as CSV

source("libraries.r")
source("functions/generic.r")

# create local data dir
dir.create("data/working/")
dir.create("data/raw/")

# csv to get
csv_cpi = "data/raw/CPI2.csv" 

# get raw tibble of CPI
cpi = read_delim(csv_cpi, delim=",", col_types=cols()) %>% 
  mutate(year = year(DATE),
         cpi = CPIAUCSL_NBD19900101) %>% 
  select(year, cpi)

# save as rds
rdsinpath(cpi, "data/working/")


