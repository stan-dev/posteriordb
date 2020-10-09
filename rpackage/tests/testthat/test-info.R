context("test-info")

test_that("info() should extract the object information", {

  posterior_db_path <- posteriordb:::get_test_pdb_dir()
  expect_silent(pdb_test <- pdb_local(posterior_db_path))
  pdb_clear_cache()
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb = pdb_test))

  # Data
  expect_silent(d <- pdb_data(po))
  expect_silent(di1 <- pdb_data_info(po))
  expect_silent(di2 <- info(d))
  expect_identical(di1, di2)
  expect_s3_class(d, "pdb_data")
  expect_s3_class(d, "list")

  # Models
  expect_silent(m <- pdb_model_code(po, "stan"))
  expect_silent(mi1 <- pdb_model_info(po))
  expect_silent(mi2 <- info(m))
  expect_identical(mi1, mi2)
  expect_s3_class(m, "pdb_model_code")
  expect_s3_class(m, "character")

  # Reference posterior draws
  expect_silent(rp <- pdb_reference_posterior_draws(po, "stan"))
  expect_silent(rpi1 <- pdb_reference_posterior_draws_info(po))
  expect_silent(rpi2 <- info(rp))
  expect_identical(rpi1, rpi2)
  expect_s3_class(rp, "pdb_reference_posterior_draws")
  expect_s3_class(rp, "draws_list")

})


test_that("data info constructor ", {
  x <- list(name = "wells_data2",
            keywords = c("wells","arsenic","Bangladesh"),
            title = "Factors affecting the decision to switch wells",
            description = "Decisions of households in Bangladesh about whether to change their source of
                     drinking water.",
            urls = "https://github.com/stan-dev/example-models/tree/master/ARM/Ch.5",
            references = "gelman2006data",
            added_date = Sys.Date(),
            data_file = "data/data/.json",
            added_by = "Phil Clemson")
  expect_error(di <- pdb_data_info(x))
  x$data_file <- NULL
  expect_silent(di <- pdb_data_info(x))
  x$data_file <- "data/data/wells_data2.json"
  expect_silent(di <- pdb_data_info(x))
})
