import h2o
h2o.init()

###############
# From dictionary

patients = {
  'height':[188, 157, 175],
  'age':[29, 33, 65],
  'risk':['A', 'B', 'B']
  }
df = h2o.H2OFrame(patients)

###############
# From dictionary, with customization

patients = {
  'height':[188, 157, 175.1],
  'age':[29, 33, 65],
  'risk':['A', 'B', 'B']
  }
df = h2o.H2OFrame.from_python(
  patients,
  column_types=['enum', None, None],
  destination_frame="patients"
  )

df.types
df.frame_id


###################
import pandas as pd
patients = pd.DataFrame({
  'height':[188, 157, 175.1],
  'age':[29, 33, 65],
  'risk':['A', 'B', 'B']
  }
df = h2o.H2OFrame(patients)
df.types
df.frame_id

#############
patients = pd.DataFrame({
  'height':[188, 157, 175.1],
  'age':[29, 33, 65],
  'risk':['A', 'B', 'B']
  })
df = h2o.H2OFrame.from_python(
  patients,
  column_names=patients.columns.tolist()
  )
df.types
df.frame_id

