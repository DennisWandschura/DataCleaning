library(stringr)
library(tidyr)
library(dplyr, warn.conflicts = FALSE)

# loads the features file with fixed header
loadFeaturesFile <- function()
{
  # first check if the file exists
  featuresFilePath <- "./UCI_HAR_Dataset/features.txt"
  if(!file.exists(featuresFilePath))
  {
    # if not return error message
    stop("Feature file not found: '", featuresFilePath, "';")
  }
  
  # load feature names and fix the header
  features <- read.table(featuresFilePath) %>% 
    as_tibble %>% 
    rename(featureid=V1, featurename=V2)
  
  # lowercase and remove all non alphanumeric characters from 'featurename'
  # problem is there are duplicate values so i fix that as well
  features$featurename <- features$featurename %>% 
      str_replace_all("[^[:alnum:]]", "") %>% 
      tolower %>%
      make.unique(sep=".")
  
  features
}

# loads the activities file with fixed header
loadActivitiesFile <- function()
{
  # first check if the file exists
  activityFilePath <- "./UCI_HAR_Dataset/activity_labels.txt"
  if(!file.exists(activityFilePath))
  {
    # if not return error message
    stop("Activities file not found: '", activityFilePath, "'!")
  }
  
  # load activity label names and fix the header
  activities <- read.table(activityFilePath) %>%
      as_tibble %>%
      rename(activityid=V1, activityname=V2)
  
  activities
}

# load the test data and merges the labels, subjects and data into one dataset
loadData <- function(pathToDataFile, pathToLabelFile, pathToSubjectsFile, activities, features)
{
  if(!file.exists(pathToDataFile))
  {
    # if not return error message
    stop("Data file not found: '", pathToDataFile, "'!")
  }
  
  if(!file.exists(pathToLabelFile))
  {
    # if not return error message
    stop("Label file not found: '", pathToLabelFile, "'!")
  }
  
  if(!file.exists(pathToSubjectsFile))
  {
    # if not return error message
    stop("Subjects file not found: '", pathToSubjectsFile, "'!")
  }
  
  # load data file with feature names as column header
  myData <- read.table(pathToDataFile) %>% 
    as_tibble %>%
    rename_with(function(x) {features$featurename})
  
  # load label file and fix header
  myLabels <- read.table(pathToLabelFile) %>% 
    as_tibble %>% 
    rename(activityid=V1)
  
  # set activity names as label
  myLabels <- myLabels %>%
    left_join(activities, by=join_by(activityid)) %>% 
    select(activityname)
  
  # load subject ids
  mySubjects <- read.table(pathToSubjectsFile) %>% 
    as_tibble %>%
    rename(subjectid=V1)
  
  # merge everything together
  bind_cols(myLabels, mySubjects, myData)
}

testDataFilePath <- "./UCI_HAR_Dataset/test/X_test.txt"
testLabelsFilePath <- "./UCI_HAR_Dataset/test/y_test.txt"
testSubjectsFilePath <- "./UCI_HAR_Dataset/test/subject_test.txt"

trainingDataFilePath <- "./UCI_HAR_Dataset/train/X_train.txt"
trainingLabelsFilePath <- "./UCI_HAR_Dataset/train/y_train.txt"
trainingSubjectsFilePath <- "./UCI_HAR_Dataset/train/subject_train.txt"

activities <- loadActivitiesFile()

features <- loadFeaturesFile()

# load test data and add type as a new column
testData <- loadData(testDataFilePath, testLabelsFilePath, testSubjectsFilePath, activities, features) %>% 
  mutate(type = "test", .after = activityname)

# load training data and add type as a new column
trainingData <- loadData(trainingDataFilePath, trainingLabelsFilePath, trainingSubjectsFilePath, activities, features) %>% 
  mutate(type = "training", .after = activityname)

# merge into one set
mergedData <- union_all(testData, trainingData)

# only select mean and std columns from test and training data
mergedDataMeanStd <- select(mergedData, activityname, type, subjectid, contains("mean") | contains("std"))

# create a tidy dataset
tidyDataset <- pivot_longer(mergedDataMeanStd, !c(activityname, type, subjectid), names_to = "featurename", values_to = "featurevalue")
# transform feature names from unique back to original
tidyDataset <- tidyDataset %>% mutate(featurename = str_match(featurename, "^[a-zA-Z0-9]*"))

# create summary of features for each activity, subject and measured feature.
summaryDataset <- tidyDataset %>% group_by(activityname, subjectid, featurename) %>% summarise(mean = mean(featurevalue))

# write summary data to file
write.table(summaryDataset, "summaryTable.txt", row.name=FALSE)