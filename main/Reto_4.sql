
SELECT YEAR(posttime) AS Year, WEEK(posttime) AS Week,
c.placa AS Carrito,
i.descripcion AS Ingrediente,
SUM(il.quantity) AS aperturas
FROM inventorylogs il
INNER JOIN ingredientes i ON il.ingredientesID = i.ingredienteID
INNER JOIN carritos c ON il.carritoID = c.carritoID
WHERE il.operationType = 2
GROUP BY YEAR(posttime), WEEK(posttime), Carrito, Ingrediente, operationType
ORDER BY Year, Week;

SELECT YEAR(posttime) AS Year, WEEK(posttime) AS Week,
c.placa AS Carrito,
i.descripcion AS Ingrediente,
SUM(il.quantity) AS cierres
FROM inventorylogs il
INNER JOIN ingredientes i ON il.ingredientesID = i.ingredienteID
INNER JOIN carritos c ON il.carritoID = c.carritoID
WHERE il.operationType = 3
GROUP BY YEAR(posttime), WEEK(posttime), Carrito, Ingrediente, operationType
ORDER BY Year, Week;

SELECT YEAR(posttime) AS Year, WEEK(posttime) AS Week,
c.placa AS Carrito,
i.descripcion AS Ingrediente,
SUM(il.quantity) AS ventas
FROM inventorylogs il
INNER JOIN ingredientes i ON il.ingredientesID = i.ingredienteID
INNER JOIN carritos c ON il.carritoID = c.carritoID
WHERE il.operationType = 0
GROUP BY YEAR(posttime), WEEK(posttime), Carrito, Ingrediente, operationType
ORDER BY Year, Week;

SELECT 
    Year,
    Day,
    Carrito,
    Ingrediente,
    aperturas + cierres + ventas + refills AS Diff
FROM
    (SELECT 
        YEAR(posttime) AS Year,
            DAY(posttime) AS Day,
            c.placa AS Carrito,
            i.descripcion AS Ingrediente,
            SUM(CASE
                WHEN il.operationType = 2 THEN il.quantity
                ELSE 0
            END) AS aperturas,
            SUM(CASE
                WHEN il.operationType = 3 THEN il.quantity
                ELSE 0
            END) AS cierres,
            SUM(CASE
                WHEN il.operationType = 0 THEN il.quantity
                ELSE 0
            END) AS ventas,
            SUM(CASE
                WHEN il.operationType = 1 THEN il.quantity
                ELSE 0
            END) AS refills
    FROM
        inventorylogs il
    INNER JOIN ingredientes i ON il.ingredientesID = i.ingredienteID
    INNER JOIN carritos c ON il.carritoID = c.carritoID
    GROUP BY YEAR(posttime) , DAY(posttime) , Carrito , Ingrediente
    ORDER BY Year , Day) AS subquery
GROUP BY Year , Day , Carrito , Ingrediente
ORDER BY Year , Day;