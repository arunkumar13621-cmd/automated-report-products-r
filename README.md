# Automated Report Products (R Markdown, PDF, Excel)

One command builds all report products from the cleaned synthetic survey: a parameterised HTML report for each of the 12 institutions, a PDF summary and a formatted Excel workbook.

**Run:** `Rscript build_reports.R` (about 10 seconds). **Test:** `Rscript -e "testthat::test_dir('tests/testthat')"` (6 tests, 13 checks). See `docs/WORKFLOW.md` for how to refresh and change it.

## Outputs (`output/`)
* `html/PTI01.html` to `PTI12.html`: one parameterised R Markdown template rendered once per institution.
* `Outcomes_Summary.pdf`: 2-page summary with tables and a chart.
* `Outcomes_Summary.xlsx`: sheets Overall, By program, By institution and Notes, with number formats, frozen header rows and column widths.

## Checks
Tests confirm that every institution has a report, that Excel numbers equal a direct calculation, that institution counts add up to all respondents and that small groups are suppressed.

## Limits
The layout is plain. Data is synthetic. The same suppression rule (fewer than 10) is applied in every product, but there is no complementary suppression, so a suppressed number could in principle be worked out from totals.
