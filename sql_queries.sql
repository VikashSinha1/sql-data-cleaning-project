/****** Script for SelectTopNRows command from SSMS  ******/
--- looking at the data
select * from [Nashville Housing Data]

---changing datetime into date datatype

select SaleDate
from [Nashville Housing Data]

select SaleDate,convert(time,SaleDate)as datetime
from [Nashville Housing Data]

alter table [Nashville Housing Data]
add saledate1 date

update [Nashville Housing Data]
set saledate1 = convert(time,SaleDate)

---populate property address

select *
from [Nashville Housing Data] where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress)
from [Nashville Housing Data] a
join [Nashville Housing Data] b on a.ParcelID=b.ParcelID 
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a set propertyaddress= isnull(a.propertyaddress,b.PropertyAddress)
from [Nashville Housing Data] a
join [Nashville Housing Data] b on a.ParcelID=b.ParcelID 
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

select *
from [Nashville Housing Data] where PropertyAddress is null
order by ParcelID

---seperating PROPERTY ADDRESS address into individual columns(address,city,state) using SUBSTRING AND CHARINDEX

select PropertyAddress 
from [Nashville Housing Data]

select 
SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)as address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(PropertyAddress))as address
from [Nashville Housing Data]

alter table [Nashville Housing Data]
add propertysplitaddress nvarchar(255)

alter table [Nashville Housing Data]
add propertysplitcity nvarchar(255)

update [Nashville Housing Data]
set propertysplitaddress=SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1)

update [Nashville Housing Data]
set propertysplitcity=SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,len(PropertyAddress))

select * from [Nashville Housing Data]

---seperating OWNER ADDRESS address into individual columns(address,city,state) using PARSENAME

SELECT OwnerAddress
FROM [Nashville Housing Data]

select
PARSENAME(replace(owneraddress,',','.'),3)as address, 
PARSENAME(replace(owneraddress,',','.'),2)as city,
PARSENAME(replace(owneraddress,',','.'),1)as state
from [Nashville Housing Data]

alter table [Nashville Housing Data]
add address varchar(255)

alter table [Nashville Housing Data]
add city varchar(255)

alter table [Nashville Housing Data]
add state varchar(255)

update [Nashville Housing Data]
set address=PARSENAME(replace(owneraddress,',','.'),3)

update [Nashville Housing Data]
set city=PARSENAME(replace(owneraddress,',','.'),2)

update [Nashville Housing Data]
set state=PARSENAME(replace(owneraddress,',','.'),1)

select * from [Nashville Housing Data]


---changing Y and N from sold as vacant column

select distinct(SoldAsVacant),COUNT(soldasvacant)
from [Nashville Housing Data]
group by SoldAsVacant

select *,
case when SoldAsVacant ='0' then 'No'
     else 'Yes'
	 end as 'Sold_As_Vacant'
from [Nashville Housing Data]

alter table [Nashville Housing Data]
add sold_as_vacant varchar(14)

update [Nashville Housing Data]
set sold_as_vacant=case when SoldAsVacant ='0' then 'No'
     else 'Yes'
	 end


select * from [Nashville Housing Data]


-----Remove Dublicates


with ROWNUM_CTE AS
(select *,
ROW_NUMBER() over(
    partition by parcelid,
	             landuse,
				 propertyaddress,
				 saledate,
				 saleprice,
				 ownername order by uniqueid
)as row_num
from [Nashville Housing Data])

select * 
from ROWNUM_CTE WHERE row_num>1
order by propertyaddress


with ROWNUM_CTE AS
(select *,
ROW_NUMBER() over(
    partition by parcelid,
	             landuse,
				 propertyaddress,
				 saledate,
				 saleprice,
				 ownername order by uniqueid
)as row_num
from [Nashville Housing Data])

delete
from ROWNUM_CTE WHERE row_num>1


---- delete unused columns

select * from [Nashville Housing Data]

alter table [Nashville Housing Data]
drop column propertyaddress,owneraddress,soldasvacant,taxdistrict
