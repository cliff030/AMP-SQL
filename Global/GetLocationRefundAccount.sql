IF OBJECT_ID('Custom_GetLocationRefundAccount', 'TF') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_GetLocationRefundAccount
END
GO

CREATE FUNCTION Custom_GetLocationRefundAccount(
	@LocationID int
)
RETURNS @RefundAccount TABLE (
	AccountNumber nvarchar(50) default null,
	RoutingNumber nvarchar(12) default null,
	BankName nvarchar(50) default null,
	BankCity nvarchar(100) default null,
	BankState nchar(2) default null
)
AS
BEGIN
	DECLARE @DBName nvarchar(max)
	SET @DBName = DB_NAME()

	DECLARE @BankAccountID int

	SET @BankAccountID = (
		SELECT cra.BankAccountID
		FROM [AMP-DC].[CreditsoftCompanies].[dbo].[CreditsoftRefundBankAccounts] AS cra
		INNER JOIN [AMP-DC].[CreditsoftCompanies].[dbo].[Companies] AS cc
			ON cra.CompanyID = cc.CompanyID
		WHERE cra.LocationID = @LocationID
		AND cc.CreditsoftDatabase = @DBName
		AND cra.Active = 1
	)

	INSERT INTO @RefundAccount
	(
		AccountNumber, RoutingNumber, BankName, BankCity, BankState
	)
	(
		SELECT AccountNumber, OriginatorID, BankName, 'Oldsmar', 'FL'
		FROM BankAccounts
		WHERE BankAccountID = @BankAccountID
	)

	RETURN
END
GO