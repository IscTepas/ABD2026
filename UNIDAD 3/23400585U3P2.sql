--PRACTICA 2
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--06/03/2026
USE AdventureWorks2022
GO
--1. Consulta cuantos y cuales esquemas tiene la BD y ponlo en comentarios en el query
SELECT COUNT(*) AS [N. de esquemas], S.[name] AS [Esquema]
FROM sys.objects O
INNER JOIN sys.schemas S ON (O.schema_id = S.schema_id)
GROUP BY S.[name];
/*
N. de esquemas	Esquema
157	Sales
70	Person
165	Production
29	dbo
134	sys
48	HumanResources
59	Purchasing
*/
--2. Realiza un select * a una tabla de cada esquema
SELECT * FROM HumanResources.Department
SELECT * FROM Person.Person
SELECT * FROM Production.[Product]
SELECT * FROM Purchasing.Vendor
SELECT * FROM Sales.Store
--3. Crear 4 logins con los siguientes nombres: loginVentas, loginRH, loginFinanzas y loginTI.
CREATE LOGIN loginVentas WITH PASSWORD='1234'
CREATE LOGIN loginRH WITH PASSWORD='1234'
CREATE LOGIN loginFinanzas WITH PASSWORD='1234'
CREATE LOGIN loginTI WITH PASSWORD='1234'
--4. Crear Usuarios en dentro de la base de datos AdventureWorks crear los siguientes
--usuarios asociados a los logins:
--loginVentas → userVentas
CREATE USER userVentas FOR LOGIN loginVentas
--loginRH → userRH
CREATE USER userRH FOR LOGIN loginRH
--loginFinanzas → userFinanzas
CREATE USER userFinanzas FOR LOGIN loginFinanzas
--loginTI → userTI
CREATE USER userTI FOR LOGIN loginTI
GO
--5. Crear dos nuevos schemas dentro de la base de datos: Auditoria y Reportes
CREATE SCHEMA Auditoria
GO
CREATE SCHEMA Reportes
GO
--6. Crear Tablas en Schemas:
--Tabla 1: Schema: Auditoria Nombre: LogCambios
--Campos:
--IdLog – entero autoincremental
--TablaAfectada – varchar
--UsuarioBD – varchar
--FechaCambio – datetime
--TipoOperacion – varchar
CREATE TABLE Auditoria.LogCambios(
	IdLog INT IDENTITY(1,1) PRIMARY KEY,
	TablaAfectada VARCHAR(50),
	UsuarioBD  VARCHAR(50),
	FechaCambio DATETIME DEFAULT GETDATE(),
	TipoOperacion varchar (50)
)
--Tabla 2: Schema: Reportes Nombre: ReporteVentas
--Campos:
--IdReporte – entero autoincremental
--FechaReporte – datetime
--TotalVentas – money
--UsuarioGenera – varchar
CREATE TABLE Reportes.ReporteVentas (
    IdReporte INT IDENTITY(1,1) PRIMARY KEY,
    FechaReporte DATETIME DEFAULT GETDATE(),
    TotalVentas MONEY,
    UsuarioGenera VARCHAR(50)
);
--7. Crearr 4 roles personalizados en la base de datos: rolVentas, rolRH, rolFinanzas,rolTI
CREATE ROLE rolVentas
CREATE ROLE rolRH
CREATE ROLE rolFinanzas
CREATE ROLE rolTI
--8. Asignar los Usuarios a Roles a su rol correspondiente.
EXEC sp_addrolemember rolVentas,userVentas
EXEC sp_addrolemember rolRH,userRH
EXEC sp_addrolemember rolFinanzas,userFinanzas
EXEC sp_addrolemember rolTI,userTI
--9. Asignar Permisos:
--Rol Ventas 
--Permitir consultar todas las tablas del schema Sales.
--No debe poder modificar información.
GRANT SELECT ON SCHEMA::SALES TO ROLVENTAS
DENY INSERT,UPDATE, DELETE ON SCHEMA::SALES TO ROLVENTAS
--Rol Recursos Humanos
--Permitir en la tabla HumanResources.Employee los permisos:
--SELECT
--INSERT
--UPDATE
GRANT SELECT, INSERT, UPDATE ON HUMANRESOURCES.EMPLOYEE TO ROLRH
GO
--Rol Finanzas
--Permitir SELECT sobre todas las tablas del schema Finance.
CREATE SCHEMA FINANCE
GO
GRANT SELECT ON SCHEMA::FINANCE TO rolFinanzas
--Rol TI—con roles predefinidos
--Lectura y Escritura en toda la BD
--Debe poder crear, alter y eliminar tablas
--Crear usuarios y logins  
EXEC sp_addrolemember db_datawriter,rolTI;
EXEC sp_addrolemember db_ddladmin,rolTI;
EXEC sp_addrolemember db_ddladmin,rolTI;
EXEC sp_addrolemember db_accessadmin,rolTI;
EXEC sp_addsrvrolemember loginTI, securityadmin;

--11. Revocar Permisos
--1. Revocar el permiso SELECT al rol rolVentas sobre el schema Sales.
REVOKE SELECT ON SCHEMA::SALES TO ROLVENTAS
--2. Verificar nuevamente si el usuario userVentas puede consultar la información.
--12. Mostrar esquemas, mostrar roles y mostrar miembros
SELECT s.[name] AS Esquema
FROM Sys.schemas S
EXEC sp_helprole;
EXEC sp_helprolemember;
