# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/
spec/v2.0.0.html).

## [0.0.12] - 2026-06-23
### Fixed
- Rate limiting now applies to `GET /lego/sets/lookup` in addition to `GET /lego/sets/random`.

## [0.0.11] - 2026-06-23
### Changed
- Updated `concurrent-ruby` to 1.3.7 to address CVE-2026-54904, CVE-2026-54905, CVE-2026-54906.

## [0.0.10] - 2026-06-22
### Changed
- Updated `brakeman` to 8.0.5.

## [0.0.9] - 2026-06-22
### Changed
- Updated `addressable` to 2.9.0, `nokogiri` to 1.19.4, `puma` to 8.0.2, `rack` to 3.2.6, `rack-session` to 2.1.2, `net-imap` to 0.6.4.1, `erb` to 6.0.4 to address security vulnerabilities.

## [0.0.8] - 2026-06-22
### Added
- `GET /lego/sets/lookup?set_number=60408` — looks up a specific LEGO set by number from Rebrickable, persists to `lego_api_lego_sets`, returns name/external_id/theme/num_parts/image_url. Appends "-1" suffix automatically if not present.
- `ExternalApi::LegoService.lookup_by_number(set_number:)` — direct Rebrickable fetch by set number.

## [0.0.7] - 2026-03-30
### Changed
- Updated mcp to 0.10.0 to address CVE-2026-33946.

## [0.0.6] - 2026-03-28
### Changed
- Fixed theme-filtered random selection to page within the theme result set.
- Return a 404 when a theme filter yields no results instead of empty payloads.

## [0.0.5] - 2026-03-28
### Added
- Added optional theme filtering for `GET /lego/sets/random` using `theme=city|minecraft|creator`.
- Added theme metadata to request logs and API metadata.

## [0.0.4] - 2026-03-28
### Changed
- Namespaced database tables with `lego_api_` prefixes to avoid collisions in shared databases.
- Made the request log FK migration create the namespaced LEGO sets table when missing.
- Fixed the request log foreign key to target `lego_set_id` correctly.
- Corrected schema foreign key to reference `lego_set_id`.

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
