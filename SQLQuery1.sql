--Import both excel files
--View the tables
select * 
from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

select * 
from Portfolioproject..CovidVaccinations
where continent is not null
order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths
where continent is not null
Order by 1,2

---Total cases vs total deaths (India)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where location like '%india%'
order by 1,2

---Total cases vs population

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From Portfolioproject..CovidDeaths
where location like '%india%'
order by 1,2

----Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentofPopulationInfected
From Portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location, Population
order by PercentofPopulationInfected desc

----Countries with Highest Deaths

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location, Population
order by TotalDeathCount desc

----Death By cointinent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

----Global numbers

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From Portfolioproject..CovidDeaths
Where continent is not null
Group by date
order by 1, 2

---- Total Deaths Globally

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From Portfolioproject..CovidDeaths
Where continent is not null
order by 1, 2

----Join tables

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---Total populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as  RollingPeopleVaccinated
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---USE CTE
Drop

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3)

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercent
From PopvsVac

----Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as  RollingPeopleVaccinated
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercent
From PopvsVac


--Creating view to store data for later visualisation

Create view PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as  RollingPeopleVaccinated
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PopulationVaccinated
