# backend

API em Node.js + Express, com os motores de decisão e as tarefas agendadas. O código começa na sprint S1 (itens PB-01 e PB-02).

Organização prevista:

```
src/
  routes/       rotas da API REST
  regras/       motores de decisão em funções puras (preço mínimo, promoções, estoque, publicidade)
  integracoes/  clientes das APIs do Mercado Livre e do Mercado Ads
  tarefas/      tarefas agendadas (sincronização de estoque, convites de promoção, renovação de tokens)
  db/           acesso ao PostgreSQL (6 tabelas do DER v2)
tests/          testes com Vitest
```

As credenciais (tokens do Mercado Livre, senha do banco) ficam em `.env`, que não vai para o repositório.
