# laod in data for the app
library(here)
library(dplyr)
library(DBI)
library(RSQLite)
library(janitor)
library(lubridate)
library(RcppRoll)
library(tidyr)
library(stringr)


# Connect to the SQLite DB 
con <- dbConnect(RSQLite::SQLite(), 
                 here("covid-ireland.db"))



#list the tables in the DB
# dbListTables(con)
# dbListFields(con, "dailycases")

#### Future data will load data from Google Cloud ###
# require test to check that the columns exist
pop_grp <- 100000

dailycases <- tbl(con, "dailycases") %>%
  select(OBJECTID,ORIGID,CountyName,PopulationCensus16,
         TimeStamp, ConfirmedCovidCases, PopulationProportionCovidCases) %>%
  collect() %>%
  rename(cumm_cases = ConfirmedCovidCases,
         tot_infected_per_100k = PopulationProportionCovidCases) %>%
  clean_names()

dbDisconnect(con)

#tidy up the date column 
dailycases <- dailycases %>% 
  mutate(time_stamp = ymd(str_sub(time_stamp,1,10)))

#all new columns and prefix c
dailycases <- dailycases %>% 
  group_by(county_name) %>% 
  arrange(time_stamp) %>%
  mutate(
    day_cases = cumm_cases - lag(cumm_cases,1), 
    day_delta = as.integer(time_stamp - lag(time_stamp,1)), #see not below: 
    day_cases_7 = roll_mean(day_cases, n = 7, align = "right", fill = NA),
    day_cases_14 = roll_mean(day_cases, n = 14, align = "right", fill = NA),
    day_cases_7x2 = roll_mean(day_cases_7, n = 7, align = "right", fill = NA),
    day_casess_14x2 = roll_mean(day_cases_14, n = 14, align = "right" , fill = NA ),
    chg7_in_day_cases_7x2 = day_cases_7x2 - lag(day_cases_7x2, 7),
    avg_chg7 = roll_mean(chg7_in_day_cases_7x2, n = 7, align = "right", fill = NA),
    cumm_14 = roll_sum(day_cases, n =14, align = "right", fill = NA),
    cumm_14_inc = cumm_14 / (population_census16/ pop_grp),
    cumm_14_inc_7_day_chg = (cumm_14_inc - lag(cumm_14_inc, 7))/lag(cumm_14_inc,7),
    plt1_x =  cumm_14_inc,
    plt1_y = cumm_14_inc_7_day_chg) %>%
  ungroup()
