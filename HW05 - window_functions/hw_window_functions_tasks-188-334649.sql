/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
set statistics time, io on
declare @startDate date = '2015-01-01'

select i.InvoiceId, CustomerName, InvoiceDate, 
(select sum(UnitPrice*Quantity) 
	from Sales.InvoiceLines il 
	where il.InvoiceID = i.InvoiceID 
	) as InvoiceSumm,
(select sum(UnitPrice*Quantity) 
	from Sales.InvoiceLines il 
	join Sales.Invoices inv on inv.InvoiceID = il.InvoiceID 
	and inv.InvoiceDate between DATEFROMPARTS(year(@startDate), month(@startDate), 1) and eomonth(DATEFROMPARTS(year(i.InvoiceDate), month(i.InvoiceDate), 1))
	) as RunningTotal
from Sales.Invoices i
join Sales.Customers c on c.CustomerID = i.CustomerID
where InvoiceDate >= @startDate
group by i.InvoiceId, CustomerName, InvoiceDate
order by InvoiceDate, CustomerName, i.InvoiceId
/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 16 мс, истекшее время = 52 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

(затронуто записей: 31440)
Таблица "InvoiceLines". Сканирований 888, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 502, физических операций чтения LOB 3, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 778, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 444, пропущено 0.
Таблица "Worktable". Сканирований 32326, логических операций чтения 230170, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Workfile". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 2, логических операций чтения 22800, физических операций чтения 3, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 11388, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 1, логических операций чтения 40, физических операций чтения 1, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 31, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 24484 мс, затраченное время = 24995 мс.
*/
/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

set statistics time, io on
declare @startDate date = '2015-01-01';
with SalesByMonthCTE as (
	select i.InvoiceId, CustomerName, InvoiceDate,
	sum(UnitPrice*Quantity) as InvoiceSumm
	from Sales.Invoices i
	join Sales.Customers c on c.CustomerID = i.CustomerID
	join Sales.InvoiceLines il on il.InvoiceID = i.Invoiceid
	where InvoiceDate >= @startDate
	group by i.InvoiceId, CustomerName, InvoiceDate
	)
select InvoiceId, CustomerName, InvoiceDate, InvoiceSumm,
	SUM(InvoiceSumm) OVER (ORDER BY YEAR(InvoiceDate), MONTH(InvoiceDate)
	RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RunningTotal
	from SalesByMonthCTE
	order by InvoiceDate, CustomerName, InvoiceId
/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 31 мс, истекшее время = 62 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

(затронуто записей: 31440)
Таблица "InvoiceLines". Сканирований 2, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 341, физических операций чтения LOB 3, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 778, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 1, логических операций чтения 11400, физических операций чтения 3, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 11388, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 1, логических операций чтения 40, физических операций чтения 1, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 31, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 172 мс, затраченное время = 763 мс.
*/
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

with QtyCTE as (
select StockItemName, MONTH(InvoiceDate) as SalesMonth, 
sum(Quantity) as Qty
from Sales.InvoiceLines il
join Sales.Invoices i on i.InvoiceID = il.InvoiceID
join Warehouse.StockItems s on s.StockItemID = il.StockItemID 
where InvoiceDate between '2016-01-01' and '2016-12-31'
group by MONTH(InvoiceDate), StockItemName
)
select * from(
	select StockItemName, SalesMonth, Qty, 
	ROW_NUMBER() OVER (PARTITION BY SalesMonth ORDER BY Qty desc) as rn
	from QtyCTE) as tbl
	where rn <= 2
	order by SalesMonth, Qty desc, StockItemName 

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
select 
ROW_NUMBER() OVER (PARTITION BY left(StockItemName, 1) ORDER BY StockItemName) as Rn,
StockItemName, StockItemID, Brand, UnitPrice,
COUNT(StockItemId) OVER () as ItemCount,
COUNT(StockItemId) OVER (PARTITION BY left(StockItemName, 1) ORDER BY StockItemName
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ItemCountByLetter,
LEAD(StockItemId) OVER (PARTITION BY left(StockItemName, 1) ORDER BY StockItemName) as LeadItemId,
LAG(StockItemId) OVER (PARTITION BY left(StockItemName, 1) ORDER BY StockItemName) as LagItemId,
LAG(StockItemName, 2, 'No items') OVER (PARTITION BY left(StockItemName, 1) ORDER BY StockItemName) as LagItemName,
NTILE(30) OVER (ORDER BY TypicalWeightPerUnit) as GroupId
from Warehouse.StockItems s
order by StockItemName

select 
StockItemName, StockItemID, Brand, UnitPrice,TypicalWeightPerUnit,
NTILE(30) OVER (ORDER BY TypicalWeightPerUnit) as GroupId
from Warehouse.StockItems s
order by GroupId

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

with salesCTE as (
select PersonID, p.FullName as PersonName, c.CustomerID, c.CustomerName, i.InvoiceDate, sum(UnitPrice*Quantity) as InvoiceSumm
from Sales.Invoices i
join Application.People p on p.PersonID = i.SalespersonPersonID
join Sales.Customers c on c.CustomerID = i.CustomerID
join Sales.InvoiceLines il on il.InvoiceID = i.Invoiceid
group by PersonID, p.FullName, c.CustomerID, c.CustomerName, i.InvoiceDate, i.InvoiceID
)
select * from(
	select PersonID, PersonName, CustomerID, CustomerName, InvoiceDate, InvoiceSumm,
	ROW_NUMBER() OVER (PARTITION BY PersonID ORDER BY InvoiceDate desc) as rn
	from salesCTE as Rn
	) as tbl
	where rn = 1
	order by PersonID
/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
with expItemsCTE as (
	select c.CustomerID, CustomerName, StockItemID, max(UnitPrice) as Price, max(InvoiceDate) as SalesDate
	from Sales.InvoiceLines il 
	join Sales.Invoices i on i.Invoiceid = il.InvoiceID
	join Sales.Customers c on c.CustomerID = i.CustomerID
	group by c.CustomerID, CustomerName, StockItemID
)
select * from(
	select CustomerID, CustomerName, StockItemID, Price, SalesDate,
	DENSE_RANK() OVER (PARTITION BY CustomerId ORDER BY Price desc, StockItemID) as rn
	from expItemsCTE
	) as tbl
	where rn <= 2
	order by CustomerID, rn, StockItemID

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 