--PRACTICA 6
--NUÑEZ CARVAJAL JOSE TADEO
--13/03/26
--1. Crear la BDParticiones 
SELECT * FROM REPORTS R
INNER JOIN ReportPhoto F ON (F.IdReport = R.IdReport)
WHERE R.IdReport BETWEEN 100 AND 1670
CREATE DATABASE BDPARTICIONES
ON PRIMARY
(
NAME ='BDPARTICIONES.MDF',
FILENAME='C:\ABD2026\UNIDAD 3\BDPARTICIONES.mdf'
)
LOG ON
(
NAME ='BDPARTICIONES_LOG',
FILENAME = 'C:\ABD2026\UNIDAD 3\BDPARTICIONES.ldf'
)
GO
USE BDPARTICIONES
--
--2. Crear tres  tablas: 
CREATE TABLE Departament 
(idDepartament CHAR(5) PRIMARY KEY, 
DepartamentName VARCHAR(100) 
); 
CREATE TABLE Reports 
(IdReport  int identity(1,1) PRIMARY KEY, 
ReportDate date  not null default getdate(), 
ReportName varchar (100), 
ReportNumber varchar (20), 
ReportDescription varchar (max), 
idDepartament CHAR(5) FOREIGN KEY  
REFERENCES Departament(idDepartament) 
) 
CREATE TABLE ReportPhoto 
( 
IdReport  int PRIMARY KEY, 
ReportPhoto VARCHAR(200), 
FOREIGN KEY (idReport) 
REFERENCES Reports(idReport) 
); 
GO
--
EXEC sp_helpindex 'Reports'
--PK__Reports__46F9D6CEEEEEE295
--CLUSTERED 
--3. Inserta dos departamentos : A001 Informatica  y A002 Gerencia 
INSERT INTO Departament VALUES ('A001','Informatica')
--
INSERT INTO Departament VALUES ('A002','Gerencia')
--4. Llenar la tabla Reports con el sp que se te paso 
EXEC sp_insert_reports;

SELECT * FROM Departament;
select * from reports;

-- 5. Llenar la tabla ReportPhoto con un INSERT – SELECT sacando el id de la tabla
-- reports y poniendo fijo una ruta y no nombre de imagen.
INSERT INTO ReportPhoto
SELECT idReport, 'C:\ABD2026\imagen.png'
FROM Reports;

SELECT COUNT(*) AS TotalReports FROM Reports;
SELECT * FROM Reports;

-- 6. Consultar la tabla y verificar que se hayan insertado, usar en la consulta las
-- estadísticas para poder ver el tiempo que dura la consulta, anotar en el query

SET STATISTICS IO ON
SET STATISTICS TIME ON
SELECT * FROM REPORTS
WHERE ReportName LIKE '%33%'
SET STATISTICS IO OFF
SET STATISTICS TIME OFF

/*
(5982 rows affected)
Table 'Reports'. Scan count 1, logical reads 150559, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

(2 rows affected)

(1 row affected)

 SQL Server Execution Times:
   CPU time = 485 ms,  elapsed time = 1174 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

Completion time: 2026-03-18T11:01:53.3863129-07:00

*/


-- 7. Verificar los años distintos de las fechas de los reportes y consultar cuantos
-- registros existen de cada año, anótalo en el query.

SELECT DISTINCT(YEAR(ReportDate)) AS ReportYear 
FROM REPORTS
ORDER BY YEAR(ReportDate);

