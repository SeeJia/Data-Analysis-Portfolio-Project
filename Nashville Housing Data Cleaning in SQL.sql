--Display All The Data

SELECT * FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


--------------------------------------------------------------------------------------------------------------


--Populate Property Address Data

SELECT * FROM NashvilleHousing
ORDER BY ParcelID


SELECT 
    tableID1.ParcelID, 
    tableID1.PropertyAddress, 
    tableID2.ParcelID, 
    tableID2.PropertyAddress, 
    ISNULL(tableID1.PropertyAddress, tableID2.PropertyAddress) 
FROM NashvilleHousing AS tableID1
JOIN NashvilleHousing AS tableID2
ON tableID1.ParcelID = tableID2.ParcelID
AND tableID1.UniqueID <> tableID2.UniqueID
WHERE tableID1.PropertyAddress IS NULL

UPDATE tableID1
SET PropertyAddress = ISNULL(tableID1.PropertyAddress, tableID2.PropertyAddress) 
FROM NashvilleHousing AS tableID1
JOIN NashvilleHousing AS tableID2
ON tableID1.ParcelID = tableID2.ParcelID
AND tableID1.UniqueID <> tableID2.UniqueID
WHERE tableID1.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress FROM NashvilleHousing
-- ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD 
PropertySplitAddress NVARCHAR(255), 
PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1), 
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD
OwnerSplitAddress NVARCHAR(255),
OwnerSplitCity NVARCHAR(255),
OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM NashvilleHousing

SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant


--------------------------------------------------------------------------------------------------------------


--Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY 
            ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
        ORDER BY
            UniqueID 
    ) row_num
FROM NashvilleHousing
-- ORDER BY ParcelID
)
-- DELETE 
-- FROM RowNumCTE
-- WHERE row_num > 1
SELECT * FROM 
RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate