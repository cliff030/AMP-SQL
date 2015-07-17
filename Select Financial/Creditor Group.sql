IF OBJECT_ID('Custom_CreditorNegotiations') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CreditorNegotiations
END
GO

CREATE PROCEDURE Custom_CreditorNegotiations
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @Newline nchar(2)
SET @Newline = CHAR(13) + CHAR(10)

DECLARE @CurDate datetime
SET @CurDate = GETDATE()

DECLARE @IssueText nvarchar(2000), @IssueCategoryID int, @IssueCategory nvarchar(25), @IssueSubCategoryID int

SET @IssueCategoryID = 21
SET @IssueCategory = ( SELECT Category FROM IssueCategories WHERE CategoryID = @IssueCategoryID )
SET @IssueText = 'Collection Agency: ' + @Newline + 'Rep''' + 's Name: ' + @Newline + 'Phone #: ' + @Newline + 'Extension: ' + @Newline + 'Current Balance: ' + @Newline + 'Offer: ' + @Newline + 'Counters: ' + @Newline + 'Cycle / Charge-off Date: ' + @Newline + 'Follow-up Date: '

DECLARE @CreditorGroupID int, @CreditorGroupName nvarchar(250)
DECLARE @DateOfFirstDraft datetime
DECLARE @DateInterval int 

DECLARE CreditorGroupsCursor CURSOR LOCAL FORWARD_ONLY STATIC FOR	
	SELECT DISTINCT CreditorGroupCreditorID 
	FROM Creditors 
	WHERE CreditorGroupCreditorID IS NOT NULL

OPEN CreditorGroupsCursor

FETCH NEXT FROM CreditorGroupsCursor
INTO @CreditorGroupID

WHILE @@FETCH_STATUS = 0
BEGIN

SET @DateInterval =
	CASE @CreditorGroupID
	WHEN 55 THEN 60 -- Kohls
	WHEN 92 THEN 90 -- US Bank
	WHEN 1217 THEN 60 -- Bank of America
	WHEN 1378 THEN 60 -- Chase
	WHEN 1400 THEN 60 -- Citi Card
	WHEN 1570 THEN 90 -- Discover
	WHEN 1696 THEN 90 -- GE Money Bank
	WHEN 1899 THEN 90 -- Macys
	WHEN 4651 THEN 90 -- Barclays
	WHEN 11357 THEN 330 -- Comenity
	END
	
SET @IssueSubCategoryID =
	CASE @CreditorGroupID
	WHEN 55 THEN 39 -- Kohls
	WHEN 92 THEN 40 -- US Bank
	WHEN 1217 THEN 41 -- Bank of America
	WHEN 1378 THEN 42 -- Chase
	WHEN 1400 THEN 43 -- Citi Card
	WHEN 1570 THEN 44 -- Discover
	WHEN 1696 THEN 45 -- GE Money Bank
	WHEN 1899 THEN 46 -- Macys
	WHEN 4651 THEN 47 -- Barclays
	WHEN 11357 THEN 48 -- Comenity
	ELSE NULL
	END

INSERT INTO Issues ( CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientCredID, ClientType, Status, Summary, CategoryID, category, IssueSubCategoryID, LocationID, TaskDate )
(
	SELECT DISTINCT 'Admin', @CurDate, NULL, 6, c.ClientID, cc.ClientCredID, 'Client', 'OPEN', @IssueText, @IssueCategoryID, @IssueCategory, @IssueSubCategoryID, 5, @CurDate
	FROM Creditors AS cr
	INNER JOIN ClientCred AS cc
		ON cc.CreditorID = cr.CreditorID
	INNER JOIN Clients AS c
		ON cc.ClientID = c.ClientID
	LEFT JOIN ClientCredNegotiation AS ccn
		ON ccn.ClientCredID = cc.ClientCredID 
	WHERE cr.CreditorGroupCreditorID = @CreditorGroupID
	AND c.ClientStatus NOT IN ('COMPLETED','CANCEL')
	AND DATEDIFF(day,CONVERT(date,(SELECT TOP 1 DateCredited FROM ACHBatchDetails WHERE ClientID = c.ClientID)),CONVERT(date,@CurDate)) >= @DateInterval
	AND ( ccn.Approved IS NULL OR ccn.Approved = 0 OR ( ccn.Processed IS NULL OR ccn.Processed = 0 ) )
	AND cc.AccountStatus = 'OPEN'
	AND NOT EXISTS ( SELECT ClientID FROM Issues WHERE ClientID = c.ClientID AND ClientID IS NOT NULL AND ClientCredID = cc.ClientCredID AND ClientCredID IS NOT NULL AND CategoryID = @IssueCategoryID AND IssueSubcategoryID = @IssueSubCategoryID )
)

FETCH NEXT FROM CreditorGroupsCursor
INTO @CreditorGroupID
END

CLOSE CreditorGroupsCursor
DEALLOCATE CreditorGroupsCursor

END
GO