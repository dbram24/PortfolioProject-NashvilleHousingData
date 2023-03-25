--SKILLS DEMONSTRATED: ALTER TABLE, Self Joins, COALESCE, String Functions, CASE Statements, CTEs, Data Cleaning

-- Standardize Date Format

ALTER TABLE nashvillehousing
ALTER COLUMN saledate TYPE DATE USING saledate::DATE;

SELECT saledate FROM nashvillehousing
LIMIT 5;

-- Populate null Property Address data using the observation that locations with the same parcel ID are at the same address

SELECT *
FROM nashvillehousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT t1.UniqueID, t1.ParcelId, t1.PropertyAddress, t2.UniqueID, t2.ParcelID, t2.PropertyAddress--,COALESCE(t1.PropertyAddress,t2.PropertyAddress)
FROM nashvillehousing as t1
JOIN nashvillehousing as t2
ON t1.ParcelID = t2.ParcelID
AND t1.UniqueID != t2.UniqueID
--WHERE t1.PropertyAddress IS NULL;

UPDATE nashvillehousing AS t1
SET propertyaddress = COALESCE(t2.propertyaddress, t1.propertyaddress)
FROM nashvillehousing as t2
WHERE t1.parcelID = t2.parcelID AND t1.uniqueID != t2.uniqueID AND t1.propertyaddress IS NULL;

-- Separating address from city into separate columns for PropertyAddress column

SELECT propertyaddress
FROM nashvillehousing;

SELECT SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) AS address, SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1) AS city
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitAddress VARCHAR(250);
ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitCity VARCHAR(250);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1)
UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1)

SELECT propertyaddress, propertysplitaddress, propertysplitcity
FROM nashvillehousing;

-- Separating address, city, and state into separate columns for OwnerAddress column

SELECT OwnerAddress
FROM nashvillehousing;

SELECT
SPLIT_PART(OwnerAddress, ',', 1),
SPLIT_PART(OwnerAddress, ',', 2),
SPLIT_PART(OwnerAddress, ',', 3)
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitAddress VARCHAR(250);
ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitCity VARCHAR(250);
ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitState VARCHAR(250);

UPDATE nashvillehousing
SET OwnerSplitAddress = SPLIT_PART(OwnerAddress, ',', 1);
UPDATE nashvillehousing
SET OwnerSplitCity = SPLIT_PART(OwnerAddress, ',', 2);
UPDATE nashvillehousing
SET OwnerSplitState = SPLIT_PART(OwnerAddress, ',', 3);

SELECT owneraddress, ownersplitaddress, ownersplitcity, ownersplitstate FROM nashvillehousing
WHERE ownersplitaddress IS NOT NULL;

-- Drop redundant address columns
ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress;


-- Change Y and N to Yes and No in SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM nashvillehousing
WHERE soldasvacant in ('Y', 'N');

UPDATE nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END;
	
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;

-- Remove duplicate rows

SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_Num
FROM nashvillehousing
ORDER BY ParcelID;

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_Num
FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_Num
FROM nashvillehousing
)
DELETE
FROM nashvillehousing
WHERE UniqueId in (SELECT UniqueID FROM RowNumCTE WHERE Row_Num > 1);

-- Final Table

SELECT * FROM nashvillehousing;