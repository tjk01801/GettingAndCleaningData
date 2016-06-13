# The reshape2 library will be used. For more information go to http://seananderson.ca/2013/10/19/reshape.html
library(reshape2)

# Performing the file download

  filename<- "getdata_dataset.zip"
  
  #Now, download the file from the site given from the Getting and Cleaning Data Course Project page.
  if(!file.exists(filename)){
    fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl,filename)
  }
  
  if(!file.exists("UCI HAR Dataset"))
  {
    unzip(filename)
  }

# Peforming setting up the data 

  # Once we have the files downloaded, we need to prepare it for cleaning it up.
  labelsForActivities <- read.table("UCI HAR Dataset/activity_labels.txt")   
  labelsForActivities[,2] <- as.character(activityLabels[,2])
  featuresForActivities <- read.table("UCI HAR Dataset/features.txt")
  featuresForActivities[,2] <- as.character(featuresForActivities[,2])
  
  
  # Only data that represents mean and standard deviation is needed.
  activityMeanStd <- grep(".*mean.*|.*std.*", featuresForActivities[,2])
  activityMeanStd.names <- features[activityMeanStd,2]
  activityMeanStd.names = gsub('-mean', 'Mean', activityMeanStd.names)
  activityMeanStd.names = gsub('-std', 'Std', activityMeanStd.names)
  activityMeanStd.names <- gsub('[-()]', '', activityMeanStd.names)
  
  # Load the datasets
  # Training data
  train <- read.table("UCI HAR Dataset/train/X_train.txt")[activityMeanStd]
  activitiesForTrain <- read.table("UCI HAR Dataset/train/Y_train.txt")
  subjectsForTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
  train <- cbind(trainSubjects, trainActivities, train)
  
  # Test data
  test <- read.table("UCI HAR Dataset/test/X_test.txt")[activityMeanStd]
  activitiesForTest <- read.table("UCI HAR Dataset/test/Y_test.txt")
  subjectsForTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
  test <- cbind(subjectsForTest, activitiesForTest, test)
  
# Performing Data Shaping and manipulation  
  # Merge the train and test datasets and apply the labels
  allData <- rbind(train, test)
  colnames(allData) <- c("subject", "activity", activityMeanStd.names)
  
  # Create the factors out of the activities and the subjects
  allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
  allData$subject <- as.factor(allData$subject)
  
  # We will use the melt method to condense the wide data into a single column of data. More information can be found at http://www.r-bloggers.com/melt/
  allData.melt <- melt(allData, id = c("subject", "activity"))
  allData.mean <- dcast(allData.melt, subject + activity ~ variable, mean)
  
  #output the data to a file
  write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
  