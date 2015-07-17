ALTER PROCEDURE Custom_NSFIssue
AS
BEGIN
DECLARE @StartDate datetime, @EndDate datetime 
SET @StartDate = dbo.StartofDay(dateadd(day,-1,getdate()))
SET @EndDate = dbo.startofday(GETDATE())

INSERT INTO Issues (
	CreatedUserID, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID 
)
	SELECT 'Admin',NULL,9,ClientID,'Client','Open','Payment marked NSF due to ' + ISNULL(NSFReason,'') + '. ' + dbo.Custom_NSFPolicy(ClientID),16,'NSF',5 
	FROM Receipts 
	WHERE NSFDate >= @StartDate AND NSFDate < @EndDate AND NSF = 1 AND ClientID <> 3
END