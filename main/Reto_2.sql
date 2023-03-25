-- Reto 2 fill database
USE coperosystem ; 

-- Insertar ingredientes
INSERT INTO coperosystem.ingredientes (descripcion, medida, stack) VALUES
('Jugo de Limón', 'ml', 10000),
('Jugo de Naranja', 'ml', 10000),
('Ginebra', 'ml', 5000),
('Vodka', 'ml', 5000),
('Ron', 'ml', 5000),
('Azúcar', 'gr', 1000),
('Soda', 'ml', 10000),
('Tónica', 'ml', 5000),
('Hielo', 'pieza', 100),
('Sal', 'gr', 1000),
('Tequila','ml', 5000), 
('Velmut','ml', 5000);


-- Insertar productos de coctelería
INSERT INTO coperosystem.copoProductos (descripcion) VALUES
('Gin Tonic'),
('Margarita'),
('Daiquiri'),
('Mojito'),
('Bloody Mary'),
('Cosmopolitan'),
('Mai Tai'),
('Sex on the Beach'),
('Manhattan'),
('Whiskey Sour');

INSERT INTO coperosystem.carritos (placa, color) VALUES
('ABC1', 'Rojo'),
('DEF2', 'Azul'),
('GHI3', 'Verde'),
('JKL4', 'Amarillo'),
('MNO5', 'Negro'),
('PQR6', 'Blanco'),
('STU7', 'Gris'),
('VWX8', 'Marrón'),
('YZA9', 'Plateado'),
('BCD0', 'Dorado'),
('EFG1', 'Café'),
('HIJ2', 'Morado'),
('KLM3', 'Naranja'),
('NOP4', 'Rosado'),
('QRS5', 'Turquesa');

INSERT INTO coperosystem.playas (playaID,nombre) VALUES
(1	,'Playa Tamarindo'),
(2,'Playa Manuel Antonio'),
(3,'Playa Conchal');



-- Gin Tonic
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 3, 1), -- Ginebra
(100, 8, 1), -- Tónica
(1, 9, 1); -- Hielo

-- Margarita
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 2), -- Jugo de Limón
(25, 6, 2), -- Azúcar
(50, 11, 2), -- Tequila
(1, 9, 2), -- Hielo
(25, 10, 2); -- Sal

-- Daiquiri
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 3), -- Jugo de Limón
(25, 6, 3), -- Azúcar
(50, 4, 3), -- Vodka
(1, 9, 3); -- Hielo

-- Mojito
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 4), -- Jugo de Limón
(25, 6, 4), -- Azúcar
(50, 5, 4), -- Ron
(1, 9, 4), -- Hielo
(25, 7, 4); -- Soda

-- Bloody Mary
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 5), -- Jugo de Limón
(100, 2, 5), -- Jugo de Naranja
(50, 5, 5), -- Ron
(1, 9, 5), -- Hielo
(5, 6, 5), -- Azúcar
(5, 10, 5); -- Sal

-- Cosmopolitan
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(40, 1, 6), -- Jugo de Limón
(20, 6, 6), -- Azúcar
(20, 3, 6), -- Ginebra
(20, 4, 6), -- Vodka
(10, 2, 6), -- Jugo de Naranja
(1, 9, 6); -- Hielo

-- Mai Tai
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 7), -- Jugo de Limón
(25, 6, 7), -- Azúcar
(50, 5, 7), -- Ron
(1, 9, 7), -- Hielo
(25, 8, 7); -- Tónica

-- Sex on the Beach
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 8), -- Jugo de Limón
(50, 2, 8), -- Jugo de Naranja
(25, 6, 8), -- Azúcar
(50, 5, 8), -- Ron
(1, 9, 8); -- Hielo

-- Manhattan
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 9), -- Jugo de Limón
(50, 4, 9), -- Vodka
(1, 9, 9), -- Hielo
(25, 12, 9); -- Vermut

-- Whiskey Sour
INSERT INTO coperosystem.ingreXProdu (cantidad, ingredienteID, productoID) VALUES
(50, 1, 10), -- Jugo de Limón
(50, 5, 10), -- Ron
(1, 9, 10), -- Hielo
(25, 4, 10); -- Whiskey



