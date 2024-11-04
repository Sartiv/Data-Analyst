# read.csv
postings <- read.csv("g:/Projects/Job Posting/postings.csv", stringsAsFactors = FALSE)

head(postings)
colnames(postings)
#str(postings)
#names(postings)
#unique(postings$title)  
#colSums(is.na(postings)) #  #nulls per column

# remove useless columns for analyze
install.packages("dplyr")  
library(dplyr)

postings_cleaned <- postings %>%
  select(-job_posting_url, -application_url, -expiry, -closed_time, 
         -listed_time, -posting_domain, -sponsored, -work_type, -currency, -compensation_type)

colnames(postings_cleaned)

# clean company_name
postings_cleaned$company_name <- trimws(postings_cleaned$company_name) #remove spaces
postings_cleaned$company_name <- tolower(postings_cleaned$company_name) #convert UPPER to lower
postings_cleaned$company_name <- gsub("\\b(inc|llc|ltd|llp|corp|co|incorporated|limited)\\b", "", postings_cleaned$company_name)
postings_cleaned$company_name <- gsub("[[:punct:]]", "", postings_cleaned$company_name) #remove special chars

# clean title
postings_cleaned$title <- trimws(postings_cleaned$title) #remove spaces
postings_cleaned$title <- gsub("[^a-zA-Z0-9 !\"#$%&'()*+,-./:;<=>?@[\\]^_`|~]", "", postings_cleaned$title) # remove emoticons

#Salaries
salary <- postings_cleaned %>%
  select(max_salary, med_salary, min_salary, pay_period, normalized_salary)

#Clean 'location' to export states
postings_cleaned$state <- ifelse(
  grepl(", [A-Z]{2}$", postings_cleaned$location),
  sub(".*, ([A-Z]{2})$", "\\1", postings_cleaned$location),
  NA
)

na_states <- postings_cleaned %>%
  filter(is.na(state)) %>%
  select(location, state)

print(na_states)


# step 1: "United States" to NA 
postings_cleaned$state <- ifelse(grepl("United States", postings_cleaned$location), NA, postings_cleaned$state)

