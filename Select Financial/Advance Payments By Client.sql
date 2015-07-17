IF OBJECT_ID('Custom_AdvancePaymentsByClient','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_AdvancePaymentsByClient
END
GO

CREATE PROCEDURE Custom_AdvancePaymentsByClient(
	@ClientID int
)
AS
BEGIN

SELECT cc.AccountNumber, CONVERT(date,ISNULL(ISNULL(psd.RevisedDisbursementDate,psd.TargetDisbursement),psd.DueDate)) AS 'DisbursementDate', pp.DefaultAmount, psd.Paid
FROM ProgramScheduleDebtor AS psd
INNER JOIN ProgramPayments AS pp
	ON pp.ProgramScheduleDebtorID = psd.ProgramScheduleDebtorID
INNER JOIN ClientCred AS cc
	ON cc.ClientCredID = pp.ClientCredID
WHERE cc.CreditorID = 9302
AND cc.ClientID = @ClientID
AND psd.Paid = 0
AND pp.DefaultAmount > 0
ORDER BY ISNULL(ISNULL(psd.RevisedDisbursementDate,psd.TargetDisbursement),psd.DueDate) ASC

END
GO