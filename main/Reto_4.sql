
SELECT 
    Year,
    Day,
    Copero,
    Ingrediente,
    aperturas + cierres + ventas + refills AS Diff
FROM
    (SELECT 
        YEAR(posttime) AS Year,
            DAY(posttime) AS Day,
            c.nombre AS Copero,
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
    INNER JOIN Coperos c ON il.coperoID = c.coperoID
    GROUP BY YEAR(posttime) , DAY(posttime) , Copero , Ingrediente
    ORDER BY Year , Day) AS subquery
GROUP BY Year , Day , Copero , Ingrediente
ORDER BY Year , Day;