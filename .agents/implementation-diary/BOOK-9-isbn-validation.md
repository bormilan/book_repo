# BOOK-9: ISBN validation

- Added ISBN-10 and ISBN-13 check-digit validation.
- Empty manual ISBN values remain allowed.
- Manual entry disables Save and explains invalid ISBN input.
- Scanner validation now rejects an ISBN-13 with an invalid check digit before
  lookup.
- Added tests for valid values, invalid check digits, and empty optional ISBNs.
- Ran the full simulator test suite successfully.
