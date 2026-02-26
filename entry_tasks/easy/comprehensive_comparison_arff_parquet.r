library(mlr3oml)
library(mlr3)


run_experiment_easy = function(task_id) {
  cache_dir = getOption("mlr3oml.cache")

  clear_cache = function() {
    if (dir.exists(cache_dir)) {
      unlink(cache_dir, recursive = TRUE, force = TRUE)
    }
  }

  print_file_sizes = function(label) {
    print(label)
    files = list.files(cache_dir, full.names = TRUE, recursive = TRUE)
    if (length(files) == 0L) {
      print(data.frame(size = numeric(0)))
    } else {
      print(file.info(files)[, "size", drop = FALSE])
    }
  }

  print(paste("Task ID:", task_id))
  print(paste("Cache directory:", cache_dir))

  print("--- ARFF: download + read ---")
  clear_cache()
  time_arff_download_task = system.time({
    task_arff_download = otsk(task_id, parquet = FALSE)
  })
  print("ARFF task object creation time (download path):")
  print(time_arff_download_task)

  time_arff_download_data = system.time({
    task_arff_download$data$data
  })
  print("ARFF data materialization time (download path):")
  print(time_arff_download_data)
  print_file_sizes("--- ARFF cache files after download path ---")

  print("--- ARFF: read from cache ---")
  time_arff_cache_task = system.time({
    task_arff_cache = otsk(task_id, parquet = FALSE)
  })
  print("ARFF task object creation time (cache path):")
  print(time_arff_cache_task)

  time_arff_cache_data = system.time({
    task_arff_cache$data$data
  })
  print("ARFF data materialization time (cache path):")
  print(time_arff_cache_data)
  print_file_sizes("--- ARFF cache files after cache path ---")

  print("--- Parquet: download + read ---")
  clear_cache()
  time_parquet_download_task = system.time({
    task_parquet_download = otsk(task_id, parquet = TRUE)
  })
  print("Parquet task object creation time (download path):")
  print(time_parquet_download_task)

  time_parquet_download_data = system.time({
    task_parquet_download$data$data
  })
  print("Parquet data materialization time (download path):")
  print(time_parquet_download_data)
  print_file_sizes("--- Parquet cache files after download path ---")

  print("--- Parquet: read from cache ---")
  time_parquet_cache_task = system.time({
    task_parquet_cache = otsk(task_id, parquet = TRUE)
  })
  print("Parquet task object creation time (cache path):")
  print(time_parquet_cache_task)

  time_parquet_cache_data = system.time({
    task_parquet_cache$data$data
  })
  print("Parquet data materialization time (cache path):")
  print(time_parquet_cache_data)
  print_file_sizes("--- Parquet cache files after cache path ---")
  clear_cache()
}

# Examples:
# run_experiment_easy(145953) # small dataset (3198*37)
run_experiment_easy(363535) # quite large dataset (1552210*44)
# run_experiment_easy(167050) # quite large dataset (1076790*30)
# run_experiment_easy(146606) # medium dataset (98050*29)