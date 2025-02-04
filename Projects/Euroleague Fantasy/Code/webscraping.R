# Φόρτωση απαραίτητων βιβλιοθηκών
library(httr)
library(jsonlite)
library(dplyr)

# Ορισμός του URL για το API
gamecode <- 1
seasoncode <- "E2024"
urlBoxScore <- paste0("https://live.euroleague.net/api/BoxScore?gamecode=", gamecode, "&seasoncode=", seasoncode)

# Ανάκτηση δεδομένων από το API
response <- GET(urlBoxScore)

# Έλεγχος κατάστασης
if (status_code(response) == 200) {
  # Μετατροπή σε λίστα
  BoxScoreData <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # 1. Εξαγωγή ByQuarter
  by_quarter <- BoxScoreData$ByQuarter %>%
    mutate(GameCode = gamecode, SeasonCode = seasoncode)  # Προσθήκη primary key
  
  # 2. Εξαγωγή EndOfQuarter
  end_of_quarter <- BoxScoreData$EndOfQuarter %>%
    mutate(GameCode = gamecode, SeasonCode = seasoncode)  # Προσθήκη primary key
  
  # 3. Εξαγωγή Referees και Attendance
  metadata <- data.frame(
    GameCode = gamecode,
    SeasonCode = seasoncode,
    Referees = BoxScoreData$Referees,
    Attendance = BoxScoreData$Attendance
  )
  
  # Αποθήκευση σε αρχεία CSV
  write.csv(by_quarter, "G:/Projects/Euroleague Fantasy/Data/ByQuarter.csv", row.names = FALSE)
  write.csv(end_of_quarter, "G:/Projects/Euroleague Fantasy/Data/EndOfQuarter.csv", row.names = FALSE)
  write.csv(metadata, "G:/Projects/Euroleague Fantasy/Data/GameMetadata.csv", row.names = FALSE)
  
  # Εμφάνιση επιβεβαίωσης
  print("Τα δεδομένα αποθηκεύτηκαν επιτυχώς!")
  
} else {
  print(paste("Σφάλμα:", status_code(response)))
}
