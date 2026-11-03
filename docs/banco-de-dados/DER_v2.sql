-- =============================================================
-- CannonParts - DER v2 (escopo reduzido: somente Mercado Livre, sem IA)
-- Script DDL MySQL para gerar o DER no MySQL Workbench
-- Importar via: File > Import > Reverse Engineer MySQL Create Script
--
-- Principio do modelo: o banco guarda SOMENTE o que pertence a empresa e
-- nao existe no Mercado Livre. Vendas, anuncios, promocoes, perguntas e
-- metricas do Mercado Ads (somente leitura) sao consultados na API no momento do uso, sem
-- copia local (mesmo comportamento do sistema em producao).
-- O vinculo anuncio -> SKU tambem vem da API: cada anuncio do ML guarda o
-- SKU do vendedor (SELLER_SKU); anuncio sem SKU fica fora das regras (RN11).
--
-- 6 tabelas:
--   usuario, convite_acesso         -> RF01, RN09
--   conta_ml                        -> RF05, RN07, RN10
--   produto                         -> RF03, RF04, RF07, RF09, RN01, RN03, RN05, RN12
--   configuracao                    -> RF06, RF07, RN02, RN04, RN10 (parametros das regras)
--   log_auditoria                   -> RF06, RF08, RF09, RN08
-- =============================================================

CREATE DATABASE IF NOT EXISTS `cannonparts`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `cannonparts`;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------
-- Tabela: usuario  (equipe interna que acessa o painel)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario` (
  `id_usuario`  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome`        VARCHAR(120) NOT NULL,
  `email`       VARCHAR(150) NOT NULL,
  `senha_hash`  VARCHAR(255) NULL COMMENT 'NULL ate o usuario aceitar o convite',
  `perfil`      ENUM('DONO','ANALISTA','OPERADOR_ESTOQUE') NOT NULL,
  `ativo`       TINYINT(1) NOT NULL DEFAULT 1,
  `criado_em`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------
-- Tabela: convite_acesso  (link enviado por e-mail para o usuario definir a senha)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `convite_acesso` (
  `id_convite`  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario`  INT UNSIGNED NOT NULL,
  `token_hash`  VARCHAR(255) NOT NULL,
  `expira_em`   DATETIME NOT NULL,
  `usado_em`    DATETIME NULL,
  PRIMARY KEY (`id_convite`),
  KEY `fk_convite_usuario_idx` (`id_usuario`),
  CONSTRAINT `fk_convite_usuario` FOREIGN KEY (`id_usuario`)
    REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------
-- Tabela: conta_ml  (contas do Mercado Livre conectadas via OAuth 2.0)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `conta_ml` (
  `id_conta`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `apelido`          VARCHAR(80) NOT NULL,
  `ml_user_id`       BIGINT UNSIGNED NOT NULL,
  `access_token`     VARCHAR(255) NOT NULL,
  `refresh_token`    VARCHAR(255) NOT NULL,
  `token_expira_em`  DATETIME NOT NULL,
  `ativa`            TINYINT(1) NOT NULL DEFAULT 1,
  `principal`        TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Conta que fica com as ultimas unidades (RN10); apenas uma',
  `conectada_em`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_conta`),
  UNIQUE KEY `uq_conta_ml_user` (`ml_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------
-- Tabela: produto  (peca/SKU: custo, preco minimo e estoque proprio)
-- Cada SKU e vendido isoladamente: o sistema nao trabalha com kits.
-- O estoque disponivel = estoque_base - vendas desde estoque_contado_em
-- (vendas lidas da API do ML a cada 5 minutos), igual ao calculo usado hoje.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `produto` (
  `id_produto`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sku`                 VARCHAR(60) NOT NULL,
  `descricao`           VARCHAR(200) NULL,
  `custo`               DECIMAL(10,2) NULL,
  `preco_minimo`        DECIMAL(10,2) NULL,
  `estoque_base`        INT NOT NULL DEFAULT 0,
  `estoque_contado_em`  DATETIME NULL,
  `atualizado_em`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_produto`),
  UNIQUE KEY `uq_produto_sku` (`sku`),
  CONSTRAINT `ck_produto_preco_minimo` CHECK (`preco_minimo` IS NULL OR `preco_minimo` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------
-- Tabela: configuracao  (parametros das regras automaticas)
-- Chaves previstas: promocao.margem_minima, promocao.tarifa_venda,
-- promocao.tarifa_fixa, estoque.alerta_baixo,
-- estoque.limite_conta_unica (RN10), estoque.intervalo_sincronizacao_min (RF05)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `configuracao` (
  `chave`           VARCHAR(60) NOT NULL,
  `valor`           JSON NOT NULL,
  `atualizado_por`  INT UNSIGNED NULL,
  `atualizado_em`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`chave`),
  KEY `fk_config_usuario_idx` (`atualizado_por`),
  CONSTRAINT `fk_config_usuario` FOREIGN KEY (`atualizado_por`)
    REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------
-- Tabela: log_auditoria  (decisoes automaticas e alteracoes manuais)
-- id_usuario NULL = acao do sistema (motor de promocoes, sincronizacao de estoque)
-- Cada linha da carga de anuncios (RF09) gera um registro: CRIAR_ANUNCIO
-- com status EXECUTADA (id do anuncio criado em referencia) ou FALHOU (motivo em detalhe).
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `log_auditoria` (
  `id_log`       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario`   INT UNSIGNED NULL,
  `id_conta`     INT UNSIGNED NULL,
  `modulo`       ENUM('PRECO_MINIMO','ESTOQUE','PROMOCAO','ANUNCIO','USUARIO','CONTA','CONFIGURACAO') NOT NULL,
  `origem`       ENUM('AUTOMATICA','MANUAL') NOT NULL,
  `acao`         VARCHAR(60) NOT NULL COMMENT 'Ex.: ACEITAR_CONVITE, RECUSAR_CONVITE, CRIAR_ANUNCIO, IMPORTAR_PLANILHA, SINCRONIZAR_ESTOQUE',
  `referencia`   VARCHAR(80) NULL COMMENT 'SKU, id do anuncio ou convite',
  `regra`        VARCHAR(30) NULL COMMENT 'Ex.: RN01, RN10',
  `status`       ENUM('EXECUTADA','FALHOU') NOT NULL,
  `detalhe`      JSON NULL COMMENT 'Valores antes/depois, margem calculada, mensagem de erro',
  `criado_em`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`),
  KEY `fk_log_usuario_idx` (`id_usuario`),
  KEY `fk_log_conta_idx` (`id_conta`),
  KEY `idx_log_modulo_data` (`modulo`, `criado_em`),
  CONSTRAINT `fk_log_usuario` FOREIGN KEY (`id_usuario`)
    REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_log_conta` FOREIGN KEY (`id_conta`)
    REFERENCES `conta_ml` (`id_conta`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
