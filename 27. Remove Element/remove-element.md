# Remove Element (LeetCode 27)

**Difficulty:** Easy · **Pattern:** Two pointers, slow/fast forward fill · **Target:** O(n) time, O(1) extra space

---

## 1. The problem in plain words

You get an array `nums` and a number `val`. Throw away every copy of `val`.

Two catches:

1. **In place.** No building a new array and returning it. You must rearrange `nums` itself.
2. **You return a count, not an array.** Call it `k` — the number of survivors. The judge only ever looks at `nums[0...k]`. Everything from index `k` onward is officially garbage; it can be anything.

```
nums = [0, 1, 2, 2, 3, 0, 4, 2]   val = 2

answer: k = 5, and nums[0...5] must contain {0, 0, 1, 3, 4}

nums = [0, 1, 3, 0, 4, ?, ?, ?]
        └──── keep ────┘ └─ junk ─┘
```

**Order does not matter.** The judge sorts your first `k` elements before comparing. So `[0,1,3,0,4]` and `[4,3,1,0,0]` are both accepted.

### Examples

| # | nums | val | k | valid first-k |
|---|------|-----|---|---------------|
| 1 | `[3,2,2,3]` | 3 | 2 | `[2,2]` |
| 2 | `[0,1,2,2,3,0,4,2]` | 2 | 5 | `[0,1,3,0,4]` in any order |
| 3 | `[]` | 0 | 0 | `[]` |
| 4 | `[2,2,2]` | 2 | 0 | `[]` |

### Constraints

```
0 <= nums.length <= 100
0 <= nums[i] <= 50
0 <= val <= 100
```

Note `val` can be a number that never appears (up to 100, while values only go to 50). Then `k == nums.length` and you change nothing.

### Mental model

A row of numbered lockers. Some hold junk (`val`), some hold keepers. You may not add lockers. Slide every keeper to the front, then report how many lockers are now "real."

---

## 2. Why the naive idea breaks

The instinct is: walk the array, delete each match.

```ruby
nums.each_with_index do |num, i|
  nums.delete_at(i) if num == val    # BUG
end
```

Deleting shifts everything left, but the loop's index keeps marching right. You step **over** the value that slid into the hole:

```
nums = [2, 2, 1]   val = 2

i=0: nums[0] is 2 -> delete_at(0) -> [2, 1]
i=1: nums[1] is 1 -> keep                 <-- the 2 now at index 0 was never re-checked
result: [2, 1]     WRONG
```

Second instinct: build a fresh array with `select`, then copy it back. Correct, but it costs O(n) extra memory and misses the point of the exercise.

---

## 3. The key insight

You are reading the array left to right, and you are writing the array left to right — and **the write finger can never outrun the read finger.** Every slot the writer touches is a slot the reader already passed.

That is the whole trick. Two fingers, both moving forward, at different speeds:

| Name | Starts at | Moves | Meaning |
|------|-----------|-------|---------|
| `read` | `0` | **every** iteration | the value being inspected right now |
| `k` | `0` | only when we keep | the next free slot in the keep zone, *and* the survivor count |

`k` doing double duty — "where to write next" and "how many I've kept" — is why the function can just `return k` at the end. They are the same number by construction.

Each step:

- `nums[read] == val` → skip. `k` stays put, so that slot stays reserved for the next keeper.
- `nums[read] != val` → `nums[k] = nums[read]`, then `k += 1`.

Since `k <= read` always, `nums[k] = nums[read]` either writes onto an already-consumed slot or onto itself. Nothing unread is ever destroyed.

---

## 4. Solution (Ruby)

```ruby
# @param {Integer[]} nums
# @param {Integer} val
# @return {Integer}
def remove_element(nums, val)
  k = 0                       # write finger: next free slot in the "keep" zone
  nums.each do |num|          # read finger: walks every value once
    next if num == val        # a match: skip it, k does not move
    nums[k] = num             # a keeper: park it at the front
    k += 1
  end
  k
end
```

### Line notes

- **`k = 0`** — the keep zone starts empty. It also starts as the answer, and grows into the answer.
- **`nums.each do |num|`** — `each` is safe here *only because we never change the array's length*. We overwrite in place, so the iteration is not disturbed. Contrast with the `delete_at` bug in §2.
- **`next if num == val`** — the "drop" branch is a no-op. Dropping is literally *doing nothing*.
- **`nums[k] = num`** — when nothing has been dropped yet, `k == read` and this line assigns a slot to itself. Wasteful but harmless; see §7 for the version that avoids it.
- **`k`** on the last line — Ruby returns the last expression, no `return` keyword needed.

