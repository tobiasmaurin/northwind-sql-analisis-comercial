USE Northwind;

--Validacion de cantidad de filas esperadas: 2155
SELECT  COUNT(*) AS Cant_filas 
FROM rpt.v_ventas;


--Validacion de cantidad de pedidos esperados: 830
SELECT COUNT(DISTINCT id_pedido) AS pedidos
FROM rpt.v_ventas;


--Validacion de facturacion por mes: 1996 = 208.083,97, 1997 = 617.085,20 y 1998 = 440.623,87
SELECT YEAR(fecha_pedido) AS anio,
		SUM(facturacion) AS facturacion
FROM rpt.v_ventas
GROUP BY YEAR(fecha_pedido)
ORDER BY anio;