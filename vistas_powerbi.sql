USE Northwind;
GO

--Se crea un esquema, si es que el mismo no existe.
IF SCHEMA_ID ('rpt') IS NULL
EXEC ('CREATE SCHEMA rpt');

GO

-- Se crea una vista de la tabla de hechos
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


-- Ahora se crearan las vistas de tablas de dimensiones

--Vista de la tabla de clientes

CREATE OR ALTER VIEW rpt.v_clientes
AS
SELECT CustomerID AS id_cliente,
		CompanyName AS cliente,
		City AS ciudad,
		Country AS pais
FROM Customers

GO

--Vista de la tabla de productos

CREATE OR ALTER VIEW rpt.v_productos
AS 
SELECT p.ProductID AS id_producto,
		p.ProductName AS producto,
		c.CategoryName AS categoria,
		s.CompanyName AS proveedor,
		s.Country AS pais_proveedor,
		CASE 
			WHEN p.Discontinued = 1 THEN 'Sí'
			ELSE 'No'
			END AS descatalogado
FROM Products AS p
LEFT JOIN Categories AS c
	ON p.CategoryID = c.CategoryID
LEFT JOIN Suppliers AS s
	ON p.SupplierID = s.SupplierID

GO

--Vista de tabla de empleados

CREATE OR ALTER VIEW rpt.v_empleados
AS
SELECT EmployeeID AS id_empleado,
		CONCAT(FirstName, ' ' , LastName) AS empleado,
		Title AS cargo,
		CAST(HireDate AS DATE) AS fecha_contratacion,
		Country AS pais
FROM Employees

GO

--Vista de tabla de transportistas

CREATE OR ALTER VIEW rpt.v_transportistas
AS
SELECT ShipperID AS id_transportista,
		CompanyName AS transportista
FROM Shippers

GO
