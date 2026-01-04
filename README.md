# COVID-Data-Exploration

The main reporsitory consists of the datasets used as well as the SQL files. The dataset used here is from [ourworldindata](https://ourworldindata.org/covid-deaths), though the columns have been changed now the dataset uploaded in the repository contains all we need for the data exploration.

The csv files might cause troubles due to inconsistent and unformatted data , I've added a data importing file which was used for importing the covidvaccinations data. If the Import Wizard fails on MySQL workbench then this is the alternative I found useful. ALso remember to give permission to read a file from your local system. You can do this by going to Edit Connection>Advanced>text box and then including the connection parameter.

We create views of certain queries as well which is useful for data visualization using Tableau
