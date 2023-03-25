
DROP PROCEDURE IF EXISTS RegistrarVenta;
DELIMITER $$
CREATE PROCEDURE RegistrarVenta(IN pturnoID INT, IN pfechaVenta DATETIME, 
IN pcomisionID INT, IN ptipopago TINYINT, IN ppago INT, IN pordergroup VARCHAR(36))
BEGIN
	-- Variables del pago
	DECLARE comisionTotal FLOAT;
    DECLARE precioTotal INT;
    DECLARE vuelto1 INT;
    
    -- Variables del turno
    DECLARE copero INT;
    DECLARE carrito INT;
    DECLARE playa INT;
    
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
    
SELECT 
    IFNULL(co.coperoID, - 1),
    IFNULL(ca.carritoID, - 1),
    IFNULL(p.playaID, - 1)
INTO copero , carrito , playa FROM
    turnos t
        JOIN
    coperos co ON t.coperoID = co.coperoID
        JOIN
    carritos ca ON t.carritoID = ca.carritoID
        JOIN
    playas p ON t.playaID = p.playaID
WHERE
    t.turnoID = pturnoID;
    
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
    
        SET autocommit = 0;
		START TRANSACTION;
			    -- Creacion de los logs
			INSERT INTO inventoryLogs(posttime,operationType,quantity,ingredientesID,createdAt, computer, username, carritoID) 
			SELECT pfechaVenta, 0, ixp.cantidad * -1 * og.cantidad, ixp.ingredienteID, pfechaVenta, 'computer1', 'user1', carrito
			FROM tmporder og
			INNER JOIN ingreXProdu ixp ON og.productoID = ixp.productoID 
			WHERE og.ordergroup = pordergroup;
    
    -- Registro de la venta 
			INSERT INTO Ventas (posttime, tipopago, monto, vuelto, comisionID, coperoID, carritoID, playaID,  ordergroup, montoComision, createdAt, computer, username)
			VALUES (pfechaVenta, ptipopago, precioTotal, vuelto1, pcomisionID, copero, carrito, playa, pordergroup, comisionTotal, pfechaVenta, "computer1", "user1");
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS RegistrarRefill;
DELIMITER $$
CREATE PROCEDURE RegistrarRefill(IN pcarritoID INT, IN pfechaVenta DATETIME)
BEGIN

	INSERT INTO inventoryLogs(posttime,operationType,quantity,ingredientesID,createdAt, computer, username, carritoID) 
	SELECT pfechaVenta, 1, stack, ixc.ingredienteID, pfechaVenta, 'computer1', 'user1', carritoID 
	FROM totalIngredientsByCarrito ixc
	INNER JOIN ingredientes i ON ixc.ingredienteID = i.ingredienteID
	WHERE carritoID = pcarritoID AND ixc.totalQuantity < i.stack * 0.3;
                
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS RegistrarOpen;
DELIMITER $$
CREATE PROCEDURE RegistrarOpen(IN pcarritoID INT, IN pfechaVenta DATETIME)
BEGIN
	-- Creacion de los logs
	INSERT INTO inventoryLogs(posttime,operationType,quantity,ingredientesID,createdAt, computer, username, carritoID) 
	SELECT pfechaVenta, 2, stack, ingredienteID, pfechaVenta, 'computer1', 'user1', carritoID
	FROM ingredientes, carritos
    WHERE carritoID = pcarritoID;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS RegistrarClose;
DELIMITER $$
CREATE PROCEDURE RegistrarClose(IN pcarritoID INT, IN pfechaVenta DATETIME)
BEGIN
	-- Vacia los elementos del carrito
	INSERT INTO inventoryLogs(posttime,operationType,quantity,ingredientesID,createdAt, computer, username, carritoID) 
	SELECT pfechaVenta, 3, totalQuantity * -1, ingredienteID, pfechaVenta, 'computer1', 'user1', pcarritoID
	FROM totalIngredientsByCarrito 
    WHERE carritoID = pcarritoID;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS cambioTurno;
DELIMITER $$
CREATE PROCEDURE cambioTurno(IN inicioAM DATETIME ,IN inicioPM DATETIME)
BEGIN
	DECLARE vcarritoID INT;
    DECLARE foundTurn INT;
	DECLARE vcoperoID1 INT;
    DECLARE vturnoID INT;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT DISTINCT carritoID FROM turnos WHERE horaInicio = inicioAM OR horaInicio = inicioPM;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
	readLoop: WHILE NOT done DO
        FETCH cur INTO vcarritoID;
        IF NOT done THEN
			IF (SELECT COUNT(*) 
				FROM turnos 
				WHERE carritoID = vcarritoID 
				AND horaInicio IN (inicioAM, inicioPM)) = 2 THEN 
				-- REGISTRAR CAMBIO
                -- SELECT coperoID, turnoID FROM turnos 
                -- WHERE (horaInicio = inicioAM OR horaInicio = inicioPM) AND carritoID = vcarritoID
                -- ORDER BY coperoID DESC
                -- LIMIT 1
                -- INTO vcoperoID1, vturnoID;
                
                -- INSERT INTO cajacheck(fecha,checkTypeID,checkStatusID,coperoID1,coperoID2,turnoID,createdAt,computer,username)
                -- SELECT inicioPM, 1, 3, vcoperoID1, t.coperoID, vturnoID, inicioPM, 'computer1', 'user1'
                -- FROM turnos t
                -- WHERE (horaInicio = inicioAM OR horaInicio = inicioPM) AND carritoID = vcarritoID
                -- ORDER BY coperoID 
                -- LIMIT 1;
                delete FROM cajacheck;
               
			ELSEIF (SELECT COUNT(*) 
				FROM turnos 
				WHERE carritoID = vcarritoID 
				AND horaInicio = inicioAM) = 1 THEN
			    CALL RegistrarClose(vcarritoID, inicioPM);
			ELSE 
				CALL RegistrarOpen(vcarritoID, inicioPM);
			END IF;
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

