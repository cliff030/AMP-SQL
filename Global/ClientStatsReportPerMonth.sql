ALTER FUNCTION dbo.Custom_ClientStatsReportPerMonth(
	@StartDate datetime
) RETURNS @ClientList table(StartDate datetime, EndDate datetime, TotalClients int, NumNSF int, PercentNSF decimal(7,4), NumCancel int, PercentCancel decimal(7,4) )
AS
BEGIN
	DECLARE @EndDate datetime
	DECLARE @TotalClients int
	
	DECLARE @NumNSF int
	DECLARE @PercentNSF decimal(7,4)
	
	DECLARE @NumCancel int
	DECLARE @PercentCancel decimal(7,4)
	
	SET @StartDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@StartDate)-1),@StartDate),101)
	SET @EndDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@StartDate))-1),DATEADD(mm,1,@StartDate)),101)
	
	DECLARE @TempClientList table(
		ClientID int,
		AuditStatus varchar(500)
	)
	
	
	INSERT INTO @TempClientList( ClientID, AuditStatus )
	(
		SELECT ez.ClientID, ez.NewFieldValue
		FROM ezy_auditlog AS ez
		WHERE ez.ClientID IS NOT NULL 
		AND dbo.StartofDay(ez.DateTime) >= @StartDate
		AND dbo.StartofDay(ez.DateTime) <= @EndDate
		AND ez.FieldName = 'ClientStatus'
		AND (
			ez.NewFieldValue = 'NSF'
			OR ez.NewFieldValue = 'CANCEL'
		)
	)
	
	SET @TotalClients = ( SELECT COUNT(ClientID) FROM Clients WHERE dbo.StartOfDay(DateStart) <= @EndDate )
		
	SET @NumNSF = ( SELECT COUNT(DISTINCT ClientID) FROM @TempClientList WHERE AuditStatus = 'NSF' )	
	SET @PercentNSF = ( CAST(@NumNSF AS decimal(9,2)) / CAST(@TotalClients AS decimal(9,2)) )
	
	SET @NumCancel = ( SELECT COUNT(DISTINCT c.ClientID) FROM @TempClientList AS cl INNER JOIN Clients AS C ON c.ClientID = cl.ClientID WHERE AuditStatus = 'CANCEL' AND c.Active = 0 )	
	SET @PercentCancel = ( CAST(@NumCancel AS decimal(9,2)) / CAST(@TotalClients AS decimal(9,2)) )
	
	INSERT INTO @ClientList
	SELECT @StartDate AS 'Start Date', @EndDate AS 'End Date', @TotalClients AS 'Total Clients', @NumNSF AS 'Number of NSFs', @PercentNSF AS 'NSF %', @NumCancel AS 'Number of Cancels', @PercentCancel AS 'Cancel %'
	
	RETURN
END