IF OBJECT_ID('dbo.Custom_NSFPolicy','FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.Custom_NSFPolicy
END
GO

CREATE FUNCTION Custom_NSFPolicy(
	@ClientID int
) RETURNS nvarchar(500)
AS
BEGIN
	DECLARE @PolicyReason nvarchar(500)
	
	IF ( SELECT COUNT(ClientID) FROM Receipts WHERE ClientID = @ClientID AND NSF = 1 ) > 0
	BEGIN
		IF ( SELECT TOP 1 ClientID FROM Receipts WHERE ClientID = @ClientID AND NSF = 1 AND NSFReason IN ( 'INELIGIBLE', 'NOT AUTHORIZED', 'PAYMENT STOPPED', 'PYMT REFUS', 'REVOKED', 'STOP PAY', 'UNAUTH CORP', 'REFER TO MAKER' ) ) = @ClientID
		BEGIN
			SET @PolicyReason = 'Client NSF due to a hard return. ACH cannot be turned back on without new banking information and a voided check.'
		END
		ELSE IF ( SELECT COUNT(ReceiptID) FROM Receipts WHERE ClientID = @ClientID AND NSF = 1 AND CONVERT(date,DateReceived) >= DATEADD(year,-1,CONVERT(date,GETDATE())) ) >= 3
		BEGIN
			SET @PolicyReason = 'Client has more than 3 NSFs within the last year. ACH cannot be turned back on without contacting AMP.'
		END
		ELSE IF ( SELECT TOP 1 NSFReason FROM Receipts WHERE ClientID = @ClientID ORDER BY DateReceived DESC ) IN ('NO ACCOUNT','ACCOUNT NOT FOUND')
		BEGIN
			SET @PolicyReason = 'Client NSF due to invalid bank account information. ACH cannot be turned back on without new banking information and a voided check.' 
		END
		ELSE
		BEGIN
			SET @PolicyReason = 'Client not in violation of NSF policy. You may re-enable ACH.'
		END	
	END
	ELSE
	BEGIN
		SET @PolicyReason = 'Client not in violation of NSF policy. You may re-enable ACH.'
	END
		
	RETURN @PolicyReason
END
GO