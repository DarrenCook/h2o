data[,"petal_len"] <- data[,"petal_len"] * 1.2
data[,"ratio"] <- data[,"petal_wid"] / data[,"sepal_wid"]
h2o.sd(data[,"petal_len"])
h2o.cor(data[,"ratio"], data[,"petal_len"])
data[,"species"] <- h2o.gsub("Iris-", "", as.character(data[,"class"]) )
data[,"is_long"] <- ifelse(data[,"petal_len"] > mean(data[,"petal_len"]), 1, 0)

# Same code, different syntax
data$petal_len <- data$petal_len * 1.2
data$ratio <- data$petal_wid / data$sepal_wid
h2o.sd(data$petal_len)
h2o.cor(data$ratio, data$petal_len)
data$species <- h2o.gsub("Iris-", "", as.character(data$class) )
data$is_long <- ifelse(data$petal_len > mean(data$petal_len), 1, 0)