## [Unreleased]

## 0.8.2 2024-10-16

- Fixes API change in Collection#query method. Parameters `where` and `where_document` are now optional.

## 0.8.1 2024-10-16

- Adds support for Chroma hosted service. See README for more details how to set your `api_key`, `tenant`, and `database`.

## [0.6.0] 2023-06-05

- Fix failure to rescue from API call exceptions.
- Fix embedding loading into Embedding resource.

## [0.5.0] 2023-05-26

- Adds method `get_or_create` to Collection class.

## [0.4.0] 2023-05-23

- This version implements Chroma's API change where Collection uses its collection id for many operations. Changes in the
  gem are internals, public API remains the same. Just be aware you need Chroma 0.3.25 or better with this gem version.

## [0.3.0] 2023-05-19

- Uses Ruby Next to transpile newer Ruby to older Ruby versions in order to support Ruby 2.7, 3.0, and 3.1

## [0.2.0] 2023-05-12

- Complete API to communicate with Chroma database via its API interface

## [0.1.0] - 2023-05-04

- Initial release
