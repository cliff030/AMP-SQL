-- CancelAfterOneSettlement
-- Returns the number of clients who made 1 settlement and then cancelled

CREATE FUNCTION Custom_CancelAfterOneSettlement()
RETURNS int
AS
BEGIN

DECLARE @ClientID int, @NumSettlements int

DECLARE @Custom_ClientCancelAfterOneSettlement table( ClientID int )

DECLARE ClientListCursor CURSOR FOR 
	SELECT DISTINCT c.ClientID
	FROM Clients AS c
	INNER JOIN ClientCred AS cr
		ON c.ClientID = cr.ClientID
	WHERE c.ClientStatus = 'CANCEL'
	AND (
		cr.AccountStatus = 'SETTLED' 
		OR cr.AccountStatus = 'PAID IN FULL'
	)
	ORDER BY c.ClientID
	
OPEN ClientListCursor
FETCH NEXT FROM ClientListCursor INTO @ClientID

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @NumSettlements = ( SELECT COUNT(*) FROM ClientCred WHERE ClientID = @ClientID AND (AccountStatus = 'SETTLED' OR AccountStatus = 'PAID IN FULL') )
	IF @NumSettlements = 1
	BEGIN
		INSERT INTO @Custom_ClientCancelAfterOneSettlement ( ClientID ) VALUES ( @ClientID )
	END
	
	FETCH NEXT FROM ClientListCursor INTO @ClientID
END

CLOSE ClientListCursor
DEALLOCATE ClientListCursor

RETURN (SELECT COUNT(*) FROM @Custom_ClientCancelAfterOneSettlement)
END