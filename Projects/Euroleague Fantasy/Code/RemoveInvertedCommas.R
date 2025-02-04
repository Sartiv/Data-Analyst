# Libraries
library(dplyr) # Για επεξεργασία δεδομένων

# 1. Φόρτωση του αρχείου
file_path <- "G:/Projects/Euroleague Fantasy/Data/HeaderStats_Updated.csv"
header_stats <- read.csv(file_path, stringsAsFactors = FALSE)

# 2. Αφαίρεση εισαγωγικών από όλες τις στήλες
header_stats_clean <- data.frame(lapply(header_stats, function(x) {
  if (is.character(x)) {
    return(gsub('"', '', x)) # Αφαιρεί τα εισαγωγικά από τις τιμές κειμένου
  } else {
    return(x) # Διατηρεί τις μη κειμενικές τιμές όπως είναι
  }
}))

# 3. Αποθήκευση του καθαρισμένου αρχείου στο ίδιο όνομα
write.csv(header_stats_clean, file_path, row.names = FALSE, quote = FALSE)

# Μήνυμα επιτυχίας
cat("The file has been cleaned and saved successfully!")
