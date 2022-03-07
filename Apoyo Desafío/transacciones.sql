

--1. Cargar el respaldo de la base de datos unidad2.sql
--en postgres crear db dia2; 
-- en CMD(windows):
-- cd C:\Program Files\PostgreSQL\10\bin
--psql -U postgres -W -h localhost dia2 < C:\Users\hernan\Desktop\desafioLatam\sql\transacciones\unidad2.sql




--2. El cliente usuario01 ha realizado la siguiente compra:
BEGIN;
INSERT INTO compra(id,cliente_id, fecha) VALUES ((SELECT MAX(id) + 1 FROM compra),1,(SELECT CURRENT_DATE));
SAVEPOINT nueva_compra1;
UPDATE producto SET stock = stock - 5 WHERE id = 9;
INSERT INTO detalle_compra(id,producto_id,compra_id,cantidad) VALUES((SELECT MAX(id) + 1 FROM detalle_compra),9,(select max(id) from compra),5);
COMMIT;


SELECT * FROM producto;


--3. El cliente usuario02 ha realizado la siguiente compra:
BEGIN;
INSERT INTO compra(id,cliente_id, fecha) VALUES ((SELECT MAX(id) + 1 FROM compra),2,(SELECT CURRENT_DATE));
SAVEPOINT nueva_compra2;
UPDATE producto SET stock = stock - 3 WHERE id = 1;
INSERT INTO detalle_compra(id,producto_id,compra_id,cantidad) VALUES((SELECT MAX(id) + 1 FROM detalle_compra),1,(select max(id) from compra),3);
UPDATE producto SET stock = stock - 3 WHERE id = 2;
INSERT INTO detalle_compra(id,producto_id,compra_id,cantidad) VALUES((SELECT MAX(id) + 1 FROM detalle_compra),2,(select max(id) from compra),3);
UPDATE producto SET stock = stock - 3 WHERE id = 8;
INSERT INTO detalle_compra(id,producto_id,compra_id,cantidad) VALUES((SELECT MAX(id) + 1 FROM detalle_compra),8,(select max(id) from compra),3);
COMMIT;

-- ROLLBACK por falta de stock
--ERROR:  el nuevo registro para la relación «producto» viola la restricción «check» «stock_valido»
--DETALLE:  La fila que falla contiene (8, producto8, -3, 8923).


--4. Realizar las siguientes consultas:

--a. Deshabilitar el AUTOCOMMIT
\set AUTOCOMMIT off
--b. Insertar un nuevo cliente
BEGIN;
SAVEPOINT pto4;
INSERT INTO cliente(id,nombre,email) VALUES((SELECT MAX(id) + 1 FROM cliente),'Pablo','..');
--c. Confirmar que fue agregado en la tabla cliente
SELECT EXISTS(SELECT nombre FROM cliente WHERE nombre ='Pablo');
--d. Realizar un ROLLBACK
ROLLBACK;
--e. Confirmar que se restauró la información, sin considerar la inserción delpunto b
SELECT EXISTS(SELECT nombre FROM cliente WHERE nombre ='Pablo');
--ahora saldra falsa, indicando que se restaruo la informacion.
--f. Habilitar de nuevo el AUTOCOMMIT
\set AUTOCOMMIT on