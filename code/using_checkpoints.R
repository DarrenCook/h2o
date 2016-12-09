y <- "income"
x <- c("age", "gender")

m1 <- h2o.deeplearning(x, y, train, model_id = "DL:50x50-5", hidden = c(50,50),  epochs = 5)

m2 <- h2o.deeplearning(x, y, train, model_id = "DL:50x50-15", hidden = c(50,50),  epochs = 15, checkpoint = "DL:50x50-5")
