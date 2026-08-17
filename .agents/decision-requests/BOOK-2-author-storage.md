# BOOK-2 — Author storage

## Context

The book model needs to persist author information. A SwiftData `[String]`
attribute emitted a Core Data warning in the iOS 17 model store, even though
the initial tests passed.

## Options considered

- Persist an array using a custom transformable attribute or a separate Author
  model and relationship.
- Store an optional author display string for the first version.

## Choice made

Persist authors as one optional display string in `Book.authors`.

## Rationale

The current UI only displays author text, and Open Library data can be joined
into that string when lookup is added. This avoids a fragile transformable
array and unnecessary relationship complexity for version 0.0.1.

## Follow-up

Revisit a separate Author model if the app needs author search, filtering, or
individual author navigation.
