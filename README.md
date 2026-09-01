# CHEZA! - Kenyan Party Games Platform 🇰🇪🎉
### *PLAY. LAUGH. REPEAT.*

**CHEZA!** is a production-ready Kenyan multiplayer party games platform built in Flutter and Dart, featuring **TWO complete party games in one app**:

1. 🎭 **CHARADES (Phone on Forehead Tilt Mechanic)**:
   - Hold the phone against your forehead facing your friends.
   - **TILT UP = CORRECT (+1)** / **TILT DOWN = PASS** using real accelerometer/gyroscope sensors (with touch controls for laptop/web testing!).
   - Calibration screen, countdown, animated timer, team scoring, and 250+ Kenyan slang/food/culture cards.

2. 👑 **KINGS CUP (Classic 52-Card Deck Game with Kenyan Party & Family Rules)**:
   - Digital 52-card randomized deck.
   - King counter tracker (e.g. 👑👑⚪⚪ 2/4 Kings drawn).
   - Custom King rules creator (e.g. *"No saying 'bro'"*, *"Clap before speaking"*).
   - Active rules drawer, mate linkage system, and 4th King finale!

---

## 📱 Blueprint Screens Overview

| Screen # | Screen Name | Description |
| :---: | :--- | :--- |
| **1** | **Splash Screen** | "CHEZA! PLAY. LAUGH. REPEAT.", 4 friends illustration, loading bar. |
| **2** | **Home Screen** | "Hi, Michael!", "READY TO PLAY?", CHARADES & KINGS CUP hero cards, bottom menu bar (Players, Categories, Achievements, Settings), Last Game banner. |
| **3** | **Choose Your Game** | "WHAT ARE WE PLAYING?" — Charades ("Tilt to answer") or Kings Cup ("Survive the night"). |
| **4** | **Player Setup** | "ADD PLAYERS" (Michael, Ivy, Brian, Kevin, Sharon), "+ ADD PLAYER", "CONTINUE". |
| **5** | **Game Settings** | Game Mode (Party / Family), Round Time (15s, 30s, 45s, 60s), Difficulty (Easy, Medium, Hard), Sound, Haptics, Pass Count. |
| **6** | **Forehead Calibration** | "PUT YOUR PHONE ON YOUR FOREHEAD - Screen facing your friends. Keep it straight." |
| **7** | **Countdown** | "GET READY! 3 2 1 START!" |
| **8** | **Charades Gameplay** | Digital timer, Score, Team header, Category, Giant Word (`MANZE`), TILT UP / TILT DOWN. |
| **9 & 10** | **Correct & Pass Overlays**| Fullscreen Green "+1 POINT" overlay & Fullscreen Red "PASS!" overlay. |
| **11 & 14**| **Kings Cup Board** | 38 Cards remaining, 2/4 Kings with crown indicators, Current player turn, Active rules list, "DRAW CARD". |
| **12** | **Card Reveal** | Card suit + rank + rule title + icon + action explanation ("DONE", "NEXT PLAYER"). |
| **13** | **King Card Rule Maker**| "Make a rule", custom rule input dialog, adds to active rules drawer. |
| **15** | **The Final King!** | "THE FINAL KING! KING'S CUP - Whoever drew the final King drinks the entire cup!". |

---

## 🃏 Kings Cup Card Rules Included (Screen 16)

- **Ace - WATERFALL**: Start drinking at the same time as the person to your left. Don't stop until they do! *(Family: Continuous wave of humming/clapping)*
- **2 - YOU**: Choose someone to drink / do challenge.
- **3 - ME**: You drink / do challenge yourself.
- **4 - FLOOR**: Everyone touch the floor! Last person drinks.
- **5 - GUYS**: All guys in the party drink / strike a superhero pose.
- **6 - CHICKS**: All ladies in the party drink / victory twirl.
- **7 - HEAVEN**: Hands in the air! Last person to point up drinks.
- **8 - MATE**: Choose a drinking mate. Whenever you drink, your mate drinks too!
- **9 - RHYME**: Say a word. Clockwise players say rhyming words. First to fail drinks.
- **10 - CATEGORIES**: Pick a category (e.g. Kenyan Foods). Clockwise players name items.
- **JACK - NEVER HAVE I EVER**: 3 fingers up! First to lose all fingers drinks.
- **QUEEN - QUESTIONS**: Ask someone a question without answering. Chain continues until someone hesitates.
- **KING - KING'S CUP**: Make a rule! Pour drink into center King's Cup. 4th King drinks the whole cup!

---

## 🚀 How to Run and Test

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run on Laptop (Chrome Browser)
flutter run -d chrome

# 3. Run on Android Device / Emulator
flutter run

# 4. Run automated tests
flutter test
```
