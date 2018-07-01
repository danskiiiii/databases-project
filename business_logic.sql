USE dbad_s426281
GO

--VIEW 
IF OBJECT_ID('Kartkowicze','V') IS NOT NULL
DROP VIEW Kartkowicze
GO

CREATE VIEW Kartkowicze(imię,nazwisko)
AS
   SELECT  imię , nazwisko
   FROM    Piłkarze
   WHERE   nr_licencji in (SELECT DISTINCT nr_licencji from Piłkarze p join Zdarzenia_meczowe z 
					  on p.nr_licencji = z.piłkarz
					   WHERE z.typ =3 or z.typ=4)
GO

IF OBJECT_ID('Spotkania','V') IS NOT NULL
DROP VIEW Spotkania
GO

CREATE VIEW Spotkania(gospodarze, A ,B,goście)
AS
   SELECT d1.nazwa, m.bramki_gosp, m.bramki_gość,d2.nazwa   
   FROM Mecze m join Drużyny d1 on  m.gospodarze = d1.id_drużyny   join Drużyny d2 on m.goście=d2.id_drużyny    			
GO



--PROCEDURY
--------------------
--Operująca na tabeli transakcyjnej
IF OBJECT_ID('Dodaj_zdarzenie','P') IS NOT NULL
DROP PROCEDURE Dodaj_zdarzenie
GO

CREATE PROCEDURE Dodaj_zdarzenie (@nr_meczu INT, @id_piłkarza INT, @typ INT, @minuta INT)
                         
AS
   IF NOT EXISTS ( SELECT * from Mecze WHERE nr_meczu = @nr_meczu)
        BEGIN
                RAISERROR (N'Bledny numer meczu: %s', 16, 1,  @nr_meczu )
        END
	IF NOT EXISTS ( SELECT * from Piłkarze WHERE nr_licencji = @id_piłkarza)
        BEGIN
                RAISERROR (N'Bledny numer licencji piłkarza: %s', 16, 1, @id_piłkarza  )
        END

	IF NOT EXISTS ( SELECT * from Typy_zdarzeń WHERE id_zdarzenia = @typ)
        BEGIN
                RAISERROR (N'Bledny numer licencji piłkarza: %s', 16, 1, @typ )
        END

INSERT INTO Zdarzenia_meczowe( mecz, piłkarz, typ, minuta)
        VALUES (@nr_meczu, @id_piłkarza, @typ , @minuta)
GO

--Wstawiająca
IF OBJECT_ID('Dodaj_piłkarza','P') IS NOT NULL
DROP PROCEDURE Dodaj_piłkarza
GO

CREATE PROCEDURE Dodaj_piłkarza (@imię VARCHAR(20), @nazwisko VARCHAR(30), 
                          @narodowość VARCHAR(20), @drużyna INT, @pensja MONEY)
                         
AS
   IF NOT EXISTS ( SELECT * from Drużyny WHERE id_drużyny = @drużyna)
        BEGIN
                RAISERROR (N'Bledne id drużyny: %s', 16, 1,  @drużyna )
        END
	
INSERT INTO Piłkarze( imię , nazwisko, narodowość ,drużyna, pensja)
        VALUES (@imię, @nazwisko, @narodowość , @drużyna,@pensja)
GO

--Modyfikująca
IF OBJECT_ID('Po_premii','P') IS NOT NULL
DROP PROCEDURE Po_premii
GO
CREATE PROCEDURE Po_premii (@drużyna INT, @proc TINYINT )       
AS
BEGIN 
IF NOT EXISTS ( SELECT * from Drużyny WHERE id_drużyny = @drużyna)
        BEGIN
                RAISERROR (N'Bledne id drużyny: %s', 16, 1,  @drużyna )
        END
UPDATE Piłkarze
set dodatki = dodatki - (1.0*(dodatki*@proc/100)) where drużyna = @drużyna
END;
GO

--Usuwająca
IF OBJECT_ID('Usuń_piłkarza','P') IS NOT NULL
DROP PROCEDURE Usuń_piłkarza
GO

CREATE PROCEDURE Usuń_piłkarza (@imię VARCHAR(20), @nazwisko VARCHAR(30))                         
AS  	
DELETE FROM Piłkarze WHERE imię = @imię and nazwisko = @nazwisko
GO

--Raportująca
IF OBJECT_ID('Strzelcy','P') IS NOT NULL
DROP PROCEDURE Strzelcy
GO

