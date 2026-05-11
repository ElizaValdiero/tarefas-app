# Tarefas App

Aplicativo de gerenciamento de tarefas.

## Tecnologias utilizadas

- Flutter
- Python + FastAPI
- PostgreSQL
- Docker

## Como rodar

### 1. Clone o repositório
```bash
git clone https://github.com/ElizaValdiero/tarefas-app.git
cd tarefas-app
```

### 2. Crie o arquivo `.env` na raiz
Copie o arquivo `.env.example` e preencha com seus dados:
```bash
cp .env.example .env
```

```env
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
DATABASE_URL=
```

### 3. Suba os containers
```bash
docker-compose up --build
```

### 4. Rode o Flutter
```bash
cd flutter_app
flutter run
```