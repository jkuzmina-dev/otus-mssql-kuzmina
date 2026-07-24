USE [Kindergarten]
GO

CREATE INDEX idx_Children_Name
ON Children ([Name])

CREATE INDEX idx_Groups_Name
ON Groups ([Name])

CREATE INDEX idx_Attendance_Group_Date
ON Attendance(GroupID, Date)
INCLUDE (ChildID, IsPresent);

CREATE INDEX idx_Operations_Child_OperationType
ON Operations (ChildID, OperationType)
INCLUDE (Amount);

--Табель посещения детей опредленной группы за указанный интервал времени
SELECT a.Date
      ,c.Name
      ,g.Name
      ,a.IsPresent
  FROM [dbo].[Attendance] a
  join Children c on c.ChildID = a.ChildID
  join Groups g on g.GroupID = a.GroupID
  where a.Date between '2026-06-01' and '2026-07-30'
        and g.Name = 'Пчелка'
  order by a.Date, c.Name

GO

--Баланс по начислениям/оплатам по конкретному ребенку
SELECT
    c.Name,
    SUM(CASE WHEN o.OperationType = N'начисление' THEN o.Amount ELSE 0 END) AS Accrual,
    SUM(CASE WHEN o.OperationType = N'погашение' THEN o.Amount ELSE 0 END) AS Payment,
    SUM(CASE WHEN o.OperationType = N'начисление' THEN -o.Amount
             WHEN o.OperationType = N'погашение' THEN o.Amount
             ELSE 0 END) AS Balance
FROM Children c
LEFT JOIN Operations o
    ON o.ChildID = c.ChildID
WHERE c.Name = N'Зайцев Максим Павлович'
GROUP BY c.ChildID, c.Name;

GO

    
