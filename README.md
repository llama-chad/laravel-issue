# Laravel Boost Issue

## Steps Taken to Reproduce
Below are all the steps taken to reproduce this repository and the issue.

### 0. Configure docker environment
1. Copy .env.example to .env
2. set UID and GID environment variables

### 1. Install Laravel `docker compose run --rm laravel new src --github="--public"`.
1. Vue
2. Built-In Auth
3. Pest
4. Skipped install npm depenedencies

### 2.  Install/Build NPM Dependencies
1. Install missing dependencies `docker compose run --rm pnpm install lightningcss-linux-arm64-musl lightningcss-linux-x64-gnu lightningcss-linux-x64-musl --save-optional`
2. Build frontend `docker compose run --rm pnpm build`

### 3.Setup database
1.
```yaml
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=app
DB_USERNAME=app
DBPASSWORD=app
```
2. `docker compose run --rm artisan migrate

### 3. Start Containers
`docker compose up -d`

### 4. Install Boost
1. `docker compose run --rm composer require laravel/boost --dev`
2. `docker compose run --rm artisan boost:install`
- Claude Code
- Cursor
- VS Code

- Claude Code
- Codex
- Cursor
- Github Copilot

### 5. Test with the Inspector
1. `php src/artisan mcp:inspector laravel-boost`
2. Open link given from command output
3. Click `Connect`
4. Click `Tools`
5. Click `List Tools`
6. See output terminal output
