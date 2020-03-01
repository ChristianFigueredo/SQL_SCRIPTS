CREATE TABLE Document_Types (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Document_Description varchar(40),
);

CREATE TABLE Persons (
    Id int IDENTITY(1,1) PRIMARY KEY,
    LastName varchar(40) NOT NULL,
    FirstName varchar(40),
    Cellphone varchar(15),
	Adress varchar(50),
	Photo varchar(255),
	Id_Document_Type int FOREIGN KEY REFERENCES Document_Types (Id),
	Document_Number varchar(15)
);

CREATE TABLE Type_Animals (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Description_Animal varchar(40),
);

CREATE TABLE Races (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Description_Race varchar(50),
	Id_Type_Animal int FOREIGN KEY REFERENCES Type_Animals (Id)
);

CREATE TABLE Pets(
	Id int IDENTITY(1,1) PRIMARY KEY,
	Pet_Name varchar(50),
	Day_Birth date,
	Id_Race int FOREIGN KEY REFERENCES Races (Id),
	Photo varchar(255)
);