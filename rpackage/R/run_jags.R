#' Run JAGS on a posterior
#'
#' @references
#' See \url{http://mcmc-jags.sourceforge.net/}.
#'
#' @param x a [pdb_posterior] object.
#' @param args.jags.model Arguments as a list supplied to [rjags::jags.model] (excluding file and data)
#' @param args.coda.samples Arguments as a list supplied to [rjags::coda.samples] (excluding model)
#' @param ... currently not in use.
#'
run_jags <- function(x, args.jags.model, args.coda.samples, ...){
  checkmate::assert_list(args.jags.model)
  checkmate::assert_names(names(args.jags.model), disjunct.from = c("file", "data"))
  checkmate::assert_list(args.coda.samples)
  checkmate::assert_names(names(args.coda.samples), disjunct.from = c("model"))
  UseMethod("run_jags")
}

#' @rdname run_jags
run_jags.pdb_posterior <- function(x, args.jags.model, args.coda.samples, ...){

  args.jags.model <- c(list(file = model_code_file_path(x, framework = "jags"),
                            data = get_data(x)),
                            args.jags.model)
  jm <- do.call(rjags::jags.model, args.jags.model)

  args.coda.samples <- c(list(model = jm),
                         args.coda.samples)
  if(is.null(args.coda.samples$variable.names)){
    args.coda.samples$variable.names <- names(x$dimensions)
  }
  cs <- do.call(rjags::coda.samples, args.coda.samples)
  attr(cs, "posterior_name") <- x$name
  cs
}
