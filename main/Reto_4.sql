SELECT 
    Semana,
    Day,
    Copero,
    Ingrediente,
        CASE WHEN(aperturas + cierres + ventas + refills > stack * 0.09) THEN
        'MEDIUM'
    WHEN (aperturas + cierres + ventas + refills <= stack * 0.1) THEN
        'SMALL'
    END AS Rate,
    aperturas + cierres + ventas + refills AS Diff
FROM
    (SELECT 
        WEEK(il.posttime) AS Semana,
            DATE(il.posttime) AS Day,
            c.nombre AS Copero,
            i.descripcion AS Ingrediente,
            i.stack,
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
    GROUP BY WEEK(posttime) , DATE(posttime) , Copero , Ingrediente, stack
    ORDER BY Semana , Day) AS subquery
GROUP BY Semana , Day , Copero , Ingrediente, DIFF, Rate
ORDER BY Semana , Day;


SELECT 
        WEEK(il.posttime) AS Semana,
            DATE(il.posttime) AS Day,
            c.nombre AS Copero,
            i.descripcion AS Ingrediente,
            i.stack,
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
    GROUP BY WEEK(posttime) , DATE(posttime) , Copero , Ingrediente, stack
    ORDER BY Semana , Day