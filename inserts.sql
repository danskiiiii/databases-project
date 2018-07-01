
USE dbad_s426281
GO
--SET LANGUAGE polski
--GO

--CZYSZCZENIE
IF OBJECT_ID('Zdarzenia_meczowe', 'U') IS NOT NULL 
	DROP TABLE Zdarzenia_meczowe;

IF OBJECT_ID('Mecze', 'U') IS NOT NULL 
	DROP TABLE Mecze;

IF OBJECT_ID('Trenerzy', 'U') IS NOT NULL 
	DROP TABLE Trenerzy;

IF OBJECT_ID('Pi³karze', 'U') IS NOT NULL 
	DROP TABLE Pi³karze;
	
IF OBJECT_ID('Typy_zdarzeñ', 'U') IS NOT NULL 
	DROP TABLE Typy_zdarzeñ;
	
IF OBJECT_ID('Dru¿yny', 'U') IS NOT NULL 
	DROP TABLE Dru¿yny;

IF OBJECT_ID('Stadiony', 'U') IS NOT NULL 
	DROP TABLE Stadiony;
GO

--TWORZENIE
CREATE TABLE Stadiony(
    id_stadionu  INT NOT NULL PRIMARY KEY,
	nazwa        VARCHAR(20) NOT NULL,
    miasto       VARCHAR(40) NOT NULL,
	pojemnoœæ    INT NOT NULL,
);

CREATE TABLE Typy_zdarzeñ(
    id_zdarzenia INT NOT NULL PRIMARY KEY,
	nazwa        VARCHAR(20) NOT NULL UNIQUE,
    dodatek_p³acowy   MONEY   
);

CREATE TABLE Dru¿yny(
    id_dru¿yny   INT NOT NULL PRIMARY KEY,
	nazwa        VARCHAR(20) NOT NULL,
    miasto       VARCHAR(40) NOT NULL,
	rok_za³o¿enia  INT NOT NULL,
    stadion      INT REFERENCES Stadiony(id_stadionu),
	CHECK (rok_za³o¿enia  between 1800 and 2018)	
);

CREATE TABLE Pi³karze(
    nr_licencji  INT IDENTITY (20001,1) PRIMARY KEY,
	imiê         VARCHAR(20) NOT NULL,
    nazwisko     VARCHAR(30) NOT NULL,
	narodowoœæ   VARCHAR(20) NOT NULL,
    dru¿yna      INT REFERENCES Dru¿yny(id_dru¿yny),
    pensja       MONEY NOT NULL,
    dodatki      MONEY DEFAULT 0,
    niedostêpnoœæ  DATETIME
);

CREATE TABLE Trenerzy(
    nr_licencji  INT IDENTITY (10001,1) PRIMARY KEY,
	imiê         VARCHAR(20) NOT NULL,
    nazwisko     VARCHAR(30) NOT NULL,
	stanowisko   VARCHAR(20) NOT NULL,
	narodowoœæ   VARCHAR(20) NOT NULL,
    dru¿yna      INT REFERENCES Dru¿yny(id_dru¿yny),
    pensja       MONEY NOT NULL,
    dodatki      MONEY DEFAULT 0
);

CREATE TABLE Mecze(
    nr_meczu	 INT IDENTITY(101,1) NOT NULL PRIMARY KEY,
	data_        DATETIME NOT NULL,
	gospodarze   INT REFERENCES Dru¿yny(id_dru¿yny),
	bramki_gosp  INT DEFAULT 0,
	goœcie		 INT REFERENCES Dru¿yny(id_dru¿yny),
	bramki_goœæ  INT DEFAULT 0,
	widownia     INT DEFAULT 0	   
);

CREATE TABLE Zdarzenia_meczowe(
    nr_zdarzenia INT IDENTITY (1,1) PRIMARY KEY,
	mecz         INT REFERENCES Mecze(nr_meczu),
    pi³karz      INT REFERENCES Pi³karze(nr_licencji),
    typ          INT REFERENCES Typy_zdarzeñ(id_zdarzenia),
	minuta       INT NOT NULL,
	CHECK (minuta between 0 and 90)   
);
GO

