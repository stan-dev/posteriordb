context("test-readme")

test_that("Test the code in the README", {
  # TODO: figure out how to test the code in the README
  # expect_silent(pdb_dir <- posteriordb:::get_pdb_dir(getwd()))
  # expect_silent(my_pdb <- pdb(pdb_dir))
  #
  # expect_silent(pos <- posterior_names(my_pdb))
  # pn <- c("8_schools-8_schools_centered",
  #         "8_schools-8_schools_noncentered",
  #         "prideprejustice_chapter-ldaK5",
  #         "prideprejustice_paragraph-ldaK5",
  #         "radon_mn-radon_hierarchical_intercept_centered",
  #         "radon_mn-radon_hierarchical_intercept_noncentered")
  # expect_equal(head(pos), pn)
  #
  # expect_silent(mn <- model_names(my_pdb))
  # mnt <- c("8_schools_centered",
  #         "8_schools_noncentered",
  #         "blr",
  #         "gmm_diagonal_nonordered",
  #         "gmm_diagonal_ordered",
  #         "gmm_nonordered")
  # checkmate::expect_subset(mnt,mn)
  #
  # expect_silent(dn <- dataset_names(pdb = my_pdb))
  # dnt <- c("8_schools",
  #          "prideprejustice_chapter",
  #          "prideprejustice_paragraph",
  #          "radon_mn",
  #          "radon",
  #          "roaches_scaled")
  # checkmate::expect_subset(dnt,dn)
  #
  # expect_silent(po <- posterior("8_schools-8_schools_centered", my_pdb))
  # expect_silent(ds <- dataset(po))
  # checkmate::expect_names(names(ds), identical.to = c("J", "y", "sigma"))
  #
  # expect_silent(sc <- stan_code(po))
  # expect_equal(sc[1:3], c("", "data {", "  int <lower=0> J; // number of schools"))
  #
  # expect_silent(dfp <- dataset_file_path(po))
  # checkmate::expect_file_exists(dfp)
  # expect_silent(scfp <- stan_code_file_path(x = po))
  # checkmate::expect_file_exists(scfp)
  #
  # expect_silent(di <- data_info(po))
  # checkmate::expect_names(names(di),
  #                         must.include = c("title", "description", "urls", "references", "keywords"))
  # expect_silent(mi <- model_info(po))
  # checkmate::expect_names(names(mi),
  #                         must.include = c("title", "description", "urls", "references", "keywords"))
  #
  # expect_silent(gs <- gold_standard(po))
  # expect_silent(posterior_draws <- draws(gs))
  # checkmate::expect_names(names(posterior_draws), must.include = c("theta.1", "theta.2", "theta.3"))
})
