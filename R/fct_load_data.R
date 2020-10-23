# laod in data for the app
library(here)
library(dplyr)
library(DBI)
library(RSQLite)
library(janitor)
library(lubridate)
library(tidyr)
library(stringr)


POP_GRP = 100000

load_covid_ireland <- function(src = "csv"){
  
  if(src=="csv"){
    url <-"https://opendata-geohive.hub.arcgis.com/datasets/d9be85b30d7748b5b7c09450b8aede63_0.csv?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D"
    df   <- read.csv(url)
      }
  if(src=="sqlite"){
    
    # Connect to the SQLite DB 
    con <- dbConnect(RSQLite::SQLite(), 
                     here("covid-ireland.db"))
    
    df <- tbl(con, "dailycases") %>%
      collect()
    
    dbDisconnect(con) 

    }
    
  
  df <- df %>% select(OBJECTID,ORIGID,CountyName,PopulationCensus16,
             TimeStamp, ConfirmedCovidCases, PopulationProportionCovidCases)
  
  df <- df %>% rename(cumm_cases = ConfirmedCovidCases,
         cumm_inc = PopulationProportionCovidCases) %>%
  clean_names()
  
  df <- clean_covid_ireland(df)
  
  return(df)
}

clean_covid_ireland <- function(df){
  
  
  #tidy up the date column 
  df <- df %>% 
    mutate(time_stamp = ymd(str_sub(time_stamp,1,10)))
  
  #all new columns and prefix c
  df <- df %>% 
    dplyr::group_by(county_name) %>% 
    dplyr::arrange(time_stamp) %>%
    dplyr::mutate(
      day_cases = cumm_cases - lag(cumm_cases,1), 
      day_delta = as.integer(time_stamp - lag(time_stamp,1)),
      day_cases_7x1 = RcppRoll::roll_mean(day_cases, n = 7, align = "right", fill = NA),
      day_cases_14x1 = RcppRoll::roll_mean(day_cases, n = 14, align = "right", fill = NA),
      day_cases_7x2 = RcppRoll::roll_mean(day_cases_7x1, n = 7, align = "right", fill = NA),
      day_cases_14x2 = RcppRoll::roll_mean(day_cases_14x1, n = 14, align = "right" , fill = NA ),
      chg7_in_day_cases_7x2 = day_cases_7x2 - lag(day_cases_7x2, 7),
      cumm_7 = RcppRoll::roll_sum(day_cases, n = 7, align = "right", fill = NA),
      cumm_14 = RcppRoll::roll_sum(day_cases, n = 14, align = "right", fill = NA),
      cumm_7_inc = cumm_7 / (population_census16/ POP_GRP),
      cumm_14_inc = cumm_14 / (population_census16/ POP_GRP),
      cumm_7_inc_7x1 = RcppRoll::roll_mean(cumm_7_inc, n = 7, align = "right", fill = NA),
      cumm_14_inc_14x1 = RcppRoll::roll_mean(cumm_14_inc, n = 14, align = "right", fill = NA),
      cumm_7_inc_7x2 = RcppRoll::roll_mean(cumm_7_inc_7x1, n = 7, align = "right", fill = NA),
      cumm_14_inc_14x2 = RcppRoll::roll_mean(cumm_14_inc_14x1, n = 14, align = "right", fill = NA),
      cumm_7_inc_7_day_chg = (cumm_7_inc - lag(cumm_7_inc, 7))/lag(cumm_7_inc,7),
      cumm_14_inc_7_day_chg = (cumm_14_inc - lag(cumm_14_inc, 7))/lag(cumm_14_inc,7),
      plt1_x =  cumm_7_inc,
      plt1_y = cumm_7_inc_7_day_chg) %>%
    dplyr::ungroup()
  
  #remove the very first date
  df <- df %>% filter(time_stamp != lubridate::ymd("2020-02-27"))
  
  return(df)
  
}
