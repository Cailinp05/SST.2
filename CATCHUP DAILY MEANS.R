library(tidyverse)
library(data.table) # for fast reading in of csv files
library(doParallel) # for parallel processing

in_dir <- "UTR021_SFW60"
# Specify file path and recursively read all files in all directories:

csv_list <- list.files(path = in_dir, pattern = "*.csv", full.names = TRUE, include.dirs = TRUE, recursive = TRUE)

file <- csv_list[1]

# The function to parse meta-data and read all temperature recordings:
thermoread <- function(file) {
  print(file) # FYI during processing for error checking
  # Read meta-data in header rows for later use; hopefully they are the same for all files...
  meta <- read_csv(file, n_max = 11, col_names = FALSE)
  time_series <- meta$X2[2]
  location <- meta$X2[3]
  latitude <- as.numeric(meta$X2[4])
  longitude <- as.numeric(gsub("([0-9.0-9]+).*$", "\\1", meta$X4[4]))
  depth <- as.numeric(meta$X2[6])
  serial_no <- as.numeric(meta$X4[9])
  # Read the hourly temperatures into a tibble...
  # some files have four data column, others have three; we must be able to read in both:
  ncol_test <- fread(file, skip = 15, nrows = 1) # test the number of columns
  if (ncol(ncol_test) >= 4) { # if 4 or more columns
    temps_hourly <- fread(file, skip = 12, colClasses = c(V2 = "Date", V3 = "character", V4 = "numeric")) |>
      as_tibble() |>
      select(V2, V3, V4) |>
      rename(date = V2, time = V3, temp = V4)
  } else { # if 3 columns
    temps_hourly <- fread(file, skip = 11, colClasses = c(V1 = "Date", V2 = "character", V3 = "numeric")) |>
      as_tibble() |>
      rename(date = V1, time = V2, temp = V3)
  }
  temps_hourly <- temps_hourly |>
    mutate(date = as.POSIXct(paste(date, time), format = "%Y-%m-%d %H:%M"),
           time_series = time_series,
           location = location,
           latitude = latitude,
           longitude = longitude,
           depth = depth,
           serial_no = serial_no) |>
    select(-time)
  return(temps_hourly)
  
  
}

# Apply function to all files in directory:
out.df.5 <- plyr::ldply(.data = csv_list, .fun = thermoread, .parallel = TRUE)


start_date <- as.POSIXct(paste(meta$X2[7], meta$X4[7]))
end_date <- as.POSIXct(paste(meta$X2[8], meta$X4[8]))
tseries <- seq.POSIXt(from = start_date, to = end_date, by = "hour")

# Correct dates to the temps tibble:
temps_hourly <- temps_hourly |>
  mutate(date = tseries)

# Calculate the mean temperature for each day:
temps_daily <- temps_hourly |>
  group_by(as.Date(date)) |>
  summarise(temp = mean(temp, na.rm = TRUE))
