# This file contains lots of functions to be used in testing., debug=T)
# Most of them are wrappers to make the testthat syntax nicer, for example by removing all the [[1]]s.


library(RSelenium)

allStates = c("1.1", "2.1", "2.2", "3.1", "4.1", "5.1", "6.1", "6.2", "7.1", "7.2", "7.3", "7.4",
              "7.5", "7.6", "8.1", "8.2", "8.3", "9.1")
appUrl="http://localhost:3000"
source("pageObjects.R", local=TRUE)
appDir <- system.file("app", package="EpiEstimApp")

findElem <- function(remDr, selector, using="xpath") {
  # Used instead of remDr$findElement(using="xpath", selector)
  return(remDr$findElement(using=using, selector))
}

findElems <- function(remDr, selector, using="xpath") {
  # Used instead of remDr$findElements(using="xpath", selector)
  return(remDr$findElements(using=using, selector))
}

getText <- function(remDr, selector) {
  webElem <- findElem(remDr, selector)
  # Used instead of webElem$getElementText()[[1]]
  return(webElem$getElementText()[[1]])
}

getAttribute <- function(remDr, selector, attr) {
  webElem <- findElem(remDr, selector)
  return(webElem$getElementAttribute(attr)[[1]])
}

setAttribute <- function(remDr, selector, attr, value) {
    webElem <- findElem(remDr, selector)
    webElem$setElementAttribute(attr, value)
}

isDisplayed <- function(remDr, selector) {
  webElem <- findElem(remDr, selector)
  return(webElem$isElementDisplayed()[[1]])
}

isEnabled <- function(remDr, selector) {
  webElem <- findElem(remDr, selector)
  return(webElem$isElementEnabled()[[1]])
}

isSelected <- function(remDr, selector) {
  webElem <- findElem(remDr, selector)
  return(webElem$isElementSelected()[[1]])
}

sendKeys <- function(remDr, selector, keys) {
  webElem <- findElem(remDr, selector)
  webElem$sendKeysToElement(list(keys))
}

clear <- function(remDr, selector) {
  webElem <- findElem(remDr, selector)
  webElem$clearElement()
}

click <- function(remDr, selector) {
  webElem <- findElem(remDr, selector)
  webElem$clickElement()
}

clickNext <- function(remDr) {
  click(remDr, pages$common$selectors$next_button)
}

clickPrev <- function(remDr) {
  click(remDr, pages$common$selectors$prev_button)
}

clickGo <- function(remDr) {
  click(remDr, pages$common$selectors$go_button)
}

clickStop <- function(remDr) {
  click(remDr, pages$common$selectors$stop_button)
}

checkError <- function(remDr, msg, input=NULL, timeout=120) {
  tries <- 0
  done <- FALSE
  while (!done & tries < timeout) {
    if (getText(remDr, pages$common$selectors$status) != "ERROR") {
      Sys.sleep(1)
      tries <- tries + 1
    } else {
      done <- TRUE
    }
  }
  expect_equal(getText(remDr, pages$common$selectors$error_message), msg)
  if(!is.null(input)) {
    selector <- paste("//div[@id='", input, "_error_box']", sep="")
    style <- getAttribute(remDr, selector, "style")
    expect_equal(style, "border: 3px solid red;")
  }
}

waitForElemDisplayed <- function(remDr, selector, timeout=60) {
  # Waits for webElem to be displayed for timeout seconds.
  # If passes if element is displayed within timeout, fails otherwise
  displayed <- FALSE
  tries <- 0
  while (!displayed & tries < 2*timeout) {
    tryCatch({
      displayed <- isDisplayed(remDr, selector)
      },
      error = function (e) {}
    )
    tries <- tries + 1
    Sys.sleep(0.5)
  }
  expect_true(displayed)
}

