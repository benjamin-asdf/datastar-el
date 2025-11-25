# datastar.el

A minor mode for [datastar.js](https://data-star.dev/) projects.

This package provides completion for datastar attributes in html and clojure files.

Based on the datastar [vscode extension](https://marketplace.visualstudio.com/items?itemName=starfederation.datastar-vscode).

# Features

- auto complete for `data-` attributes.
- help buffer for each `data-` attribute with documenntion link. 

## Installation

You can install this package from MELPA:

```
M-x package-install RET datastar RET
```

Or by cloning this repository and adding it to your load-path.

## Configuration with .dir-locals.el

Instead of globally enabling `datastar-mode`, it is recommended to enable it on a per-project basis using Emacs' directory-local variables feature.

Create a file named `.dir-locals.el` at the root of your project. This file will contain the configuration to enable `datastar-mode` for specific file types.

Here is an example that enables `datastar-mode` for HTML, web, Clojure, and ClojureScript files:

```emacs-lisp
((html-mode . ((eval . (datastar-turn-on-mode))))
 (web-mode . ((eval . (datastar-turn-on-mode))))
 (clojure-mode . ((eval . (datastar-turn-on-mode))))
 (clojurescript-mode . ((eval . (datastar-turn-on-mode)))))
```

When you open a file in this directory, Emacs will ask for your confirmation to apply these settings. This is a security measure to ensure you only run trusted code.

## Completion

The package provides completion for datastar attributes. The completion is triggered automatically when you are inside an HTML tag or a Clojure keyword.

You can also manually trigger the completion by using the `datastar-complete` command.

## Documentation

You can view the documentation for a datastar attribute by using the `datastar-attribute-help` command. This command will prompt you for a datastar attribute and then display the documentation for it in a help buffer.