-- Insert Coperos
INSERT INTO coperos (nombre, telefono, cedula, enable, cuentaBancaria, createdAt, computer, username)
VALUES 
  ('Olivia Johnson', 26360510, 'C0666313', 0, 'BOFAUS6SXXX12345678901234', '2023-03-14 12:45:00', 'mycomputer1', 'user1'),
  ('Sophia Smith', 78453958, 'C1950276', 1, 'CHASUS33XXX23456789012345', '2023-03-14 12:46:00', 'mycomputer2', 'user2'),
  ('Aiden Brown', 40269023, 'C1287821', 1, 'CITIUS33XXX34567890123456', '2023-03-14 12:47:00', 'mycomputer3', 'user3'),
  ('Ethan Johnson', 76426636, 'C0888822', 0, 'BOFAUS6SXXX45678901234567', '2023-03-14 12:48:00', 'mycomputer4', 'user4'),
  ('Liam Wilson', 59030380, 'C0219742', 1, 'CHASUS33XXX56789012345678', '2023-03-14 12:49:00', 'mycomputer5', 'user5'),
  ('Noah Lee', 55871528, 'C0134858', 0, 'CITIUS33XXX67890123456789', '2023-03-14 12:50:00', 'mycomputer6', 'user6'),
  ('Mia Garcia', 88948652, 'C1760405', 1, 'BOFAUS6SXXX78901234567890', '2023-03-14 12:51:00', 'mycomputer7', 'user7'),
  ('Isabella Brown', 90522611, 'C1695507', 0, 'CHASUS33XXX89012345678901', '2023-03-14 12:52:00', 'mycomputer8', 'user8'),
  ('Charlotte Davis', 97704787, 'C2099136', 1, 'CITIUS33XXX90123456789012', '2023-03-14 12:53:00', 'mycomputer9', 'user9'),
  ('William Wilson', 29884156, 'C0456237', 1, 'BOFAUS6SXXX01234567890123', '2023-03-14 12:54:00', 'mycomputer10', 'user10'),
  ('Ana Rodriguez', 54812345, 'C1234567', 1, 'BOFAUS6SXXX12345478901234', '2023-03-14 13:00:00', 'mycomputer11', 'user11'),
  ('Pedro Sanchez', 67512345, 'C2345678', 0, 'CHASUQ33XXX23456789012345', '2023-03-14 13:01:00', 'mycomputer12', 'user12'),
  ('Marina Perez', 79212345, 'C3456789', 1, 'CITIUS33XXX34567890123156', '2023-03-14 13:02:00', 'mycomputer13', 'user13'),
  ('Luis Hernandez', 81912345, 'C4567890', 0, 'B6FAUS6SXXX45678901234567', '2023-03-14 13:03:00', 'mycomputer14', 'user14'),
  ('Maria Garcia', 93612345, 'C5678901', 1, 'CHASUS33XXX56789012345878', '2023-03-14 13:04:00', 'mycomputer15', 'user15'),
  ('Carlos Martinez', 63412345, 'C6789012', 0, 'CITIUS33XSX67890123456789', '2023-03-14 13:05:00', 'mycomputer16', 'user16'),
  ('Isabel Fernandez', 75112345, 'C7890123', 1, 'BOFAUS2SXXX78901234567890', '2023-03-14 13:06:00', 'mycomputer17', 'user17'),
  ('David Garcia', 86812345, 'C8901234', 0, 'CHASUS33XXX89015345678901', '2023-03-14 13:07:00', 'mycomputer18', 'user18'),
  ('Elena Rodriguez', 98512345, 'C9012345', 1, 'CITIU233XXX90123456789012', '2023-03-14 13:08:00', 'mycomputer19', 'user19'),
  ('Manuel Sanchez', 102312345, 'C0123456', 0, 'BOFAS6SXXX01234567890123', '2023-03-14 13:09:00', 'mycomputer20', 'user20'),
  ('Julia Torres', 123456789, 'C1122334', 1, 'BOFAUS6SXXX2345678901234', '2023-03-14 14:00:00', 'mycomputer21', 'user21'),
  ('Diego Vargas', 234567890, 'C2233445', 0, 'CHASUS33XAX23456789012345', '2023-03-14 14:01:00', 'mycomputer22', 'user22'),
  ('Sofia Garcia', 345678901, 'C3344556', 1, 'CITIUS33XXX34567890123456', '2023-03-14 14:02:00', 'mycomputer23', 'user23'),
  ('Lucas Ramirez', 456789012, 'C4455667', 0, 'BOFAU66SXXX45678901234567', '2023-03-14 14:03:00', 'mycomputer24', 'user24'),
  ('Valentina Castro', 567890123, 'C5566778', 1, 'CHASUS33XXX56789012845678', '2023-03-14 14:04:00', 'mycomputer25', 'user25'),
  ('Andres Gonzalez', 678901234, 'C6677889', 0, 'CITIUS33XXX67890123456789', '2023-03-14 14:05:00', 'mycomputer26', 'user26'),
  ('Carolina Silva', 789012345, 'C7788990', 1, 'BOFAUS6SXXX75901234567890', '2023-03-14 14:06:00', 'mycomputer27', 'user27'),
  ('Daniel Herrera', 890123456, 'C8899001', 0, 'CHAS3S33XXX89012345678901', '2023-03-14 14:07:00', 'mycomputer28', 'user28'),
  ('Gabriela Jimenez', 901234567, 'C9900112', 1, 'CITIUS33XX490123456789012', '2023-03-14 14:08:00', 'mycomputer29', 'user29'),
  ('Juan Gomez', 12345678, 'C0011223', 0, 'BOFAUS6SXXX01234567890123', '2023-03-14 14:09:00', 'mycomputer30', 'user30');


