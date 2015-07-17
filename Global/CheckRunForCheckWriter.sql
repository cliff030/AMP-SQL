IF OBJECT_ID('Custom_CheckRunForCheckWriter','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CheckRunForCheckWriter
END
GO

CREATE PROCEDURE Custom_CheckRunForCheckWriter (
	@CheckRunID int,   
	@BankAccountID int,     
	@NoLock int    
)    
AS    
BEGIN     
	IF @NoLock = 1     
	BEGIN       
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED     
	END      	
	DECLARE @TrustBankAccountID int
	SET @TrustBankAccountID = 0
	
	DECLARE @RefundBankName nvarchar(50), @RefundRoutingNumber nvarchar(9), @RefundAccountNumber nvarchar(50), @RefundBankCity nvarchar(20), @RefundBankState nvarchar(2)
	
	SET @RefundBankName = 'Synovus'
	SET @RefundBankCity = 'Oldsmar'
	SET @RefundBankState = 'FL'
	
	IF DB_NAME() = 'CSDATA8'
	BEGIN
		SET @RefundRoutingNumber = '063114166'
		set @RefundAccountNumber = '1004962724'
	END
	
	IF DB_NAME() = 'CSDATA8_INC'
	BEGIN
		SET @RefundRoutingNumber = '063114166'
		SET @RefundAccountNumber = '1004962708'
	END
	
	IF DB_NAME() = 'CSDATA8_FFN'
	BEGIN
		SET @RefundRoutingNumber = '063114166'
		SET @RefundAccountNumber = '1004962716'
	END
	
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
	
	IF @BankAccountID = @TrustBankAccountID
	BEGIN  
		SELECT NULL AS 'CheckID', 
		@CompanyName AS 'CompanyName', 
		'Bruce Boudreau' AS 'ContactName', 
		@Address1 AS 'Address', 
		NULL AS 'Address2',  
		@City AS 'City', 
		@State AS 'State', @Zip AS 'PostalCode', 
		NULL AS 'Phone', NULL AS 'Email',      
		REPLACE(c.FirstName + ' ' + c.LastName,',','') AS 'Payee',  
		NULL AS 'Date', 
		MAX(cks.CheckID) AS 'CheckNumber', 
		SUM(cks.Amount) AS 'Amount', 
		'Facsimile' AS 'SigReq', NULL AS 'PrintOnCheck', NULL AS 'Format',  
		@RefundBankName AS 'BankName', 
		@RefundBankCity AS 'BankCity', 
		@RefundBankState AS 'BankState', 
		@RefundRoutingNumber AS 'RoutingNumber',  
		@RefundAccountNumber AS 'AccountNumber', 
		NULL AS 'CustomRouting', NULL AS 'FractionCode', NULL AS 'CreditCardNumber',  NULL AS 'ExpirationDate', NULL AS 'DeliveryDate', NULL AS 'DeliveryStatus', NULL AS 'ReIssue', NULL AS 'ReIssueDay',  NULL AS 'User1', NULL AS 'User2', NULL AS 'Notes', 
		CONVERT(nvarchar,@CheckRunID) AS 'Memo', 
		NULL AS 'Printed', NULL AS 'EnteredBy', NULL AS 'DateEntered',  NULL AS 'ModifiedBy', NULL AS 'DateModified'     
		FROM Checks AS cks   
		INNER JOIN Payments AS p    
			ON p.CheckID = cks.CheckID 
			AND p.BankAccountID = cks.BankAccountID      
		INNER JOIN Clients AS c    
			ON c.ClientID = p.ClientID   
		INNER JOIN BankAccounts AS ba       
			ON ba.BankAccountID = p.BankAccountID   
		INNER JOIN Creditors AS cred    
			ON cks.CreditorID = cred.CreditorID   
		WHERE cks.Voided = 0    
		AND cks.CheckRunID = @CheckRunID    
		AND cks.BankAccountID = @BankAccountID  
		AND p.AccountNumber = 'CLIENT REFUND'
		GROUP BY c.LastName, c.FirstName, ba.BankName, ba.OriginatorID, ba.AccountNumber		
		ORDER BY Payee DESC     
	END  
	ELSE  
	BEGIN      
		SELECT NULL AS 'CheckID', 
		@CompanyName AS 'CompanyName', 
		@CompanyName AS 'ContactName', 
		@Address1 AS 'Address', 
		NULL AS 'Address2',  
		@City AS 'City', 
		@State AS 'State', 
		@Zip AS 'PostalCode', 
		NULL AS 'Phone', NULL AS 'Email',     
		REPLACE(cred.Name,',','') AS 'Payee',  
		NULL AS 'Date', 
		cks.CheckID AS 'CheckNumber', 
		cks.Amount, 
		'Required' AS 'SigReq', NULL AS 'PrintOnCheck', NULL AS 'Format',  
		ba.BankName AS 'BankName', 
		'Safety Harbor' AS 'BankCity', 
		'FL' AS 'BankState', 
		ba.OriginatorID AS 'RoutingNumber',  
		ba.AccountNumber AS 'AccountNumber', 
		NULL AS 'CustomRouting', NULL AS 'FractionCode', NULL AS 'CreditCardNumber',  NULL AS 'ExpirationDate', NULL AS 'DeliveryDate', NULL AS 'DeliveryStatus', NULL AS 'ReIssue', NULL AS 'ReIssueDay',  NULL AS 'User1', NULL AS 'User2', NULL AS 'Notes', 
		'For the benefit of '  + c.FirstName + ' ' + c.LastName AS 'Memo', 
		NULL AS 'Printed', NULL AS 'EnteredBy', NULL AS 'DateEntered',  NULL AS 'ModifiedBy', NULL AS 'DateModified'     
		FROM Checks AS cks   
		INNER JOIN Payments AS p    
			ON p.CheckID = cks.CheckID 
			AND p.BankAccountID = cks.BankAccountID      
		INNER JOIN Clients AS c    
			ON c.ClientID = p.ClientID   
		INNER JOIN BankAccounts AS ba       
			ON ba.BankAccountID = p.BankAccountID   
		INNER JOIN Creditors AS cred    
			ON cks.CreditorID = cred.CreditorID   
		WHERE cks.Voided = 0    
		AND cks.CheckRunID = @CheckRunID    
		AND cks.BankAccountID = @BankAccountID  
		AND p.AccountNumber <> 'CLIENT REFUND'  
		
		UNION
		
		SELECT NULL AS 'CheckID', 
		@CompanyName AS 'CompanyName', 
		@CompanyName AS 'ContactName', 
		@Address1 AS 'Address', 
		NULL AS 'Address2',  
		@City AS 'City', 
		@State AS 'State', @Zip AS 'PostalCode', 
		NULL AS 'Phone', NULL AS 'Email',      
		REPLACE(c.FirstName + ' ' + c.LastName,',','') AS 'Payee',  
		NULL AS 'Date', 
		MAX(cks.CheckID) AS 'CheckNumber', 
		SUM(cks.Amount) AS 'Amount', 
		'Required' AS 'SigReq', NULL AS 'PrintOnCheck', NULL AS 'Format',  
		ba.BankName AS 'BankName', 
		'Safety Harbor' AS 'BankCity', 'FL' AS 'BankState', 
		ba.OriginatorID AS 'RoutingNumber',  
		ba.AccountNumber AS 'AccountNumber', 
		NULL AS 'CustomRouting', NULL AS 'FractionCode', NULL AS 'CreditCardNumber',  NULL AS 'ExpirationDate', NULL AS 'DeliveryDate', NULL AS 'DeliveryStatus', NULL AS 'ReIssue', NULL AS 'ReIssueDay',  NULL AS 'User1', NULL AS 'User2', NULL AS 'Notes', 
		CONVERT(nvarchar,@CheckRunID) AS 'Memo', 
		NULL AS 'Printed', NULL AS 'EnteredBy', NULL AS 'DateEntered',  NULL AS 'ModifiedBy', NULL AS 'DateModified'    
		FROM Checks AS cks   
		INNER JOIN Payments AS p    
			ON p.CheckID = cks.CheckID 
			AND p.BankAccountID = cks.BankAccountID      
		INNER JOIN Clients AS c    
			ON c.ClientID = p.ClientID   
		INNER JOIN BankAccounts AS ba       
			ON ba.BankAccountID = p.BankAccountID   
		INNER JOIN Creditors AS cred    
			ON cks.CreditorID = cred.CreditorID   
		WHERE cks.Voided = 0    
		AND cks.CheckRunID = @CheckRunID    
		AND cks.BankAccountID = @BankAccountID  
		AND p.AccountNumber = 'CLIENT REFUND'
		GROUP BY c.LastName, c.FirstName, ba.BankName, ba.OriginatorID, ba.AccountNumber		
		ORDER BY Payee DESC  
	END
END
GO