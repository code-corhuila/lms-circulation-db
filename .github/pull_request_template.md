## User story

<!-- code-corhuila/library-docs#NN -->

## What changes and why

<!-- A few lines. -->

## How it was tested

<!-- The reconstruction-verification result (db-ci.yml): migrate from empty, a
second migrate applying nothing, the validator rejecting/accepting documents as
expected, the indexes existing by name. -->

## Promotion trail

<!-- Only for a PR into qa or main: the list of commits re-applied, each with its
own `(cherry picked from commit <sha>)` line. Delete this section for a PR into
develop. -->

## Checklist

- [ ] No secrets committed — only `.env.example` with names
- [ ] The validator rejects a document with an unknown field, a bad enum value, or missing a required field
- [ ] The validator accepts a valid document
- [ ] Indexes exist with their explicit names
- [ ] MongoDB runs as a replica set
