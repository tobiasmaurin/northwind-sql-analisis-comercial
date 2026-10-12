# Análisis comercial de Northwind con SQL Server

Diagnóstico comercial para el comité de dirección de una distribuidora de alimentación: crecimiento del negocio, concentración de clientes, clientes en riesgo, evolución por categoría y rendimiento del equipo comercial.

**Herramientas:** SQL Server · SSMS · T-SQL (CTE, funciones de ventana, agregación condicional)

---

## Resumen ejecutivo

- **El negocio crece:** la facturación de enero-abril de 1998 es un **+120,7 %** mayor que la del mismo periodo de 1997, sobre todo porque **los pedidos se duplicaron** (+108,1 %).
- **Alta dependencia de pocos clientes:** los **10 mayores clientes generan el 45 % de la facturación** y solo los 3 primeros, el 25,2 %.
- **7 clientes de 1997 no han vuelto a comprar en 1998** y suman 41.533,84 de facturación. **Dos de ellos concentran el 84 %** de ese importe, y uno, Mère Paillarde, es además uno de los 10 mayores clientes de la empresa.
- **Grains/Cereals, Confections y Condiments crecen muy por debajo de la media** (+31,6 %, +70,7 % y +71,7 % frente al +120,7 % total).
- **Facturación y puntualidad no siempre van juntas:** la comercial que más factura tiene el tercer porcentaje de envíos a tiempo más bajo del equipo.

---

## Contexto

Northwind Traders distribuye alimentación gourmet a clientes de todo el mundo. En mayo de 1998 se incorpora una nueva directora comercial que, en dos semanas, debe presentar al comité de dirección su diagnóstico y sus prioridades para el resto del año.

Como analista de datos, preparé el análisis que respalda esa presentación: números claros y conclusiones de negocio pensadas para un público que no sabe SQL.

**Datos:** base de datos de ejemplo Northwind (Microsoft): 830 pedidos, 2.155 líneas de pedido, 91 clientes, 77 productos y 9 empleados. Periodo: del 4 de julio de 1996 al 6 de mayo de 1998.

## Preguntas de negocio

1. **Visión general:** ¿el negocio crece o decrece?
2. **Concentración de clientes:** ¿cuánto depende la facturación de los 10 mayores clientes?
3. **Clientes en riesgo:** ¿qué clientes compraron en 1997 y no han vuelto a comprar en 1998?
4. **Evolución por categoría:** ¿qué categorías crecen y cuáles preocupan?
5. **Equipo comercial (1997):** ¿quién destaca y dónde hay margen de mejora?

---

## Hallazgos

### 1. El negocio crece con fuerza, impulsado por el número de pedidos

| Año | Pedidos | Clientes con compras | Facturación | Ticket medio por pedido |
|---|---:|---:|---:|---:|
| 1996 (desde julio) | 152 | 67 | 208.083,97 | 1.368,97 |
| 1997 | 408 | 86 | 617.085,20 | 1.512,46 |
| 1998 (hasta el 6 de mayo) | 270 | 81 | 440.623,87 | 1.631,94 |

1996 y 1998 son años incompletos, así que comparar los totales anuales daría una imagen falsa. Para una comparación justa usé el **mismo periodo (enero-abril)** de cada año:

| Enero-abril | Pedidos | Facturación | Ticket medio por pedido |
|---|---:|---:|---:|
| 1997 | 123 | 191.321,88 | 1.555,46 |
| 1998 | 256 | 422.290,24 | 1.649,57 |
| **Variación** | **+108,1 %** | **+120,7 %** | **+6,1 %** |

La facturación más que se duplica, y el motor del crecimiento es el **volumen**: los pedidos crecen un 108,1 %, mientras que el importe medio por pedido apenas sube un 6,1 %. Además, en solo cuatro meses de 1998 ya han comprado 81 clientes, casi tantos como en todo 1997 (86).

### 2. Alta dependencia de pocos clientes

| # | Cliente | Facturación | % sobre el total | % acumulado |
|---:|---|---:|---:|---:|
| 1 | QUICK-Stop | 110.277,30 | 8,7 % | 8,7 % |
| 2 | Ernst Handel | 104.874,98 | 8,3 % | 17,0 % |
| 3 | Save-a-lot Markets | 104.361,95 | 8,2 % | 25,2 % |
| 4 | Rattlesnake Canyon Grocery | 51.097,80 | 4,0 % | 29,3 % |
| 5 | Hungry Owl All-Night Grocers | 49.979,91 | 3,9 % | 33,2 % |
| 6 | Hanari Carnes | 32.841,37 | 2,6 % | 35,8 % |
| 7 | Königlich Essen | 30.908,38 | 2,4 % | 38,3 % |
| 8 | Folk och fä HB | 29.567,56 | 2,3 % | 40,6 % |
| 9 | Mère Paillarde | 28.872,19 | 2,3 % | 42,9 % |
| 10 | White Clover Markets | 27.363,61 | 2,2 % | 45,0 % |

