# SQL Trainer

SQL Trainer is an interactive command-line console for practising SQL and ActiveRecord queries against real databases. It supports PostgreSQL, MySQL2, and SQLite3, enforces read-only access to protect your data, and provides built-in tools for inspecting the schema of any connected database.

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
    - [Database configuration](#database-configuration)
    - [Environment variables](#environment-variables)
* [Database setup](#database-setup)
* [Running the console](#running-the-console)
* [Console commands](#console-commands)
    - [General commands](#general-commands)
    - [Database connection commands](#database-connection-commands)
    - [Schema inspection commands](#schema-inspection-commands)
    - [Query commands](#query-commands)
    - [Rake task commands](#rake-task-commands)
* [Rake tasks](#rake-tasks)
* [Query validation and safety](#query-validation-and-safety)
* [Project structure](#project-structure)

## Requirements

- Ruby >= 3.0.0
- One or more of the following databases: PostgreSQL, MySQL2, SQLite3
- Bundler

## Installation

1. Clone the repository and navigate into its directory.

2. Install the dependencies:

   ```bash
   bundle install
   ```

3. Create the configuration files described in the [Configuration](#configuration) section.

4. Set up the databases as described in the [Database setup](#database-setup) section.

## Configuration

### Database configuration

Database connections are defined in `config/database.yml`. Each entry follows a strict naming convention:

```
<domain>_<adapter>
```

The `<domain>` part identifies the logical domain or dataset (for example, `learn_hub` or `shop`). The `<adapter>` part must be one of `postgresql`, `mysql2`, or `sqlite3`.

**PostgreSQL example:**

```yaml
learn_hub_postgresql:
  adapter: postgresql
  encoding: unicode
  database: learn_hub
  pool: 5
  username: <%= ENV["POSTGRESQL_DB_USERNAME"] %>
  password: <%= ENV["POSTGRESQL_DB_PASSWORD"] %>
  host: <%= ENV["POSTGRESQL_DB_HOST"] %>
  port: <%= ENV["POSTGRESQL_DB_PORT"] %>
```

**MySQL2 example:**

```yaml
learn_hub_mysql2:
  adapter: mysql2
  encoding: utf8mb4
  database: learn_hub
  pool: 5
  username: <%= ENV["MYSQL2_DB_USERNAME"] %>
  password: <%= ENV["MYSQL2_DB_PASSWORD"] %>
  host: <%= ENV["MYSQL2_DB_HOST"] %>
  port: <%= ENV["MYSQL2_DB_PORT"] %>
```

**SQLite3 example:**

```yaml
learn_hub_sqlite3:
  adapter: sqlite3
  database: db/learn_hub/learn_hub.sqlite3
  pool: 5
  timeout: 5000
```

Configuration key naming rules:

- The configuration key must follow the pattern `<domain>_<adapter>`.
- For PostgreSQL and MySQL2, the value of `database` must match the domain part of the key exactly (e.g. key `learn_hub_postgresql` requires `database: learn_hub`).
- For SQLite3, the value of `database` must follow the path pattern `db/<domain>/<domain>.sqlite3` (e.g. `db/learn_hub/learn_hub.sqlite3`).

### Environment variables

Credentials for PostgreSQL and MySQL2 connections are loaded from environment variables. Create a `.env` file in the project root (the `dotenv` gem loads it automatically) or set the variables in your shell.

Required variables for PostgreSQL:

```
POSTGRESQL_DB_USERNAME=
POSTGRESQL_DB_PASSWORD=
POSTGRESQL_DB_HOST=
POSTGRESQL_DB_PORT=
```

Required variables for MySQL2:

```
MYSQL2_DB_USERNAME=
MYSQL2_DB_PASSWORD=
MYSQL2_DB_HOST=
MYSQL2_DB_PORT=
```

SQLite3 databases do not require any environment variables.

## Database setup

Each domain requires the following directory structure:

```
models/<domain>/           # ActiveRecord model files
db/<domain>/migrate/       # Migration files
db/<domain>/seeds.rb       # Seed data file
db/<domain>/<domain>.sqlite3  # SQLite3 database file (SQLite3 only)
```

To prepare all databases defined in `config/database.yml` in a single step, run:

```bash
rake db:setup
```

This command creates each database, runs its migrations, and loads its seed data.

To perform these steps individually for a specific configuration key:

```bash
rake db:create[learn_hub_postgresql]
rake db:migrate[learn_hub_postgresql]
rake db:seed[learn_hub_postgresql]
```

## Running the console

Start the interactive console with:

```bash
bin/console
```

The console prompt changes to reflect the current connection state:

- `sql-trainer>` — not connected to any database
- `sql-trainer [learn_hub]>` — connected to the `learn_hub` database

## Console commands

### General commands

| Command | Description |
|---------|-------------|
| `help` or `h` or `?` | Display all available commands and usage examples |
| `clear` or `cls` | Clear the screen and redisplay the welcome banner |
| `exit` or `quit` or `q` | Exit the console |

### Database connection commands

| Command | Description |
|---------|-------------|
| `configs` | List all configuration keys defined in `database.yml` |
| `connect <key>` | Connect to the database identified by `<key>` |
| `connection` | Display information about the current connection |
| `disconnect` | Disconnect from the current database |

Example:

```
connect learn_hub_postgresql
```

### Schema inspection commands

These commands require an active database connection.

| Command | Description |
|---------|-------------|
| `tables` | List all user tables in the connected database |
| `describe <table>` or `desc <table>` | Show the structure of a table: columns, indexes, foreign keys, and row count |
| `relations` or `rels` | Show ActiveRecord associations for all loaded models |
| `relations <table>` or `rels <table>` | Show ActiveRecord associations for a specific table |

Example:

```
describe categories
relations users
```

### Query commands

These commands require an active database connection. All queries are validated and restricted to read-only operations.

| Command | Description |
|---------|-------------|
| `sql <query>` | Execute a raw SQL SELECT query |
| `SELECT ...` | Execute a raw SQL SELECT query (the `sql` prefix is optional) |
| `ar <code>` | Execute an ActiveRecord query |
| `<Model>.<method>` | Execute an ActiveRecord query (the `ar` prefix is optional for recognised patterns) |
| `explain <query>` | Display the execution plan for a SQL SELECT query |

Examples:

```
# SQL — select the first 5 published courses
sql SELECT * FROM courses WHERE is_published = true LIMIT 5

# SQL — list users with their roles (JOIN)
SELECT users.first_name, users.last_name, users.email, roles.name AS role
FROM users
INNER JOIN roles ON roles.id = users.role_id
ORDER BY users.last_name

# SQL — top 5 courses by average rating
SELECT courses.title, AVG(reviews.rating) AS avg_rating, COUNT(reviews.id) AS reviews_count
FROM courses
INNER JOIN reviews ON reviews.course_id = courses.id
GROUP BY courses.id, courses.title
ORDER BY avg_rating DESC
LIMIT 5

# SQL — enrollment count grouped by status
SELECT status, COUNT(*) AS total
FROM enrollments
GROUP BY status

# ActiveRecord — all published beginner-level courses
ar LearnHub::Course.where(is_published: true, level: "beginner").order(:title)

# ActiveRecord — users with their enrollments (eager loading)
LearnHub::User.includes(:enrollments).where(enrollments: { status: "active" }).limit(10)

# ActiveRecord — courses with the number of enrolled students
LearnHub::Course.joins(:enrollments).group(:id).order("COUNT(enrollments.id) DESC").limit(5).select("courses.*, COUNT(enrollments.id) AS enrollments_count")

# ActiveRecord — average score for submissions with status graded
LearnHub::Submission.where(status: "graded").average(:score)

# ActiveRecord — all top-level categories (without a parent)
LearnHub::Category.where(parent_category_id: nil).order(:name)

# EXPLAIN — execution plan for a query on the enrollments table
explain SELECT * FROM enrollments WHERE user_id = 1 AND status = 'active'
```

### Rake task commands

| Command | Description |
|---------|-------------|
| `rake tasks` | List all available Rake tasks |
| `rake <task>` | Execute a Rake task (only `db:*` tasks are supported) |

Note: Rake tasks cannot be executed while a database connection is active. Disconnect first using the `disconnect` command.

Example:

```
disconnect
rake db:reset[learn_hub_postgresql]
```

## Rake tasks

The following Rake tasks are available from the command line or from within the console.

| Task | Description |
|------|-------------|
| `rake db:setup` | Create, migrate, and seed all databases defined in `database.yml` |
| `rake db:create[<key>]` | Create the database for the given configuration key |
| `rake db:drop[<key>]` | Drop the database for the given configuration key |
| `rake db:migrate[<key>]` | Run pending migrations for the given configuration key |
| `rake db:rollback[<key>,<step>]` | Revert the last `<step>` migrations (default: 1) |
| `rake db:seed[<key>]` | Load seed data for the given configuration key |
| `rake db:reset[<key>]` | Drop, create, migrate, and seed the database for the given key |

## Query validation and safety

All SQL and ActiveRecord queries are validated before execution. The console enforces the following restrictions:

**SQL queries** — only `SELECT` statements are allowed. The following commands are blocked: `INSERT`, `UPDATE`, `DELETE`, `DROP`, `CREATE`, `ALTER`, `TRUNCATE`, `GRANT`, `REVOKE`, `EXEC`, `EXECUTE`, `CALL`, `MERGE`, `REPLACE`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `LOCK`, and `UNLOCK`.

**ActiveRecord queries** — only data-reading methods are allowed. The following methods are blocked: `create`, `update`, `save`, `delete`, `destroy`, `insert`, `upsert`, and all their variants.

In addition, dangerous patterns such as stacked statements, `UNION ... SELECT INTO`, and Ruby code constructs such as `eval`, `system`, `exec`, backtick execution, and direct file system manipulation are blocked in both SQL and ActiveRecord input.

## Project structure

```
bin/
  console                  # Executable that starts the interactive console

config/
  database.yml             # Database connection configurations
  settings.yml             # Console and formatter settings

db/
  <domain>/
    migrate/               # Migration files for the domain
    seeds.rb               # Seed data for the domain
    <domain>.sqlite3       # SQLite3 database file (SQLite3 only)

lib/
  sql_trainer.rb           # Main entry point and module definition
  sql_trainer/
    console.rb             # Interactive console loop
    console/
      command/             # Command parsing, routing, and handlers
      ui.rb                # Terminal output and welcome screen
    database/
      configuration.rb     # Loads and validates database.yml
      manager.rb           # Manages the active database connection
      setup.rb             # Create, drop, migrate, seed operations
    formatters/            # Output formatters for query results and schema info
    query/
      executor.rb          # Executes SQL and ActiveRecord queries
      validator.rb         # Validates queries against forbidden commands and patterns
    schema_inspector.rb    # Inspects tables, columns, indexes, foreign keys
    settings.rb            # Reads values from settings.yml
    components/            # Reusable UI components (tables, sections, formatters)

models/
  <domain>/                # ActiveRecord model files for the domain

Gemfile                    # Ruby gem dependencies
Rakefile                   # Rake task definitions
```
