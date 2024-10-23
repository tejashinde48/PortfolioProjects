select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


select location,  date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- 1. Look for Total Cases vs Total Deaths 
	-- This show the likelihood if you come in contact of covid in your country 

select location,  date, total_cases, total_deaths, (total_deaths/total_cases)/0.01 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

-- 2. Look for Total Cases vs Population
	-- Shows what percentage of population got covid

select location,  date, total_cases, population, (total_deaths/population)*100 as Population_Total_Cases
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

-- 3. looking at countries with Highest Infection Rate compared to Populatin

select location,population ,max(total_cases) as Highestes_Infection_Count,  MAX((total_deaths/population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentofPopulationInfected desc

-- 4. looking at countries with Highest Death Count per Population

select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--  BREAK THINGS DOWN BY CONTINENT

select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--BREAK THINGS DOWN BY LOCATION

select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--	SHOWING THE CONTINENTS WITH THE DEATH COUNTS PER POPULATION

select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select  SUM(new_cases) as Totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int)) /sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
order by 2,3


With PopvsVac (Continent, Location, Date, Population, new_vaccinations,Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_Num
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
and dea.population is not null
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100 as Rolling_Num
from #PercentPopulationVaccinated


--Create View to store data

Create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
--order by 2,3


 select * 
  from PercentPopulationVaccinated