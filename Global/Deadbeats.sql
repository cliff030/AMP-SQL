ALTER PROCEDURE Custom_DeadBeats(
	@ProgramScheduleID int,
	@DaysOverdue int
)
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE TABLE #Custom_DeadBeats ( ClientID int, PaidToDate money, MonthsInProgram int, DateOfFirstCharge date, AmountOwed money, DaysOverdue int )

INSERT INTO #Custom_DeadBeats ( ClientID, PaidToDate, MonthsInProgram, DateOfFirstCharge, AmountOwed, DaysOverdue )
(
	SELECT	c.ClientID, dbo.Custom_ServiceChargePaidToDate(c.ClientID) AS 'Paid to Date', DATEDIFF(month,dbo.Custom_DateOfFirstCharge(c.ClientID),GETDATE()) as 'Months Since First Charge', dbo.Custom_DateOfFirstCharge(c.ClientID) AS 'Date of First Charge', ( ( DATEDIFF(month,dbo.Custom_DateOfFirstCharge(c.ClientID),GETDATE()) * dbo.Custom_GetClientFee(c.ClientID) ) - dbo.Custom_ServiceChargePaidToDate(c.ClientID) ), MAX(t1.numofdays) AS 'DaysOverdue'
	FROM (
			SELECT pp.ClientID, DefaultAmount, pd.DueDate, DATEDIFF(day, pd.DueDate, GETDATE()) AS numofdays
			FROM ProgramPayments AS pp
			LEFT JOIN ProgramScheduleDebtor AS pd 
				ON pp.ProgramScheduleDebtorID = pd.ProgramScheduleDebtorID AND pd.DebtorType = 'Client'
			LEFT JOIN ClientCred AS cc 
				ON pp.ClientCredID = cc.ClientCredID
			LEFT JOIN Creditors AS cred 
				ON cc.CreditorID = cred.CreditorID
			WHERE pd.Paid = 0
			AND cred.CreditorType = 'MONTHLY AND F/S'
			AND pp.DefaultAmount <> 0
			AND pd.DueDate < GETDATE()
			AND (
				@ProgramScheduleID IS NULL 
				OR pd.ProgramScheduleID = @ProgramScheduleID
			)
			GROUP BY pp.ClientID, DefaultAmount, pd.DueDate
			HAVING	DATEDIFF(day, pd.DueDate, GETDATE()) >= @DaysOverdue
	) AS t1
	LEFT JOIN Clients AS c 
		ON t1.ClientID = c.ClientID
	LEFT JOIN Receipts r 
		ON c.ClientID = r.ClientID 
		AND r.ReceiptID = dbo.GetLastPayment(c.ClientID) 
		AND r.NSF = 0
	LEFT JOIN ProgramSchedules AS ps 
		ON c.ProgramScheduleID = ps.ProgramScheduleID
	WHERE c.Active = 1
	AND dbo.Custom_ReturnClientAccumulatedFunds(c.ClientID) >= dbo.Custom_GetClientFee(c.ClientID)
	AND c.ClientID <> 3
	GROUP BY c.ClientID, c.WholeName, c.DateEntered, r.DateReceived, ps.ProgramScheduleName
)

SELECT * FROM #Custom_DeadBeats WHERE AmountOwed > 0

END