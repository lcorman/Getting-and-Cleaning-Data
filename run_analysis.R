library(dplyr)

# Read in data from zip file
temp <- tempfile()

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = temp,
              mode = "wb")

unzip(temp, exdir = getwd())

### Read training data

# Training set
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")

# Training labels
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

### Read test data

# Test set
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")

# Test labels
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

### Read overall labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

features <- read.table("./UCI HAR Dataset/features.txt")

### Merge training and test data, and add subject and activity info

# Bind rows together
fullData <- rbind(X_train, X_test)

# Add column names
colnames(fullData) <- features[,2]

# Combine subjects
fullSubjects <- rbind(subject_train, subject_test)

# Add column name
colnames(fullSubjects) <- c("Subject")

# Combine activity numbers and join with activity labels
fullActivities <- rbind(y_train, y_test) %>% left_join(activity_labels,
                                                       by = c("V1"))
# Add column names
colnames(fullActivities) <- c("ActivityNumber", "ActivityName")

# Combine all columns
fullData <- cbind(fullSubjects, fullActivities, fullData)

### Filter and transform

# Select only mean and standard deviation columns
columns <- c(which(grepl("mean()", colnames(fullData), fixed = T)),
             which(grepl("std()", colnames(fullData), fixed = T)))

fullDataFilter <- fullData[, c(1:3, columns)]

### Create second data set with average of each variable for each activity/subject

# Group by subject and activity, then take mean
fullDataFilterAvg <- fullDataFilter %>% group_by(Subject, ActivityNumber, ActivityName) %>% 
  summarize_all(mean)

# Update column names to reflect that variables are now averages
colnames(fullDataFilterAvg)[4:69] <- paste0("Avg-", colnames(fullDataFilterAvg)[4:69])

### Save tidy data

write.table(fullDataFilter, "tidyAll.txt")

write.table(fullDataFilterAvg, "tidyAvg.txt")

