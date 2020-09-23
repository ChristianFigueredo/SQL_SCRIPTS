CREATE TABLE DocumentType (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Description varchar(40) NOT NULL,
	Acronym varchar (40) NOT NULL
);

CREATE TABLE State (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Name varchar(50) NOT NULL,
	Description varchar(50) NOT NULL
);

CREATE TABLE Person (
    Id int IDENTITY(1,1) PRIMARY KEY,
    LastName varchar(40) NOT NULL,
    FirstName varchar(40) NOT NULL,
    Cellphone varchar(15) NOT NULL,
	Email varchar(100) NOT NULL,
	Adress varchar(50) NOT NULL,
	Photo varchar(255) NOT NULL,
	Document_Number varchar(15) NOT NULL,
	Id_Document_Type int FOREIGN KEY REFERENCES DocumentType (Id)
);

CREATE TABLE AnimalType (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Description varchar(40) NOT NULL
); 

CREATE TABLE Race (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Description varchar(50) NOT NULL,
	Id_Type_Animal int FOREIGN KEY REFERENCES AnimalType (Id)
);

CREATE TABLE Pet (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Pet_Name varchar(50) NOT NULL,
	Day_Birth date NOT NULL,
	Photo varchar(255) NOT NULL,
	Id_Race int FOREIGN KEY REFERENCES Race (Id),
	Id_Person int FOREIGN KEY REFERENCES Person (Id)
);

CREATE TABLE PetStateHistory (
	Id int IDENTITY(1,1) PRIMARY KEY,
	TransactionDate datetime NOT NULL,
	Id_State int FOREIGN KEY REFERENCES State (Id),
	Id_Pet int FOREIGN KEY REFERENCES Pet (Id),
	Id_Person int FOREIGN KEY REFERENCES Person (Id),
);

CREATE TABLE PersonStateHistory (
	Id int IDENTITY(1,1) PRIMARY KEY,
	TransactionDate datetime NOT NULL,
	Id_State int FOREIGN KEY REFERENCES State (Id),
	Id_Person int FOREIGN KEY REFERENCES Person (Id),
);

CREATE TABLE Profile (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Name varchar(50) NOT NULL,
	Description varchar(50) NOT NULL
);

CREATE TABLE UserData (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Password varchar(50) NOT NULL,
	Nickname varchar(50) NOT NULL,
	Id_Person int FOREIGN KEY REFERENCES Person (Id),
	Id_Profile int FOREIGN KEY REFERENCES Profile (Id)
);

insert into DocumentType (Acronym, Description) values ('CC', 'CEDULA DE CIUDADANIA');
insert into DocumentType (Acronym, Description) values ('PA', 'PASAPORTE');
insert into DocumentType (Acronym, Description) values ('CE', 'CEDULA EXTRANJERIA');
insert into DocumentType (Acronym, Description) values ('CD', 'CARNET DIPLOMATICO');
insert into DocumentType (Acronym, Description) values ('PE', 'PERMISO ESPECIAL DE PERMANENCIA');

insert into AnimalType (Description) values ('CAN');
insert into AnimalType (Description) values ('FELINO');
insert into AnimalType (Description) values ('AVE');
insert into AnimalType (Description) values ('REPTIL');

insert into Race ( Description, Id_Type_Animal) values ('GALLINA BLANCA', 3);
insert into Race ( Description, Id_Type_Animal) values ('ANGORA', 2);
insert into Race ( Description, Id_Type_Animal) values ('BULL DOG', 1);
insert into Race ( Description, Id_Type_Animal) values ('MORROCOY', 4);

insert into State ( Name, Description) values ('ACTIVO', 'PROPIETARIO');
insert into State ( Name, Description) values ('INACTIVO', 'PROPIETARIO');
insert into State ( Name, Description) values ('ACTIVO', 'MASCOTA');
insert into State ( Name, Description) values ('REPORTADO PERDIDO', 'MASCOTA');
insert into State ( Name, Description) values ('REPORTADO ENCONTRADO', 'MASCOTA');
insert into State ( Name, Description) values ('ENTREGADO A PROPIETARIO', 'MASCOTA');
insert into State ( Name, Description) values ('FALLECIDO', 'MASCOTA');
insert into State ( Name, Description) values ('INACTIVO', 'MASCOTA');

select * from Person
select * from PersonStateHistory
select * from Pet
select * from PetStateHistory
select * from Race
select * from AnimalType
select * from DocumentType
select * from State