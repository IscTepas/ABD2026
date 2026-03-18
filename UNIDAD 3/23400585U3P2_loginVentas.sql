--PRACTICA 2
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--06/03/2026
USE AdventureWorks2022
GO
--10. Probar Accesos crea un query para cada usuario
--Caso 1: userVentas debe poder consultar tablas de Sales pero no HumanResources.
SELECT * FROM Sales.CountryRegionCurrency;
SELECT * FROM Sales.CurrencyRate;
SELECT * FROM Sales.Currency;

SELECT * FROM HumanResources.Employee;
--11. Revocar Permisos
--2. Verificar nuevamente si el usuario userVentas puede consultar la información.
SELECT * FROM SALES.Store