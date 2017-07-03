context("Test Suite 4 (E2E) --> Endpoint 9.1")

library(RSelenium)
library(testthat)
library(EpiEstim)
source("functions.R", local=TRUE)



# ---------------------------------------------------------------------------#
# Test 6 - Different init.pars                                               #
# ---------------------------------------------------------------------------#
drivers <- getRemDrivers("Test Suite 4 (E2E) --> Endpoint 9.1 (Test 6)")
rD <- drivers$rDr
remDr <- drivers$remDr

appOut <- NULL
openRemDriver(remDr)
tryCatch({
  test_that("can connect to app", {
    connectToApp(remDr)
  })

  test_that("app is ready within 30 seconds", {
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC
  })

  test_that("can walk through the app to endpoint state (Test 6)", {
      # Walk the app through to endpoint state with default inputs
    click(remDr, pages$state1.1$selectors$preloadedDataButton)
    clickNext(remDr) # Move to state 2.2
    waitForStateDisplayed(remDr, "2.2")
    click(remDr, pages$state2.2$selectors$datasetOption1Input)
    clickNext(remDr) # Move to state 5.1
    waitForStateDisplayed(remDr, "5.1")
    click(remDr, pages$state5.1$selectors$exposureDataYesInput)
    clickNext(remDr) # Move to state 6.1
    waitForStateDisplayed(remDr, "6.1")
    click(remDr, pages$state6.1$selectors$SIDataTypeOwnButton)
    clickNext(remDr) # Move to state 7.2
    waitForStateDisplayed(remDr, "7.2")
    click(remDr, pages$state7.2$selectors$SIFromRawButton)
    clickNext(remDr) # Move to state 8.2
    waitForStateDisplayed(remDr, "8.2")
    if (getAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "value") == "") {
      # SAUCELABS gives an error about interacting with an element
      # which is not currently visible. Explicitly show the element
      # first to fix this?
      setAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "style", "display: block;")
      path <- getFilePath(remDr, "datasets/SerialIntervalData/EcuadorRotavirus.csv")
      sendKeys(remDr, pages$state8.2$selectors$SIDataUploadInput,
               path)
    }
    sendKeys(remDr, pages$state8.2$selectors$seedInput, "1")
    clickNext(remDr) # Move to state 9.1
    waitForStateDisplayed(remDr, "9.1")
    sendKeys(remDr, pages$state9.1$selectors$seedInput, "1")
    sendKeys(remDr, pages$state9.1$selectors$param1Input, "2") # <---
    sendKeys(remDr, pages$state9.1$selectors$param2Input, "1") # <---
    clickGo(remDr)
    Sys.sleep(1)
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC

    appOut <<- extractOutputFromApp(remDr)
    closeRemDrivers(remDr, rD)
  })
},
error = function(e) {
  closeRemDrivers(remDr, rD)
  stop(e)
})


test_that("Test 6 output matches", {
  # Compare the output to EpiEstim's output
  I <- read.csv(paste(appDir, "datasets/IncidenceData/PennsylvaniaH1N1.csv", sep="/"), header=FALSE)
  I <- EpiEstim:::process_I(I)
  SI.Data <- read.csv(paste(appDir, "datasets/SerialIntervalData/EcuadorRotavirus.csv", sep="/"), header=FALSE)
  SI.Data <- EpiEstim:::process_SI.Data(SI.Data)

  epiEstimOut <- EstimateR(I, T.Start=2:25, T.End=8:31, SI.Data=SI.Data,
                           SI.parametricDistr="G", method="SIFromData", n1=500,
                           n2=100, seed=1, MCMC.control=list(burnin=3000, thin=10, seed=1, init.pars=c(2,1)))

  compareOutputFromApp(appOut, epiEstimOut)
})



# ---------------------------------------------------------------------------#
# Test 7 - Different distribution (1)                                        #
# ---------------------------------------------------------------------------#
drivers <- getRemDrivers("Test Suite 4 (E2E) --> Endpoint 9.1 (Test 7)")
rD <- drivers$rDr
remDr <- drivers$remDr

