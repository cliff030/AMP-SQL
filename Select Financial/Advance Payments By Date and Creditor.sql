IF (OBJECT_ID('Custom_RepaymentsByCreditAndDate','P')) IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_RepaymentsByCreditAndDate
END
GO

CREATE PROCEDURE Custom_RepaymentsByCreditAndDate (
	@StartDate date,
	@EndDate date,
	@CreditorID integer
)
AS
BEGIN
	SELECT pp.ClientID, CONVERT(date,ISNULL(ISNULL(psd.RevisedDisbursementDate,psd.TargetDisbursement),psd.DueDate)) AS 'DisbursementDate', pp.DefaultAmount AS 'Amount', psd.Description, cc.Balance, cc.OrigDebt, cc.BalanceVerifiedOn
	FROM ProgramScheduleDebtor AS psd
	INNER JOIN ProgramPayments AS pp
		ON pp.ProgramScheduleDebtorID = psd.ProgramScheduleDebtorID
	INNER JOIN ClientCred AS cc
		ON cc.ClientCredID = pp.ClientCredID
	INNER JOIN Clients AS c
		ON c.ClientID = cc.ClientID
	WHERE cc.CreditorID = @CreditorID
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
	AND c.Active = 1
	AND pp.DefaultAmount > 0
	--ORDER BY ISNULL(ISNULL(psd.RevisedDisbursementDate,psd.TargetDisbursement),psd.DueDate) ASC
	ORDER BY cc.BalanceVerifiedOn ASC
END
GO