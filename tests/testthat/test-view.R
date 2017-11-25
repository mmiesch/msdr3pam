context("Test summary and map")

test_that("summarize works", {

  dir <- system.file("extdata",package="msdr3pam")
  dfsum <- fars_summarize_years(c(2013,2014,2015),dir=dir)
  expect_equal(dfsum$"2015"[6],2765)
  expect_equal(dfsum$"2013"[1],2230)
})

test_that("map works", {

  dir <- system.file("extdata",package="msdr3pam")
  expect_that(fars_map_state(126,2013,dir=dir),throws_error())
  expect_that(fars_map_state(12,3015,dir=dir),throws_error())

})