appOut <- NULL
openRemDriver(remDr)
tryCatch({
  test_that("can connect to app", {
    connectToApp(remDr)
  })

  test_that("app is ready within 30 seconds", {
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC
  })

  test_that("can walk through the app to endpoint state (Test 7)", {
      # Walk the app through to endpoint state with default inputs
    click(remDr, pages$state1.1$selectors$preloadedDataButton)
    clickNext(remDr) # Move to state 2.2
    waitForStateDisplayed(remDr, "2.2")
    click(remDr, pages$state2.2$selectors$datasetOption1Input)
    clickNext(remDr) # Move to state 5.1
    waitForStateDisplayed(remDr, "5.1")
    click(remDr, pages$state5.1$selectors$exposureDataYesInput)
    clickNext(remDr) # Move to state 6.1
    waitForStateDisplayed(remDr, "6.1")
    click(remDr, pages$state6.1$selectors$SIDataTypeOwnButton)
    clickNext(remDr) # Move to state 7.2
    waitForStateDisplayed(remDr, "7.2")
    click(remDr, pages$state7.2$selectors$SIFromRawButton)
    clickNext(remDr) # Move to state 8.2
    waitForStateDisplayed(remDr, "8.2")
    if (getAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "value") == "") {
      # SAUCELABS gives an error about interacting with an element
      # which is not currently visible. Explicitly show the element
      # first to fix this?
      setAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "style", "display: block;")
      path <- getFilePath(remDr, "datasets/SerialIntervalData/EcuadorRotavirus.csv")
      sendKeys(remDr, pages$state8.2$selectors$SIDataUploadInput,
               path)
    }
    sendKeys(remDr, pages$state8.2$selectors$seedInput, "1")
    clickNext(remDr) # Move to state 9.1
    waitForStateDisplayed(remDr, "9.1")
    click(remDr, pages$state9.1$selectors$distributionOption2Input) # <--
    sendKeys(remDr, pages$state9.1$selectors$seedInput, "1")
    clickGo(remDr)
    Sys.sleep(1)
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC

    appOut <<- extractOutputFromApp(remDr)
    closeRemDrivers(remDr, rD)
  })
},
error = function(e) {
  closeRemDrivers(remDr, rD)
  stop(e)
})


test_that("Test 7 output matches", {
  # Compare the output to EpiEstim's output
  I <- read.csv(paste(appDir, "datasets/IncidenceData/PennsylvaniaH1N1.csv", sep="/"), header=FALSE)
  I <- EpiEstim:::process_I(I)
  SI.Data <- read.csv(paste(appDir, "datasets/SerialIntervalData/EcuadorRotavirus.csv", sep="/"), header=FALSE)
  SI.Data <- EpiEstim:::process_SI.Data(SI.Data)

  epiEstimOut <- EstimateR(I, T.Start=2:25, T.End=8:31, SI.Data=SI.Data,
                           SI.parametricDistr="off1G", method="SIFromData", n1=500,
                           n2=100, seed=1, MCMC.control=list(burnin=3000, thin=10, seed=1))

  compareOutputFromApp(appOut, epiEstimOut)
})



# ---------------------------------------------------------------------------#
# Test 8 - Different distribution (1)                                        #
# ---------------------------------------------------------------------------#
drivers <- getRemDrivers("Test Suite 4 (E2E) --> Endpoint 9.1 (Test 8)")
rD <- drivers$rDr
remDr <- drivers$remDr

appOut <- NULL
openRemDriver(remDr)
tryCatch({
  test_that("can connect to app", {
    connectToApp(remDr)
  })

  test_that("app is ready within 30 seconds", {
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC
  })

  test_that("can walk through the app to endpoint state (Test 8)", {
      # Walk the app through to endpoint state with default inputs
    click(remDr, pages$state1.1$selectors$preloadedDataButton)
    clickNext(remDr) # Move to state 2.2
    waitForStateDisplayed(remDr, "2.2")
    click(remDr, pages$state2.2$selectors$datasetOption1Input)
    clickNext(remDr) # Move to state 5.1
    waitForStateDisplayed(remDr, "5.1")
    click(remDr, pages$state5.1$selectors$exposureDataYesInput)
    clickNext(remDr) # Move to state 6.1
    waitForStateDisplayed(remDr, "6.1")
    click(remDr, pages$state6.1$selectors$SIDataTypeOwnButton)
    clickNext(remDr) # Move to state 7.2
    waitForStateDisplayed(remDr, "7.2")
    click(remDr, pages$state7.2$selectors$SIFromRawButton)
    clickNext(remDr) # Move to state 8.2
    waitForStateDisplayed(remDr, "8.2")
    if (getAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "value") == "") {
      # SAUCELABS gives an error about interacting with an element
      # which is not currently visible. Explicitly show the element
      # first to fix this?
      setAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "style", "display: block;")
      path <- getFilePath(remDr, "datasets/SerialIntervalData/EcuadorRotavirus.csv")
      sendKeys(remDr, pages$state8.2$selectors$SIDataUploadInput,
               path)
    }
    sendKeys(remDr, pages$state8.2$selectors$seedInput, "1")
    clickNext(remDr) # Move to state 9.1
    waitForStateDisplayed(remDr, "9.1")
    click(remDr, pages$state9.1$selectors$distributionOption3Input) # <--
    sendKeys(remDr, pages$state9.1$selectors$seedInput, "1")
    clickGo(remDr)
    Sys.sleep(1)
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC

    appOut <<- extractOutputFromApp(remDr)
    closeRemDrivers(remDr, rD)
  })
},
error = function(e) {
  closeRemDrivers(remDr, rD)
  stop(e)
})


