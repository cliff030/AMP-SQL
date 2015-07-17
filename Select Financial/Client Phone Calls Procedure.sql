IF OBJECT_ID('Custom_ClientPhoneCalls') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_ClientPhoneCalls
END
GO

CREATE PROCEDURE Custom_ClientPhoneCalls
AS
BEGIN
DECLARE @CurDate date
DECLARE @TestClientID int

SET @curdate= GETDATE()
SET @TestClientID=3

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','7 Day Phone Call',19,'7 day phone call',5,@curdate 
	FROM Clients AS c 
	WHERE ( DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 7 
	AND DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) <= 29 )
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=19 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','30 Day Phone Call',10,'30 day phone call',5,@curdate 
	FROM Clients c 
	WHERE ( DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 30 
	AND DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) <= 59 )
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=10 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','60 Day Phone Call',11,'60 day phone call',5,@curdate 
	FROM Clients c 
	WHERE ( DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 60 
	AND DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) <= 89 )
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=11 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','90 Day Phone Call',12,'90 day phone call',5,@curdate 
	FROM Clients c 
	WHERE ( DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 90 
	AND DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) <= 119 )
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=12 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','120 Day Phone Call',13,'120 day phone call',5,@curdate 
	FROM Clients c 
	WHERE ( DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 120 
	AND DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) <= 149 )
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=13 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','150 Day Phone Call',14,'150 day phone call',5,@curdate 
	FROM Clients c 
	WHERE ( DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 150 
	AND DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) <= 179 )
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=14 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)

INSERT INTO Issues (CreatedUserID, CreatedDate, AssignedUserID, AssignedDepartmentID, ClientID, ClientType, Status, Summary, CategoryID, category, LocationID, TaskDate )
( 
	SELECT DISTINCT 'Admin',@curdate,NULL,9,c.ClientID,'Client','Open','180 Day Phone Call',15,'180 day phone call',5,@curdate 
	FROM Clients c 
	WHERE DATEDIFF(day,dbo.StartOfDay(c.DateEntered),@curdate) >= 180
	AND c.ClientStatus NOT IN ('CANCEL','COMPLETED','ON HOLD')
	AND c.ClientID NOT IN (
		SELECT ClientID FROM Issues WHERE CategoryID=15 AND ClientID IS NOT NULL
	)
	AND c.ClientID<>@TestClientID
)
END
GO