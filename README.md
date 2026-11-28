# Big Box Archive

A Rails 8 app for cataloguing big box PC games: a public archive of titles, each collector's own collection, and (coming soon) a 3D viewer built from scans of every side of the box.

## Stack

- Ruby (see `.ruby-version`), Rails 8.1, PostgreSQL 16
- Hotwire, Propshaft, importmap, ViewComponent
- Solid Queue, Solid Cache and Solid Cable
- RSpec, FactoryBot, Capybara and shoulda-matchers
- Kamal for deploys

## Getting started

```sh
bin/setup          # installs gems, prepares the database and loads seeds
bin/dev            # starts the app on http://localhost:3000
```

The seeds create the demo collector (username `michael` by default, admin) and a few sample titles. Set `DEMO_EMAIL` and `DEMO_PASSWORD` before seeding to choose the demo account's sign-in. `DEMO_COLLECTOR` changes which collection the home page features.

## Admin access

The admin area is at `/admin`, and an **Admin** link appears in the header once you're signed in as an admin. From there you can add, edit and delete titles and their box photos, and manage users.

Accounts made through sign-up are collectors. To make an account an admin, run:

```sh
bin/rails "users:grant_admin[michael]"         # by username
bin/rails "users:grant_admin[you@example.com]" # or by email address
bin/rails "users:revoke_admin[michael]"        # to take it away again
```

After that, admins can promote other users from **Admin → Users**.

## Tests

```sh
bundle exec rspec  # the specs
bin/ci             # lint, security scans and specs, as CI runs them
```
