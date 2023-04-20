/*
DATA CLEANING IN SQL

Trevor Ali
*/


Select *
From PortfolioProject.dbo.Housing

--------------------------------------------------------------------------------------------------------------------------

-- STANDARDIZING DATE FORMATS
-- Problem: We have a DateTimeStamp for the SaleDate column which doesn't need time
-- Approach: Convert DateTimeStamp to a DateStamp then update

Alter table PortfolioProject..Housing
	Add SaleDateConv Date

update PortfolioProject..Housing
	set saleDateConv = convert(date,saledate)


 --------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA
-- Problem: We have some rows in the PropertyAddress column which are NULL, and PropertyAddresses should never be NULL
-- FIX: SELF_JOIN the table by ParcelID=ParcelID ad UiqueID<>UniqueID to identify the NULLs then ISNULL populate them with the corresponding Property address then update
-- WHY? 

Select *
From PortfolioProject..Housing
	Where PropertyAddress is null
	Order by ParcelID

--SELF-JOIN
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing a
	join PortfolioProject..Housing b
		on a.ParcelID = b.ParcelID and
		a.[UniqueID ] <> b.[UniqueID ]

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..Housing a
	join PortfolioProject..Housing b
		on a.ParcelID = b.ParcelID and
		a.[UniqueID ] <> b.[UniqueID ]


------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)
-- Problem: Address, City and State all in one column
-- FIX:
-- WHY? 

Select PropertyAddress
From PortfolioProject..Housing
-----------------------------------------------
--Breakout for PropertyAddress Using Substrings
Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address
From PortfolioProject..Housing

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) Address
From PortfolioProject..Housing


Alter Table PortfolioProject..Housing
	Add PropertySplitAddress nvarchar(255)
update PortfolioProject..Housing
	set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject..Housing
	Add PropertySplitCity nvarchar(255)
update PortfolioProject..Housing
	set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))

--CHECK
select * from PortfolioProject..Housing



-------------------------------------------
--Breakout For OwnersAddress Using PARESNAME
select 
	PARSENAME(replace(owneraddress, ',' , '.'), 3) as OwnerAddress2,
	PARSENAME(replace(owneraddress, ',' , '.'), 2) OwnerCity,
	PARSENAME(replace(owneraddress, ',' , '.'), 1) OwnerState

from PortfolioProject..Housing
where OwnerAddress is not null


ALTER Table PortfolioProject..Housing
Add OwnerAddress2 nvarchar(255), 
	OwnerCity nvarchar(255), 
	OwnerState nvarchar(255)

Update PortfolioProject..Housing
set	OwnerAddress2 = PARSENAME(replace(owneraddress, ',' , '.'), 3),
	OwnerCity = PARSENAME(replace(owneraddress, ',' , '.'), 2),
	OwnerState = PARSENAME(replace(owneraddress, ',' , '.'), 1)
	   	  


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(Soldasvacant), count(soldasvacant)
From PortfolioProject..Housing
group by SoldAsVacant
order by 2 desc

Select SoldAsVacant,
(Case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End) Corrected
From PortfolioProject..Housing

with cte_Case as (
Select SoldAsVacant,
(Case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End) as Corrected
From PortfolioProject..Housing)

select distinct(Corrected), count(Corrected)
from cte_Case
	group by Corrected

-- UPDATE
update PortfolioProject..Housing
set SoldAsVacant = Case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- LOOKING FOR DUPLICATES
With CTE_ROWNUM as 
(
Select *,
	ROW_NUMBER() over 
	(PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
					UniqueID) as Row_Num
From PortfolioProject..Housing
)
Select *
From CTE_ROWNUM 
Where Row_Num <> 1

-- REMOVING DUPLICATES

With CTE_ROWNUM as (
Select *,
	ROW_NUMBER() over 
	(PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) as Row_Num

From PortfolioProject..Housing
)
DELETE
From CTE_ROWNUM
where row_num <> 1


Select * 
From PortfolioProject..Housing
---------------------------------------------------------------------------------------------------------



Select [UniqueID ], ParcelID, OwnerName, OwnerAddress2, OwnerCity, OwnerState, PropertySplitAddress, PropertySplitCity, LandUse, 
		SoldAsVacant, SalePrice, SaleDate, LegalReference, LandValue, BuildingValue, TotalValue
From PortfolioProject..Housing


-- Temporarily saving the CLean Data as a VIEW with needed information for later analysis and visualization
Create View
CleanHousingTable as
Select [UniqueID ], ParcelID, OwnerName, OwnerAddress2, OwnerCity, OwnerState, PropertySplitAddress, PropertySplitCity, LandUse, 
		SoldAsVacant, SalePrice, SaleDate, LegalReference, LandValue, BuildingValue, TotalValue
From PortfolioProject..Housing

Select * From PortfolioProject..CleanHousingTable


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
