IF OBJECT_ID('Custom_GetRefundAccount', 'TF') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_GetRefundAccount
END
GO

CREATE FUNCTION Custom_GetRefundAccount()
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

	INSERT INTO @RefundAccount  ( 
		AccountNumber, RoutingNumber, BankName, BankCity, BankState
	)
	(
		SELECT cba.AccountNumber, cba.RoutingNumber, b.Name, b.City, b.[State]
		FROM [AMP-DC].[CreditsoftCompanies].[dbo].[CompanyBankAccounts] AS cba
		INNER JOIN [AMP-DC].[CreditsoftCompanies].[dbo].[Companies] AS c
			ON c.CompanyID = cba.CompanyID
		LEFT JOIN [AMP-DC].[CreditsoftCompanies].[dbo].[Banks] AS b
			ON cba.BankID = b.BankID
		WHERE c.CreditsoftDatabase = @DBName
		AND cba.AccountType = 'REFUND'
		AND cba.Active = 1
	)

	IF (SELECT COUNT(*) FROM @RefundAccount) <= 0
	BEGIN
		DECLARE @BankName nvarchar(50), @BankCity nvarchar(100), @BankState nchar(2)
		SET @BankName = (SELECT Name FROM [AMP-DC].[CreditsoftCompanies].[dbo].[Banks] WHERE BankID = 1)
		SET @BankCity = (SELECT City FROM [AMP-DC].[CreditsoftCompanies].[dbo].[Banks] WHERE BankID = 1)
		SET @BankState = (SELECT [State] FROM [AMP-DC].[CreditsoftCompanies].[dbo].[Banks] WHERE BankID = 1)

		INSERT INTO @RefundAccount (
			AccountNumber, RoutingNumber, BankName, BankCity, BankState
		)
		(
			SELECT AccountNumber, OriginatorID, @BankName, @BankCity, @BankState FROM BankAccounts WHERE BankAccountID = 0
		) 
	END

	RETURN
END
GO