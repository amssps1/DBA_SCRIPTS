USE [IDH]
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_01]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 01
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_01]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	
	DECLARE @Client_Sanction AS BIT = 0
	DECLARE @Clientes_do_Processo TABLE(
				IDCliente	NUMERIC NOT NULL,
				Nome		VARCHAR(90) NOT NULL,
				DataNascimento	DATETIME
			)
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	INSERT INTO @Clientes_do_Processo
		SELECT DISTINCT C.IDCliente,C.Nome,C.DataNascimento
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1	
		WHERE C.NumContribuinte = @NumContribuinteVC
  
	-- Cruzamento por nome e Data Nascimento
	SELECT @Client_Sanction = CASE WHEN WCO.Tipo = 'sanction' THEN 1 ELSE 0 END 	 
		FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
			INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome AND  C.DataNascimento = CASE WHEN ISDATE(WCO.DataNascimento) = 1 THEN WCO.DataNascimento ELSE NULL END
			LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
		WHERE  WCO.iAtivo = 1
		AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Sanction = 0 -- Cruzamento por nome e ano Nascimento
		SELECT @Client_Sanction = CASE WHEN WCO.Tipo = 'sanction' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C  ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE  WCO.iAtivo = 1
			AND ISDATE(WCO.DataNascimento) = 0
			AND LEN(WCO.DataNascimento) >= 4
			AND YEAR(C.DataNascimento) = CAST(LEFT(WCO.DataNascimento,4) AS INT)
			AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Sanction = 0 -- Cruzamento por nome 
		SELECT @Client_Sanction = CASE WHEN WCO.Tipo = 'sanction' THEN 1 ELSE 0 END 	 
			FROM   COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C  ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND LEN(WCO.DataNascimento) = 0
			AND Exclui.IdExclusoesFicheiro IS NULL

	SELECT @Client_Sanction AS 'Criterio01' 

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_02]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 02
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_02]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	
	DECLARE @Client_Terrorism AS BIT = 0
	DECLARE @Clientes_do_Processo TABLE(
				IDCliente	NUMERIC NOT NULL,
				Nome		VARCHAR(90) NOT NULL,
				DataNascimento	DATETIME
			)
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	INSERT INTO @Clientes_do_Processo
		SELECT DISTINCT C.IDCliente,C.Nome,C.DataNascimento
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1	
		WHERE C.NumContribuinte = @NumContribuinteVC
 
	-- Cruzamento por nome e Data Nascimento
	SELECT @Client_Terrorism = CASE WHEN WCO.Tipo LIKE '%terror%' THEN 1 ELSE 0 END 	 
		FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
			INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome AND C.DataNascimento = CASE WHEN ISDATE(WCO.DataNascimento) = 1 THEN WCO.DataNascimento ELSE NULL END
			LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
		WHERE WCO.iAtivo = 1
		AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Terrorism = 0 -- Cruzamento por nome e ano Nascimento
		SELECT @Client_Terrorism = CASE WHEN WCO.Tipo LIKE '%terror%' THEN 1 ELSE 0 END	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND ISDATE(WCO.DataNascimento) = 0
			AND LEN(WCO.DataNascimento) >= 4
			AND YEAR(C.DataNascimento) = CAST(LEFT(WCO.DataNascimento,4) AS INT)
			AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Terrorism = 0 -- Cruzamento por nome 
		SELECT @Client_Terrorism = CASE WHEN WCO.Tipo LIKE '%terror%' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND LEN(WCO.DataNascimento) = 0
			AND Exclui.IdExclusoesFicheiro IS NULL

	SELECT @Client_Terrorism 'Criterio02'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP]  VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_03]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 03
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_03]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	
	DECLARE @Cliente_PEP AS BIT = 0
	DECLARE @Clientes_do_Processo TABLE(
				IDCliente	NUMERIC NOT NULL,
				Nome		VARCHAR(90) NOT NULL,
				DataNascimento	DATETIME
			)
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	INSERT INTO @Clientes_do_Processo
		SELECT DISTINCT C.IDCliente,C.Nome,C.DataNascimento
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1	
		WHERE C.NumContribuinte = @NumContribuinteVC

	-- Cruzamento por nome e Data Nascimento
	SELECT 
		@Cliente_PEP = CASE WHEN WCO.Tipo LIKE 'PEP%' THEN 1 ELSE 0 END 		 
	FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
			INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome AND C.DataNascimento = CASE WHEN ISDATE(WCO.DataNascimento) = 1 THEN WCO.DataNascimento ELSE NULL END
			LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
	WHERE WCO.iAtivo = 1
	AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Cliente_PEP = 0 -- Cruzamento por nome e ano Nascimento
		SELECT @Cliente_PEP = CASE WHEN WCO.Tipo LIKE 'PEP%' THEN 1 ELSE 0 END 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND ISDATE(WCO.DataNascimento) = 0
			AND LEN(WCO.DataNascimento) >= 4
			AND YEAR(C.DataNascimento) = CAST(LEFT(WCO.DataNascimento,4) AS INT)
			AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Cliente_PEP = 0 -- Cruzamento por nome  (apenas quando tivermos 3 ou mais palavras no nome)
		SELECT @Cliente_PEP = CASE WHEN WCO.Tipo LIKE 'PEP%' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND LEN(WCO.DataNascimento) = 0
			AND [dbo].[WordCount](WCO.Nome) >= 4
			AND Exclui.IdExclusoesFicheiro IS NULL

	SELECT @Cliente_PEP 'Criterio03'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_04]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 04
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_04]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	Declare @result as bit = 0
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	IF EXISTS(SELECT TOP 1 1
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
			INNER JOIN [dbo].[COF_ClienteOpcaoBCFT] BCFT WITH(NOLOCK) ON C.IDCliente = BCFT.IdCliente AND BCFT.iAtivo = 1
		WHERE C.NumContribuinte = @NumContribuinteVC
		AND BCFT.CodResposta = 'S')
		SET @result = 1
	
	-- Se não encontrou Cliente procura Não Clientes
	IF (@result = 0)
		IF EXISTS(SELECT TOP 1 1
			FROM COF_NaoClienteOpcaoBCFT BCFT WITH(NOLOCK)
			WHERE BCFT.NumContribuinte = @NumContribuinte
			AND BCFT.CodResposta = 'S')
			SET @result = 1

	SELECT @result AS 'Criterio04'


