# KnitMaker

[![Elixir CI](https://github.com/arjan/knit_maker/actions/workflows/elixir.yml/badge.svg)](https://github.com/arjan/knit_maker/actions/workflows/elixir.yml)

An interface for creating knittings as feedback on physical/virtual events
(meetups, exhibitions, symposia, etc).

## Data model

**user**
is_admin: true/false
is_anonymous: true/false

**event**

- slug
- title
- description
- image

**question**

- event_id
- order (number)
- type (enum)
- config (map)
- code (string)

**user_event_feedback**

- event_id
- user_id
- question_id
- timestamps
- data?
- value (number)
