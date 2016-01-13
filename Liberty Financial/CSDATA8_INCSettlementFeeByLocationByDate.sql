IF OBJECT_ID('Custom_CSDATA8_INCSettlementFeeByLocationByDate','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CSDATA8_INCSettlementFeeByLocationByDate
END
GO

CREATE PROCEDURE Custom_CSDATA8_INCSettlementFeeByLocationByDate
(   
	@StartDate date,
	@EndDate date
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @CreditorID int
	SET @CreditorID = 4
	
	SELECT CASE(c.LocationID) WHEN 1 THEN 'Liberty Financial' WHEN 5 THEN 'Liberty Financial' WHEN 6 THEN 'Liberty Financial' ELSE 'Key Financial' END AS 'Location',
	SUM(p.Amount) AS 'Amount', 
	CONVERT(date,cks.DateCreated) AS 'DateCreated'
	FROM Checks AS cks
	INNER JOIN Payments AS p
		ON p.CheckID = cks.CheckID
	INNER JOIN Clients AS c
		ON c.ClientID = p.ClientID
	WHERE cks.Voided = 0
	AND cks.CreditorID = @CreditorID
	AND CONVERT(date,cks.DateCreated) >= @StartDate
	AND CONVERT(date,cks.DateCreated) <= @EndDate
	GROUP BY CONVERT(date,cks.DateCreated), c.LocationID
	ORDER BY CONVERT(date,cks.DateCreated) ASC
END
GO