# f-sabiti

COVID-19 data are downloaded from [Our World in Data's GitHub Repository](https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv) on 20 April 2020.

The data has been filtered for dates after 10th death for each country. This means that countries with less than 10 total deaths due to COVID-19 so far are not included in the analysis, leaving `r n_country_ecdc` countries for analysis of all countries and `r n_country_ecdc_mt100_deaths` for analysis of all countries with more than 100 total deaths due to COVID-19.

This document addresses (though doesn't exactly answer) two questions:

1. Is the consistency in Turkey's cumulative deaths to cumulative confirmed cases ratio across consecutive days naturally occurring or might it indicate manipulation in numbers?

2. Can Benford's law be used to explore whether the numbers reported by Turkey are real or manipulated?

The rendered report can be found [here](https://rpubs.com/minebocek/f-sabiti).
