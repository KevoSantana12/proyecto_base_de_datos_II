USE master;
GO

-- Creacion de la base de datos
CREATE DATABASE RentaAutosBaseDatosII;
GO
 
-- Uso de la base de datos
USE RentaAutosBaseDatosII;
GO

-- Tabla: Carros
CREATE TABLE Carros (
    IdCarro INT PRIMARY KEY IDENTITY(1,1),
    Marca VARCHAR(50) NOT NULL,
    Modelo INT NOT NULL,
    Precio_Dia MONEY NOT NULL,
    Fk_Estado INT NOT NULL,
    Matricula VARCHAR(20) NOT NULL,
    FOREIGN KEY (Fk_Estado) REFERENCES Estado_Vehiculo(IdEstado)
);
GO
 
-- Tabla:  Estado Vehiculo
 
CREATE TABLE Estado_Vehiculo (
    IdEstado INT PRIMARY KEY IDENTITY(1,1),
    Estado VARCHAR(50),
    Detalle VARCHAR(100)
);
 
 
-- Tabla: Cliente
CREATE TABLE Cliente (
    IdCliente INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Cedula VARCHAR(20) NOT NULL UNIQUE,
    Telefono VARCHAR(15) NOT NULL
);
GO
 
-- Tabla: Sucursal
CREATE TABLE Sucursal (
    IdSucursal INT PRIMARY KEY IDENTITY(1,1),
    Sucursal VARCHAR(100) NOT NULL
);
GO
 
-- Tabla: Gerente_Ventas
CREATE TABLE Gerente_Ventas (
    IdGerente INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL
);
GO
 
-- Tabla: Renta_Carro
CREATE TABLE Renta_Carro (
    IdRenta INT PRIMARY KEY IDENTITY(1,1),
    Fecha_Renta DATE NOT NULL,
    Fecha_Devolucion DATE NOT NULL,
	Pagado BIT,
    Total MONEY NOT NULL,
    Fk_Carro INT NOT NULL,
    Fk_Cliente INT NOT NULL,
    Fk_Sucursal INT NOT NULL,
    Fk_Gerente INT NOT NULL,
    FOREIGN KEY (Fk_Carro) REFERENCES Carros(IdCarro),
    FOREIGN KEY (Fk_Cliente) REFERENCES Cliente(IdCliente),
    FOREIGN KEY (Fk_Sucursal) REFERENCES Sucursal(IdSucursal),
    FOREIGN KEY (Fk_Gerente) REFERENCES Gerente_Ventas(IdGerente)
);
GO
 
-- Tabla: Historial_Renta
CREATE TABLE Historial_Renta (
    IdHistorial INT PRIMARY KEY IDENTITY(1,1),
	Fecha_Renta DATE NOT NULL,
    Fecha_Devolucion DATE NOT NULL,
    Total MONEY NOT NULL,
    Cliente VARCHAR(100) NOT NULL,
    Matricula VARCHAR(20) NOT NULL,
    Sucursal VARCHAR(100) NOT NULL,
    Gerente VARCHAR(100) NOT NULL,
    Fk_Renta_Carro INT NOT NULL,
    FOREIGN KEY (Fk_Renta_Carro) REFERENCES Renta_Carro(IdRenta)
);
GO
 
--Procedimientos Almacenados
CREATE PROCEDURE InsertarEstadoVehiculo 
    @Estado VARCHAR(50),
    @Detalle VARCHAR(100)
AS
BEGIN
    INSERT INTO Estado_Vehiculo (Estado, Detalle)
    VALUES (@Estado, @Detalle);
END;
GO
 
CREATE PROCEDURE InsertarCarro 
    @Marca VARCHAR(50),
    @Modelo INT,
    @Precio_Dia MONEY,
    @Fk_Estado INT,
    @Matricula VARCHAR(20)
AS
BEGIN
    INSERT INTO Carros (Marca, Modelo, Precio_Dia, Fk_Estado, Matricula)
    VALUES (@Marca, @Modelo, @Precio_Dia, @Fk_Estado, @Matricula);
END;
GO
 
CREATE PROCEDURE InsertarCliente 
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50),
    @Cedula VARCHAR(20),
    @Telefono VARCHAR(15)
AS
BEGIN
    INSERT INTO Cliente (Nombre, Apellido, Cedula, Telefono)
    VALUES (@Nombre, @Apellido, @Cedula, @Telefono);
END;
GO
 
CREATE PROCEDURE InsertarSucursal 
    @Sucursal VARCHAR(100)
AS
BEGIN
    INSERT INTO Sucursal (Sucursal)
    VALUES (@Sucursal);
END;
GO
 
CREATE PROCEDURE InsertarGerenteVentas 
    @Nombre VARCHAR(50),
    @Apellido VARCHAR(50)
AS
BEGIN
    INSERT INTO Gerente_Ventas (Nombre, Apellido)
    VALUES (@Nombre, @Apellido);
END;
GO
 
