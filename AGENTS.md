# Implementation agent guide

Follow these rules for every implementation task in this repository.

## Workflow

1. Work test-first (TDD): write a failing test that describes the behavior
   before implementing it. The test defines the work that follows.
2. Work iteratively. Stay with one task until it is complete and its relevant
   tests pass; do not leave a partially implemented task behind.
3. Use a feature branch for every task. Include the issue ID in the branch
   name, for example `BOOK-123/add-isbn-scanner`.
4. Open a pull request when the task is complete. Include the issue ID in the
   pull-request title and write a brief, descriptive summary explaining why
   the changes solve the issue.
5. Update the applicable implementation-task checklist only after the task and
   its tests are complete.

## Decisions and questions

- Ask the project owner when a problem is unclear or needs a product decision.
- If there are several reasonable technical options and waiting would block the
  task, choose one, implement it, and create a decision request documenting
  the choice and alternatives.
- Store decision requests in `.agents/decision-requests/`. Name each note with
  the issue ID and a short description, for example
  `BOOK-123-scanner-framework.md`.

## Implementation diary

After completing an implementation task, write a note in
`.agents/implementation-diary/` named with the issue ID and a short
description, for example `BOOK-123-isbn-scanner.md`.

Each diary note must record:

- The task and issue ID.
- What was implemented.
- Tests added and tests run.
- Any notable design choices, limitations, or follow-up work.

## Definition of done

A task is done only when its behavior is implemented, relevant tests pass, the
implementation checklist is updated, the implementation diary note exists,
and a pull request has been opened.
