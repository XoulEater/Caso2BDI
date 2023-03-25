
-- Pago a coperos en rango de tiempo 
SELECT YEAR(v.posttime) AS Year, WEEK(v.posttime) AS Week,
	c.nombre AS Copero, 
	SUM(v.montoComision) AS Pago,
    COUNT(*) AS ventas
FROM ventas v
INNER JOIN coperos c ON v.coperoID = c.coperoID
GROUP BY YEAR(v.posttime), WEEK(v.posttime), Copero
ORDER BY Year, Week, Copero;

-- Ingredientes usados en el rango de fechas
SELECT YEAR(posttime) AS Year, WEEK(posttime) AS Week,
    i.descripcion AS Ingrediente, 
	SUM(il.quantity) AS Cantidad,
	i.medida AS Unidad
FROM ingredientes i 
INNER JOIN inventorylogs il ON il.ingredientesID = i.ingredienteID AND il.operationType = 0
GROUP BY YEAR(il.posttime), WEEK(il.posttime), il.ingredientesID
ORDER BY Year, Week;

SELECT YEAR(posttime) AS Year, WEEK(posttime) AS Week, SUM(monto) AS Total
FROM ventas
GROUP BY YEAR(posttime), WEEK(posttime)
ORDER BY Year, Week;