USE dbad_s426281
GO

--VIEW
SELECT * FROM   Kartkowicze
GO
SELECT * FROM   Spotkania
GO

--PROCEDURY
--------------------
--Operująca na tabeli transakcyjnej
EXEC Dodaj_zdarzenie 101, 20002,3,55   --prawidłowe     
EXEC Dodaj_zdarzenie 195, 20001,4,5   --błędne,nie ma takiego meczu           
EXEC Dodaj_zdarzenie 195, 39001,4,5   --błędne,nie ma takiego piłkarza 

--Wstawiająca 
EXEC Dodaj_piłkarza 'Jan','Nowak', 'Polska', 6,900 --prawidłowe
EXEC Dodaj_piłkarza 'Jan','Nowak', 'Polska', 16,900 --błędne,nie ma takiej drużyny

--Modyfikująca
EXEC Po_premii 1,50 --prawidłowe
SELECT * FROM Piłkarze;

EXEC Po_premii 56,25 --błędne,nie ma takiej drużyny


--Usuwająca
EXEC Usuń_piłkarza 'Dele','Alli'

--Raportująca
EXEC Strzelcy

--FUNKCJE
--------------------
--Skalarna
SELECT dbo.Ile_na_pensje(1)
SELECT dbo.Ile_na_pensje(2)
SELECT dbo.Ile_na_pensje(3)

--Tablicowa
SELECT * FROM Niedostępni()

--TRIGGERY
INSERT INTO  Zdarzenia_meczowe VALUES ( 105 , 20001 , 1  , 65  );
SELECT * FROM Piłkarze;


SELECT * FROM Piłkarze;
SELECT * FROM Trenerzy;
SELECT * FROM Drużyny;
SELECT * FROM Stadiony;
SELECT * FROM Mecze;
SELECT * FROM Zdarzenia_meczowe ;
SELECT * FROM Typy_zdarzeń;


