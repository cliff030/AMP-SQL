ALTER PROCEDURE Custom_LeadAnalysis_GetDebts(
	@ClientID int
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @NumExpenses int, @NumDebits int
	SET @NumExpenses = ( SELECT COUNT(*) FROM LeadBudget WHERE ClientID = @ClientID )

	CREATE TABLE #Custom_LeadDebits (
		Name nvarchar(250), OrigDebt money, OrigMonthly money, InitialAPR decimal(11,9)
	)
	
	INSERT INTO #Custom_LeadDebits (Name, OrigDebt, OrigMonthly, InitialAPR) 
	(
	SELECT c.Name AS 'Creditor Name', lcc.OrigDebt AS 'Balance', lcc.OrigMonthly AS 'Monthly Payment', lcc.InitialAPR AS 'Interest Rate'
	FROM LeadClientCred AS lcc
	INNER JOIN Creditors AS c
		ON lcc.CreditorID = c.CreditorID
	WHERE lcc.ClientID = @ClientID
	AND lcc.CreditorID <> 0
	AND lcc.CreditorID <> 3
	)
	
	SET @NumDebits = ( SELECT COUNT(*) FROM #Custom_LeadDebits )
	
	WHILE @NumDebits < @NumExpenses 
	BEGIN
		INSERT INTO #Custom_LeadDebits 
		VALUES ( NULL, NULL, NULL, NULL )
		
		SET @NumDebits = ( SELECT COUNT(*) FROM #Custom_LeadDebits )
	END
	
	SELECT * FROM #Custom_LeadDebits 
END