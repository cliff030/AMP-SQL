IF OBJECT_ID('Custom_SettlementFeeProjection','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_SettlementFeeProjection
END
GO

CREATE PROCEDURE Custom_SettlementFeeProjection (
	@StartDate date,
	@EndDate date
)
AS
BEGIN

SELECT c.ClientID, CONVERT(date,psd.DueDate) AS 'DueDate', CONVERT(date,ISNULL(psd.RevisedDisbursementDate,psd.TargetDisbursement)) AS 'DisbursementDate', pp.DefaultAmount
FROM ProgramPayments AS pp
INNER JOIN ProgramScheduleDebtor AS psd
	ON psd.ProgramScheduleDebtorID = pp.ProgramScheduleDebtorID
INNER JOIN ClientCred AS cc
	ON cc.ClientCredID = pp.ClientCredID
INNER JOIN Clients AS c
	ON c.ClientID = cc.ClientID
WHERE cc.CreditorID = 4
AND cc.AccountStatus = 'OPEN'
AND c.Active = 1
AND pp.DefaultAmount > 0
AND (
	@StartDate <=
	CASE
	WHEN psd.RevisedDisbursementDate IS NOT NULL THEN CONVERT(date,psd.RevisedDisbursementDate)
	WHEN psd.RevisedDisbursementDate IS NULL AND psd.TargetDisbursement IS NOT NULL THEN CONVERT(date,psd.TargetDisbursement)
	ELSE CONVERT(date,psd.DueDate)
	END
)
AND (
	@EndDate >=
	CASE
	WHEN psd.RevisedDisbursementDate IS NOT NULL THEN CONVERT(date,psd.RevisedDisbursementDate)
	WHEN psd.RevisedDisbursementDate IS NULL AND psd.TargetDisbursement IS NOT NULL THEN CONVERT(date,psd.TargetDisbursement)
	ELSE CONVERT(date,psd.DueDate)
	END
)
ORDER BY ISNULL(psd.RevisedDisbursementDate,psd.TargetDisbursement) DESC

END
GO