# KnitMaker

[![Elixir CI](https://github.com/arjan/knit_maker/actions/workflows/elixir.yml/badge.svg)](https://github.com/arjan/knit_maker/actions/workflows/elixir.yml)

An interface for creating knittings as feedback on physical/virtual events
(meetups, exhibitions, symposia, etc).

## Event interface

Visitors can participate by browsing to an event's URL, and are greeted with a
welcome page:

![Event homepage](images/event.jpg)

Next, they are presented a series of questions to be answered:

![Event homepage](images/question.jpg)

Finally, all of these questions help create a knitting pattern that looks similar to one of the following:

![Knitting example](images/knit1.png)
![Knitting example](images/knit2.png)

## Admin interface

Events can be created and edited on the admin interface:

![Admin interface](images/admin.png)

> Users that sign up need to be made administrator manually by setting the
> `is_admin` flag in the database for the user.

On the admin pages you can edit all aspects of each event, including creating
questions and their corresponding visualizations.
