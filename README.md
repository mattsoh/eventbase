# Eventbase

A Rails 8 app. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how the code is laid out.

## Setup

You need Ruby (see `.ruby-version`), Node (see `.node-version`), Yarn and PostgreSQL.

```bash
bin/setup
```

This installs dependencies, sets up the database and starts the server on
http://localhost:3000.

If Postgres needs a username and password, set `DATABASE_URL` first:

```bash
export DATABASE_URL="postgres://user:password@localhost/eventbase_development"
```

## Running

```bash
bin/dev
```

Starts Rails and the JS watcher (see `Procfile.dev`).

## Other commands

```bash
bin/rails db:migrate   # run migrations
bin/rails db:seed      # load seed data
bin/rails test         # run tests
bin/rails console      # console
bin/ci                 # lint, security checks and tests
```
