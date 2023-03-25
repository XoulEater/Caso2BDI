use coperosystem;

-- 2.1
SELECT p.descripcion AS producto, i.descripcion AS ingrediente, ixp.cantidad, i.medida
FROM copoProductos p
INNER JOIN ingreXProdu ixp ON p.productoID = ixp.productoID
INNER JOIN ingredientes i ON ixp.ingredienteID = i.ingredienteID
WHERE p.productoID = 1;

-- 2.2
SELECT produ.descripcion AS producto, 
COALESCE(pxp.precio, pb.precio) AS precio, 
CASE pxp.precio WHEN NULL THEN 'No' ELSE 'Si' END AS flagEspecial, 
IFNULL(p.nombre, 'No asociado') AS nombrePlaya
FROM copoProductos produ
INNER JOIN preciobase pb ON produ.productoID = pb.productoID AND pb.active = 1
LEFT JOIN precioPorPlaya pxp ON produ.productoID = pxp.productoID AND pxp.active = 1
LEFT JOIN playas p ON pxp.playaID = p.playaID
ORDER BY precio DESC;

-- 2.3
SELECT p.descripcion AS producto, i.descripcion AS ingrediente
FROM ingrexprodu ixp
INNER JOIN ingredientes i ON ixp.ingredienteID = i.ingredienteID
INNER JOIN copoproductos p ON ixp.productoID = p.productoID 
WHERE i.ingredienteID NOT IN(SELECT ingredienteID FROM ingrexprodu WHERE productoID != p.productoID);

-- 2.4


-- 2.5
SELECT p.nombre AS playa, 
	SUM(v.monto) AS vendido,
    COUNT(*) AS ventas
FROM ventas v
INNER JOIN playas p ON v.playaID = p.playaID
INNER JOIN carritos c ON v.carritoID = c.carritoID 
WHERE v.posttime BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 MONTH)
GROUP BY p.nombre;



select p.nombre, c.nombre
from coperosxplaya cxp
INNER JOIN coperos c ON cxp.coperoID = c.coperoID
INNER JOIN playas p ON p.playaID = cxp.playaID;

select p.nombre, c.placa
from carritosxplaya cxp
INNER JOIN carritos c ON cxp.carritoID = c.carritoID
INNER JOIN playas p ON p.playaID = cxp.playaID;


CREATE VIEW totalIngredientsByCarrito1 AS
SELECT 
    carritos.placa AS carritoPlaca,
    ingredientes.descripcion AS ingrediente,
    SUM(inventoryLogs.quantity) AS totalQuantity
FROM 
    coperosystem.inventoryLogs
    INNER JOIN coperosystem.carritos ON inventoryLogs.carritoID = carritos.carritoID
    INNER JOIN coperosystem.ingredientes ON inventoryLogs.ingredientesID = ingredientes.ingredienteID
WHERE 
    carritos.enable = 1
    AND ingredientes.enable = 1
GROUP BY 
    carritos.placa, 
    ingredientes.descripcion;