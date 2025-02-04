# Βιβλιοθήκες
library(httr)
library(jsonlite)
library(dplyr)

# Παράμετροι για τις σεζόν και τους αγώνες
seasons <- list(
  E2023 = 333,
  E2022 = 330,
  E2021 = 330,
  E2020 = 328,
  E2018 = 260,
  E2017 = 260,
  E2016 = 263
)

# Αρχεία CSV
files <- list(
  PlayerStatsBoxScore = "G:/Projects/Euroleague Fantasy/Data/PlayerStatsBoxScore.csv"
)

# Συνάρτηση για αποθήκευση με append
write_append <- function(data, file) {
  if (!file.exists(file)) {
    write.csv(data, file, row.names = FALSE)
  } else {
    write.table(data, file, row.names = FALSE, col.names = FALSE, sep = ",", append = TRUE)
  }
}

# Loop για κάθε σεζόν και αγώνα
for (seasoncode in names(seasons)) {
  max_gamecode <- seasons[[seasoncode]]
  
  for (gamecode in 1:max_gamecode) {
    url <- paste0("https://live.euroleague.net/api/BoxScore?gamecode=", gamecode, "&seasoncode=", seasoncode)
    response <- GET(url)
    
    if (status_code(response) == 200) {
      # Ελέγχουμε αν το περιεχόμενο είναι κενό
      content_text <- content(response, "text")
      
      if (nchar(content_text) == 0) {
        print(paste("Κενό περιεχόμενο για SeasonCode:", seasoncode, "GameCode:", gamecode))
        next  # Παρακάμπτουμε αυτό το gamecode
      }
      
      # Προσπαθούμε να διαβάσουμε το JSON
      tryCatch({
        BoxScoreData <- fromJSON(content_text, flatten = TRUE)
        
        # Επεξεργασία των δεδομένων όπως πριν
        if (!is.null(BoxScoreData$ByQuarter)) {
          by_quarter <- BoxScoreData$ByQuarter %>%
            mutate(GameCode = gamecode, SeasonCode = seasoncode)
          write_append(by_quarter, files$ByQuarter)
        }
        
        if (!is.null(BoxScoreData$EndOfQuarter)) {
          end_of_quarter <- BoxScoreData$EndOfQuarter %>%
            mutate(GameCode = gamecode, SeasonCode = seasoncode)
          write_append(end_of_quarter, files$EndOfQuarter)
        }
        
        metadata <- data.frame(
          GameCode = gamecode,
          SeasonCode = seasoncode,
          Referees = BoxScoreData$Referees,
          Attendance = BoxScoreData$Attendance
        )
        write_append(metadata, files$Metadata)
        
        print(paste("Αποθηκεύτηκαν δεδομένα για SeasonCode:", seasoncode, "GameCode:", gamecode))
        
      }, error = function(e) {
        # Χειρισμός σφάλματος αν το JSON δεν διαβάζεται
        print(paste("Σφάλμα στο JSON για SeasonCode:", seasoncode, "GameCode:", gamecode, "-", e$message))
      })
      
    } else {
      print(paste("Σφάλμα στο SeasonCode:", seasoncode, "GameCode:", gamecode, " - Status Code:", status_code(response)))
    }
  }
  
}

print("Όλα τα δεδομένα αποθηκεύτηκαν επιτυχώς!")
