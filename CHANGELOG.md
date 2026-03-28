# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/
spec/v2.0.0.html).

## [0.0.1] - 2026-03-28
### Added
- Initial API for `GET /lego/sets/random` with `persist=false` support.
- Rebrickable API integration via `ExternalApi::LegoService`.
- Lego set persistence with `lego_sets` table and request logging with `request_logs`.
- Rate limiting for `GET /lego/sets/random` via `RATE_LIMIT_PER_MINUTE`.
- Legal endpoints (`/terms`, `/privacy`, `/accessibility`) backed by `config/legal_content.json`.
- Health check endpoint at `GET /up`.

### Changed
- Added timeout, empty-result fallback, and safer page selection for Rebrickable lookups.
- Normalized set identifiers to `external_id` to match the database schema.

MAJOR: Incremented for incompatible API changes.
MINOR: Incremented for adding functionality in a backwards-compatible manner.
PATCH: Incremented for backwards-compatible bug fixes.

major.minor.patch
