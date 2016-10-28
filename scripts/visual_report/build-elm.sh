#!/bin/bash

elm-make Main.elm --warn --output elm.js

elm-make src/modules/Rank.elm src/modules/MashTree.elm --warn --output mashTree.js