*Facturación de todo el periodo (julio de 1996 a mayo de 1998), sobre un total de 1.265.793,04.*

- Los **10 mayores clientes concentran el 45 %** de la facturación.
- Los **3 primeros** (QUICK-Stop, Ernst Handel y Save-a-lot Markets) suman el **25,2 %**: cada uno aporta más del doble que el cuarto cliente.

La pérdida de uno solo de estos tres clientes supondría perder en torno al 8 % de la facturación.

### 3. Siete clientes de 1997 no han vuelto a comprar en 1998

| Cliente | País | Facturación 1997 | Último pedido | Días sin comprar (a 06/05/1998) |
|---|---|---:|---|---:|
| Mère Paillarde | Canadá | 23.332,31 | 30/10/1997 | 188 |
| Folies gourmandes | Francia | 11.666,90 | 22/12/1997 | 135 |
| Familia Arquibaldo | Brasil | 3.127,13 | 31/10/1997 | 187 |
| Hungry Coyote Import Store | EE. UU. | 2.283,20 | 08/09/1997 | 240 |
| GROSELLA-Restaurante | Venezuela | 387,50 | 18/12/1997 | 139 |
| Vins et alcools Chevalier | Francia | 379,80 | 12/11/1997 | 175 |
| Lazy K Kountry Store | EE. UU. | 357,00 | 22/05/1997 | 349 |
| **Total** | | **41.533,84** | | |

- En conjunto representan el **6,7 % de la facturación de 1997**.
- **Mère Paillarde y Folies gourmandes suman el 84 %** de ese importe. Mère Paillarde, además, es el **9.º mayor cliente** de toda la serie histórica y lleva más de seis meses sin comprar.

Es el hallazgo más accionable del análisis: son clientes con un historial de compra demostrado que se pueden contactar ya.

### 4. Todas las categorías crecen, pero tres se quedan muy por debajo de la media

| Categoría | Facturación ene-abr 1997 | Facturación ene-abr 1998 | Variación |
|---|---:|---:|---:|
| Grains/Cereals | 18.953,50 | 24.945,84 | +31,6 % |
| Confections | 30.855,53 | 52.672,50 | +70,7 % |
| Condiments | 18.570,47 | 31.892,21 | +71,7 % |
| Produce | 14.955,18 | 30.020,65 | +100,7 % |
| Meat/Poultry | 24.015,79 | 49.546,74 | +106,3 % |
| Dairy Products | 30.155,74 | 77.511,07 | +157,0 % |
| Beverages | 42.461,23 | 111.968,18 | +163,7 % |
| Seafood | 11.354,44 | 43.733,05 | +285,2 % |
| **Total** | **191.321,88** | **422.290,24** | **+120,7 %** |

- **Ninguna categoría decrece**, pero **Grains/Cereals (+31,6 %), Confections (+70,7 %) y Condiments (+71,7 %)** crecen muy por debajo del +120,7 % de la empresa y pierden peso en la facturación.
- **Beverages** es la categoría que más factura y una de las que más crece (+163,7 %). **Seafood** casi se multiplica por cuatro (+285,2 %).

### 5. Equipo comercial (1997): facturación y puntualidad no siempre van juntas

| Ranking | Comercial | Pedidos | Facturación | Ticket medio | % enviados a tiempo |
|---:|---|---:|---:|---:|---:|
| 1 | Margaret Peacock | 81 | 128.809,79 | 1.590,24 | 92,6 % |
| 2 | Janet Leverling | 71 | 108.026,16 | 1.521,50 | 97,2 % |
| 3 | Nancy Davolio | 55 | 93.148,08 | 1.693,60 | 98,2 % |
| 4 | Andrew Fuller | 41 | 70.444,14 | 1.718,15 | 92,7 % |
| 5 | Robert King | 36 | 60.471,20 | 1.679,76 | 88,9 % |
| 6 | Laura Callahan | 54 | 56.032,62 | 1.037,64 | 94,4 % |
| 7 | Michael Suyama | 33 | 43.126,37 | 1.306,86 | 97,0 % |
| 8 | Steven Buchanan | 18 | 30.716,47 | 1.706,47 | 100,0 % |
| 9 | Anne Dodsworth | 19 | 26.310,39 | 1.384,76 | 89,5 % |

