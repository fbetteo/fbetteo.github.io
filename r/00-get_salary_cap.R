# download salary cap data
# source of salary cap  file:
# https://www.basketball-reference.com/contracts/salary-cap-history.html
# table copied to excel and saved as csv

source("libraries.r")
source("functions/generic.r")

# create local data dir
dir.create("data/working/")
dir.create("data/raw/")

# csv to get
csv_cap = "data/raw/salarycap.csv" 

# get raw tibble of CPI
raw_cap = read_delim(csv_cap, delim=",", col_types=cols()) %>%
  janitor::clean_names() %>%
  mutate(year = as.numeric(str_sub(year,1,4)) + 1) %>%
  mutate(salary_cap = as.numeric(str_remove_all(salary_cap, ",|\\$"))) %>%
  select(-salary_cap_2015)


# save as rds
rdsinpath(raw_cap, "data/working/")


