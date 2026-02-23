BACKUP DATABASE db_cofidis_dah_interface_aux
TO DISK = 'Y:\BACKUP\db_cofidis_dah_interface_aux.bak'
WITH INIT, COMPRESSION, stats=10
Go
 
--Run Log Backup
BACKUP Log db_cofidis_dah_interface_aux
TO DISK = 'Y:\BACKUP\db_cofidis_dah_interface_aux_log.trn'
WITH INIT



----
-- EOS
--RESTORE Full Backup
RESTORE DATABASE db_cofidis_dah_interface_aux
FROM DISK = 'Y:\BACKUP\db_cofidis_dah_interface_aux.bak' 
 WITH NORECOVERY,stats=10,
 MOVE 'db_cofidis_dah_interface_FR' TO 'Y:\DATA\db_cofidis_dah_interface_FR_aux.mdf',
  MOVE 'db_cofidis_dah_interface_FR_INDX' TO 'Y:\DATA\db_cofidis_dah_interface_FR_INDX_aux.ndf',
   MOVE 'db_cofidis_dah_interface_FR_1' TO 'Y:\DATA\db_cofidis_dah_interface_FR_1_aux.ndf',
    MOVE 'db_cofidis_dah_interface_FR_2' TO 'Y:\DATA\db_cofidis_dah_interface_FR_2_aux.ndf',
 MOVE 'db_cofidis_dah_interface_FR_log' TO 'L:\LOG\db_cofidis_dah_interface_FR_log.ldf'
 GO
--RESTORE TLog Backup
RESTORE DATABASE db_cofidis_dah_interface_aux
FROM DISK = 'Y:\BACKUP\db_cofidis_dah_interface_aux_log.trn' 
 WITH NORECOVERY
 
--------------------------------------------------------------------------------------------------   


BACKUP DATABASE db_cofidis_dah_transactionlog
TO DISK = 'Y:\BACKUP\db_cofidis_dah_transactionlog.bak'
WITH INIT, COMPRESSION, stats=10
Go
 
--Run Log Backup
BACKUP Log db_cofidis_dah_transactionlog
TO DISK = 'Y:\BACKUP\db_cofidis_dah_transactionlog_log.trn'
WITH INIT


--EOS
RESTORE DATABASE db_cofidis_dah_transactionlog
FROM DISK = 'Y:\BACKUP\db_cofidis_dah_transactionlog.bak' 
 WITH NORECOVERY,stats=10,
 MOVE 'db_cofidis_dah_transactionlog' TO 'Y:\DATA\db_cofidis_dah_transactionlog.mdf',
  MOVE 'db_cofidis_dah_transactionlog_INDEX' TO 'Y:\DATA\db_cofidis_dah_transactionlog_INDEX.ndf',
 MOVE 'db_cofidis_dah_transactionlog_log' TO 'L:\LOG\db_cofidis_dah_transactionlog_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE db_cofidis_dah_transactionlog
FROM DISK = 'Y:\BACKUP\db_cofidis_dah_transactionlog_log.trn' 
 WITH NORECOVERY

-------

BACKUP DATABASE ExtratoCofidis
TO DISK = 'Y:\BACKUP\ExtratoCofidis.bak'
WITH INIT, COMPRESSION, stats=10
Go
 
--Run Log Backup
BACKUP Log ExtratoCofidis
TO DISK = 'Y:\BACKUP\ExtratoCofidis_log.trn'
WITH INIT


--EOS
RESTORE DATABASE ExtratoCofidis
FROM DISK = 'Y:\BACKUP\ExtratoCofidis.bak' 
 WITH NORECOVERY,stats=10,
 MOVE 'ExtratoCofidis' TO 'Y:\DATA\ExtratoCofidis.mdf',
  MOVE 'ExtratoCofidis_IDX' TO 'Y:\DATA\ExtratoCofidis_INDEX.ndf',
 MOVE 'ExtratoCofidis_log' TO 'L:\LOG\ExtratoCofidis_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE ExtratoCofidis
FROM DISK = 'Y:\BACKUP\ExtratoCofidis_log.trn' 
 WITH NORECOVERY

----------------------------------- 

-------

BACKUP DATABASE FactCofidis
TO DISK = 'Y:\BACKUP\FactCofidis.bak'
WITH INIT, COMPRESSION, stats=10
Go
 
--Run Log Backup
BACKUP Log FactCofidis
TO DISK = 'Y:\BACKUP\FactCofidis_log.trn'
WITH INIT


--EOS
RESTORE DATABASE FactCofidis
FROM DISK = 'Y:\BACKUP\FactCofidis.bak' 
 WITH NORECOVERY,stats=10,
 MOVE 'FactCofidis' TO 'Y:\DATA\FactCofidis.mdf',
  MOVE 'FactCofidis_IDX' TO 'Y:\DATA\FactCofidis_INDEX.ndf',
 MOVE 'FactCofidis_log' TO 'L:\LOG\FactCofidis_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE FactCofidis
FROM DISK = 'Y:\BACKUP\FactCofidis_log.trn' 
 WITH NORECOVERY










 
 /*
 

AdministracaoSistemas


db_cofidis_dah_interface_aux
db_cofidis_dah_transactionlog
dba_db
ExtratoCofidis
FactCofidis

Loms
master
model
msdb
PartnerBorderaux
ReconciliacaoBancaria
RiskLevel
SSISDB
tempdb
*/
