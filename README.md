# BananaGramOrama

[Bananagrams][1] clone done as an exercise in continued learning of [Elixir][2] and [Elm][3].

Goal is to use 100% (or close to it) Elm on the front-end and Elixir w/ [Phoenix Channels][4] on the back-end for real-time game support.

## Development

Prerequisites
  - [Elixir v1.3][2]
  - [Elm][3]

Setup you configuration file:

    $ cp config/dev.exs.sample config/dev.exs
    $ vim config/dev.exs
    
To install dependencies run:

    $ mix deps.get
    $ npm install
    $ cd web/elm
    $ elm package install 
    
Be sure to configure your database information. Then run:

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
