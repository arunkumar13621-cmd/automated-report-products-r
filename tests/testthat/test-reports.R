library(testthat); library(openxlsx)
setwd("../..")
source("R/data_functions.R")
d <- load_outcomes("data/clean_survey.csv")

test_that("one HTML report exists for every institution and names it", {
  inst <- sort(unique(d$institution_id))
  f <- file.path("output/html", paste0(inst, ".html"))
  expect_true(all(file.exists(f)))
  txt <- paste(readLines(f[2], warn = FALSE), collapse = " ")
  expect_true(grepl("PTI02", txt)); expect_true(grepl("Synthetic data", txt))
})
test_that("the PDF summary exists and has content", {
  expect_true(file.exists("output/Outcomes_Summary.pdf"))
  expect_gt(file.size("output/Outcomes_Summary.pdf"), 10000)
})
test_that("Excel workbook has the expected sheets", {
  expect_equal(sort(getSheetNames("output/Outcomes_Summary.xlsx")), sort(c("Overall", "By program", "By institution", "Notes")))
})
test_that("Excel figures match a direct calculation", {
  x <- read.xlsx("output/Outcomes_Summary.xlsx", "By program")
  tr <- d[d$program_area == "Trades" & !is.na(d$emp), ]
  expect_equal(x$Employment.rate[x[[1]] == "Trades"], weighted.mean(tr$emp, tr$weight), tolerance = 1e-8)
  expect_equal(x$Respondents[x[[1]] == "Trades"], sum(d$program_area == "Trades"))
  o <- read.xlsx("output/Outcomes_Summary.xlsx", "Overall")
  expect_equal(o$Value[1], nrow(d))
})
test_that("Excel by-institution counts add up to all respondents", {
  x <- read.xlsx("output/Outcomes_Summary.xlsx", "By institution")
  expect_equal(sum(x$Respondents), nrow(d)); expect_equal(nrow(x), 12)
})
test_that("small groups would be suppressed in the products", {
  tiny <- head(d[d$institution_id == "PTI01", ], 7)
  s <- summarise_by(tiny, "program_area")
  expect_true(all(s$suppressed)); expect_true(all(is.na(s$employment_rate)))
})