END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_05]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 05
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_05]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	Declare @result as bit = 0
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	-- Info cliente "Operação Suspeita" Interna 
	IF EXISTS(SELECT TOP 1 1
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
			INNER JOIN COF_ClienteOperacaoSuspeita COSu WITH(NOLOCK) ON C.IdCliente = COSu.IdCliente		 
		WHERE  C.NumContribuinte = @NumContribuinteVC
		AND COSu.iSuspeicao = 1 AND COSu.iActive = 1)
	SET @result = 1
	
	SELECT @result AS 'Criterio05'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_06]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 06
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_06]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	Declare @result as bit = 0
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	-- Info cliente "Operação Suspeita"  Externa(criterio 6)
	IF EXISTS(SELECT TOP 1 1
			FROM COF_Cliente C WITH(NOLOCK)
				INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
				INNER JOIN COF_OperacaoSuspeitaImportacaoCliente COSExterno WITH(NOLOCK) ON C.IdCliente = COSExterno.IdCliente
			WHERE  C.NumContribuinte = @NumContribuinteVC)
		SET @result = 1
			
	SELECT @result AS 'Criterio06'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_07]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 07
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_07]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	Declare @result as bit = 0
	DECLARE 
		@TipoRequerInvestigacao as int,
		@lab as int
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	SELECT @TipoRequerInvestigacao = IdTipoReferencia FROM COF_TipoReferencia WITH(NOLOCK) WHERE Codigo = 'TRI'
	SELECT @lab = IdReferencias FROM COF_Referencias WITH(NOLOCK) WHERE IdTipoReferencia = @TipoRequerInvestigacao AND Codigo = 'TILAB'

	-- Info Cliente Flag LAB "requer investig -> lab"  (se retornar registos tem flag LAB - Critério 7)
	IF EXISTS(SELECT TOP 1 1
				FROM COF_Cliente C WITH(NOLOCK)
					INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
					INNER JOIN [dbo].[COF_TipoRequerInvestigacao] TipoInvestig WITH(NOLOCK) ON C.IDCliente = TipoInvestig.IDCliente AND TipoInvestig.iActivo = 1
				WHERE TipoInvestig.idtipo = @lab --ID Cof_Referencias Flag LAB
				AND C.NumContribuinte = @NumContribuinteVC)
		SET @result = 1
			
	SELECT @result AS 'Criterio07'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_33]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 33
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_33]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	Declare @result as bit = 0
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	IF EXISTS(SELECT TOP 1 1
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_EmpresaSocio ES WITH(NOLOCK) ON ES.IdClienteSocio = C.IDCliente
			INNER JOIN COF_EmpresaInterveniente EI WITH(NOLOCK) ON EI.IdInterveniente = ES.IdSocio AND EI.IdTipoInterveniente IN (4100,4101,4102) and iAtivo = 1
			INNER JOIN COF_ClienteEmpresa CE WITH(NOLOCK) ON CE.IdEmpresa = EI.IdEmpresa 
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = CE.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
			INNER JOIN [dbo].[COF_ClienteOpcaoBCFT] BCFT WITH(NOLOCK) ON C.IDCliente = BCFT.IdCliente AND BCFT.iAtivo = 1
		WHERE C.NumContribuinte = @NumContribuinteVC
		AND BCFT.CodResposta = 'S')
		SET @result = 1
		
	SELECT @result AS 'Criterio33'


