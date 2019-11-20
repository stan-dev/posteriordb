
context("test-readme")

test_that("Check that the generated README is up-to-date", {
  current_readme <- readLines("../../../README.md")
  rmarkdown::render("../../../README.Rmd")
  generated_readme <- readLines("../../../README.md")
  expect_equal(current_readme, generated_readme)
})
