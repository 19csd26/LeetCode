# Merge Sorted Array (LeetCode 88) -- with a printed trace of every iteration.
#
# Cell legend for nums1:
#   5   a real value that matters
#   .   dead space: nums1 data we already consumed (stale leftover copy)
#   _   padding we have not written to yet

W = 4  # column width

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

def show(nums1, m, nums2, p1, p2, write, written)
  n1 = nums1.each_with_index.map do |v, i|
    if written[i] then v
    elsif i <= p1  then v
    elsif i < m    then '.'
    else                '_'
    end
  end

  puts "        nums1: #{cells(n1)}"
  puts "               #{markers(nums1.size, [[p1, 'p1'], [write, 'w']])}"
  puts "        nums2: #{cells(nums2)}"
  puts "               #{markers(nums2.size, [[p2, 'p2']])}"
end

def merge(nums1, m, nums2, n)
  p1    = m - 1
  p2    = n - 1
  write = m + n - 1

  written = Array.new(m + n, false)
  puts "nums1 = #{nums1.inspect}  m = #{m}      nums2 = #{nums2.inspect}  n = #{n}"
  puts "start: p1 = #{p1}, p2 = #{p2}, write = #{write}"
  puts
  show(nums1, m, nums2, p1, p2, write, written)
  puts

  step = 0
  while p2 >= 0
    step += 1
    left  = p1 >= 0 ? nums1[p1].to_s : 'empty'
    right = nums2[p2]

    if p1 >= 0 && nums1[p1] > nums2[p2]
      puts "ITER #{step}: nums1[#{p1}]=#{left} vs nums2[#{p2}]=#{right}  ->  #{left} is bigger, take from NUMS1"
      puts "        nums1[#{write}] = #{nums1[p1]};  p1 #{p1} -> #{p1 - 1};  write #{write} -> #{write - 1}"
      nums1[write] = nums1[p1]
      p1 -= 1
    else
      reason = p1 >= 0 ? "#{right} is bigger (or tied), take from NUMS2" : 'nums1 is EMPTY, take from NUMS2'
      puts "ITER #{step}: nums1[#{p1}]=#{left} vs nums2[#{p2}]=#{right}  ->  #{reason}"
      puts "        nums1[#{write}] = #{right};  p2 #{p2} -> #{p2 - 1};  write #{write} -> #{write - 1}"
      nums1[write] = nums2[p2]
      p2 -= 1
    end

    written[write] = true
    write -= 1

    show(nums1, m, nums2, p1, p2, write, written)
    puts
  end

  puts "STOP: p2 = #{p2} (nums2 exhausted). Anything left in nums1 is already in place."
  puts "RESULT: #{nums1.inspect}"
end

merge([1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3)
