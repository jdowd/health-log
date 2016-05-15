## HealthLog
A quick and dirty ruby script to make it easy to quickly log daily health
metrics. You are what you track, or something like that.


#### Usage
To record a new entry type "**health**" in your terminal.

It's even easier with [Alfred](https://www.alfredapp.com/): Just type "**>
health**" in the Alfred search bar, and it will open Terminal with that command.

An entry like this:
```
w: 200.3 s: 7hrs bl: 4 x: 20min on the rower dq: good, except for a candy bar
dv: overate at lunch c: travelling and got hungry in airport :( ```

will be interpreted as:
```
2016-05-15:
  weight: 200.3
  sleep: 7hrs
  belt loop: 4
  exercise: 20min on the rower
  diet-quality: good, except for a candy bar
  diet-volume: overate at lunch
  comment: travelling and got hungry in airport :(
```

Your entries will be saved in `history.yml` in the repo (gitignored).


#### Installation
- clone the repo locally
- cd into repo
- `chmod +x health_log`
- `ln -s $PWD/health_log /usr/local/bin/health`

#### Road map
Lots of stuff to add, but this is not a super high priority atm.

#### Contributing
PRs welcomed! There's a minimal test suite, please add tests for any new
features.
