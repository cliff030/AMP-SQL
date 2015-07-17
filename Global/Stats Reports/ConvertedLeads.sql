-- ConvertedLeads
-- Returns the number of leads who converted to clients

ALTER FUNCTION Custom_ConvertedLeads(
	@StartDate date,
	@EndDate date
)
RETURNS int
AS
BEGIN
	RETURN (SELECT COUNT(*) from LeadClient where LeadStatus = 'CONVERTED' AND CONVERT(date,DateEntered) >= @StartDate AND CONVERT(date,DateEntered) <= @EndDate)
END