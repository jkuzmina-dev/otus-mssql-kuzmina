/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
INSERT INTO [Sales].[Customers]
           ([CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[PrimaryContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryPostalCode]
           ,[PostalAddressLine1]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     OUTPUT inserted.CustomerID
     VALUES
           (N'Ivan Ivanov',1,3,1001,3,19586,19586,'2026-06-12',0,0,0,7,'(8452) 124-567','(8452) 124-567','http://www.ivanIvanov.ru','Lenina St.5','123450','PO Box 1234','123450',1),
           (N'IP Antonov',1,3,1001,3,19586,19586,'2026-06-12',0,0,0,7,'(8452) 324-567','(8452) 324-567','http://www.antonov.ru','Lenina St.10','145678','PO Box 1456','145678',1),
           (N'Markiza',1,3,1001,3,19586,19586,'2026-06-12',0,0,0,7,'(8452) 456-900','(8452) 456-900','http://www.markiza.ru','Gornaya St.1','367890','PO Box 3678','367890',1),
           (N'OOO Pyaterochka',1,3,1001,3,19586,19586,'2026-06-12',0,0,0,7,'(8452) 999-434','(8452) 999-434','http://www.payterochka.ru','Sadovaya St.35','523456','PO Box 5234','523456',1),
           (N'Aybolit',1,3,1001,3,19586,19586,'2026-06-12',0,0,0,7,'(8452) 111-111','(8452) 111-111','http://www.aybolit.ru','Radischeva St.25','100001','PO Box 1000','100001',1);

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers WHERE CustomerID = 1069


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update Sales.Customers SET BillToCustomerID = CustomerID, AccountOpenedDate = '2026-06-13'
WHERE CustomerName = N'IP Antonov'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
--создаем новую таблицу [Sales].[CustomersNew]
CREATE TABLE [Sales].[CustomersNew](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL)

INSERT INTO [Sales].[CustomersNew]
           ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     SELECT 
           [CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
           FROM [Sales].[Customers]
--вставим новую запись в [Sales].[Customers]
INSERT INTO [Sales].[Customers]
           ([CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[PrimaryContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryPostalCode]
           ,[PostalAddressLine1]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     OUTPUT inserted.CustomerID
     VALUES
           (N'Ivan Ivanov',1,3,1001,3,19586,19586,'2026-06-12',0,0,0,7,'(8452) 124-567','(8452) 124-567','http://www.ivanIvanov.ru','Lenina St.5','123450','PO Box 1234','123450',1)
--merge 
--если записи совпадают, то в CustomersNew ставим AccountOpenedDate = текущей дате
--если нет - то в ставляем новую из Customers
merge Sales.CustomersNew as target
using Sales.Customers as source on source.CustomerId = target.CustomerId
when matched then update set 
            CustomerID = source.CustomerID
           ,CustomerName = source.CustomerName
           ,BillToCustomerID = source.BillToCustomerID
           ,CustomerCategoryID = source.CustomerCategoryID
           ,BuyingGroupID = source.BuyingGroupID
           ,PrimaryContactPersonID = source.PrimaryContactPersonID
           ,AlternateContactPersonID = source.AlternateContactPersonID
           ,DeliveryMethodID = source.DeliveryMethodID
           ,DeliveryCityID = source.DeliveryCityID
           ,PostalCityID = source.PostalCityID
           ,CreditLimit = source.CreditLimit
           ,AccountOpenedDate = getDate()
           ,StandardDiscountPercentage = source.StandardDiscountPercentage
           ,IsStatementSent = source.IsStatementSent
           ,IsOnCreditHold = source.IsOnCreditHold
           ,PaymentDays = source.PaymentDays
           ,PhoneNumber = source.PhoneNumber
           ,FaxNumber = source.FaxNumber
           ,DeliveryRun = source.DeliveryRun
           ,RunPosition = source.RunPosition
           ,WebsiteURL = source.WebsiteURL
           ,DeliveryAddressLine1 = source.DeliveryAddressLine1
           ,DeliveryAddressLine2 = source.DeliveryAddressLine2
           ,DeliveryPostalCode = source.DeliveryPostalCode
           ,DeliveryLocation = source.DeliveryLocation
           ,PostalAddressLine1 = source.PostalAddressLine1
           ,PostalAddressLine2 = source.PostalAddressLine2
           ,PostalPostalCode = source.PostalPostalCode
           ,LastEditedBy = source.LastEditedBy
when not matched by target then insert 
            ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]) values 
           (source.CustomerID
           ,source.CustomerName
           ,source.BillToCustomerID
           ,source.CustomerCategoryID
           ,source.BuyingGroupID
           ,source.PrimaryContactPersonID
           ,source.AlternateContactPersonID
           ,source.DeliveryMethodID
           ,source.DeliveryCityID
           ,source.PostalCityID
           ,source.CreditLimit
           ,source.AccountOpenedDate
           ,source.StandardDiscountPercentage
           ,source.IsStatementSent
           ,source.IsOnCreditHold
           ,source.PaymentDays
           ,source.PhoneNumber
           ,source.FaxNumber
           ,source.DeliveryRun
           ,source.RunPosition
           ,source.WebsiteURL
           ,source.DeliveryAddressLine1
           ,source.DeliveryAddressLine2
           ,source.DeliveryPostalCode
           ,source.DeliveryLocation
           ,source.PostalAddressLine1
           ,source.PostalAddressLine2
           ,source.PostalPostalCode
           ,source.LastEditedBy);

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  
SELECT @@SERVERNAME
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.CustomersNew" out  "E:\SQL Server\BCP\CustomersNew.txt" -T -w -t"@eu&$1&" -S WIN-D7J5QNEPIA0'

drop table if exists Sales.CustomersNew_BulkDemo
-- копируем структуру таблицы
select * into Sales.CustomersNew_BulkDemo from Sales.CustomersNew where 1=0

BULK INSERT Sales.CustomersNew_BulkDemo
FROM "E:\SQL Server\BCP\CustomersNew.txt"
WITH (
		BATCHSIZE = 1000,       -- commit every 1000 rows
		DATAFILETYPE = 'widechar', -- file uses Unicode widechar format (BCP -w)
		FIELDTERMINATOR = '@eu&$1&', -- custom delimiter used in the BCP command above
		ROWTERMINATOR ='\n',   -- newline row terminator (may need '\r\n' for Windows files)
		KEEPNULLS,
		TABLOCK         
		);
select * from Sales.CustomersNew_BulkDemo