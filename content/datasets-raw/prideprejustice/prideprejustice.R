library(janeaustenr)
library(tidytext)

data("prideprejudice")

# Pride and
dat <- data.frame(text = prideprejudice, paragraph = 0, chapter = 0, stringsAsFactors = FALSE)

# Add paragraphs and chapter sID
paragraph_indication <- as.integer(dat$text == "")
dat$paragraph <- cumsum(paragraph_indication)

chapter_indication <- as.integer(grepl(stringr::str_trim(tolower(dat$text)), pattern = "^chapter [0-9]+$"))
dat$chapter <- cumsum(chapter_indication)

# Remove chapter titles
dat <- dat[!chapter_indication,]

# Tidy data
tidy_pride <- unnest_tokens(dat, word, text)

# Remove stopwords (taken from the Mallet stopword list)
stopwords <- data.frame(word = readLines("stops_en.txt"), stringsAsFactors = FALSE)
tidy_pride <- anti_join(tidy_pride, y = stopwords)

# Remove rare words
word_freq <- table(tidy_pride$word)
rare_words <- data.frame(word = names(word_freq[word_freq <= 5]), stringsAsFactors = FALSE)
tidy_pride <- anti_join(tidy_pride, y = rare_words)

# Cleanup
tidy_pride$word <- stringr::str_replace_all(tidy_pride$word, pattern = "_", replacement = "")
tidy_pride <- tidy_pride[tidy_pride$chapter>0,]
tidy_pride$paragraph <- as.integer(as.factor(tidy_pride$paragraph))
tidy_pride$w <- as.integer(as.factor(tidy_pride$word))

vocabulary <- levels(as.factor(tidy_pride$word))

# To stan
prideprejustice_paragraph <-
  list(V = length(vocabulary),
       M = length(unique(tidy_pride$paragraph)),
       N = length(tidy_pride$w),
       w = tidy_pride$w,
       doc = tidy_pride$paragraph,
       alpha = rep(0.1, 5L),
       beta = rep(0.1, length(vocabulary)))

writeLines(jsonlite::toJSON(prideprejustice_paragraph, pretty = TRUE, auto_unbox = TRUE), con = "prideprejustice_paragraph.json")
zip(zipfile = "prideprejustice_paragraph.json.zip", files = "prideprejustice_paragraph.json")

data_info <- list(title = jsonlite::unbox("The book 'Pride and Prejustice' by Jane Austen."),
                  description = jsonlite::unbox("The book has been tokenized, stop words and rare words (<=5) has been removed. Variable 'doc' is paragraph id."),
                  urls = character(0),
                  references = character(0),
                  keywords = "text data")
jsonlite::write_json(data_info, "prideprejustice_paragraph.info.json", pretty = TRUE)

prideprejustice_chapter <-
  list(V = length(vocabulary),
       M = length(unique(tidy_pride$chapter)),
       N = length(tidy_pride$w),
       w = tidy_pride$w,
       doc = tidy_pride$chapter,
       alpha = rep(0.1, 5L),
       beta = rep(0.1, length(vocabulary)))

writeLines(jsonlite::toJSON(prideprejustice_chapter, pretty = TRUE, auto_unbox = TRUE), con = "prideprejustice_chapter.json")
zip(zipfile = "prideprejustice_chapter.json.zip", files = "prideprejustice_chapter.json")

data_info <- list(title = jsonlite::unbox("The book 'Pride and Prejustice' by Jane Austen."),
                  description = jsonlite::unbox("The book has been tokenized, stop words and rare words (<=5) has been removed. Variable 'doc' is chapter id."),
                  urls = character(0),
                  references = character(0),
                  keywords = "text data")
jsonlite::write_json(data_info, "prideprejustice_chapter.info.json", pretty = TRUE)

