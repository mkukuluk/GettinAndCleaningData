#Step 1
# reading the data into variables
testLabels <- read.table("UCIHARData/test/y_test.txt", col.names="label")
testSubjects <- read.table("UCIHARData/test/subject_test.txt", col.names="subject")
testData <- read.table("UCIHARData/test/X_test.txt")
trainLabels <- read.table("UCIHARData/train/y_train.txt", col.names="label")
trainSubjects <- read.table("UCIHARData/train/subject_train.txt", col.names="subject")
trainData <- read.table("UCIHARData/train/X_train.txt")

# put the data format: subjects, labels, others
allData <- rbind(cbind(testSubjects, testLabels, testData),
              cbind(trainSubjects, trainLabels, trainData))

# Step 2
# read the features data
features <- read.table("UCIHARData/features.txt", strip.white=TRUE, stringsAsFactors=FALSE)

# we need to get only features of mean and standard deviation
featuresMeanStdv <- features[grep("mean\\(\\)|std\\(\\)", features$V2),]

# select only the means and standard devs from allData
# increase by 2 because we have subjects and labels in the beginning
allDataMeanStdv <- allData[, c(1, 2, featuresMeanStdv$V1+2)]

#Step 3
# read the labels (activities)
labels <- read.table("UCIHARData/activity_labels.txt", stringsAsFactors=FALSE)
# replace allData labels with the label names
allDataMeanStdv$label <- labels[allDataMeanStdv$label, 2]

# Step 4
# first make a list of the current column names and feature names
currColnames <- c("subject", "label", featuresMeanStdv$V2)
# then tidy that list
# by removing every non-alphabetic character and converting to lowercase
currColnames <- tolower(gsub("[^[:alpha:]]", "", currColnames))
# then use the list as column names for data
colnames(allDataMeanStdv) <- currColnames

#Step 5
# find the mean for all combinations of subject and label
aggrData <- aggregate(allDataMeanStdv[, 3:ncol(allDataMeanStdv)],
                       by=list(subject = allDataMeanStdv$subject, 
                               label = allDataMeanStdv$label),
                       mean)

# write the data
write.table(format(aggrData, scientific=T), "TidyData.txt",
            row.names=F, col.names=F, quote=2)