# step 2: city to state
state_city_to_state <- c(
  # Alabama
  "Alabama" = "AL", "Montgomery" = "AL", "Birmingham" = "AL",
  # Alaska
  "Alaska" = "AK", "Juneau" = "AK", "Anchorage" = "AK",
  # Arizona
  "Arizona" = "AZ", "Phoenix" = "AZ", "Tucson" = "AZ",
  # Arkansas
  "Arkansas" = "AR", "Little Rock" = "AR", "Fayetteville" = "AR",
  # California
  "California" = "CA", "Sacramento" = "CA", "Los Angeles" = "CA", "San Francisco" = "CA",
  # Colorado
  "Colorado" = "CO", "Denver" = "CO", "Colorado Springs" = "CO",
  # Connecticut
  "Connecticut" = "CT", "Hartford" = "CT", "Bridgeport" = "CT",
  # Delaware
  "Delaware" = "DE", "Dover" = "DE", "Wilmington" = "DE",
  # Florida
  "Florida" = "FL", "Tallahassee" = "FL", "Miami" = "FL", "Orlando" = "FL",
  # Georgia
  "Georgia" = "GA", "Atlanta" = "GA", "Savannah" = "GA",
  # Hawaii
  "Hawaii" = "HI", "Honolulu" = "HI",
  # Idaho
  "Idaho" = "ID", "Boise" = "ID",
  # Illinois
  "Illinois" = "IL", "Springfield" = "IL", "Chicago" = "IL",
  # Indiana
  "Indiana" = "IN", "Indianapolis" = "IN", "Fort Wayne" = "IN",
  # Iowa
  "Iowa" = "IA", "Des Moines" = "IA", "Cedar Rapids" = "IA",
  # Kansas
  "Kansas" = "KS", "Topeka" = "KS", "Wichita" = "KS",
  # Kentucky
  "Kentucky" = "KY", "Frankfort" = "KY", "Louisville" = "KY",
  # Louisiana
  "Louisiana" = "LA", "Baton Rouge" = "LA", "New Orleans" = "LA",
  # Maine
  "Maine" = "ME", "Augusta" = "ME", "Portland" = "ME",
  # Maryland
  "Maryland" = "MD", "Annapolis" = "MD", "Baltimore" = "MD",
  # Massachusetts
  "Massachusetts" = "MA", "Boston" = "MA", "Worcester" = "MA",
  # Michigan
  "Michigan" = "MI", "Lansing" = "MI", "Detroit" = "MI",
  # Minnesota
  "Minnesota" = "MN", "Saint Paul" = "MN", "Minneapolis" = "MN",
  # Mississippi
  "Mississippi" = "MS", "Jackson" = "MS", "Gulfport" = "MS",
  # Missouri
  "Missouri" = "MO", "Jefferson City" = "MO", "Kansas City" = "MO",
  # Montana
  "Montana" = "MT", "Helena" = "MT", "Billings" = "MT",
  # Nebraska
  "Nebraska" = "NE", "Lincoln" = "NE", "Omaha" = "NE",
  # Nevada
  "Nevada" = "NV", "Carson City" = "NV", "Las Vegas" = "NV",
  # New Hampshire
  "New Hampshire" = "NH", "Concord" = "NH", "Manchester" = "NH",
  # New Jersey
  "New Jersey" = "NJ", "Trenton" = "NJ", "Newark" = "NJ",
  # New Mexico
  "New Mexico" = "NM", "Santa Fe" = "NM", "Albuquerque" = "NM",
  # New York
  "New York" = "NY", "Albany" = "NY", "New York City" = "NY", "Buffalo" = "NY",
  # North Carolina
  "North Carolina" = "NC", "Raleigh" = "NC", "Charlotte" = "NC",
  # North Dakota
  "North Dakota" = "ND", "Bismarck" = "ND", "Fargo" = "ND",
  # Ohio
  "Ohio" = "OH", "Columbus" = "OH", "Cleveland" = "OH", "Cincinnati" = "OH",
  # Oklahoma
  "Oklahoma" = "OK", "Oklahoma City" = "OK", "Tulsa" = "OK",
  # Oregon
  "Oregon" = "OR", "Salem" = "OR", "Portland" = "OR",
  # Pennsylvania
  "Pennsylvania" = "PA", "Harrisburg" = "PA", "Philadelphia" = "PA",
  # Rhode Island
  "Rhode Island" = "RI", "Providence" = "RI",
  # South Carolina
  "South Carolina" = "SC", "Columbia" = "SC", "Charleston" = "SC",
  # South Dakota
  "South Dakota" = "SD", "Pierre" = "SD", "Sioux Falls" = "SD",
  # Tennessee
  "Tennessee" = "TN", "Nashville" = "TN", "Memphis" = "TN",
  # Texas
  "Texas" = "TX", "Austin" = "TX", "Houston" = "TX", "Dallas" = "TX",
  # Utah
  "Utah" = "UT", "Salt Lake City" = "UT", "Provo" = "UT",
  # Vermont
  "Vermont" = "VT", "Montpelier" = "VT", "Burlington" = "VT",
  # Virginia
  "Virginia" = "VA", "Richmond" = "VA", "Virginia Beach" = "VA",
  # Washington
  "Washington" = "WA", "Olympia" = "WA", "Seattle" = "WA",
  # West Virginia
  "West Virginia" = "WV", "Charleston" = "WV", "Huntington" = "WV",
  # Wisconsin
  "Wisconsin" = "WI", "Madison" = "WI", "Milwaukee" = "WI",
  # Wyoming
  "Wyoming" = "WY", "Cheyenne" = "WY"
)

# Διατρέχουμε κάθε στοιχείο του λεξικού
for (city in names(state_city_to_state)) {
  # Συντομογραφία της πολιτείας για την τρέχουσα πόλη
  state_abbreviation <- state_city_to_state[city]
  
  # Ενημέρωση των NA στη στήλη state όταν το location περιέχει την πόλη
  postings_cleaned$state <- ifelse(
    is.na(postings_cleaned$state) & grepl(city, postings_cleaned$location, ignore.case = TRUE),
    state_abbreviation,
    postings_cleaned$state
  )
}

# Convert original_listed_time from Unix timestamp to date
postings_cleaned$datetime_posting <- as.POSIXct(postings_cleaned$original_listed_time / 1000, origin="1970-01-01", tz="UTC")

