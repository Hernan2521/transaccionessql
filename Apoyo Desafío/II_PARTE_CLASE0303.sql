CREATE DATABASE g8_bdbanco;


CREATE TABLE cuentas (
    numero_cuenta INT NOT NULL UNIQUE PRIMARY KEY,
    balance INT CHECK (balance >= 0) --,
    -- PRIMARY KEY(numero_cuenta)
);

-- INSERT INTO cuentas (numero_cuenta, balance) VALUES (1, -1000);
INSERT INTO cuentas (numero_cuenta, balance) VALUES (1, 1000);
INSERT INTO cuentas (numero_cuenta, balance) VALUES (2, 1000);
/*
---------- COMMIT
*/
-- Hacer una transferencia de $1000 desde la cuenta 1 a la cuenta 2
BEGIN TRANSACTION;
UPDATE cuentas SET balance = balance - 1000 WHERE numero_cuenta = 1;
UPDATE cuentas SET balance = balance + 1000 WHERE numero_cuenta = 2;
COMMIT;
/*
---------- EJEMPLO DE TRANSACCIÓN CON ERROR
*/
-- Hacer una transferencia de $3000 desde la cuenta 2 a la cuenta 1
BEGIN TRANSACTION;
UPDATE cuentas SET balance = balance + 3000  WHERE numero_cuenta = 1;
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 2;
COMMIT;


/*
---------- EJEMPLO ROLLBACK
*/
-- Hacer una transferencia de $3000 desde la cuenta 2 a la cuenta 1
BEGIN TRANSACTION;
UPDATE cuentas SET balance = balance + 3000  WHERE numero_cuenta = 1;
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 2;
ROLLBACK;

BEGIN TRANSACTION;
UPDATE cuentas SET balance = balance + 1500  WHERE numero_cuenta = 1;
UPDATE cuentas SET balance = balance - 1500 WHERE numero_cuenta = 2;
ROLLBACK;


/*
---------- EJEMPLO SAVEPOINT
*/
-- Registrar una nueva cuenta con un saldo de $5000 y luego 
-- hacer una transferencia de $3000 desde la cuenta 2 a la nueva cuenta creada
BEGIN TRANSACTION;
INSERT INTO cuentas(numero_cuenta, balance) VALUES (3,5000);
SAVEPOINT nueva_cuenta; -- punto de recuperación
UPDATE cuentas SET balance = balance + 3000 WHERE numero_cuenta = (SELECT MAX(numero_cuenta) from cuentas);
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 2;
ROLLBACK TO nueva_cuenta;
COMMIT;


BEGIN TRANSACTION;
INSERT INTO cuentas(numero_cuenta, balance) VALUES (4,1000000);
SAVEPOINT nueva_cuenta; -- punto de recuperación
UPDATE cuentas SET balance = balance + 3000 WHERE numero_cuenta = (SELECT MAX(numero_cuenta) from cuentas);
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 3;
ROLLBACK TO nueva_cuenta;
COMMIT;

BEGIN TRANSACTION;
INSERT INTO cuentas(numero_cuenta, balance) VALUES (5,500000);
SAVEPOINT nueva_cuenta; 
UPDATE cuentas SET balance = balance + 3000 WHERE numero_cuenta = 5;
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 3;
ROLLBACK TO nueva_cuenta;
COMMIT;


BEGIN TRANSACTION;
INSERT INTO cuentas(numero_cuenta, balance) VALUES (6,10000);
SAVEPOINT nueva_cuenta; 
UPDATE cuentas SET balance = balance + 3000 WHERE numero_cuenta = 5;
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 3;
ROLLBACK TO nueva_cuenta;
COMMIT;

BEGIN TRANSACTION;
INSERT INTO cuentas(numero_cuenta, balance) VALUES (7,15000);
UPDATE cuentas SET balance = balance + 3000 WHERE numero_cuenta = (SELECT MAX(numero_cuenta) from cuentas);
UPDATE cuentas SET balance = balance - 3000 WHERE numero_cuenta = 3;
COMMIT;



