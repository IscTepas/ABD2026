--PRACTICA 2
--UNIDAD 3
--NUÑEZ CARVAJAL JOSE TADEO
--06/03/2026
USE AdventureWorks2022
GO
--10. Probar Accesos crea un query para cada usuario
--Caso 4: userTI debe poder insertar registros en Auditoria.LogCambios.
SELECT * FROM Auditoria.LogCambios;

INSERT INTO AUDITORIA.LogCambios(TablaAfectada,UsuarioBD,TipoOperacion)
VALUES('PRUEBA SEGURIDAD','USERIT','INSERT')
