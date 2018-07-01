USE dbad_s426281
GO

--VIEW 
IF OBJECT_ID('Kartkowicze','V') IS NOT NULL
DROP VIEW Kartkowicze
GO

CREATE VIEW Kartkowicze(imi�,nazwisko)
AS
   SELECT  imi� , nazwisko
   FROM    Pi�karze
   WHERE   nr_licencji in (SELECT DISTINCT nr_licencji from Pi�karze p join Zdarzenia_meczowe z 
					  on p.nr_licencji = z.pi�karz
					   WHERE z.typ =3 or z.typ=4)
GO

IF OBJECT_ID('Spotkania','V') IS NOT NULL
DROP VIEW Spotkania
GO

CREATE VIEW Spotkania(gospodarze, A ,B,go�cie)
AS
   SELECT d1.nazwa, m.bramki_gosp, m.bramki_go��,d2.nazwa   
   FROM Mecze m join Dru�yny d1 on  m.gospodarze = d1.id_dru�yny   join Dru�yny d2 on m.go�cie=d2.id_dru�yny    			
GO



--PROCEDURY
--------------------
--Operuj�ca na tabeli transakcyjnej
IF OBJECT_ID('Dodaj_zdarzenie','P') IS NOT NULL
DROP PROCEDURE Dodaj_zdarzenie
GO

CREATE PROCEDURE Dodaj_zdarzenie (@nr_meczu INT, @id_pi�karza INT, @typ INT, @minuta INT)
                         
AS
   IF NOT EXISTS ( SELECT * from Mecze WHERE nr_meczu = @nr_meczu)
        BEGIN
                RAISERROR (N'Bledny numer meczu: %s', 16, 1,  @nr_meczu )
        END
	IF NOT EXISTS ( SELECT * from Pi�karze WHERE nr_licencji = @id_pi�karza)
        BEGIN
                RAISERROR (N'Bledny numer licencji pi�karza: %s', 16, 1, @id_pi�karza  )
        END

	IF NOT EXISTS ( SELECT * from Typy_zdarze� WHERE id_zdarzenia = @typ)
        BEGIN
                RAISERROR (N'Bledny numer licencji pi�karza: %s', 16, 1, @typ )
        END

INSERT INTO Zdarzenia_meczowe( mecz, pi�karz, typ, minuta)
        VALUES (@nr_meczu, @id_pi�karza, @typ , @minuta)
GO

--Wstawiaj�ca
IF OBJECT_ID('Dodaj_pi�karza','P') IS NOT NULL
DROP PROCEDURE Dodaj_pi�karza
GO

CREATE PROCEDURE Dodaj_pi�karza (@imi� VARCHAR(20), @nazwisko VARCHAR(30), 
                          @narodowo�� VARCHAR(20), @dru�yna INT, @pensja MONEY)
                         
AS
   IF NOT EXISTS ( SELECT * from Dru�yny WHERE id_dru�yny = @dru�yna)
        BEGIN
                RAISERROR (N'Bledne id dru�yny: %s', 16, 1,  @dru�yna )
        END
	
INSERT INTO Pi�karze( imi� , nazwisko, narodowo�� ,dru�yna, pensja)
        VALUES (@imi�, @nazwisko, @narodowo�� , @dru�yna,@pensja)
GO

--Modyfikuj�ca
IF OBJECT_ID('Po_premii','P') IS NOT NULL
DROP PROCEDURE Po_premii
GO
CREATE PROCEDURE Po_premii (@dru�yna INT, @proc TINYINT )       
AS
BEGIN 
IF NOT EXISTS ( SELECT * from Dru�yny WHERE id_dru�yny = @dru�yna)
        BEGIN
                RAISERROR (N'Bledne id dru�yny: %s', 16, 1,  @dru�yna )
        END
UPDATE Pi�karze
set dodatki = dodatki - (1.0*(dodatki*@proc/100)) where dru�yna = @dru�yna
END;
GO

--Usuwaj�ca
IF OBJECT_ID('Usu�_pi�karza','P') IS NOT NULL
DROP PROCEDURE Usu�_pi�karza
GO

CREATE PROCEDURE Usu�_pi�karza (@imi� VARCHAR(20), @nazwisko VARCHAR(30))                         
AS  	
DELETE FROM Pi�karze WHERE imi� = @imi� and nazwisko = @nazwisko
GO

