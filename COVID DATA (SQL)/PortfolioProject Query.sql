SELECT * 
FROM PortfolioProject.dbo.CovidDeath
WHERE continent is not NULL
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4


--Select Datato use

SELECT Location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeath
ORDER BY 1,2


--Total cases Versus Total Deaths(for Death percentage)

SELECT Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject.dbo.CovidDeath
WHERE location like 'Nigeria' AND continent is not NULL
ORDER BY 1,2



--Looking at Total Cases versus Population (Percentage that got covid)
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Population_Percentage_Infected
FROM PortfolioProject.dbo.CovidDeath
WHERE location like 'Nigeria'
ORDER BY 1,2



--Country with the highest infection rate
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria'
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC


--Countries with Mortality rate per Population
SELECT Location, MAX(CAST(total_deaths AS int)) AS MortalityRate
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria'
WHERE continent is not NULL
GROUP BY location
ORDER BY MortalityRate DESC





--Observing Based ON Continents 

SELECT location, MAX(CAST(total_deaths AS int)) AS MortalityRate
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria'
WHERE continent is NULL
GROUP BY location
ORDER BY MortalityRate DESC

SELECT continent, MAX(CAST(total_deaths AS int)) AS MortalityRate
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria'
WHERE continent is not NULL
GROUP BY continent
ORDER BY MortalityRate DESC


--For African Countries
SELECT location, MAX(CAST(total_deaths AS int)) AS MortalityRate
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria'
WHERE continent like 'Africa'
GROUP BY location
ORDER BY MortalityRate DESC


--Globally

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria' 
WHERE continent is not NULL
Group BY date
ORDER BY 1,2

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject.dbo.CovidDeath
--WHERE location like 'Nigeria' 
WHERE continent is not NULL
ORDER BY 1,2




--Adding Vaxx to the picture

SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4



SELECT * 
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date


	--Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vaxx.new_vaccinations,
SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativeVaxx
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using CTE to Explore vaxx

WITH PopvsVaxx (continent, location, date, population, new_vaccinations, CummulativeVaxx)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vaxx.new_vaccinations,
SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativeVaxx
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (CummulativeVaxx/population)*100
FROM PopvsVaxx


--Smothed and for Nigeria 

WITH PopvsVaxx (continent, location, date, population, new_vaccinations, CummulativeVaxx)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vaxx.new_vaccinations,
SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativeVaxx
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL AND dea.location like 'United States'
--ORDER BY 2,3
)
SELECT *, (CummulativeVaxx/population)*100 as Popultion_Vaccinated
FROM PopvsVaxx




--Using Temp Tables


DROP TABLE iF EXISTS #PercentPopulationVaxxed
Create Table #PercentPopulationVaxxed
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CummulativeVaxx numeric
)

INSERT INTO #PercentPopulationVaxxed
SELECT dea.continent, dea.location, dea.date, dea.population, vaxx.new_vaccinations,
SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativeVaxx
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date
WHERE dea.continent IS NOT NULL --AND new_vaccinations IS NOT NULL AND dea.location like 'Nigeria'
--ORDER BY 2,3

SELECT *, (CummulativeVaxx/Population)*100
FROM #PercentPopulationVaxxed


------------------------------------------------------------

DROP TABLE iF EXISTS #PercentPopulationVaxxedNG
Create Table #PercentPopulationVaxxedNG
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CummulativeVaxx numeric
)

INSERT INTO #PercentPopulationVaxxedNG
SELECT dea.continent, dea.location, dea.date, dea.population, vaxx.new_vaccinations,
SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativeVaxx
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL AND dea.location like 'Nigeria'
--ORDER BY 2,3

SELECT *, (CummulativeVaxx/Population)*100
FROM #PercentPopulationVaxxedNG





---FOR VIEWS AND VISUALISATION

CREATE VIEW PercentPopulationVaxxed AS
SELECT dea.continent, dea.location, dea.date, dea.population, vaxx.new_vaccinations,
SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativeVaxx
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccinations vaxx
	ON dea.location = vaxx.location
	AND dea.date = vaxx.date
WHERE dea.continent IS NOT NULL --AND new_vaccinations IS NOT NULL AND dea.location like 'Nigeria'
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaxxed