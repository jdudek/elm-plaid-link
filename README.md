# elm-plaid-link

A sample integration of Plaid Link in Elm.

## Installation

Make sure you have Elm 0.17 installed. Then install all dependencies and build the app:

```
make setup all
```

## Development

Start the server:

```
make start
```

Run a watcher that compiles Elm code when it changes:

```
make watch
```

## Conventions

All Elm code is formatted with `elm-format`.

## Plaid Link in your own app

The Elm package repository does not allow packages that call to native code through ports, hence this project cannot be published as an Elm library. However, it’s fairly straightforward to add Plaid Link into an Elm application:

* Copy the [`src/Plaid.elm`](src/Plaid.elm) file into your own project
* Initialize Plaid Link and wire the ports—see [`public/index.html`](public/index.html) for an example.
* Trigger `Plaid.cmdToOpen` command when you want to open Plaid Link
* Handle messages triggered when Plaid Link is loaded, successfully completed or cancelled by the user. See the `update` function in [`src/Main.elm`](src/Main.elm).

# License

MIT.

