# 27. Remove Element -- prints the pointer state every iteration.
# Edit the last line to trace your own input.
#
# Cell legend for nums:
#   5   a value inside the keep zone (indices 0...k) -- final answer material
#   .   dead space: index >= k, whatever sits there no longer counts

W = 4

def cells(vals)
  vals.map { |v| v.to_s.rjust(W) }.join
end

def markers(len, marks)
  grouped = {}
  marks.each { |idx, label| (grouped[idx] ||= []) << label if idx >= 0 && idx < len }
  row = Array.new(len, ' ' * W)
  grouped.each { |idx, labels| row[idx] = "^#{labels.join('+')}".rjust(W) }
  row.join
end

def show(nums, k, read)
  view = nums.each_with_index.map { |v, i| i < k ? v : '.' }
  puts "  nums: #{cells(view)}"
  puts "        #{markers(nums.size, [[k, 'k'], [read, 'r']])}"
end

def remove_element(nums, val)
  puts "nums = #{nums.inspect}, val = #{val}"
  k = 0
  puts "start: k = 0 (keep zone empty), read = 0"
  show(nums, k, 0)
  puts

  nums.size.times do |read|
    num = nums[read]
    if num == val
      puts "ITER #{read + 1}: nums[#{read}] = #{num} == val -> DROP"
      puts "        k stays #{k}; slot #{k} still open for the next keeper"
    else
      puts "ITER #{read + 1}: nums[#{read}] = #{num} != val -> KEEP"
      puts "        nums[#{k}] = #{num}; k #{k} -> #{k + 1}"
      nums[k] = num
      k += 1
    end
    show(nums, k, read + 1)
    puts
  end

  puts "STOP: read walked off the end."
  puts "RESULT: k = #{k}, nums[0...#{k}] = #{nums[0, k].inspect}, full array = #{nums.inspect}"
  k
end

remove_element([0, 1, 2, 2, 3, 0, 4, 2], 2)
