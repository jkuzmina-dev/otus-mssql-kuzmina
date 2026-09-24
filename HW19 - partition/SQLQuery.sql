--оценка числа записей в диапазонах дат
SELECT YEAR(TransactionOccurredWhen) as [year], count(*) as lines
  FROM [WideWorldImporters].[Warehouse].[StockItemTransactions]
  group by YEAR(TransactionOccurredWhen)
  order by YEAR(TransactionOccurredWhen)


--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'E:\SQL Server\Data\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO

-- граничные точки
CREATE PARTITION FUNCTION [fnYearPartition](DATETIME2) 
AS 
	RANGE RIGHT FOR VALUES ('20120101','20130101','20140101','20150101','20160101', '20170101');
GO

-- расположение секций 
CREATE PARTITION SCHEME [schmYearPartition] 
AS 
	PARTITION [fnYearPartition] ALL TO ([YearData])
GO

--создаем таблицу для секционированния 
SELECT * INTO Warehouse.StockItemsTransPartitioned
FROM Warehouse.StockItemTransactions;

--создадим кластерный индекс в той же схеме с ключом секционирования
ALTER TABLE Warehouse.StockItemsTransPartitioned 
	ADD CONSTRAINT PK_Warehouse_TransYears 
	PRIMARY KEY CLUSTERED  (TransactionOccurredWhen, StockItemTransactionID) ON [schmYearPartition](TransactionOccurredWhen);

-- проверка
-- секционированные таблицы
select distinct object_name(object_id)
from sys.partitions p
where partition_number > 1

-- вся инфа по секционированию
select f.name
	, iif(f.boundary_value_on_right = 0, 'left', 'right') as LeftORRight
	, v.value
	, v.boundary_id
	, t.name 
from sys.partition_functions f
inner join  sys.partition_range_values v on f.function_id = v.function_id
inner join sys.partition_parameters p on f.function_id = p.function_id
inner join sys.types t on t.system_type_id = p.system_type_id
order by f.name, boundary_id

-- число записей в секциях
select $partition.fnYearPartition(TransactionOccurredWhen) as num_partition
	, count(*) as qty
	, min(TransactionOccurredWhen) as min_
	, max(TransactionOccurredWhen) as max_ 
from Warehouse.StockItemsTransPartitioned
group by $partition.fnYearPartition(TransactionOccurredWhen) 
order by 1

