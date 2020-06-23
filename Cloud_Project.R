#HPC
install.packages("devtools")
devtools::install_github("hadley/multidplyr")
install.packages("Rcpp")
install.packages("quantmod")
install.packages("xml2")
install.packages("rlang")

install.packages("devtools")
library(devtools)
install_github("hadley/multidplyr")

library(multidplyr) # parallel processing
library(rvest)      # web scraping
library(tidyverse)  # ggplot2, purrr, dplyr, tidyr, readr, tibble
library(stringr)    # working with strings
library(lubridate)  # working with dates 
library(parallel)

library(data.table)
library(rvest)
library(quantmod)
library(parallel)

num1<- read.csv("numbers.csv")
str(num1)

fun5<-function(X1, return_format = "tibble"){
  
  abc <- ifelse(X1<51, 1,0)
  if (return_format == "tibble") {
      abc <- abc %>%
      as_tibble()
  }
  return (abc)
}

old<-Sys.time()
num1_processed_in_series <- num1 %>%
  mutate(
    total = map(.x = num1$X1, 
                       ~ fun5(X1 = .x, 
                              return_format = "tibble")
              )               
  )
new<- Sys.time()-old
t(new)

num1_processed_in_series %>% unnest()

detectCores()

group <- rep(1:10, length.out = nrow(num1))
num1 <- bind_cols(tibble(group), num1)
num1

cluster <- create_cluster(cores = 10)
cluster

by_group <- num1 %>%
  partition(group, cluster = cluster)
by_group

by_group %>%
  # Assign libraries
  cluster_library("tidyverse") %>%
  cluster_library("stringr") %>%
  cluster_library("lubridate") %>%
  cluster_library("quantmod") %>%
  # Assign values (use this to load functions or data to each core)
  cluster_assign_value("fun5", fun5) 

cluster_get(by_group, "fun5")[[1]]

old<-Sys.time()

num1_processed_in_parallel <- by_group %>% # Use by_group party_df
  mutate(
    total = map(.x = X1, ~fun5(X1 = .x, 
                               return_format = "tibble")
    )
  ) %>%
  collect() %>%  
  as_tibble()
new<- Sys.time()-old
t(new)

num1_processed_in_parallel %>% unnest()


#Creating random nos and saving it
a <- floor(runif(100000, min=0, max=101))

write.csv(a, file ="myfile.csv", row.names=FALSE)

