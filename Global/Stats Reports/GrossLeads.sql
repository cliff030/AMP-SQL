-- Gross Leads
-- Returns every lead ever created

ALTER FUNCTION Custom_GrossLeads(
	@StartDate date,
	@EndDate date
)
RETURNS int
AS
BEGIN
	RETURN (SELECT COUNT(*) FROM LeadClient WHERE CONVERT(date,DateEntered) >= @StartDate AND CONVERT(date,DateEntered) <= @EndDate)
END