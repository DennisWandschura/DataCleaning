# Getting and Cleaning Data Course Project - Readme
In this project i had to create a tidy dataset based on provided wearable data, create a Codebook and this Readme file.

## Files
- *CodeBook.md*: Describes the used variables and its data-types.
- *README.md*: This file.
- *run_analysis.R*: File containing the script for the analysis, creates the file 'summaryTable.txt'.

## My work process
The first thing i did was download and check the data. It is important to understand what kind of data you have and how the data is connected.
Help was provided in with the wearable data included 'Readme.txt'.

- A total of 30 subjects.
- Subjects were split into two groups: Test and Train.
- Subjects performed activities.
- Measured data and corresponding activity and subject are saved separately.
- Measured data columns correspond to the features.

I then started working on the R-script.
Starting with the test data i loaded the 3 files 'subject_test.txt', 'X_test.txt' and 'y_test.txt' into data-frames.
Because the data of the three files belong together i merged them into one data-frame.
There were no headers contained in the files so the header names were auto-generated, which i tried to fix. 
The headers for the measurements was in the file 'features.txt', but while trying to use the values as header i noticed that not all values were unique.
I had to transform the feature-values to unique values before using them as table header.

After merging the test-data with the activities and using the features as header for the measurements i moved the code into functions, because i have to do exactly the same for the training-data.
I also made functions for loading the activity- and features-data, so that the specific code for those tasks is separated from the rest.

Now having the two data-frames, test and training, i had to merge those two together.
After merging you might want to tell if the data is from the test or training data, so i added a new column 'type' to each table and then merged the two.
I then filtered the data-frame so it only contains the measurements on the mean and standard deviation while still having the identifying columns for the activity, subject and type.

After preparing and filtering the data i had to create a tidy-dataset.
A tidy-dataset has the following three properties:

- Each variable must have its own column.
- Each observation must have its own row.
- Each value must have its own cell (SQL 1st normal form).

I had the following columns:  
activity, type, subject, feature1, feature2, feature3, etc.

In order to make the dataset tidy i had to transform the feature-columns into rows. I moved the feature-data into two new columns, featurename and featurevalue, and now every observation was in its own row.
Next i had to compute the average of each observation, but because i previously had made the feature-names unique (so i could use them as column header) i needed to fix that.
The reason for un-uniquing the feature-names is, if one would try to group the observations by feature-name there would be more features than in reality.

Finally i created the final table, which contains the mean of each feature-value grouped by activity, subject and feature-name.
I was also thinking of including the type, test or training, but because the subjects were split between the two i deemed it as unnecessary.

## What does the script do?
Please note that the function documentation does not show every line of code.

### Main part
I load the data from the files using the defined functions. In these functions i also do some processing of the data/headers. See below for more info for each function.  
  
After loading the file data i also append a new column 'type' to be able to tell the data apart.  
Example for the test-data:  
```
testData <- loadData(testDataFilePath, testLabelsFilePath, testSubjectsFilePath, activities, features) %>% 
  mutate(type = "test", .after = activityname)
```  
Then i merge the test and training data and filter the features
```
mergedData <- union_all(testData, trainingData)
mergedDataMeanStd <- select(mergedData, activityname, type, subjectid, contains("mean") | contains("std"))
```

After merging the data i create the tidy dataset
```
tidyDataset <- pivot_longer(mergedDataMeanStd, !c(activityname, type, subjectid), 
                            names_to = "featurename", values_to = "featurevalue")
```
And i fix the feature names. Duplicate entries were assigned a value like Feature12.1 and i change that value back into Feature12.
```
tidyDataset <- tidyDataset %>% 
  mutate(featurename = str_match(featurename, "^[a-zA-Z0-9]*"))
```

Finally i create the summary grouped by activity, subject and feature and write it to file.
```
summaryDataset <- tidyDataset %>% 
  group_by(activityname, subjectid, featurename) %>% 
  summarise(mean = mean(featurevalue))
write.table(summaryDataset, "summaryTable.txt", row.name=FALSE)
```

### loadFeaturesFile function
Returns a table of feature-ids and unique feature-names

First i check if the required file exists and if not i stop the exectution with an appropriate error message.
```
featuresFilePath <- "./UCI_HAR_Dataset/features.txt"
if(!file.exists(featuresFilePath))
{
  # if not return error message
  stop("Feature file not found: '", featuresFilePath, "';")
}
```

If the file exists i load the data and rename the column-headers to 'featureid' and 'featurename'.
```
features <- read.table(featuresFilePath) %>% 
  as_tibble %>% 
  rename(featureid=V1, featurename=V2)
```

I remove all non-alphanumeric characters from the feature-names and make them lower case. I also make them unique so can use them as column header.
```
features$featurename <- features$featurename %>% 
    str_replace_all("[^[:alnum:]]", "") %>% 
    tolower %>%
    make.unique(sep=".")
```

### loadActivitiesFile function
Returns a table of activity-ids and activity-names

Just like in the function loadFeaturesFile i first check if the required file exists before loading the data.
Before returning the loaded data i also rename the column-headers to 'activityid' and 'activityname'
```
activities <- read.table(activityFilePath) %>%
    as_tibble %>%
    rename(activityid=V1, activityname=V2)
```

### loadData function
Returns a table of activities, subjects and feature-measurements. Used for loading the test and training data.

Just like in the function loadFeaturesFile i first check if the required files exists before loading the data.
Loading the feature-measurements i rename the column headers with the previously loaded feature-names
```
myData <- read.table(pathToDataFile) %>% 
  as_tibble %>%
  rename_with(function(x) {features$featurename})
```

I then load the data-labels and rename the columns to 'activityid' and 'activityname'.
After loading the data-labels i join them with the previously loaded activities and just keep the activity-names.
```
myLabels <- myLabels %>%
  left_join(activities, by=join_by(activityid)) %>% 
  select(activityname)
```

Last file i am loading is the subject-data where i also rename the column to 'subjectid'.

At the end i just have to merge all my loaded columns into one table.
```
bind_cols(myLabels, mySubjects, myData)
```
