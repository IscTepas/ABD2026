-- PRACTICA 4
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--09/03/26

--Practica 4. BD DesarrolloPersonal
/*
El ITTEPIC necesita una bd llamada Desarrollo del Personal en donde almacenara los
cursos, diplomados, talleres, instructores, manuales, participantes, entre otros para llevar
el registro y control de los cursos de capacitación que les da cada semestre a los profesores
y personal administrativo de la institución. Solo debes hacer la creación de roles y creación
de usuario 1 con sa (usuario dbo)
*/
--1. Crea la base de datos
CREATE DATABASE DesarrolloPersonal
ON PRIMARY
(
NAME = 'DesarrolloPersonal', 
FILENAME = 'C:\ABD2026\UNIDAD 3\DesarrolloPersonal.mdf'
)
LOG ON 
(
NAME = 'DesarrolloPersonal_LOG', 
FILENAME = 'C:\ABD2026\UNIDAD 3\DesarrolloPersonal.ldf'
)
USE DesarrolloPersonal
GO
--2. Crea tres roles:
/*El primero: es un rol que puede hacer respaldos, modificaciones al esquema de la
bd, realizar consultas en la bd, crear usuarios(logins).*/
CREATE ROLE ROL1
GRANT BACKUP DATABASE TO ROL1
GRANT CREATE TABLE TO ROL1
GRANT ALTER ANY SCHEMA TO ROL1
GRANT SELECT TO ROL1
GRANT ALTER ANY USER TO ROL1
--• El segundo: solo puede consultar, insertar, actualizar y eliminar registros.
CREATE ROLE ROL2
GRANT SELECT,INSERT,UPDATE,DELETE TO ROL2
---• El tercero : solo podrá consultar
CREATE ROLE ROL3
GRANT SELECT TO ROL3
--3. Crear un usuario y agrégalo al rol 1.
CREATE LOGIN LOGIN1 WITH PASSWORD='1234'
CREATE USER USER1 FOR LOGIN LOGIN1
ALTER ROLE ROL1 ADD MEMBER USER1
--4. Conéctate con el usuario que pertenece al rol 1 y realiza lo siguiente:
GRANT ALTER ANY LOGIN TO LOGIN1
--a) Crear un usuario y lo agregas al rol 2
CREATE LOGIN LOGIN2 WITH PASSWORD='1234'
CREATE USER USER2 FOR LOGIN LOGIN2
ALTER ROLE ROL2 ADD MEMBER USER2
--b) Crear un usuario y lo agregas al rol 3.
CREATE LOGIN LOGIN3 WITH PASSWORD='1234'
CREATE USER USER3 FOR LOGIN LOGIN3
ALTER ROLE ROL3 ADD MEMBER USER3
GO
--c) Crea los Esquemas: CATALOGOS, PARTICIPANTES, IMPARTIDOS
CREATE SCHEMA CATALOGOS
GO
CREATE SCHEMA PARTICIPANTES
GO
CREATE SCHEMA IMPARTIDOS
GO
CREATE SCHEMA DIPLOMADOS
GO
--d) Crea Tablas:
CREATE TABLE CATALOGOS.CURSOS
( CUR_ID INT IDENTITY(1,1) PRIMARY KEY,
 CUR_NOMBRE VARCHAR(50),
 CUR_DESCRIPTICION VARCHAR(300),
 INT_ID INT
 );
CREATE TABLE CATALOGOS.TALLER
( TAR_ID INT IDENTITY(1,1) PRIMARY KEY,
 TAR_NOMBRE VARCHAR(50),
 TAR_DESCRIPTICION VARCHAR(300),
 INT_ID INT
 );
CREATE TABLE CATALOGOS.DIPLOMADOS
( DIP_ID INT IDENTITY(1,1) PRIMARY KEY,
 DIP_NOMBRE VARCHAR(50),
 DIP_DESCRIPTICION VARCHAR(300),
 INT_ID INT
 );
CREATE TABLE MANUALES
( MANUAL_ID INT IDENTITY(1,1) PRIMARY KEY,
 ID_CUDIPTA VARCHAR(50), --FK PARA CUALQUIER TIPO CURSO, TALLER ,
 MANUAL_URL VARCHAR(150)
);
CREATE TABLE PARTICIPANTES.CURSOSABIERTOS
( IMP_ID INT PRIMARY KEY,
 ID_CUDIPTA VARCHAR(50), --FK PARA CUALQUIER TIPO CURSO, TALLER ,
 IMP_FECHAINI DATE,
 IMP_FECHAFIN DATE,
 );
CREATE TABLE INSTRUCTORES
( INT_ID INT IDENTITY(1,1) PRIMARY KEY,
 INT_NOMBRE VARCHAR(50),
 INT_PROFESION VARCHAR(30) );
CREATE TABLE DIPLOMADOS.LISTAS
( LIS_ID INT PRIMARY KEY,
 IMP_ID INT,
 ID_TRAB INT,
 LIS_ESTATUS CHAR(1));
