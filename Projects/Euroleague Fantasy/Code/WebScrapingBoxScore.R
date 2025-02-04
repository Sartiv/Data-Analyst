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
  ByQuarter = "G:/Projects/Euroleague Fantasy/Data/ByQuarter.csv",
  EndOfQuarter = "G:/Projects/Euroleague Fantasy/Data/EndOfQuarter.csv",
  Metadata = "G:/Projects/Euroleague Fantasy/Data/GameMetadata.csv",
  PlayersStats = "G:/Projects/Euroleague Fantasy/Data/PlayersStats.csv",
  TeamTotals = "G:/Projects/Euroleague Fantasy/Data/TeamTotals.csv"
)

# Function for saving data with append
write_append <- function(data, file) {
  if (!is.null(data) && nrow(data) > 0) {  # Check if data exists
    if (!file.exists(file)) {
      write.csv(data, file, row.names = FALSE)
    } else {
      write.table(data, file, row.names = FALSE, col.names = FALSE, sep = ",", append = TRUE)
    }
  } else {
    print(paste("Empty data: nothing was saved to the file", file))
  }
}

# Loop for each season and game
for (seasoncode in names(seasons)) {
  max_gamecode <- seasons[[seasoncode]]
  
  for (gamecode in 1:max_gamecode) {
    url <- paste0("https://live.euroleague.net/api/BoxScore?gamecode=", gamecode, "&seasoncode=", seasoncode)
    response <- GET(url)
    
    if (status_code(response) == 200) {
      # Check if the response is null
      content_text <- content(response, "text")
      
      if (nchar(content_text) == 0) {
        print(paste("Empty content for SeasonCode", seasoncode, "GameCode:", gamecode))
        next  
      }
      
      tryCatch({
        BoxScoreData <- fromJSON(content_text, flatten = TRUE)
        
        # 1. ByQuarter
        if (!is.null(BoxScoreData$ByQuarter)) {
          by_quarter <- BoxScoreData$ByQuarter %>%
            mutate(GameCode = gamecode, SeasonCode = seasoncode)
          write_append(by_quarter, files$ByQuarter)
        }

        # 2. EndOfQuarter
        if (!is.null(BoxScoreData$EndOfQuarter)) {
          end_of_quarter <- BoxScoreData$EndOfQuarter %>%
            mutate(GameCode = gamecode, SeasonCode = seasoncode)
          write_append(end_of_quarter, files$EndOfQuarter)
        }

        # 3. Metadata
        metadata <- data.frame(
          GameCode = gamecode,
          SeasonCode = seasoncode,
          Referees = BoxScoreData$Referees,
          Attendance = BoxScoreData$Attendance
        )
        write_append(metadata, files$Metadata)

        # 4. PlayersStats
        if (!is.null(BoxScoreData$Stats$PlayersStats) && length(BoxScoreData$Stats$PlayersStats) > 0) {
          players_stats_list <- lapply(seq_along(BoxScoreData$Stats$PlayersStats), function(i) {
            team_stats <- BoxScoreData$Stats$PlayersStats[[i]]
            team_name <- BoxScoreData$Stats$Team[i]
            
            if (!is.null(team_stats) && nrow(team_stats) > 0) {
              team_stats <- team_stats %>%
                mutate(
                  GameCode = gamecode,
                  SeasonCode = seasoncode,
                  Team = team_name
                )
              return(team_stats)
            } else {
              return(NULL)
            }
          })
          
          # Remove NULL elements
          players_stats_list <- players_stats_list[!sapply(players_stats_list, is.null)]
          
          # Create a unified dataframe if data exists
          if (length(players_stats_list) > 0) {
            players_stats <- bind_rows(players_stats_list)
            write_append(players_stats, files$PlayersStats)
          } else {
            print(paste("Empty PlayersStats for GameCode:", gamecode, "SeasonCode:", seasoncode))
          }
        }
        
        
        # 5. TeamTotals (tmr.* και totr.*)
        if (!is.null(BoxScoreData$Stats)) {
          team_totals <- BoxScoreData$Stats %>%
            select(starts_with("tmr."), starts_with("totr.")) %>%
            mutate(
              GameCode = gamecode,
              SeasonCode = seasoncode,
              Team = BoxScoreData$Stats$Team
            )
          write_append(team_totals, files$TeamTotals)
        }
        
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