# Application_type 
postings_cleaned$application_type <- case_when(
  postings_cleaned$application_type == "ComplexOnsiteApply" ~ "COM-ONS",
  postings_cleaned$application_type == "OffsiteApply" ~ "OFF",
  postings_cleaned$application_type == "SimpleOnsiteApply" ~ "SIM-ONS",
  postings_cleaned$application_type == "UnknownApply" ~ "UNK",
  TRUE ~ postings_cleaned$application_type  # keep the rest
)

#adding company_size
companies <- read.csv("g:/Projects/Job Posting/companies/companies.csv", stringsAsFactors = FALSE)

postings_cleaned <- merge(postings_cleaned, companies[, c("company_id", "company_size")], 
                          by = "company_id", all.x = TRUE)

postings_cleaned <- postings_cleaned[, c(1:3, ncol(postings_cleaned), 4:(ncol(postings_cleaned)-1))]

#adding industry
company_industries <- read.csv("g:/Projects/Job Posting/companies/company_industries.csv", stringsAsFactors = FALSE)
postings_cleaned <- merge(postings_cleaned, company_industries, by = "company_id", all.x = TRUE)
postings_cleaned <- postings_cleaned[, c(1:4, ncol(postings_cleaned), 5:(ncol(postings_cleaned)-1))]

company_industries_unique <- company_industries[!duplicated(company_industries$company_id), ]
postings_cleaned <- merge(postings_cleaned, company_industries_unique, by = "company_id", all.x = TRUE)

#back up
postings_cleaned_backup <- postings_cleaned
postings_cleaned <- postings_cleaned_backup

#employee_count and follower_count
employee_counts <- read.csv("g:/Projects/Job Posting/companies/employee_counts.csv", stringsAsFactors = FALSE)

# Μετατροπή του time_recorded σε μορφή ημερομηνίας για ευκολότερο φιλτράρισμα
employee_counts$time_recorded <- as.POSIXct(employee_counts$time_recorded, origin="1970-01-01", tz="UTC")

# Φιλτράρισμα για την πιο πρόσφατη εγγραφή κάθε εταιρείας

employee_counts_latest <- employee_counts %>%
  group_by(company_id) %>%
  filter(time_recorded == max(time_recorded)) %>%
  distinct(company_id, .keep_all = TRUE) %>%
  ungroup()

# Επανασυγχώνευση στο postings_cleaned_backup
postings_cleaned <- merge(postings_cleaned_backup, employee_counts_latest[, c("company_id", "employee_count", "follower_count")],
                          by = "company_id", all.x = TRUE)

missing_salary_jobs <- postings_cleaned %>%
  filter(is.na(normalized_salary)) %>%
  select(job_id)

#type of insurance
benefits <- read.csv("g:/Projects/Job Posting/jobs/benefits.csv", stringsAsFactors = FALSE)

benefits_combined <- benefits %>%
  group_by(job_id) %>%
  summarize(type_insurance = paste(type, collapse = ", ")) %>%
  ungroup()

postings_cleaned <- merge(postings_cleaned, benefits_combined, by = "job_id", all.x = TRUE)

#fixing columns industry, industry.x , industry.y

# Δημιουργία νέας στήλης industry με τιμές από industry.x, και συμπλήρωση από industry.y όπου χρειάζεται
postings_cleaned$industry <- ifelse(!is.na(postings_cleaned$industry.x), postings_cleaned$industry.x, postings_cleaned$industry.y)

# Διαγραφή των περιττών στηλών
postings_cleaned <- postings_cleaned %>%
  select(-industry.x, -industry.y)

# remove original_listed_time and fips
postings_cleaned <- postings_cleaned %>%
  select(-original_listed_time, -fips)



###############################################################################
#                                                                             #
#                     V I S U A L I Z A T I O N                               #
#                                                                             #
###############################################################################


library(dplyr)

# Ομαδοποίηση και υπολογισμός συνολικών views και applies ανά τίτλο
popular_jobs <- postings_cleaned %>%
  group_by(title) %>%
  summarize(total_views = sum(views, na.rm = TRUE),
            total_applies = sum(applies, na.rm = TRUE)) %>%
  arrange(desc(total_views), desc(total_applies))

