# Build all report products: one HTML report per institution, a PDF summary and an Excel workbook.
suppressPackageStartupMessages({library(rmarkdown); library(openxlsx); library(dplyr)})
source("R/data_functions.R")
args <- commandArgs(trailingOnly = TRUE)
data_path <- if (length(args) >= 1) args[1] else "data/clean_survey.csv"
dir.create("output/html", recursive = TRUE, showWarnings = FALSE)
d <- load_outcomes(data_path)

# 1. HTML: one report per institution
for (inst in sort(unique(d$institution_id)))
  render("reports/institution_report.Rmd", output_file = paste0(inst, ".html"), output_dir = "output/html",
         params = list(institution = inst, data_path = data_path), quiet = TRUE, envir = new.env(), knit_root_dir = getwd())

# 2. PDF summary
render("reports/summary_report.Rmd", output_file = "Outcomes_Summary.pdf", output_dir = "output",
       params = list(data_path = data_path), quiet = TRUE, envir = new.env(), knit_root_dir = getwd())

# 3. Excel workbook (values, formatted, with notes)
by_prog <- summarise_by(d, "program_area"); by_inst <- summarise_by(d, "institution_id")
overall <- kpis(d)
fix <- function(t) { t$suppressed <- NULL; names(t) <- c(names(t)[1], "Respondents", "Employment rate", "Median wage", "Mean quality"); t }
wb <- createWorkbook()
hdr <- createStyle(textDecoration = "bold", fgFill = "#DCE6F1", border = "bottom")
pctst <- createStyle(numFmt = "0.0%"); wagest <- createStyle(numFmt = "$#,##0.00"); decst <- createStyle(numFmt = "0.00")
add <- function(name, t) {
  addWorksheet(wb, name); writeData(wb, name, t, headerStyle = hdr, na.string = "suppressed"); freezePane(wb, name, firstRow = TRUE)
  n <- nrow(t)
  addStyle(wb, name, pctst, rows = 2:(n + 1), cols = 3, gridExpand = TRUE, stack = TRUE)
  addStyle(wb, name, wagest, rows = 2:(n + 1), cols = 4, gridExpand = TRUE, stack = TRUE)
  addStyle(wb, name, decst, rows = 2:(n + 1), cols = 5, gridExpand = TRUE, stack = TRUE)
  setColWidths(wb, name, cols = 1:5, widths = c(26, 13, 16, 13, 14))
}
add("By program", fix(by_prog)); add("By institution", fix(by_inst))
addWorksheet(wb, "Overall")
writeData(wb, "Overall", data.frame(Measure = c("Respondents", "Employed within 6 months (weighted)", "Median hourly wage", "Mean quality rating"),
  Value = c(overall$respondents, overall$employment_rate, overall$median_wage, overall$mean_quality)), headerStyle = hdr)
addStyle(wb, "Overall", pctst, rows = 3, cols = 2); addStyle(wb, "Overall", wagest, rows = 4, cols = 2); addStyle(wb, "Overall", decst, rows = 5, cols = 2)
setColWidths(wb, "Overall", cols = 1:2, widths = c(38, 14))
addWorksheet(wb, "Notes")
writeData(wb, "Notes", data.frame(Note = c("Synthetic data. Fictional institutions and respondents.",
  paste0("Groups with fewer than ", MIN_CELL, " respondents are shown as 'suppressed'."), "Employment rates are weighted by institution.", paste("Built from", data_path, "on", Sys.Date()))), headerStyle = hdr)
setColWidths(wb, "Notes", cols = 1, widths = 90)
saveWorkbook(wb, "output/Outcomes_Summary.xlsx", overwrite = TRUE)
cat("Built", length(list.files("output/html", "\\.html$")), "HTML reports, 1 PDF and 1 Excel workbook\n")
