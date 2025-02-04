# Libraries
library(dplyr) # Για επεξεργασία δεδομένων

# 1. Φόρτωση του αρχείου
file_path <- "G:/Projects/Euroleague Fantasy/Data/teamTotal_edit.csv"
team_totals <- read.csv(file_path, stringsAsFactors = FALSE)

# 2. Επισκόπηση των δεδομένων
str(team_totals)      # Τύποι στηλών
head(team_totals)     # Δείγμα δεδομένων

# 3. Μετατροπή της στήλης TotalMinutes σε TotalSeconds
convert_to_seconds <- function(time_string) {
  # Ελέγχει αν η τιμή είναι έγκυρη ή NA
  if (is.na(time_string) || time_string == "") {
    return(NA)
  }
  
  # Διαχωρισμός της τιμής με βάση το ":"
  time_parts <- as.numeric(unlist(strsplit(time_string, ":")))
  
  # Υπολογισμός συνολικών δευτερολέπτων
  if (length(time_parts) == 3) { # MMM:ss:δεκατά
    total_seconds <- time_parts[1] * 60 + time_parts[2]
  } else {
    total_seconds <- NA
  }
  
  return(total_seconds)
}

# 4. Δημιουργία νέας στήλης TotalSeconds
team_totals <- team_totals %>%
  mutate(
    TotalSeconds = sapply(total_Minutes, convert_to_seconds)
  )

# 5. Επισκόπηση του νέου dataframe
str(team_totals)      # Νέοι τύποι στηλών
head(team_totals)     # Δείγμα δεδομένων

# 6. Αποθήκευση σε νέο CSV (προαιρετικά)
write.csv(team_totals, "G:/Projects/Euroleague Fantasy/Data/TeamTotals_Updated.csv", row.names = FALSE)

# Μήνυμα επιτυχίας
cat("Η επεξεργασία ολοκληρώθηκε επιτυχώς!")