---

## 5. Iteration-by-iteration trace

Input: `nums = [0,1,2,2,3,0,4,2]`, `val = 2`

Legend — `.` = dead space (index `>= k`, no longer counts)

```
start: k = 0, read = 0
  nums:    .   .   .   .   .   .   .   .
        ^k+r

ITER 1: nums[0] = 0 != val -> KEEP;  nums[0] = 0; k 0 -> 1
  nums:    0   .   .   .   .   .   .   .
            ^k+r

ITER 2: nums[1] = 1 != val -> KEEP;  nums[1] = 1; k 1 -> 2
  nums:    0   1   .   .   .   .   .   .
                ^k+r

ITER 3: nums[2] = 2 == val -> DROP;  k stays 2
  nums:    0   1   .   .   .   .   .   .
                  ^k  ^r

ITER 4: nums[3] = 2 == val -> DROP;  k stays 2
  nums:    0   1   .   .   .   .   .   .
                  ^k      ^r

ITER 5: nums[4] = 3 != val -> KEEP;  nums[2] = 3; k 2 -> 3
  nums:    0   1   3   .   .   .   .   .
                      ^k      ^r

ITER 6: nums[5] = 0 != val -> KEEP;  nums[3] = 0; k 3 -> 4
  nums:    0   1   3   0   .   .   .   .
                          ^k      ^r

ITER 7: nums[6] = 4 != val -> KEEP;  nums[4] = 4; k 4 -> 5
  nums:    0   1   3   0   4   .   .   .
                              ^k      ^r

ITER 8: nums[7] = 2 == val -> DROP;  k stays 5
  nums:    0   1   3   0   4   .   .   .
                              ^k

RESULT: k = 5, keep zone = [0, 1, 3, 0, 4]
        raw array = [0, 1, 3, 0, 4, 0, 4, 2]  <- tail is junk, judge ignores it
```

### What happened, round by round

**ITERS 1–2.** No drops yet, so `k` and `read` are the same finger. `nums[0] = 0` and `nums[1] = 1` write values onto themselves. Pure no-ops, but the code doesn't need to know that.

**ITERS 3–4.** Two drops in a row. `read` advances, `k` freezes at 2. The gap between the fingers just opened to 2 — **that gap is exactly the number of values dropped so far.** Slot 2 is now reserved.

**ITER 5.** The first real move. `3` lives at index 4 but gets written to index 2, jumping over the two discarded `2`s. Index 4 still physically holds `3`, but `read` has passed it, so nobody will ever look again.

**ITERS 6–7.** The gap holds steady at 2; every keeper slides left by exactly 2 places.

**ITER 8.** Final drop. `k` never moves again.

**RESULT.** The raw array ends as `[0,1,3,0,4,0,4,2]`. Positions 5–7 are stale copies left over from the slide. That's fine — you returned `k = 5`, so the judge reads only the first five.

---

## 6. Why you can safely write into the array you're reading

The invariant, true before and after every iteration:

> **`k <= read`**

Proof in one line: both start at 0; `read` increments every round; `k` increments at most once per round. So `k` can never get ahead.

Consequence: `nums[k] = nums[read]` writes to an index that is either the one being read, or one strictly to its left — already inspected, already dead. **You cannot clobber data you still need.** That is the same guarantee as problem 88, just achieved by walking forward instead of backward.

Second invariant, which is why `return k` is correct:

> **`nums[0...k]` always contains exactly the non-`val` values seen so far, in their original relative order.**