--INSERTY
INSERT INTO Stadiony     VALUES ( 1, 'Etihad','Manchester', 54693  );
INSERT INTO Stadiony     VALUES ( 2, 'Old Trafford','Manchester', 74994  );
INSERT INTO Stadiony     VALUES ( 3, 'Stamford Bridge','London', 41631  );
INSERT INTO Stadiony     VALUES ( 4, 'Anfield','Liverpool', 54074 );
INSERT INTO Stadiony     VALUES ( 5, 'Wembley','London', 90000 );
INSERT INTO Stadiony     VALUES ( 6, 'Emirates','London', 60432 );

INSERT INTO Typy_zdarzeñ VALUES ( 1, 'gol', 1000 );
INSERT INTO Typy_zdarzeñ VALUES ( 2, 'asysta',500);
INSERT INTO Typy_zdarzeñ VALUES ( 3, '¿ó³ta kartka', -200 );
INSERT INTO Typy_zdarzeñ VALUES ( 4, 'czerwona kartka', -1500);
INSERT INTO Typy_zdarzeñ VALUES ( 5, 'kontuzja', NULL );

INSERT INTO  Dru¿yny    VALUES ( 1, 'Man.City', 'Manchester', 1894, 1 );
INSERT INTO  Dru¿yny    VALUES ( 2, 'Man.United', 'Manchester', 1878, 2  );
INSERT INTO  Dru¿yny    VALUES ( 3, 'Chelsea', 'London', 1905, 3  );
INSERT INTO  Dru¿yny    VALUES ( 4, 'Liverpool F.C.', 'Liverpool', 1892, 4  );
INSERT INTO  Dru¿yny    VALUES ( 5, 'Tottenham', 'London', 1882, 5  );
INSERT INTO  Dru¿yny    VALUES ( 6, 'Arsenal', 'London', 1886, 6  );

