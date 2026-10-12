# How the Eventbase code is organized

This is the plan for how we lay out the code as Eventbase grows. Some of it describes
what's already in the repo, and some of it is where we're headed. When the two disagree,
update this doc in the same PR that changes things.

The short version: it's a plain Rails 8 app and we want to keep it that way. Stick to
Rails conventions, render HTML on the server, add JavaScript with Stimulus only where it
actually helps, and don't add a new layer or gem until we feel real pain without it.

## Stack

- **Rails 8.1** on Ruby (version in `.ruby-version`)
- **PostgreSQL** for everything. Solid Queue, Solid Cache and Solid Cable all sit on
  Postgres too, so there's no Redis to run.
- **Hotwire** (Turbo + Stimulus) for interactivity
- **esbuild** via `jsbundling-rails` to bundle JS, and **Propshaft** to serve assets
- **Plain CSS** with custom properties. No Tailwind, no Sass.
- **Minitest** for tests, Capybara + Selenium for system tests
- **Kamal** for deploys
- **Yarn** for JS packages. Don't commit a `package-lock.json`.

Run it locally with `bin/dev`. That starts the Rails server and `yarn build --watch`
from `Procfile.dev`.

## Directory layout

Most of this is standard Rails. These notes cover how we use each folder.

```
app/
  assets/stylesheets/   tokens.css, base.css, site.css, then one file per page/feature
  controllers/          thin controllers, one per resource
  helpers/              view formatting only
  javascript/controllers/  Stimulus controllers
  jobs/                 background work (Solid Queue)
  mailers/
  models/               domain logic lives here
    concerns/           shared model behaviour, once it's used in 2+ places
  views/
    layouts/
    shared/             header, footer, logo, other site-wide partials
    <resource>/         views and partials for each controller
config/
db/
  migrate/
docs/                   this file and anything else worth writing down
lib/tasks/              one-off and maintenance rake tasks
test/
```

`DesignStyle/DESIGN.MD` is the design system spec. It's gitignored, so ask someone for
a copy if you don't have it.

## Models and the domain

The models are where the business logic goes. Right now we only have `User`, but this
is roughly the domain we expect to end up with:

| Model          | What it is                                                    |
| -------------- | ------------------------------------------------------------- |
| `User`         | Someone with an account. Can attend and organize events.      |
| `Event`        | Title, description, start/end time, location, capacity.       |
| `Venue`        | Where an event happens (physical address or online link).     |
| `Rsvp`         | Joins a user to an event, with a status (going, waitlist...). |
| `Organization` | Optional. A group that hosts events and has members.          |
| `Membership`   | Joins a user to an organization with a role.                  |

We'll add these when we actually build the features, not ahead of time.

Conventions for models:

- **Push rules down into the database too.** If something is required, use `null: false`.
  If it has to be unique, add a unique index as well as the validation. `users` already
  does this for `email` and `username`, and both columns are `citext`, so uniqueness
  ignores case without us having to remember `LOWER()`.
- **Use `normalizes`** to clean up input (strip whitespace, downcase emails) rather than
  doing it in controllers or callbacks.
- **Use enums for statuses** (`enum :status, { going: 0, waitlist: 1, ... }`) and back
  them with an integer column that has a default.
- **Scopes for common queries**, e.g. `Event.upcoming`, `Event.published`. If a query
  shows up in two controllers, it should probably be a scope.
- **Keep callbacks light.** Normalizing or setting a default is fine. Sending email or
  calling an external API from a callback isn't. Do that explicitly, or in a job.
- **Concerns** in `app/models/concerns` once two or more models share behaviour
  (something like `Sluggable`). Don't make a concern for a single model.

### When logic outgrows a model

The first move is a plain method on the model. If a model gets really big, pull a cohesive
chunk out into a plain Ruby object next to it, namespaced under the model:

```
app/models/event.rb
app/models/event/publisher.rb     # Event::Publisher
app/models/event/capacity.rb
```

We aren't adding `app/services`, `app/interactors` or similar folders for now. Namespaced
POROs under `app/models` cover the same need and keep related code next to each other. If
that stops working we can talk about it again.

## Controllers and routes

- **Stick to RESTful resources.** Use the seven standard actions. If you're reaching for a
  custom action, it usually means you need a new resource. For example, publishing an event
  becomes `resource :publication` nested under events (`POST /events/:id/publication`)
  rather than `post :publish`.
- **Keep controllers thin**: load the record, check permissions, call the model, then
  render or redirect. If an action is longer than ~15 lines, something should move to the
  model.
- **Strong params** with `params.expect(...)` (the Rails 8 style).
- **Nest routes one level at most** (`events/:event_id/rsvps`). Use `shallow: true` when it
  makes sense.
- Shared controller behaviour (authentication, setting the current user) goes in
  `app/controllers/concerns`.

`WelcomeController#index` is the landing page and the root route. It will probably stay a
simple static-ish page.

### Authentication

We plan to use the Rails 8 authentication generator (`bin/rails generate authentication`)
instead of Devise. That means turning on `bcrypt` in the Gemfile and adding a
`password_digest` column to `users`. It gives us `Session`, `Current`, and an
`Authentication` concern that we own and can change.

Authorization (who can edit which event) starts as plain methods on the models, like
`event.editable_by?(user)`, called from a `before_action`. We'll consider Pundit or
something similar if the rules get complicated.

## Views

- **Every page is built from partials.** Look at `welcome/index.html.erb`: it just renders
  `welcome/_hero`, `welcome/_ticker` and so on. Follow that pattern for new pages.
- **Site-wide partials** (header, footer, logo, flash messages, empty states) go in
  `app/views/shared/`.
- **Partials for a single record** follow Rails naming (`events/_event.html.erb`) so that
  `render @events` just works and Turbo Streams can target them.
- **Keep logic out of templates.** Anything more than a simple `if` goes into a helper or a
  model method. Helpers are for formatting (dates, prices, labels), not business rules.
- **Copy goes in `config/locales/en.yml`** once it's more than placeholder text. That makes
  it easier to find and change wording later.
- **Accessibility is the default.** Use semantic elements, give every form field a label,
  make sure there's a visible focus state, and announce dynamic changes in a live region.
  `clipboard_controller.js` is a good example of that last one.

## JavaScript

- **Turbo first.** Turbo Drive handles navigation, Turbo Frames handle sections that update
  on their own (like an RSVP button), and Turbo Streams handle live updates through Solid
  Cable (like an attendee count).
- **Stimulus for small behaviours.** Each controller does one job and is named after it
  (`clipboard_controller.js`, `dropdown_controller.js`). Configure them with `targets` and
  `values` instead of reading data attributes by hand.
- Always clean up timers and listeners in `disconnect()`.
- **No frontend framework.** If a feature truly needs one (say, a drag-and-drop seating
  chart), we'll discuss it first and keep it isolated to that page.
- `hello_controller.js` is the generator's example and can be deleted.

## CSS

The styles are split into layers:

1. **`tokens.css`**: design tokens. Raw palette (`--color-crimson`, `--color-cream`...) plus
   semantic tokens (`--surface`, `--text`, `--outline`...). Dark mode is handled here by
   re-pointing the semantic tokens.
2. **`base.css`**: resets, typography, and the small primitives (`.tag`, `.btn`, `.card`,
   `.panel`).
3. **`components.css`**: bigger shared pieces built from those primitives: `.section`,
   `.event-card`, `.code-chip`, `.meter`, `.checklist` and so on. If a second page needs
   something from a page stylesheet, move it here.
4. **`site.css`**: layout and the shared header and footer.
5. **One file per page or feature**, e.g. `welcome.css`, `events.css`. Only layout for that
   page goes here.

`stylesheet_link_tag :app` loads every file in the folder alphabetically, so don't rely on
file order to win a conflict. Use a more specific selector (`.hero__features .tag`).

Rules:

- Components only use **semantic tokens**. If you write `var(--color-crimson)` or a hex value
  in a component, it won't follow dark mode or future theme changes.
- If you need a new color or spacing value, add it as a token first.
- Use plain, readable class names scoped to the component (`.event-card`,
  `.event-card__date`). Keep nesting shallow.
- Design decisions come from `DesignStyle/DESIGN.MD`. If you change the design, update the
  doc as well.

## Background jobs, mail, and real-time

- **Jobs** (`app/jobs`, Solid Queue) are for anything slow or that talks to the outside
  world: sending email, reminders, image processing. Jobs should be idempotent and take
  record IDs instead of whole objects.
- **Recurring work** like "send reminders 24 hours before an event" goes in
  `config/recurring.yml`.
- **Mailers** are grouped by model (`EventMailer`, `RsvpMailer`). Always send with
  `deliver_later`.
- **Real-time updates** use Turbo Streams broadcast from models
  (`broadcasts_refreshes` or explicit `broadcast_*` calls). We don't write Action Cable
  channels by hand unless we have to.

## Database

- Create migrations with the generators and run them before committing, so that
  `db/schema.rb` is part of the same commit.
- Don't edit a migration once it's been pushed to `main`. Write a new migration instead.
- Every foreign key gets `null: false` (if required), an index, and a database-level
  foreign key constraint (`t.references :event, null: false, foreign_key: true`).
- Store times as UTC `datetime` columns. Events need a `time_zone` column so we can show
  local times properly.
- Seed data in `db/seeds.rb` should be enough to click around the app locally, and running
  it twice shouldn't break anything (use `find_or_create_by!`).

## Tests

- **Model tests** cover validations, scopes and domain methods. Most of our tests should be
  here.
- **Controller/integration tests** cover each action's happy path and the authorization
  failures.
- **System tests** (Capybara) are only for important user flows, like signing up, creating
  an event and RSVPing. They're slow, so we keep them few.
- We use **fixtures**, not factories. Keep `test/fixtures/*.yml` small and realistic.
- Bug fixes come with a test that fails without the fix.

## Code quality and CI

Before you push, `bin/ci` should pass. It runs:

- `bin/rubocop` (rubocop-rails-omakase style)
- `bin/brakeman` for security issues
- `bin/bundler-audit` for vulnerable gems
- the test suite

GitHub Actions (`.github/workflows/ci.yml`) runs the same checks on every PR.

## Git workflow

- Branch off `main`, using `feat/...`, `fix/...` or `chore/...`.
- Use conventional-style commit messages, like the existing history
  (`feat: Add user model`, `fix: db migration`).
- Keep PRs small. A PR adding a new model usually has the migration, model, tests and
  fixtures together. The UI for it can come in a separate PR.
- Pull before you push (`git pull --rebase`) so you don't end up with rejected pushes.

## Adding a feature: example

Say we're adding events. It would roughly go like this:

1. `bin/rails g model Event title:string starts_at:datetime ...` Then tighten the migration
   (null constraints, indexes, FKs) and run it.
2. Add validations, scopes and `normalizes` to `Event`, with model tests and fixtures.
3. `resources :events` in routes, then `EventsController` with only the actions we need.
4. Views in `app/views/events/`: `index`, `show`, `new`/`edit` sharing a `_form`, and an
   `_event` partial.
5. Styles in `app/assets/stylesheets/events.css` using the semantic tokens.
6. A Stimulus controller only if part of it needs behaviour Turbo doesn't already give us.
7. One system test for "organizer creates an event and sees it listed."
8. `bin/ci`, then open a PR.
