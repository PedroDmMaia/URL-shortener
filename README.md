# URL Shortener Serverless

Encurtador de URLs construído com Java 17 e serviços serverless da AWS. O projeto recebe uma URL original, grava os dados no S3 e redireciona o código curto para o destino enquanto ele não estiver expirado.

## Arquitetura

```mermaid
flowchart LR
    client[Cliente] --> api[API Gateway HTTP]
    api -->|POST /create| create[Lambda generateShortenerUrl]
    api -->|GET /{urlCode}| redirect[Lambda RedirectUrlShotener]
    create -->|PutObject| bucket[(S3)]
    redirect -->|GetObject| bucket
```

## Stack

- Java 17
- AWS Lambda
- Amazon API Gateway HTTP API
- Amazon S3
- Terraform
- Maven
- GitHub Actions

As funções são empacotadas como JARs shaded, com as dependências incluídas. O bucket usa o namespace regional da conta (`account-regional`) e bloqueio de acesso público.

## Fluxo da API

### Criar uma URL curta

```bash
curl -X POST "$API_ENDPOINT/create" \
  -H "Content-Type: application/json" \
  -d '{"originalUrl":"https://example.com","expirationTime":"1893456000"}'
```

Resposta:

```json
{"code":"a1b2c3d4"}
```

### Redirecionar

```bash
curl -i "$API_ENDPOINT/a1b2c3d4"
```

A resposta é `302` com o header `Location`. Se a URL estiver expirada, a resposta é `410`.

`API_ENDPOINT` pode ser obtido após o deploy:

```powershell
terraform -chdir=terraform output -raw api_endpoint
```

## Executar os testes

```powershell
cd CreateUrlLambda
mvn test

cd ..\RedirectUrlShotener
mvn test
```

Os testes cobrem parsing do request, validação de entrada, geração do código curto, extração do caminho e expiração da URL.

## Build

```powershell
cd CreateUrlLambda
mvn clean package

cd ..\RedirectUrlShotener
mvn clean package
```

Os JARs finais ficam em `target/` e são usados diretamente pelo Terraform.

## Deploy com Terraform

Configure suas credenciais AWS usando um profile, variáveis de ambiente ou AWS IAM Identity Center. Não coloque chaves no repositório.

```powershell
Copy-Item terraform\terraform.tfvars.example terraform\terraform.tfvars
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
terraform -chdir=terraform apply
```

O Terraform injeta o nome do bucket na variável de ambiente `BUCKET_NAME` das duas Lambdas. O nome final é formado por:

```text
<bucket_name_prefix>-<account_id>-<region>-an
```

Para aprender por etapas, também é possível aplicar alvos específicos, mas o fluxo normal deve ser um `plan` completo seguido de `apply`.

## State do Terraform

O projeto não configura backend remoto automaticamente. Durante o estudo, o state fica local e não deve ser commitado.

Para um ambiente compartilhado, crie primeiro uma infraestrutura de bootstrap separada com:

1. Um bucket S3 dedicado ao state, com versionamento e criptografia.
2. Controle de acesso restrito ao time.
3. Locking do state habilitado no backend S3 (`use_lockfile = true`) ou o mecanismo de locking adotado pela sua versão do Terraform.

Depois, configure o backend no Terraform principal. O bucket da aplicação não deve ser usado para armazenar o próprio state.

## Segurança

As roles das Lambdas seguem least privilege:

- `AWSLambdaBasicExecutionRole` para logs no CloudWatch.
- `s3:PutObject` somente para a Lambda de criação.
- `s3:GetObject` somente para a Lambda de redirect.
- Nenhuma role usa `PowerUserAccess`.

## CI

O workflow em `.github/workflows/ci.yml` executa os testes Maven das duas funções e valida o Terraform em cada push ou pull request. O CI não executa `apply`.

## O que aprendi neste projeto

- Como empacotar aplicações Java para Lambda.
- Como conectar API Gateway, Lambda e S3.
- Como importar infraestrutura existente com Terraform.
- Como criar a infraestrutura do zero em etapas.
- Como o `account-regional namespace` do S3 exige `bucket_namespace = "account-regional"`.
- Como throttling zerado em um stage do API Gateway causa `429 Too Many Requests`.
- Como substituir permissões amplas por IAM least privilege.
