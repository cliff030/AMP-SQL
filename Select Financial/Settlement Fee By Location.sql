select c.LocationID, c.ClientID, c.WholeName, p.Amount 
from checks AS cks
inner join Payments as p
	on p.CheckID = cks.CheckID
inner join Clients AS c
	on c.ClientID = p.ClientID
where cks.checkid = 61285