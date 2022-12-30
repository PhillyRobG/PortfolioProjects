-- Cleaning Data using SQL
-- Nashville Housing Data

-- Standardize Date Format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM sqlprojectportfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM sqlprojectportfolio.dbo.NashvilleHousing

-- Populate Property Address Data

-- Find NULL values

SELECT *
FROM sqlprojectportfolio.dbo.NashvilleHousing
WHERE PropertyAddress is null

-- USE ParcelID to determine Property Address

SELECT *
FROM sqlprojectportfolio.dbo.NashvilleHousing
Order BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM sqlprojectportfolio.dbo.NashvilleHousing a
JOIN sqlprojectportfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sqlprojectportfolio.dbo.NashvilleHousing a
JOIN sqlprojectportfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sqlprojectportfolio.dbo.NashvilleHousing a
JOIN sqlprojectportfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM sqlprojectportfolio.dbo.NashvilleHousing a
JOIN sqlprojectportfolio.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-- Break Property Address into Individual Columns (Address, City)

SELECT PropertyAddress
FROM sqlprojectportfolio.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
FROM sqlprojectportfolio.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM sqlprojectportfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar (255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar (255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM sqlprojectportfolio.dbo.NashvilleHousing

-- Break Owner Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM sqlprojectportfolio.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM sqlprojectportfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar (255)

UPDATE NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar (255)

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar (255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM sqlprojectportfolio.dbo.NashvilleHousing

-- Change Y and N to Yes and No in SoldAsVacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM sqlprojectportfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END
FROM sqlprojectportfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM sqlprojectportfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Remove Duplicates

SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM sqlprojectportfolio.dbo.NashvilleHousing
ORDER BY ParcelID

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM sqlprojectportfolio.dbo.NashvilleHousing)

Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM sqlprojectportfolio.dbo.NashvilleHousing)

DELETE
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM sqlprojectportfolio.dbo.NashvilleHousing)

Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM sqlprojectportfolio.dbo.NashvilleHousing

ALTER TABLE sqlprojectportfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE sqlprojectportfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate, TaxDistrict

SELECT *
FROM sqlprojectportfolio.dbo.NashvilleHousing

-- Renamed Columns Using Object Explorer
