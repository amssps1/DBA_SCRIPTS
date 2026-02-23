-- =============================================
-- Data Masking Script --
-- Can be used for every Country --
-- For every new Country insert the New Country's server and database data in the table #ProductionEnvironments
-- Countries being validated at this moment: Portugal, Russia and China.
--
-- Author:		VTXRM	
-- Create year: 2017
-- Update RFP: 2019-04-11 - Added validation to prevent the execution of this script in Production environments (PT, RU and CN).
-- =============================================

DECLARE @ServerName varchar(255),
@DatabaseName varchar(255)

IF OBJECT_ID('tempdb..#ProductionEnvironments') IS NOT NULL
DROP TABLE #ProductionEnvironments

CREATE TABLE #ProductionEnvironments (Client varchar(40), ProductionServerName varchar(60), ProductionDatabaseName varchar(40))

INSERT INTO #ProductionEnvironments VALUES ('Portugal', 'SQLPOACC1P\ACC1P', 'ACCIPIENS')
INSERT INTO #ProductionEnvironments VALUES ('Russia', 'SQLGLACC1P\GLACC1P', 'ACCIPIENS_P_RUS')
INSERT INTO #ProductionEnvironments VALUES ('China', 'SQLSGLIS1P\LIS1P', 'Accipiens_VWC_P')

-- For ervey new client
-- INSERT INTO #ProductionEnvironments VALUES ('NewCountry_Name', 'NewCountry_ProductionServerName', 'NewCountry_ProductionServerName')

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	@ServerName = CONVERT(varchar(255), SERVERPROPERTY('Servername')), 
		@DatabaseName = DB_NAME()

