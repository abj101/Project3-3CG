# Mythological Card Clash

A turn-based collectible card game featuring mythological creatures and gods from Greek mythology. Players strategically place cards across three locations to accumulate points and achieve victory.

## Programming Patterns

I used various programming patterns to make this mythological card game. All of these programming patterns are found in our course textbook:

* **State Machine** - I implemented a comprehensive state machine system (StateMachine.lua) to manage different game phases including MenuState, PlayState, RevealState, and EndState. This allows seamless transitions between game states and keeps logic organized.

* **State** - I used individual state classes for each game phase. This pattern allowed me to cleanly separate the logic for menu navigation, card staging, card revealing/resolution, and end game scenarios.

* **Command** - I implemented the command pattern through the Grabber system (Grabber.lua) which handles card dragging, dropping, and placement commands. This encapsulates card manipulation actions and makes the interaction system modular.

* **Prototype** - I used the prototype pattern extensively in Card.lua where card prototypes are defined once and then cloned to create individual card instances. This is efficient for creating multiple copies of the same card type throughout the game.

* **Subclass Sandbox** - I implemented this pattern in the card ability system where each card has its own unique `triggerAbility` implementation. Cards like Zeus, Ares, Medusa, and others each have their own specialized behavior while inheriting from the base Card class structure.

## Peer Feedback

The people who gave me feedback are Eric, Cassian, and my Dad since I couldn't get a third. In terms of suggestions, they gave similar feedback about the card system implementation. They said that the prototype pattern worked well for card creation and that the state machine made the game flow very clear and easy to follow. They also suggested implementing a more sophisticated AI system for Player 2 rather than random card placement. They commented that the mythological theme was engaging and that the card abilities were creative and balanced. Other feedback they gave is that the code is well-structured with clear separation of concerns between game logic, rendering, and input handling.

## Postmortem

There are many improvements that I plan to make to the code. First, I want to implement a more intelligent AI system for Player 2 that considers card synergies and location control rather than just playing cards randomly. I also want to add visual feedback during card ability resolution so players can better understand what effects are being applied. 

I would like to implement better card text formatting - currently the card names are positioned awkwardly and could benefit from better layout and potentially icons for different card types. The game would also benefit from animations during card placement and ability resolution to make the experience more engaging.

In regards to programming patterns that would be beneficial to the code, I think the Observer pattern would be excellent for handling card ability interactions and chaining effects. The Flyweight pattern could also optimize memory usage since many cards share similar visual elements. An Event Queue system would help manage the timing and sequencing of card abilities during the reveal phase.

Something I did well is the modular architecture - the separation between game states, card logic, and rendering systems makes the code maintainable and extensible. The prototype pattern implementation for cards is clean and makes adding new card types straightforward. The state machine provides clear game flow and makes debugging easier.

Overall, I'm pleased with the mythological theme implementation and the strategic depth of the card abilities, but I hope to polish the user experience and add more sophisticated game systems in future iterations.

## Assets

All assets were created by me:
- **Card Art**: Created conceptual placeholders for mythological creatures and gods
- **UI Elements**: Designed game interface elements including buttons, card frames, and location backgrounds
- **Game Design**: Developed all card abilities, game mechanics, and balancing