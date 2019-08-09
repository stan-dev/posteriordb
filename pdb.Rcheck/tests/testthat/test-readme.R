context("test-readme")

test_that("Test the code in the README", {
  test_dir <- getwd()
  setwd("../../../")
  root_dir <- getwd()
  setwd(test_dir)
  
  expect_silent(my_pdb <- pdb(root_dir))

  expect_silent(pos <- posterior_names(my_pdb))
  mn <- c("8_schools|centered", 
          "8_schools|noncentered", 
          "prideprejustice_chapter|ldaK5", 
          "prideprejustice_paragraph|ldaK5", 
          "radon_mn|radon_hierarchical_intercept_centered",
          "radon_mn|radon_hierarchical_intercept_noncentered")
  expect_equal(head(pos), mn)
  
  
  

})

