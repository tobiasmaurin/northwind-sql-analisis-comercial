--Este script es para agregar un registro y comprobar que el pipeline funciona

SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO dbo.Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShipVia, ShipName)
VALUES (N'ALFKI', 1, '1998-05-07', '1998-06-04', 1, N'PRUEBA PIPELINE') ;

DECLARE @id INT = SCOPE_IDENTITY();

INSERT INTO dbo.[Order Details] (OrderID , ProductID , UnitPrice , Quantity , Discount)
VALUES (@id , 1 , 18 , 10 , 0);

SELECT *
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od
	ON o.OrderID = od.OrderID
WHERE o.ShipName = 'PRUEBA PIPELINE';

COMMIT;
 