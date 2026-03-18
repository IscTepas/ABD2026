-- PRACTICA 5
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--11/03/26
--PRACTICA 5. BD AEROPUERTO
--1. Adjunta la BD Aeropuerto que se te subió al drive
USE AEROPUERTO
GO
--2. Crea el diagrama
--3. Analiza la bd consultando lo que tiene cada tabla
SELECT * FROM SYS.objects
WHERE TYPE='U'
SELECT * FROM DBO.AEROLINEA
SELECT * FROM DBO.AEROPUERTO
SELECT * FROM DBO.AVION
SELECT * FROM DBO.PAIS
SELECT * FROM DBO.PASAJERO
SELECT * FROM DBO.RESERVA
SELECT * FROM DBO.VUELO
GO
--4. Crea al menos dos esquemas tu decide cuales de acuerdo a las tablas que tiene y cámbialas
CREATE SCHEMA [CONTROL]
GO
CREATE SCHEMA CHECKIN
GO
--5. Crear tres logins a nivel de servidor:
--login_gerente
CREATE LOGIN login_gerente WITH PASSWORD='1234', DEFAULT_DATABASE=AEROPUERTO
--login_operativo
CREATE LOGIN login_operativo WITH PASSWORD='1234'
--login_consulta
CREATE LOGIN login_consulta WITH PASSWORD='1234'
--6. Crear tres usuarios dentro de la base de datos AEROPUERTO que estén asociados a los logins creados anteriormente:
--usuario_gerente
CREATE USER usuario_gerente FOR LOGIN login_gerente
--usuario_operativo
CREATE USER usuario_operativo FOR LOGIN login_operativo
--usuario_consulta
CREATE USER usuario_consulta FOR LOGIN login_consulta WITH DEFAULT_SCHEMA=CHECKIN
--7. Crear tres roles personalizados dentro de la base de datos:
--rol_gerencia: administración completa de la BD, puede consultar, insertar,
--modificar y eliminar información, crear tablas, alterarlas y dropearlas.
CREATE ROLE ROL_GERENCIA
EXEC sp_addrolemember [db_owner],ROL_GERENCIA
--rol_operativo: usuarios encargados de las operaciones diarias (reservas, vuelos,
--pasajeros, etc.)
CREATE ROLE ROL_OPERATIVO
EXEC sp_addrolemember [db_datawriter],ROL_OPERATIVO
EXEC sp_addrolemember [db_datareader],ROL_OPERATIVO
--rol_lectura: usuarios de consulta
CREATE ROLE ROL_LECTURA
EXEC sp_addrolemember [db_datareader],ROL_LECTURA
--8. Asignar permisos a cada rol según su función dentro del sistema (administración,
--operación o consulta).
--rol_gerencia: herendando de otros roles.
--rol_operativo: con GRANT
--rol_lectura: herendando de otros roles.
--9. Agregar los usuarios creados a los roles personalizados correspondientes
ALTER ROLE ROL_GERENCIA ADD MEMBER usuario_gerente
ALTER ROLE ROL_OPERATIVO ADD MEMBER usuario_operativo
ALTER ROLE ROL_LECTURA ADD MEMBER usuario_consulta
--10. Crear índices en cada tabla por otro campo que no sea la pk
EXEC sp_helpindex PAIS;
CREATE NONCLUSTERED INDEX inx_pais_nombre ON [CHECKIN].PAIS(nombre);

EXEC sp_helpindex AEROPUERTO;
CREATE NONCLUSTERED INDEX inx_aerop_paisnombre
ON [CONTROL].AEROPUERTO(idPais, nombre);

EXEC sp_helpindex VUELO;
CREATE NONCLUSTERED INDEX inx_vuelo_origen
ON [CONTROL].VUELO(origen);
CREATE NONCLUSTERED INDEX inx_vuelo_destino
ON [CONTROL].VUELO(destino);

EXEC sp_helpindex PASAJERO;
CREATE NONCLUSTERED INDEX inx_pasajero_nombre ON [CHECKIN].Pasajero(nombre);

EXEC sp_helpindex AEROLINEA;
CREATE NONCLUSTERED INDEX inx_aerolinea_idPais
ON [CONTROL].AEROLINEA(idPais);

EXEC sp_helpindex AVION
CREATE NONCLUSTERED INDEX inx_avion_aerolinea
ON [CONTROL].AVION(idAeroLinea);

EXEC sp_helpindex RESERVA;
CREATE NONCLUSTERED INDEX inx_reserva_pasajero
ON [CHECKIN].RESERVA(idPasajero);
CREATE NONCLUSTERED INDEX inx_reserva_vuelo
ON [CHECKIN].RESERVA(idVuelo);
--11. Consulta los índices que tiene cada tabla.
EXEC sp_helpindex AEROLINEA
EXEC sp_helpindex AEROPUERTO
EXEC sp_helpindex AVION
EXEC sp_helpindex PAIS
EXEC sp_helpindex PASAJERO
EXEC sp_helpindex RESERVA
EXEC sp_helpindex VUELO
--12. Consulta los índices que tiene toda la base de datos
SELECT
	Tab.name as [Tabla],
	IX.name as [Nombre indice],
	IX.type_desc as [Tipo indice],
	Col.name as [Columnas del indice],
	IXC.is_included_column AS [Columnas incluidas]
