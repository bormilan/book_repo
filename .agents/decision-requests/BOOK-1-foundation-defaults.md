# BOOK-1 — Foundation defaults

## Context

The project needs a bundle identifier and an Open Library `User-Agent` before
the first implementation task can be completed. Neither value had a supplied
project-specific value.

## Options considered

- Stop implementation until the owner provides both values.
- Use provisional, configurable defaults and request confirmation before the
  Open Library integration is implemented.

## Choice made

Use the provisional bundle identifier `com.bormilan.bookcatalog`. Configure
the `User-Agent` through the `OPEN_LIBRARY_USER_AGENT` build setting, with an
ignored `Config.xcconfig` file supported for a maintainer-specific value.

## Rationale

The bundle identifier is suitable for local development and can be changed in
one project setting before distribution. The Open Library request is not made
until BOOK-6, so a placeholder contact value does not affect current behavior.
Keeping the real contact value in ignored local configuration prevents it from
being committed unintentionally.

## Follow-up

Before implementing BOOK-6 or releasing the app, the project owner should set
`OPEN_LIBRARY_USER_AGENT` to an app name and an approved maintainer contact
email.
