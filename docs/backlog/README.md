# Product Backlog priorizado

Versão 2.0 · 03/11/2026 · Responsável pela ordenação: Anna Julya Vieira Fernandes (representante do Product Owner)

Documento de entrega no modelo da disciplina: [Product_Backlog_Priorizado.docx](Product_Backlog_Priorizado.docx) ([PDF](Product_Backlog_Priorizado.pdf)). Lá estão a história de usuário e os critérios de aceitação de cada item.

**Critérios:** MoSCoW (Must, Should, Could; os itens Won’t ficaram fora desta versão) e, dentro de cada grupo, proteção do lucro, dependências, valor para as personas e esforço. Valor de negócio de 1 a 5; esforço em story points (1, 2, 3, 5, 8, 13).

| Ordem | ID | Item | Épico | MoSCoW | Valor | SP | Dependência | Sprint | Status |
|---|---|---|---|---|---|---|---|---|---|
| 1 | PB-01 | Estrutura do projeto (frontend, backend, testes e Docker) | Base técnica | Must | 3 | 3 | — | S1 | Não iniciado |
| 2 | PB-02 | Banco PostgreSQL com as 6 tabelas do DER v2 | Base técnica | Must | 3 | 3 | PB-01 | S1 | Não iniciado |
| 3 | PB-03 | Login e acesso por perfil | Gestão de acesso | Must | 5 | 5 | PB-02 | S1 | Não iniciado |
| 4 | PB-04 | Conexão das contas do Mercado Livre (OAuth 2.0) | Contas do Mercado Livre | Must | 5 | 8 | PB-03 | S1 | Não iniciado |
| 5 | PB-05 | Cadastro de custo e preço mínimo por SKU | Preço mínimo | Must | 5 | 3 | PB-02, PB-03 | S1 | Não iniciado |
| 6 | PB-06 | Bloqueio de preço abaixo do mínimo | Preço mínimo | Must | 5 | 5 | PB-05 | S2 | Não iniciado |
| 7 | PB-07 | Log de auditoria | Auditoria | Must | 4 | 5 | PB-02 | S2 | Não iniciado |
| 8 | PB-08 | Ajuste de estoque após contagem física | Estoque | Must | 4 | 3 | PB-05, PB-07 | S2 | Não iniciado |
| 9 | PB-09 | Baixa de estoque a cada venda e sincronização entre as contas | Estoque | Must | 5 | 8 | PB-04, PB-08 | S2 | Não iniciado |
| 10 | PB-10 | Decisão automática dos convites de promoção | Promoções | Must | 5 | 8 | PB-06, PB-07 | S2 | Não iniciado |
| 11 | PB-11 | Dashboard consolidado de vendas | Dashboard | Must | 4 | 5 | PB-04 | S3 | Não iniciado |
| 12 | PB-12 | Conta principal com as últimas unidades | Estoque | Should | 4 | 5 | PB-09 | S3 | Não iniciado |
| 13 | PB-13 | Carga de anúncios em lote com prévia de erros | Carga de anúncios | Should | 4 | 8 | PB-06, PB-07 | S3 | Não iniciado |
| 14 | PB-14 | Margem de contribuição e ACOS real por anúncio | Publicidade | Should | 4 | 8 | PB-04, PB-05 | S3 | Não iniciado |
| 15 | PB-15 | ACOS-alvo máximo e alertas de publicidade | Publicidade | Should | 3 | 3 | PB-14 | S3 | Não iniciado |
| 16 | PB-16 | Indicador de lucro protegido | Dashboard | Should | 3 | 3 | PB-07, PB-10, PB-11 | S4 | Não iniciado |
| 17 | PB-17 | Lista de anúncios sem SKU | Estoque | Should | 3 | 2 | PB-04 | S4 | Não iniciado |
| 18 | PB-18 | Tela de configurações das regras | Configurações | Should | 3 | 3 | PB-10, PB-12, PB-15 | S4 | Não iniciado |
| 19 | PB-19 | Testes automatizados dos motores de decisão | Qualidade | Should | 3 | 5 | PB-06, PB-09, PB-10, PB-14 | S4 | Não iniciado |
| 20 | PB-20 | Publicação no Render | Implantação | Should | 3 | 3 | PB-01 | S4 | Não iniciado |
| 21 | PB-21 | Convite por e-mail para novos usuários | Gestão de acesso | Could | 2 | 3 | PB-03 | S4 | Não iniciado |

Total: 21 itens e 99 story points.

**Fora desta versão (Won’t):** loja própria com Mercado Pago, funções com inteligência artificial, piloto automático de publicidade com robô RPA e emissão automática de DC-e.
