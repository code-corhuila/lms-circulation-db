# lms-circulation-db

> Circulation bounded context: database

Part of the **LMS Library** distributed system — team `lms-library`, Grupo 2.
Governance and documentation live in [`library-docs`](https://github.com/code-corhuila/library-docs).

Database: **MongoDB** (`loan_db`), not PostgreSQL — the one exception in this project, per
[`ADR-005-mongodb-for-circulation-service.md`](https://github.com/code-corhuila/library-docs/blob/main/05-architecture/decisions/records/ADR-005-mongodb-for-circulation-service.md):
a `Loan` document is flat, with no foreign key to `students`/`books` (those live in
`lms-membership-db`/`lms-catalog-db`), so it gains nothing from a relational engine.

**This repository owns the whole database lifecycle** — image, configuration, volume, healthcheck,
**and now the schema**: the `loans` collection, its `$jsonSchema` validator, and its indexes.

This corrects a real gap: `lms-circulation-api`'s `EnsureIndexes()` used to create these indexes
itself at startup, which a prior review on that repo's PR (`lms-circulation-api#2`) already
flagged as critical — `rules/2-anexos/B-db-mongo.md` is explicit that schema/index ownership
belongs here, never in the `-api`. `EnsureIndexes()` itself hasn't been removed yet (tracked as a
follow-up in `lms-circulation-api#2`'s own description); this repo now has what it needs to own
that responsibility.

## Structure

Follows `rules/2-anexos/B-db-mongo.md` (the course's own repository norm), with **Liquibase and
its MongoDB extension** as the migration tool (`ADR-010-liquibase-for-database-migrations.md`) —
Flyway isn't an option for MongoDB under the norm.

```
01_ddl/
├── 00_collections/  → loans and idempotency_keys, each with its $jsonSchema validator (strict/error)
├── 01_validators/   → empty today — no post-creation collMod change yet
├── 02_indexes/      → idx_loan_student_id, idx_loan_book_id, idx_loan_status_due_date
└── 03_views/        → empty today — no aggregation view needed
02_dml/              → empty today — no seed/patch data for loans
03_dcl/00_roles/     → circulation_reader/circulation_writer, via createRole (no password)
changelog/
└── changelog-master.yaml → the single Liquibase entry point
deploy/
├── compose.yml            → this domain's own MongoDB (single-node replica set) + the executor
├── liquibase.Dockerfile    → Liquibase + its MongoDB extension (two packages, not one)
└── liquibase.properties   → changelog path, connection string from environment
```

No `04_tcl/` and no `05_rollbacks/` — Mongo has neither under the norm; every changeset declares
its own inverse operation (`drop`, `dropIndexes`, `dropRole`) inline instead of a mirrored file.

MongoDB runs as a **single-node replica set**, even here in development (`rules/2-anexos/B-db-mongo.md`,
rule 6) — that's what makes transactions and change streams available, so development behaves
like production.

**Not verified against a real Liquibase+mongodb-extension install** in this environment (no
Docker/toolchain access) — the `runCommand` changesets follow MongoDB's own stable command shapes,
but the exact liquibase-mongodb YAML keys should be confirmed on a real run before merging
(`.github/workflows/db-ci.yml`, added in this same change, is meant to be that first real run).

## Migration scope

**From scratch** — this domain has no database in `lms-library` yet. (`docker-compose.yml` here
was new work, not a relocation — since replaced by `deploy/compose.yml`.)

The full map lives in `library-docs`.

---

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `library-docs`.
