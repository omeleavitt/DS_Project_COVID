library(tidyverse)
library(glmnet)
library(tseries)
library(forecast)

# Load all datasets
world_ed_data = read_csv('EDULIT_DS_11052020130401190.csv')
ed_impact_data = read_csv('covid_impact_education (1).csv')
covid_data = read_csv(url('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv'))

# Edit data tables so they can be combined
world_ed_data = world_ed_data %>% 
  select(LOCATION, Country, Indicator, Value) %>% 
  pivot_wider(names_from = Indicator, values_from = Value) %>%
  dplyr::rename(ISO = LOCATION,
                PrePrimary = 'Enrolment in pre-primary education, both sexes (number)',
                Primary = 'Enrolment in primary education, both sexes (number)',
                Low_Sec = 'Enrolment in lower secondary education, both sexes (number)',
                Up_Sec = 'Enrolment in upper secondary education, both sexes (number)',
                Sec_tot = 'Enrolment in secondary education, both sexes (number)',
                Post_sec_non_tert = 'Enrolment in post-secondary non-tertiary education, both sexes (number)',
                Tert = 'Enrolment in tertiary education, all programmes, both sexes (number)',
                ChildDev = 'Enrolment in early childhood educational development programmes, both sexes (number)',
                EChild = 'Enrolment in early childhood education, both sexes (number)') %>%
  select(-Sec_tot)

## The sum of the number of students enrolled in pre-primary, primary, and lower secondary school
#  is used as a proxy for the number of children requiring at-home care. By the time a child
#  finishes lower secondary school (middle school) in most contries they are 14 or 15 years old.
world_ed_data$Children = world_ed_data$PrePrimary + world_ed_data$Primary + world_ed_data$Low_Sec
#  The world total fertility rate is 2.5 children per woman. We assume one parent can care for an
#  entire household of children.
world_ed_data$Parents = world_ed_data$Children/2.5
world_ed_data = world_ed_data %>% select(c(ISO, Country, Children, Parents))

ed_impact_data$Date = as.Date.character(ed_impact_data$Date, '%d/%m/%Y')
closure_date <- ed_impact_data[match(unique(ed_impact_data$Country), ed_impact_data$Country),]

covid_data$date = as.Date.character(covid_data$date, '%Y-%m-%d')
covid_data = covid_data %>% dplyr::rename(Date = date, Country = location, ISO = iso_code)

ed_data = right_join(world_ed_data, closure_date, by = c('ISO', 'Country'))
ed_data = rename(ed_data, ClosureDate = Date, ClosureType = Scale) %>% select(-Note)

all_data = full_join(covid_data, ed_data, by = c('ISO'))
all_data = all_data %>% select(c(ISO, Country.x, Date, new_cases, total_cases, new_deaths, total_deaths, Children, Parents, population, population_density, median_age, ClosureDate, ClosureType)) %>% rename(Country = Country.x)


#all_data$Children = all_data$Children/all_data$population
#all_data$Parents = all_data$Parents/all_data$population

all_data$Date = as.numeric(difftime(all_data$Date, as.Date('2019/12/31'), units = 'days'))
all_data$ClosureDate = as.numeric(difftime(all_data$ClosureDate, as.Date('2019/12/31'), units = 'days'))
all_data$ClosureType = all_data$ClosureType %>% as.factor()
#all_data$SchoolClosedFlag = as.numeric(difftime(all_data$Date, all_data$ClosureDate)>=0)
all_data$SchoolClosedFlag = as.numeric(all_data$Date-all_data$ClosureDate>0)
all_data = all_data %>% drop_na()
DNK_data = filter(all_data, ISO == 'DNK')

DNK_ts = ts(data=DNK_data$total_cases, start = 0, end = max(DNK_data$Date))
DNK_mod = auto.arima(DNK_ts, xreg = c(-DNK_data$SchoolClosedFlag*DNK_data$Children*DNK_data$ClosureType))
OpenDay = 80
ForecastLength = 150
Flags = as.numeric(c(seq(1:ForecastLength))<OpenDay)

fc = forecast(DNK_mod, xreg = Flags*DNK_data$Children[1])
autoplot(fc)




        