SELECT COUNT(*) AS TotalReports, YEAR(ReportDate) AS ReportYear
FROM REPORTS
GROUP BY YEAR(ReportDate)
ORDER BY YEAR(ReportDate);
/*
28000	2023
39000	2024
81300	2025
1700	2026
*/
--8. Particionar la tabla por el año y usando una tabla como puente (crearla igual
--que la tabla reports pero sin identitiy)
--8.1 Crear la tabla puente
ALTER DATABASE BDPARTICIONES
ADD FILEGROUP PART2023
ALTER DATABASE BDPARTICIONES
ADD FILEGROUP PART2024
ALTER DATABASE BDPARTICIONES
ADD FILEGROUP PART2025
ALTER DATABASE BDPARTICIONES
ADD FILEGROUP PART2026
--
SELECT NAME AS AVAILABLEFILEGROUPS
FROM SYS.FILEGROUPS
WHERE TYPE='FG'
USE MASTER
--8.2 CREAR DATA FILES PARA CADA FILEGROUP
ALTER DATABASE BDPARTICIONES
ADD FILE (
NAME='PARTICION2023.1.NDF',
FILENAME='C:\ABD2026\UNIDAD 3\DISCOD\PARTICION2023.NDF')
TO FILEGROUP PART2023
--
ALTER DATABASE BDPARTICIONES
ADD FILE (
NAME='PARTICION2024.1.NDF',
FILENAME='C:\ABD2026\UNIDAD 3\DISCOE\PARTICION2024.NDF')
TO FILEGROUP PART2024
--
ALTER DATABASE BDPARTICIONES
ADD FILE (
NAME='PARTICION2025.1.NDF',
FILENAME='C:\ABD2026\UNIDAD 3\DISCOF\PARTICION2025.NDF')
TO FILEGROUP PART2025
--
ALTER DATABASE BDPARTICIONES
ADD FILE (
NAME='PARTICION2026.1.NDF',
FILENAME='C:\ABD2026\UNIDAD 3\DISCOG\PARTICION2026.NDF')
TO FILEGROUP PART2026
--CONSULTAR LOS FILEGROUPS Y DATAFILES CREADOS
SELECT NAME AS 'FILENAME',
PHYSICAL_NAME AS 'PHYSICAL NAME'
FROM SYS.DATABASE_FILES
WHERE TYPE_DESC='ROWS'
--8.3 Crear la funcion de particion
CREATE PARTITION FUNCTION F_PARTITIONDATE (DATE)
AS RANGE LEFT FOR VALUES ('2023-12-31','2024-12-31','2025-12-31')
--8.4 Crear el esquema de partición
CREATE PARTITION SCHEME PS_PARTITIONDATE
AS PARTITION F_PARTITIONDATE TO (PART2023, PART2024, PART2025, PART2026)
--8.5 
CREATE TABLE Reports_PARTICIONADA 
(IdReport  int PRIMARY KEY NONCLUSTERED, 
ReportDate date  not null default getdate(), 
ReportName varchar (100), 
ReportNumber varchar (20), 
ReportDescription varchar (max), 
idDepartament CHAR(5)
) 
CREATE CLUSTERED INDEX IX_REPORTS_PARTICIONADA ON Reports_PARTICIONADA (ReportDate)
ON PS_PARTITIONDATE(ReportDate)
--
EXEC sp_helpindex 'Reports_PARTICIONADA'
GO
-- VACIAR LOS DATOS DE LA TABLA REPORTS
INSERT INTO Reports_PARTICIONADA 
SELECT * FROM Reports;
--
SELECT COUNT(*) AS TotalReports FROM Reports_PARTICIONADA;
--DROPERAR TABLA REPORTS
--PRIMERO VERIFICAR SI TIENE TABLAS HIJAS
--SI TIENE: QUITAR FK DE LAS TABLAS HIJAS
--HIJAS
--RENOMBRAR LA TABLA PARTICIONADA A REPORTS
--REGRESAR CONSTRAINT

--9. Verificar que se hayan creado los filegrops, datafailes, esquemas de partición,
--función de partición

--10. Verificar que las particiones hayan quedado bien de acuerdo a los resultados del
--punto 7
--11. Renombrar la tabla para quede la bd como originalmente estaba y agregar todo
--lo que haga falta para que la bd quede igual
--12. Consultar de nuevo la tabla y las estadísticas y comparar con la consulta anterior,
--anotar comentarios en el query.
--13. Inserta 4 registros en el 2024 y 3 en el 2025
--14. Vuelve a verificar las particiones y checa que los registros queden en donde
--corresponden.