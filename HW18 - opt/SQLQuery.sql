WITH CustomerTotal AS (
    -- Предварительно считаем сумму по каждому клиенту
    SELECT
        o.CustomerID,
        SUM(ol.UnitPrice * ol.Quantity) AS TotalAmount
    FROM Sales.Orders o
    JOIN Sales.OrderLines ol ON ol.OrderID = o.OrderID
    GROUP BY o.CustomerID
)
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Warehouse.StockItems AS si 
        ON si.StockItemID = det.StockItemID
    AND si.SupplierID  = 12
    JOIN CustomerTotal AS ct  
        ON ct.CustomerID = inv.CustomerID
    AND ct.TotalAmount > 250000
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND Inv.InvoiceDate = ord.OrderDate
    AND EXISTS (
        SELECT 1 FROM Sales.CustomerTransactions AS ct
        WHERE ct.InvoiceID = inv.InvoiceID)
    AND EXISTS (
        SELECT 1 FROM Warehouse.StockItemTransactions AS sit
        WHERE sit.StockItemID = det.StockItemID)
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
GO

CREATE INDEX IX_Invoices_InvoiceDate
ON Sales.Invoices(InvoiceDate);

CREATE INDEX IX_Orders_OrderDate
ON Sales.Orders(OrderDate);