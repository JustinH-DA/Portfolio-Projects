--select *
--From PortfolioProject..['Covid Deaths]
--order by 3,4

--select *
--From PortfolioProject..['Covid Vaccs]
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths]
Order by 1,2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases,total_deaths, CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)*100 AS DeathPercentage
From PortfolioProject..['Covid Deaths]
WHERE location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population 

SELECT location, date, total_cases, (total_cases/population)*100 AS DeathPercentage
From PortfolioProject..['Covid Deaths]
WHERE location like '%states%'
Order by 1,2

--Looking at countries with Highest Infection Rate compared to Populaton

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths]
WHERE location like '%states%'
Group by location, population
Order by PercentPopulationInfected 

--Showing Countries with highest deathcount per population

SELECT Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..['Covid Deaths]
--WHERE location like '%states%'
Group by location 
Order by TotalDeathCount desc


--GLOBAL Numbers


SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths]
--WHERE location like '%states%'
WHERE location is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccination 

Select dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORder by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths] dea
Join PortfolioProject..['Covid Vaccs] vac
	 on dea.location = vac.location
	and dea.date = vac.date
 WHERE dea.location is not null
 Order by 1, 2


 --USE CTE

 With PopvsVAC (location, date, population, New_vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORder by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths] dea
Join PortfolioProject..['Covid Vaccs] vac
	 on dea.location = vac.location
	and dea.date = vac.date
 WHERE dea.location is not null
 --Order by 1, 2
 )
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVAC

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Location nvarchar(255),
Data datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORder by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths] dea
Join PortfolioProject..['Covid Vaccs] vac
	 on dea.location = vac.location
	and dea.date = vac.date
 WHERE dea.location is not null
 --Order by 1, 2

 Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations
--DROP VIEW if exists PercentPopulationVaccinated 
Create View PercentPopulationVaccinated as 
Select dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORder by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths] dea
Join PortfolioProject..['Covid Vaccs] vac
	 on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location is not null
 --Order by 1, 2

 Select * 
 From PercentPopulationVaccinated
