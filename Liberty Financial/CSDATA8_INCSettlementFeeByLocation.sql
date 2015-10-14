USE CSDATA8_INC
GO

IF OBJECT_ID('Custom_CSDATA8_INCSettlementFeeByLocation','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CSDATA8_INCSettlementFeeByLocation
END
GO

CREATE PROCEDURE Custom_CSDATA8_INCSettlementFeeByLocation (
	@CheckRunID int,
	@BankAccountID int
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @CreditorID int
	SET @CreditorID = 4

	DECLARE @CompanyName nvarchar(150)    
	DECLARE @Address1 nvarchar(50)    
	DECLARE @City nvarchar(20)    
	DECLARE @State nvarchar(2)    
	DECLARE @Zip nvarchar(15)      
	SET @CompanyName = (SELECT REPLACE(CompanyName,',','') FROM SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @Address1 = (SELECT REPLACE(Address1,'-','') FROM SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @City = (SELECT City FROM SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @State = (SELECT State FROM SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @Zip = (SELECT ZIP FROM SystemTable WHERE CompanyName LIKE 'Account Management Plus%')
	
	CREATE TABLE #Custom_ChecksByLocation (
		LocationID int,
		CheckID int,
		Amount money,
		BankAccountID int
	)
	
	INSERT INTO #Custom_ChecksByLocation (
		LocationID, CheckID, Amount, BankAccountID
	)
	(
		SELECT c.LocationID, cks.CheckID, p.Amount, p.BankAccountID
		FROM Checks AS cks
		INNER JOIN Payments AS p
			ON p.CheckID = cks.CheckID
		INNER JOIN Clients AS c
			ON c.ClientID = p.ClientID
		WHERE cks.Voided = 0
		AND cks.BankAccountID = @BankAccountID
		AND cks.CheckRunID = @CheckRunID
		AND cks.CreditorID = @CreditorID
	)
	
	SELECT NULL AS 'CheckID', 
	@CompanyName AS 'CompanyName', 
	@CompanyName AS 'ContactName', 
	@Address1 AS 'Address', 
	NULL AS 'Address2',  
	@City AS 'City', 
	@State AS 'State', 
	@Zip AS 'PostalCode', 
	NULL AS 'Phone', NULL AS 'Email',     
	CASE(ccl.LocationID) WHEN 1 THEN 'Liberty Financial' WHEN 5 THEN 'Liberty Financial' WHEN 6 THEN 'Liberty Financial' ELSE 'Key Financial' END AS 'Payee',  
	NULL AS 'Date', 
	CONVERT(nvarchar,MAX(ccl.CheckID)) + CONVERT(nvarchar,ccl.LocationID) AS 'CheckNumber', 
	SUM(ccl.Amount) AS 'Amount', 
	'Required' AS 'SigReq', 
	NULL AS 'PrintOnCheck', 
	NULL AS 'Format',  
	ba.BankName AS 'BankName', 
	'Safety Harbor' AS 'BankCity', 
	'FL' AS 'BankState', 
	ba.OriginatorID AS 'RoutingNumber',  
	ba.AccountNumber AS 'AccountNumber', 
	NULL AS 'CustomRouting', 
	NULL AS 'FractionCode', 
	NULL AS 'CreditCardNumber',  
	NULL AS 'ExpirationDate', 
	NULL AS 'DeliveryDate', 
	NULL AS 'DeliveryStatus', 
	NULL AS 'ReIssue', NULL AS 'ReIssueDay',  
	NULL AS 'User1', 
	NULL AS 'User2', 
	NULL AS 'Notes', 
	'Settlement fee - Check # ' + CONVERT(nvarchar,MAX(ccl.CheckID)) + CONVERT(nvarchar,ccl.LocationID) AS 'Memo', 
	NULL AS 'Printed', 
	NULL AS 'EnteredBy', 
	NULL AS 'DateEntered', 
	NULL AS 'ModifiedBy', 
	NULL AS 'DateModified'
	FROM #Custom_ChecksByLocation AS ccl
	INNER JOIN BankAccounts AS ba
		ON ba.BankAccountID = ccl.BankAccountID
	GROUP BY ccl.LocationID, ba.BankName, ba.OriginatorID, ba.AccountNumber
END
GO