

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData



--Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [PortfolioProject].dbo.NashvilleHousingData


ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
ALTER COLUMN SaleDate DATE;


----CHECK PROPERTY ADDRESS and Populate

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL


SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--Separate Addrss from the City

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHousingData



ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
ADD  PropertyNewAddress nvarchar(255);

UPDATE [PortfolioProject].dbo.NashvilleHousingData
SET PropertyNewAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
ADD PropertyNewCity nvarchar(255);

UPDATE [PortfolioProject].dbo.NashvilleHousingData
SET PropertyNewCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




SELECT *
FROM [PortfolioProject].dbo.NashvilleHousingData


SELECT OwnerAddress
FROM [PortfolioProject].dbo.NashvilleHousingData


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [PortfolioProject].dbo.NashvilleHousingData



ALTER TABLE[PortfolioProject].dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update [PortfolioProject].dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update [PortfolioProject].dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update [PortfolioProject].dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [PortfolioProject].dbo.NashvilleHousingData




--Check an corret the "Soldasvacant" column

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From [PortfolioProject].dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2 


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From [PortfolioProject].dbo.NashvilleHousingData



Update [PortfolioProject].dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



---REMOVING DUPLICATES 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [PortfolioProject].dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [PortfolioProject].dbo.NashvilleHousingData
)
DELETE
From RowNumCTE
Where row_num > 1




Select *
From [PortfolioProject].dbo.NashvilleHousingData





--								Delete Unused Columns



--Select *
--From [PortfolioProject].dbo.NashvilleHousingData


--ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--ALTER TABLE [PortfolioProject].dbo.NashvilleHousingData
--DROP COLUMN PropertySplitAddress

