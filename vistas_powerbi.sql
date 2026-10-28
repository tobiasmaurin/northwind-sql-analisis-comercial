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


-- Vista de la dimensión calendario: una fila por día, años completos
CREATE OR ALTER VIEW rpt.v_calendario
AS
WITH periodo AS (
    -- 1) Límites: 1 de enero del primer año y 31 de diciembre del último
    SELECT DATEFROMPARTS(MIN(YEAR(OrderDate)), 1, 1)  AS inicio,
           DATEFROMPARTS(MAX(YEAR(OrderDate)), 12, 31) AS fin
    FROM dbo.Orders
),
fechas AS (
    -- 2) Una fila por día entre inicio y fin
    SELECT DATEADD(DAY, s.value, p.inicio) AS fecha
    FROM periodo AS p
    CROSS APPLY GENERATE_SERIES(0, DATEDIFF(DAY, p.inicio, p.fin)) AS s
)
-- 3) Las columnas de la dimensión
SELECT
    fecha,
    YEAR(fecha)                          AS anio,
    DATEPART(QUARTER, fecha)             AS trimestre,
    MONTH(fecha)                         AS mes,
    CHOOSE(MONTH(fecha),
           N'Enero', N'Febrero', N'Marzo', N'Abril', N'Mayo', N'Junio',
           N'Julio', N'Agosto', N'Septiembre', N'Octubre', N'Noviembre', N'Diciembre')
                                         AS nombre_mes,
    YEAR(fecha) * 100 + MONTH(fecha)     AS anio_mes,
    DAY(fecha)                           AS dia,
    DATEDIFF(DAY, '19000101', fecha) % 7 + 1
                                         AS dia_semana,
    CHOOSE(DATEDIFF(DAY, '19000101', fecha) % 7 + 1,
           N'Lunes', N'Martes', N'Miércoles', N'Jueves', N'Viernes', N'Sábado', N'Domingo')
                                         AS nombre_dia,
    CASE WHEN DATEDIFF(DAY, '19000101', fecha) % 7 + 1 >= 6
         THEN N'Sí' ELSE N'No' END       AS fin_de_semana
FROM fechas;
GO