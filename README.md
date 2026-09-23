# lms-circulation-db

> Circulation bounded context: database

Part of the **LMS Library** distributed system — team `lms-library`, Grupo 2.
Governance and documentation live in [`library-docs`](https://github.com/code-corhuila/library-docs).

Database: **MongoDB** (`loan_db`), not PostgreSQL — the one exception in this project, per
[`ADR-005-mongodb-for-circulation-service.md`](https://github.com/code-corhuila/library-docs/blob/main/05-architecture/decisions/records/ADR-005-mongodb-for-circulation-service.md):
a `Loan` document is flat, with no foreign key to `students`/`books` (those live in
`lms-membership-db`/`lms-catalog-db`), so it gains nothing from a relational engine.

**This repository owns the whole database lifecycle** — image, configuration, volume, healthcheck.
Unlike the Postgres-backed `-db` repos, there's no `migrations/` folder here: Mongo needs no
schema migrations, and the `loans` collection's indexes are created by `lms-circulation-api`
itself at startup (`internal/infrastructure/mongodb.EnsureIndexes`), not by this repo — Mongo's
schema evolution story is "redeploy the service with the new index definitions," not a versioned
migration tool.

## Migration scope

**From scratch** — this domain has no database in `lms-library` yet. (`docker-compose.yml` here
is new work, not a relocation.)

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
