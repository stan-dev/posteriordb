context("test-pdb")

test_that("model_names and data_names works as expected", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  expect_silent(posteriors <- posterior_names(pdb_test))
  expect_silent(mn <- model_names(pdb_test))
  expect_silent(dn <- data_names(pdb_test))

  posteriors <- posteriors[grepl(x = posteriors, "-")]
  slpdat <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[1]]))
  slpmn <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[2]]))

  expect_true(all(slpmn %in% mn))
  expect_true(all(slpdat %in% dn))
})


test_that("pdb_version", {
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb(posterior_db_path))
  checkmate::expect_list(pdb_version(pdb_test))
  checkmate::expect_names(names(pdb_version(pdb_test)), must.include = "sha")
})


test_that("pdb_local", {
  skip_on_appveyor()
  skip_on_covr()
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdbl1 <- pdb_local(posterior_db_path))
  expect_silent(pdbl2 <- pdb_local())
  expect_silent(pdbl3 <- pdb_local("../"))
  expect_error(pdbl4 <- pdb_local("../../../../"))
  expect_equal(pdbl1, pdbl2)
  expect_equal(pdbl1, pdbl3)
})


test_that("pdb_config", {
  skip_on_covr()
  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdbl1 <- pdb_local())
  expect_silent(pdbl2 <- pdb_local(posterior_db_path))

  writeLines(text = c("type: \"local\""), con = ".pdb_config.yml")
  expect_silent(pdbc1 <- pdb_config())
  pdbc1b <- pdbc1; pdbc1b$.pdb_config.yml <- NULL
  writeLines(text = c("type: \"local\"",
                      paste0("path: \"", posterior_db_path, "\"")), con = ".pdb_config.yml")
  expect_silent(pdbc2 <- pdb_config())
  pdbc2b <- pdbc2; pdbc2b$.pdb_config.yml <- NULL

  expect_silent(pdbd <- pdb_default())
  pdbdb <- pdbd; pdbdb$.pdb_config.yml <- NULL

  expect_equal(pdbl1, pdbl2)
  expect_equal(pdbl1, pdbc1b)
  expect_equal(pdbl1, pdbc2b)
  expect_equal(pdbl1, pdbdb)

  expect_failure(expect_equal(pdbl1, pdbc1))
  expect_failure(expect_equal(pdbl1, pdbc2))
  expect_failure(expect_equal(pdbc1, pdbc2))
  expect_failure(expect_equal(pdbc1, pdbd))

  expect_equal(pdbc2, pdbd)

  file.remove(".pdb_config.yml")
})
