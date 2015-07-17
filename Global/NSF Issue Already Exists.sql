IF OBJECT_ID('Custom_NSFIssueAlreadyExists','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_NSFIssueAlreadyExists
END
GO

CREATE FUNCTION Custom_NSFIssueAlreadyExists(
	@ClientID int,
	@CurDate datetime
) RETURNS bit
AS
BEGIN
	DECLARE @IssueExists bit
	SET @IssueExists = 0
	
	DECLARE @IssueCount int
		
	SET @IssueCount = ( SELECT COUNT(*)
		FROM Custom_NSFIssueSingletons AS nis
		INNER JOIN Issues AS i
			ON nis.IssueID = i.IssueID
		WHERE i.ClientID = @ClientID
		AND (
			CreatedDate <= @CurDate
			AND CreatedDate >= dbo.StartOfDay(@CurDate)
		)
	)
	
	IF @IssueCount > 0
	BEGIN
		SET @IssueExists = 1
	END
	
	RETURN @IssueExists
END
GO