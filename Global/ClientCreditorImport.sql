ALTER PROCEDURE Custom_ClientCreditorImport
AS
BEGIN
DECLARE @StartDate datetime
SET @StartDate = dbo.StartOfDay(DATEADD(day,-1,GetDate()))

--SET @StartDate = '2012-11-01 00:00:00'

DECLARE @EndDate datetime
SET @EndDate = dbo.StartOfDay(GETDATE())

declare @StartOfDayStartDate datetime
set @StartOfDayStartDate = dbo.StartofDay(@StartDate)
declare @StartOfNextDayEndDate datetime
set @StartOfNextDayEndDate = dbo.StartOfNextDay(@EndDate)

select c.clientid, ISNULL(c.wholename,c.LastName + ', ' + c.FirstName) AS 'wholename', ISNULL(c.Address1,'') AS 'Address1', ISNULL(c.Address2,'') AS 'Address2', ISNULL(c.City,'') AS 'City', ISNULL(c.State,'') AS 'State', ISNULL(c.Zip,'') AS 'Zip'
from leadclient lc 
	left join clients c on lc.clientid = c.leadclientid
	left join locations l on lc.locationid = l.locationid
	left join ezy_users eu on lc.counselor = eu.userid
where 	lc.exported = 1
	--and (@Counselor is null or lc.counselor = @Counselor)
	--and (@LocationID is null or lc.locationid = @LocationID)
	and lc.exporteddate >= @StartOfDayStartDate
	and lc.exporteddate < @StartOfNextDayEndDate
	and c.ClientID IS NOT NULL
order by lc.wholename
END