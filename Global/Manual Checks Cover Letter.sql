ALTER PROCEDURE Custom_ManualChecksCoverLetter (
	@CheckRunID int
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT cred.Name, cred.Address1, cred.Address2, cred.City, cred.State, cred.Zip, ck.CheckID 
	FROM CheckRun AS cr
	INNER JOIN Checks AS ck
		ON ck.CheckRunID = cr.CheckRunID
	INNER JOIN Creditors AS cred
		ON cred.CreditorID = ck.CreditorID
	WHERE cr.CheckRunID = @CheckRunID
END