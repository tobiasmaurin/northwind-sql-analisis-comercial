USE Northwind;
GO

--Se crea un esquema, si es que el mismo no existe.
IF SCHEMA_ID ('rpt') IS NULL
EXEC ('CREATE SCHEMA rpt');

GO

-- Se crea una vista
CREATE OR ALTER VIEW rpt.v_ventas
AS 
SELECT o.OrderID AS id_pedido,
		od.ProductID AS id_producto,
		o.CustomerID AS id_cliente,
		o.EmployeeID AS id_empleado,
		o.ShipVia AS id_transportista,
		CAST (o.OrderDate AS DATE) AS fecha_pedido,
		CAST(o.RequiredDate AS DATE) AS fecha_requerida,
		CAST(o.ShippedDate AS DATE) AS fecha_envio,
		od.UnitPrice AS precio_unitario,
		od.Quantity AS unidades,
		od.Discount AS descuento,
		od.UnitPrice*od.Quantity*(1-od.Discount) AS facturacion
FROM Orders AS o
JOIN [Order Details] AS od
	ON o.OrderID = od.OrderID

GO
