IF OBJECT_ID('Custom_CheckWriterSettlementFees','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CheckWriterSettlementFees
END
GO

CREATE PROCEDURE Custom_CheckWriterSettlementFees
(
	@CheckRunID int,   
	@BankAccountID int
)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

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

DECLARE @Payee nvarchar(50)
DECLARE @CreditorID int

IF DB_NAME() = 'CSDATA8'
BEGIN
	SET @Payee = 'Select Financial'
	SET @CreditorID = 4
END    
ELSE IF DB_NAME() = 'CSDATA8_INC'
BEGIN
	SET @Payee = 'Liberty Financial'
	SET @CreditorID = 4
END
ELSE IF DB_NAME() = 'CSDATA8_FFN'
BEGIN
	SET @Payee = 'First Financial'
	SET @CreditorID = 11048
END

SELECT NULL AS 'CheckID', 
@CompanyName AS 'CompanyName', 
@CompanyName AS 'ContactName', 
@Address1 AS 'Address', 
NULL AS 'Address2',  
@City AS 'City', 
@State AS 'State', 
@Zip AS 'PostalCode', 
NULL AS 'Phone', NULL AS 'Email',     
@Payee AS 'Payee',  
NULL AS 'Date', 
MAX(DISTINCT cks.CheckID) AS 'CheckNumber', 
SUM(DISTINCT cks.Amount) AS 'Amount', 
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
'Settlement fee - Check # ' + CONVERT(nvarchar,MAX(DISTINCT cks.CheckID)) AS 'Memo', 
NULL AS 'Printed', 
NULL AS 'EnteredBy', 
NULL AS 'DateEntered', 
NULL AS 'ModifiedBy', 
NULL AS 'DateModified'     
FROM Checks AS cks   
INNER JOIN Payments AS p    
	ON p.CheckID = cks.CheckID 
	AND p.BankAccountID = cks.BankAccountID       
INNER JOIN BankAccounts AS ba       
	ON ba.BankAccountID = p.BankAccountID    
WHERE cks.Voided = 0    
AND cks.CheckRunID = @CheckRunID    
AND cks.BankAccountID = @BankAccountID    
AND p.CreditorID = @CreditorID
GROUP BY ba.BankName, ba.OriginatorID, ba.AccountNumber
ORDER BY Payee DESC    

END
GO