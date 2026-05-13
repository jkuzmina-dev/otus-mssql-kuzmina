/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select year(InvoiceDate) as Year,
month(InvoiceDate) as Month,
avg(UnitPrice) as AvgPrice, 
sum(ExtendedPrice) as SumAmount
from Sales.Invoices i
join Sales.InvoiceLines l on l.InvoiceID = i.InvoiceID
group by year(InvoiceDate), month(InvoiceDate)
order by Year, Month

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(InvoiceDate) as Year,
month(InvoiceDate) as Month,
sum(ExtendedPrice) as SumAmount
from Sales.Invoices i
join Sales.InvoiceLines l on l.InvoiceID = i.InvoiceID
group by year(InvoiceDate), month(InvoiceDate)
having sum(ExtendedPrice) > 4600000
order by Year, Month

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(InvoiceDate) as Year,
month(InvoiceDate) as Month,
StockItemName,
sum(ExtendedPrice) as SumAmount,
min(InvoiceDate) as FirstInvoiceDate,
sum(Quantity) as Quantity
from Sales.Invoices i
join Sales.InvoiceLines l on l.InvoiceID = i.InvoiceID
join Warehouse.StockItems si on si.StockItemID = l.StockItemID
group by year(InvoiceDate), month(InvoiceDate), StockItemName
having sum(Quantity) < 50
order by Year, Month, StockItemName

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
use master;
CREATE TABLE tbl_Calendar (
    ID INT IDENTITY,
    [Date] DATE,
    [Day] INT,
    [Month] INT,
    [Year] INT
);

DECLARE @SetStartDate DATE, @Start INT, @Stop INT, @Step INT;
SET @SetStartDate = '2013-01-01'; -- Начальная дата календаря
SET @Start = 0;
SET @Stop = 365*4; -- Количество дней (4 года);
SET @Step = 1;

INSERT INTO tbl_Calendar (
    [Date],
    [Day],
    [Month],
    [Year]
)
SELECT DATEADD(DAY, value, @SetStartDate) AS [Date],
       DATEPART(DAY, DATEADD(DAY, value, @SetStartDate)) AS [Day],
       MONTH(DATEADD(DAY, value, @SetStartDate)) AS [Month],
       YEAR(DATEADD(DAY, value, @SetStartDate)) AS [Year]
FROM GENERATE_SERIES(@Start, @Stop, @Step);

use WideWorldImporters;
select c.Year,
c.Month,
case when sum(ExtendedPrice) > 4600000 then sum(ExtendedPrice)
else 0 end as SumAmount
from master.dbo.tbl_Calendar c
left join Sales.Invoices i on c.Date = i.InvoiceDate
left join Sales.InvoiceLines l on l.InvoiceID = i.InvoiceID
group by Year, Month
order by Year, Month


