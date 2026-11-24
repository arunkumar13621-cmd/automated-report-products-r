# Workflow: refreshing the report products

## Purpose
Produce the same set of reports from a survey file every time, without copying and pasting.

## Inputs
`data/clean_survey.csv`, the cleaned file from the survey pipeline (one row per respondent, with an institution weight).

## Steps
1. Run the survey pipeline (`survey_pipeline/run_pipeline.R`) and copy `output/clean_survey.csv` to `data/`.
2. Run `Rscript build_reports.R`. To use another file, give its path as the first argument.
3. Open `output/` and check: 12 HTML files, one PDF, one workbook.
4. Run the tests. They compare the Excel numbers with a direct calculation.

## What each file does
* `R/data_functions.R`: filtering, summaries and the small-cell rule (one place, so every product follows the same rule).
* `reports/institution_report.Rmd`: template with a parameter for the institution.
* `reports/summary_report.Rmd`: PDF summary.
* `build_reports.R`: builds everything.

## Changing things
* Minimum group size: change `MIN_CELL` in `R/data_functions.R`.
* New institution: it appears automatically when it is in the data.
* New measure: add it to `summarise_by()`, then to the template and the workbook.

## Assumptions and known issues
* Rates are weighted by institution. Small groups above the minimum size can still be unstable.
* Fewer-than-10 suppression is not complementary suppression.
