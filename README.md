# BananaGramOrama

[Bananagrams][1] clone done as an exercise in continued learning of [Elixir][2] and [Elm][3].

Goal is to use 100% (or close to it) Elm on the front-end and Elixir w/ [Phoenix Channels][4] on the back-end for real-time game support.

## Development

To install prerequisites run:

    $ mix deps.get
    $ npm install

First, configure your database in config/dev.exs and run:

    $ cp config/dev.exs.sample config/dev.exs
    $ vim config/dev.exs
    $ mix ecto.create

To run the Phoenix application:

    $ mix phoenix.server

You can also run the app inside IEx:

    $ iex -S mix phoenix.server

## Notes

* [Previous online version][5] of the game (retired in 2013)

[1]: https://en.wikipedia.org/wiki/Bananagrams
[2]: http://elixir-lang.org/
[3]: http://elm-lang.org/
[4]: http://www.phoenixframework.org/docs/channels
[5]: https://en.wikipedia.org/wiki/Bananagrams_(online_game)