END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterio_34]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 34
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterio_34]
	@NumContribuinte DECIMAL
AS
BEGIN TRY

	DECLARE @NumdossiersAceites as int
	DECLARE @NumdossiersKitSimples as int
	DECLARE @idKitSimples as int = 103346 --select idparameterization FROM [PACParameterization] PacParam where PacParam.idParameterizationType = 25 and code = 1
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	SELECT @NumdossiersAceites = count(*), 
			@NumdossiersKitSimples = SUM(CASE WHEN PP.IDKit = @idKitSimples THEN 1 ELSE 0 END)
	FROM COF_Cliente C WITH(NOLOCK)
		INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
		INNER JOIN [dbo].[COF_ProcessoParceiros] PP WITH(NOLOCK) ON CUP.IDProcesso = PP.IDProcesso
	WHERE C.NumContribuinte = @NumContribuinteVC
	AND CUP.CodEstado = 'A'

	-- Cliente só tem propostas aceites com kit documentacao simples
	SELECT CAST(CASE WHEN @NumdossiersAceites = @NumdossiersKitSimples THEN 1 ELSE 0 END AS BIT) AS 'Criterio34'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteCriterios_RM]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 17/07/2023
-- Description: Obtem resultado dos criterios 
--		8,9,10,13,14,15 para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteCriterios_RM]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	Declare @result as bit = 0

	SELECT 
		[iDocumentosIrregulares] AS 'Criterio08'
		,[iEmpresaEstruturaComplexa] AS 'Criterio09'
		,[iClienteSobVigilancia] AS 'Criterio10'
		,[iProfissaoRisco] AS 'Criterio13'
		,[iAreaActividadeRisco]  AS 'Criterio14' 		
		,[iEmpresaRecente]  AS 'Criterio15'
	FROM [dbo].[RSK_InfoBranqueamento] IB WITH(NOLOCK)
	WHERE IB.NumContribuinte = @NumContribuinte
 
