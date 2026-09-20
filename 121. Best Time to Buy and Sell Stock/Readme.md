# Best Time to Buy and Sell Stock (LeetCode 121)

**Difficulty:** Easy · **Pattern:** Single-pass, two-variable tracking · **Target:** O(n) time, O(1) space

---

## 1. The problem

You have an array `prices` where `prices[i]` is the stock price on day `i`.  
You may buy once and sell once — sell must come *after* the buy.  
Return the maximum profit, or `0` if no profit is possible.

```
prices = [7, 1, 5, 3, 6, 4]

buy  day 1 (price 1)
sell day 4 (price 6)
profit = 6 - 1 = 5         ← answer
```

### Examples

| prices | answer | reason |
|---|---|---|
| `[7, 1, 5, 3, 6, 4]` | `5` | buy at 1, sell at 6 |
| `[7, 6, 4, 3, 1]` | `0` | prices only fall |
| `[1, 2]` | `1` | trivial two-day case |
| `[]` | `0` | no days at all |

### Constraints

```
0 <= prices.length <= 10^5
0 <= prices[i]     <= 10^4
```

---

## 2. Why the naive approach is too slow

The brute-force is: try every (buy\_day, sell\_day) pair where sell > buy, track the max.

```ruby
max_p = 0
(0...n).each do |i|
  (i+1...n).each do |j|
    max_p = [max_p, prices[j] - prices[i]].max
  end
end
```

That's O(n²) — two nested loops over 10⁵ elements means 10¹⁰ operations. Too slow.

---

## 3. The key insight

At every day, your profit if you sell *today* is:

```
today's price  −  cheapest price seen so far
```

So you only need two variables updated in one pass:

| Variable | Meaning |
|---|---|
| `min_price` | Cheapest buy day seen so far |
| `max_profit` | Best sell-minus-buy seen so far |

Every day you either:
- Found a cheaper buy day → update `min_price`
- Selling today beats the current best → update `max_profit`
- Neither → move on

---

## 4. Solution (Ruby)

```ruby
def max_profit(prices)
  min_price  = Float::INFINITY
  max_profit = 0

  prices.each do |price|
    if price < min_price
      min_price = price
    elsif price - min_price > max_profit
      max_profit = price - min_price
    end
  end

  max_profit
end
```

### Why `Float::INFINITY` as the starting `min_price`?

Any real price will be less than `∞`, so the very first day always sets `min_price` correctly — no special-case needed for an empty array or a single element.

### Why `elsif`, not two separate `if`s?

If `price < min_price`, we just updated the buy anchor. Selling on the same day as you buy gives zero profit, so checking profit on that same iteration is pointless. `elsif` skips it cleanly.

---

## 5. Iteration-by-iteration trace

Input: `[7, 1, 5, 3, 6, 4]`

| Day | Price | min_price | max_profit | Action |
|---|---|---|---|---|
| 0 | 7 | 7 | 0 | new min |
| 1 | 1 | 1 | 0 | new min |
| 2 | 5 | 1 | 4 | new best profit (5 − 1) |
| 3 | 3 | 1 | 4 | no update |
| 4 | 6 | 1 | 5 | new best profit (6 − 1) |
| 5 | 4 | 1 | 5 | no update |

**Answer: 5** ✓

Input: `[7, 6, 4, 3, 1]`

| Day | Price | min_price | max_profit | Action |
|---|---|---|---|---|
| 0 | 7 | 7 | 0 | new min |
| 1 | 6 | 6 | 0 | new min |
| 2 | 4 | 4 | 0 | new min |
| 3 | 3 | 3 | 0 | new min |
| 4 | 1 | 1 | 0 | new min |

`min_price` chases prices all the way down. `max_profit` never moves. **Answer: 0** ✓

---

## 6. Edge cases (all handled for free)

| Input | What happens |
|---|---|
| `[]` | loop never runs → returns `0` ✓ |
| `[5]` | loop runs once, sets `min_price=5`, profit stays `0` ✓ |
| `[2, 1]` | day 0 sets min=2, day 1 sets min=1 — `elsif` never fires → `0` ✓ |
| `[1, 2]` | day 0 sets min=1, day 1 profit=1 → `1` ✓ |
| all same | `elsif` condition always false → `0` ✓ |

---

## 7. Complexity

| | |
|---|---|
| **Time** | **O(n)** — single pass |
| **Space** | **O(1)** — two scalar variables |

---

## 8. The transferable pattern

> **"Track a running minimum (or maximum) and check what the current element contributes against it."**

One variable holds the best "context" seen so far; the other accumulates the best "result" using that context. You never need to look back.

### Same pattern, other problems

| Problem | Running min/max | Result variable |
|---|---|---|
| 121. Best Time to Buy and Sell Stock | min price seen | max profit |
| 53. Maximum Subarray (Kadane's) | max subarray ending here | global max |
| 152. Maximum Product Subarray | min and max product ending here | global max |
| 238. Product of Array Except Self | prefix product | suffix product |
| 42. Trapping Rain Water | max height from left | trapped water |

**One-line takeaway:** buy low, sell high — track the lowest buy you've seen, update your best profit at every step.

---

## Files in this folder

| File | Purpose |
|---|---|
| `buy_and_sell_stock.rb` | Clean solution + 10 test cases (`ruby buy_and_sell_stock.rb`) |
| `buy_and_sell_stock_traced.rb` | Prints variable state every day (`ruby buy_and_sell_stock_traced.rb`) |
| `best-time-to-buy-and-sell-stock.md` | This document |
