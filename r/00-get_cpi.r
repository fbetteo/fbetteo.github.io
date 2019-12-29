# download CPI to adjust salaries

source("libraries.r")
source("functions/generic.r")

url = "https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=
line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=
on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=
yes&show_axis_titles=yes&show_tooltip=yes&id=CPALTT01USA661S&scale=left&cosd=
1960-01-01&coed=2018-01-01&line_color=%234572a7&link_values=false&line_style=
solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Annual&fam=avg&fgst=
lin&fgsnd=2009-06-01&line_index=1&transformation=lin&vintage_date=
2019-05-02&revision_date=2019-05-02&nd=1960-01-01"


# create local data dir
dir.create("data/working/")
dir.create("data/raw/")

# download csv to data/raw/
destfile = "data/raw/cpi.csv"
download.file(url=url, destfile=destfile)

# get tibble of cpi
cpi = read_delim(destfile, delim=",", col_types=cols()) %>% 
  mutate(year = year(DATE),
         cpi = CPALTT01USA661S) %>% 
  select(year, cpi)

# save as rds
rdsinpath(cpi, "data/working/")

