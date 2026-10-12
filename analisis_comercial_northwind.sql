--1. Visión general
--a) Por año: número de pedidos, número de clientes que compraron,facturación y ticket medio por pedido.
--b) Comparación justa: enero-abril de 1997 frente a enero-abril de 1998.

--a)
WITH FacturacionPedido AS
					(SELECT o.OrderID,
							SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS Facturacion
					FROM Orders AS o
					JOIN [Order Details] AS od
						ON o.OrderID = od.OrderID
					GROUP BY o.OrderID
					)
SELECT FORMAT(o.OrderDate,'yyyy') AS Anio,
		COUNT(DISTINCT o.OrderID) AS CantPedidos,
		COUNT(DISTINCT o.CustomerID) AS CantClientes,
		CAST(SUM(fp.Facturacion) AS DECIMAL (12,2)) AS Facturacion,
		CAST(AVG(fp.Facturacion) AS DECIMAL (12,2)) AS TicketMedio
FROM Orders AS o
JOIN FacturacionPedido AS fp
	ON o.OrderID = fp.OrderID
GROUP BY FORMAT(o.OrderDate,'yyyy');

--b) 
WITH Anio1997 AS (
					SELECT FORMAT (OrderDate,'yyyy') AS Anio,
							COUNT(DISTINCT o.OrderID) AS CantPedidos,
							COUNT(DISTINCT o.CustomerID) AS CantClientes,
							SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS Facturacion
					FROM Orders AS o
					JOIN [Order Details] AS od
						ON o.OrderID = od.OrderID
					WHERE o.OrderDate >= '1997-01-01'
					AND o.OrderDate < '1997-05-01'
					GROUP BY FORMAT (OrderDate,'yyyy')
					),
	Anio1998 AS 
				  (
					SELECT FORMAT (OrderDate,'yyyy') AS Anio,
							COUNT(DISTINCT o.OrderID) AS CantPedidos,
							COUNT(DISTINCT o.CustomerID) AS CantClientes,
							SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS Facturacion
					FROM Orders AS o
					JOIN [Order Details] AS od
						ON o.OrderID = od.OrderID
					WHERE o.OrderDate >= '1998-01-01'
					AND o.OrderDate < '1998-05-01'
					GROUP BY FORMAT (OrderDate,'yyyy')
					)
	
SELECT A97.CantPedidos AS Pedidos1997,
		A98.CantPedidos AS Pedidos1998,
		CAST(A97.Facturacion AS DECIMAL (12,2)) AS Fact1997,
		CAST(A98.Facturacion AS DECIMAL (12,2)) AS Fact1998,
		CAST((A98.Facturacion-A97.Facturacion)/A97.Facturacion*100 AS DECIMAL (12,1)) AS Vaiacion
FROM Anio1997 AS A97
CROSS JOIN Anio1998 AS A98;



--2. Concentración de clientes
--Considerando todo el periodo de datos: los 10 clientes con mayor facturación, con su facturación,
--el % que representa cada uno sobre la facturación total de la empresa y el % acumulado 


WITH FactClientes AS (
						SELECT c.CustomerID,
								c.CompanyName,
								SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS Facturacion
						FROM Customers AS c
						JOIN Orders AS o
							ON c.CustomerID = o.CustomerID
						JOIN [Order Details] AS od
							ON o.OrderID = od.OrderID
						GROUP BY c.CustomerID,c.CompanyName
						)
SELECT TOP 10 CustomerID,
	CompanyName,
	CAST(Facturacion AS DECIMAL (12,2)) AS Facturacion,
	CAST(Facturacion/(SELECT SUM(Facturacion) FROM FactClientes)*100 AS DECIMAL (12,1)) AS PctSobTotal,
	CAST(SUM(Facturacion/(SELECT SUM(Facturacion) FROM FactClientes)*100)
							OVER(ORDER BY Facturacion DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DECIMAL (12,1)) AS pctAcumulado
FROM FactClientes
ORDER BY Facturacion DESC;


--3. Clientes en riesgo
--Clientes que compraron en 1997 pero no han hecho ningún pedido en 1998.
--nombre de la empresa, país, facturación de 1997, fecha de su último pedido
--y días transcurridos hasta el 6 de mayo de 1998. Ordenado por facturación de 1997, de mayor a menor.



SELECT c.CompanyName,
		c.Country,
		CAST(SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS DECIMAL (12,2)) AS Facturacion,
		MAX(o.OrderDate) AS FechaUltPedido,
		DATEDIFF(DAY,MAX(o.OrderDate),'1998-05-06') AS DiasSinComprar,
		SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) OVER () AS TotalEnRiesgo
