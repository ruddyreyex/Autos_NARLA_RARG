use Autos_Narla_Ruddy;

--MARCAS
--Consulta general Marcas
CREATE PROCEDURE sp_Marcas_Consultar_Todas
AS
BEGIN
SELECT * FROM Marcas;
END;
GO

--Consulta por nombre
CREATE PROCEDURE sp_Marcas_Buscar_PorNombre
@Nombre NVARCHAR(100)
AS
BEGIN
SELECT * FROM Marcas
WHERE Nombre_Marca LIKE '%' + @Nombre + '%';
END;
GO

--Actualizar
CREATE PROCEDURE sp_Marcas_Actualizar
@Id_Marca INT,
@NuevoNombre NVARCHAR(100)
AS
BEGIN
UPDATE Marcas
SET Nombre_Marca = @NuevoNombre
WHERE Id_Marca = @Id_Marca;
END;
GO


--VEHICULOS
--Consulta general Vehiculos
CREATE PROCEDURE sp_Vehiculos_Consultar_Todos
AS
BEGIN
SELECT * FROM Vehiculos;
END;
GO

--Parametro por rango de precio
CREATE PROCEDURE sp_Vehiculos_Buscar
@Id_Marca INT = NULL,
@PrecioMin DECIMAL(10,2) = NULL,
@PrecioMax DECIMAL(10,2) = NULL
AS
BEGIN
SELECT * FROM Vehiculos
WHERE (@Id_Marca IS NULL OR Id_Marca = @Id_Marca)
AND (@PrecioMin IS NULL OR Precio_Venta >= @PrecioMin)
AND (@PrecioMax IS NULL OR Precio_Venta <= @PrecioMax);
END;
GO


--ACTUALIZACIÓN DE PRECIOS Y OBSERVACIONES
CREATE PROCEDURE sp_Vehiculos_Actualizar
@Id_Vehiculo VARCHAR(505),
@NuevoPrecio DECIMAL(10,2),
@NuevaObs NVARCHAR(MAX)
AS
BEGIN
UPDATE Vehiculos
SET Precio_Venta = @NuevoPrecio,
Observaciones = @NuevaObs
WHERE Id_Vehiculo = @Id_Vehiculo;
END;
GO

--VEHICULOS DISPONIBLES
SELECT 
COUNT(*) AS Total_En_Stock
FROM Vehiculos
WHERE en_Stock = 1;


--PRECIOS DE LOS VEHICULOS
SELECT 
AVG(Precio_Venta) AS Promedio_Precio,
MAX(Precio_Venta) AS Precio_Maximo,
MIN(Precio_Venta) AS Precio_Minimo
FROM Vehiculos;


--MARCAS CON MAS EXISTENCIA
SELECT 
m.Nombre_Marca,
COUNT(v.Id_Vehiculo) AS Cantidad_Vehiculos
FROM Vehiculos v
INNER JOIN Marcas m ON v.Id_Marca = m.Id_Marca
GROUP BY m.Nombre_Marca
ORDER BY Cantidad_Vehiculos DESC;


--TOTAL DE DINERO RECOGIDOS POR VENTAS VEHICULOS
SELECT 
SUM(Precio_Venta - (Precio_Venta * (Descuento / 100))) AS Total_Ingresos
FROM Ventas;


--PROMEDIO DE DESCUENTOS
SELECT 
    AVG(Descuento) AS Promedio_Descuento
FROM Ventas;