CREATE TABLE TRABAJADOR
(ID_TRAB INT PRIMARY KEY,
 NOMBRE_TRAB VARCHAR(100),
 DEPTO_TRAB VARCHAR(60)
);
--f) Cambia las tablas que quedaron en diferente esquema al diagrama.
ALTER SCHEMA CATALOGOS TRANSFER dbo.MANUALES;
ALTER SCHEMA CATALOGOS TRANSFER dbo.INSTRUCTORES;
ALTER SCHEMA CATALOGOS TRANSFER dbo.TRABAJADOR;
ALTER SCHEMA IMPARTIDOS TRANSFER DIPLOMADOS.LISTAS;
--g) Consultar en que esquemas quedaron cada tabla mostrando el esquema, el objeto
SELECT O.name AS 'TABLA', S.name AS 'ESQUEMA', U.name AS 'PROPIETARIO'
FROM SYS.objects O
INNER JOIN SYS.schemas S ON (O.schema_id=S.schema_id)
INNER JOIN SYS.sysusers U ON (U.uid=S.principal_id)
WHERE TYPE='U'
ORDER BY S.name
--h) Ponga diferentes esquemas por default a cada usuario.
ALTER USER USER1 WITH DEFAULT_SCHEMA = CATALOGOS;
ALTER USER USER2 WITH DEFAULT_SCHEMA = PARTICIPANTES;
ALTER USER USER3 WITH DEFAULT_SCHEMA = IMPARTIDOS;
GO
--5. Conéctate con el usuario correspondiente de acuerdo a los permisos asignados Inserte,
--modifique y borre al menos dos registros en distintas tablas.
--INSERTAR
INSERT INTO CATALOGOS.INSTRUCTORES (INT_NOMBRE, INT_PROFESION) 
VALUES ('Alan Turing', 'Matemático'), 
       ('Ada Lovelace', 'Programadora');
INSERT INTO CATALOGOS.TRABAJADOR (ID_TRAB, NOMBRE_TRAB, DEPTO_TRAB) 
VALUES (1, 'Juan Perez', 'Sistemas'), 
       (2, 'Maria Lopez', 'Recursos Humanos');
--MODIFICAR
UPDATE CATALOGOS.INSTRUCTORES 
SET INT_PROFESION = 'Científico de la Computación' 
WHERE INT_NOMBRE = 'Alan Turing';
UPDATE CATALOGOS.TRABAJADOR 
SET DEPTO_TRAB = 'TI' 
WHERE ID_TRAB = 1;
--BORRAR
DELETE FROM CATALOGOS.INSTRUCTORES WHERE INT_NOMBRE = 'Ada Lovelace';
DELETE FROM CATALOGOS.TRABAJADOR WHERE ID_TRAB = 2;
GO
--6. Conéctate con el usuario correspondiente y consulta los registros de cada tabla y realiza
--al menos dos consultas más con INNER JOIN y WHERE, tu decides cuales.
SELECT * FROM CATALOGOS.INSTRUCTORES;
SELECT * FROM CATALOGOS.TRABAJADOR;
SELECT C.CUR_NOMBRE, C.CUR_DESCRIPTICION, I.INT_NOMBRE, I.INT_PROFESION
FROM CATALOGOS.CURSOS C
INNER JOIN CATALOGOS.INSTRUCTORES I ON C.INT_ID = I.INT_ID
WHERE I.INT_PROFESION LIKE '%Computación%';
--
SELECT L.LIS_ESTATUS, T.NOMBRE_TRAB, T.DEPTO_TRAB
FROM IMPARTIDOS.LISTAS L
INNER JOIN CATALOGOS.TRABAJADOR T ON L.ID_TRAB = T.ID_TRAB
WHERE T.DEPTO_TRAB = 'TI';
GO

--7. Regresa a SA y consulta cuantos usuarios hay en cada rol.
SELECT 
    dp1.name AS Nombre_Rol, 
    COUNT(drm.member_principal_id) AS Cantidad_Usuarios
FROM sys.database_role_members drm
INNER JOIN sys.database_principals dp1 ON drm.role_principal_id = dp1.principal_id
WHERE dp1.type = 'R' 
GROUP BY dp1.name;
GO
--8. Genere el diagrama de la bd (dbo)
ALTER AUTHORIZATION ON DATABASE::DesarrolloPersonal TO sa;
--9. Describe como quedo la bd con comentarios con los resultados de las consultas cuales
--esquemas hay, a que esquema pertenece cada tabla, los usuarios creados, los roles y los
--miembros.
--10. Consulta los índices de la base de datos mostrando el esquema, nombre de objeto, 
--nombre de índice y tipo de índice 

--11. Consulta los porcentajes de fragmentación de los índices 

--12. Reconstruye al menos dos índices y reorganiza dos. 
insert into CATALOGOS.CURSOS (CUR_NOMBRE, CUR_DESCRIPTICION, INT_ID) values ('Curso de SQL', 'Aprende SQL desde cero', 1);


