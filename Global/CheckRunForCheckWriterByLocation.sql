IF OBJECT_ID('Custom_CheckRunForCheckWriterByLocation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CheckRunForCheckWriterByLocation
END
GO

CREATE PROCEDURE [dbo].[Custom_CheckRunForCheckWriterByLocation] (
	@CheckRunID int,   
	@BankAccountID int 
)    
AS    
BEGIN          
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED   	

	DECLARE @TrustBankAccountID int
	SET @TrustBankAccountID = 0
	
	DECLARE @SystemTable table (
		CompanyName nvarchar(512),
		Address1 nvarchar(200),
		Address2 nvarchar(10) null,
		City nvarchar(100),
		[State] nvarchar(100),
		Zip nvarchar(20)
	)
	INSERT INTO @SystemTable ( CompanyName, Address1, Address2, City, [State], Zip ) ( select * from dbo.Custom_GetAMPAddress() )

	DECLARE @CompanyName nvarchar(150)    
	DECLARE @Address1 nvarchar(50)    
	DECLARE @City nvarchar(20)    
	DECLARE @State nvarchar(2)    
	DECLARE @Zip nvarchar(15)      
	SET @CompanyName = (SELECT REPLACE(CompanyName,',','') FROM @SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @Address1 = (SELECT REPLACE(Address1,'-','') FROM @SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @City = (SELECT City FROM @SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @State = (SELECT State FROM @SystemTable WHERE CompanyName LIKE 'Account Management Plus%')    
	SET @Zip = (SELECT ZIP FROM @SystemTable WHERE CompanyName LIKE 'Account Management Plus%')                 
	
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
		(SELECT BankName FROM dbo.Custom_GetLocationRefundAccount(c.LocationID)) AS 'BankName', 
		(SELECT BankCity FROM dbo.Custom_GetLocationRefundAccount(c.LocationID)) AS 'BankCity', 
		(SELECT BankState FROM dbo.Custom_GetLocationRefundAccount(c.LocationID)) AS 'BankState', 
		(SELECT RoutingNumber FROM dbo.Custom_GetLocationRefundAccount(c.LocationID)) AS 'RoutingNumber',  
		(SELECT AccountNumber FROM dbo.Custom_GetLocationRefundAccount(c.LocationID)) AS 'AccountNumber', 
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
		GROUP BY c.LastName, c.FirstName, ba.BankName, ba.OriginatorID, ba.AccountNumber, c.LocationID		
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
		c.FirstName + ' ' + c.LastName + ' ' + cc.AccountNumber AS 'Memo',
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
		LEFT JOIN ClientCred AS cc
			ON p.ClientCredID = cc.ClientCredID   
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