FROM Customers AS c
JOIN Orders AS o
	ON c.CustomerID = o.CustomerID
JOIN [Order Details] AS od
	ON o.OrderID = od.OrderID
WHERE o.OrderDate >= '1997-01-01'
AND o.OrderDate <'1998-01-01'
AND c.CustomerID NOT IN (SELECT o.CustomerID
						 FROM Orders AS o
						 WHERE o.OrderDate >= '1998-01-01'
							AND o.OrderDate <'1999-01-01')
GROUP BY c.CustomerID, c.CompanyName, C.Country
ORDER BY Facturacion DESC;



--4. Evolución por categoría
--Para cada categoría: facturación de enero-abril de 1997, facturación de enero-abril de 1998
--y variación porcentual. Ordenado de menor a mayor variación.


WITH Anio1997 AS (
					SELECT c.CategoryID,
							c.CategoryName,
							SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS Facturacion97
					FROM Orders AS o
					JOIN [Order Details] AS od
						ON o.OrderID = od.OrderID
					JOIN Products AS p
						ON od.ProductID = p.ProductID
					JOIN Categories AS c
						ON p.CategoryID = c.CategoryID
					WHERE o.OrderDate >= '1997-01-01'
					AND o.OrderDate < '1997-05-01'
					GROUP BY c.CategoryID, c.CategoryName
					),

	Anio1998 AS		
					(
					SELECT c.CategoryID,
							c.CategoryName,
							SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS Facturacion98
					FROM Orders AS o
					JOIN [Order Details] AS od
						ON o.OrderID = od.OrderID
					JOIN Products AS p
						ON od.ProductID = p.ProductID
					JOIN Categories AS c
						ON p.CategoryID = c.CategoryID
					WHERE o.OrderDate >= '1998-01-01'
					AND o.OrderDate < '1998-05-01'
					GROUP BY c.CategoryID, c.CategoryName
					)
SELECT A97.CategoryName,
		CAST(A97.Facturacion97 AS DECIMAL (12,2)) AS Fact1997,
		CAST(A98.Facturacion98 AS DECIMAL (12,2)) AS Fact1998,
		CAST((A98.Facturacion98-A97.Facturacion97)/A97.Facturacion97*100 AS DECIMAL (12,1)) AS Variacion
FROM Anio1997 AS A97
JOIN  Anio1998 AS A98
	ON A97.CategoryID = A98.CategoryID
ORDER BY Variacion ASC;

--5. Equipo comercial (1997)
--Para cada empleado, en 1997: nombre completo, número de pedidos, facturación, ticket medio, 
--posición en el ranking por facturación y % de sus pedidos enviados a tiempo 


WITH FactEmployees AS (
    -- Pedidos y facturación de cada empleado en 1997
    SELECT e.EmployeeID,
           e.FirstName + ' ' + e.LastName AS Nombre,
           COUNT(DISTINCT o.OrderID)      AS NumPedidos,
           SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Facturacion
    FROM Employees AS e
    JOIN Orders AS o            ON e.EmployeeID = o.EmployeeID
    JOIN [Order Details] AS od  ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= '1997-01-01'
      AND o.OrderDate <  '1998-01-01'
    GROUP BY e.EmployeeID, e.FirstName, e.LastName
),
Envios AS (
    -- Pedidos enviados y pedidos enviados a tiempo de cada empleado en 1997
    SELECT EmployeeID,
           SUM(CASE WHEN ShippedDate IS NOT NULL     THEN 1 ELSE 0 END) AS PedidosEnviados,
           SUM(CASE WHEN ShippedDate <= RequiredDate THEN 1 ELSE 0 END) AS PedidosATiempo
    FROM Orders
    WHERE OrderDate >= '1997-01-01'
      AND OrderDate <  '1998-01-01'
    GROUP BY EmployeeID
)
SELECT fe.Nombre,
       fe.NumPedidos,
       CAST(fe.Facturacion AS DECIMAL(12,2))                 AS Facturacion,
       CAST(fe.Facturacion / fe.NumPedidos AS DECIMAL(12,2)) AS TicketMedio,
       RANK() OVER (ORDER BY fe.Facturacion DESC)            AS Ranking,
       CAST(100.0 * en.PedidosATiempo / NULLIF(en.PedidosEnviados, 0)
            AS DECIMAL(5,1))                                 AS PctEnviadosATiempo
FROM FactEmployees AS fe
LEFT JOIN Envios AS en
    ON fe.EmployeeID = en.EmployeeID
ORDER BY Ranking