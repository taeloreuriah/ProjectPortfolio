--Data Cleaning


Select * 
FROM [Portfolio Project]..NashvilleHousingData

--Standardize Date Format

Select SaleDateConverted, convert (Date,SaleDate)
FROM [Portfolio Project]..NashvilleHousingData


UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data

Select *
from [Portfolio Project]..NashvilleHousingData
--WHERE PropertyAddress is null 
ORDER BY ParcelId


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousingData a
JOIN [Portfolio Project]..NashvilleHousingData b
on a.ParcelId = b.ParcelId
AND a.[UniqueID] <> b.[uniqueid]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousingData a
JOIN [Portfolio Project]..NashvilleHousingData b
on a.ParcelId = b.ParcelId
AND a.[UniqueID] <> b.[uniqueid]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns 


Select PropertyAddress
from [Portfolio Project]..NashvilleHousingData
--WHERE PropertyAddress is null 
--ORDER BY ParcelId

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)) as Address
FROM [Portfolio Project]..NashvilleHousingData

--to eliminate comma

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) as Address
FROM [Portfolio Project]..NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE NashvilleHousingData
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress), LEN(PropertyAddress))

SELECT * 
From NashvilleHousingData

SELECT OwnerAddress
From NashvilleHousingData


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousingData
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
From NashvilleHousingData


--Change Y and N to Yes and No in 'Sold as Vacant' field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousingData
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From NashvilleHousingData


Update NashvilleHousingData
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


--Remove Duplicates

With RowNumCTE AS(
Select *,
Row_number() OVER (
Partition by ParcelId,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by
			UniqueID
			) row_num


From NashvilleHousingData
--Order by ParcelID
)
SELECT *
From RowNumCTE
where row_num>1
--order by PropertyAddress


--Delete Unused Columns


Select * 
From NashvilleHousingData


Alter Table NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table NashvilleHousingData
Drop Column SaleDate