extractOutputFromApp <- function(remDr) {
  # Extract incidence data
  click(remDr, pages$common$selectors$incidence_tab)
  waitForElemDisplayed(remDr, pages$common$selectors$incidence_table)
  str <- getText(remDr, pages$common$selectors$incidence_table)
  str2 <- gsub(" ", ",", str)
  con <- textConnection(str2)
  incidence <- read.csv(con, sep=",", header=TRUE)

  # Extract serialInterval data
  click(remDr, pages$common$selectors$serial_interval_tab)
  waitForElemDisplayed(remDr, pages$common$selectors$serial_interval_table)
  str <- getText(remDr, pages$common$selectors$serial_interval_table)
  str2 <- gsub(" ", ",", str)
  con <- textConnection(str2)
  serialInterval <- read.csv(con, sep=",", header=TRUE)

  # Extract reproduction data
  click(remDr, pages$common$selectors$reproduction_tab)
  waitForElemDisplayed(remDr, pages$common$selectors$reproduction_table)
  str <- getText(remDr, pages$common$selectors$reproduction_table)
  str <- gsub(" ", ",", str)
  con <- textConnection(str)
  reproduction <- read.csv(con, sep=",", header=TRUE)
  names(reproduction) <- gsub(".R.", "(R)", names(reproduction))

  # Return the list
  list(incid=incidence, si_distr=serialInterval, R=reproduction)
}

compareOutputFromApp <- function(appOut, epiEstimOut, debug=FALSE) {
  expect_true(compare::compare(appOut$R, round(epiEstimOut$R, 2))$result)
  df <- round(as.data.frame(epiEstimOut$si_distr), 2)
  if (ncol(df) == 1) {
      names(df) <- "data"
      rownames(df) <- NULL
  }
  expect_true(compare::compare(appOut$si_distr, df)$result)
  expect_true(compare::compare(appOut$incid$local, round(epiEstimOut$I_local, 2))$result)
  expect_true(compare::compare(appOut$incid$imported, round(epiEstimOut$I_imported, 2))$result)
  if (debug) {
    cat("\n\nappOut$R:\n")
    str(appOut$R)
    cat("\n\nepiEstimOut$R:\n")
    str(round(epiEstimOut$R, 2))
    cat("\n\nappOut$incid:\n")
    str(appOut$incid)
    cat("\n\nepiEstimOut$incid:\n")
    str(round(epiEstimOut$I_local, 2))
    str(round(epiEstimOut$I_imported, 2))
    cat("\n\nappOut$si_distr:\n")
    str(appOut$si_distr)
    cat("\n\nepiEstimOut$si_distr:\n")
    str(df)
  }
}

connectToApp <- function(remDr) {
  # Navigates to the app, checks the title appears.
  remDr$navigate(appUrl)
  title <- getText(remDr, pages$common$selectors$incidence_title)
  expect_equal(title, "Incidence Data")
}

waitForAppReady <- function(remDr, timeout=120) {
  # Waits for "Initialising..." to change to "Ready" for timeout seconds.
  ready <- FALSE
  tries=0
  while (!ready & tries < timeout) {
    status <- getText(remDr, pages$common$selectors$status_bar)
    if (status != "Ready") {
      tries = tries + 1
      Sys.sleep(1)
    } else {
      ready <- TRUE
    }
  }
  expect_equal(status, "Ready")
}

checkDisplayedState <- function(remDr, expectedState) {
  # Checks that only expectedState is displayed.

  # Expected state should be displayed
  selector <- paste("//div[@id='", expectedState, "']", sep="")
  expect_true(isDisplayed(remDr, selector))
  # No other states should be displayed
  for (state in setdiff(allStates, expectedState)) {
    selector <- paste("//div[@id='", state, "']", sep="")
    expect_false(isDisplayed(remDr, selector))
  }
}

getDisplayedState <- function(remDr) {
  # Returns the currently displayed state
  for (state in allStates) {
    selector <- paste("//div[@id='", state, "']", sep="")
    if (isDisplayed(remDr, selector)) {
        return(state)
    }
  }
}

waitForStateDisplayed <- function(remDr, state) {
    selector <- paste("//div[@id='", state, "']", sep="")
    waitForElemDisplayed(remDr, selector)
}

