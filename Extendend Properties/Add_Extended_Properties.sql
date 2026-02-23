

EXEC sp_addextendedproperty 
    @name = 'Description', 
    @value = 'Esta Coluna vai conter o nome do cliente', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'firstname';


	EXEC sp_addextendedproperty 
    @name = 'Classificacao', 
    @value = 'Confidencial', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'firstname';

	EXEC sp_addextendedproperty 
    @name = 'RGPD', 
    @value = 'SIM', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'firstname';


	EXEC sp_addextendedproperty 
    @name = 'Domain', 
    @value = 'EStá no Dominio do Billing', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'firstname';


	EXEC sp_addextendedproperty 
    @name = 'Owner', 
    @value = 'O Owner é Responsável Interface Clientes', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'firstname';

	EXEC sp_addextendedproperty 
    @name = 'Observacoes', 
    @value = 'Campo obrigatório ...', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'firstname';


	-------

	EXEC sp_addextendedproperty 
    @name = 'Description', 
    @value = 'Esta Coluna vai conter  o apelido  do cliente', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'lastname';


		EXEC sp_addextendedproperty 
    @name = 'Description', 
    @value = 'Esta Coluna vai conter  o nome do meio  do cliente', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'middleinitial';


	-- Agora com MS_Description

	
	EXEC sp_addextendedproperty 
    @name = 'MS_Description', 
    @value = 'Esta Coluna vai conter  o saldo do cliente actual', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'curr_balance';


		EXEC sp_addextendedproperty 
    @name = 'MS_Description', 
    @value = 'Esta Coluna vai conter o codigo do email do cliente', 
    @level0type = 'Schema', @level0name = 'dbo', 
    @level1type = 'Table',  @level1name = 'member2', 
    @level2type = 'Column', @level2name = 'mail_code';