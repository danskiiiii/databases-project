USE dbad_s426281
GO

--VIEW
SELECT * FROM   Kartkowicze
GO
SELECT * FROM   Spotkania
GO

--PROCEDURY
--------------------
--Operuj¹ca na tabeli transakcyjnej
EXEC Dodaj_zdarzenie 101, 20002,3,55   --prawid³owe     
EXEC Dodaj_zdarzenie 195, 20001,4,5   --b³êdne,nie ma takiego meczu           
EXEC Dodaj_zdarzenie 195, 39001,4,5   --b³êdne,nie ma takiego pi³karza 

--Wstawiaj¹ca 
EXEC Dodaj_pi³karza 'Jan','Nowak', 'Polska', 6,900 --prawid³owe
EXEC Dodaj_pi³karza 'Jan','Nowak', 'Polska', 16,900 --b³êdne,nie ma takiej dru¿yny

--Modyfikuj¹ca
EXEC Po_premii 1,50 --prawid³owe
SELECT * FROM Pi³karze;

EXEC Po_premii 56,25 --b³êdne,nie ma takiej dru¿yny


--Usuwaj¹ca
EXEC Usuñ_pi³karza 'Dele','Alli'

--Raportuj¹ca
EXEC Strzelcy

--FUNKCJE
--------------------
--Skalarna
SELECT dbo.Ile_na_pensje(1)
SELECT dbo.Ile_na_pensje(2)
SELECT dbo.Ile_na_pensje(3)

--Tablicowa
SELECT * FROM Niedostêpni()

--TRIGGERY
INSERT INTO  Zdarzenia_meczowe VALUES ( 105 , 20001 , 1  , 65  );
SELECT * FROM Pi³karze;


SELECT * FROM Pi³karze;
SELECT * FROM Trenerzy;
SELECT * FROM Dru¿yny;
SELECT * FROM Stadiony;
SELECT * FROM Mecze;
SELECT * FROM Zdarzenia_meczowe ;
SELECT * FROM Typy_zdarzeñ;


