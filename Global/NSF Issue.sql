IF OBJECT_ID('Custom_NSFIssue') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_NSFIssue
END
GO

CREATE PROCEDURE Custom_NSFIssue    
AS    
BEGIN    

DECLARE @DatabaseName nvarchar(max)

SET @DatabaseName = DB_NAME()

DECLARE @CurDate datetime, @CurTime time  
DECLARE @StartDate date, @EndDate date       

DECLARE @InsertedIssueID int

DECLARE @CreatedUserID nvarchar(20), @AssignedUserID nvarchar(20), @AssignedDepartmentID int, @ClientID int, @ClientType nvarchar(6), @Status nvarchar(20), @Summary nvarchar(2000), @CategoryID int, @Category nvarchar(25), @LocationID int

SET @CurDate = GETDATE()  
SET @CurTime = CAST(@CurDate as time)    
  
IF @CurTime >= '00:00:00' AND @CurTime <= '09:00:00'  
BEGIN   
	SET @StartDate = DATEADD(day,-1,@CurDate)   
END  
ELSE  
BEGIN   
	SET @StartDate = @CurDate  
END  

SET @EndDate = DATEADD(day,1,@StartDate)    

IF @DatabaseName = 'CSDATA8'
BEGIN
	SET @LocationID = 5
END
ELSE IF @DatabaseName = 'CSDATA8_INC' 
BEGIN
	SET @LocationID = 6
END
ELSE IF @DatabaseName = 'CSDATA8_FFN'
BEGIN
	SET @LocationID = 1
END
ELSE
BEGIN
	SET @LocationID = 1
END

SET @AssignedUserID = ( SELECT DefaultUserID FROM IssueCategories WHERE CategoryID = 16 )
SET @AssignedDepartmentID = ( SELECT DefaultDepartmentID FROM IssueCategories WHERE CategoryID = 16 )


DECLARE ClientListCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR 
	SELECT 'Admin',@AssignedUserID,9,ClientID,'Client','Open','Payment marked NSF due to ' + ISNULL(NSFReason,'') + '. ' + dbo.Custom_NSFPolicy(ClientID),16,'NSF'
	FROM Receipts       
	WHERE NSFDate >= @StartDate    
	AND NSFDate <= @EndDate    
	AND NSF = 1    
	AND ClientID <> 3   
	AND dbo.Custom_NSFIssueAlreadyExists(ClientID, @CurDate) = 0

OPEN ClientListCursor

FETCH NEXT FROM ClientListCursor
INTO @CreatedUserID, @AssignedUserID, @AssignedDepartmentID, @ClientID, @ClientType, @Status, @Summary, @CategoryID, @Category

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO Issues (      
		CreatedUserID, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID     
	) VALUES (
		@CreatedUserID, @AssignedUserID, @AssignedDepartmentID, @ClientID, @ClientType, @Status, @Summary, @CategoryID, @Category, @LocationID
	)
	
	SET @InsertedIssueID = SCOPE_IDENTITY()
	
	INSERT INTO Custom_NSFIssueSingletons ( IssueID ) VALUES ( @InsertedIssueID )
	
	FETCH NEXT FROM ClientListCursor
	INTO @CreatedUserID, @AssignedUserID, @AssignedDepartmentID, @ClientID, @ClientType, @Status, @Summary, @CategoryID, @Category
END

CLOSE ClientListCursor
DEALLOCATE ClientListCursor
	
END  
GO