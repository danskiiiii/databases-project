USE dbad_s426281
GO

--VIEW
SELECT * FROM   Kartkowicze
GO
SELECT * FROM   Spotkania
GO

--PROCEDURY
--------------------
--Operuj�ca na tabeli transakcyjnej
EXEC Dodaj_zdarzenie 101, 20002,3,55   --prawid�owe     
EXEC Dodaj_zdarzenie 195, 20001,4,5   --b��dne,nie ma takiego meczu           
EXEC Dodaj_zdarzenie 195, 39001,4,5   --b��dne,nie ma takiego pi�karza 

--Wstawiaj�ca 
EXEC Dodaj_pi�karza 'Jan','Nowak', 'Polska', 6,900 --prawid�owe
EXEC Dodaj_pi�karza 'Jan','Nowak', 'Polska', 16,900 --b��dne,nie ma takiej dru�yny

--Modyfikuj�ca
EXEC Po_premii 1,50 --prawid�owe
SELECT * FROM Pi�karze;

EXEC Po_premii 56,25 --b��dne,nie ma takiej dru�yny


--Usuwaj�ca
EXEC Usu�_pi�karza 'Dele','Alli'

--Raportuj�ca
EXEC Strzelcy

--FUNKCJE
--------------------
--Skalarna
SELECT dbo.Ile_na_pensje(1)
SELECT dbo.Ile_na_pensje(2)
SELECT dbo.Ile_na_pensje(3)

--Tablicowa
SELECT * FROM Niedost�pni()

--TRIGGERY
INSERT INTO  Zdarzenia_meczowe VALUES ( 105 , 20001 , 1  , 65  );
SELECT * FROM Pi�karze;


SELECT * FROM Pi�karze;
SELECT * FROM Trenerzy;
SELECT * FROM Dru�yny;
SELECT * FROM Stadiony;
SELECT * FROM Mecze;
SELECT * FROM Zdarzenia_meczowe ;
SELECT * FROM Typy_zdarze�;


