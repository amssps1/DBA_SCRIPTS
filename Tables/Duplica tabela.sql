
select * from SMSC


UPDATE SMSC set phoneTemplate = '()*(99)\d\d\d\d\d\d\d' where  smscid=1
UPDATE SMSC set phoneTemplate = '()*(96|91|92|93|2[1-9])\d\d\d\d\d\d\d' where  smscid=3


