-- StatsReport
-- Runs the various StatsReports functions and returns a table containing our information

ALTER PROCEDURE Custom_Statsreports(
	@StartDate date,
	@EndDate date
)
AS
BEGIN
	DECLARE @AvgBalance money, @AvgMonths int, @AvgPayment money, @CancelsAfterSettle int, @CancelsNoDraft int, @CancelsWithRefund int, @Cancels90Days int, @CompletedClients int, @ConvertedLeads int, @GrossLeads int
	
	SET @AvgBalance = ( SELECT dbo.Custom_AvgBalance(@StartDate,@EndDate) )
	SET @AvgMonths = ( SELECT dbo.Custom_AvgMonthsInProgram(@StartDate,@EndDate) )
	SET @AvgPayment = ( SELECT dbo.Custom_AvgPayment(@StartDate,@EndDate) )
	SET @CancelsAfterSettle = ( SELECT dbo.Custom_CancelAfterSettlement(@StartDate,@EndDate) )
	SET @CancelsNoDraft = ( SELECT dbo.Custom_CancelsNoDraft(@StartDate,@EndDate) )
	SET @CancelsWithRefund = ( SELECT dbo.Custom_CancelsWithRefund(@StartDate,@EndDate) )
	SET @Cancels90Days = ( SELECT dbo.Custom_Cancels90Days(@StartDate,@EndDate) )
	SET @ConvertedLeads = ( SELECT dbo.Custom_ConvertedLeads(@StartDate,@EndDate) )
	SET @GrossLeads = ( SELECT dbo.Custom_GrossLeads(@StartDate,@EndDate) )
	
	DECLARE @PercentGrossLeads float
	DECLARE @PercentCancelNoDraft float
	DECLARE @PercentCancelRefund float
	DECLARE @PercentCancelAfterSettle float
	DECLARE @PercentCancel90Days float
	
	IF @GrossLeads = 0
	BEGIN
		SET @PercentGrossLeads = 0
	END
	ELSE
	BEGIN
		SET @PercentGrossLeads = ( SELECT CONVERT(float,@ConvertedLeads) / CONVERT(float,@GrossLeads) )
	END
	
	IF @ConvertedLeads = 0
	BEGIN
		SET @PercentCancelNoDraft = 0
		SET @PercentCancelRefund = 0
		SET @PercentCancelAfterSettle = 0
		SET @PercentCancel90Days = 0
	END
	ELSE
	BEGIN
		SET @PercentCancelNoDraft = ( SELECT CONVERT(float,@CancelsNoDraft) / CONVERT(float,@ConvertedLeads) )
		SET @PercentCancelRefund = ( SELECT CONVERT(float,@CancelsWithRefund) / CONVERT(float,@ConvertedLeads) )
		SET @PercentCancelAfterSettle = ( SELECT CONVERT(float,@CancelsAfterSettle) / CONVERT(float,@ConvertedLeads) )
		SET @PercentCancel90Days = ( SELECT CONVERT(float,@Cancels90Days) / CONVERT(float,@ConvertedLeads) )
	END
	
	SELECT @AvgBalance AS 'AvgBalance', @AvgMonths AS 'AvgMonths', @AvgPayment AS 'AvgPayment', @CancelsAfterSettle AS 'CancelsAfterSettle', @PercentCancelAfterSettle AS 'PercentCancelAfterSettle', @CancelsNoDraft AS 'CancelsNoDraft', @PercentCancelNoDraft AS 'PercentCancelNoDraft', @CancelsWithRefund AS 'CancelsWithRefund', @PercentCancelRefund AS 'PercentCancelWithRefund', @Cancels90Days AS 'Cancels90Days', @PercentCancel90Days AS 'PercentCancel90Days', @ConvertedLeads AS 'ConvertedLeads', @GrossLeads AS 'GrossLeads', @PercentGrossLeads AS 'GrossLeadPercentage'
END