IF OBJECT_ID('Custom_PaymentSearchByLocation') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_PaymentSearchByLocation
END

GO

CREATE PROCEDURE [dbo].[Custom_PaymentSearchByLocation](
	@StartDate date,
	@EndDate date,
--	@Amount money,
	@LocationID int
)
AS
BEGIN
	SELECT P.CheckID, P.ClientID, CONVERT(date,P.Created) AS 'PaymentDate', P.Amount, REPLACE(P.Description,'{ClientCred.AccountNumber}',CC.AccountNumber) AS 'Description', C.WholeName, cred.Name
	FROM Payments AS P
	INNER JOIN Clients AS C
		ON C.ClientID = P.ClientID
	INNER JOIN ClientCred AS CC
		ON CC.ClientCredID = P.ClientCredID
	INNER JOIN Creditors AS cred
		ON cred.CreditorID = cc.CreditorID
	WHERE 
	--P.CreditorID = 0
	C.LocationID = @LocationID
	--AND P.Amount = @Amount
	AND p.CreditorID IN ( 12652, 0 )
	AND CONVERT(date,P.Created) >= @StartDate AND CONVERT(date,P.Created) <= @EndDate
	AND P.Refunded = 0
	ORDER BY P.Created, P.ClientID, cred.Name ASC
END
GO