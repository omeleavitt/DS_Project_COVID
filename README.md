## Data Science for BME: Final Project
#### Olivia Leavitt/omeleavitt
##### 15 May 2020

By now, COVID-19, the disease caused by the coronavirus SARS2-CoV-19 has reached most countries worldwide and
has had unprecedented impacts on daily life. One of the most dangerous aspects of COVID is the wide variety of 
symptom severity between patients. Some patients are asymptomatic or only develop a cough, while others have 
severe lung damage that requires hospitalization. Generally, older patients are more at risk of developing the 
most severe symptoms, while young adults and children tend to be asymptomatic. Those who are asymptomatic can
still spread the disease, and may do so unknowingly. This is particularly true in schools, where students can
have extremely close contact. Therefore, many nations and local governments decided to close schools in the early
days of the COVID pandemic. Along with social distancing, remote schooling allowed many daily activities to continue
while limiting social contact between people, an important first step in limiting the spread of the pandemic.
A positive side-effect of the transition to remote schooling and suspension of childcare is that many parents
who may not otherwise comply with social distancing guidelines due to work responsibilities are forced to 
stay home to care for their children. Thus, the transition to remote schooling also limits the number of adults
that might spread the disease. There was also concern that schools themselves may become super-spreader sites
because children are mostly asymptomatic. The webapp presented is an attempt to demonstrate the effect of school
closure and reopening on COVID-19 case and death rates through the ARIMA prediction algorithm.

The ARIMA or auto-regressive integrated moving average algorithm is used to make predictions about future points in a time 
series based on the previous values of a univariate time series. External regressors may also be added to the model. 
An R package exists that implements the ARIMA algorithm for forecasting. Time series used in the model must be univariate
and stationary; any non-stationarity such as seasonality in the data must be accounted for. For each time point in the 
preceeding time series, a generalized linear model is fit to the time series data with the previous /p/ timepoints included
as regressors along with any covarying data. This model can then be used to forecast forward. 

This app uses data on the educational impact of COVID-19 and the students enrolled at each level of education as of 2015 
collected from the UNESCO website, and the Our World In Data dataset on current COVID-19 cases. The OWID dataset is updated
automatically daily and is downloaded in the setup section of the app. After data cleaning, the datasets are combined such that
there is one master data table in "long format" that has time series data of cases and deaths as well as current student 
enrollment and the daily status of schools. The number of children in school is taken as the number of students enrolled in pre-primary,
primary, and lower secondary school. Children finishing lower secondary school are 13-14 years of age and probably would not
require full-time care by a parent staying at home. The level of school closure (local or national) is also taken into account
by using it as a factor. The school status flag is converted to a number that is multiplied by the number of children--zero if the
schools are open, 1 if they are closed locally, or 2 if they are closed nationally. The code then makes a time series out of the user selected data set (new or cumulative, deaths 
or cases, and country) and fits the ARIMA model. Then a time series of the regressor values (the school status) is made from the
user-input forecast length and school reopening date, which is then used to make a forecast.

Dependencies:
The code requires the packages tidyverse, shiny, tseries, glmnet, and forecast. All are available through CRAN

Link:
The live app can be found at: <https://omeleavitt.shinyapps.io/CovidSchools/>

Video:
The video presentation can be found at: https://drive.google.com/file/d/1I5eQdLs1eEsHaac8zGrhD5fbAEPWoc_u/view?usp=sharing

Data sources: <https://en.unesco.org/covid19/educationresponse>; 
<http://data.uis.unesco.org/Index.aspx?DataSetCode=EDULIT_DS&popupcustomise=true&lang=en>; 
<https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data.csv>

Example: Open the link and try selecting Belgium, new_cases. Play with the sliders and notice that the sharp increase in
new cases corresponds to the date selected for school reopening. The vertical line corresponds to when schools closed.
This effect is not robust for many data selections; this
is likely because many nations followed school closing protocols almost immediately and since the ARIMA model is based only
on previous data points, the early closing means only a modest change in the forecast which is easily obscured.
