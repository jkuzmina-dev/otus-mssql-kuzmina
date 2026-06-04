/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

with salesCTE as (
	select 
	REPLACE(REPLACE(CustomerName, N'Tailspin Toys (', ''), ')', '') as Customer,
	DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) as InvoiceMonth, 
	count(InvoiceID) as SalesCount
	from Sales.Invoices i
	join Sales.Customers c on c.CustomerID = i.CustomerID
	where CustomerName IN (N'Tailspin Toys (Head Office)', N'Tailspin Toys (Sylvanite, MT)', N'Tailspin Toys (Peeples Valley, AZ)', N'Tailspin Toys (Medicine Lodge, KS)', N'Tailspin Toys (Gasport, NY)', N'Tailspin Toys (Jessie, ND)')
	group by CustomerName, DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
)
select 
	p.InvoiceMonth,
	p.[Head Office],
	p.[Sylvanite, MT],
	p.[Peeples Valley, AZ],
	p.[Medicine Lodge, KS],
	p.[Gasport, NY],
	p.[Jessie, ND]
from salesCTE
PIVOT
(
	SUM(SalesCount)
	FOR Customer IN ([Head Office], [Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])
) as p
order by p.InvoiceMonth
/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

with addressCTE as (
	select CustomerName, [DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2]
	from Sales.Customers c
	where c.CustomerName like N'%Tailspin Toys%'
)
select 
	u.CustomerName,
	u.Address
from addressCTE
UNPIVOT
(
	Address FOR Value IN ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])
) as u

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
with codesCTE as (
	select CountryID, CountryName, [IsoAlpha3Code], [IsoNumericCode]
	from Application.Countries c
)

select 
	u.CountryID,
	u.CountryName,
	u.Code
from (
	select CountryID, CountryName, [IsoAlpha3Code], convert(nvarchar(3), [IsoNumericCode]) as [IsoNumericCode]
	from Application.Countries c
) as src
UNPIVOT 
(
	Code FOR Value IN ([IsoAlpha3Code], [IsoNumericCode])
) as u

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select 
	c.CustomerID, 
	c.CustomerName,
	p.StockItemID,
	p.UnitPrice,
	p.SalesDate
	from Sales.Customers as c 
CROSS APPLY 
(
	SELECT TOP (2) 
		StockItemID,
		UnitPrice,
		max(InvoiceDate) as SalesDate
	from Sales.Invoices i
	join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
	where i.CustomerID = c.CustomerID
	group by UnitPrice, StockItemID
	order by UnitPrice desc
) as p
order by CustomerID, UnitPrice desc