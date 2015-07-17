IF OBJECT_ID('Custom_IssueAlreadyExists','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_IssueAlreadyExists
END
GO

CREATE FUNCTION Custom_IssueAlreadyExists(
	@ClientID int,
	@CurDate datetime,
	@CategoryID int
) RETURNS bit
AS
BEGIN
	DECLARE @IssueExists bit
	SET @IssueExists = 0
	
	DECLARE @IssueCount int
	
	SET @IssueCount = ( SELECT COUNT(*)
		FROM Issues
		WHERE ClientID = @ClientID
		AND CategoryID = @CategoryID
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