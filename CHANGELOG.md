# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/
spec/v2.0.0.html).

## [0.0.4] - 2026-03-28
### Changed
- Namespaced database tables with `lego_api_` prefixes to avoid collisions in shared databases.
- Made the request log FK migration create the namespaced LEGO sets table when missing.
- Fixed the request log foreign key to target `lego_set_id` correctly.

## [0.0.3] - 2026-03-28
### Changed
- Bumped Rails to 8.1.3.
- Updated `actions/cache` to v5 in CI.

## [0.0.2] - 2026-03-28
### Added
- Importmap audit shim for CI and expanded GitHub Actions checks.
- Database schema snapshot for test prep.
- Added system test scaffolding and a health check system test.

### Changed
- Added timeout, empty-result fallback, and safer page selection for Rebrickable lookups.
- Normalized set identifiers to `external_id` to match the database schema.
- Aligned lint formatting with RuboCop array spacing expectations.
- Aligned percent literal delimiters and empty array formatting for RuboCop.

## [0.0.1] - 2026-03-28
### Added
- Initial API for `GET /lego/sets/random` with `persist=false` support.
- Rebrickable API integration via `ExternalApi::LegoService`.
- Lego set persistence with `lego_sets` table and request logging with `request_logs`.
- Rate limiting for `GET /lego/sets/random` via `RATE_LIMIT_PER_MINUTE`.
- Legal endpoints (`/terms`, `/privacy`, `/accessibility`) backed by `config/legal_content.json`.
- Health check endpoint at `GET /up`.

MAJOR: Incremented for incompatible API changes.
MINOR: Incremented for adding functionality in a backwards-compatible manner.
PATCH: Incremented for backwards-compatible bug fixes.

major.minor.patch
