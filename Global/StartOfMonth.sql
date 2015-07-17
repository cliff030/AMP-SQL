ALTER FUNCTION dbo.Custom_StartOfMonth(
	@CurDate datetime
) RETURNS datetime
AS
BEGIN
	RETURN CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@CurDate)-1),@CurDate),101)
END