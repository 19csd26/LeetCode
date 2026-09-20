# 121. Best Time to Buy and Sell Stock -- clean solution + tests.  Run: ruby buy_and_sell_stock.rb

# @param {Integer[]} prices
# @return {Integer}
def max_profit(prices)
  min_price  = Float::INFINITY   # cheapest buy day seen so far
  max_profit = 0                 # best profit seen so far

  prices.each do |price|
    if price < min_price
      min_price = price          # found a cheaper buy day — update anchor
    elsif price - min_price > max_profit
      max_profit = price - min_price   # selling today beats the current best
    end
  end

  max_profit
end

# ---- tests ----
tests = [
  # [prices, expected_profit]
  [[7, 1, 5, 3, 6, 4], 5],    # buy day 1 (1), sell day 4 (6)
  [[7, 6, 4, 3, 1],    0],    # only falling prices — no profit
  [[1, 2],             1],    # two elements, profit exists
  [[2, 1],             0],    # two elements, falling
  [[1],                0],    # single element — no transaction possible
  [[],                 0],    # empty — no transaction possible
  [[3, 3, 3],          0],    # all same — no profit
  [[1, 4, 2, 7],       6],    # buy at 1, sell at 7 (skip the dip at 2)
  [[2, 1, 2, 0, 1],    1],    # reset min to 0, profit = 1
  [[10000, 1, 10000],  9999], # large range
]

tests.each_with_index do |(prices, expected), idx|
  got = max_profit(prices.dup)
  ok  = got == expected
  puts format('%-6s #%02d  prices=%-28s  expected=%-5d  got=%d',
              ok ? 'PASS' : 'FAIL', idx + 1, prices.inspect, expected, got)
end
