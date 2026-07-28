/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
GO;
CREATE OR ALTER FUNCTION dbo.fGetCustomerMaxSum()
RETURNS int
AS
    BEGIN
        DECLARE @Result int;
        SELECT @Result = 
        (select top 1 CustomerID
        from Sales.Invoices as i
        join Sales.InvoiceLines as l on l.InvoiceID = i.InvoiceID
        group by CustomerID
        order by SUM(Quantity*UnitPrice) desc)
        RETURN @Result;
    END;
GO

select dbo.fGetCustomerMaxSum() as CustomerID;
GO;
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE OR ALTER PROCEDURE dbo.uspCustTotalAmount
    @CustomerID int,
    @TotalSumm decimal(18,2) OUT
AS 
    BEGIN
    SET NOCOUNT ON;
    SELECT @TotalSumm = SUM(Quantity*UnitPrice)
    from Sales.Invoices as i
    join Sales.InvoiceLines as l on l.InvoiceID = i.InvoiceID
    where i.CustomerID = @CustomerID
    END;
GO

DECLARE @CustomerID int = 1
DECLARE @totalSumm decimal(18,2);

EXEC dbo.uspCustTotalAmount
    @CustomerID,
    @TotalSumm = @totalSumm OUTPUT;

SELECT @CustomerID as CustomerID, @totalSumm as TotalSumm;
GO
/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--функция
CREATE OR ALTER FUNCTION dbo.fTest()
RETURNS TABLE
AS
	RETURN
	SELECT o.OrderID,
        o.OrderDate,
        o.CustomerID,
        o.SalespersonPersonID,

        l.OrderLineID,
        l.StockItemID,
        l.Description,
        l.Quantity,

        p.PersonID,
        p.FullName,
        p.EmailAddress FROM Sales.Orders o
	JOIN Sales.OrderLines l on l.OrderID = o.OrderID
	JOIN Application.People p on p.PersonID = o.SalespersonPersonID
	WHERE MONTH(OrderDate) = 1 AND Description LIKE '%Gu%' AND EmailAddress LIKE '%h%'
GO

--ХП
CREATE OR ALTER PROCEDURE dbo.uspTest
AS 
    BEGIN
    SET NOCOUNT ON;
	SELECT o.OrderID,
        o.OrderDate,
        o.CustomerID,
        o.SalespersonPersonID,

        l.OrderLineID,
        l.StockItemID,
        l.Description,
        l.Quantity,

        p.PersonID,
        p.FullName,
        p.EmailAddress FROM Sales.Orders o
	JOIN Sales.OrderLines l on l.OrderID = o.OrderID
	JOIN Application.People p on p.PersonID = o.SalespersonPersonID
	WHERE MONTH(OrderDate) = 1 AND Description LIKE '%Gu%' AND EmailAddress LIKE '%h%'
    END;
GO
--вызов функции и ХП
SET STATISTICS TIME ON;
EXEC dbo.uspTest

SELECT *
FROM dbo.fTest();
GO
--Хоть я пыталась написать неоптимальный запрос, на небольшом объеме данных разницы между функцией и ХП не видно
--Предполагается, что на больших выборках ХП работает быстрее, чем функция, т.к. для нее происходит кэширование плана запроса
/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
--функция выводит все накладные по клиенту
CREATE OR ALTER FUNCTION dbo.fGetCustomerInvoices(@CustomerID int)
RETURNS TABLE
AS
    RETURN 
    SELECT InvoiceId, InvoiceDate
    FROM Sales.Invoices i
    WHERE i.CustomerID = @CustomerID
GO

SELECT CustomerID, CustomerName, i.InvoiceID, i.InvoiceDate
    from Sales.Customers c
    CROSS APPLY dbo.fGetCustomerInvoices(c.CustomerID) i
    order by CustomerID, i.InvoiceID

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
--Предполагаю, что можно использовать Read committed, т.к. все функции и процедуры используются вероятно для какой-то отчетности.
--Слишком строгая согласованнность данных не требуется, нужна хорошая скорость чтения данных.
