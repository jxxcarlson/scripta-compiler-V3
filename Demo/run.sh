lsof -ti :8080 | xargs kill -9 2>/dev/null
elm make src/Main.elm --output=main.js
python3 -m http.server 8080