At the end, "seen so far" means "all of them," so `k` is the total survivor count. (Order is preserved for free, even though the problem doesn't require it.)

---

## 7. Variant: swap with the tail

When `val` is **rare**, the version above still writes to nearly every slot. Alternative: whenever you hit a `val`, drag the last unchecked value into the hole and shrink the array's live region.

```ruby
def remove_element(nums, val)
  i = 0
  n = nums.size
  while i < n
    if nums[i] == val
      nums[i] = nums[n - 1]   # pull the last live value into this hole
      n -= 1                  # shrink the live region
                              # NOTE: do NOT advance i -- the value we just
                              # pulled in has not been checked yet
    else
      i += 1
    end
  end
  n
end
```

| | slow/fast (§4) | swap-with-tail (§7) |
|---|---|---|
| Writes when `val` is rare | ~n | ~0 |
| Writes when `val` is common | ~few | ~n |
| Preserves relative order | yes | no |
| Easy to get wrong | no | yes (the "don't advance `i`" trap) |

Both are O(n) time, O(1) space. **Submit §4** — it's the one you'll actually recall under pressure, and the order-preserving shape transfers to problems 26 and 283 unchanged. Know §7 exists so you can name it if an interviewer asks "can you do fewer writes?"

---

## 8. Ruby-specific gotchas

### `each` is fine; `each_with_index` + `delete_at` is not

Mutating **values** during `each` is safe. Mutating **length** during iteration is the bug in §2. Ruby will not warn you.

### Don't submit the one-liners

Both of these pass the judge:

```ruby
nums.delete(val)                # mutates in place, returns val or nil
nums.size

nums.reject! { |x| x == val }   # returns nil if nothing was removed!
nums.size
```

They're legal — the judge doesn't care about array length. But they hand the whole exercise to the standard library, and `reject!`'s `nil` return has bitten people who wrote `nums.reject! { ... }.size`. Know they exist; submit the pointer version.

### Bare `next` inside a block

`next` skips to the next iteration of the **block**, not of an enclosing loop. Inside `nums.each do |num|`, `next` is exactly the "continue" you want. If you'd rather be explicit, `if num != val ... end` reads the same.

### `!=` compares by value here

`nums` holds Integers, so `==` / `!=` are plain numeric comparisons. No `equal?` / `eql?` subtleties to worry about at these constraints.

### Return the count, not the array

The single most common wrong submission is returning `nums` or `nums[0, k]`. LeetCode's Ruby signature wants an Integer.

---

## 9. Edge cases (handled for free)

| Input | What happens |
|-------|--------------|
| `nums = []` | `each` never runs → returns `0` ✅ |
| `val` not present | Every element is a keeper, `k == read` throughout, every write is a self-assign → returns `n` ✅ |
| Every element is `val` | Every iteration drops → returns `0`, keep zone empty ✅ |
| `val = 100` (impossible value) | Same as "not present" ✅ |
| All elements identical and kept | No drops, no shifting ✅ |

Again: **zero special-case code.** The invariant does the work.

---

## 10. Complexity

| | |
|---|---|
| **Time** | **O(n)** — one pass, each element inspected exactly once. |
| **Space** | **O(1)** — two integer variables. |

---

## 11. The transferable pattern

> **When filtering an array in place, keep a slow "write" pointer for what survives and a fast "read" pointer for what you're inspecting. The write pointer can never pass the read pointer, so writing is always safe.**

### The same shape, other problems

| Problem | The condition that means "keep" |
|---------|--------------------------------|
| 27. Remove Element | `num != val` |
| 26. Remove Duplicates from Sorted Array | `num != nums[k - 1]` |
| 80. Remove Duplicates from Sorted Array II | `k < 2 || num != nums[k - 2]` |
| 283. Move Zeroes | `num != 0`, then zero-fill the tail |
| 905. Sort Array By Parity | `num.even?` (a partition, so two passes or a swap) |
| 88. Merge Sorted Array | same idea run **backwards**, because the free space is at the tail |

26, 27, 80 and 283 are literally this function with one line changed. Learn it once.

---

## 12. Appendix: other languages

<details>
<summary>Python</summary>

```python
class Solution:
    def removeElement(self, nums: List[int], val: int) -> int:
        k = 0
        for num in nums:
            if num != val:
                nums[k] = num
                k += 1
        return k
```
</details>

<details>
<summary>Java</summary>

```java
class Solution {
    public int removeElement(int[] nums, int val) {
        int k = 0;
        for (int num : nums) {
            if (num != val) nums[k++] = num;
        }
        return k;
    }
}
```
</details>

---

## Files in this folder

| File | Purpose |
|------|---------|
| `remove_element.rb` | Clean solution + swap variant + 9 test cases (`ruby remove_element.rb`) |
| `remove_element_traced.rb` | Prints the pointer state every iteration (`ruby remove_element_traced.rb`) |
| `remove-element.md` | This document |

To trace your own input, edit the **last line** of `remove_element_traced.rb`:

```ruby
remove_element([0, 1, 2, 2, 3, 0, 4, 2], 2)
```

Try `remove_element([1, 2, 3], 9)` — nothing is ever dropped, `k` and `read` stay locked together, and every write is a self-assignment.

## One-line takeaway

**Two forward fingers: one reads everything, one writes only the survivors. The count of survivors *is* the answer.**