navigateToState <- function(remDr, state) {
  # Navigate to state
  currentState <- getDisplayedState(remDr)
  if (currentState == state) {
      return()
  }
  switch(state,
         "1.1" = {
           count <- 0
           while (getDisplayedState(remDr) != "1.1") {
             clickPrev(remDr)
             if (count > 20) break
           }
         },
         "2.1" = {
           navigateToState(remDr, "1.1")
           click(remDr, pages$state1.1$selectors$own_data_button)
           clickNext(remDr)
         },
         "2.2" = {
           navigateToState(remDr, "1.1")
           click(remDr, pages$state1.1$selectors$preloaded_data_button)
           clickNext(remDr)
         },
         "3.1" = {
           navigateToState(remDr, "2.1")
           # We won't be able to move on unless we upload a
           # file...
           if (getAttribute(remDr, pages$state2.1$selectors$incidence_data_upload_input, "value") == "") {
             # SAUCELABS gives an error about interacting with an element
             # which is not currently visible. Explicitly show the element
             # first to fix this?
             setAttribute(remDr, pages$state2.1$selectors$incidence_data_upload_input, "style", "display: block;")
           }
           path <- getFilePath(remDr, "datasets/IncidenceData/H1N1Pennsylvania2009.csv")
           sendKeys(remDr, pages$state2.1$selectors$incidence_data_upload_input,
                    path)
           clickNext(remDr)
         },
         "4.1" = {
           navigateToState(remDr, "3.1")
           click(remDr, pages$state3.1$selectors$imported_yes_button)
           clickNext(remDr)
         },
         "5.1" = {
           navigateToState(remDr, "2.2")
           clickNext(remDr)
         },
         "6.1" = {
           navigateToState(remDr, "5.1")
           click(remDr, pages$state5.1$selectors$exposure_data_yes_input)
           clickNext(remDr)
         },
         "6.2" = {
           navigateToState(remDr, "5.1")
           click(remDr, pages$state5.1$selectors$exposure_data_no_input)
           clickNext(remDr)
         },
         "7.1" = {
           navigateToState(remDr, "6.1")
           click(remDr, pages$state6.1$selectors$si_data_type_preloaded_button)
           clickNext(remDr)
         },
         "7.2" = {
           navigateToState(remDr, "6.1")
           click(remDr, pages$state6.1$selectors$si_data_type_own_button)
           clickNext(remDr)
         },
         "7.3" = {
           navigateToState(remDr, "6.2")
           click(remDr, pages$state6.2$selectors$si_est_type_option_1_button)
           clickNext(remDr)
         },
         "7.4" = {
           navigateToState(remDr, "6.2")
           click(remDr, pages$state6.2$selectors$si_est_type_option_2_button)
           clickNext(remDr)
         },
         "7.5" = {
           navigateToState(remDr, "6.2")
           click(remDr, pages$state6.2$selectors$si_est_type_option_3_button)
           clickNext(remDr)
         },
         "7.6" = {
           navigateToState(remDr, "6.2")
           click(remDr, pages$state6.2$selectors$si_est_type_option_4_button)
           clickNext(remDr)
         },
         "8.1" = {
           navigateToState(remDr, "7.1")
           clickNext(remDr)
         },
         "8.2" = {
           navigateToState(remDr, "7.2")
           click(remDr, pages$state7.2$selectors$si_from_raw_button)
           clickNext(remDr)
         },
         "8.3" = {
           navigateToState(remDr, "7.2")
           click(remDr, pages$state7.2$selectors$si_from_sample_button)
           clickNext(remDr)
         },
         "9.1" = {
           navigateToState(remDr, "8.2")
           # We won't be able to move on unless we upload a
           # file...
           if (getAttribute(remDr, pages$state8.2$selectors$si_data_upload_input, "value") == "") {
             # SAUCELABS gives an error about interacting with an element
             # which is not currently visible. Explicitly show the element
             # first to fix this?
             setAttribute(remDr, pages$state8.2$selectors$si_data_upload_input, "style", "display: block;")
           }
           path <- getFilePath(remDr, "datasets/SerialIntervalData/H1N1NewYork2009.csv")
           sendKeys(remDr, pages$state8.2$selectors$si_data_upload_input,
                    path)
           clickNext(remDr)
         }
  )
  waitForStateDisplayed(remDr, state)
}

buildMatrix <- list(
  platforms=c("linux", "linux", "Windows 10", "Windows 10"),
  browserNames=c("firefox", "chrome", "firefox", "chrome")
)

