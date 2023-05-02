SELECT * FROM [Portfolio Project]..CovidDeaths
where location like '%states%'
ALTER table [dbo].[CovidDeaths]
ALTER column total_deaths BIGINT
ALTER table [dbo].[CovidDeaths]
ALTER column total_cases BIGINT

SELECT * FROM [Portfolio Project]..CovidVaccinations
ALTER table [dbo].[CovidVaccinations]
ALTER column new_vaccinations BIGINT

SELECT * FROM [Portfolio Project]..CovidDeaths
ALTER table [dbo].[CovidDeaths]
ALTER column total_deaths FLOAT


SELECT location,date, total_cases, total_deaths, new_cases, population
FROM [Portfolio Project]..CovidDeaths
order by 1,2

-- Shows Likelihood of death if contracting covid in United States
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at total cases vs. population
--What percentage of population got Covid
SELECT location, population, MAX(total_cases) as HighestInfectedCount,  MAX(cast(total_cases/population as int))*100 as InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location,population
order by InfectedPercentage desc

--Break-down by Continent

--Countries with highest Death Count 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by continent
order by TotalDeathCount desc

--Global Numbers

SELECT date, SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(nullif(cast(new_cases as int),0))*100 as DeathPercentage 
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2


--Total Vaccination vs Population
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


	Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	and new_vaccinations > 0 
	order by 2,3 
	
	Select * ,(RollingPeopleVaccinated/population)*100
	From #PercentPopulationVaccinated





	--Creating View to Store Data for Later Visualizations

	Create View PercentPopulationVaccinated as 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	and new_vaccinations > 0 
	--order by 2,3 

	Create View TotalCasesbyPopulation as
	SELECT location, population, MAX(total_cases) as HighestInfectedCount,  MAX(cast(total_cases/population as int))*100 as InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
Group by location,population

Create View LikelihoodofFatality as
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths

Select * 
FROM TotalCasesbyPopulation