IF (SELECT COUNT(*) FROM #ProductionEnvironments WHERE ProductionServerName = @ServerName AND ProductionDatabaseName = @DatabaseName) > 0
BEGIN
	RAISERROR('Error - This script cannot be executed in PRODUCTION environment' , 10, 1);
	RETURN
END
ELSE
BEGIN

	BEGIN TRAN

	DECLARE @entityType int
	DECLARE @entityTypeAbrev nvarchar(20)
	DECLARE @entityId bigint
	DECLARE @entityNumber bigint

	DECLARE @FullName nvarchar(max)
	DECLARE @ShortName nvarchar(max)

	DECLARE @Street nvarchar(max)
	DECLARE @EmailAddress nvarchar(max)
	DECLARE @PhoneNumber nvarchar(max)

	DECLARE @RandNumber int
	DECLARE @BirthDate date
	DECLARE @NIB nvarchar (21)
	DECLARE @IBAN nvarchar (25)


	declare @CurEnt cursor -- cursor para as entidades
	declare @CurAddress cursor -- cursor para as moradas
	declare @CurPhones cursor -- cursor para os tlfs
	declare @CurEmails cursor
	declare @CurLegalDocType cursor
	declare @CurBankAccount cursor
	declare @CurIntervs cursor

	declare @phoneTypeCid int
	declare @emailTypeCid int
	declare @legaldocTypeCid int
	declare @streetTypeCid int
	declare @bankAccountTypeCid int
	declare @credOperIntervTypeId int
	declare @credOperIntervDid bigint
	declare @entityAdressId bigint
	declare @entityEmailId bigint
	declare @entityPhoneId bigint
	declare @entityLegalDocId bigint
	declare @legalDocNumber nvarchar (9)
	declare @bankAccountTid bigint
	declare @legalDocNumberOld nvarchar(9)
	declare @bankDid bigint

	DECLARE Cur Cursor static local FOR
	SELECT Cid,Abrev FROM EntityType
	OPEN Cur
	FETCH NEXT FROM Cur INTO @entityType, @entityTypeAbrev
	WHILE @@FETCH_STATUS = 0
	BEGIN

	SET @CurEnt = Cursor static local FOR
	SELECT did FROM Entity where EntityTypeCid=@entityType
	OPEN @CurEnt
	FETCH NEXT FROM @CurEnt INTO @entityId
		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			SET @RandNumber= FLOOR(RAND()*(28-1)+1);
		
			select @entityNumber=EntityNumber from Entity 
			where did=@entityId
			print @entityNumber

			SET  @FullName= @entityTypeAbrev + ' ' + cast(@entityNumber as nvarchar)
			SET  @ShortName = @FullName 
			/* 
			* ENTIDADE*/
		
			UPDATE entity set fullname=@FullName, ShortName=@ShortName where did=@entityId
		
			UPDATE Agenda set EntityName= @FullName where EntityDid=@entityId 
		
			UPDATE AssetRetakeProposal set EntityName = @FullName where EntityDid=@entityId 
		
			UPDATE ClaimInterv SET EntityName = @FullName where EntityDid = @entityId
		
			UPDATE LitInterv SET EntityName = @FullName where EntityDid = @entityId
		
			UPDATE EntityExternalNumber set External_EntityName = 'EXT_' + @FullName where EntityDid=@entityAdressId
		
			UPDATE CreditRecoveryExpense set Pay_EntityName='PAY_'+@FullName where Pay_EntityDid=@entityId
		
			UPDATE AssetRetake set SaleEntityName='SALE_'+@FullName where Recover_EntityDid=@entityId
		
		
			UPDATE person set 
			FirstName = @entityTypeAbrev, 
			LastName=cast(@entityNumber as nvarchar),
			PEPReference=null, 
			EmploymentCompany=null,
			EmploymentAddress=null,
			BirthDate = DATEADD(DAY,@RandNumber,BirthDate)
			where OwnerDid=@entityId
		
		
			/*
			 * INTERVS
			 */
			SET @CurIntervs = Cursor static local FOR
			select did, CredOperIntervType from CredOperInterv where EntityDid=@entityId
			OPEN @CurIntervs
			FETCH NEXT FROM @CurIntervs INTO @credOperIntervDid, @credOperIntervTypeId
			WHILE @@FETCH_STATUS = 0
			BEGIN	
			
				--print 'INTERVENçÔES ' + cast(@credOperIntervDid as nvarchar) + ' tipo' + cast(@credOperIntervTypeId as varchar(max))
			
				Update person set 
				FirstName = @entityTypeAbrev, 
				LastName=cast(@entityNumber as nvarchar),
				PEPReference=null, 
				EmploymentCompany=null,
				EmploymentAddress=null,
				BirthDate = DATEADD(DAY,@RandNumber,BirthDate),
				FatherName = 'Father ' + cast(@entityNumber as nvarchar),
				MotherName = 'Mother ' + cast(@entityNumber as nvarchar)
				where OwnerDid=@credOperIntervDid
			
			
			FETCH NEXT FROM @CurIntervs INTO @credOperIntervDid, @credOperIntervTypeId
			END
			CLOSE @CurIntervs
			DEALLOCATE @CurIntervs 
			/* 
			* PROPOSTAS / CONTRATOS */
			UPDATE CredOper set EntityName=@FullName where Customer_EntityDid=@entityId
		
			/* 
			* INSURANCE */
		
			UPDATE InsuranceInterv set 
			EntityName=@FullName,
			BirthDate= @BirthDate,
			LicenceDate = DATEADD(day,FLOOR(RAND()*(28-1)+1),LicenceDate)
			where EntityDid=@entityId
		
			/* 
			* ADDRESS */
		
				
			SET @CurAddress = Cursor static local FOR
			select did, isnull(StreetType.Cid,0) , isnull(StreetType.Abrev,'Street')  from EntityAddress left join StreetType 
				on EntityAddress.AddressTypeCid = StreetType.Cid where EntityDid=@entityId
			OPEN @CurAddress
			FETCH NEXT FROM @CurAddress INTO @entityAdressId, @streetTypeCid, @Street
			WHILE @@FETCH_STATUS = 0
			BEGIN	
				SET @Street = @Street + ' ' + cast(@streetTypeCid as varchar(max)) + ' ' + @entityTypeAbrev + ' ' + cast(@entityNumber as nvarchar)
				UPDATE  EntityAddress set Street=@Street where Did=@entityAdressId
				--print @Street + ' ' + cast(@streetTypeCid as varchar(max)) + ' ' + @entityTypeAbrev + ' ' + cast(@entityNumber as nvarchar)
			FETCH NEXT FROM @CurAddress INTO @entityAdressId, @streetTypeCid, @Street
			END
			CLOSE @CurAddress
			DEALLOCATE @CurAddress
		
		
			--Select @EmailAddress=EmailAddress from EntityEmail where OwnerDid=@entityId
			/* 
			* EMAILS */
		
			SET @CurEmails = Cursor static local FOR
			Select tid, ISNULL(EntityEmailTypeCid,0) from EntityEmail where OwnerDid=@entityId
			OPEN @CurEmails
			FETCH NEXT FROM @CurEmails INTO @entityEmailId, @emailTypeCid
			WHILE @@FETCH_STATUS = 0
			BEGIN	
				SET @EmailAddress = cast(@emailTypeCid as nvarchar) + cast(@entityNumber as nvarchar) + '@' +Lower(replace(@entityTypeAbrev,' ', ''))+'.com'
				UPDATE EntityEmail set EmailAddress=@EmailAddress where Tid=@entityEmailId
				--print cast(@emailTypeCid as nvarchar) + cast(@entityNumber as nvarchar) + '@' +Lower(replace(@entityTypeAbrev,' ', ''))+'.com'
			FETCH NEXT FROM @CurEmails INTO @entityEmailId, @emailTypeCid
			END
			CLOSE @CurEmails
			DEALLOCATE @CurEmails
		
		
			--Select @PhoneNumber=PhoneNumber from EntityPhone where OwnerDid=@entityId
			/* 
			* PHONES */
		
			SET @CurPhones = Cursor static local FOR
			Select tid, ISNULL(PhoneTypeCid,0) from EntityPhone where OwnerDid=@entityId
			OPEN @CurPhones
			FETCH NEXT FROM @CurPhones INTO @entityPhoneId, @phoneTypeCid
			WHILE @@FETCH_STATUS = 0
			BEGIN	
				SET @PhoneNumber = right(replicate(@phoneTypeCid,9)+cast(@entityNumber as nvarchar),9)
				UPDATE EntityPhone set PhoneNumber=@PhoneNumber where Tid=@entityPhoneId
				--print right(replicate(@phoneTypeCid,9)+cast(@entityNumber as nvarchar),9)
			FETCH NEXT FROM @CurPhones INTO @entityPhoneId, @phoneTypeCid
			END
			CLOSE @CurPhones
			DEALLOCATE @CurPhones
		
		
			--Select * from EntityLegalDoc where OwnerDid=@entityId
			/* 
			* LEGALDOCTYPES */
		
			SET @CurLegalDocType = Cursor static local FOR
			Select did, LegalDocTypeCid, LegalDocNumber from EntityLegalDoc where OwnerDid=@entityId
			OPEN @CurLegalDocType
			FETCH NEXT FROM @CurLegalDocType INTO @entityLegalDocId, @legalDocTypeCid, @legalDocNumberOld
			WHILE @@FETCH_STATUS = 0
			BEGIN	
				SET @legalDocNumber = right(replicate(@entityNumber,9)+cast(@legalDocTypeCid as nvarchar),9)
				update EntityLegalDoc set LegalDocNumber= @legalDocNumber where Did=@entityLegalDocId
			
				UPDATE EntityIncident SET LegalDocNumber=@legalDocNumber, EntityName=@FullName where LegalDocNumber=@legalDocNumberOld	
				--print right(replicate(@entityNumber,9)+cast(@legalDocTypeCid as nvarchar),9)
			FETCH NEXT FROM @CurLegalDocType INTO @entityLegalDocId, @legalDocTypeCid, @legalDocNumberOld
			END
			CLOSE @CurLegalDocType
			DEALLOCATE @CurLegalDocType
		
			update EntityContact set ContactName= 'OTHER_' + @FullName where EntityDid=@entityId
		
		
			--Select * from bankaccount where entitydid
			/* 
			 * BANKACCOUNT */
		
			SET @CurBankAccount = Cursor static local FOR
			Select tid, bankAccountTypeCid, BankDid from BankAccount where EntityDid=@entityId
			OPEN @CurBankAccount
			FETCH NEXT FROM @CurBankAccount INTO @bankAccountTid, @bankAccountTypeCid, @bankDid
			WHILE @@FETCH_STATUS = 0
			BEGIN	
			
				set @NIB = right(replicate(@entityNumber,20)+cast(@bankAccountTypeCid as nvarchar),21)
				set @IBAN = 'PT50' + @NIB
			
				UPDATE BankAccount set NIB=@NIB, IBAN=@IBAN where Tid=@bankAccountTid
			
				UPDATE AplBankAccount set BBAN=@NIB, IBAN=@IBAN where Bank_EntityDid=@bankDid
				
			FETCH NEXT FROM @CurBankAccount INTO @bankAccountTid, @bankAccountTypeCid,@bankDid
			END
			CLOSE @CurBankAccount
			DEALLOCATE @CurBankAccount
			print ''
			FETCH NEXT FROM @CurEnt INTO @entityId
		END
		CLOSE @CurEnt
		DEALLOCATE @CurEnt
	FETCH NEXT FROM Cur INTO @entityType, @entityTypeAbrev
	END
	CLOSE Cur
	DEALLOCATE Cur

	-- COTAÇÕES
	UPDATE CredOper set EntityName = null where CredOperStep=1
  		
	-- EQUIPAMENTOS:
	UPDATE Equipment set LicencePlate=NULL, LicenceDate=NULL, SerialNumber=NULL, EquipmentKey= NULL

	-- VALIDAÇõES:
	update legaldoctype set Validation_AplStatementTid=null

	-- OPERATION PAYMENT DATA:
	update OperationPaymentData set PaymentModeCid=6, NIB=NULL, PaymentData=NULL -- NUMERARIO

	-- DADOS BDP (RESPONSABILIDADES) -----------------------------------------------------------------------
	delete from BCBAccountIntervenient
	delete from BCBIntervenient
	delete from BPCentralDebtor
	delete from BPCentralAggregation
	delete from BPCentralGuarantee
	delete from BPCentralSpecialFeature
	delete from BPCentralBalance
	delete from BPCentral
	delete from BPLegalDoc
	delete from BPDebtorLegalDoc

	-------------OUTROS DADOS -------------------------------------------------------------------------------
	DELETE from RADElements
	DELETE from EANElements
	DELETE from SaftCustomerElement
	DELETE from RemittanceElement
	DELETE from AuthorizationDebitDirectLog
	DELETE from AuthorizationDebitDirect
	UPDATE SchedulerProcess Set IsInactive=1
	UPDATE DataFlowType set InvalidDate=GETDATE(), FetchLevel=-1
	UPDATE ATMClientFile set FileArchiveTid = null
	UPDATE COCardFileItem set FileArchiveTid = null
	UPDATE CollFile set FileArchiveTid = null
	UPDATE MLCommunication set FileArchiveTid = null
	DELETE from DataFlowParam
	DELETE from DataFlow where FileArchiveTid is not null
	DELETE from Remittance where FileArchiveTid is not null
	DELETE from filearchive


	--rollback

	commit

END