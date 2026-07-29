exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
GO

reconfigure
GO
--подключение сборки
CREATE ASSEMBLY CLRFunctions FROM 'E:\SQL Server\HW\otus-mssql-kuzmina\HW14 - CLR\SplitString.dll' 
GO

--проверка существования сборки
SELECT * FROM sys.assemblies
GO

--подключение функции
CREATE OR ALTER FUNCTION [dbo].SplitString(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [CLRFunctions].[SplitString.UserDefinedFunctions].SplitString
GO

--использование
select InvoiceID, part from Sales.Invoices i
CROSS APPLY 
dbo.SplitString(i.DeliveryInstructions, ',')