INSERT INTO  Pi³karze    VALUES (  'Kevin', 'De Bruyne', 'Belgia', 1, 180000 , 5500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Gabriel', 'Jesus', 'Brazylia', 1, 150000 , 1500,NULL );
INSERT INTO  Pi³karze    VALUES (  'David', 'Silva', 'Hiszpania', 1, 190000 , 7500, NULL);
INSERT INTO  Pi³karze    VALUES (  'Sergio', 'Aguero', 'Argentyna', 1, 220000 , 1800, '02/25/2018' );
INSERT INTO  Pi³karze    VALUES (  'Paul', 'Pogba', 'Francja', 2, 250000 , 9500 , NULL);
INSERT INTO  Pi³karze    VALUES (  'Juan', 'Mata', 'Hiszpania', 2, 120000 , 15500 , NULL);
INSERT INTO  Pi³karze    VALUES (  'Romelu', 'Lukaku', 'Belgia', 2, 210000 , 2500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Michael', 'Carrick', 'Anglia', 2, 150000 , 3500 , '04/03/2018');
INSERT INTO  Pi³karze    VALUES (  'Eden', 'Hazard', 'Belgia', 3, 230000 , 1500, NULL );
INSERT INTO  Pi³karze    VALUES (  'David', 'Luiz', 'Brazylia', 3, 180000 , 2500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Alvaro', 'Morata', 'Hiszpania', 3, 150000 ,1200 , '02/10/2018' );
INSERT INTO  Pi³karze    VALUES (  'Roberto', 'Firmino', 'Brazylia', 4, 20000 , 1500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Emre', 'Can', 'Niemcy', 4, 120000 , 4500, '03/12/2018' );
INSERT INTO  Pi³karze    VALUES (  'Sadio', 'Mane', 'Senegal', 4, 130000 , 5500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Mohammed', 'Salah', 'Egipt', 4, 170000 , 1500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Harry', 'Kane', 'Anglia', 5, 250000 , 1100, NULL );
INSERT INTO  Pi³karze    VALUES (  'Christian', 'Eriksen', 'Dania', 5, 150000 , 1500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Dele', 'Alli', 'Anglia', 5, 175000  , 3800, '02/02/2018' );
INSERT INTO  Pi³karze    VALUES (  'Alexandre', 'Lacazette', 'Francja', 6, 200000 , 1500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Mesut', 'Ozil', 'Niemcy', 6, 210000 , 2500, NULL );
INSERT INTO  Pi³karze    VALUES (  'Danny', 'Welbeck', 'Anglia', 6, 140000 , 1500, NULL );

INSERT INTO  Trenerzy    VALUES (  'Josep', 'Guardiola', 'Head Coach' ,'Hiszpania', 1, 220000 , 1500 );
INSERT INTO  Trenerzy    VALUES (  'Jason', 'Wilcox', 'Head of Academy' ,'Anglia', 1,	19000 , 100  );
INSERT INTO  Trenerzy    VALUES (  'Jose', 'Mourinho', 'Manager' ,'Portugalia', 2, 200000 , 1900  );
INSERT INTO  Trenerzy    VALUES (  'Antonio', 'Conte', 'Head Coach' ,'W³ochy', 3, 190000 , 1500  );
INSERT INTO  Trenerzy    VALUES (  'Guy', 'Laurence', 'Technical director' ,'Anglia', 3, 18000 , 500  );
INSERT INTO  Trenerzy    VALUES (  'Julio', 'Tous', 'Fitness coach' ,'Hiszpania', 3, 7000 , 100  );
INSERT INTO  Trenerzy    VALUES (  'Jurgen', 'Klopp', 'Manager' ,'Niemcy', 4, 170000 , 1500  );
INSERT INTO  Trenerzy    VALUES (  'Alex', 'Inglethorpe', 'Academy Director' ,'Anglia', 4, 5000 , 300  );
INSERT INTO  Trenerzy    VALUES (  'Mauricio', 'Pochettino', 'Manager' ,'Argentyna', 5, 150000 , 1300  );
INSERT INTO  Trenerzy    VALUES (  'Arsene', 'Wenger', 'Manager' ,'Francja', 6, 175000 , 2500  );

INSERT INTO  Mecze       VALUES (  '09/11/2017' ,1 ,2 ,3 ,0 ,29000 );
INSERT INTO  Mecze       VALUES (  '10/28/2017' ,1 ,5 ,6 , 1, 38000);
INSERT INTO  Mecze       VALUES (  '11/19/2017' ,2 ,1, 3,2 , 27800);
INSERT INTO  Mecze       VALUES (  '12/09/2017' ,6 ,1 ,5 ,0 , 19500);
INSERT INTO  Mecze       VALUES (  '11/24/2017' ,5 ,2 ,2 ,2 , 25500);
INSERT INTO  Mecze       VALUES (  '07/12/2017' ,5 ,3 ,1 ,3 , 38000);
INSERT INTO  Mecze       VALUES (  '09/12/2017' ,3 ,3 ,2, 0, 42303);
INSERT INTO  Mecze       VALUES (  '08/08/2017' ,4 ,5 ,6 ,2 , 17590);
INSERT INTO  Mecze       VALUES (  '12/09/2017' ,2 ,3, 5 ,1 , 21320);
INSERT INTO  Mecze       VALUES (  '11/11/2017' ,3 ,2, 1 ,4 ,33020 );
INSERT INTO  Mecze       VALUES (  '12/15/2017' ,6 ,0, 1 ,2 , 21990);
INSERT INTO  Mecze       VALUES (  '10/28/2017' ,5, 2, 6 ,1 , 25980);
INSERT INTO  Mecze       VALUES (  '10/28/2017' ,4, 2, 1 ,5 , 17000);
INSERT INTO  Mecze       VALUES (  '10/28/2017' ,6, 1, 3 ,1 , 15300);

INSERT INTO  Zdarzenia_meczowe VALUES ( 101 , 20001 , 1  , 51   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 101 , 20001 , 1  , 65   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 101 , 20002 , 2  , 65   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 101 , 20010  , 3  , 82   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 102 , 20003 , 1  , 89   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 102 , 20020 , 5  , 85   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 102 , 20021 , 1  , 15   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 102 , 20001 , 3  , 75   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 102 , 20003 ,   1,  42  );
INSERT INTO  Zdarzenia_meczowe VALUES ( 102 , 20004 , 2  , 42   );
INSERT INTO  Zdarzenia_meczowe VALUES ( 103 , 20007 , 1  , 50  );


--SELECT
SELECT * FROM Pi³karze;
SELECT * FROM Trenerzy;
SELECT * FROM Dru¿yny;
SELECT * FROM Stadiony;
SELECT * FROM Mecze;
SELECT * FROM Zdarzenia_meczowe ;
SELECT * FROM Typy_zdarzeñ;



