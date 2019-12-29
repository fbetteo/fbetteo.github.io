
# examine match between strings (return df to match names + unmatched names)
names_match = function(strings_a, strings_b) {
  
  a = strings_a %>% unique() %>% sort()
  b = strings_b %>% unique() %>% sort()
  
  # distance matrix (with full matching)
  d = adist(a, b) %>% `dimnames<-`(list(a, b))
  # names with full match
  match_full = a[apply(d, 1, function(r) sum(r==0)==1)]
  # distance matrix of names wout full match (with partial matching)
  d2 = adist(a[!a %in% match_full], b[!b %in% match_full], partial=T) %>%
    `dimnames<-`(list(a[!a %in% match_full], b[!b %in% match_full]))
  # names with partial match
  match_partial = rownames(d2)[apply(d2, 1, function(r) sum(r==0)==1)]
  # df of partial matches
  if (length(match_partial)==0) {
    df_partial = NULL 
  } else {
    df_partial = apply(d2, 1, function(r) which(r==0, arr.ind=T))[match_partial] %>% 
      modify_depth(1, names) %>% stack() %>% setNames(c("names_b","names_a")) %>% 
      mutate_if(is.factor, as.character)
  }
  # df of unmatched names with closest match (only small dist)
  df_nomatch =
    reshape2::melt(d2[!rownames(d2)%in%df_partial$names_a,
                      !colnames(d2)%in%df_partial$names_b, drop=F]) %>% 
    setNames(c("names_a","names_b","dist")) %>% 
    mutate_at(vars(names_a,names_b), as.character) %>%
    arrange(dist, -nchar(names_a)) %>% 
    dplyr::filter(dist<=10)
  
  out = list(full=match_full, partial=df_partial, no=df_nomatch)
  return(out)
  
}
