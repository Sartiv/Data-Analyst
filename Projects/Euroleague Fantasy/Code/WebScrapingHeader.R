# Libraries
library(httr)
library(jsonlite)
library(dplyr)

# Parameters for seasons and games
seasons <- list(
  E2023 = 333,
  E2022 = 330,
  E2021 = 330,
  E2020 = 328,
  E2018 = 260,
  E2017 = 260,
  E2016 = 263
)

# CSV files
files <- list(
  Header = "G:/Projects/Euroleague Fantasy/Data/Header.csv"
)

# Function to append data to a CSV
write_append <- function(data, file) {
  if (!is.null(data) && nrow(data) > 0) 
    {
    if (!file.exists(file)) 
      {
      write.csv(data, file, row.names = FALSE)
      print(paste("Created file:", file))
      } else 
       {
        write.table(data, file, row.names = FALSE, col.names = FALSE, sep = ",", append = TRUE)
        print(paste("Appended to file:", file))
       }
     } else 
     {
       print(paste("Empty data: nothing was saved to", file))
     }
}

# Loop for each season and game
for (seasoncode in names(seasons)) {
  max_gamecode <- seasons[[seasoncode]]
  
  for (gamecode in 1:max_gamecode) {
    url <- paste0("https://live.euroleague.net/api/Header?gamecode=", gamecode, "&seasoncode=", seasoncode)
    response <- GET(url)
    
    if (status_code(response) == 200) {
      # Check if the response is null
      content_text <- content(response, "text")
      
      if (nchar(content_text) == 0) {
        print(paste("Empty content for SeasonCode", seasoncode, "GameCode:", gamecode))
        next  
      }
      
      tryCatch({
        HeaderData <- fromJSON(content_text, flatten = TRUE)
        
        # Convert HeaderData to a dataframe
        header <- as.data.frame(t(unlist(HeaderData)), stringsAsFactors = FALSE)
        header <- header %>%
          mutate(
            GameCode = gamecode,
            SeasonCode = seasoncode
          )
        
        # Save to CSV
        write_append(header, files$Header)
        print(paste("Data saved for SeasonCode:", seasoncode, "GameCode:", gamecode))
        
      }, error = function(e) {
        print(paste("Error in JSON for SeasonCode:", seasoncode, "GameCode:", gamecode, "-", e$message))
      })
      
    } else {
      print(paste("Error in SeasonCode:", seasoncode, "GameCode:", gamecode, " - Status Code:", status_code(response)))
    }
  }
}

print("All data successfully saved!")
