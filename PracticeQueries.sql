-- Cleaning Data in SQL Queries

Select * 
FROM NashvilleHousing
order by 1


-- Standardize Date Format



/* UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, Saledate)*/

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)

Select SaleDateConverted
FROM NashvilleHousing

-- Populate Property Address data

Select *
FROM Practice.dbo.NashvilleHousing
order by ParcelID

SELECT a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Practice.dbo.NashvilleHousing a
JOIN Practice.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
   WHERE a.PropertyAddress is NULL

   UPDATE a
   SET a.propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
   FROM Practice.dbo.NashvilleHousing a
	JOIN Practice.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
    WHERE a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Practice.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Practice.dbo.NashvilleHousing

ALTER TABLE Practice.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE Practice.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Practice.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE Practice.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




SELECT 
OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as State
FROM Practice.dbo.NashvilleHousing

ALTER TABLE Practice.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE Practice.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Practice.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE Practice.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE Practice.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE Practice.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Testing if worked 
SELECT *
FROM Practice.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Practice.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM Practice.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

-- Renive Duplicates

WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID 
			 ) row_num
FROM Practice.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------
--               Delete Unused Columns
--------------------------------------------------------------------------

SELECT *
FROM Practice.dbo.NashvilleHousing

ALTER TABLE Practice.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE Practice.dbo.NashvilleHousing
DROP COLUMN SaleDate