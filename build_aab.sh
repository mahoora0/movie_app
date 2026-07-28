#!/bin/bash
source .env
flutter build appbundle --release --dart-define=TMDB_API_KEY=$TMDB_API_KEY "$@"
