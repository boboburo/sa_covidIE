library(lubridate)
library(dplyr)


focus_day_df <- function(df, date){
  
  date = ymd(date)

  df <- df %>% filter(time_stamp == date)
  
  strip_infs_na <- !(
    is.na(rowSums(df %>% select(plt1_x,plt1_y))) | 
      is.infinite(rowSums(df %>% select(plt1_x, plt1_y))))
  
  df <- df[strip_infs_na,]
  
  return(df)
}