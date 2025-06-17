library(stringr)
library(dplyr, warn.conflicts = FALSE)

#Merges the training and the test sets to create one data set.
#
#Extracts only the measurements on the mean and standard deviation for each measurement. 
#
#Uses descriptive activity names to name the activities in the data set
#
#Appropriately labels the data set with descriptive variable names. 
#
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# activity label names
activities <- read.table("./UCI_HAR_Dataset/activity_labels.txt") %>% as_tibble %>% rename(activityid=V1, activityname=V2)

# feature names
features <- read.table("./UCI_HAR_Dataset/features.txt") %>% as_tibble %>% rename(featureid=V1, featurename=V2)
# fix names
features$featurename <- features$featurename %>% str_replace_all("[^[:alnum:]]", "") %>% tolower

# Test data
test_x <- read.table("./UCI_HAR_Dataset/test/X_test.txt") %>% as_tibble
# set features as column headers
names(test_x) <- features$name

test_subjects <- read.table("./UCI_HAR_Dataset/test/subject_test.txt") %>% rename(subjectid=V1)

# Test labels
test_labels <- read.table("./UCI_HAR_Dataset/test/y_test.txt") %>% rename(activityid=V1)

# start merging test
# get activity names
test_data <- test_labels %>% left_join(activities, by=join_by(activityid)) %>% select(activityname)
# add subjectid in front and the data at the back
test_data <- test_subjects %>% bind_cols(test_data) %>% bind_cols(test_x)
test_data <- as_tibble(test_data)

# data_mean <- select(test_data, contains("mean"))
# data_std <- select(test_data, contains("std"))