
iris.csv: The iris data set, without headers.  (Used in chapter 2)
iris_wheader.csv: The iris data set, with headers.  (Used in chapter 1)

ENB2012_data.csv:  The Building Energy data set. Introduced in chapter 3, and used in chapters 5 to 8.

mnist.train.csv.gz: The 60,000 training rows for MNIST.  Introduced in chapter 3, and used in chapters 5 to 8.
mnist.test.csv.gz: The 10,000 test rows for MNIST.  Introduced in chapter 3, and used in chapters 5 to 8.

mnist.enhanced_train.csv.gz: The 50,000 row training MNIST data, with extra columns.  Introduced in chapter 3, and used in chapters 5 to 8.
mnist.enhanced_valid.csv.gz: The 10,000 row validation MNIST data, with extra columns.  Introduced in chapter 3, and used in chapters 5 to 8.
mnist.enhanced_test.csv.gz: The 10,000 row test MNIST data, with extra columns.  Introduced in chapter 3, and used in chapters 5 to 8.

football.train.csv, football.valid.csv, football.test.csv:  The training, validation and test data for the Football data set.  Introduced in chapter 3, and used in chapters 5, 6 and 9. This is the version with missing data.
football.train2.csv, football.valid2.csv, football.test2.csv are the same files after the missing data repair (described in chapter 9, and used in chapters 7 and 8).

england/2013_2014/ contains the raw football data used in chapter 3. Note: the book gives a command to load this directory directly from GitHub, but `h2o.importFolder()` does not work with http. So, you need to have downloaded the files, and load them that way.

By the way, you can get the raw data for other years from https://github.com/jokecamp/FootballData/tree/master/football-data.co.uk/england. (Simplest to download the whole repository, then delete directories you don't need; wasteful, but simple.)
