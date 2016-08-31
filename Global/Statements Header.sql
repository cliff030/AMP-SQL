IF OBJECT_ID('Custom_StatementsHeader', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_StatementsHeader
END
GO

CREATE PROCEDURE Custom_StatementsHeader
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED   

	SELECT 	Name AS 'CompanyName', Address1, Address2, City, State, Zip, (Select chardata from preferences where preference = 'PayTo') as PayTo,
	StatementNote3, ClientPhoneNumber, ClientFaxNumber
	FROM [AMP-DC].[CreditsoftCompanies].[dbo].[AMP]
END
GO