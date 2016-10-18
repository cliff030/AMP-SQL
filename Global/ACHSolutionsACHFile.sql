IF OBJECT_ID('Custom_ACHSolutionsACHFile', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_ACHSolutionsACHFile
END
GO

CREATE PROCEDURE Custom_ACHSolutionsACHFile (
	@ACHBatchGroupID int
)
AS
BEGIN

SELECT 'ACH00700000252' AS 'Account Name', c.FirstName  + ' ' + c.LastName AS 'Name',
achd.Amount AS 'Amount', 'Debit' AS 'Transaction Type', 'PPD' AS 'SEC Code',
achb.ABA AS 'ABA Number', achb.BankAccountNumber AS 'Account Number',
CASE WHEN CONVERT(date,ach.BatchDate) < CONVERT(date,GETDATE())
THEN CONVERT(date,GETDATE())
ELSE CONVERT(date,ach.BatchDate)
END AS 'Effective Date', 
achb.AccType AS 'Account Type'
FROM ACHBatchGroup AS achbg
INNER JOIN ACHBatch AS ach
	ON ach.ACHBatchGroupID = achbg.ACHBatchGroupID
INNER JOIN ACHBatchDetails AS achd
	ON achd.ACHBatchID = ach.ACHBatchID
INNER JOIN ACHBankAccounts AS achb
	ON achb.ACHBankAccountID = achd.ACHBankAccountID
INNER JOIN Clients AS c
	ON c.ClientID = achd.ClientID
WHERE achbg.ACHBatchGroupID = @ACHBatchGroupID

END
GO