# checking if the data file is already downloaded or not. if not, no need to download once again

if (!file.exists("UCI HAR Dataset"))
{
# downloading data file
temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
#unzipping
unzip(temp)
unlink(temp)
}

# storing current working directory for creating tidy data file alter
curDir<-getwd() # save location of the working directory the script was launched from
setwd(curDir)

# changing working directory to directory where data file are unzipped
setwd("UCI HAR Dataset/")
# Reading features 
features <- read.table("features.txt")["V2"]
# Reading activity labels
activity_lables<-read.table("activity_labels.txt")["V2"]
# finding the indices of features which contain either "mean" or "std" in their names
indices_mean_std_of_col <- grep("mean|std", features$V2)

# changing the working directory to train where training data files are stored
setwd("train/")
# Reading X- axis traning data
x_train<- read.table("X_train.txt")
# labeling the columns with features as training data file does not have headers
names(x_train)<-features$V2

# Reading Y- train data
y_train <- read.table("Y_train.txt")

# Labeling Y-train data as Lables
names(y_train) <- "labels"

#Reading training subjects data set
subject_train <- read.table("subject_train.txt")
# Labeling subjects data as "Subjects"
names(subject_train) <- "subjects"

#Changing the working directory to test where test data set is stored
setwd("../test/")
# Reading X-Test data set
x_test<- read.table("X_test.txt")
# Labeling X-Test data frame
names(x_test)<-features$V2
#Reading Y-Test data
y_test <- read.table("Y_test.txt")
#Labeling the data 
names(y_test) <- "labels"

subject_test <- read.table("subject_test.txt")
names(subject_test) <- "subjects"


# Extraing subset fro training data based features required
mean_and_std_colnames <- colnames(x_train)[indices_mean_std_of_col]

#subsetting Training data 
x_train_subset <- subset(x_train, select = mean_and_std_colnames)

#merging training data set
xy_train_merge <- cbind(subject_train, y_train, x_train_subset)

#subsetting test data 
x_test_subset <- subset(x_test, select = mean_and_std_colnames)
#merging test data
xy_test_merge <- cbind(subject_test, y_test, x_test_subset)

#merging train and test data
train_test_merge <- rbind(xy_train_merge, xy_test_merge)

# creation of tidy data set
tidy_data <- aggregate(train_test_merge[,3:ncol(train_test_merge)], list(subject = train_test_merge$subjects, activity = train_test_merge$labels), mean)
tidy_data <- tidy_data[order(tidy_data$subject),]
tidy_data$activity <- activity_lables[tidy_data$activity,]
setwd(curDir)
write.table(tidy_data, file ="./tidy_data.txt", sep ="/t", row.names = FALSE)