# Προβολή των κορυφαίων θέσεων
head(popular_jobs, 10)



# Επιλογή των κορυφαίων 10 θέσεων για οπτικοποίηση
top_jobs <- head(popular_jobs, 15)

ggplot(top_jobs, aes(x = reorder(title, total_views), y = total_views)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Top 15 Most Viewed Job Titles",
       x = "Job Title",
       y = "Total Views") +
  coord_flip()

# skill_desc 
# Load necessary libraries
library(dplyr)
library(tidytext)
library(stringr)


# Separate the skills into individual words/phrases
skills_count <- postings_cleaned %>%
  # Select only the skills_desc column
  select(skills_desc) %>%
  # Remove any rows with NA
  filter(!is.na(skills_desc)) %>%
  # Separate each word in skills_desc into individual rows
  unnest_tokens(skill, skills_desc, token = "words") %>%
  # Count the occurrences of each skill
  count(skill, sort = TRUE)

skills_keywords <- c(
  "data", "analysis", "analyst", "sql", "python", "excel", "powerbi", "tableau", "visualization",
  "statistics", "modeling", "machine", "learning", "project", "management", "communication",
  "presentation", "reporting", "database", "engineering", "cloud", "azure", "aws", "big", "data",
  "r", "java", "javascript", "agile", "scrum", "hadoop", "spark", "analytics", "research", 
  "problem-solving", "forecasting", "data-driven", "optimization", "ai", "artificial", 
  "intelligence", "ml", "nlp", "deep", "learning", "predictive", "etl", "dashboard",
  
  # Skills from skill.csv
  "art", "creative", "design", "advertising", "product management", "distribution", "education",
  "training", "project management", "consulting", "purchasing", "supply chain", "analyst", 
  "health care provider", "research", "science", "general business", "customer service", 
  "strategy/planning", "finance", "legal", "engineering", "quality assurance", "business development",
  "information technology", "administrative", "production", "marketing", "public relations", 
  "writing/editing", "accounting/auditing", "human resources", "manufacturing", "sales", "management"
)

filtered_skills_count <- skills_count %>%
  filter(skill %in% skills_keywords)

# Display the top filtered skills
head(filtered_skills_count, 10)

# Select top 10 most common skills for visualization
top_skills <- head(filtered_skills_count, 20)

# Create the horizontal bar chart
ggplot(top_skills, aes(x = reorder(skill, n), y = n)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Top 20 Most Requested Skills",
       x = "Skills",
       y = "Frequency") +
  coord_flip() +
  theme_minimal()

# Salary per popular job
library(dplyr)
library(ggplot2)
library(scales)  # Για τη μορφοποίηση των αριθμών στον άξονα

# Δημιουργία φιλτραρισμένου dataset με τα όρια που έθεσες
filtered_salary_data <- postings_cleaned %>%
  filter(normalized_salary >= 15000, normalized_salary <= 500000)

# Επιλογή των 15 κορυφαίων τίτλων εργασίας βάσει προβολών
top_jobs <- popular_jobs %>% head(15)

# Δημιουργία box plot για το εύρος μισθών στις top 15 θέσεις εργασίας
ggplot(filtered_salary_data %>% filter(title %in% top_jobs$title), 
       aes(x = reorder(title, -normalized_salary), y = normalized_salary)) +
  geom_boxplot(fill = "lightblue") +
  scale_y_continuous(labels = comma) +  # Μορφοποίηση του άξονα y με απλά νούμερα
  labs(title = "Salary Range for Top 15 Most Viewed Job Titles",
       x = "Job Title",
       y = "Salary") +
  coord_flip() +
  theme_minimal()

# Salary per Location
library(dplyr)
library(ggplot2)
library(usmap)
library(scales)

# Υπολογισμός μέσου μισθού ανά πολιτεία
state_salary <- filtered_salary_data %>%
  group_by(state) %>%
  summarize(avg_salary = mean(normalized_salary, na.rm = TRUE))

# Δημιουργία του χάρτη των ΗΠΑ με χρωματική κωδικοποίηση ανάλογα με τον μέσο μισθό
plot_usmap(data = state_salary, values = "avg_salary", color = "white") +
  scale_fill_continuous(low = "lightblue", high = "darkblue", label = dollar) +
  labs(title = "Average Salary by State in the USA",
       fill = "Average Salary") +
  theme(legend.position = "right")

