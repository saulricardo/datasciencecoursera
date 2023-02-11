# Needed libraries
library(data.table)
library(reshape2)

# Get the wd, ensure this is the place where you have your files
wd <- getwd()

# Grab labels adn features
activityLabel <- fread(file.path(wd, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(wd, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresNamesFiltered <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresNamesFiltered, featureNames]
measurements <- gsub('[()]', '', measurements)

# Get test data
test <- fread(file.path(wd, "UCI HAR Dataset/test/X_test.txt"))[, featuresNamesFiltered, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(wd, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(wd, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# Get train data
train <- fread(file.path(wd, "UCI HAR Dataset/train/X_train.txt"))[, featuresNamesFiltered, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(wd, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path(wd, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

# combine
combined <- rbind(train, test)

# better naming
combined[["Activity"]] <- factor(combined[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])

# Part 5 
combined2 <- combined
combined2[["SubjectNum"]] <- as.factor(combined2[, SubjectNum])
combined2 <- reshape2::melt(data = combined2, id = c("SubjectNum", "Activity"))
combined2 <- reshape2::dcast(data = combined2, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined2, file = "FinalData.txt", quote = FALSE)