/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select PersonID, FullName
from Application.People p
where p.IsSalesperson = 1 and
not exists (
	select SalespersonPersonID
		from Sales.Invoices i
		where i.SalespersonPersonID = p.PersonID and InvoiceDate = '2015-07-04'
	)

with salesCTE as (
	select SalespersonPersonID, count(InvoiceId) as SalesCount
		from Sales.Invoices i
		where InvoiceDate = '2015-07-04'
		group by SalespersonPersonID
		)
select PersonID, FullName
from Application.People p
where p.IsSalesperson = 1 and 
not exists (
	select SalespersonPersonID 
	from salesCTE
	where salesCTE.SalespersonPersonID = p.PersonID
	)

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select StockItemId, StockItemName, UnitPrice
from Warehouse.StockItems i
where UnitPrice = (select min(UnitPrice) from Warehouse.StockItems)

select StockItemId, StockItemName, UnitPrice
from Warehouse.StockItems i
where UnitPrice <=ALL (select min(UnitPrice) from Warehouse.StockItems)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select CustomerID, CustomerName
from Sales.Customers
where CustomerId in (
	select top 5 CustomerId
		from Sales.CustomerTransactions
		where TransactionTypeID = 3
		order by TransactionAmount
		)

with transCTE as (
	select top 5 CustomerId
		from Sales.CustomerTransactions
		where TransactionTypeID = 3
		order by TransactionAmount
		)
select distinct c.CustomerID, CustomerName
from Sales.Customers c
join transCTE t on t.CustomerID = c.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/



select distinct city.CityID, city.CityName, p.FullName
from Sales.Invoices i
join Sales.Customers c on c.CustomerID = i.CustomerID
join Application.Cities city on city.CityID = c.DeliveryCityID
join Application.People p on p.PersonID = i.PackedByPersonID
join Sales.InvoiceLines l on l.InvoiceID = i.InvoiceID 
where l.StockItemID in (select top 3 StockItemId
	from Warehouse.StockItems i
	order by UnitPrice desc)

with expensiveItemsCTE as (
	select top 3 StockItemId, StockItemName, UnitPrice
	from Warehouse.StockItems i
	order by UnitPrice desc
	)
select distinct city.CityID, city.CityName, p.FullName
from Sales.Invoices i
join Sales.Customers c on c.CustomerID = i.CustomerID
join Application.Cities city on city.CityID = c.DeliveryCityID
join Application.People p on p.PersonID = i.PackedByPersonID
join Sales.InvoiceLines l on l.InvoiceID = i.InvoiceID 
join expensiveItemsCTE e on e.StockItemID = l.StockItemID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

--Вывести номер и дату накладной, имя сотрудника,
--общую сумму по строкам накладной для тех накладных, для которых эта сумма больше 27000
--сумму по скомплектованным строкам заказов, у которых указано Время комплектации
--упорядочить по убыванию общей суммы накладной
SET STATISTICS IO, TIME ON
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
--Для оптимизации и улучшения читабельности запроса можно использовать CTE, можно убрать подзапрос по сотрудникам
SET STATISTICS IO, TIME ON
;with salesTotalsPickedCTE as (
	SELECT l.OrderID as OrderId, SUM(l.PickedQuantity*l.UnitPrice) as TotalSummForPickedItems
		FROM Sales.OrderLines l
		where exists (
		select 1 
		from Sales.Orders o 
		where o.OrderID = l.OrderID and o.PickingCompletedWhen is not null)
		GROUP BY l.OrderId
		)
, salesTotalCTE as (
	SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
)
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	salesTotalCTE.TotalSumm,
	salesTotalsPickedCTE.TotalSummForPickedItems
	FROM Sales.Invoices 
	JOIN salesTotalCTE on salesTotalCTE.InvoiceId = Invoices.InvoiceID
	JOIN salesTotalsPickedCTE on salesTotalsPickedCTE.OrderId = Invoices.OrderID
	JOIN Application.People on People.PersonID = Invoices.SalespersonPersonID
	ORDER BY TotalSumm DESC
