insert into Base.ClientProductToCallCenter (ClientToProductID, CallCenterID, ActiveFlag, SourceCode, LastUpdateDate)
select 
    a.ClientToProductID, 
    '36334343-0000-0000-0000-000000000000' as CallCenterID, /*Default: Madison CallCenter*/ 
	1 as ActiveFlag, a.SourceCode, 
    getdate() as LastUpdateDate
from base.clienttoproduct a
join base.product b on a.productid=b.productid
join base.client c on c.ClientID = a.ClientId
left join ( select z.ClientToProductID
		from base.clientproducttocallcenter z
		join base.clienttoproduct y
		on z.clienttoproductid=y.clienttoproductid
		join base.callcenter x
		on z.callcenterid=x.callcenterid
		join base.product w
		on y.productid=w.productid
		where w.productcode in ('MAP','PDCHSP')) z
on a.ClientToProductID=z.ClientToProductID
--where b.productcode in ('MAP','PDCHSP')
where (
		b.productcode in ('PDCHSP')
		or(
			b.productcode in ('MAP') AND ClientCode IN ('COMO','PAGE1SLN')
		)
	)
and z.ClientToProductID is null