FROM SYS.indexes IX
INNER JOIN SYS.index_columns IXC ON (IX.object_id=IXC.object_id AND IX.index_id=IXC.index_id)
INNER JOIN SYS.columns COL ON (IX.object_id=COL.object_id AND IXC.column_id= COL.column_id)
INNER JOIN SYS.tables TAB ON (IX.object_id=TAB.object_id)
--13. Consulta los objetos que tiene cada esquema
--CAMBIAR LAS TABLAS DE ESQUEMAS
ALTER SCHEMA [CONTROL] TRANSFER [dbo].[AEROLINEA]
ALTER SCHEMA [CONTROL] TRANSFER [dbo].[AVION]
ALTER SCHEMA [CONTROL] TRANSFER [dbo].[VUELO]
ALTER SCHEMA [CONTROL] TRANSFER [dbo].[AEROPUERTO]
--
ALTER SCHEMA CHECKIN TRANSFER [dbo].[PAIS]
ALTER SCHEMA CHECKIN TRANSFER [dbo].[PASAJERO]
ALTER SCHEMA CHECKIN TRANSFER [dbo].[RESERVA]
--
--14. Verifica el índice de fragmentación de los índices de la tabla de vuelos y
--reorganízalo o reconstrúyelo.
SELECT OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name,
	IDX.name AS Index_Name,
	IDXPS.index_type_desc AS Index_Type,
	IDXPS.avg_fragmentation_in_percent AS
	Fragmentation_Percentage
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL,NULL, NULL, NULL) IDXPS
INNER JOIN sys.indexes IDX ON IDX.object_id = IDXPS.object_id AND IDX.index_id = IDXPS.index_id
ORDER BY Fragmentation_Percentage DESC
--15. Verificar los roles y usuarios creados utilizando comandos del sistema sp_helpuser
--y sp_helprolemember y-o consulta select para ver los miembros de cada role.
EXEC sp_helpuser
EXEC sp_helprolemember
--16. Conectarse al servidor usando cada uno de los logins creados y comprobar que los
--permisos funcionan correctamente (realizando consultas, inserciones o
--actualizaciones).
EXEC AS USER = 'usuario_gerente'
SELECT * FROM CHECKIN.PAIS
INSERT INTO CHECKIN.PAIS(nombre) VALUES('Argentina')
UPDATE CHECKIN.PAIS SET nombre='Argentina' WHERE idPais=1
DELETE FROM CHECKIN.PAIS WHERE Nombre='Argentina'
REVERT
--
EXEC AS USER= 'usuario_operativo'
SELECT * FROM CHECKIN.PASAJERO
INSERT INTO CHECKIN.PASAJERO(nombre) VALUES('Juan Perez')
UPDATE CHECKIN.PASAJERO SET nombre='Juan Perez' WHERE idPasajero=1
DELETE FROM CHECKIN.PASAJERO WHERE nombre='Juan Perez'
REVERT
--
EXEC AS USER= 'usuario_consulta'
SELECT * FROM CONTROL.AEROPUERTO
INSERT INTO CONTROL.AEROPUERTO(nombre) VALUES('Aeropuerto Internacional de la Ciudad de Mexico')
UPDATE CONTROL.AEROPUERTO SET nombre='Aeropuerto Internacional de la Ciudad de Mexico' WHERE idAeropuerto=1
DELETE FROM CONTROL.AEROPUERTO WHERE nombre='Aeropuerto Internacional de la Ciudad de Mexico'
REVERT
--17. Registrar las acciones realizadas por cada usuario y anotar qué operaciones tuvo

--permitido realizar y cuáles no.
--usuario_gerente: pudo realizar todas las operaciones (SELECT, INSERT, UPDATE, DELETE) en la tabla CHECKIN.PAIS sin restricciones.
--usuario_operativo: pudo realizar todas las operaciones (SELECT, INSERT, UPDATE, DELETE) en la tabla CHECKIN.PASAJERO sin restricciones.
--usuario_consulta: solo pudo realizar la operación SELECT en la tabla CONTROL.AEROPUERTO, las operaciones de INSERT, UPDATE y DELETE no fueron permitidas.


ALTER TABLE CHECKIN.RESERVA DROP CONSTRAINT FK_RESERVA_PASAJERO
ALTER TABLE CHECKIN.PASAJERO DROP CONSTRAINT [PK__PASAJERO__78E232CBD3197299]

ALTER TABLE CHECKIN.PASAJERO ADD CONSTRAINT PK_PASAJERO  PRIMARY KEY NONCLUSTERED (idPasajero)
CREATE CLUSTERED INDEX inx_pasajero_nom ON CHECKIN.PASAJERO(NOMBRE)

EXEC sp_helpindex [CHECKIN.PASAJERO]

ALTER TABLE CHECKIN.RESERVA ADD CONSTRAINT FK_RESERVA_PASAJERO FOREIGN KEY (idPasajero) REFERENCES CHECKIN.PASAJERO(idPasajero)
