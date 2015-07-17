IF OBJECT_ID('Custom_MoneyInOut', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_MoneyInOut
END
GO

CREATE PROCEDURE Custom_MoneyInOut(
	@StartDate date,
	@EndDate date
)
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET @StartDate = ( SELECT CONVERT(date,dbo.Custom_StartOfMonth(@StartDate)) )
SET @EndDate = ( SELECT CONVERT(date,dbo.Custom_StartOfMonth(@EndDate)) )

DECLARE @CurDate date
SET @CurDate = @StartDate
	
DECLARE @CreditorID int

IF ( SELECT DB_NAME() ) = 'CSDATA8'
BEGIN
	SET @CreditorID = 9302
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_INC'
BEGIN
	SET @CreditorID = 9527
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_FFN'
BEGIN
	SET @CreditorID = 11054
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_KAR'
BEGIN
	SET @CreditorID = 10915
END
ELSE
BEGIN
	SET @CreditorID = 9302
END
		
CREATE TABLE #Custom_MoneyInOut ( ReviewDate date, MoneyOut money, MoneyIn money )

WHILE @CurDate <= @EndDate
BEGIN
	INSERT INTO #Custom_MoneyInOut ( ReviewDate, MoneyOut, MoneyIn ) 
	(
		SELECT @CurDate, MoneyOut, MoneyIn FROM dbo.Custom_MoneyInOutPerMonth(@CurDate,@CreditorID)
	)
	
	SET @CurDate = DATEADD(month,1,@CurDate)
END
	
SELECT * FROM #Custom_MoneyInOut
END
GO