###################### top15 states - job postings
library(dplyr)
library(ggplot2)

# Υπολογισμός του πλήθους των αγγελιών ανά πολιτεία
state_counts <- postings_cleaned %>%
  filter(!is.na(state)) %>%
  group_by(state) %>%
  summarize(job_count = n()) %>%
  arrange(desc(job_count))

# Επιλογή των 15 κορυφαίων πολιτειών για την οπτικοποίηση
top_15_states <- state_counts %>% head(15)

# Δημιουργία οριζόντιου ραβδογράμματος
ggplot(top_15_states, aes(x = reorder(state, job_count), y = job_count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Top 15 States by Job Postings",
       x = "State",
       y = "Number of Job Postings") +
  coord_flip() +
  theme_minimal()

# Calculate percentage of remote jobs
remote_percentage <- postings_cleaned %>%
  summarize(
    remote_count = sum(remote_allowed == 1, na.rm = TRUE),
    total_count = n()
  ) %>%
  mutate(remote_percentage = (remote_count / total_count) * 100) %>%
  pull(remote_percentage)

# Εμφάνιση του αποτελέσματος
cat("Percentage of Remote Positions:", remote_percentage, "%\n")

### Find top remote jobs
library(dplyr)
library(ggplot2)

# Φιλτράρουμε τις remote θέσεις και υπολογίζουμε το πλήθος των αγγελιών ανά τίτλο
remote_job_counts <- postings_cleaned %>%
  filter(remote_allowed == 1) %>%
  group_by(title) %>%
  summarize(remote_count = n()) %>%
  arrange(desc(remote_count))

# Επιλέγουμε τις κορυφαίες 10 remote θέσεις
top_remote_jobs <- remote_job_counts %>% head(10)

# Δημιουργία οριζόντιου ραβδογράμματος για τις πιο περιζήτητες remote θέσεις
ggplot(top_remote_jobs, aes(x = reorder(title, remote_count), y = remote_count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Top 10 Most Demanded Remote Job Titles",
       x = "Job Title",
       y = "Number of Remote Job Postings") +
  coord_flip() +
  theme_minimal()

##### relation company size - remote ###
library(dplyr)
library(ggplot2)

# Φιλτράρουμε για remote θέσεις εργασίας και υπολογίζουμε το πλήθος ανά μέγεθος εταιρείας
remote_by_company_size <- postings_cleaned %>%
  filter(remote_allowed == 1) %>%
  group_by(company_size) %>%
  summarize(remote_count = n(),
            avg_employee_count = mean(employee_count, na.rm = TRUE))

# Υπολογισμός του ποσοστού remote εργασιών ανά μέγεθος εταιρείας (για όλες τις εταιρείες)
total_by_company_size <- postings_cleaned %>%
  group_by(company_size) %>%
  summarize(total_count = n())

# Συνδυάζουμε τα δεδομένα για να υπολογίσουμε το ποσοστό remote εργασιών
remote_analysis <- remote_by_company_size %>%
  left_join(total_by_company_size, by = "company_size") %>%
  mutate(remote_percentage = (remote_count / total_count) * 100)

# Δημιουργία bar plot για το ποσοστό των remote εργασιών ανά μέγεθος εταιρείας
ggplot(remote_analysis, aes(x = factor(company_size), y = remote_percentage)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Percentage of Remote Jobs by Company Size",
       x = "Company Size",
       y = "Percentage of Remote Jobs (%)") +
  theme_minimal()

#### Description / views 
library(dplyr)
library(tidytext)
library(ggplot2)

# Λεξικό τεχνικών όρων που είχαμε ορίσει
skills_keywords <- c(
  "data", "analysis", "analyst", "sql", "python", "excel", "powerbi", "tableau", "visualization",
  "statistics", "modeling", "machine", "learning", "project", "management", "communication",
  "presentation", "reporting", "database", "engineering", "cloud", "azure", "aws", "big", "data",
  "r", "java", "javascript", "agile", "scrum", "hadoop", "spark", "analytics", "research", 
  "problem-solving", "forecasting", "data-driven", "optimization", "ai", "artificial", 
  "intelligence", "ml", "nlp", "deep", "learning", "predictive", "etl", "dashboard",
  
  # Skills from skill.csv
  "art", "creative", "design", "advertising", "product management", "distribution", "education",
  "training", "project management", "consulting", "purchasing", "supply chain", "analyst", 
  "health care provider", "research", "science", "general business", "customer service", 
  "strategy/planning", "finance", "legal", "engineering", "quality assurance", "business development",
  "information technology", "administrative", "production", "marketing", "public relations", 
  "writing/editing", "accounting/auditing", "human resources", "manufacturing", "sales", "management"
)

# Προσθήκη stop words
data("stop_words")

# Υπολογισμός της διάμεσου των views
median_views <- median(postings_cleaned$views, na.rm = TRUE)

# Διαχωρισμός των αγγελιών σε top 50% και bottom 50% με βάση τα views
top_views <- postings_cleaned %>% filter(views > median_views)
bottom_views <- postings_cleaned %>% filter(views <= median_views)


# Διαχωρισμός των λέξεων στο description για κάθε ομάδα και αφαίρεση stop words
top_words <- top_views %>%
  unnest_tokens(word, description) %>%
  anti_join(stop_words, by = "word") %>%
  filter(word %in% skills_keywords) %>%
  count(word, sort = TRUE)

bottom_words <- bottom_views %>%
  unnest_tokens(word, description) %>%
  anti_join(stop_words, by = "word") %>%
  filter(word %in% skills_keywords) %>%
  count(word, sort = TRUE)

# Συγχώνευση των δύο συνόλων δεδομένων και σύγκριση της συχνότητας λέξεων
comparison <- top_words %>%
  rename(top_count = n) %>%
  inner_join(bottom_words, by = "word") %>%
  rename(bottom_count = n) %>%
  mutate(diff = top_count - bottom_count) %>%
  arrange(desc(diff))

# Εμφάνιση των top 10 λέξεων με μεγαλύτερη διαφορά
head(comparison, 10)

# Αποθήκευση των αποτελεσμάτων σε .csv
write.csv(comparison, "G:/Projects/Job Posting/R Language/comparison_results.csv", row.names = FALSE)

##### Average Number of Applications by Application Type

library(dplyr)
library(ggplot2)

# Υπολογισμός του μέσου αριθμού αιτήσεων ανά application_type
application_effect <- postings_cleaned %>%
  filter(!is.na(applies), !is.na(application_type)) %>%
  group_by(application_type) %>%
  summarize(avg_applies = mean(applies, na.rm = TRUE),
            total_applies = sum(applies, na.rm = TRUE),
            count = n())

# Δημιουργία bar plot για να δείξουμε τον μέσο αριθμό αιτήσεων ανά application_type
ggplot(application_effect, aes(x = application_type, y = avg_applies, fill = application_type)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Number of Applications by Application Type",
       x = "Application Type",
       y = "Average Number of Applications") +
  theme_minimal()

###### 

library(dplyr)
library(ggplot2)
library(scales)

# Υπολογισμός του συντελεστή συσχέτισης
correlation_applies <- cor(postings_cleaned$follower_count, postings_cleaned$applies, use = "complete.obs")
correlation_views <- cor(postings_cleaned$follower_count, postings_cleaned$views, use = "complete.obs")

# Εκτύπωση των συντελεστών συσχέτισης
cat("Correlation between follower_count and applies:", correlation_applies, "\n")
cat("Correlation between follower_count and views:", correlation_views, "\n")


# Δημιουργία διαγράμματος διασποράς για follower_count και applies με μορφοποίηση άξονα
ggplot(postings_cleaned, aes(x = follower_count, y = applies)) +
  geom_point(alpha = 0.5, color = "blue") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(title = "Scatter Plot of Follower Count vs. Applications",
       x = "Follower Count",
       y = "Number of Applications") +
  theme_minimal()

# Δημιουργία διαγράμματος διασποράς για follower_count και views με μορφοποίηση άξονα
ggplot(postings_cleaned, aes(x = follower_count, y = views)) +
  geom_point(alpha = 0.5, color = "darkgreen") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(title = "Scatter Plot of Follower Count vs. Views",
       x = "Follower Count",
       y = "Number of Views") +
  theme_minimal()
































