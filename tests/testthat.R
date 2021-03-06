library(testthat)
library(EpiEstimApp)
library(subprocess)
library(devtools)
library(httr)

# Helper functions:
is_windows <- function () (tolower(.Platform$OS.type) == "windows")

R_binary <- function () {
  R_exe <- ifelse (is_windows(), "R.exe", "R")
  return(file.path(R.home("bin"), R_exe))
}

# Start the server
cat("Starting app\n")
handle <- spawn_process(R_binary(), c('--no-save'))
process_write(handle, "EpiEstimApp::runEpiEstimApp(port=3000)\n")
cat("Waiting for app to start...\n")
timeout <- 600
t <- 0
while (t < timeout) {
  tryCatch({
      res <- GET("http://localhost:3000")
      if (res$status == 200) {
          break()
      }
  }, error = function(e) {
     # Ignore "could not connect to server" etc
  })
  t <- t + 1
  Sys.sleep(1)
}
cat("App started. Running tests\n")
tryCatch({
    test_check("EpiEstimApp")
    cat("Tests finished.\n")
  },
  error = function(e) {
    cat("An error occured.\n")
    cat("\n\n\nPrinting output from app's STDOUT:\n")
    cat(process_read(handle, PIPE_STDOUT, timeout=1000), sep="\n")
    cat("\n\n\nPrinting output from app's STDERR:\n")
    cat(process_read(handle, PIPE_STDERR), sep="\n")
    cat("Throwing error\n")
    stop(e)
  })
cat("Closing App\n")
process_kill(handle)
cat("Done running testthat\n")
