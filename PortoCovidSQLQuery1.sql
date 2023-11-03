
Select *
From PortCovidProject..PortCovidDeaths
Order by 3,4

Select *
From PortCovidProject..PortCovidVaccinations
Where location = 'indonesia'
Order by 3,4

Select continent, location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as float))*100 as DeathPercentage
From PortCovidProject..PortCovidDeaths
--Where continent is not null
Where location = 'indonesia'
Order by 1,2,3

Select continent, location, date, population, total_cases, (cast(total_cases as int)/population)*100 as CovidPercentage
From PortCovidProject..PortCovidDeaths
--Where continent is not null
Where location = 'indonesia'
Order by 1,2,3

Select continent, location, population, max(cast(total_cases as int)) as HighestInfectionCount, max(cast(total_cases as int)/population)*100 as PopulationInfectedPercentage
From PortCovidProject..PortCovidDeaths
--Where continent is not null
--Where location = 'indonesia'
Where continent = 'asia'
Group by continent, location, population
Order by PopulationInfectedPercentage desc

Select continent, location, max(cast(total_deaths as int)) as TotalDeathCount
From PortCovidProject..PortCovidDeaths
--Where continent is not null
--Where location = 'indonesia'
Where continent = 'asia'
Group by continent, location
Order by TotalDeathCount desc

Select date, nullif(sum(new_cases),0), nullif(sum(new_deaths),0),nullif(sum(new_deaths),0)/nullif(sum(new_cases),0)*100
From PortCovidProject..PortCovidDeaths
Where continent is not null
--Where location = 'indonesia'
Group by date
Order by 1

with PopulationVsVaccination (continent, location, date, population, new_vaccination, CummulativeVaccination)
as
(
Select pcd.continent, pcd.location, pcd.date, population, new_vaccinations, sum(cast(new_vaccinations as int)) over (partition by pcd.location order by pcd.location,pcd.date) as CummulativeVaccination
From PortCovidProject..PortCovidDeaths pcd
Join PortCovidProject..PortCovidVaccinations pcv
on pcd.location = pcv.location and pcd.date = pcv.date
Where pcd.continent is not null
)
Select *, (CummulativeVaccination/population)*100
From PopulationVsVaccination
Where location = 'indonesia'

Create View FinalCovidPortfolio01 as
Select continent, location, population,
sum(cast(new_cases as int)) as Total_Cases, 
sum(cast(new_deaths as int)) as Total_Deaths, 
sum(cast(new_cases as float))/population*100 as Infection_Rate,
nullif(sum(cast(new_deaths as float)),0)/sum(cast(new_cases as int))*100 as Death_Rate
From PortCovidProject..PortCovidDeaths
Where continent is not null
--Where location = 'indonesia'
--and continent = 'asia'
Group by continent, location, population

Select *
From PortCovidProject..finalcovidportfolio01

Create view FinalCovidPortfolio02 as
Select pcd.continent, pcd.location, pcd.date, population, new_cases, new_deaths, people_vaccinated,
(sum(cast(new_cases as bigint)) over (partition by pcd.location order by pcd.location,pcd.date)/pcd.population)*100 as CasePercentage,
(sum(cast(new_deaths as bigint)) over (partition by pcd.location order by pcd.location,pcd.date)/pcd.population)*100 as DeathPercentage,
(cast(people_vaccinated as bigint))/pcd.population*100 as VaccinationPercentage
From PortCovidProject..PortCovidDeaths pcd
Join PortCovidProject..PortCovidVaccinations pcv
	on pcd.location = pcv.location and pcd.date = pcv.date
Where pcd.continent is not null

With Cte as
(
Select *, 
count(VaccinationPercentage) over (partition by location order by location, date) as CountVac
From FinalCovidPortfolio02
)
Select *,
FIRST_VALUE(VaccinationPercentage) over (partition by location, CountVac order by date) as VaccPercentage
From Cte