--Raportuj�ca
IF OBJECT_ID('Strzelcy','P') IS NOT NULL
DROP PROCEDURE Strzelcy
GO

CREATE PROCEDURE Strzelcy                        
AS  					   
SELECT imi�, nazwisko , count (typ) [liczba bramek]
FROM Pi�karze p join Zdarzenia_meczowe r
on p.nr_licencji = r.pi�karz 
GROUP BY imi�, nazwisko,typ
HAVING typ=1
ORDER BY count (typ) desc
GO

--FUNKCJE
--------------------
--Skalarna
IF OBJECT_ID('Ile_na_pensje') IS NOT NULL
DROP FUNCTION Ile_na_pensje
GO
CREATE FUNCTION Ile_na_pensje  (@dru�yna INT)
        RETURNS MONEY
AS
BEGIN
DECLARE @pensje MONEY; 
SELECT  @pensje = SUM (pensja+dodatki) FROM Pi�karze WHERE dru�yna=@dru�yna; 
RETURN   @pensje
END;
GO

--Tablicowa
IF OBJECT_ID('Niedost�pni') IS NOT NULL
DROP FUNCTION Niedost�pni
GO
CREATE FUNCTION  Niedost�pni()
        RETURNS TABLE
AS
       RETURN SELECT   imi�,nazwisko, niedost�pno�� as [data powrotu] ,
	                   DATEDIFF (DAY, GETDATE(),niedost�pno��) as [pozosta�o dni]
	   FROM Pi�karze 
	   WHERE niedost�pno�� IS NOT NULL
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

SET @temp1=  (SELECT imi� FROM Pi�karze 
					WHERE nr_licencji=  (SELECT pi�karz FROM inserted));
SET @temp2=  (SELECT nazwisko FROM Pi�karze 
					WHERE nr_licencji=  (SELECT pi�karz FROM inserted));
SET @zmiana= (SELECT dodatek_p�acowy FROM  Typy_zdarze� 
						WHERE id_zdarzenia = (SELECT typ FROM inserted))

UPDATE
    Pi�karze
SET
    dodatki = dodatki + @zmiana

	WHERE nr_licencji= (SELECT nr_licencji FROM inserted)	
 PRINT 'Zmieniono warto�� pola dodatki dla pi�karza ' 
		+ @temp1+ ' ' + @temp2 + ' o ' + CAST(@zmiana AS VARCHAR)+'�'
 END
 GO

 --Instead of
IF OBJECT_ID('podw�jna_premia', 'TR') IS NOT NULL
DROP TRIGGER podw�jna_premia
GO

CREATE TRIGGER podw�jna_premia ON Zdarzenia_meczowe
INSTEAD OF INSERT
AS 
IF ((SELECT typ FROM inserted) = 1 and
                    (SELECT count(*) FROM Zdarzenia_meczowe z join inserted i on i.pi�karz=z.pi�karz					
					WHERE z.typ=1 and i.pi�karz=z.pi�karz and i.mecz=z.mecz)>1)
	BEGIN
    DECLARE @temp1 varchar (30)
    DECLARE @temp2 varchar (30)
    DECLARE @zmiana INT

   SET @temp1=  (SELECT imi� FROM Pi�karze 
					WHERE nr_licencji=  (SELECT pi�karz FROM inserted));
    SET @temp2=  (SELECT nazwisko FROM Pi�karze 
					WHERE nr_licencji=  (SELECT pi�karz FROM inserted));
    SET @zmiana= (SELECT dodatek_p�acowy FROM  Typy_zdarze� 
						WHERE id_zdarzenia = (SELECT typ FROM inserted))
	UPDATE
    Pi�karze
	SET
    dodatki = dodatki + (2*@zmiana)
	WHERE nr_licencji= (SELECT nr_licencji FROM inserted)	
	PRINT ' Podw�jna premia za ustrzelenie hattricka dla ' 
		+ @temp1+ ' ' + @temp2 + ' premia ' + CAST((@zmiana*2) AS VARCHAR)+'�'
	END
 ELSE
 BEGIN
 INSERT  into Zdarzenia_meczowe (mecz,pi�karz,typ,minuta) select mecz,pi�karz,typ,minuta from inserted
 END 
 GO







