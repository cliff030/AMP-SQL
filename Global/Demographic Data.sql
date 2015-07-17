select c.ClientID, c.WholeName, c.ClientStatus, SUM(ci.IncomeValue) AS 'Total Income', cs.TotDebt AS 'Total Debt', cs.Sex, cs.DOB AS 'Birthday'
from clientincome AS ci
right join clients as c
	on c.ClientID = ci.ClientID
left join ClientStats as cs
	on cs.ClientID = c.ClientID
GROUP BY c.ClientID, c.WholeName, c.ClientStatus, cs.TotDebt, cs.Sex, cs.DOB