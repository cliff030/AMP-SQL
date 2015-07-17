ALTER VIEW Custom_ClientTransactions
AS

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
	WHERE ba.isoperating = 0

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
	AND ba.isoperating = 0

	UNION

	

	SELECT p.paymentid,
	p.clientid,
	p.creditorid,
	p.clientcredid AS 'clientcred',
	cred.name,
	(CASE WHEN cks.datecreated IS NULL THEN p.created ELSE cks.datecreated END) AS 'postdate',
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
	WHERE p.type in (2,4,5)
	AND ba.isoperating = 0 
	
	