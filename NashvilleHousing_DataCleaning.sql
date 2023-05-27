/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM [Portfolio Project].dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


--SELECT SaleDate ,cast(SaleDate as date)
--FROM [Portfolio Project].dbo.NashvilleHousing


--Update NashvilleHousing
--Set SaleDate=CONVERT(Date,SaleDate)


Select saleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project].dbo.NashvilleHousing


-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--self join tables to get propertyaddress value for null columns

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress 
FROM [Portfolio Project].dbo.NashvilleHousing a
join
[Portfolio Project].dbo.NashvilleHousing b
on
a.ParcelID=b.ParcelID 
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--get null value in propertaddress 'a' with property address of 'b'

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
join
[Portfolio Project].dbo.NashvilleHousing b
on
a.ParcelID=b.ParcelID 
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--update table
Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join
[Portfolio Project].dbo.NashvilleHousing b
on
a.ParcelID=b.ParcelID 
AND
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM [Portfolio Project].dbo.NashvilleHousing


SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


Select *
From [Portfolio Project].dbo.NashvilleHousing

---Performing similar properties on column OwnerAddress using PARSENAME INSTEAD OF SUBSTRING

Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing


Select OwnerAddress,PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Select *
--From [Portfolio Project].dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
   when SoldAsVacant='N' Then 'No'
   Else SoldAsVacant
END
From [Portfolio Project].dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =
 CASE when SoldAsVacant = 'Y' Then 'Yes'
   when SoldAsVacant='N' Then 'No'
   Else SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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

From [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)
--Select *
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


Select *
From [Portfolio Project].dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO














