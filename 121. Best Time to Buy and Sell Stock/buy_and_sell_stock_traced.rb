# 121. Best Time to Buy and Sell Stock -- traced version.  Run: ruby buy_and_sell_stock_traced.rb
# Prints min_price and max_profit after every day so you can see the two-variable dance.

def max_profit_traced(prices)
  min_price  = Float::INFINITY
  max_profit = 0

  puts format('%-5s  %-10s  %-10s  %-10s  %s', 'Day', 'Price', 'min_price', 'max_profit', 'Action')
  puts '-' * 58

  prices.each_with_index do |price, day|
    if price < min_price
      action    = "new min"
      min_price = price
    elsif price - min_price > max_profit
      action     = "new best profit (sell #{price} - buy #{min_price})"
      max_profit = price - min_price
    else
      action = "no update"
    end

    puts format('%-5d  %-10d  %-10s  %-10d  %s',
                day, price,
                min_price == Float::INFINITY ? '∞' : min_price.to_s,
                max_profit, action)
  end

  puts "\nFinal max_profit: #{max_profit}"
  max_profit
end

puts "=== Example 1: [7, 1, 5, 3, 6, 4]  (expected 5) ==="
max_profit_traced([7, 1, 5, 3, 6, 4])

puts
puts "=== Example 2: [7, 6, 4, 3, 1]  (expected 0) ==="
max_profit_traced([7, 6, 4, 3, 1])

puts
puts "=== Example 3: [1, 4, 2, 7]  (expected 6) ==="
max_profit_traced([1, 4, 2, 7])
