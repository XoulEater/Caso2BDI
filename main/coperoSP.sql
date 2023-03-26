


DROP PROCEDURE IF EXISTS RegistrarVenta;
DELIMITER $$
CREATE PROCEDURE RegistrarVenta(IN copero INT, IN carrito INT, IN playa INT, IN pfechaVenta DATETIME, 
IN pcomisionID INT, IN ptipopago TINYINT, IN ppago INT, IN pordergroup VARCHAR(36))
BEGIN
	-- Variables del pago
	DECLARE comisionTotal FLOAT;
    DECLARE precioTotal INT;
    DECLARE vuelto1 INT;
    
    DECLARE INVALID_COMISSION INT DEFAULT(53000);
    DECLARE INVALID_SHIFT_PLAYA INT DEFAULT(53002);
    DECLARE INVALID_SHIFT_CARRITO INT DEFAULT(53003);
    DECLARE INVALID_SHIFT_COPERO INT DEFAULT(53004);
    
    
        
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- *******************
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @err_no = MYSQL_ERRNO, @message = MESSAGE_TEXT;
        
        IF (ISNULL(@message)) THEN 
			SET @message = 'NO SE QUE PONER'; 
        ELSE
            SET @message = CONCAT('Internal error: ', @message);
        END IF;
        
        ROLLBACK;
        
        RESIGNAL SET MESSAGE_TEXT = @message;
	END;-- *******************
		
	-- Calculo del precio total
	SELECT 
		SUM(COALESCE(precioPorPlaya.precio, precioBase.precio) * og.cantidad)
	INTO precioTotal FROM
		tmporder og
			LEFT JOIN
		preciobase ON og.productoID = preciobase.productoID
			AND precioBase.active = 1
			LEFT JOIN
		precioPorPlaya ON og.productoID = precioPorPlaya.productoID
			AND precioPorPlaya.active = 1
			AND precioPorPlaya.playaID = playa
	WHERE
		og.ordergroup = pordergroup;
		
		-- Calculo del pago y del vuelto segun metodo de pago
		SELECT 
		porcentaje * precioTotal
	FROM
		comisiones
	WHERE
		comisionID = pcomisionID INTO comisionTotal;
		
	IF (comisionTotal IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = INVALID_COMISSION,
		MESSAGE_TEXT = 'Error de comisión: valor inválido ingresado';
	END IF;
	
	IF (ptipopago > 0) THEN
		SET ppago = precioTotal;
		SET vuelto1 = 0;
	ELSE
		SET vuelto1 = ppago - precioTotal;
	END IF;
		
	IF (copero IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = INVALID_SHIFT_COPERO, MESSAGE_TEXT = 'Error de TURNO: copero inválido';
	END IF;
		
	IF (carrito IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = INVALID_SHIFT_CARRITO, MESSAGE_TEXT = 'Error de TURNO: carrio inválido ';
	END IF;
		
	IF (playa IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = INVALID_SHIFT_PLAYA, MESSAGE_TEXT = 'Error de TURNO: pla7ya inválido ';
	END IF;
    
    SET @inventorygroup = UUID();
    INSERT INTO tmpinventorydata(inventorygroup, ingredienteID, cantidad, operationType)
    SELECT @inventorygroup, ixp.ingredienteID, ixp.cantidad * -1 * og.cantidad, 0
	FROM tmporder og
	INNER JOIN ingreXProdu ixp ON og.productoID = ixp.productoID 
	WHERE og.ordergroup = pordergroup;
    
    CALL RegistrarInventoryLog(@inventorygroup, carrito, copero, pfechaVenta);
    
    SET autocommit = 0;
	START TRANSACTION;
    -- Registro de la venta 
	INSERT INTO Ventas (posttime, tipopago, monto, vuelto, comisionID, coperoID, carritoID, playaID,  ordergroup, montoComision, createdAt, computer, username)
	VALUES (pfechaVenta, ptipopago, precioTotal, vuelto1, pcomisionID, copero, carrito, playa, pordergroup, comisionTotal, pfechaVenta, "computer1", "user1");
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS RegistrarInventoryLog;
DELIMITER $$
CREATE PROCEDURE RegistrarInventoryLog(IN pInventoryGroup VARCHAR(36), IN pcarritoID INT, IN pcoperoID INT, IN pfecha DATETIME)
BEGIN
        
	-- METER VALIDACIONES DE pInventoryGroup, coperoID, carritoID
	-- Creacion de los logs
	INSERT INTO inventoryLogs(posttime,operationType, quantity ,ingredientesID,createdAt, computer, username, carritoID, coperoID) 
	SELECT pfecha, operationType, cantidad, ingredienteID, pfecha, 'computer1', 'user1', pcarritoID, pcoperoID
	FROM tmpinventorydata
	WHERE inventorygroup = pInventorygroup;
    
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS RegistrarRefill;
DELIMITER $$
CREATE PROCEDURE RegistrarRefill(IN copero INT, IN carrito INT, IN pfecha DATETIME)
BEGIN

	SET @inventorygroup = UUID();
	INSERT INTO tmpinventorydata(inventorygroup, ingredienteID, cantidad, operationType) 
	SELECT @inventorygroup, ingredienteID, stack, 1
	FROM totalIngredientsByCarrito 
	WHERE carritoID = carrito AND totalQuantity < (stack * 0.3) AND dia = DATE(pfecha)
    AND HOUR(pfecha) >= horario AND HOUR(pfecha) <= (horario + 5);
    
    CALL RegistrarInventoryLog(@inventorygroup, carrito, copero, pfecha);
                
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS RegistrarOpen;
DELIMITER $$
CREATE PROCEDURE RegistrarOpen(IN copero INT, IN carrito INT, IN pfecha DATETIME)
BEGIN

	SET @inventorygroup = UUID();
	INSERT INTO tmpinventorydata(inventorygroup, ingredienteID, cantidad, operationType) 
	SELECT @inventorygroup, ingredienteID, stack, 2
	FROM ingredientes;
    
	CALL RegistrarInventoryLog(@inventorygroup, carrito, copero, pfecha);
     
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS RegistrarClose;
DELIMITER $$
CREATE PROCEDURE RegistrarClose(IN copero INT, IN carrito INT, IN pfecha DATETIME)
BEGIN
	SET @inventorygroup = UUID();
    -- ROUND(i.stack * (RAND()*0.2))
    -- -1000, 10, -990
	-- Vacia los elementos del carrito
	INSERT INTO tmpinventorydata(inventorygroup, ingredienteID, cantidad, operationType) 
    SELECT @inventorygroup, ingredienteID, (totalQuantity * -1) + ROUND(stack * (RAND()*0.1)), 3
    FROM totalIngredientsByCarrito 
    WHERE carritoID = carrito AND dia = DATE(pfecha) 
    AND HOUR(pfecha) >= horario AND HOUR(pfecha) <= (horario + 5);
    
    CALL RegistrarInventoryLog(@inventorygroup, carrito, copero, pfecha);
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS Cierre;
DELIMITER $$
CREATE PROCEDURE Cierre(IN inicio DATETIME)
BEGIN
	DECLARE vcoperoID INT;
    DECLARE vcarritoID INT;
    DECLARE horaCierre DATETIME;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT DISTINCT coperoID, carritoID, HoraFinal FROM turnos WHERE horaInicio = inicio;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	OPEN cur;
	readLoop: WHILE NOT done DO
        FETCH cur INTO vcoperoID, vcarritoID, horaCierre;
        IF NOT done THEN
			CALL RegistrarClose(vcoperoID, vcarritoID, horaCierre);
		END IF;
	END WHILE;
    CLOSE cur;
    
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS Apertura;
DELIMITER $$
CREATE PROCEDURE Apertura(IN inicio DATETIME)
BEGIN
	DECLARE vcoperoID INT;
    DECLARE vcarritoID INT;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT DISTINCT coperoID, carritoID FROM turnos WHERE horaInicio = inicio;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	OPEN cur;
	readLoop: WHILE NOT done DO
        FETCH cur INTO vcoperoID, vcarritoID;
        IF NOT done THEN
			CALL RegistrarOpen(vcoperoID, vcarritoID, inicio);
		END IF;
	END WHILE;
    CLOSE cur;
    
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS generarTurnos;
DELIMITER $$
CREATE PROCEDURE generarTurnos(IN startHour DATETIME, IN quantity INT, IN pplayaID INT)
BEGIN

	INSERT INTO turnos (horaInicio, HoraFinal, carritoID, coperoID, playaID, createdAt, computer, username)
	SELECT DISTINCT startHour, DATE_ADD(startHour, INTERVAL 5 HOUR), carritoID, carritoID * 2 - ROUND(RAND()), pplayaID, startHour, 'computer1', 'user1'
	FROM tmpShifts
	WHERE playaID = pplayaID
	GROUP BY carritoID
	HAVING COUNT(*) = 2
	ORDER BY RAND()
	LIMIT 3;
		
END$$
DELIMITER ;




DROP PROCEDURE IF EXISTS Llenado;
DELIMITER $$
CREATE PROCEDURE Llenado(IN startDate DATETIME)
BEGIN
        DECLARE currentDate DATETIME;
        DECLARE currentDay INT;
        DECLARE currenthora DATETIME;
        DECLARE endDate DATETIME;
        
        DECLARE ventasXdia INT;
		DECLARE ventasAM INT;
        DECLARE ventasPM INT;
        
        DECLARE inicioAM DATETIME;
		DECLARE inicioPM DATETIME;
        
        DECLARE ordenID INT;
        DECLARE productosAComprar INT;
        DECLARE cantidadAComprar INT;
        DECLARE vcarritoID INT;
        DECLARE vcoperoID INT;
        DECLARE vturnoID INT;
        DECLARE vplayaID INT;
        
        DECLARE vtipopago INT;
        DECLARE vpago INT;
        DECLARE totalProdu INT;
        
		DECLARE var INT;
	
        SET currentDate = STR_TO_DATE(CONCAT(DATE_FORMAT(startDate, '%Y-%m-%d'), ' 07:00:00'), '%Y-%m-%d %H:%i:%s');
        SET endDate = DATE_ADD(startDate, INTERVAL 1 MONTH);
		SET currentDay = DAYOFWEEK(currentDate);
		IF currentDay = 1 OR currentDay = 7 THEN
			SET ventasXdia =  FLOOR(RAND() * (60 - 45 + 1)) + 45;
		ELSE
			SET ventasXdia = FLOOR(RAND() * (60 - 10 + 1)) + 10;
		END IF;
        
        WHILE DATE(currentDate) <= DATE(endDate) DO 
	
			SET ventasAM = ventasXdia / 2;
            
            CALL generarTurnos(currentDate, 3, 1);
            CALL generarTurnos(currentDate, 3, 2);
            CALL generarTurnos(currentDate, 3, 3);
			SET currenthora = currentDate;
		
            CALL Apertura(currentDate);
            
            WHILE ventasAM >= 0 DO
				SET totalProdu = 0;
				-- Genero una orden 
                SET @orden = UUID();
                SET productosAComprar = FLOOR(RAND() * 3) + 1;
                
				-- Ciclo para elegir productos y sus cantidades
                WHILE productosAComprar >= 0 DO
					SET cantidadAComprar = FLOOR(RAND() * 2) + 1;
                    SET totalProdu = totalProdu + cantidadAComprar;
					INSERT INTO tmporder(ordergroup, productoID, cantidad)
					SELECT @orden,  p.productoID, cantidadAComprar
                    FROM copoproductos p 
                    ORDER BY RAND()
                    LIMIT 1;
                    SET productosAComprar = productosAComprar - 1;
                END WHILE;
                
                -- Selecciono un turno para que atienda la venta
                SELECT turnoID FROM turnos
                WHERE horaInicio = currentDate
                ORDER BY RAND()
                LIMIT 1
                INTO vturnoID;
                SET currenthora = DATE_ADD(currenthora, INTERVAL FLOOR(RAND() * 300/(ventasXdia/2)) MINUTE);
                SET vtipopago = FLOOR(RAND() * 4);
                SET vpago = 0;
                IF vtipopago = 0 THEN
					SET vpago = totalProdu * 9000; -- Con esto si o si alcanza
				END IF;
                
                -- Registro la venta y valido si hace falta refill
				SELECT 
					IFNULL(co.coperoID, - 1),
					IFNULL(ca.carritoID, - 1),
                    IFNULL(pl.playaID, - 1)
				INTO vcoperoID , vcarritoID , vplayaID
				FROM turnos t
				INNER JOIN coperos co ON t.coperoID = co.coperoID
				INNER JOIN carritos ca ON t.carritoID = ca.carritoID
				INNER JOIN playas pl ON t.playaID = pl.playaID
				WHERE t.turnoID = vturnoID;
                CALL RegistrarVenta(vcoperoID, vcarritoID, vplayaID, currenthora, 1, vtipopago, vpago,  @orden);
                CALL RegistrarRefill(vcoperoID, vcarritoID, DATE_ADD(currenthora, INTERVAL 1 MINUTE));
				SET ventasAM = ventasAM - 1;
                
            END WHILE;
            
            CALL Cierre(currentDate);
	
			IF TIME(currentDate) = '07:00:00' THEN
				SET currentDate = DATE_ADD(currentDate, INTERVAL 6 HOUR);
			else
				SET currentDate = DATE_ADD(currentDate, INTERVAL 18 HOUR);
				SET currentDay = DAYOFWEEK(currentDate);
				IF currentDay = 1 OR currentDay = 7 THEN
					SET ventasXdia =  FLOOR(RAND() * (60 - 45 + 1)) + 45;
				ELSE
					SET ventasXdia = FLOOR(RAND() * (60 - 10 + 1)) + 10;
				END IF;
			END IF;
            
		END WHILE;
END$$
DELIMITER ;

DROP VIEW IF EXISTS totalIngredientsByCarrito;
CREATE VIEW totalIngredientsByCarrito AS
    SELECT 
		DATE(il.posttime) AS dia,
		CASE 
            WHEN HOUR(il.posttime) >= 7 AND  HOUR(il.posttime) <= 12 THEN 7 -- [7, 12]
            ELSE 13
        END AS horario,
        c.carritoID AS carritoID,
        i.ingredienteID AS ingredienteID,
        SUM(il.quantity) AS totalQuantity,
        i.stack 
    FROM
        inventoryLogs il
            INNER JOIN
        carritos c ON il.carritoID = c.carritoID
            INNER JOIN
        ingredientes i ON il.ingredientesID = i.ingredienteID
    GROUP BY dia, horario, c.carritoID , i.ingredienteID
    ORDER BY dia, horario,  c.carritoID,  i.ingredienteID;


-- WHERE il.posttime < '2023-03-25 13:03:00'
