# redribbot

```
                     _______________
                    /               \
   //\              |   Greeting,   |
  ////\    _____    |     Geeks.    |
 //////\  /_____\   \               /
 ======= |[^_/\_]|   /--------------
  |   | _|___@@__|__
  +===+/  ///     \_\
   | |_\ /// HUBOT/\\
   |___/\//      /  \\
         \      /   +---+
          \____/    |   |
           | //|    +===+
            \//      |xx|
```

## Run

make sure you have `pm2`, `coffee-script`

```
npm install -g pm2 coffee-script
```

modify `HUBOT_SLACK_TOKEN` key in `processes.json`.

```
"env" : {
  "HUBOT_SLACK_TOKEN" : "..."
}
```

fire up!!

```
./bin/hubot
```

now, you can manage hubot process with `pm2`
