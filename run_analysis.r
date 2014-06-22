# require(sqldf)
# require(reshape2)
# require(plyr)

# train_x <- read.table("train/X_train.txt")
# subject_train = read.table("train/subject_train.txt")
# train_y <- read.table("train/Y_train.txt")
# 
# test_x <- read.table("test/X_test.txt")
# subject_test = read.table("test/subject_test.txt")
# test_y <- read.table("test/Y_test.txt")
# 
# featuresDF <- read.table("features.txt")
# activityDF <- read.table("activity_labels.txt")
# 
# # Step 1
# dfTrain <- train_x
# colnames <- as.vector(featuresDF[,2])
# colnames(dfTrain) <- colnames
# dfTrain$Activity <- as.vector(train_y)
# dfTrain[,"Activity"] <- as.vector(train_y)
# 
# dfTrain$Subject <- as.vector(subject_train)
# dfTrain[,"Subject"] <- as.vector(subject_train)
# 
# 
# dfTest <- test_x
# colnames <- as.vector(featuresDF[,2])
# colnames(dfTest) <- colnames
# 
# dfTest$Activity <- as.vector(test_y)
# dfTest[,"Activity"] <- as.vector(test_y)
# 
# dfTest$Subject <- as.vector(subject_test)
# dfTest[,"Subject"] <- as.vector(subject_test)
# 
# dfTotal <- rbind(dfTrain, dfTest)

#activityDF["ActivityName"] <- activityDF$V2

# Step 2
# Use SQL DF to pull out the column names we want
colNamesMeasDF <- sqldf("select * from featuresDF where V2 like '%std()%' or V2 like '%mean()%'")
colNamesMeasVect <- as.vector(colNamesMeasDF$V2)
colNamesMeasVectFull <- c(colNamesMeasVect, "Activity", "Subject")

# Subset to get our columns
dfMeas <- dfTotal[, colNamesMeasVectFull]

# Step 3
# Join in the activity names from the activit_labels.txt 
#dfMeasJoined <- sqldf("select dfMeas.*, activityDF.V2 as ActivityName from dfMeas inner join activityDF on activityDF.V1 = dfMeas.Activity")
dfMeasMerge <- merge(dfMeas, activityDF, by.x="Activity", by.y="V1")

# Step 4
# Kind of unsure if this is completed by renaming the columns from V1, v2, etc. to the names from features_info.txt
# For now I'm going to call that good in the interest of time, this was done as part of Step 1

# Step 5
#colNamesMeasVect <- as.vector(colNamesMeasVectFull$V2)
dfMeasMelt <- melt(dfMeasMerge, id=c("Subject", "ActivityName"), measure.vars = colNamesMeasVect)

dfFinal <- ddply(dfMeasMelt, .(Subject, ActivityName, variable), summarize, avg=mean(value))
dfFinalCast <- dcast(dfFinal, Subject + ActivityName ~ variable, value.var="avg")

write.csv(dfFinal, 'SamsungData.csv')