/*--------------------Ejercicio guiado: 
Pongamos a prueba los conocimientos 
*/
/*
La pizzeria nacional Hot Cheese, ofrece en su sitio web para el servicio de pizzas a domicilio
y, apesar de estar funcionando bien los primeros meses, ha bajado su clientela por
incomodidades en sus usuarios, que realizan pagos electrónicos en la aplicación y
posteriormente reciben un correo de disculpas por la empresa diciendo que la pizza que
compró ya no está disponible. El dueño de la pizzería ha tomado cartas sobre el asunto y ha
solicitado contratar a un programador de bases de datos, para que cree una nueva base de
datos aplicando las restricciones para evitar que siga sucediendo esta situación.

Pasos para dar solución al requerimiento:
*/

-- 1. Crear una base de datos llamada “pizzeria”.
CREATE DATABASE g8_pizzeria;
-- 2. Conectarse a la base de datos pizzeria.
\c g8_pizzeria;
-- 3. Crear 2 tablas llamadas “ventas” y “pizzas” con la siguiente estructura.
 /*   MODELO DE LA TABLA VENTAS
    - cliente
    - fecha
    - monto
    - pizza (FK)
    MODELO DE LA TABLA PIZZAS
    - id(PK)
    - stock
    - costo
    - nombre

    */
CREATE TABLE pizzas(
    id_pizza INT PRIMARY KEY,
    stock INT CHECK (stock >= 0),
    costo INT,
    nombre VARCHAR(25)
);

CREATE TABLE ventas(
    id_ventas INT PRIMARY KEY,
    cliente VARCHAR(20),
    fecha DATE,
    monto INT,
    pizza_id INT REFERENCES pizzas(id_pizza)
);


-- 4. Agregar 1 registro a la tabla “pizzas” seteando como stock inicial 0.
INSERT INTO pizzas (id_pizza, stock, costo, nombre) 
VALUES (1,0, 12000, 'Uhlalá');

-- 5. Realizar una transacción que registre una nueva pizza con un stock positivo 
-- mayor a 1.
BEGIN TRANSACTION;
INSERT INTO pizzas (id_pizza, stock, costo, nombre) 
VALUES (2, 2, 15000, 'Jamón a todo dar');
COMMIT;

-- 6. Realizar una transacción que registre una venta con la pizza con stock 0 e intentar
-- actualizar su stock restándole 1.
BEGIN;
INSERT INTO ventas (id_ventas, cliente, fecha, monto, pizza_id) 
VALUES (1,'Dexter Gonzalez', '2020-02-02', 12000, 1);
UPDATE pizzas SET stock = stock - 1 WHERE id_pizza = 1;
COMMIT;

-- 7. Realizar una transacción que intente registrar 1 venta por cada pizza (considerando
--  que solo una de ellas tiene stock), guardando un
-- SAVEPOINT luego de la primera venta y volviendo a este punto si surge un error.

BEGIN;
INSERT INTO ventas (id_ventas, cliente, fecha, monto, pizza_id) 
VALUES (1,'Juan Bravo', '2020-02-02', 15000, 2);
UPDATE pizzas SET stock = stock - 1 WHERE id_pizza = 2;
SAVEPOINT valida_v;
INSERT INTO ventas (cliente, fecha, monto, pizza_id) 
VALUES ('Utonio Ramirez', '2020-02-02', 12000, 1);
UPDATE pizzas SET stock = stock - 1 WHERE id_pizza = 1;
ROLLBACK TO valida_v;
COMMIT;

-- 8. Exportar la base de datos “pizzeria” como un archivo pizzeria.sql.

-- en CMD:
-- cd C:\Program Files\PostgreSQL\10\bin> 
-- pg_dump -U postgres pizzeria > <rutaDeDestino>\pizzeria.sql
-- 
-- C:\Program Files\PostgreSQL\10\bin>pg_dump -U postgres pizzeria> C:\Users\belin\Desktop\pizzeria.sql
-- C:\Program Files\PostgreSQL\10\bin>pg_dump -U postgres --inserts pizzeria> C:\Users\belin\Desktop\pizzeria.sql

-- 9. Eliminar la base de datos “pizzeria”.
DROP DATABASE g8_pizzeria;
-- 10. Importar el archivo pizzeria.sql.

CREATE DATABASE g8_pizzeria;

-- C:\Program Files\PostgreSQL\10\bin>
-- psql -U postgres nombre_base_de_datos_existente < C:\Users\belin\Desktop\nombre_del_archivo_a_importar.sql

-- 11. Respaldo de todas las BD:
-- C:\Program Files\PostgreSQL\10\bin> pg_dumpall -U postgres --inserts >  C:\Users\belin\Desktop\respaldo.sql