test_that("Test 8 output matches", {
  # Compare the output to EpiEstim's output
  I <- read.csv(paste(appDir, "datasets/IncidenceData/PennsylvaniaH1N1.csv", sep="/"), header=FALSE)
  I <- EpiEstim:::process_I(I)
  SI.Data <- read.csv(paste(appDir, "datasets/SerialIntervalData/EcuadorRotavirus.csv", sep="/"), header=FALSE)
  SI.Data <- EpiEstim:::process_SI.Data(SI.Data)

  epiEstimOut <- EstimateR(I, T.Start=2:25, T.End=8:31, SI.Data=SI.Data,
                           SI.parametricDistr="W", method="SIFromData", n1=500,
                           n2=100, seed=1, MCMC.control=list(burnin=3000, thin=10, seed=1))

  compareOutputFromApp(appOut, epiEstimOut)
})



# ---------------------------------------------------------------------------#
# Test 9 - Different distribution (1)                                        #
# ---------------------------------------------------------------------------#
drivers <- getRemDrivers("Test Suite 4 (E2E) --> Endpoint 9.1 (Test 9)")
rD <- drivers$rDr
remDr <- drivers$remDr

appOut <- NULL
openRemDriver(remDr)
tryCatch({
  test_that("can connect to app", {
    connectToApp(remDr)
  })

  test_that("app is ready within 30 seconds", {
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC
  })

  test_that("can walk through the app to endpoint state (Test 9)", {
      # Walk the app through to endpoint state with default inputs
    click(remDr, pages$state1.1$selectors$preloadedDataButton)
    clickNext(remDr) # Move to state 2.2
    waitForStateDisplayed(remDr, "2.2")
    click(remDr, pages$state2.2$selectors$datasetOption1Input)
    clickNext(remDr) # Move to state 5.1
    waitForStateDisplayed(remDr, "5.1")
    click(remDr, pages$state5.1$selectors$exposureDataYesInput)
    clickNext(remDr) # Move to state 6.1
    waitForStateDisplayed(remDr, "6.1")
    click(remDr, pages$state6.1$selectors$SIDataTypeOwnButton)
    clickNext(remDr) # Move to state 7.2
    waitForStateDisplayed(remDr, "7.2")
    click(remDr, pages$state7.2$selectors$SIFromRawButton)
    clickNext(remDr) # Move to state 8.2
    waitForStateDisplayed(remDr, "8.2")
    if (getAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "value") == "") {
      # SAUCELABS gives an error about interacting with an element
      # which is not currently visible. Explicitly show the element
      # first to fix this?
      setAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "style", "display: block;")
      path <- getFilePath(remDr, "datasets/SerialIntervalData/EcuadorRotavirus.csv")
      sendKeys(remDr, pages$state8.2$selectors$SIDataUploadInput,
               path)
    }
    sendKeys(remDr, pages$state8.2$selectors$seedInput, "1")
    clickNext(remDr) # Move to state 9.1
    waitForStateDisplayed(remDr, "9.1")
    click(remDr, pages$state9.1$selectors$distributionOption4Input) # <--
    sendKeys(remDr, pages$state9.1$selectors$seedInput, "1")
    clickGo(remDr)
    Sys.sleep(1)
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC

    appOut <<- extractOutputFromApp(remDr)
    closeRemDrivers(remDr, rD)
  })
},
error = function(e) {
  closeRemDrivers(remDr, rD)
  stop(e)
})


