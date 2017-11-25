## ------------------------------------------------------------------------
dir <- file.path("~","Desktop","fars_data")

## ------------------------------------------------------------------------
dir <- system.file("extdata",package="msdr3pam")

## ----make filename-------------------------------------------------------
library(msdr3pam)
make_filename(2013,dir=dir)

## ----read data-----------------------------------------------------------
df <- fars_read(make_filename(2013,dir=dir))
head(df)

