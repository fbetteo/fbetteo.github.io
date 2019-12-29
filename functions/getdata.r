source("libraries.r")


# scrape data from prosportstransactions ----------------------------------

scrape_events = function(item, begin_date) {
 
  # begin_date : yyyy-mm-dd format
  # item: one of
  #   IL : Movement to/from injured/inactive list
  #   Injuries : Missed games due to injury 
  #   Personal : Missed games due to personal reasons  
  #   Disciplinary : Disciplinary actions (suspensions, fines, etc.)
  #   Legal : Legal/Criminal incidents
  
  # url to scrape
  url = "http://www.prosportstransactions.com/basketball/Search/SearchResults.php?Player=&Team=&" %+% 
    "BeginDate=" %+% begin_date %+% "&EndDate=&" %+% item %+% "ChkBx=yes&Submit=Search"
  # html nodes of first page
  web = rvest::html_session(url)
  # links of first page
  buttons = web %>% rvest::html_nodes("p.bodyCopy > a") %>% rvest::html_text()
  # list of dataframes with data
  dat_list = list()
  # get data while until there is no Next link
  i = 1
  while ("Next" %in% buttons) {
    # get table of data as data.frame and store in list
    dat_temp = rvest::html_nodes(web, "body > div.container > table.datatable.center") %>% 
      rvest::html_table(header=T) %>% "[["(1)
    dat_list[[i]] = dat_temp
    # go to next page
    web = web %>% rvest::follow_link("Next")
    i = i+1
    # update links in page
    buttons = web %>% rvest::html_nodes("p.bodyCopy > a") %>% rvest::html_text()
  }
  # FOR THE LAST PAGE: get table of data as data.frame and store in list
  dat_temp = rvest::html_nodes(web, "body > div.container > table.datatable.center") %>% 
    rvest::html_table(header=T) %>% "[["(1)
  dat_list[[i]] = dat_temp
  # bind dataframes rows as tibble and mutate date
  out = dat_list %>% bind_rows() %>% as_tibble() %>% 
    mutate(Date = as.Date(Date))
  
  return(out)
  
}

