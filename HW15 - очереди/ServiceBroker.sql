--------------------------
-- подготовка
USE WideWorldImporters
--ALTER TABLE Sales.Invoices ADD InvoiceConfirmedForProcessing DATETIME;
CREATE TABLE Sales.CustOrders (
[CustomerID] [int] NOT NULL,
[DateFrom] [Date],
[DateTo] [Date],
[OrdersCount] [INT],
[CreationDateTime] [DATETIME])

--включить брокер
USE master 
ALTER DATABASE WideWorldImporters SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; 
-- NO WAIT дл¤ prod (в однопользовательском режиме!!!)

--sb должен функционировать от имени sa
ALTER AUTHORIZATION ON DATABASE::WideWorldImporters TO [sa];

-- доверенное соединение (если 2 БД)
--ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

--------------------------
-- инфраструктура
-- Service: Queue + Contract(Direction, MessageType) 

USE WideWorldImporters

-- naming
CREATE MESSAGE TYPE [//WWI/SB/RequestMessage] VALIDATION=WELL_FORMED_XML;
CREATE MESSAGE TYPE [//WWI/SB/ReplyMessage] VALIDATION=WELL_FORMED_XML;

CREATE CONTRACT [//WWI/SB/Contract] (
	[//WWI/SB/RequestMessage] SENT BY INITIATOR
    , [//WWI/SB/ReplyMessage] SENT BY TARGET
    );

-- цель
CREATE QUEUE TargetQueueWWI;
CREATE SERVICE [//WWI/SB/TargetService] ON QUEUE TargetQueueWWI ([//WWI/SB/Contract]);

--инициатор
CREATE QUEUE InitiatorQueueWWI;
CREATE SERVICE [//WWI/SB/InitiatorService] ON QUEUE InitiatorQueueWWI ([//WWI/SB/Contract]);

--- хп
-- SendNewCustomer.sql - обычная хп
-- GetNewCustomer.sql - RECEIVE на стороне цели; активационная процедура (всегда без параметров)
-- ConfirmCustomer.sql - RECEIVE на стороне инициатора; активационная процедура (всегда без параметров)

--------------------------
-- тесты
SELECT CustomerID
FROM Sales.Invoices
WHERE InvoiceID IN (61210,61211,61212,61213) ;

-- отправка в ручном режме
-- SEND 2 target (открыли диалог)
EXEC Sales.SendNewCustomer @customerId = 192, @dateFrom = '2015-01-01', @dateTo = '2015-12-31';

SELECT CAST(message_body AS XML),* FROM dbo.TargetQueueWWI; -- здесь сообщение
SELECT CAST(message_body AS XML),* FROM dbo.InitiatorQueueWWI;

EXEC Sales.GetNewCustomer; -- без параметров!

SELECT * FROM Sales.CustOrders

SELECT CAST(message_body AS XML),* FROM dbo.TargetQueueWWI;
SELECT CAST(message_body AS XML),* FROM dbo.InitiatorQueueWWI;  -- здесь сообщение

EXEC Sales.ConfirmCustomer; -- без параметров

--------------------------
-- автоматическая обработка через процедуры активации (без параметров)
ALTER QUEUE TargetQueueWWI 
WITH ACTIVATION (
	STATUS = ON -- вкл
	, PROCEDURE_NAME = Sales.GetNewCustomer
	, MAX_QUEUE_READERS = 1 -- 1 worker (0 - хп будет вызвана)
	, EXECUTE AS OWNER -- контекст безопаности
	); 
GO

ALTER QUEUE InitiatorQueueWWI 
WITH ACTIVATION (
	STATUS = ON --  вкл
	, PROCEDURE_NAME = Sales.ConfirmCustomer
	, MAX_QUEUE_READERS = 1 -- 1 worker (0 - хп будет вызвана)
	, EXECUTE AS OWNER -- контекст безопаности
	); 
GO
-- тесты
EXEC Sales.SendNewCustomer @customerId = 961, @dateFrom = '2015-01-01', @dateTo = '2015-12-31';
SELECT * FROM Sales.CustOrders

--список диалогов
SELECT conversation_handle, is_initiator, s.name as 'local service', far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce 
-- представление диалогов удаляется асинхронно сборщиком мусора Service Broker, а не в момент END CONVERSATION
-- чтобы её не переполнять НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
LEFT JOIN sys.services s ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;