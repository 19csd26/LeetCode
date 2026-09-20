# frozen_string_literal: true

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

def trace_start(nums, val)
  puts format('nums = %p, val = %p', nums, val)
  puts 'start: k = 0 (keep zone empty), read = 0'
  show(nums, 0, 0)
  puts
end

def trace_iteration(nums, val, read, k)
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
  k
end

def trace_result(nums, k)
  puts 'STOP: read walked off the end.'
  puts "RESULT: k = #{k}, nums[0...#{k}] = #{nums[0, k].inspect}, full array = #{nums.inspect}"
  k
end

def trace_all_iterations(nums, val)
  k = 0
  nums.size.times { |read| k = trace_iteration(nums, val, read, k) }
  k
end

def remove_element(nums, val)
  trace_start(nums, val)
  trace_result(nums, trace_all_iterations(nums, val))
end

remove_element([0, 1, 2, 2, 3, 0, 4, 2], 2)
