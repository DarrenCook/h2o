import h2o
h2o.init()

datasets = "https://raw.githubusercontent.com/DarrenCook/h2o/bk/datasets/"
data = h2o.import_file(datasets + "iris_wheader.csv")
data.frame_id  #iris_wheader.hex

data = data[:,1:] #Drop column 0. Keep column 1 onwards.
data.frame_id  #py_2_sid_88fe

data = h2o.assign(data, "iris")
data.frame_id  #iris

h2o.ls()  #iris and iris_wheader.hex, no py_2_sid_88fe
h2o.remove("iris_wheader.hex")
h2o.ls()  #Just lists iris
