
context("test-readme")

test_that("Check that the generated README is up-to-date", {
  current_readme <- read.file("README.md")
  rmarkdown::render("README.Rmd")
  generated_readme <- read.file("README.md")
  expect_equal(current_readme, generated_readme)
})
