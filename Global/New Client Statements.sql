ALTER FUNCTION Custom_NewClients(
	@ClientID int
) RETURNS tinyint
AS
BEGIN
	DECLARE @count int
	DECLARE @foo tinyint
	
	DECLARE @StartMonth int
	DECLARE @StartYear int

	Declare @StartDate as Datetime, @EndDate as Datetime, @EndDate2 as Datetime, @Date datetime
	set @Date = dbo.startofday(GETDATE())

	set @StartDate = dateadd(MONTH,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
	set @EndDate = dateadd(SECOND,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
	set @EndDate2 = dateadd(MONTH,+1,@EndDate)
	
	SET @count = (
		SELECT COUNT(r.ReceiptID)
		FROM Receipts AS r
		RIGHT JOIN Clients AS c
			ON r.ClientID = c.ClientID
		WHERE r.ClientID = @ClientID
	)
	
	DECLARE @ReceiptDate datetime
	
	IF @count <= 1	
	BEGIN
		SET @ReceiptDate = (
			SELECT r.DateReceived
			FROM Receipts AS r
			WHERE r.ClientID = @ClientID
		)
		
		IF ( @ReceiptDate >= @StartDate AND @ReceiptDate <= @EndDate2 )
			SET @foo = 1
		ELSE
			SET @foo = 0
	END
	ELSE
	BEGIN
		SET @foo = 0
	END
	
	RETURN @foo
END