--Agregamos datos de prueba
EXEC InsertarEstadoVehiculo 'Disponible', 'El vehículo se puede usar';
EXEC InsertarEstadoVehiculo 'No disponible', 'El vehículo no se puede usar';
EXEC InsertarEstadoVehiculo 'En taller', 'El vehiculo tiene fallas tecnicas';
 
EXEC InsertarCarro 'Toyota', 2022, 50.00, 1, 'ABC-123';
EXEC InsertarCarro 'Honda', 2020, 45.00, 2, 'DEF-456';
EXEC InsertarCarro 'Ford', 2019, 40.00, 3, 'GHI-789';
 
EXEC InsertarCliente 'Juan', 'Pérez', '1234567890', '555-1234';
EXEC InsertarCliente 'María', 'Gómez', '0987654321', '555-5678';
EXEC InsertarCliente 'Carlos', 'Martínez', '1122334455', '555-9101';
 
EXEC InsertarSucursal 'San Jose';
EXEC InsertarSucursal 'Heredia';
EXEC InsertarSucursal 'San Ramon';
 
EXEC InsertarGerenteVentas 'Pedro', 'Sánchez';
EXEC InsertarGerenteVentas 'Ana', 'López';
EXEC InsertarGerenteVentas 'Luis', 'Ramírez';
GO
 
 
--Disparadores
CREATE TRIGGER trg_InsertarHistorialRenta
ON Renta_Carro
AFTER INSERT
AS
BEGIN
    -- Insertar en la tabla Historial_Renta los detalles de la renta que se acaba de agregar
    INSERT INTO Historial_Renta (Fecha_Renta, Fecha_Devolucion, Total, Cliente, Matricula, Sucursal, Gerente, Fk_Renta_Carro)
    SELECT 
        i.Fecha_Renta,
        i.Fecha_Devolucion,
        i.Total,
        c.Nombre + ' ' + c.Apellido AS Cliente,
        car.Matricula,
        suc.Sucursal,
        gv.Nombre + ' ' + gv.Apellido AS Gerente,
        i.IdRenta
    FROM 
        inserted i
    JOIN Cliente c ON c.IdCliente = i.Fk_Cliente
    JOIN Carros car ON car.IdCarro = i.Fk_Carro
    JOIN Sucursal suc ON suc.IdSucursal = i.Fk_Sucursal
    JOIN Gerente_Ventas gv ON gv.IdGerente = i.Fk_Gerente;
END;
GO
 
 
--Manejo de exepciones y creacion de vistas
-- Crear procedimiento con manejo de excepciones para insertar una renta
CREATE PROCEDURE InsertarRentaConExcepcion
    @Fecha_Renta DATE,
    @Fecha_Devolucion DATE,
    @Pagado BIT,
    @Total MONEY,
    @Fk_Carro INT,
    @Fk_Cliente INT,
    @Fk_Sucursal INT,
    @Fk_Gerente INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar transacción
        BEGIN TRANSACTION;
 
        -- Insertar en la tabla Renta_Carro
        INSERT INTO Renta_Carro (Fecha_Renta, Fecha_Devolucion, Pagado, Total, Fk_Carro, Fk_Cliente, Fk_Sucursal, Fk_Gerente)
        VALUES (@Fecha_Renta, @Fecha_Devolucion, @Pagado, @Total, @Fk_Carro, @Fk_Cliente, @Fk_Sucursal, @Fk_Gerente);
 
        -- Si la inserción es exitosa, se hace un commit
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, se hace un rollback y se lanza el error
        ROLLBACK TRANSACTION;
 
        -- Retornar el mensaje de error
        THROW;
    END CATCH
END;
GO
 
 
-- Crear una vista para ver todas las rentas
CREATE VIEW Vista_Rentas AS
SELECT 
    r.IdRenta,
    r.Fecha_Renta,
    r.Fecha_Devolucion,
    r.Total,
    c.Nombre + ' ' + c.Apellido AS Cliente,
    car.Matricula,
    suc.Sucursal,
    gv.Nombre + ' ' + gv.Apellido AS Gerente
FROM 
    Renta_Carro r
JOIN Cliente c ON c.IdCliente = r.Fk_Cliente
JOIN Carros car ON car.IdCarro = r.Fk_Carro
JOIN Sucursal suc ON suc.IdSucursal = r.Fk_Sucursal
JOIN Gerente_Ventas gv ON gv.IdGerente = r.Fk_Gerente;
GO
 
 
-- Insertar una renta con manejo de excepciones
EXEC InsertarRentaConExcepcion 
    @Fecha_Renta = '2025-03-15',
    @Fecha_Devolucion = '2025-03-20',
    @Pagado = 1,
    @Total = 500.00,
    @Fk_Carro = 1, 
    @Fk_Cliente = 1, 
    @Fk_Sucursal = 1,
	@Fk_Gerente = 1;
GO
 
-- Consultar el historial de rentas
SELECT * FROM Historial_Renta;
GO