IF OBJECT_ID('Custom_TellerPositivePay','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_TellerPositivePay
END
GO

CREATE PROCEDURE Custom_TellerPositivePay
(
	@BankAccountID int,
	@CheckRunID int
)
AS
BEGIN

DECLARE @BankAccountNumber nvarchar(50)

SET @BankAccountNumber = ( SELECT AccountNumber FROM BankAccounts WHERE BankAccountID = @BankAccountID )

Declare @CheckRunTable table (      
			Name nvarchar(50),   Amount money,   CreditorID int,   CheckID int
		)    
		
		DECLARE @TempCheckTable table(      
			CheckID int,      Name nvarchar(50),      Amount money, CheckDate date
		)     
		
		INSERT INTO @CheckRunTable(      
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
				AND (        
					cred.Name = c.WholeName       OR cred.Name = c.LastName + ', ' + c.FirstName      
				)               
			)      
		)           
		
		INSERT INTO @TempCheckTable(    
			Name, Amount, CheckID, CheckDate    
		)      
		(    
			SELECT DISTINCT rbc.Name, SUM(rbc.Amount), MAX(cks.CheckID), cks.DateCreated 
			FROM @CheckRunTable AS rbc    
			INNER JOIN Checks AS cks     
				ON cks.CheckID = rbc.CheckID    
			WHERE rbc.Name <> 'Settlement Fee' 
			GROUP BY rbc.Name, cks.DateCreated 
		) 
		
		SELECT @BankAccountNumber AS 'Account Number', CheckID, CheckDate, Amount, 'RA', Name
		FROM @TempCheckTable 

END