CREATE PROCEDURE Strzelcy                        
AS  					   
SELECT imię, nazwisko , count (typ) [liczba bramek]
FROM Piłkarze p join Zdarzenia_meczowe r
on p.nr_licencji = r.piłkarz 
GROUP BY imię, nazwisko,typ
HAVING typ=1
ORDER BY count (typ) desc
GO

--FUNKCJE
--------------------
--Skalarna
IF OBJECT_ID('Ile_na_pensje') IS NOT NULL
DROP FUNCTION Ile_na_pensje
GO
CREATE FUNCTION Ile_na_pensje  (@drużyna INT)
        RETURNS MONEY
AS
BEGIN
DECLARE @pensje MONEY; 
SELECT  @pensje = SUM (pensja+dodatki) FROM Piłkarze WHERE drużyna=@drużyna; 
RETURN   @pensje
END;
GO

--Tablicowa
IF OBJECT_ID('Niedostępni') IS NOT NULL
DROP FUNCTION Niedostępni
GO
CREATE FUNCTION  Niedostępni()
        RETURNS TABLE
AS
       RETURN SELECT   imię,nazwisko, niedostępność as [data powrotu] ,
	                   DATEDIFF (DAY, GETDATE(),niedostępność) as [pozostało dni]
	   FROM Piłkarze 
	   WHERE niedostępność IS NOT NULL
GO

--TRIGGERY
--After
IF OBJECT_ID('zmiana_dodatku', 'TR') IS NOT NULL
DROP TRIGGER zmiana_dodatku
GO

CREATE TRIGGER zmiana_dodatku ON Zdarzenia_meczowe
AFTER   INSERT
AS 
IF ((SELECT typ FROM inserted) != 5)
BEGIN
DECLARE @temp1 varchar (30)
DECLARE @temp2 varchar (30)
DECLARE @zmiana INT

SET @temp1=  (SELECT imię FROM Piłkarze 
					WHERE nr_licencji=  (SELECT piłkarz FROM inserted));
SET @temp2=  (SELECT nazwisko FROM Piłkarze 
					WHERE nr_licencji=  (SELECT piłkarz FROM inserted));
SET @zmiana= (SELECT dodatek_płacowy FROM  Typy_zdarzeń 
						WHERE id_zdarzenia = (SELECT typ FROM inserted))

UPDATE
    Piłkarze
SET
    dodatki = dodatki + @zmiana

	WHERE nr_licencji= (SELECT nr_licencji FROM inserted)	
 PRINT 'Zmieniono wartość pola dodatki dla piłkarza ' 
		+ @temp1+ ' ' + @temp2 + ' o ' + CAST(@zmiana AS VARCHAR)+'€'
 END
 GO

 --Instead of
IF OBJECT_ID('podwójna_premia', 'TR') IS NOT NULL
DROP TRIGGER podwójna_premia
GO

CREATE TRIGGER podwójna_premia ON Zdarzenia_meczowe
INSTEAD OF INSERT
AS 
IF ((SELECT typ FROM inserted) = 1 and
                    (SELECT count(*) FROM Zdarzenia_meczowe z join inserted i on i.piłkarz=z.piłkarz					
					WHERE z.typ=1 and i.piłkarz=z.piłkarz and i.mecz=z.mecz)>1)
	BEGIN
    DECLARE @temp1 varchar (30)
    DECLARE @temp2 varchar (30)
    DECLARE @zmiana INT

   SET @temp1=  (SELECT imię FROM Piłkarze 
					WHERE nr_licencji=  (SELECT piłkarz FROM inserted));
    SET @temp2=  (SELECT nazwisko FROM Piłkarze 
					WHERE nr_licencji=  (SELECT piłkarz FROM inserted));
    SET @zmiana= (SELECT dodatek_płacowy FROM  Typy_zdarzeń 
						WHERE id_zdarzenia = (SELECT typ FROM inserted))
	UPDATE
    Piłkarze
	SET
    dodatki = dodatki + (2*@zmiana)
	WHERE nr_licencji= (SELECT nr_licencji FROM inserted)	
	PRINT ' Podwójna premia za ustrzelenie hattricka dla ' 
		+ @temp1+ ' ' + @temp2 + ' premia ' + CAST((@zmiana*2) AS VARCHAR)+'€'
	END
 ELSE
 BEGIN
 INSERT  into Zdarzenia_meczowe (mecz,piłkarz,typ,minuta) select mecz,piłkarz,typ,minuta from inserted
 END 
 GO







