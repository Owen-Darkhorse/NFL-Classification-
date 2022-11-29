library(tidyverse)
library(xgboost)
library(tree)
library(boot)
library(kableExtra)
library(ggplot2)

##################### Basic Procedures ##################################
## Training testing split
train_test_split <- function(dataset, trainPercentage = 70) {
  samp.size <- nrow(dataset)
  train.size <- samp.size * trainPercentage / 100 %>% floor()
  
  train.indx <- sample(1:samp.size, train.size)
  train.set <- dataset[train.indx,]
  test.set <- dataset[-train.indx, ]
  
  return(list("Train" = train.set, "Test" = test.set))
}

## Fit the model on the training data
## Return training error
## Test error estimation
## Display model details
## You can supply additional arguements
## Default type is "response" for categorical variable
## Default threshold for positive case is 0.5
buildModel <- function(train.set, test.set, x.var, y.var, 
                       model, type = "response", threshold = 0.5, ...){
  # Convert strings into variable names
  model.formula <- formula(paste(y.var,"~",paste(x.var, collapse = "+")))
  
  # train.set <- train.set[, c(x.var, y.var)]
  # test.set <- train.set[, c(x.var, y.var)]
  # browser()
  fittedModel <- model(model.formula, data = train.set, ...)
  
  
  ## Numerical or categorical data type
  response.type <- ifelse(class(y.var) == "numeric", "numeric", "character")
  
  test.error <- NULL; train.error <- NULL
  if (response.type == "numeric") {
    predictions <- predict(fittedModel, newdata = test.set)
    train.error <- mean((train.set[, y.var] - fittedModel$fitted.values)^2)
    test.error <- mean((test.set[, y.var] - predictions)^2)
    
  ## Tentatively for binary response usage
  } else if (response.type == "character") {
    # predictions <- predict(fittedModel, newdata = test.set, type = "response")
    fitted.type = predict(fittedModel, newdata = train.set, type = "response") ## convert numbers to character
    pred.type = predict(fittedModel, newdata = test.set, type = "response")
    
    train.error <- mean(train.set[, y.var] == fitted.type)
    test.error <- mean(test.set[, y.var] == pred.type)
  }
  
  print("The training & testing errors are")
  test.result <- data.frame(
    "Training Error" = train.error,
    "Test Error" = test.error
  ) %>% round(2) %>% kableExtra::kable()
  print(test.result)
  
  print(fittedModel$fitted.values[1:10])
  fittedModel
   
}

## K-fold Cross validation
## Choose the optimal tuning parameter one at a time
## model is a function from packages
## User supplies a vector of tuning Parameters
cvAndtestError <- function(train.set, model, lossFn, K, tuningParam) {
  
  cv.error.arr <- c()
  for (i in tuningParam) {
    fittedModel <- model(train.set, tuningParam)
    cv.out <- cv.glm(train.set, glmfit = model, cost = lossFn, K = K)
    cv.error <- cv.out$delta[1]
    cv.error.arr <- c(cv.error.arr, cv.error)
  }
  
  cv.error.frame <- data.frame(tuning.Param, cv.error.arr)
  min.error.row <- slice_min(cv.error.frame, order_by = cv.error.arr)
  geom_line(data = cv.error.frame, x = tuningParam, y = cv.error.arr) + 
    # Horizontal Line for optimal tuning parameter
    geom_hline(yintercept = min.error.row[2], linetype = 2, col = "grey")  + 
    # Vertical line for optimal tuning parameter
    geom_vline(xintercept = min.error.row[2], linetype = 2, col = "grey")
  
  list("complete erorr frame" = cv.error.frame, 
       "optimal  parameter" = min.error.row)
}


#################### More Error estimation #########################




################### Main Function calls everything ####################

main <- function(dataset, trainPercentage, x.var, y.var, 
                 Kfold, model, tuniningParam, lossFn) {
  
  split <- train_test_split(dataset, trainPercentage)
  modelResult <- buildModel(split$train.set, split$test.set, x.var, y.var, model, ...)
  cvResult <- cvAndtestError(train.set, model, lossFn, K, tuningParam)
  
  list(modelResult, cvResult)
}



################### Use Cases #########################################
library(ISLR2); library(MASS)
data(iris); data(College); data(Smarket)
## Linear Regression
college.split <- train_test_split(College)
x.var <- c("Outstate", "Expend", "Room.Board"); y.var <- "Apps"
college.fitted <- buildModel(college.split[[1]], college.split[[2]], x.var, y.var, lm)
# college.names <- names(college.fitted$fitted.values)
# college.fitted$fitted.values == College[college.names,"Apps"]

## Logistic Regression
smarket.split <- train_test_split(Smarket)
smarket.fitted <- buildModel(smarket.split$Train, smarket.split$Test, 
                             x.var = paste0("Lag", 1:3), y.var = "Direction",
                             glm,  family = binomial())
smarket.fitted

## Regression Tree
iris.split <- train_test_split(iris)
iris.fitted <- buildModel(iris.split$Train, iris.split$Test, 
                          x.var = names(iris)[-5], y.var = "Species",
                          tree)
plot(iris.fitted); text(iris.fitted)

## SVM 






