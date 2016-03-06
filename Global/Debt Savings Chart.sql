IF OBJECT_ID('Custom_DebtSavingsChart') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_DebtSavingsChart
END
GO

CREATE PROCEDURE [dbo].[Custom_DebtSavingsChart](
	@ClientID int
)
AS
BEGIN
	CREATE TABLE #Custom_DebtSavingsChart(
		PayOffPlan nvarchar(max),
		PayOffTime int,
		PayOffAmount money,
		ChartColor nvarchar(15)
	)
	
	DECLARE @TextProjected nvarchar(max), @TextSettlement nvarchar(max), @TextCounseling nvarchar(max)

	DECLARE @OrigMonthlyPmt money
	
	DECLARE @TotalDebt money, @AvgInterest decimal(11,9), @MonthlyPaymentAmount money
	
	SET @TotalDebt = ( SELECT OrigDebt_CALCULATED FROM LeadClient WHERE ClientID = @ClientID )	
	
	SET @AvgInterest = ( 
		SELECT AVG(lcc.InitialAPR)
		FROM LeadClientCred AS lcc
		INNER JOIN Creditors AS c
			ON lcc.CreditorID = c.CreditorID
		WHERE lcc.ClientID = @ClientID
		AND lcc.CreditorID <> 0
		AND lcc.CreditorID <> 3 
	)
	
	SET @OrigMonthlyPmt = ( 
		SELECT SUM(lcc.OrigMonthly)
		FROM LeadClientCred AS lcc
		INNER JOIN Creditors AS c
			ON lcc.CreditorID = c.CreditorID
		WHERE lcc.ClientID = @ClientID
		AND lcc.CreditorID <> 0
		AND lcc.CreditorID <> 3 
	)
	
	DECLARE @ProjectedPayments money, @ProjectedPayOffTime int
	
	SET @ProjectedPayOffTime = ( SELECT dbo.Custom_CalculatePayOffTime(@AvgInterest, @TotalDebt, @OrigMonthlyPmt) )
	
	SET @ProjectedPayments = @OrigMonthlyPmt * @ProjectedPayOffTime	
	
	DECLARE @CounselingMonthlyPmt money
	DECLARE @CounselingPayments money
	DECLARE @CounselingPayOffTime int
	
	SET @CounselingMonthlyPmt = @TotalDebt * 0.03
	SET @CounselingPayOffTime = ( SELECT dbo.Custom_CalculatePayOffTime(@AvgInterest, @TotalDebt, @CounselingMonthlyPmt) )
	SET @CounselingPayments = @CounselingMonthlyPmt * @CounselingPayOffTime	
	
	DECLARE @SettlementPayments money
	DECLARE @SettlementPayOffTime int
	
	SET @SettlementPayOffTime = (
		SELECT dbo.PSDebtorProgramLength(clientid, 'lead')
		FROM LeadClient
		WHERE ClientID = @ClientID
	)
	
	SET @SettlementPayments = (
		SELECT CEILING(CONVERT(money,(OrigDebt_CALCULATED * 0.6)) / CONVERT(money,@SettlementPayOffTime)) * CONVERT(money,@SettlementPayOffTime)
		FROM LeadClient
		WHERE ClientID = @ClientID
	)
	
	SET @TextProjected = 'Make minimum payments' + CHAR(10) + dbo.Custom_DebtSavingsFormatDate(@ProjectedPayOffTime)
	SET @TextSettlement = 'Our Program' + CHAR(10) + CONVERT(nvarchar,@SettlementPayOffTime) + ' months'
	SET @TextCounseling = 'Credit Counseling' + CHAR(10) + dbo.Custom_DebtSavingsFormatDate(@CounselingPayOffTime)
	
	INSERT INTO #Custom_DebtSavingsChart VALUES ( @TextProjected, @ProjectedPayOffTime, @ProjectedPayments, 'gray' )
	INSERT INTO #Custom_DebtSavingsChart VALUES ( @TextCounseling, @CounselingPayOffTime, @CounselingPayments, 'silver' )
	INSERT INTO #Custom_DebtSavingsChart VALUES ( @TextSettlement, @SettlementPayOffTime, @SettlementPayments, 'red' )	
	
	SELECT * FROM #Custom_DebtSavingsChart
END

GO


