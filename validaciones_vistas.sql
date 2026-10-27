USE Northwind;
GO

--Validacion de cantidad de filas esperadas: 2155
SELECT  COUNT(*) AS Cant_filas 
FROM rpt.v_ventas;


--Validacion de cantidad de pedidos esperados: 830
SELECT COUNT(DISTINCT id_pedido) AS pedidos
FROM rpt.v_ventas;


--Validacion de facturacion por mes: 1996 = 208.083,97, 1997 = 617.085,20 y 1998 = 440.623,87
SELECT YEAR(fecha_pedido) AS anio,
		ROUND(SUM(facturacion),2) AS facturacion
FROM rpt.v_ventas
GROUP BY YEAR(fecha_pedido)
ORDER BY anio;

--Validaciones de las vistas de tablas de dimensiones

--Clientes: 91 filas
SELECT COUNT(*) AS filas,
		COUNT(DISTINCT id_cliente) AS id_distintos
FROM rpt.v_clientes;

--productos: 77 filas
SELECT COUNT(*) AS filas,
		COUNT(DISTINCT id_producto) AS id_distintos
FROM rpt.v_productos;

--empleados: 9 filas
SELECT COUNT(*) AS filas,
		COUNT(DISTINCT id_empleado) AS id_distintos
FROM rpt.v_empleados;

--transportistas: 3 filas
SELECT COUNT(*) AS filas,
		COUNT(DISTINCT id_transportista) AS id_distintos
FROM rpt.v_transportistas;

--Ahora revisamos si hay id huerfanos en alguna tabla de dimensiones. Todas deberian ser 0
SELECT COUNT(*) AS huerfano
FROM rpt.v_ventas AS v
LEFT JOIN rpt.v_clientes AS c
	ON v.id_cliente = c.id_cliente
WHERE c.id_cliente IS NULL;

SELECT COUNT(*) AS huerfano
FROM rpt.v_ventas AS v
LEFT JOIN rpt.v_empleados AS e
	ON v.id_empleado = e.id_empleado
WHERE e.id_empleado IS NULL;

SELECT COUNT(*) AS huerfano
FROM rpt.v_ventas AS v
LEFT JOIN rpt.v_productos AS p
	ON v.id_producto = p.id_producto
WHERE p.id_producto IS NULL;

SELECT COUNT(*) AS huerfano
FROM rpt.v_ventas AS v
LEFT JOIN rpt.v_transportistas AS t
	ON v.id_transportista = t.id_transportista
WHERE t.id_transportista IS NULL;

