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

create `.hubotrc` file on your `$HOME` and add following.

```
export HUBOT_SLACK_TOKEN="..."
export WEBHOOK_SECRET="..."
```

fire up!!

```
pm2 start processes.json
```

now, you can manage hubot process with `pm2`

## Test it local

just type following command

```
./bin/hubot
```
