IF OBJECT_ID('Custom_RefundCheck','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_RefundCheck
END
GO

CREATE PROCEDURE Custom_RefundCheck (
	@ClientID int,
	@HoldTime int = 10
)
AS
BEGIN

DECLARE @DaysSinceLastCharge int, @MailDate date
SET @DaysSinceLastCharge = (SELECT TOP 1 DATEDIFF(day,DateReceived,getdate()) FROM Receipts WHERE ClientID = @ClientID AND PaymentType <> 'REFUND' AND ReceiptAmount > 0 AND NSF = 0 ORDER BY CONVERT(date,DateReceived) DESC)

IF @DaysSinceLastCharge < @HoldTime
BEGIN
	SET @MailDate = DATEADD(day,(@HoldTime - @DaysSinceLastCharge),GETDATE())
END
ELSE
BEGIN
	SET @MailDate = GETDATE()
END

SELECT @MailDate

END
GO