END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_ClienteInfo]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem Dados para os calculos
--	dos criterios 16,17,18,19,20,21,22 e 23
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_ClienteInfo]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	-- Info Cliente Pais de Rendimentos (Criterios 16,17,18,19,20,21,22 e 23)
	SELECT  TOP 1 1 as categoriaCliente, C.IDCliente,C.Nome,
		C.iRendimentosObtdoNoEstrangeiro,
		C.idPaisRendimentosNoEstrangeiro, P.SiglaISO as codPaisRendimentos,
		0 AS iResidenciaEstrangeiro,
		NULL AS codPaisResidencia
	FROM COF_Cliente C WITH(NOLOCK)
		INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = C.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
		LEFT JOIN COF_Paises P WITH(NOLOCK) ON P.idPAis = C.idPaisRendimentosNoEstrangeiro
	WHERE C.NumContribuinte = @NumContribuinteVC
	ORDER BY C.UpdatedDate DESC	
 

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_IntEmpresaCriterio_24]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 24
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_IntEmpresaCriterio_24]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	
	DECLARE @Client_Sanction AS BIT = 0
	DECLARE @Clientes_do_Processo TABLE(
				IDCliente	NUMERIC NOT NULL,
				Nome		VARCHAR(90) NOT NULL,
				DataNascimento	DATETIME
			)
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	INSERT INTO @Clientes_do_Processo
		SELECT DISTINCT C.IDCliente,C.Nome,C.DataNascimento
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_EmpresaSocio ES WITH(NOLOCK) ON ES.IdClienteSocio = C.IDCliente
			INNER JOIN COF_EmpresaInterveniente EI WITH(NOLOCK) ON EI.IdInterveniente = ES.IdSocio AND EI.IdTipoInterveniente IN (4100,4101,4102) and iAtivo = 1
			INNER JOIN COF_ClienteEmpresa CE WITH(NOLOCK) ON CE.IdEmpresa = EI.IdEmpresa 
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = CE.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
		WHERE C.NumContribuinte = @NumContribuinteVC
 
	-- Cruzamento por nome e Data Nascimento
	SELECT @Client_Sanction = CASE WHEN WCO.Tipo = 'sanction' THEN 1 ELSE 0 END 	 
		FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
			INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome AND  C.DataNascimento = CASE WHEN ISDATE(WCO.DataNascimento) = 1 THEN WCO.DataNascimento ELSE NULL END
			LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
		WHERE WCO.iAtivo = 1
		AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Sanction = 0 -- Cruzamento por nome e ano Nascimento
		SELECT @Client_Sanction = CASE WHEN WCO.Tipo = 'sanction' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND ISDATE(WCO.DataNascimento) = 0
			AND LEN(WCO.DataNascimento) >= 4
			AND YEAR(C.DataNascimento) = CAST(LEFT(WCO.DataNascimento,4) AS INT)
			AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Sanction = 0 -- Cruzamento por nome 
		SELECT @Client_Sanction = CASE WHEN WCO.Tipo = 'sanction' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND LEN(WCO.DataNascimento) = 0
			AND Exclui.IdExclusoesFicheiro IS NULL

	SELECT @Client_Sanction AS 'Criterio24' 

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_IntEmpresaCriterio_25]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 25
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_IntEmpresaCriterio_25]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	
	DECLARE @Client_Terrorism AS BIT = 0
		DECLARE @Clientes_do_Processo TABLE(
				IDCliente	NUMERIC NOT NULL,
				Nome		VARCHAR(90) NOT NULL,
				DataNascimento	DATETIME
			)
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	INSERT INTO @Clientes_do_Processo
		SELECT DISTINCT C.IDCliente,C.Nome,C.DataNascimento
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_EmpresaSocio ES WITH(NOLOCK) ON ES.IdClienteSocio = C.IDCliente
			INNER JOIN COF_EmpresaInterveniente EI WITH(NOLOCK) ON EI.IdInterveniente = ES.IdSocio AND EI.IdTipoInterveniente IN (4100,4101,4102) and iAtivo = 1
			INNER JOIN COF_ClienteEmpresa CE WITH(NOLOCK) ON CE.IdEmpresa = EI.IdEmpresa 
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = CE.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
		WHERE C.NumContribuinte = @NumContribuinteVC
 
	-- Cruzamento por nome e Data Nascimento
	SELECT @Client_Terrorism = CASE WHEN WCO.Tipo LIKE '%terror%' THEN 1 ELSE 0 END 	 
		FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
			INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome AND C.DataNascimento = CASE WHEN ISDATE(WCO.DataNascimento) = 1 THEN WCO.DataNascimento ELSE NULL END
			LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
		WHERE WCO.iAtivo = 1
		AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Terrorism = 0 -- Cruzamento por nome e ano Nascimento
		SELECT @Client_Terrorism = CASE WHEN WCO.Tipo LIKE '%terror%' THEN 1 ELSE 0 END	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND ISDATE(WCO.DataNascimento) = 0
			AND LEN(WCO.DataNascimento) >= 4
			AND YEAR(C.DataNascimento) = CAST(LEFT(WCO.DataNascimento,4) AS INT)
			AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Client_Terrorism = 0 -- Cruzamento por nome 
		SELECT @Client_Terrorism = CASE WHEN WCO.Tipo LIKE '%terror%' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND LEN(WCO.DataNascimento) = 0
			AND Exclui.IdExclusoesFicheiro IS NULL

	SELECT @Client_Terrorism 'Criterio25'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP]  VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_IntEmpresaCriterio_26]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem resultado do criterio 26
