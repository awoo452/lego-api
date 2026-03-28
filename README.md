# Random LEGO Set API

## Features

A Ruby on Rails API that fetches a random LEGO set from the Rebrickable API, logs each request, and can optionally store a subset of the data in PostgreSQL.

### API

`GET /lego/sets/random` returns a random LEGO set payload.

Query parameters:
- `persist=false` skips writing to the database (default persists the set).
- `theme=city|minecraft|creator` filters the random set to a specific theme.

Side effects (when `persist` is not `false`):
- Creates or updates a `LegoSet` record with `name`, `external_id`, `theme`, `num_parts`, `image_url`, `raw_data`.
- Links the request log to the created LEGO set via `lego_set_id`.

Request logging:
- All API requests except `GET /up` are logged in the `request_logs` table.
- Each log captures request metadata (HTTP method, path, IP address, user agent, origin, params, status, duration, metadata).

Rate limiting:
- If rate limited, returns HTTP `429` with a `Retry-After` header.

`GET /up` is the Rails health check endpoint.

### Legal Pages (HTML)

This API-only app also serves minimal HTML legal pages for compliance-friendly, stable URLs:
- `GET /terms`
- `GET /privacy`
- `GET /accessibility`

The content is stored in `config/legal_content.json` and rendered by a lightweight controller/view.

### Configuration

- `CORS_ORIGINS` — Comma-separated list of allowed origins for browser clients.
  - If unset: development/test allow localhost; production defaults to a shared allowlist.
- `DATABASE_URL` — Required in production; local development uses `config/database.yml`.
- `REBRICKABLE_API_KEY` — Required for Rebrickable API access.
- `RATE_LIMIT_PER_MINUTE` — Max requests per minute per IP for `GET /lego/sets/random` (default: 3).
- `RAILS_MAX_THREADS` — Connection pool size (default: 5).

### Data Model

Table: `lego_api_lego_sets`
- `name` (string)
- `external_id` (string, set_num)
- `theme` (string)
- `num_parts` (integer)
- `image_url` (string)
- `raw_data` (jsonb)
- `created_at` / `updated_at`

Table: `lego_api_request_logs`
- `request_id` (string)
- `http_method` (string)
- `path` (string)
- `ip` (string)
- `user_agent` (string)
- `referer` (string)
- `origin` (string)
- `params` (jsonb)
- `status` (integer)
- `duration_ms` (integer)
- `metadata` (jsonb)
- `lego_set_id` (foreign key, nullable)
- `created_at` / `updated_at`

## Setup

1. `bin/setup`

Manual setup:
- `bundle install`
- `bin/rails db:prepare`

## Run

1. `bin/rails server`

## Tests

1. `bin/rails test`
2. `bin/rails test:system`

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for notable changes.

LEGO is a trademark of the LEGO Group. This project is not affiliated with or endorsed by the LEGO Group.
