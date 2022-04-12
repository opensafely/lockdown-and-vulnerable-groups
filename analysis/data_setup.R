
here::i_am("lockdown-and-vulnerable-groups/analysis/data_setup.R")
here()

library(here)
library(feather)
library(tidyverse)
library(readr)

here("GitHub", "lockdown-and-vulnerable-groups", "output", "input_PreNIPP_2020-02-24.feather")

input_2020_02_24<- read_feather (here::here ("GitHub/lockdown-and-vulnerable-groups/outputoutput/measures", "input_PreNIPP_2020-02-24.feather"))

input <- read_csv(here::here("GitHub/lockdown-and-vulnerable-groups/output", "input_PreNIPP_2020-02-24.csv.gz"))
collapse <- summaryBy(
