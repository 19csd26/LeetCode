# 27. Remove Element -- clean solution + tests.  Run: ruby remove_element.rb

# @param {Integer[]} nums
# @param {Integer} val
# @return {Integer} k = how many elements are not equal to val
#                   (nums[0...k] holds them; nums[k..] is garbage)
def remove_element(nums, val)
  k = 0                       # write finger: next free slot in the "keep" zone
  nums.each do |num|          # read finger: walks every value once
    next if num == val        # a match: skip it, k does not move -> it is overwritten later
    nums[k] = num             # a keeper: park it at the front
    k += 1
  end
  k
end

# ---- alternative: swap with the tail (fewer writes when val is rare) ----
def remove_element_swap(nums, val)
  i = 0
  n = nums.size
  while i < n
    if nums[i] == val
      nums[i] = nums[n - 1]   # drag the last unchecked value into this hole
      n -= 1                  # shrink the live region; do NOT advance i
    else
      i += 1
    end
  end
  n
end

# ---- tests ----
# Judge rule: only the first k elements matter, and only as a multiset.
tests = [
  [[3, 2, 2, 3],             3, [2, 2]],
  [[0, 1, 2, 2, 3, 0, 4, 2], 2, [0, 0, 1, 3, 4]],
  [[],                       0, []],
  [[1],                      1, []],
  [[1],                      2, [1]],
  [[2, 2, 2, 2],             2, []],
  [[4, 5, 6],                9, [4, 5, 6]],
  [[2, 1, 2, 1, 2],          2, [1, 1]],
  [[0, 0, 1],                0, [1]],
]

implementations = [
  [:remove_element,      method(:remove_element)],
  [:remove_element_swap, method(:remove_element_swap)],
]

implementations.each do |name, fn|
  puts "== #{name} =="
  tests.each_with_index do |(nums, val, want), idx|
    input = nums.dup
    work  = nums.dup
    k     = fn.call(work, val)
    got   = work[0, k].sort
    ok    = k == want.size && got == want.sort
    puts format('%-6s #%d %-22s val=%-2d -> k=%d  kept=%s',
                ok ? 'PASS' : 'FAIL', idx + 1, input.inspect, val, k, got.inspect)
    puts "       expected k=#{want.size} kept=#{want.sort.inspect}" unless ok
  end
  puts
end
