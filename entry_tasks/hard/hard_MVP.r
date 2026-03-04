library(httr2)
library(duckdb)
library(DBI)
library(mlr3)
library(mlr3db)
library(data.table)

req <- request("https://datasets-server.huggingface.co/parquet") |>
  req_url_query(dataset = "fka/prompts.chat") |>
  req_retry(max_tries = 3)

resp <- req_perform(req)

meta <- resp |> resp_body_json()

print("--------------------------------")
print("1. Metadata: result of the query using httr2")
print(meta)


parquet_url <- meta$parquet_files[[1]]$url 

tmp_file <- tempfile(fileext = ".parquet")

meta$parquet_files[[1]]$url |>
  request() |>
  req_perform(path = tmp_file)

con <- dbConnect(duckdb::duckdb())
res <- dbGetQuery(con, sprintf("SELECT * FROM read_parquet('%s') LIMIT 5", tmp_file))
print("--------------------------------")
print("2. Parquet Data: result of the query directly using duckdb query")
print(res)


backend <- as_duckdb_backend(tmp_file)
print("--------------------------------")
print("3. Backend: result of the query using mlr3db")
print(backend)

dt <- backend$data(rows = backend$rownames, cols = backend$colnames)

dt[, for_devs := as.factor(for_devs)]
dt[, mlr3_row_id := NULL]

task <- as_task_classif(dt, target = "for_devs", id = "hf_prompts_task")
print("--------------------------------")
print("4. Task: result of the query using mlr3")
print(task)

print("--------------------------------")
print("5. Walk through a machine learning pipeline")
learner <- lrn("classif.rpart") 

resampling <- rsmp("cv", folds = 10)

rr <- resample(task, learner, resampling)

print(rr$aggregate(msr("classif.ce")))