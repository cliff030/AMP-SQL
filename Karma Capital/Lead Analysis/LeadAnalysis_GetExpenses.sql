ALTER PROCEDURE Custom_LeadAnalysis_GetExpenses(
	@ClientID int
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT Subcategory AS 'Expense',BudgetAmount AS 'Amount'
	FROM LeadBudget 
	WHERE ClientID = @ClientID
END