getRemDrivers <- function(name) {
  if (Sys.getenv("TRAVIS_JOB_NUMBER") == "") {
        # rDr <- rsDriver(remoteServerAddr = "localhost", port = 4444L, verbose=FALSE,
        #                 browser="chrome")
        # remDr <- rDr$client
        rDr <- NULL
        remDr <- remoteDriver(remoteServerAddr="localhost", port=4444L, browser="chrome")
  } else {
        browserName = Sys.getenv("browser")
        platform = Sys.getenv("platform")
        user <- Sys.getenv("SAUCE_USERNAME") # Your Sauce Labs username
        pass <- Sys.getenv("SAUCE_ACCESS_KEY") # Your Sauce Labs access key

        port <- 4445
        ip <- paste0(user, ':', pass, "@localhost")
        extraCapabilities <- list(name = paste(Sys.getenv("TRAVIS_JOB_NUMBER"), name), username = user, accessKey = pass
                                  , startConnect = FALSE, tunnelIdentifier = Sys.getenv("TRAVIS_JOB_NUMBER"))
        remDr <- remoteDriver$new(remoteServerAddr = ip, port = port, extraCapabilities = extraCapabilities
                                  , browserName = browserName, platform = platform) 
        rDr <- NULL
  }
  return(list(remDr = remDr, rDr = rDr))
}

openRemDriver <- function(remDr) {
  # Sometimes the saucelabs job fails to start, just because it seems
  # to be a bit dodgy. (A new saucelabs job starts for each test, and we
  # have lots of tests, so even though it's unlikely to go wrong, it happens
  # reasonably often.) To try and help this, we will retry the `remDr%$open
  # command a few times if it fails the first time.
  tries <- 5
  t <- 0
  done <- FALSE
  wait <- 3
  while (!done & t < tries) {
    tryCatch({
      remDr$open(silent=TRUE)
      done <- TRUE
    },
    error = function(e) {
      # Ignore error and try again
      t <- t + 1
      Sys.sleep(wait)
    })
  }
  # One final try (will also ensure correct error is thrown)
  if (!done) {
    remDr$open(silent=TRUE)
  }
}

closeRemDrivers <- function(remDr, rDr) {
    tryCatch({
      remDr$close()
      rDr$server$stop()
    },
    error = function(e) {
      # Ignore errors when rDr is null
    })
}

getFilePath <- function(remDr, file) {
   # file should be a path relative to the apps root directory
   # Returns full file path on most systems, or uploads to saucelabs
   # and returns the path on saucelabs if needed.
   path <- paste(appDir, "/", file, sep="")
   if (Sys.getenv("TRAVIS_JOB_NUMBER")=="") {
       return(path)
   } else {
       # saucelabsPath will be the path to the home directory on saucelabs
       # so we take substring(path, 6) which removes the /home/ from path
       # to avoid having it twice.
       saucelabsPath <- myUpload(remDr, path)
       newPath <- paste0(saucelabsPath, substring(path, 6), sep="")
       return(newPath)
   }
}

myUpload <- function(remDr, myfile){
  # Uploads file to saucelabs and returns the path of the home folder
  tmpfile <- tempfile(fileext = ".zip")
  # zip file
  zip(tmpfile, myfile)
  # base64 encode
  zz <- file(tmpfile, "rb")
  ar <- readBin(tmpfile, "raw", file.info(tmpfile)$size)
  encFile <- caTools::base64encode(ar)
  close(zz)
  qpath <- sprintf("%s/session/%s/file", remDr$serverURL, 
                   remDr$sessionInfo[["id"]])
  res <- queryRD(qpath, "POST", qdata = list(file = encFile))
  # return result from server
  httr::content(res, simplifyVector = FALSE)$value
}

# The following functions is used in the above FileUpload function
# and are taken from:
# https://github.com/ropensci/RSelenium/blob/539660780454c321822b37e4c39a321a34528b0d/R/errorHandler.R
# See https://github.com/ropensci/RSelenium/issues/130

# TODO: Error handling/status code checking etc
queryRD = 
        function(ipAddr, method = "GET", qdata = NULL){
          "A method to communicate with the remote server implementing the 
          JSON wire protocol."
        getUC.params <- 
          list(url = ipAddr, verb = method, body = qdata, encode = "json")
        res <- tryCatch(
          {do.call(httr::VERB, getUC.params)}, 
          error = function(e){e}
        )
res}

