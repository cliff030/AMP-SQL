ALTER FUNCTION dbo.Custom_DebitsCreditsFunction(
	@ClientID int
) 
RETURNS int
AS
BEGIN
DECLARE @Custom_DebitsandCredits table (
	rowid int, clientid int, creditorid int, clientcred int, name_creditor nvarchar(250),   postdate datetime, description nvarchar(100),pmt int, credit money,   debits money, sortorder int, batch bigint, summarydescription nvarchar(100), nsf bit,
	starting_balance money
)

Declare @StartDate as Datetime, @EndDate as Datetime, @EndDate2 as Datetime, @Date datetime
set @Date = dbo.startofday(GETDATE())

set @StartDate = dateadd(MONTH,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
set @EndDate = dateadd(SECOND,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
set @EndDate2 = dateadd(MONTH,+1,@EndDate)

INSERT INTO @Custom_DebitsandCredits (
	rowid, clientid, creditorid, clientcred, name_creditor, postdate, description,pmt, credit,   debits, sortorder, batch, summarydescription, nsf
)
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
	CASE WHEN r.receiptamount < 0 THEN 'NSF Reversal' ELSE 'Received' END AS 'summarydescription',
	r.NSF  
	FROM receipts r
	INNER JOIN clients c
		ON r.clientid = c.clientid
	LEFT JOIN bankaccounts ba
		ON r.bankaccountid = ba.bankaccountid
	WHERE r.clientid = @ClientID
	--AND r.NSF = 0
	AND ba.isoperating = 0
	AND r.datereceived >= @StartDate AND r.datereceived <= @EndDate2

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
	AND r.datereceived >= @StartDate AND r.datereceived <= @EndDate2

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
	AND dc.datereceived >= @StartDate AND dc.datereceived <= @EndDate2
	ORDER BY 'postdate',sortorder


	
	RETURN (SELECT COUNT(rowid) FROM @Custom_DebitsandCredits)
--	SELECT @StartOfMonthFunds + SUM(credit-debits) FROM #Custom_DebitsAndCredits
END
