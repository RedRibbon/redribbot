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

update `HUBOT_SLACK_TOKEN` and `WEBHOOK_SECRET` in `processes.json`.

```
"env" : {
  "HUBOT_SLACK_TOKEN" : "..."
}
"env" : {
  "WEBHOOK_SECRET" : "..."
}
```

fire up!!

```
pm2 start processes.json
```

now, you can manage hubot process with `pm2`