- **Margaret Peacock** lidera la facturación (21 % del total de 1997), pero tiene el **tercer porcentaje de envíos a tiempo más bajo** (92,6 %).
- **Janet Leverling y Nancy Davolio** combinan volumen y puntualidad: son 2.ª y 3.ª en facturación con un 97,2 % y un 98,2 % de envíos a tiempo.
- **Laura Callahan** gestiona muchos pedidos (54, la 4.ª del equipo), pero con el **ticket medio más bajo** (1.037,64), lo que indica margen para aumentar el importe por pedido.
- Los porcentajes de puntualidad más bajos son los de **Robert King (88,9 %)** y **Anne Dodsworth (89,5 %)**.

> **Matiz importante:** el envío puede depender de logística o del transportista, no del comercial. Antes de evaluar a nadie por la puntualidad, conviene confirmar quién controla el despacho.

---

## Recomendaciones

1. **Recuperar a los clientes en riesgo, empezando por Mère Paillarde y Folies gourmandes.** Con dos llamadas se aborda el 84 % de la facturación en riesgo (34.999,21 de 41.533,84). Mère Paillarde es prioritario por ser además uno de los 10 mayores clientes históricos.
2. **Proteger a los grandes clientes y reducir la dependencia.** Asignar un responsable de cuenta a QUICK-Stop, Ernst Handel y Save-a-lot Markets (25,2 % de la facturación) e impulsar el crecimiento de los clientes medianos para repartir el riesgo.
3. **Entender por qué Grains/Cereals, Confections y Condiments crecen menos que la media.** Revisar precios, surtido y productos descontinuados en esas categorías antes de decidir si se impulsan o se reducen.
4. **Mejorar la puntualidad de los envíos.** Analizar los retrasos por transportista junto con logística y fijar un objetivo de puntualidad común. Leverling y Davolio demuestran que se puede vender mucho y enviar a tiempo.

---

## Metodología

**Definiciones:**
- **Pedido** = un registro de `Orders` (un `OrderID`).
- **Línea de pedido** = un registro de `[Order Details]`.
- **Facturación** = `SUM(UnitPrice * Quantity * (1 - Discount))`.
- **Ticket medio** = facturación / número de pedidos.
- **Envío a tiempo** = `ShippedDate <= RequiredDate`, calculado sobre los pedidos ya enviados.
- **Cliente en riesgo** = con al menos un pedido en 1997 y ninguno en 1998.

**Decisiones de análisis:**
- Comparaciones interanuales con el **mismo periodo (enero-abril)**, porque 1996 empieza en julio y 1998 termina el 6 de mayo.
- Porcentajes sobre el total y % acumulado (análisis de Pareto) con funciones de ventana (`SUM(...) OVER ()` y `SUM(...) OVER (ORDER BY ...)`).
- Ranking del equipo con funciones de ventana, y puntualidad con conteos condicionales (`CASE` dentro de `SUM`).
- Días sin comprar calculados con `DATEDIFF` hasta el 6 de mayo de 1998, último día con datos.

**Validaciones:**
- La suma de los pedidos por año (152 + 408 + 270) coincide con los 830 pedidos de la tabla.
- La suma de la facturación por categoría coincide exactamente con la facturación total de enero-abril de cada año (191.321,88 y 422.290,24).
- La suma de los pedidos por empleado en 1997 (408) y de su facturación coincide con los totales de 1997 (diferencia de 0,02 por redondeo).
- La suma de las facturaciones anuales (1.265.793,04) es el denominador del % sobre el total del análisis de Pareto.
- En el análisis del equipo, comprobé que el filtro de 1997 se aplica **dentro** de la CTE: en una primera versión se aplicaba fuera y mezclaba datos de los tres años. Lo detecté y lo corregí.

---

## Estructura del repositorio

```
├── README.md
└── analisis_comercial_northwind.sql   ← las 5 consultas, separadas y comentadas por pregunta
```

## Cómo reproducirlo

1. Instalar SQL Server (la edición Developer o Express es gratuita) y SQL Server Management Studio (SSMS).
2. Crear la base de datos Northwind con el script oficial de Microsoft: [sql-server-samples / northwind-pubs](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs).
3. Abrir `analisis_comercial_northwind.sql` en SSMS y ejecutar cada bloque por separado (seleccionar el bloque y pulsar F5).

## Próximos pasos

- Dashboard en Power BI conectado a SQL Server con estas mismas métricas, validando que las cifras coinciden con las consultas SQL (en curso).

---

**Tobias Maurin**: Data Analyst · [LinkedIn](https://www.linkedin.com/in/tobiasmaurin/)
