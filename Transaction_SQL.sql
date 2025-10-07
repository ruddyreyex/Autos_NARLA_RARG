use Autos_Narla_Ruddy;


Begin transaction;

begin try
declare @Id_Vehiculo Varchar(505) = 'MT4623682';
declare @Precio Decimal(10,2) = 8800.00;
declare @Descuento Decimal(10,2) = 5;
declare @Cliente varchar(100) = 'Carlos López';
declare @FormaPago varchar(50) = 'Efectivo';
declare @Nota varchar(max) = 'Compra realizada sin observaciones';

--INSERTAR LAS VENTAS
INSERT INTO Ventas (Id_Vehiculo, Fecha_Venta, Precio_Venta, Descuento, Nombre_Cliente, Forma_Pago, Nota)
VALUES (@Id_Vehiculo, GETDATE(), @Precio, @Descuento, @Cliente, @FormaPago, @Nota);


--ACTUALIZAR EL STOCK DEL VEHICULO
UPDATE Vehiculos
SET en_Stock = 0
WHERE Id_Vehiculo = @Id_Vehiculo;

COMMIT TRANSACTION;
PRINT 'Venta registrada y vehículo actualizado correctamente.';
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
PRINT 'Error detectado. Se ha revertido la transacción.';
END CATCH;


--INSERTAR VEHICULOS QUE SEAN MARCAS CLASICAS
BEGIN TRANSACTION;

BEGIN TRY
INSERT INTO Vehiculos (Id_Vehiculo, Id_Marca, Modelo, Año_Vehiculo, Año_Produccion, Numero_Chasis, Tipo_Combustible, Cilindraje, Id_Tipo, Precio_Compra, Precio_Venta, es_Clasico, Observaciones)
VALUES ('ERR123456', 5, 'Civic', 2020, 2020, 'CH12345', 'Gasolina', 4, 1, 5000, 8000, 1, 'Prueba de rollback');

COMMIT TRANSACTION;
PRINT 'Vehículo insertado correctamente.';
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
PRINT 'Error: Marca no registrada como clásica. Transacción revertida.';
END CATCH;



BEGIN TRANSACTION;

DECLARE @PrecioCompra DECIMAL(10,2) = 7000;
DECLARE @PrecioVenta DECIMAL(10,2) = 6500;

INSERT INTO Vehiculos (Id_Vehiculo, Id_Marca, Modelo, Año_Vehiculo, Año_Produccion, Numero_Chasis, Tipo_Combustible, Cilindraje, Id_Tipo, Precio_Compra, Precio_Venta, Observaciones)
VALUES ('CHK001', 3, 'Focus', 2023, 2023, 'XX987654', 'Gasolina', 6, 1, @PrecioCompra, @PrecioVenta, 'Inserción condicional con verificación.');

-- VALIDACIÓN DEL PRECIO COMPRA Y VENTA DEL VEHICULO
IF (@PrecioVenta < @PrecioCompra)
BEGIN
    PRINT 'El precio de venta es menor que el de compra. Cancelando transacción...';
    ROLLBACK TRANSACTION;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Vehículo agregado correctamente.';
END

SELECT * FROM Ventas WHERE Nombre_Cliente = 'Carlos López';
