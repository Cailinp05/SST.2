# Day_1.R
# Reads in some data about SST collected various locations
# Do various data manipulations, analyses and graphs
# <Cailin_Pillay>
# <25/08/2021>

library(tidyverse)

# Run this if 'Bird_Island_Offshore_BI0_UTR11_10m_Pos7_001.csv` has columns separated by ';'
Bird_Island_Offshore_BI0_UTR11_10m_Pos7_001 <- read_csv("UTR011/Bird_Island_Offshore_BI0_UTR11_10m_Pos7_001.csv")

View(Bird_Island_Offshore_BI0_UTR11_10m_Pos7_001)
names(Bird_Island_Offshore_BI0_UTR11_10m_Pos7_001)

Bird_Island_Offshore_BI0_UTR11_10m_Pos7_001 %>% 
  +     select(`Project:`, `Algoa Bay Long Term Monitoring & Research`, `Sub Project:`) %>% # Select specific columns first
  +     slice(10:22)


