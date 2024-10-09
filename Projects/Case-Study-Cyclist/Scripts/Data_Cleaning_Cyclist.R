library("dplyr")                                                 
library("plyr")                                                  
library("readr")   

# list.files() function produces a character vector of the names of files or directories in the named directory.

# lapply() function returns a list of the same length as X, 
# each element of which is the result of applying FUN to the corresponding element of X.

# bind_rows() function is an efficient implementation of the common pattern of do.call(rbind, dfs) 
# or do.call(cbind, dfs) for binding many data frames into one.

bikes_data <- list.files(path = "G:/Projects/R/Cyclist",     
                       pattern = "*.csv", full.names = TRUE) %>%  
  lapply(read_csv) %>%                                            
  bind_rows                                                       

colnames(bikes_data)

# Rename columns to being more readable

names(bikes_data)[names(bikes_data)=='start_lat'] <- 'start_latitude'
names(bikes_data)[names(bikes_data)=='start_lng'] <- 'start_longitude'

names(bikes_data)[names(bikes_data)=='end_lat'] <- 'end_latitude'
names(bikes_data)[names(bikes_data)=='end_lng'] <- 'end_longitude'

colnames(bikes_data)

# Remove the column ride_id

bikes_data <- bikes_data[,-1]

colnames(bikes_data)

# Export to 1 file .csv

write.csv(bikes_data, "G:/Projects/R/Cyclist/bikes_data.csv", quote=FALSE)




