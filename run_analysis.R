library(dplyr)

## Set the working directory
setwd("~/Desktop/Coursera/Getting & Cleaning Data/Project/")

## Load the training data and append the activity and subject columns. 
training = read.csv("UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
training[,562] = read.csv("UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training[,563] = read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

## Load the testing data and append the activity and subject columns. 
testing = read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing[,562] = read.csv("UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing[,563] = read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

## Merge training and test sets together into a data table and drop the original data frames.
dataSet = rbind(training, testing)
rm(testing)
rm(training)

## Load the activity table.
activity = read.csv("UCI HAR Dataset/activity_labels.txt", sep="", header=FALSE)

## Load the features table and update feature names
features = read.csv("UCI HAR Dataset/features.txt", sep="", header=FALSE)
features[,2] = gsub('-mean', 'Mean', features[,2])
features[,2] = gsub('-std', 'Std', features[,2])
features[,2] = gsub('[-()]', '', features[,2])

## Identify the columns on mean and standard deviation and update the features list
colsToKeep <- grep(".*Mean.*|.*Std.*", features[,2])
features <- features[colsToKeep,]

## Add subject and activity and update the data to only include the columns we want
colsToKeep <- c(colsToKeep, 562, 563)
dataSet <- dataSet[,colsToKeep]

## Update the column names in dataSet
colnames(dataSet) <- c(features$V2, "activity", "subject")
colnames(dataSet) <- tolower(colnames(dataSet))

currentActivity = 1
for (activityLabel in activity$V2) {
      dataSet$activity <- gsub(currentActivity, activityLabel, dataSet$activity)
      currentActivity <- currentActivity + 1
}

dataSet$activity <- as.factor(dataSet$activity)
dataSet$subject <- as.factor(dataSet$subject)

## Aggregate the data by activity and subject
tidy = aggregate(dataSet, by=list(activity = dataSet$activity, subject=dataSet$subject), mean)
tidy[,90] = NULL
tidy[,89] = NULL

## Write table to a text file in the working directory  
write.table(tidy, "tidy.txt", sep="\t")
