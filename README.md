# Eventbase

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how the code is organized.

## Running it locally

You'll need Ruby (version in `.ruby-version`), Node (version in `.node-version`), Yarn,
and PostgreSQL. Make sure Postgres is running before you start.

### First time

From the project folder, in Git Bash (or any shell on Mac/Linux):

```bash
bin/setup
```

That installs the gems and JS packages, creates and migrates the database, and starts the
app. Open http://localhost:3000.

### After that

```bash
bin/dev
```

This starts the Rails server and the JS watcher together (see `Procfile.dev`). Ctrl+C
stops both.

`bin/dev` is a shell script, so it won't run from PowerShell or cmd. Either use Git Bash,
or run the two processes in separate terminals:

```bash
yarn build --watch       # terminal 1: rebuilds JS when it changes
ruby bin/rails server    # terminal 2: the app
```

### Other useful commands

| Command                | What it does                                     |
| ---------------------- | ------------------------------------------------ |
| `bin/rails db:migrate` | Run new migrations after pulling                 |
| `bin/rails db:seed`    | Load seed data from `db/seeds.rb`                |
| `bin/rails test`       | Run the tests                                    |
| `bin/rails console`    | Ruby console with the app loaded                 |
| `bin/ci`               | Rubocop, security checks and tests, same as CI   |

### Database won't connect?

`config/database.yml` doesn't set a username or password. That's usually fine on Mac and
Linux, but on Windows Postgres normally needs both. Set a connection URL before running
setup (swap in your own Postgres user and password):

```bash
export DATABASE_URL="postgres://postgres:yourpassword@localhost/eventbase_development"
```

Don't commit your password into `database.yml`.
