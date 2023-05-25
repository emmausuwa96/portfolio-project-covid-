select *
from portfolio..coviddeaths
order by 3,4

--select *
--from portfolio..covidvacinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolio..coviddeaths
order by 1,2

---looking at total deaths vs total cases
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolio..coviddeaths
order by 1,2

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolio..coviddeaths
Where location like '%states%'
order by 1,2
---looking at total cases vs population
---showing what percentage got covid
select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from portfolio..coviddeaths
Where location like '%Nigeria%'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from portfolio..coviddeaths
Where location like '%states%'
order by 1,2

---looking countries with highest infection rate.

select location, population, MAX(total_cases) as highestinfectioncount, population, MAX((total_cases/population))*100 as percentpopulationinfected
from portfolio..coviddeaths
Where location like '%Nigeria%'
group by location, population
order by 1,2

select location, population, MAX(total_cases) as highestinfectioncount, population, MAX((total_cases/population))*100 as percentpopulationinfected
from portfolio..coviddeaths
Where location like '%states%'
group by location, population
order by 1,2

select location, population, MAX(total_cases) as highestinfectioncount, population, MAX((total_cases/population))*100 as percentpopulationinfected
from portfolio..coviddeaths
--Where location like '%Nigeria%'
group by location, population
order by percentpopulationinfected desc

---showing conutries with the highest death count per population

select location, MAX (total_deaths) as totaldeathcounts
from portfolio..coviddeaths
--Where location like '%Nigeria%'
where continent is not null
group by location
order by totaldeathcounts desc


---let break things down by continent


select continent, MAX (total_deaths) as totaldeathcounts
from portfolio..coviddeaths
--Where location like '%Nigeria%'
where continent is not null
group by continent
order by totaldeathcounts desc


---showing continents with the highest death count per population


select continent, MAX (total_deaths) as totaldeathcounts
from portfolio..coviddeaths
--Where location like '%Nigeria%'
where continent is not null
group by continent
order by totaldeathcounts desc


---GLOBAL NUMBERS

select date, SUM(new_cases) ---total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolio..coviddeaths
where continent is null
group by date
order by 1,2

select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as deathpercentage
from portfolio..coviddeaths
where continent is not null
--group by date
order by 1,2



---covidvacination

select *

from portfolio..coviddeaths  dea
join portfolio..covidvacinations vac
    on dea.location = vac. location
	and dea.date = vac.date

---looking at population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio..coviddeaths  dea
join portfolio..covidvacinations vac
    on dea.location = vac. location
	and dea.date = vac.date	
where dea.continent is not null
order by 1,2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint )) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolio..coviddeaths  dea
join portfolio..covidvacinations vac
    on dea.location = vac. location
	and dea.date = vac.date	
where dea.continent is not null
order by 2,3



---USE CTE

with popvsvac ( continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolio..coviddeaths  dea
join portfolio..covidvacinations vac
    on dea.location = vac. location
	and dea.date = vac.date	
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


---TERM TABLES

DROP Table if exists #percentpopulationvaccinated 
create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolio..coviddeaths  dea
join portfolio..covidvacinations vac
    on dea.location = vac. location
	and dea.date = vac.date	
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


---creating view to store data for later visualization


USE Portfolio
GO
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolio..coviddeaths  dea
join portfolio..covidvacinations vac
    on dea.location = vac. location
	and dea.date = vac.date	
where dea.continent is not null
---order by 2,3




select *
from PercentPopulationVaccinated
