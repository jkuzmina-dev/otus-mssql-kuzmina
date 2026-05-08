/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
select StockItemID, StockItemName 
from Warehouse.StockItems i
where StockItemName like '%urgent%' or StockItemName like 'Animal%'


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierID, SupplierName from Purchasing.Suppliers s
left join Purchasing.PurchaseOrders p on p.SupplierID = s.SupplierID
where p.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
select distinct OrderDate, o.OrderId, 
FORMAT(OrderDate, 'dd.MM.yyyy', 'ru-ru') as OrderDateFormatted,
datename(month, OrderDate) as OrderMonth,
datepart(quarter, OrderDate) as OrderQuarter,
case 
when datepart(MONTH, OrderDate) in ('1', '2', '3', '4') then 1
when datepart(MONTH, OrderDate) in ('5', '6', '7', '8') then 1
else 3
end as YearThird,
CustomerName
from Sales.Orders o
join Sales.Customers c on c.CustomerID = o.CustomerID
join Sales.OrderLines l on l.OrderID = o.OrderID and (l.UnitPrice > 100 or l.Quantity > 20) and o.PickingCompletedWhen <> ''
order by OrderQuarter, YearThird, OrderDate
offset 1000 rows 
fetch next 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select DeliveryMethodName, ExpectedDeliveryDate, SupplierName, FullName
from Purchasing.PurchaseOrders o
join Purchasing.Suppliers s on s.SupplierID = o.SupplierID 
join Application.DeliveryMethods m on m.DeliveryMethodID = o.DeliveryMethodID
join Application.People p on p.PersonID = o.ContactPersonID
where o.ExpectedDeliveryDate between '2013-12-01' and '2013-12-31' and m.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight') or o.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 CustomerName, FullName
from Sales.Orders o
join Sales.Customers c on c.CustomerID = o.CustomerID
join Application.People p on p.PersonID = o.SalespersonPersonID
order by OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/
select distinct CustomerName, PhoneNumber
from Sales.Customers c
join Sales.Orders o on o.CustomerID = c.CustomerId
join Sales.OrderLines l on l.OrderID = o.OrderID  
join Warehouse.StockItems i on i.StockItemID = l.StockItemID and i.StockItemName = 'Chocolate frogs 250g'
