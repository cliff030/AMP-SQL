ALTER FUNCTION dbo.Custom_ClientAccumulatedFundsStartOfMonth(
	@ClientID int	
) RETURNS money
AS
BEGIN
DECLARE @AccumulatedFundsByDate table (rowid int, clientid int, creditorid int, clientcred int, name_creditor nvarchar(250),   postdate datetime, description nvarchar(100),pmt int, credit money,   debits money, sortorder int, batch bigint, summarydescription nvarchar(100), nsf bit)
DECLARE @AccumulatedFunds money


Declare @StartDate as Datetime
DECLARE @Date datetime
set @Date = dbo.startofday(GETDATE())

set @StartDate = dateadd(MONTH,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))


--DECLARE @AccumulatedFundsByDate table (postdate datetime,payment smallint, credit money,debits money)

-- CREATE TABLE #Custom_AccumulatedFundsByDate (
--	postdate datetime,
--	credit money,
--	debits money
-- )

INSERT INTO @AccumulatedFundsByDate(rowid, clientid, creditorid, clientcred, name_creditor, postdate, description,pmt, credit,   debits, sortorder, batch, summarydescription, nsf)
	SELECT r.receiptid AS 'rowid',
	r.clientid,
	0 AS 'creditorid',
	r.clientid AS 'clientcred',
	c.wholename AS 'name_creditor',
	r.datereceived AS 'postdate',
	r.memo AS 'description',
	0  AS 'pmt',
	CAST((CASE WHEN r.receiptamount < 0 THEN CONVERT(money, '0') ELSE r.receiptamount END) AS money) AS 'credit',
	CAST((CASE WHEN r.receiptamount >= 0 THEN CONVERT(money, '0') ELSE -r.receiptamount END) AS money) AS 'debits',
	0 AS sortorder,
	0 AS 'batch',
	CASE WHEN r.receiptamount < 0 THEN 'Reversed' ELSE 'Received' END AS 'summarydescription',
	r.NSF  
	FROM receipts r
	INNER JOIN clients c
		ON r.clientid = c.clientid
	LEFT JOIN bankaccounts ba
		ON r.bankaccountid = ba.bankaccountid
	WHERE r.clientid = @ClientID
	AND ba.isoperating = 0
	AND r.NSF = 0
	AND r.datereceived < @StartDate

	UNION

	SELECT r.receiptid AS 'rowid',
	r.clientid,
	0 AS 'creditorid',
	r.clientid AS 'clientcred',
	c.wholename AS 'name_creditor',
	r.datereceived AS 'postdate',
	'Manual Debits By Operator' AS 'description',
	1 AS 'pmt',
	CAST((CASE WHEN - cr.amount < 0 THEN CONVERT(money,'0') ELSE -cr.amount END) AS money) AS 'credit',
	CAST((CASE WHEN - cr.amount >= 0 THEN CONVERT(money,'0') ELSE cr.amount END) AS money) AS 'debits',
	0 AS sortorder,
	0 AS 'batch',
	CASE WHEN -cr.amount < 0 THEN 'Reversed' ELSE 'Received' END AS 'summarydescription',
	r.NSF  FROM receipts r
	INNER JOIN credits cr
		ON r.receiptid = cr.receiptid
	INNER JOIN clients c
		ON r.clientid = c.clientid
	LEFT JOIN bankaccounts ba
	ON  r.bankaccountid = ba.bankaccountid
	WHERE  cr.used = 1
	AND cr.batchid IS NULL
	AND r.nsf = 0
	AND r.clientid = @ClientID
	AND ba.isoperating = 0
	AND r.datereceived < @StartDate

	UNION

	SELECT r.receiptid AS 'rowid',
	r.clientid,
	0 AS 'creditorid',
	r.clientid AS 'clientcred',
	c.wholename AS 'name_creditor',
	dc.datereceived AS 'postdate',
	'Returned Item' AS 'description',
	2 AS 'pmt',
	CAST((CASE WHEN r.receiptamount < 0 THEN CONVERT(money,'0') ELSE r.receiptamount END) AS money) AS 'credit',
	CAST((CASE WHEN r.receiptamount >= 0 THEN CONVERT(money,'0') ELSE r.receiptamount END) AS money) AS 'debits',
	1 AS sortorder,
	0 AS 'batch',
	CASE WHEN r.receiptamount < 0 THEN 'Reversed' ELSE 'Received' END AS 'summarydescription',
	r.NSF  
	FROM receipts r
	INNER JOIN (
		SELECT ISNULL(r.nsfdate,r.datereceived) AS datereceived, r.ReceiptID
		FROM Receipts AS r
	) AS dc
		ON r.ReceiptID = dc.ReceiptID
	INNER JOIN clients c
		ON r.clientid = c.clientid
	LEFT JOIN bankaccounts ba
		ON  r.bankaccountid = ba.bankaccountid
	WHERE  r.nsf = 1
	AND r.clientid = @ClientID
	AND ba.isoperating = 0
	AND dc.datereceived < @StartDate
	
	UNION

	SELECT p.paymentid,
	p.clientid,
	p.creditorid,
	p.clientcredid AS 'clientcred',
	cred.name,
	dc.datereceived AS 'postdate',
	REPLACE(p.description,'{ClientCred.AccountNumber}',
	ISNULL(cc.AccountNumber_Masked,cc.AccountNumber)),
	p.type AS 'pmt',
	CONVERT(money,'0') AS expr1,
	p.amount,
	2 AS sortorder,
	p.batchid AS 'batch',
	'Paid' AS 'summarydescription',
	0
	FROM payments p
	INNER JOIN creditors cred
		ON p.creditorid = cred.creditorid
	LEFT JOIN checks cks
		ON p.checkid = cks.checkid
	AND p.bankaccountid = cks.bankaccountid
	LEFT JOIN bankaccounts ba
		ON p.bankaccountid = ba.bankaccountid
	LEFT JOIN ClientCred cc
		ON cc.ClientCredID = p.ClientCredID
	INNER JOIN (
		SELECT (CASE WHEN cks.datecreated IS NULL THEN p.created ELSE cks.datecreated END) AS datereceived, cks.CheckID
		FROM Checks AS cks
		LEFT JOIN Payments AS p
			ON p.CheckID = cks.CheckID
	) AS dc
		ON dc.CheckID = cks.CheckID
	WHERE p.clientid = @ClientID  
	AND p.type in (2,4,5)
	AND ba.isoperating = 0 	
	AND ba.BankAccountID = 0
	AND dc.datereceived < @StartDate
	ORDER BY postdate ASC
	
	SET @AccumulatedFunds = (SELECT CAST(ISNULL(SUM(credit-debits),0) AS decimal(9,2)) AS 'AccumulatedFunds' FROM @AccumulatedFundsByDate)
	
	RETURN @AccumulatedFunds
END