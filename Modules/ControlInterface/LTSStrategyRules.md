# Long Tail Scalper Strategy
## Rules
<!-- General -->
1. EA only acts on the chart **symbol** it is attached to.
2. EA would not start if there is a foriegn order/position on the chart.
3.  EA corrects user interference
1. Session starts with a short position.
3. Grid consists of a Base and Nodes.
4. Grid Base is the current location of the grid. it is the currently open position.
2. Grid Nodes are pending orders.
2. There are two types of nodes(orders), Recovery nodes and Continuation nodes.
7. No buy stop should be placed at the price of the last
3. Maximum one position must be open at a time.
4. Maximum two orders must be pending at a time.
5. In the case of one pending order, order must be a recovery node
6. Grid nodes
<!-- Recovery nodes-->
6. Recovery node can only placed on an open position or a pending order, if it doesn't already exist.

<!-- Implementation-->
Implementation Constraints
- EA must never delete either Exit (TakeProfit/StopLoss)


(!) Refer to documentation for defination of terms