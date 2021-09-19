SELECT *
FROM Projects..covidDeath
ORDER BY 3,4


SELECT *
FROM Projects..covidVaccination
ORDER BY 3,4

-- SELECT THE DATA WE ARE GOING TO USE--

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Projects..covidDeath
where continent is not null
ORDER BY 1,2

-- Total cases vs Total Death--
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Projects..covidDeath
WHERE location like '%India%'
ORDER BY 1,2 desc

-- Total cases vs Population
SELECT Location, date,population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM Projects..covidDeath
where continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

-- Countries with heighest infection rate
SELECT Location, population, MAX(total_cases) AS HeighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Projects..covidDeath
where continent is not null
GROUP BY location, population
ORDER BY 4 desc

-- Countries with heighest death rate
SELECT Location, 
MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM Projects..covidDeath
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- REMOVING NULL VALUES WILL FILTER THE CONTINENT DATA 
SELECT * 
FROM Projects..covidDeath
WHERE continent IS NOT NULL
ORDER BY continent

-- Continent with Heighest Death Rate

SELECT continent, 
MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM Projects..covidDeath
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--select * from Projects..covidDeath where continent is not null

--select location, date, new_cases, icu_patients, total_deaths
--from Projects..covidDeath
--where continent is not null
--order by 4 desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Projects..covidDeath
where continent is null
group by location
order by TotalDeathCount desc

-- continents with heighest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Projects..covidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

--- Global Numbers New cases

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/ sum(new_cases) *100 as DeathPercentage
from Projects..covidDeath
where continent is not null 
order by 1,2

-----
select date,
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_death,
sum(cast(new_deaths as int))/ sum(new_cases)* 100 as DeathPercentage
from Projects..covidDeath
where continent is not null
group by date
order by 1,2 desc

----- Covid Vaccination

select * 
from Projects..covidDeath dea
join Projects..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

--- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, 
dea.population,
vac.new_vaccinations
from Projects..covidDeath as dea
join Projects..covidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

----
select dea.continent, dea.location, dea.date, 
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over(partition by dea.Location order by dea.Location, dea.date)
from Projects..covidDeath dea
join Projects..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--- USE CTE
WITH PopVsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVaccinated
FROM Projects..covidDeath dea
join Projects..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *
FROM PopVsVac

-- Temp table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVacinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVacinated
SELECT dea.continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVaccinated
FROM Projects..covidDeath dea
join Projects..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVacinated

-- Create View for later Data visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVaccinated
FROM Projects..covidDeath dea
join Projects..covidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

