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

ALTER TABLE Vehiculos
ADD CONSTRAINT fk_Vehiculos_Marcas FOREIGN KEY (Id_Marca) REFERENCES Marcas(Id_Marca);

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

--Solo agregar 6 fotos
Go
create trigger trg_Validar_MaxFotos
On fotos_vehiculos
after insert 
as
begin
if exists (
select 1 from inserted i
cross apply (
select COUNT(*) as cnt from Fotos_Vehiculos f where f.Id_Vehiculo = i.Id_Vehiculo
) x
where x.cnt > 6 
)
begin 
raiserror ('No se puede agregar mas de 6 fotos', 16, 1);
rollback transaction;
end
end;
go


--descuento
go
create procedure registrar_ventas
@Id_Venta varchar(30),
@Precio_Final decimal (12,2),
@Descuento decimal(5,2),
@Cliente varchar (200),
@Forma_Pago varchar(100),
@Nota nvarchar(max)
as
begin
if @Descuento < 0 or @Descuento > 10
begin
raiserror ('Descuento invalido', 16,1);
return;
end

insert into Ventas (Id_Vehiculo, Precio_Venta, Descuento, Nombre_Cliente, Forma_Pago, Nota)
values (@Id_Venta, @Precio_Final, @Descuento, @Cliente, @Forma_Pago, @Nota)
update Vehiculos set en_Stock = 0 where @Id_Venta = @Id_Venta;
end;
go

--vistas
create view vw_ingresos_ventas as
select FORMAT(Fecha_Venta, 'yyyy-mm') as mes, COUNT (*) as total, SUM(Precio_Venta) as Ingresos
from Ventas 
Group by FORMAT (Fecha_Venta, 'yyyy-mm')
go




Select * from Ventas;

INSERT INTO Marcas(Nombre_Marca)
VALUES
  ('Toyota'),
  ('Hyunday'),
  ('Ford'),
  ('Kia'),
  ('Honda'),
  ('Nissan'),
  ('Chevloret'),
  ('Lada'),
  ('Mercedez Benz'),
  ('Mitsubishi');

  INSERT INTO tipo_vehiculo(Nombre_Tipo)
VALUES
  ('Sedan'),
  ('Camioneta'),
  ('Minivan');

  INSERT INTO marcas_clasicas(Id_Marca)
VALUES
  (1),
  (2),
  (9);

  INSERT INTO Vehiculos (Id_Vehiculo,Id_Marca,Modelo,Año_Vehiculo,Año_Produccion,Numero_Chasis,Tipo_Combustible,Cilindraje,Id_Tipo,Precio_Compra,Precio_Venta,Fecha_Ingreso,Observaciones)
VALUES
  ('M2351681',2,'Verna',2021,2012,'RW743863','Combustible',5,2,4728,7267,'05/03/2025','Pellentesque habitant morbi tristique senectus et netus et malesuada'),
  ('CH235494',8,'Lada',2022,2020,'OB732358','Combustible',5,3,4079,8255,'03/10/2025','auctor velit. Aliquam nisl. Nulla eu neque pellentesque massa'),
  ('C562188',1,'Yaris',2011,2010,'AV457815','Combustible',3,1,4618,6424,'08/02/2025','convallis'),
  ('MS156184',2,'sentra',2011,2010,'FE216433','Diesel',5,2,4718,7870,'10/07/2024','amet ornare lectus justo eu arcu.'),
  ('GR4551287',6,'Kicks',2024,2023,'SK435325','Combustible',3,1,3690,6932,'03/03/2025','cursus'),
  ('MT256696',7,'Geo Metro',2014,2013,'CC814967','Diesel',8,3,4912,7612,'07/11/2025','cursus in,'),
  ('M1565326',2,'Accent',2024,2023,'EB828653','Diesel',5,2,4472,6920,'05/08/2026','luctus vulputate, nisi sem semper erat, in consectetuer'),
  ('L423356',7,'Geo',2015,2014,'SJ618452','Combustible',7,2,3671,6127,'05/06/2025','Etiam vestibulum massa rutrum magna. Cras convallis'),
  ('MT4623682',10,'Montero',2025,2024,'BT367353','Combustible',7,1,4219,8797,'01/10/2024','malesuada fames ac turpis egestas. Aliquam fringilla cursus purus. Nullam'),
  ('BO265648',7,'Cross',2001,2000,'YX728924','Combustible',3,3,4766,6712,'06/02/2024','Etiam ligula tortor, dictum eu,'),
  ('M4566286',5,'Prime',2021,2016,'LF219547','Combustible',7,1,4233,8439,'09/03/2024','quis arcu vel quam dignissim pharetra. Nam ac nulla. In'),
  ('MS855322',8,'Montana',1996,1995,'IX922008','Diesel',3,2,3657,6123,'07/07/2026','Integer mollis. Integer tincidunt');
  
  
INSERT INTO Ventas (Id_Vehiculo,Fecha_Venta,Precio_Venta,Descuento,Nombre_Cliente,Forma_Pago,Nota)
VALUES
  ('GR4551287','14/11/2024',6442,3,'Steel Bruce','Efectivo','pellentesque a, facilisis non, bibendum sed, est. Nunc laoreet lectus'),
  ('M4566286','12/02/2025',6611,5,'Hu Mcdaniel','Efectivo','Phasellus in felis. Nulla tempor augue ac ipsum. Phasellus vitae'),
  ('BO265648','10/07/2025',8701,8,'Colton Odom','Credito','justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin sed'),
  ('GR4551287','04/09/2026',6274,6,'Sawyer Cochran','Efectivo','Ut nec urna et arcu imperdiet ullamcorper. Duis at lacus.'),
  ('M2351681','19/08/2026',7914,9,'Preston Trevino','Credito','in molestie tortor nibh sit amet orci. Ut sagittis lobortis'),
  ('M1565326','16/08/2026',8176,10,'Vincent Webb','Credito','Donec tincidunt. Donec vitae erat vel pede blandit congue. In'),
  ('M4566286','05/08/2026',7688,4,'Jeremy Miranda','Credito','mauris erat eget ipsum. Suspendisse sagittis. Nullam vitae diam. Proin'),
  ('BO265648','06/08/2026',6035,5,'Shellie Vang','Efectivo','orci luctus et ultrices posuere cubilia Curae Phasellus ornare. Fusce');
