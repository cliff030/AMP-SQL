IF OBJECT_ID('dbo.Custom_ACHForNSFClients','TF') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.Custom_ACHForNSFClients
END
GO

CREATE FUNCTION Custom_ACHForNSFClients(
	@ClientID int
) RETURNS @IsACH table( ClientID int )
AS
BEGIN
	DECLARE @EnableACH bit
	SET @EnableACH = 1
	
	IF ( SELECT COUNT(ClientID) FROM Receipts WHERE ClientID = @ClientID AND NSF = 1 ) > 0
	BEGIN
		IF ( SELECT TOP 1 ClientID FROM Receipts WHERE ClientID = @ClientID AND NSF = 1 AND NSFReason IN ( 'INELIGIBLE', 'NOT AUTHORIZED', 'PAYMENT STOPPED', 'PYMT REFUS', 'REVOKED', 'STOP PAY', 'UNAUTH CORP', 'REFER TO MAKER' ) ) = @ClientID
		BEGIN
			SET @EnableACH = 0 
		END
		ELSE IF ( SELECT COUNT(ReceiptID) FROM Receipts WHERE ClientID = @ClientID AND NSF = 1 AND CONVERT(date,DateReceived) >= DATEADD(year,-1,CONVERT(date,GETDATE())) ) >= 3
		BEGIN
			SET @EnableACH = 0 
		END
		ELSE IF ( SELECT TOP 1 NSFReason FROM Receipts WHERE ClientID = @ClientID ORDER BY DateReceived DESC ) IN ('NO ACCOUNT','ACCOUNT NOT FOUND')
		BEGIN
			SET @EnableACH = 0 
		END
		ELSE
		BEGIN
			SET @EnableACH = 1 
		END		
	END
	
	IF ( @ClientID = 3 )
	BEGIN
		SET @EnableACH = 0
	END
	
	IF @EnableACH = 1
	BEGIN 
		INSERT INTO @IsACH VALUES ( @ClientID )
	END
	
	RETURN
END
GO