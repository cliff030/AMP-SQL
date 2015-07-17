ALTER PROCEDURE Custom_ClientStatsReport(
	@StartDate datetime,
	@EndDate datetime
)
AS
BEGIN
	SET @StartDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@StartDate)-1),@StartDate),101)
	SET @EndDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@EndDate)-1),@EndDate),101)

	DECLARE @CurDate datetime
	SET @CurDate = @StartDate
	
	CREATE TABLE #Report(
		CurMonth datetime,
		TotalClients int,
		NumNSF int,
		PercentNSF decimal(7,4),
		NumCancel int,
		PercentCancel decimal(7,4)
	)

	WHILE @CurDate <= @EndDate
	BEGIN
		INSERT INTO #Report
		SELECT @CurDate, TotalClients, NumNSF, PercentNSF, NumCancel, PercentCancel FROM dbo.Custom_ClientStatsReportPerMonth(@CurDate)
		
		SET @CurDate = dbo.Custom_GetNextMonth(@CurDate)
	END
	
	SELECT * FROM #Report
END