
m <- 400
dat <- data.frame(doc = factor(c(rep("doc1", m), rep("doc2", m), rep("doc3", m))),
                  type = factor(c(rep("word1", 0.9*m), c(rep("word2", 0.1*m), rep("word2", m), rep("word3", m)))))

# To stan
three_docs1200 <-
  list(V = length(levels(dat$type)),
       M = length(unique(dat$doc)),
       N = length(dat$type),
       w = as.integer(dat$type),
       doc = as.integer(dat$doc))
