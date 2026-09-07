# @param {Integer[]} nums1
# @param {Integer} m
# @param {Integer[]} nums2
# @param {Integer} n
# @return {Void} modifies nums1 in place
def merge(nums1, m, nums2, n)
  p1    = m - 1        # read finger: last real value in nums1
  p2    = n - 1        # read finger: last value in nums2
  write = m + n - 1    # write finger: last slot in nums1

  while p2 >= 0
    if p1 >= 0 && nums1[p1] > nums2[p2]
      nums1[write] = nums1[p1]
      p1 -= 1
    else
      nums1[write] = nums2[p2]
      p2 -= 1
    end
    write -= 1
  end
end

# ---- tests ----
tests = [
  [[1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3, [1, 2, 2, 3, 5, 6]],
  [[1],                1, [],        0, [1]],
  [[0],                0, [1],        1, [1]],
  [[4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3, [1, 2, 3, 4, 5, 6]],
  [[1, 2, 3, 0, 0, 0], 3, [4, 5, 6], 3, [1, 2, 3, 4, 5, 6]],
  [[2, 2, 0, 0],       2, [2, 2],    2, [2, 2, 2, 2]],
  [[-5, 0, 0],         1, [-9, 3],   2, [-9, -5, 3]],
  [[0, 0, 0],          0, [1, 2, 3], 3, [1, 2, 3]],
]

tests.each_with_index do |(nums1, m, nums2, n, want), idx|
  input = nums1.dup
  merge(nums1, m, nums2, n)
  ok = nums1 == want
  puts format('%-6s #%d  %-16s m=%d  %-12s n=%d  ->  %s',
              ok ? 'PASS' : 'FAIL', idx + 1,
              input.inspect, m, nums2.inspect, n, nums1.inspect)
  puts "       expected #{want.inspect}" unless ok
end
