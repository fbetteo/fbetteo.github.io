source("libraries.r")

# df_pro=events$injuries

# initial clean events from sportprotransactions
clean_events = function(df_pro) {
  
  out = df_pro %>% 
    janitor::clean_names() %>%
    mutate(season = ifelse(month(date)<=9, year(date), year(date)+1)) %>% 
    mutate_at(vars(acquired, relinquished),
              function(x) str_remove(x,"\u2022") %>% str_squish())
  
  return(out)
  
}
