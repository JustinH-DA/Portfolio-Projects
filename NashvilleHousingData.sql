--Cleaning Data for Nashville Housing Queries

Select *
From PortfolioProject.dbo.NashvilleHousingData

--Standardize Data Format

Select SaleDateConverted, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousingData


Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousingData
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
Join PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
Join PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousingData



ALTER TABLE NashvilleHousingData
Add PropertySplitAddress NVarChar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousingData
Add PropertySplitCity NVarChar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousingData


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingData




ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress NVarChar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity NVarChar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState NVarChar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--Change Y and N to Yes and No in "Solad as Vacant" Field 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group By SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END




-- Remove Dupluicates

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

From PortfolioProject.dbo.NashvilleHousingData
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


--Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousingData

Alter Table PortfolioProject.dbo.NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousingData
Drop Column SaleDate