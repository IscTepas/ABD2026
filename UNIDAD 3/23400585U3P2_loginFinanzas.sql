--PRACTICA 2
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--06/03/2026
USE AdventureWorks2022
GO
--10. Probar Accesos crea un query para cada usuario
--Caso 3: userFinanzas debe poder consultar información financiera pero no
--modificar registros.
SELECT * FROM Production.BillOfMaterials;

SELECT * FROM Production.Culture;
--
UPDATE Production.Culture SET [Name] = 'Prueba' WHERE CultureID='en';
