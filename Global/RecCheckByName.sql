IF OBJECT_ID('Custom_RecCheckByname') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_RecCheckByname
END
GO

CREATE PROCEDURE Custom_RecCheckByname(
	@LastName nvarchar(200),
	@Amount money,
	@CreditorID int = NULL
)
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF @CreditorID IS NULL
BEGIN

SELECT ck.CheckID, cr.Name, c.ClientID, c.WholeName, CONVERT(date,ck.DateCreated) AS DateCreated, p.Amount, CONVERT(date,ck.DateCleared) AS DateCleared
FROM Payments AS p 
INNER JOIN Checks AS ck
	ON ck.CheckID = p.CheckID
INNER JOIN Creditors AS cr
	ON cr.CreditorID = ck.CreditorID
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
WHERE c.LastName LIKE @LastName + '%'
AND p.Amount = ABS(@Amount) 
AND ck.Voided = 0
AND ck.CreditorID NOT IN (0,3,4,9302)
ORDER BY ck.DateCreated ASC

IF @@ROWCOUNT = 0
BEGIN
	SELECT ck.CheckID, cr.Name, c.ClientID, c.WholeName, CONVERT(date,ck.DateCreated) AS DateCreated, p.Amount, CONVERT(date,ck.DateCleared) AS DateCleared
	FROM Payments AS p 
	INNER JOIN Checks AS ck
		ON ck.CheckID = p.CheckID
	INNER JOIN Creditors AS cr
		ON cr.CreditorID = ck.CreditorID
	INNER JOIN Clients AS c
		ON c.ClientID = p.ClientID
	WHERE c.FirstName LIKE @LastName + '%'
	AND p.Amount = ABS(@Amount) 
	AND ck.Voided = 0
	AND ck.CreditorID NOT IN (0,3,4,9302)
	ORDER BY ck.DateCreated ASC
END

END

ELSE
BEGIN
SELECT ck.CheckID, cr.Name,  c.ClientID, c.WholeName, CONVERT(date,ck.DateCreated) AS DateCreated, p.Amount, CONVERT(date,ck.DateCleared) AS DateCleared
FROM Payments AS p 
INNER JOIN Checks AS ck
	ON ck.CheckID = p.CheckID
INNER JOIN Creditors AS cr
	ON cr.CreditorID = ck.CreditorID
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
WHERE c.LastName LIKE @LastName + '%'
AND p.Amount = ABS(@Amount) 
AND ck.Voided = 0
AND ck.CreditorID = @CreditorID
ORDER BY ck.DateCreated ASC
END

END
GO