DROP PROCEDURE IF EXISTS Cierre;
DELIMITER $$
CREATE PROCEDURE Cierre(IN inicioPM DATETIME)
BEGIN
	DECLARE vcarritoID INT;
    DECLARE horaCierre DATETIME;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT DISTINCT carritoID, HoraFinal FROM turnos WHERE horaInicio = inicioPM;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	OPEN cur;
	readLoop: WHILE NOT done DO
        FETCH cur INTO vcarritoID, horaCierre;
        IF NOT done THEN
			CALL RegistrarClose(vcarritoID, horaCierre);
		END IF;
	END WHILE;
    CLOSE cur;
    
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS Apertura;
DELIMITER $$
CREATE PROCEDURE Apertura(IN inicioAM DATETIME)
BEGIN
	DECLARE vcarritoID INT;
    DECLARE horaCierre DATETIME;
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT DISTINCT carritoID FROM turnos WHERE horaInicio = inicioAM;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	OPEN cur;
	readLoop: WHILE NOT done DO
        FETCH cur INTO vcarritoID;
        IF NOT done THEN
			CALL RegistrarOpen(vcarritoID, inicioAM);
		END IF;
	END WHILE;
    CLOSE cur;
    
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
        DECLARE vturnoID INT;
        
        DECLARE vtipopago INT;
        DECLARE vpago INT;
        DECLARE totalProdu INT;
        
		DECLARE var INT;
	
        SET currentDate = startDate;
        SET endDate = DATE_ADD(startDate, INTERVAL 2 MONTH);
        
        WHILE DATE(currentDate) <= DATE(endDate) DO 
        
			SET currentDay = DAYOFWEEK(currentDate);
			IF currentDay = 1 OR currentDay = 7 THEN
				SET ventasXdia =  FLOOR(RAND() * (60 - 45 + 1)) + 45;
            ELSE
				SET ventasXdia = FLOOR(RAND() * (60 - 10 + 1)) + 10;
			END IF;
        
			SET ventasAM = ventasXdia / 2;
			SET ventasPM = ventasXdia / 2;
            
            SET inicioAM = STR_TO_DATE(CONCAT(DATE_FORMAT(currentDate, '%Y-%m-%d'), ' 07:00:00'), '%Y-%m-%d %H:%i:%s');
            CALL generarTurnos(inicioAM, 3, 1);
            CALL generarTurnos(inicioAM, 3, 2);
            CALL generarTurnos(inicioAM, 3, 3);
			SET currenthora = inicioAM;
		
            CALL Apertura(inicioAM);
            
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
                WHERE horaInicio = inicioAM
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
                CALL RegistrarVenta(vturnoID, currenthora, 1, vtipopago, vpago,  @orden);
                SELECT carritoID FROM turnos 
                WHERE turnoID = vturnoID
                INTO vcarritoID;
                CALL RegistrarRefill(vcarritoID, DATE_ADD(currenthora, INTERVAL 5 MINUTE));
				SET ventasAM = ventasAM - 1;
            END WHILE;
            
			SET inicioPM = STR_TO_DATE(CONCAT(DATE_FORMAT(currentDate, '%Y-%m-%d'), ' 13:00:00'), '%Y-%m-%d %H:%i:%s');
            CALL generarTurnos(inicioPM, 3, 1);
            CALL generarTurnos(inicioPM, 3, 2);
            CALL generarTurnos(inicioPM, 3, 3);
            SET currenthora = inicioPM;
            
            CALL cambioTurno(inicioAM,inicioPM);
		
            WHILE ventasPM >= 0 DO
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
                WHERE horaInicio = inicioPM
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
                CALL RegistrarVenta(vturnoID, currenthora, 1, vtipopago, vpago,  @orden);
                SELECT carritoID FROM turnos 
                WHERE turnoID = vturnoID
                INTO vcarritoID;
                CALL RegistrarRefill(vcarritoID, DATE_SUB(currenthora, INTERVAL 5 MINUTE));
				SET ventasPM = ventasPM - 1;
            END WHILE;
            
            CALL Cierre(inicioPM);
	
			SET currentDate = DATE_ADD(currentDate, INTERVAL 1 DAY);

		END WHILE;
END$$
DELIMITER ;

DROP VIEW IF EXISTS totalIngredientsByCarrito;
CREATE VIEW totalIngredientsByCarrito AS
    SELECT 
        carritos.carritoID AS carritoID,
        ingredientes.ingredienteID AS ingredienteID,
        SUM(InventoryLogs.quantity) AS totalQuantity
    FROM
        coperosystem.inventoryLogs
            INNER JOIN
        coperosystem.carritos ON inventoryLogs.carritoID = carritos.carritoID
            INNER JOIN
        coperosystem.ingredientes ON inventoryLogs.ingredientesID = ingredientes.ingredienteID
    WHERE
        carritos.enable = 1
            AND ingredientes.enable = 1
    GROUP BY carritos.carritoID , ingredientes.ingredienteID;

