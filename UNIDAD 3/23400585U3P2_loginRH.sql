--PRACTICA 2
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--06/03/2026
USE AdventureWorks2022
GO
--10. Probar Accesos crea un query para cada usuario
--Caso 2: userRH debe poder consultar y modificar datos de Employee.
SELECT * FROM HumanResources.Employee
UPDATE HumanResources.Employee SET JobTitle=JobTitle
WHERE BusinessEntityID=1