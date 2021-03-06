-- SUPERMARKET DATABASE

CREATE TABLE TIPO_DOCUMENTO(
ID INT IDENTITY(1,1) PRIMARY KEY,
DESCRIPCION VARCHAR (40) NOT NULL,
ACRONIMO VARCHAR (10) NOT NULL
);

CREATE TABLE PERSONA (
ID INT IDENTITY(1,1) PRIMARY KEY,
NUMERO_DOCUMENTO VARCHAR(20) NOT NULL,
NOMBRE VARCHAR(40) NOT NULL,
APELLIDO VARCHAR(40) NOT NULL,
TELEFONO VARCHAR(40),
EMAIL VARCHAR(40),
DIRECCION VARCHAR(40),
ID_TIPO_DOCUMENTO INT FOREIGN KEY REFERENCES TIPO_DOCUMENTO (ID),
);

CREATE TABLE USUARIO (
ID INT IDENTITY(1,1) PRIMARY KEY,
NICKNAME VARCHAR(40) NOT NULL,
CLAVE VARCHAR(40) NOT NULL,
PERFIL VARCHAR(40) NOT NULL,
ESTADO BIT NOT NULL,
ID_PERSONA INT FOREIGN KEY REFERENCES PERSONA (ID)
);

CREATE TABLE CLIENTE (
ID INT IDENTITY(1,1) PRIMARY KEY,
PUNTOS INT,
ID_PERSONA INT FOREIGN KEY REFERENCES PERSONA (ID)
);

CREATE TABLE INVENTARIO (
ID INT IDENTITY(1,1) PRIMARY KEY,
NOMBRE VARCHAR(40),
DESCRIPCION VARCHAR(40),
TOTAL_RECIBIDOS DECIMAL(18,3),
TOTAL_VENDIDOS DECIMAL(18,3),
TOTAL_DESINCORPORADOS DECIMAL(18,3),
TOTAL_DEVUELTOS DECIMAL(18,3),
TOTAL_PROCESO DECIMAL(18,3),
PRECIO_COMPRA DECIMAL(18,3),
PRECIO_VENTA DECIMAL(18,3),
FECHA_REGISTRO DATETIME,
PORCENTAJE_IVA DECIMAL(18,1),
PORCENTAJE_DESCUENTO DECIMAL(18,2)
);

CREATE TABLE ESTADOS_FACTURA (
ID INT IDENTITY(1,1) PRIMARY KEY,
DESCRIPCION VARCHAR(40)
);

CREATE TABLE FACTURA (
ID INT IDENTITY(1,1) PRIMARY KEY,
NUMERO UNIQUEIDENTIFIER default NEWID(),
VALOR_TOTAL DECIMAL(18,3),
VALOR_SUBTOTAL DECIMAL(18,3),
VALOR_IVA DECIMAL(18,3),
VALOR_DESCUENTO DECIMAL(18,3),
FECHA_APERTURA DATETIME,
FECHA_CIERRE DATETIME,
ID_ESTADO INT FOREIGN KEY REFERENCES ESTADOS_FACTURA(ID),
ID_USUARIO INT FOREIGN KEY REFERENCES USUARIO(ID),
ID_CLIENTE INT FOREIGN KEY REFERENCES CLIENTE(ID)
);

CREATE TABLE PRODUCTO (
ID INT IDENTITY(1,1) PRIMARY KEY,
VALOR_UNITARIO DECIMAL(18,3),
VALOR_TOTAL DECIMAL(18,3),
CANTIDAD DECIMAL(18,3),
PORCENTAJE_IVA DECIMAL(18,3),
VALOR_TOTAL_IVA DECIMAL(18,3),
PORCENTAJE_DESCUENTO DECIMAL(18,3),
VALOR_TOTAL_DESCUENTO DECIMAL(18,3),
ID_INVENTARIO INT FOREIGN KEY REFERENCES INVENTARIO (ID),
ID_FACTURA INT FOREIGN KEY REFERENCES FACTURA (ID)
);





