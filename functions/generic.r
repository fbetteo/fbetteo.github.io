source("libraries.r")

# paste strings operator
"%+%" = function(a,b) paste(a,b, sep="")

# create rds from obj in path, with same name as obj
rdsinpath = function(obj, path) { 
  saveRDS(obj, path %+% deparse(substitute(obj)) %+% ".rds")
}

# create obj from rds in path, with same name as rds
objfromrds = function(rds_file) { 
  objname = basename(rds_file) %>% word(sep="\\.")
  assign(objname, readRDS(rds_file), envir=.GlobalEnv)
}

