#====================================================================
#' Print "FARS Read"
#'
#' \code{fars_read} reads data regarding fatal injuries suffered in
#' motor vehicle accidents in the US, as reported by the Fatality
#' Analysis Reporting System (FARS) of the US National Highway 
#' Traffic Safety Administration.
#'
#' @param filename A character string containing the name of the file
#'     to read.  It is assumed to be a csv file (possibly compressed) 
#'     as provided by FARS. 
#'
#' @param dir a character string containing the directory that contains
#'     the FARS data
#'
#' @return The function returns a tibble data frame (class tbl_df) as 
#'    defined ' by the dplyr package.  If the file does not exist, 
#'    the function returns ' a NULL value.  '
#'
#' @references 
#'   \url{https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars}
#'
#' @examples
#' df <- fars_read(make_filename(2014),system.file("extdata",package="msdr3pam"))
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @seealso \code{make_filename}, \code{fars_read_years}
#'
#' @export

fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#====================================================================
#' Print "Make Filename"
#'
#' \code{make_filename} creates a csv filename corresponding to 
#' tabular data for a particular year from the Fatality Analysis 
#' Reporting System (FARS) of the US National Highway Traffic Safety 
#' Administration.  The filename follows standard FARS naming 
#' convention, including a "bz2"extension reflecting bzip2 compression.
#'
#' @param year an integer or character string specifying the 
#'     desired (4-digit) calendar year 
#'
#' @param dir a character string containing the directory that contains
#'     the FARS data
#'
#' @return The function returns the name of the file (as a character
#'     string) containing FARS data for the specified year
#'
#' @references 
#'   \url{https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars}
#'
#' @examples
#' filename <- make_filename(2014,system.file("extdata",package="msdr3pam))
#' filename <- make_filename('2014',system.file("extdata",package="msdr3pam))
#'
#' @seealso \code{fars_read}
#'
#' @export

make_filename <- function(year,dir="./inst/extdata") {
        year <- as.integer(year)
        file <- sprintf("accident_%d.csv.bz2", year)
        file.path(dir,file)
}

#=================================================================
#' Print "FARS Read Years" 
#'
#' \code{fars_read_years} returns the month and year for each 
#' row (observation) in a series of FARS data files.  Each 
#' data file contains data for one calendar year on fatal 
#' injuries suffered in motor vehicle accidents as compiled
#' by the Fatality Analysis Reporting System (FARS) of the 
#' US National Highway Traffic Safety Administration.
#' If the data file for a specified year is not found
#' or is not in the proper format, a NULL value is returned.
#'
#' @param years a list of years (each represented as 4-digit integers 
#'     or character strings) for which data is desired
#'
#' @param dir a character string containing the directory that contains
#'     the FARS data
#'
#' @return The function returns a nested list of tibble data frames 
#'     (class tbl_df, as defined by the dplyr package), one for each
#'      year.  Each tibble data frame has two columns, MONTH and year.
#'
#' @references 
#'   \url{https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars}
#'
#' @examples
#' dir <- system.file("extdata",package="msdr3pam")
#' y <- fars_read_years(c(2013,2014,2015),dir=dir)
#' y <- fars_read_years(c('2013','2015'),dir=dir)
#' y <- fars_read_years(list('2014','2015'),dir=dir)
#'
#' @importFrom dplyr tbl_df mutate select
#'
#' @seealso \code{fars_read}, \code{fars_summarize_years}
#'
#' @export

fars_read_years <- function(years,dir='./inst/extdata') {
        lapply(years, function(year) {
                file <- make_filename(year,dir)                
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>% 
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#=================================================================
#' Print "FARS Summarize Years"
#'
#' \code{fars_summarize_years} lists the number of fatal 
#' injuries suffered in motor vehicle accidents in each month
#' for a specified list of years.  The data is compiled by the 
#' Fatality Analysis Reporting System (FARS) of the US National 
#' Highway Traffic Safety Administration.  
#'
#' @param years a list of years (each represented as 4-digit 
#'     integers or character strings) for which data is desired
#'
#' @param dir a character string containing the directory that contains
#'     the FARS data
#'
#' @return The function returns a tibble data frame (class tbl_df, 
#'     as defined by the dplyr package) with twelve rows, each 
#'     corresponding to a month of the year.  Columns correspond
#'     to different years and data values represent the number of
#'     fatalities for each year and month.
#'
#' @references 
#'   \url{https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars}
#'
#' @examples
#' dir <- system.file("extdata",package="msdr3pam")
#' fars_summarize_years(c(2013,2014,2015),dir=dir)
#' fars_summarize_years(c('2013','2015'),dir=dir)
#' fars_summarize_years(list('2014','2015'),dir=dir)
#'
#' @importFrom dplyr tbl_df bind_rows group_by summarize 
#' @importFrom tidyr spread
#' @import magrittr
#'
#' @seealso \code{fars_read_years, fars_read}
#'
#' @export

fars_summarize_years <- function(years,dir='./inst/extdata') {
        dat_list <- fars_read_years(years,dir=dir)
        dplyr::bind_rows(dat_list) %>% 
                dplyr::group_by(year, MONTH) %>% 
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#====================================================================
#' Print "FARS Map State"
#'
#' \code{fars_map_state} maps out the fatal motor vehicle accidents 
#' for a particular state in a particular year, according to data
#' compiled by the Fatality Analysis Reporting System (FARS) of 
#' the US National Highway Traffic Safety Administration. 
#'
#' @param state.num number of state for which data is requested
#'        (between 1 and 51).
#'
#' @param year desired calendar year
#'
#' @param dir a character string containing the directory that contains
#'     the FARS data
#'
#' @return The function plots a map of the state in question, 
#'     with points marking the locations of fatal motor vehicle
#'     accidents in the specified year.  
#'
#' @note An error message will be generated if the state number 
#'     is not in the required range (1 to 51), if the data
#'     file for the specified year cannot be found, or if
#'     the data file is not in the proper FARS format.
#'
#' @examples
#' dir <- system.file("extdata",package="msdr3pam")
#' fars_map_state(26,2013,dir=dir)
#' fars_map_state(1,2015,dir=dir)
#'
#' @importFrom dplyr tbl_df filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#' @export

fars_map_state <- function(state.num,year,dir='./inst/extdata') {
        filename <- make_filename(year,dir=dir)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
#=================================================================
