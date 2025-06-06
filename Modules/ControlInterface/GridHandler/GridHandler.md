
This worker module handles placing and moving grid nodes

- PlaceGridNodes
   - **PlaceContinuationNode** - Places a continuation stop on a reference ticket(live position).
   - **PlaceRecoveryNode** - Places a recovery stop on a reference ticket(live position or buy stop ticket).

- GridHandler
   - HandleNewPosition- handle a new base after a new position has been confirmed.
      - Updates Base object
      - Sets SL and TP
      - Clears all pending orders
      - Places new nodes
   - HandleGridGap- Handles event GridGap
      - Checks if theres a grid gap event.

---
What is a gap?
1. theres is NO open positon
2. there is pending order(s)
3. if two pending, pending orders are more distant than grid unit x2
---
What is a recovery gap?
1. everything that defines a gap
2. at least one order is pending (must be recovery)
3. the `current price` is within `grid unit` distance from `recovery node`

When recovery gap has been covered?
1. everything that defines a recovery gap
2. there are two pending orders
3. but pending orders are within grid unit x2 range
---
What is a continuation gap?
1. everything that defines a gap
2. there are two pending orders
3. the `current price` is within `grid unit` distance from `continuation node`

When continuation gap has been covered?
1. everything that defines a continuation gap
2. but pending orders are within grid unit x2 range
---
What is post-session
1. everything that defines a gap
2. user allows use-session
3. session is over
4. theres only one order on the chart(recovery node)
---
What is a post-session lag? - an order(recovery node) left after session and complete progression cycle
1. everything that defines post-session
3. the current price is NOT within grid unit distance from recovery node