--		para o calculo nivel risco
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_IntEmpresaCriterio_26]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	
	DECLARE @Cliente_PEP AS BIT = 0
	DECLARE @Clientes_do_Processo TABLE(
			IDCliente	NUMERIC NOT NULL,
			Nome		VARCHAR(90) NOT NULL,
			DataNascimento	DATETIME
		)
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	INSERT INTO @Clientes_do_Processo
		SELECT DISTINCT C.IDCliente,C.Nome,C.DataNascimento
		FROM COF_Cliente C WITH(NOLOCK)
			INNER JOIN COF_EmpresaSocio ES WITH(NOLOCK) ON ES.IdClienteSocio = C.IDCliente
			INNER JOIN COF_EmpresaInterveniente EI WITH(NOLOCK) ON EI.IdInterveniente = ES.IdSocio AND EI.IdTipoInterveniente IN (4100,4101,4102) and iAtivo = 1
			INNER JOIN COF_ClienteEmpresa CE WITH(NOLOCK) ON CE.IdEmpresa = EI.IdEmpresa 
			INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = CE.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
		WHERE C.NumContribuinte = @NumContribuinteVC
 
	-- Cruzamento por nome e Data Nascimento
	SELECT 
		@Cliente_PEP = CASE WHEN WCO.Tipo LIKE 'PEP%' THEN 1 ELSE 0 END 		 
	FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
			INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome AND C.DataNascimento = CASE WHEN ISDATE(WCO.DataNascimento) = 1 THEN WCO.DataNascimento ELSE NULL END
			LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
	WHERE WCO.iAtivo = 1
	AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Cliente_PEP = 0 -- Cruzamento por nome e ano Nascimento
		SELECT @Cliente_PEP = CASE WHEN WCO.Tipo LIKE 'PEP%' THEN 1 ELSE 0 END 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome 
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND ISDATE(WCO.DataNascimento) = 0
			AND LEN(WCO.DataNascimento) >= 4
			AND YEAR(C.DataNascimento) = CAST(LEFT(WCO.DataNascimento,4) AS INT)
			AND Exclui.IdExclusoesFicheiro IS NULL

	IF @Cliente_PEP = 0 -- Cruzamento por nome  (apenas quando tivermos 3 ou mais palavras no nome)
		SELECT @Cliente_PEP = CASE WHEN WCO.Tipo LIKE 'PEP%' THEN 1 ELSE 0 END 	 
			FROM  COF_WCO_Ficheiro WCO WITH(NOLOCK) 
				INNER JOIN @Clientes_do_Processo C ON WCO.Nome = C.Nome
				LEFT JOIN COF_WCO_ExclusoesFicheiro Exclui WITH(NOLOCK) ON Exclui.NumContribuinte = @NumContribuinteVC AND Exclui.iAtivo = 1 AND Exclui.CodigoFicheiro = RTRIM(LTRIM((WCO.Codigo)))
			WHERE WCO.iAtivo = 1
			AND LEN(WCO.DataNascimento) = 0
			AND [dbo].[WordCount](WCO.Nome) >= 4
			AND Exclui.IdExclusoesFicheiro IS NULL

	SELECT @Cliente_PEP 'Criterio26'

END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[RSK_GET_IntEmpresaInfo]    Script Date: 20/09/2023 14:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Instrução
-- Created date: 07/07/2023
-- Description: Obtem Dados para os calculos
--	dos criterios 27,28,29,30
-- Projecto: Determinacoes BdP
-- Version: 0.001
-- =============================================
ALTER PROCEDURE [dbo].[RSK_GET_IntEmpresaInfo]
	@NumContribuinte DECIMAL
AS
BEGIN TRY
	DECLARE @NumContribuinteVC VARCHAR(20) = CAST(@NumContribuinte AS VARCHAR(20))

	-- Info Intervenientes Empresa e Pais Residencia (Criterios 27,28,29,30)
	SELECT  TOP 1 1 as categoriaBefSocioOrgGest, 
		0 AS iResidenciaEstrangeiro,
		NULL AS codPaisResidencia
	FROM COF_Cliente C WITH(NOLOCK)
		INNER JOIN COF_EmpresaSocio ES WITH(NOLOCK) ON ES.IdClienteSocio = C.IDCliente
		INNER JOIN COF_EmpresaInterveniente EI WITH(NOLOCK) ON EI.IdInterveniente = ES.IdSocio AND EI.IdTipoInterveniente IN (4100,4101,4102) and iAtivo = 1
		INNER JOIN COF_ClienteEmpresa CE WITH(NOLOCK) ON CE.IdEmpresa = EI.IdEmpresa 
		INNER JOIN COF_ClienteUProcesso CUP WITH(NOLOCK) ON CUP.IDCliente = CE.IDCliente AND CUP.TipoInterveniente IN ('T','F') AND CUP.iAtivo = 1
	WHERE C.NumContribuinte = @NumContribuinteVC
	ORDER BY C.UpdatedDate DESC	
 
END TRY
BEGIN CATCH
    DECLARE @Erro AS VARCHAR(500)
    SELECT  @Erro = ERROR_MESSAGE()
    INSERT  INTO [dbo].[COF_Erros_SP] VALUES  (ERROR_PROCEDURE(), @Erro, GETDATE())
    RAISERROR(@Erro,11,1)
END CATCH
GO
