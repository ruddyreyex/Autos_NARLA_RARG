create database Autos_Narla_Ruddy;

use Autos_Narla_Ruddy;

select * from Vehiculos;

Create table marcas (
Id_Marca int identity primary key,
Nombre_Marca varchar(100) not null unique
);

create table tipo_vehiculo(
Id_Tipo int identity primary key,
Nombre_Tipo varchar(100) not null unique
);

Create table marcas_clasicas (
Id_Clasico Int identity primary key,
Id_Marca Int not null,
constraint Fk_Id_Marca foreign key (Id_Marca) references marcas (Id_Marca)
);

Create table Vehiculos(
Id_Vehiculo varchar(505) not null primary key,
Id_Marca int not null,
Modelo varchar(50) not null,
Año_Vehiculo int not null check (Año_Vehiculo > 1900 and Año_Vehiculo <= YEAR(GETDATE())),
Año_Produccion int not null check (Año_Produccion > 1900 and Año_Produccion <= YEAR(GETDATE())),
Numero_Chasis varchar (50) unique,
Tipo_Combustible varchar (50),
Cilindraje int check (Cilindraje >=0),
Id_Tipo int not null,
Precio_Compra Decimal (10,2) check (Precio_Compra >=0),
Precio_Venta Decimal (10,2) check (Precio_Venta >=0),
es_Clasico Bit Default 0,
en_Stock Bit Default 1,
Fecha_Ingreso datetime default getdate(),
Observaciones Varchar(MAX),
Constraint fk_Vehiculos_TipoVehiculo foreign key (Id_Tipo) references tipo_vehiculo (Id_Tipo)
);

Create table Fotos_Vehiculos(
Id_Foto int identity primary key,
Id_Vehiculo varchar (505) not null,
Ruta varchar (255) not null,
Orden smallint not null check (Orden >=1 and Orden <=6)
constraint fk_FotoVehiculo_Vehiculos foreign key (Id_Vehiculo) references Vehiculos (Id_Vehiculo)
);

Create table Ventas(
Id_Venta int identity primary key,
Id_Vehiculo varchar(505) not null,
Fecha_Venta datetime,
Precio_Venta Decimal (10,2) not null check (Precio_Venta >=0),
Descuento Decimal (10,2) default 0 check (Descuento >=0 and Descuento <=10),
Nombre_Cliente varchar (100),
Forma_Pago varchar(50),
Nota varchar(max),
constraint fk_Ventas_Vehiculos foreign key (Id_Vehiculo) references Vehiculos (Id_Vehiculo)
);


--Validar si el vehiculo es clasico
Go
create trigger TRG_Validar_Clasico
On Vehiculos
after insert, update
As
Begin
If exists(
select 1 from inserted i
where i.es_Clasico = 1
and not exists (select 1 from marcas_clasicas mc where mc.Id_Marca = i.Id_Marca)
)
begin 
Raiserror ('Marca no registrada',16,1);
rollback transaction;
end
end;
Go


--Validar el maximo de unidades, es de 4 unidades por vehiculo
Go
Create trigger TRG_Validar_MaxUnidades
on Vehiculos
instead of insert 
as
begin
if exists(
select 1 from inserted i
cross apply(
select COUNT (*) as cnt
from Vehiculos v
where v.en_Stock = 1
and v.Id_Marca = i.Id_Marca
and v.Modelo = i.Modelo
and Año_Vehiculo = i.Año_Produccion
and Año_Produccion = i.Año_Produccion
) x
where x.cnt >= 4
)
begin 
Raiserror ('No se puede agregar mas, ya existen mas de cuatro unidades del mismo vehiculo en el stock', 16,1);
Rollback  transaction ;
end
else
begin
insert into Vehiculos (Id_Vehiculo, Id_Marca, Modelo, Año_Vehiculo, Año_Produccion, Numero_Chasis, Tipo_Combustible, Cilindraje, Id_Tipo, Precio_Compra, Precio_Venta, es_Clasico, en_Stock, Fecha_Ingreso, Observaciones)
select Id_Vehiculo, Id_Marca, Modelo, Año_Vehiculo, Año_Produccion, Numero_Chasis, Tipo_Combustible, Cilindraje, Id_Tipo, Precio_Compra, Precio_Venta, es_Clasico, en_Stock, Fecha_Ingreso, Observaciones
from inserted;
end
end;
go

