library(mlr3oml)
library(mlr3)

run_easy_workflow = function(task_id) {
  # Download and print the OpenML task with the provided task ID
  oml_task = otsk(task_id)
  print(oml_task)

  # Access the OpenML data object on which the task is built
  print(oml_task$data)

  # Convert the OpenML task to an mlr3 task and resampling
  task = as_task(oml_task)
  resampling = as_resampling(oml_task)

  # Conduct a simple resample experiment
  rr = resample(task, lrn("classif.rpart"), resampling)
  score = rr$aggregate()
  print(score)
}

# Supervised Classification on kr-vs-kp
# Task ID: 145953
# (3198*37) small dataset
run_easy_workflow(145953)


# Supervised Classification on physionet_sepsis
# Task ID: 363535
# (1552210*44) quite large dataset
run_easy_workflow(363535)