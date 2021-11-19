use PortfolioProject

Select * from coviddeaths
where continent is not null
order by 3,4

Select * from coviddeaths
where continent is null
order by 3,4

--Select * from covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

--Total cases vs total deaths
--shows likelyhood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathsPercentage
from coviddeaths
where location like '%states%'
order by 1,2


--Looking at total cases vs population
select location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
from coviddeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)) * 100 as 
PercentPopulationInfected
from coviddeaths
--where location like '%states%'
where continent is not null
Group By  location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
select location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
--where location like '%states%'
where continent is not null
Group By  location
order by TotalDeathCount desc

--Lets break things by continent

--showing continents with the highest death count per population

select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths
--where location like '%states%'
where continent is not null
Group By  continent
order by TotalDeathCount desc


--Global Numbers
select  date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(Sum(new_deaths)/Sum(new_cases)) * 100 as deathpercentage
from coviddeaths
where continent is not null
group by date
order by 1,2

select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(Sum(new_deaths)/Sum(new_cases)) * 100 as deathpercentage
from coviddeaths
where continent is not null
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac(Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population) * 100 
from PopvsVac
order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric NULL,
New_vaccinations numeric null,
RollingPeopleVaccinated float NULL
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated
