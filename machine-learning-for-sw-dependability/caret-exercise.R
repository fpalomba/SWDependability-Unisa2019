
# Install Caret package
install.packages("caret", dependencies=c("Depends", "Suggests"))
install.packages("DMwR", dependencies=c("Depends", "Suggests"))

# Upload Caret in our project
library(caret)
library(DMwR)
library(pROC)

# Importing the dataset
dataset <- read.csv("/Users/fabiopalomba/Desktop/dataset.csv", header=TRUE, sep=",")
summary(dataset$is_smelly)

############ Exercise 1 - Building a simple model ############

# Defining the training options - A simple 10-fold cross validation will be applied
train_control<- trainControl(method="cv", number=10, savePredictions = TRUE)

# Building the model - We will use a Random Forest classifier (rf)
simple_model <- train(dataset$is_smelly~., data=dataset, trControl=train_control, method="rf")

# Training accuracy
simple_model

############ Exercise 2 - Working on the dataset: Building a model where feature selection is applied ############

# Understanding variable importance
importance <- varImp(simple_model, scale=FALSE)

# Printing and plotting features based on their importance
print(importance)
plot(importance)

# Removing non-relevant features from the dataset using the Recursive Feature Elimination algorithm (RFE): 
#it has the goal of remove non-relevant features by recursively consider and evaluate smaller and smaller sets of features.

control <- rfeControl(functions=rfFuncs, method="cv", number=10)

# Run the RFE algorithm
results <- rfe(dataset[,1:41], dataset[,42], sizes=c(1:42), rfeControl=control)

# Print results
results

# Rebuilding the dataset - Dropping the non-relevant features
drops <- c("LCOM5_type","NOAM_type", "visibility_type", "modifier_type", "NOPA_type")
dataset <- dataset[ , !(names(dataset) %in% drops)]

# Defining the training options - A simple 10-fold cross validation will be applied
train_control<- trainControl(method="cv", number=10, savePredictions = TRUE)

# Building the model - We will use a Random Forest classifier (rf)
fe_model <- train(dataset$is_smelly~., data=dataset, trControl=train_control, method="rf")

# Training accuracy
fe_model

############ Exercise 3 - Working on the dataset (2): Balancing data with SMOTE ############
# SMOTE (Synthetic Minority Over-sampling) has the goal to over-sampling the minority class by creating "synthetic" examples.

# Defining the training options - A simple 10-fold cross validation will be applied
train_control<- trainControl(method="cv", number=10, sampling="smote", savePredictions = TRUE)

# Building the model - We will use a Random Forest classifier (rf)
balanced_model <- train(dataset$is_smelly~., data=dataset, trControl=train_control, method="rf")

# Training accuracy
balanced_model

############ Exercise 4 - Working on the model: Finding the best classifier configuration ############
# Grid search algorithm: it is basically a brute-force approach to estimate hyperparameters.

# Defining the training options - A simple 10-fold cross validation will be applied
train_control<- trainControl(method="cv", number=10, search="grid", sampling="smote", savePredictions = TRUE)

# Building the model - We will use a Random Forest classifier (rf)
configured_model <- train(dataset$is_smelly~., data=dataset, trControl=train_control, method="rf")

# Training accuracy
configured_model

############ Exercise 5 - Working on the validation strategy: is 10-fold cross validation enough? ############

# Defining the training options - A repeated 10-fold cross validation will be applied
train_control<- trainControl(method="repeatedcv", number=10, search="grid", sampling="smote", repeats=10, savePredictions = TRUE)

# Building the model - We will use a Random Forest classifier (rf)
n_configured_model <- train(dataset$is_smelly~., data=dataset, trControl=train_control, method="rf")

# Training accuracy
n_configured_model

############ Exercise 6 - Working on the validation strategy: adopting a percentage-split validation ############

# Defining the percentage of the dataset that will be used for training the model - in our case, 80%
split=0.80
trainIndex <- createDataPartition(dataset$is_smelly, p=split, list=FALSE)
data_train <- dataset[ trainIndex,]
data_test <- dataset[-trainIndex,]

# Train a Random Forest
model <- randomForest(data_train$is_smelly~., data=data_train, ntree=500, keep.forest=TRUE,importance=TRUE,oob.prox =FALSE)

# Make predictions
x_test <- data_test[,1:37]
y_test <- data_test[,38]
predictions <- predict(model, x_test)

# Summarize results
confusionMatrix(predictions, y_test, positive = "true")

# Printing confusion matric
confusionMatrix

############ Exercise 7 - What's wrong? ############

test_data <- read.csv("/Users/fabiopalomba/Desktop/test.csv", header=TRUE, sep=",")
summary(test_data$is_smelly)

######### Studying the simple model

# Applying the model on unseen data
predictions <- predict(simple_model,test_data)

# Including a the predictions as additional column of the dataset
test_data <- cbind(test_data,predictions)

# Computing the confusion matrix
confusionMatrix <- confusionMatrix(test_data$predictions,test_data$is_smelly,positive = "true")

# Printing confusion matric
confusionMatrix

######### Studying the model where feature selection was applied

# Storing the predictions
predictions<- predict(fe_model,test_data)

# Including a the predictions as additional column of the dataset
test_data <- cbind(test_data,predictions)

# Computing the confusion matrix
confusionMatrix<- confusionMatrix(test_data$predictions,test_data$is_smelly,positive = "true")

# Printing confusion matric
confusionMatrix

######### Studying the model where feature selection was applied

# Storing the predictions
predictions <- predict(balanced_model,test_data)

# Including a the predictions as additional column of the dataset
test_data <- cbind(test_data,predictions)

# Computing the confusion matrix
confusionMatrix<- confusionMatrix(test_data$predictions,test_data$is_smelly,positive = "true")

# Printing confusion matric
confusionMatrix

######### Studying the configured model

# Storing the predictions
predictions<- predict(configured_model,test_data)

# Including a the predictions as additional column of the dataset
test_data <- cbind(test_data,predictions)

# Computing the confusion matrix
confusionMatrix <- confusionMatrix(test_data$predictions,test_data$is_smelly,positive = "true")

# Printing confusion matric
confusionMatrix

######### Studying the n-configured model

# Storing the predictions
predictions<- predict(n_configured_model,test_data)

# Including a the predictions as additional column of the dataset
test_data <- cbind(test_data,predictions)

# Computing the confusion matrix
confusionMatrix<- confusionMatrix(test_data$predictions,test_data$is_smelly, positive = "true")

# Printing confusion matric
confusionMatrix

######## Computing AUC-ROC

predictions <- predict(object=simple_model, dataset, type='prob')

result.roc <- roc(dataset$is_smelly, predictions$versicolor) # Draw ROC curve.
plot(result.roc, print.thres="best", print.thres.best.method="closest.topleft")

result.coords <- coords(result.roc, "best", best.method="closest.topleft", ret=c("threshold", "accuracy"))
print(result.coords)#to get threshold and accuracy
