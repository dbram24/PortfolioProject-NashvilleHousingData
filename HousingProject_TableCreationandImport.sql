CREATE TABLE NashvilleHousing(
	UniqueID INTEGER PRIMARY KEY,
	ParcelID VARCHAR(50),
	LandUse VARCHAR(100),
	PropertyAddress VARCHAR(250),
	SaleDate VARCHAR(100),
	SalePrice INTEGER,
	LegalReference VARCHAR(250),
	SoldAsVacant VARCHAR(5),
	OwnerName VARCHAR(250),
	OwnerAddress VARCHAR(250),
	Acreage REAL,
	TaxDistrict VARCHAR(250),
	LandValue INTEGER,
	BuildingValue INTEGER,
	TotalValue INTEGER,
	YearBuilt VARCHAR(10),
	Bedrooms INTEGER,
	FullBath INTEGER,
	HalfBath INTEGER
);

--Error importing data from CSV. A value in SalePrice column is listed as "120,000" instead of 120000. Will cleanup in SQL rather than excel.

ALTER TABLE nashvillehousing
ALTER COLUMN SalePrice TYPE VARCHAR(50);

SELECT * FROM nashvillehousing;