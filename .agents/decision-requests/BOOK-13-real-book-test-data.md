# BOOK-13 — Real-book test data request

## Status

Awaiting test data from the project owner.

## Why this input is needed

BOOK-13 must measure lookup coverage and metadata accuracy against books whose
edition details have been verified independently of the external providers.
Using provider responses as both implementation input and expected test output
would hide incorrect titles, authors, languages, or editions.

## Requested data

Please provide a varied set of real books. For each book, record:

- ISBN-13 from the barcode; include ISBN-10 too when printed.
- Exact title and subtitle from the title page.
- Author or authors.
- Language.
- Publisher and publication year when available.
- Optional photos of the barcode and title/copyright pages for verification.

The initial set should preferably contain 10–20 books spanning multiple
languages, publishers, publication ages, and editions. ISBN
`9789639884328` should be included as the originally reported sample, not as a
special case.

## How the data will be used

- Establish current per-provider lookup coverage.
- Classify missing and incorrect results.
- Define expected values for live contract tests.
- Review and record provider responses for deterministic automated tests.
- Measure whether the general solution improves coverage without introducing
  edition mismatches.

Live external-service tests will be opt-in and separate from normal CI.
Deterministic tests will use reviewed recorded responses so routine test runs
remain stable when a provider is unavailable or changes its catalog.

## Privacy and repository handling

Only bibliographic facts needed for testing should be committed. Photos and
personal annotations will remain local unless the project owner explicitly
approves including them. API credentials must never be included in the test
dataset.
