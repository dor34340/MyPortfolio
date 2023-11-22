/*

Cleaning Data in SQL Queries

*/
select *
FROM [master].[dbo].[NashvilleHousing]

select [SaleDate], CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

select *
from NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date
UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------
-- Populate Property Address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL ( a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND 
a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL ( a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND 
	a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select *
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)
UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)
UPDATE NashvilleHousing 
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



select *
from NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)
UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'NO'
	 ELSE SoldAsVacant
	 END
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'NO'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates
WITH RowNumCTE AS (
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

From NashvilleHousing
--order by ParcelID
)
select * from NashvilleHousing
SELECT *
FROM RowNumCTE
where row_num > 1
order by PropertyAddres

DELETE
From RowNumCTE
WHERE row_num > 1

select *
from NashvilleHousing


-- Delete Unused Columns
Alter Table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
Alter Table NashvilleHousing
DROP COLUMN SaleDate
