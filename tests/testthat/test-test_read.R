context("test read")

test_that("path is valid", {
  dir <- system.file("extdata",package="msdr3pam")
  expect_that(nchar(dir) > 1, is_true())

  expect_that(make_filename("bob",dir),gives_warning())
  expect_equal(make_filename(2013,dir)
              ,paste0(dir,"/accident_2013.csv.bz2"))

})

test_that("read is successful", {
  dir <- system.file("extdata",package="msdr3pam")

  df <- fars_read(make_filename(2013,dir))
  
  expect_equal(dim(df),c(30202,50))
  expect_equal(df$STATE[23000],42)
  expect_equal(df$YEAR[11456],2013)
  expect_equal(df$FATALS[12600],3)

  expect_that(fars_read(make_filename(3050,dir=dir)),throws_error())
  expect_that(fars_read_years(c(3050,3060),dir=dir),gives_warning())

  y <- fars_read_years(c(2013,2014,2015),dir=dir)
  expect_equal(dim(y[[2]]),c(30056,2))
  expect_equal(y[[1]]$year[8],2013)
  expect_equal(y[[3]]$MONTH[1900],7)

})
