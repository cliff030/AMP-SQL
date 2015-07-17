-- CompletedClients
-- Returns the number of completed clients

ALTER FUNCTION Custom_CompletedClients()
RETURNS int
AS
BEGIN
	RETURN (SELECT COUNT(*) FROM Clients WHERE ClientStatus = 'COMPLETED')
END