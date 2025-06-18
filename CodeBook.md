# Getting and Cleaning Data Course Project - Codebook

## Variables used during main part
| Column | Datatype | Description |
| --- | --- | --- |
| testDataFilePath | character | Filepath to the test-data file |
| testLabelsFilePath | character | Filepath to the test-label file |
| testSubjectsFilePath | character | Filepath to the test-subjects file |
| trainingDataFilePath | character | Filepath to the training-data file |
| trainingLabelsFilePath | character |  Filepath to the training-labels file |
| trainingSubjectsFilePath | character | Filepath to the training-subjects file |
| activities | data.frame | List of activities |
| features | data.frame | List of measured features |
| testData | data.frame | Training data containing the activies, subjects and measurements |
| trainingData | data.frame | Training data containing the activies, subjects and measurements |
| mergedData | data.frame | Merged test- and training-data |
| mergedDataMeanStd | data.frame | Merded dataset with only measurements of the average and standard deviation |
| tidyDataset | data.frame | Tidy dataset of mergedDataMeanStd where each observation is in its own row |
| summaryDataset | data.frame | Contains the summarized tidy dataset |

## Used columns in 'summaryDataset'
| Column | Datatype | Description |
| --- | --- | --- |
| activityname | character | Names of the measured activities |
| subjectid | integer | Ids of the subject. |
| featurename | character | Names of the measured features |
| mean | numeric | Average value of the measured features |