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
		CREATE TABLE #Custom_TempCheckRun (      
			Name nvarchar(50),   Amount money,   CreditorID int,   CheckID int    
		)    
		
		CREATE TABLE #Custom_foo(      
			CheckID int,      Name nvarchar(50),      Amount money    
		)     
		
		INSERT INTO #Custom_TempCheckRun (      
			Name, Amount, CreditorID, CheckID   
		)     
		(        
			(         
				SELECT c.FirstName + ' ' + c.LastName AS Name,
				cks.Amount,      
				cred.CreditorID,     
				cks.CheckID         
				FROM Checks AS cks     
				INNER JOIN Payments AS p      
					ON p.CheckID = cks.CheckID 
					AND p.BankAccountID = cks.BankAccountID        
				INNER JOIN Clients AS c      
					ON c.ClientID = p.ClientID     
				INNER JOIN Creditors AS cred           
					ON cks.CreditorID = cred.CreditorID         
				WHERE cks.Voided = 0       
				AND cks.CheckRunID = @CheckRunID      
				AND cks.BankAccountID = @BankAccountID
				AND p.AccountNumber = 'CLIENT REFUND'          
			)      
		)           
		
		INSERT INTO #Custom_foo (    
			Name, Amount, CheckID   
		)      
		(    
			SELECT DISTINCT rbc.Name, SUM(rbc.Amount), MAX(cks.CheckID)    
			FROM #Custom_TempCheckRun AS rbc    
			INNER JOIN Checks AS cks     
				ON cks.CheckID = rbc.CheckID    
			WHERE rbc.Name <> 'Settlement Fee' 
			GROUP BY rbc.Name   
		)      
		
		SELECT DISTINCT NULL AS 'CheckID', 
		@CompanyName AS 'CompanyName', 'Bruce Boudreau' AS 'ContactName', 
		@Address1 AS 'Address', NULL AS 'Address2',  
		@City AS 'City', 
		@State AS 'State', @Zip AS 'PostalCode', 
		NULL AS 'Phone', NULL AS 'Email',     
		foo.Name AS 'Payee',  
		NULL AS 'Date', 
		foo.CheckID AS 'CheckNumber', 
		foo.Amount, 
		'Facsimile' AS 'SigReq', NULL AS 'PrintOnCheck', NULL AS 'Format',  
		ba.BankName AS 'BankName', 
		'Safety Harbor' AS 'BankCity', 'FL' AS 'BankState', 
		ba.OriginatorID AS 'RoutingNumber',  
		ba.AccountNumber AS 'AccountNumber', 
		NULL AS 'CustomRouting', NULL AS 'FractionCode', NULL AS 'CreditCardNumber',  NULL AS 'ExpirationDate', NULL AS 'DeliveryDate', NULL AS 'DeliveryStatus', NULL AS 'ReIssue', NULL AS 'ReIssueDay',  NULL AS 'User1', NULL AS 'User2', NULL AS 'Notes', 
		@CheckRunID AS 'Memo', 
		NULL AS 'Printed', NULL AS 'EnteredBy', NULL AS 'DateEntered',  NULL AS 'ModifiedBy', NULL AS 'DateModified'     
		FROM #Custom_foo AS foo     
		INNER JOIN Payments AS p       
			ON p.CheckID = foo.CheckID     
		INNER JOIN BankAccounts AS ba       
			ON ba.BankAccountID = p.BankAccountID     
		ORDER BY Payee DESC     
	END  
	ELSE  
	BEGIN      
		SELECT DISTINCT NULL AS 'CheckID', 
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
		ORDER BY Payee DESC     
	END     
END
GO