test_that("Test 9 output matches", {
  # Compare the output to EpiEstim's output
  I <- read.csv(paste(appDir, "datasets/IncidenceData/PennsylvaniaH1N1.csv", sep="/"), header=FALSE)
  I <- EpiEstim:::process_I(I)
  SI.Data <- read.csv(paste(appDir, "datasets/SerialIntervalData/EcuadorRotavirus.csv", sep="/"), header=FALSE)
  SI.Data <- EpiEstim:::process_SI.Data(SI.Data)

  epiEstimOut <- EstimateR(I, T.Start=2:25, T.End=8:31, SI.Data=SI.Data,
                           SI.parametricDistr="off1W", method="SIFromData", n1=500,
                           n2=100, seed=1, MCMC.control=list(burnin=3000, thin=10, seed=1))

  compareOutputFromApp(appOut, epiEstimOut)
})




# ---------------------------------------------------------------------------#
# Test 10 - Different distribution (1)                                        #
# ---------------------------------------------------------------------------#
drivers <- getRemDrivers("Test Suite 4 (E2E) --> Endpoint 9.1 (Test 10)")
rD <- drivers$rDr
remDr <- drivers$remDr

appOut <- NULL
openRemDriver(remDr)
tryCatch({
  test_that("can connect to app", {
    connectToApp(remDr)
  })

  test_that("app is ready within 30 seconds", {
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC
  })

  test_that("can walk through the app to endpoint state (Test 10)", {
      # Walk the app through to endpoint state with default inputs
    click(remDr, pages$state1.1$selectors$preloadedDataButton)
    clickNext(remDr) # Move to state 2.2
    waitForStateDisplayed(remDr, "2.2")
    click(remDr, pages$state2.2$selectors$datasetOption1Input)
    clickNext(remDr) # Move to state 5.1
    waitForStateDisplayed(remDr, "5.1")
    click(remDr, pages$state5.1$selectors$exposureDataYesInput)
    clickNext(remDr) # Move to state 6.1
    waitForStateDisplayed(remDr, "6.1")
    click(remDr, pages$state6.1$selectors$SIDataTypeOwnButton)
    clickNext(remDr) # Move to state 7.2
    waitForStateDisplayed(remDr, "7.2")
    click(remDr, pages$state7.2$selectors$SIFromRawButton)
    clickNext(remDr) # Move to state 8.2
    waitForStateDisplayed(remDr, "8.2")
    if (getAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "value") == "") {
      # SAUCELABS gives an error about interacting with an element
      # which is not currently visible. Explicitly show the element
      # first to fix this?
      setAttribute(remDr, pages$state8.2$selectors$SIDataUploadInput, "style", "display: block;")
      path <- getFilePath(remDr, "datasets/SerialIntervalData/EcuadorRotavirus.csv")
      sendKeys(remDr, pages$state8.2$selectors$SIDataUploadInput,
               path)
    }
    sendKeys(remDr, pages$state8.2$selectors$seedInput, "1")
    clickNext(remDr) # Move to state 9.1
    waitForStateDisplayed(remDr, "9.1")
    click(remDr, pages$state9.1$selectors$distributionOption6Input) # <--
    sendKeys(remDr, pages$state9.1$selectors$seedInput, "1")
    clickGo(remDr)
    Sys.sleep(1)
    waitForAppReady(remDr, timeout=3000) # Long timeout for running MCMC

    appOut <<- extractOutputFromApp(remDr)
    closeRemDrivers(remDr, rD)
  })
},
error = function(e) {
  closeRemDrivers(remDr, rD)
  stop(e)
})


test_that("Test 10 output matches", {
  # Compare the output to EpiEstim's output
  I <- read.csv(paste(appDir, "datasets/IncidenceData/PennsylvaniaH1N1.csv", sep="/"), header=FALSE)
  I <- EpiEstim:::process_I(I)
  SI.Data <- read.csv(paste(appDir, "datasets/SerialIntervalData/EcuadorRotavirus.csv", sep="/"), header=FALSE)
  SI.Data <- EpiEstim:::process_SI.Data(SI.Data)

  epiEstimOut <- EstimateR(I, T.Start=2:25, T.End=8:31, SI.Data=SI.Data,
                           SI.parametricDistr="off1L", method="SIFromData", n1=500,
                           n2=100, seed=1, MCMC.control=list(burnin=3000, thin=10, seed=1))

  compareOutputFromApp(appOut, epiEstimOut)
})


