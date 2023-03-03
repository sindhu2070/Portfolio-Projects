-- Drop rows showing data for each continent:
delete from project_portfolio.covid_deaths 
where location  in ('Africa','Europe','European Union','High income','International','Low income','North America',
'Oceania','Asia','South America') limit 1000000000


-- Data used for data exploration:
SELECT continent, location, date, total_cases, new_cases, total_deaths, population  FROM project_portfolio.covid_deaths WHERE continent IS NOT NULL ORDER BY 3 , 4 limit 100000000

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,  round(total_deaths*100/total_cases) as percentage_of_deaths FROM project_portfolio.covid_deaths 
where location like '%india' and continent is not null order by 1,2 

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, total_cases, population,  round((total_cases*100/population),2) as infected_percentage FROM project_portfolio.covid_deaths 
where location like '%india' and continent is not null order by 1,2 

-- Countries with Highest Infection Rate compared to Population
SELECT location, population,  max(total_cases) as HighestInfectionCount, round(max(total_cases*100/population),2) as PercentPopulationInfected
 FROM project_portfolio.covid_deaths 
where  continent is not null  group by location order by 4 desc

-- Countries with Highest Death Count per Population
SELECT location, population,  max(total_deaths) as HighestDeathCount, round(max(total_deaths*100/population),4) as TotalDeathCountPercentage
 FROM project_portfolio.covid_deaths 
where  continent is not null  group by location order by 4 desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
with cte as
(SELECT continent, location ,max(population) as population,  max(total_deaths) as HighestDeathCount
 FROM project_portfolio.covid_deaths 
where  continent is not null  group by date)
select continent, sum(population) as TotalPopulation, sum(HighestDeathCount) as TotalDeathCount
from cte group by continent order by 3 desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)*100/SUM(New_Cases) as DeathPercentage
From project_portfolio.covid_deaths

SELECT * FROM project_portfolio.covid_vaccinations limit 1000000000

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select t.*, round(t.PeopleVaccinated*100/t.population,2) as perc_population_vaccinated from 
( SELECT cv.location, cd.population, max(cv.people_vaccinated) as
  PeopleVaccinated
  FROM project_portfolio.covid_vaccinations cv join project_portfolio.covid_deaths cd on cv.date= cd.date and cv.location= cd.location
  group by cv.location, cd.population) t
order by 1,2

-- Using CTE to perform Calculation in previous query

with PopvsVac AS(
 SELECT cv.location, cd.population, max(cv.people_vaccinated) as
 PeopleVaccinated
 FROM project_portfolio.covid_vaccinations cv join project_portfolio.covid_deaths cd on cv.date= cd.date and cv.location= cd.location
 group by cv.location, cd.population
 order by 1,2)
select PopvsVac.*,round(PeopleVaccinated*100/population,2) as perc_population_vaccinated from PopvsVac
 
 
-- Using Temp Table to perform Calculation in previous query

create temporary table if not exists temp_table
with PopvsVac AS(
 SELECT cv.location, cd.population, max(cv.people_vaccinated) as
 PeopleVaccinated
 FROM project_portfolio.covid_vaccinations cv join project_portfolio.covid_deaths cd on cv.date= cd.date and cv.location= cd.location
 group by cv.location, cd.population
 order by 1,2)
select PopvsVac.*,round(PeopleVaccinated*100/population,2) as perc_population_vaccinated from PopvsVac

select * from temp_table

-- Creating View to store data for later visualizations

create view project_portfolio.PercentPopulationVaccinated as
select t.*, round(t.PeopleVaccinated*100/t.population,2) as perc_population_vaccinated from 
( SELECT cv.location, cd.population, max(cv.people_vaccinated) as
  PeopleVaccinated
  FROM project_portfolio.covid_vaccinations cv join project_portfolio.covid_deaths cd on cv.date= cd.date and cv.location= cd.location
  group by cv.location, cd.population) t
order by 4 desc
 