-- Insert precio base
INSERT INTO coperosystem.precioBase (productoID, precio, startDate, endDate, active, computer, username, checksum) VALUES
(1, 5000, '2023-03-12 00:00:00', NULL, 1, 'ComputerA', 'UserA', NULL),
(2, 6000, '2023-03-11 00:00:00', NULL, 1, 'ComputerB', 'UserB', NULL),
(3, 4500, '2023-03-10 00:00:00', NULL, 1, 'ComputerC', 'UserC', NULL),
(4, 5500, '2023-03-09 00:00:00', NULL, 1, 'ComputerD', 'UserD', NULL),
(5, 7000, '2023-03-08 00:00:00', NULL, 1, 'ComputerE', 'UserE', NULL),
(6, 4000, '2023-03-07 00:00:00', NULL, 1, 'ComputerF', 'UserF', NULL),
(7, 9000, '2023-03-06 00:00:00', NULL, 1, 'ComputerG', 'UserG', NULL),
(8, 6500, '2023-03-05 00:00:00', NULL, 1, 'ComputerH', 'UserH', NULL),
(9, 7500, '2023-03-04 00:00:00', NULL, 1, 'ComputerI', 'UserI', NULL),
(10, 8000, '2023-03-03 00:00:00', NULL, 1, 'ComputerJ', 'UserJ', NULL);

-- Insert precio por playa 
INSERT INTO coperosystem.precioPorPlaya (playaID, productoID, precio, startDate, endDate, active, computer, username, checksum)
VALUES
(1, 1, 5000, '2022-01-01 00:00:00', '2022-03-29 00:00:00', 1, 'Computer1', 'User1', NULL),
(2, 4, 6000, '2022-02-15 00:00:00', '2022-03-31 00:00:00', 1, 'Computer2', 'User2', NULL),
(3, 2, 5500, '2022-05-01 00:00:00', '2022-03-15 00:00:00', 1, 'Computer3', 'User3', NULL);


INSERT INTO coperosystem.comisiones (active,porcentaje,startDate,computer,username,checksum
) VALUES (1,0.05,NOW(),'MiComputadora','MiUsuario',UNHEX(SHA2(CONCAT('MiComputadora', 'MiUsuario'), 256)));

-- Checksum coperos--
UPDATE coperos SET checksum=SHA2(CONCAT(nombre, telefono, cedula, enable, cuentaBancaria), 256);
-- Checksum precio base--
UPDATE precioBase SET checksum=SHA2(CONCAT(productoID, precio), 256);
-- Checksum precio por playa--
UPDATE precioPorPlaya SET checksum=SHA2(CONCAT(playaID, productoID, precio), 256);
-- Checksum ventas

INSERT INTO checkTypes (checkTypeName) values 
('apertura'), ('cierre'), ('cambioTurno');

INSERT INTO checkStatuses (statusName)
VALUES ('correcto'), ('diferenteAceptado'), ('diferenciaRechazado');


create table tmpInventoryData (
	inventorygroup VARCHAR(36),
    ingredienteID INT,
    cantidad INT,
    operationType TINYINT
);

-- operationtypes
-- 0 = sale
-- 1 = refill
-- 2 = opening
-- 3 = closing


create table tmpShifts (
    coperoID INT,
    carritoID INT,
    playaID INT
);

DROP TABLE IF EXISTS tmpOrder;
create table tmpOrder (
	ordergroup VARCHAR(36),
    productoID INT,
    cantidad INT
);

insert into tmpShifts(coperoID, carritoID, playaID)
values 
	(1, 1, 1),
	(2, 1, 1),
	(3, 2, 1),
	(4, 2, 1),
	(5, 3, 1),
	(6, 3, 1),
	(7, 4, 1),
	(8, 4, 1),
	(9, 5, 1),
	(10, 5, 1),
    (11, 6, 2),
	(12, 6, 2),
	(13, 7, 2),
	(14, 7, 2),
	(15, 8, 2),
	(16, 8, 2),
	(17, 9, 2),
	(18, 9, 2),
	(19, 10, 2),
	(20, 10, 2),
    (21, 11, 3),
	(22, 11, 3),
	(23, 12, 3),
	(24, 12, 3),
	(25, 13, 3),
	(26, 13, 3),
	(27, 14, 3),
	(28, 14, 3),
	(29, 15, 3),
    (30, 15, 3)