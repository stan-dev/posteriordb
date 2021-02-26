library(stopwords)
library(dplyr)
library(tidytext)
library(checkmate)


#' @param txt a tidy text corpus with columns [line], [chapter], [text] and [lang]
#' @param no_words_per_chapter a named vector with language as name and the number of tokens to choose per chapter
#' @param rare_word_limit The minimal number of token per word type
#' @param remove_stopwords Remove stopwords based on a stopwordlist
create_corpus <- function(txt,
                         no_words_per_chapter = c("en" = 700, "fr" = 210, "sv" = 300),
                         rare_word_limit = 10,
                         remove_stopwords = "nltk"){
  checkmate::assert_names(names(txt), must.include = c("line", "chapter", "text", "lang"))
  checkmate::assert_names(names(no_words_per_chapter), subset.of = unique(txt$lang))
  checkmate::assert_int(rare_word_limit, lower = 0)
  checkmate::assert_integerish(no_words_per_chapter, lower = 0)
  checkmate::assert_choice(remove_stopwords, null.ok = TRUE, stopwords::stopwords_getsources())
  checkmate::assert_subset(names(no_words_per_chapter),  stopwords::stopwords_getlanguages(remove_stopwords))

  # Remove it and chapter titles
  txt <- txt[c(TRUE, !(txt$chapter[-length(txt$chapter)] != txt$chapter[-1])),]
  txt <- txt[txt$chapter >= 1,]

  txt <- tidytext::unnest_tokens(txt, word, text, token = "words", to_lower = TRUE)

  # Add chapter row no
  txt <- dplyr::group_by(txt, lang, chapter)
  txt <- dplyr::mutate(txt, chapter_word_no = dplyr::row_number())

  res <- list()
  for(i in seq_along(no_words_per_chapter)){
    lang <- names(no_words_per_chapter)[i]
    tmp <- txt[txt$lang == lang, ]
    # Remove stopwords here
    sw <- stopwords::stopwords(language = lang, source = remove_stopwords)
    if(lang == "fr") sw <- c(sw, "qu’il", "a", "c’est", "d’un")
    swt <- dplyr::tibble(word = sw)

    tmp <- dplyr::anti_join(tmp, swt, by = "word")

    # Extract top words
    tmp <- get_first_n_words_from_chapter(tmp, lang, no_words_per_chapter[lang])
    res[[i]] <- remove_rare_words(tmp, rare_word_limit)
  }
  res <- do.call(rbind, res)
  res
}

#' @rdname create_corpus
remove_rare_words <- function(txt, rare_word_limit){
  checkmate::assert_names(names(txt), must.include = c("line", "chapter", "word", "lang"))
  checkmate::assert_int(rare_word_limit, lower = 0)

  txt <- dplyr::group_by(txt, word, lang)
  wf <- dplyr::summarise(txt, n = dplyr::n(), .groups = "keep")
  txt <- dplyr::left_join(txt, wf, by = c("word", "lang"))
  txt <- txt[txt$n >= rare_word_limit,]
  txt$n <- NULL
  txt
}

#' @rdname create_corpus
#' @param lang language to choose
#' #' @param n extract chapter_word_no <= n
get_first_n_words_from_chapter <- function(txt, lang, n){
  checkmate::assert_names(names(txt), must.include = c("line", "chapter", "word", "lang", "chapter_word_no"))
  checkmate::assert_choice(lang, choices = unique(txt$lang))
  checkmate::assert_int(n, lower = 1)
  tmp <- txt[txt$lang == lang,]
  tmp <- tmp[tmp$chapter_word_no <= n,]
  tmp
}



#txt <- readRDS(file = "three-men-all.rds")
#write.csv(txt, file = "three_men_multilingual.csv", row.names = FALSE)
#zip(files =  "three_men_multilingual.csv", zipfile =  "three_men_multilingual.csv.zip")
unzip(zipfile = "posterior_database/data/data-raw/three_men_multilingual/three_men_multilingual.csv.zip",
      exdir = "posterior_database/data/data-raw/three_men_multilingual/")
txt <- read.csv(file = "posterior_database/data/data-raw/three_men_multilingual/three_men_multilingual.csv")

crp <- create_corpus(txt,
                     no_words_per_chapter = c("en" = 1200, "fr" = 360, "sv" = 420),
                     rare_word_limit = 10,
                     remove_stopwords = "nltk")
names(crp)[4] <- "type"
crp$type <- as.factor(crp$type)

# tab <- table(crp$lang)
# tab;sum(tab)
# N <- nrow(crp)

# Create corpus versions
crp1 <- crp
crp1$chapter[crp1$chapter <= 10] <- 1
crp1$chapter[crp1$chapter > 10] <- 2
crp1$doc <- as.factor(paste0(crp1$lang, crp1$chapter))
table(crp1$doc)

# To stan
three_men1 <-
  list(V = length(levels(crp1$type)),
       M = length(unique(crp1$doc)),
       N = length(crp1$type),
       w = as.integer(crp1$type),
       doc = as.integer(crp1$doc))


# Corpus 2
crp2 <- crp
crp2$chapter[crp2$chapter <= 10 & crp2$lang != "en"] <- 1
crp2$chapter[crp2$chapter > 10 & crp2$lang != "en"] <- 2
docs <- c(1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10)
for(i in seq_along(docs)) crp2$chapter[crp2$lang == "en" & crp2$chapter == i ] <- docs[i]
crp2$doc <- as.factor(paste0(crp2$lang, crp2$chapter))
table(crp2$doc)

# To stan
three_men2 <-
  list(V = length(levels(crp2$type)),
       M = length(unique(crp2$doc)),
       N = length(crp2$type),
       w = as.integer(crp2$type),
       doc = as.integer(crp2$doc))

# Corpus 3
crp3 <- crp
crp3$chapter[crp3$chapter <= 10 & crp3$lang != "en"] <- 1
crp3$chapter[crp3$chapter > 10 & crp3$lang != "en"] <- 2
docs <- c(1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5)
for(i in seq_along(docs)) crp3$chapter[crp3$lang == "en" & crp3$chapter == i ] <- docs[i]
crp3$doc <- as.factor(paste0(crp3$lang, crp3$chapter))
table(crp3$doc)

# To stan
three_men3 <-
  list(V = length(levels(crp3$type)),
       M = length(unique(crp3$doc)),
       N = length(crp3$type),
       w = as.integer(crp3$type),
       doc = as.integer(crp3$doc))
