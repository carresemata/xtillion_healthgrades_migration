
CREATE OR REPLACE VIEW ODS1_STAGE_TEAM.BASE.VWUCALLCENTERDETAILS
AS

---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------

-- Base.vwuCallCenterDetails depends on:
--- Base.CallCenter
--- Base.CallCenterType
--- Base.ClientProductToCallCenter
--- Base.ClientToproduct
--- Base.CallCenterToEmail
--- Base.Email
--- Base.EmailType
--- Base.CallCenterToPhone
--- Base.Phone
--- Base.PhoneType
--- Base.Client
--- Base.Product


---------------------------------------------------------
--------------------- 1. Columns ------------------------
---------------------------------------------------------
-- clienttoproductid
-- callcenterid
-- callcentercode
-- callcentername
-- replydays
-- apptcutofftime
-- emailaddress
-- faxnumber

    select distinct
        cctc.clienttoproductid,
        cc.callcenterid,
        cc.callcentercode,
        cc.callcentername,
        case
            when cc.callcentercode in ('CC12','CC13','CC16','CC25','CC36','CC7','CC8','CC55') then 1
            when cc.callcentercode in ('CC1','CC10','CC11','CC14','CC15','CC17','CC18','CC19','CC2','CC21','CC22','CC23','CC24','CC26','CC27','CC28','CC3','CC4','CC5','CC6','CC9') then 2
            else cc.replydays
        end as replydays,
        case
            when cc.callcentercode in ('CC11','CC15','CC2','CC21','CC23','CC24','CC25','CC26','CC27','CC28','CC4') then '01:00:00.0000000'
            when cc.callcentercode in ('CC1') then '17:00:00.0000000'
            when cc.callcentercode in ('CC10','CC12','CC13','CC14','CC16','CC17','CC18','CC19','CC22','CC3','CC36','CC5','CC6','CC7','CC8','CC9') then '23:00:00.0000000'
            else cc.apptcutofftime
        end as apptcutofftime,
        email.emailaddress, 
        phone.phonenumber as faxnumber
    from base.callcenter cc
    join base.callcentertype cct on cc.callcentertypeid = cct.callcentertypeid and cct.callcentertypecode = 'CCTOAR'
    join base.clientproducttocallcenter cctc on cc.callcenterid = cctc.callcenterid and cctc.activeflag = 1
    join base.clienttoproduct cp on cctc.clienttoproductid = cp.clienttoproductid and cp.activeflag = 1
    left join base.callcentertoemail cce on cc.callcenterid = cce.callcenterid
    left join base.email email on cce.emailid = email.emailid
    left join base.emailtype et on cce.emailtypeid = et.emailtypeid and et.emailtypecode = 'EMLCC'
    join base.callcentertophone cctp on cc.callcenterid = cctp.callcenterid
    join base.phone phone on cctp.phoneid = phone.phoneid
    join base.phonetype pt on cctp.phonetypeid = pt.phonetypeid and pt.phonetypecode = 'PTCCFAX'
    where cctc.clienttoproductid != '5D6F65D5-F03D-4AA3-BE1E-45657799B4B0'

    union all


    select
    lctp.clienttoproductid,
    dcc.callcenterid,
    dcc.callcentercode,
    dcc.callcentername,
    case
        when dcc.callcentercode in ('CC12','CC13','CC16','CC25','CC36','CC7','CC8','CC55') then 1
        when dcc.callcentercode in ('CC1','CC10','CC11','CC14','CC15','CC17','CC18','CC19','CC2','CC21','CC22','CC23','CC24','CC26','CC27','CC28','CC3','CC4','CC5','CC6','CC9') then 2
        else dcc.replydays
    end as replydays,
    case
        when dcc.callcentercode in ('CC11','CC15','CC2','CC21','CC23','CC24','CC25','CC26','CC27','CC28','CC4') then '01:00:00.0000000'
        when dcc.callcentercode in ('CC1') then '17:00:00.0000000'
        when dcc.callcentercode in ('CC10','CC12','CC13','CC14','CC16','CC17','CC18','CC19','CC22','CC3','CC36','CC5','CC6','CC7','CC8','CC9') then '23:00:00.0000000'
        else dcc.apptcutofftime
    end as apptcutofftime,
    email.emailaddress, 
    phone.phonenumber as faxnumber
from
    base.clienttoproduct lctp
    join base.client dc on dc.clientid = lctp.clientid
    join base.product dp on dp.productid = lctp.productid
    join base.callcenter dcc on dcc.callcentercode = 'CC36'
    left join base.callcentertoemail lccte on dcc.callcenterid = lccte.callcenterid
    left join base.email email on lccte.emailid = email.emailid
    left join base.emailtype et on lccte.emailtypeid = et.emailtypeid and et.emailtypecode = 'EMLCC'
    join base.callcentertophone cctp on dcc.callcenterid = cctp.callcenterid
    join base.phone phone on cctp.phoneid = phone.phoneid
where
    dc.clientcode in ('PREMHP');   

