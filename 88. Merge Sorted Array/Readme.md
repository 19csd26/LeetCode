# Merge Sorted Array (LeetCode 88)

**Difficulty:** Easy · **Pattern:** Two pointers, filled backwards · **Target:** O(m + n) time, O(1) extra space

---

## 1. The problem

You're given two integer arrays `nums1` and `nums2`, both sorted in **non-decreasing** order (ascending, duplicates allowed), plus two integers `m` and `n` giving the number of real elements in each.

Merge them into one sorted array. **Do not return anything** — the answer must end up *inside* `nums1`.

To make room, `nums1` has length `m + n`: the first `m` slots hold real data, the last `n` slots are `0` padding you should ignore.

```
nums1 = [1, 2, 3, 0, 0, 0]     m = 3
         └───────┘  └──────┘
        real data    padding (3 empty slots)

nums2 = [2, 5, 6]              n = 3

answer: nums1 becomes [1, 2, 2, 3, 5, 6]
```

### Examples

| # | nums1 | m | nums2 | n | Result |
|---|-------|---|-------|---|--------|
| 1 | `[1,2,3,0,0,0]` | 3 | `[2,5,6]` | 3 | `[1,2,2,3,5,6]` |
| 2 | `[1]` | 1 | `[]` | 0 | `[1]` |
| 3 | `[0]` | 0 | `[1]` | 1 | `[1]` |

In example 3, `m = 0` means `nums1` has **no** real elements — that `0` is only there so the result can fit.

### Constraints

```
nums1.length == m + n
nums2.length == n
0 <= m, n <= 200
1 <= m + n <= 200
-10^9 <= nums1[i], nums2[j] <= 10^9
```

### Mental model

Think of `nums1` as **a shelf with `m + n` slots**. `m` slots have books; `n` are empty. Get all the books onto that shelf in order, without a second shelf.

---

## 2. Why this is trickier than it looks

Merging two sorted lists is easy *when you have somewhere to put the result*. The difficulty is that the output buffer **is** one of the inputs.

Try the natural approach — compare the smallest of each, write the winner to the front:

```
nums1 = [1, 2, 3, 0, 0, 0]     nums2 = [2, 5, 6]

Round 1: 1 vs 2 → 1 smaller → write 1 at index 0  →  [1, 2, 3, 0, 0, 0]   ok
Round 2: 2 vs 2 → tie, take nums1 → write 2 at index 1  →  [1, 2, 3, 0, 0, 0]   ok
Round 3: 3 vs 2 → 2 smaller → write 2 at index 2  →  [1, 2, 2, 0, 0, 0]
                                                            ^
                                              the 3 was there — destroyed
```

**That's the whole problem.** The front of `nums1` is occupied by data you still need to read. Every write to the front smashes an unread value.

You *could* copy `nums1` into a scratch array first. That works and is easy to reason about, but it costs O(m + n) extra memory — and the problem's follow-up is nudging you toward something better.

---

## 3. The key insight

Look at where the free space is:

```
nums1 = [1, 2, 3, _, _, _]
                  └──────┘
             empty slots are at the END
```

Writing to the front is dangerous. Writing to the **back** is completely safe — those slots are garbage.

So flip the direction. Instead of *"what's the smallest? put it first,"* ask:

> ### "What's the BIGGEST number? Put it last."

Then second-biggest second-to-last, and so on, filling right to left.

And finding the biggest is trivial: since both arrays are sorted, the largest remaining value is either the **last** remaining value of `nums1` or the **last** remaining value of `nums2`. One comparison.

### Three fingers

| Name | Starts at | Meaning |
|------|-----------|---------|
| `p1` | `m - 1` | read finger — last *real* value in `nums1` |
| `p2` | `n - 1` | read finger — last value in `nums2` |
| `write` | `m + n - 1` | write finger — last slot in `nums1` |

Each round: compare `nums1[p1]` vs `nums2[p2]`, copy the bigger to `nums1[write]`, step that read finger left, step `write` left.

---

## 4. Solution (Ruby)

```ruby
# @param {Integer[]} nums1
# @param {Integer} m
# @param {Integer[]} nums2
# @param {Integer} n
# @return {Void} modifies nums1 in place
def merge(nums1, m, nums2, n)
  p1    = m - 1        # read finger: last real value in nums1
  p2    = n - 1        # read finger: last value in nums2
  write = m + n - 1    # write finger: last slot in nums1

  # Loop until nums2 is empty. Whatever is left in nums1 is already in place.
  while p2 >= 0
    if p1 >= 0 && nums1[p1] > nums2[p2]
      nums1[write] = nums1[p1]   # nums1 has the bigger value
      p1 -= 1
    else
      nums1[write] = nums2[p2]   # nums2 wins, or nums1 is exhausted
      p2 -= 1
    end
    write -= 1                   # one slot filled, step left
  end
end
```

### Line notes

- **`while p2 >= 0`** — only `p2` is guarded. See §6.
- **`p1 >= 0 &&`** — short-circuit for "nums1 is exhausted." Critical in Ruby (see §8).
- **`>` not `>=`** — on a tie we fall to the `else` and take from `nums2`. Harmless: the values are equal, so the sorted result is identical either way.
- **Only one read finger moves per round** (you consumed one value), but **`write` moves every round** (you always filled one slot).

---

## 5. Iteration-by-iteration trace

Input: `nums1 = [1,2,3,0,0,0]`, `m = 3`, `nums2 = [2,5,6]`, `n = 3`

Legend — `_` = padding not yet written · `.` = dead space (nums1 value already consumed)

```
start: p1 = 2, p2 = 2, write = 5

        nums1:    1   2   3   _   _   _
                        ^p1          ^w
        nums2:    2   5   6
                        ^p2

ITER 1: nums1[2]=3 vs nums2[2]=6  ->  6 is bigger, take from NUMS2
        nums1[5] = 6;  p2 2 -> 1;  write 5 -> 4
        nums1:    1   2   3   _   _   6
                        ^p1      ^w
        nums2:    2   5   6
                    ^p2

ITER 2: nums1[2]=3 vs nums2[1]=5  ->  5 is bigger, take from NUMS2
        nums1[4] = 5;  p2 1 -> 0;  write 4 -> 3
        nums1:    1   2   3   _   5   6
                        ^p1  ^w
        nums2:    2   5   6
                ^p2

ITER 3: nums1[2]=3 vs nums2[0]=2  ->  3 is bigger, take from NUMS1
        nums1[3] = 3;  p1 2 -> 1;  write 3 -> 2
        nums1:    1   2   .   3   5   6
                    ^p1  ^w
        nums2:    2   5   6
                ^p2

ITER 4: nums1[1]=2 vs nums2[0]=2  ->  tied, take from NUMS2
        nums1[2] = 2;  p2 0 -> -1;  write 2 -> 1
        nums1:    1   2   2   3   5   6
                   ^p1+w
        nums2:    2   5   6

STOP: p2 = -1 (nums2 exhausted). Anything left in nums1 is already in place.
RESULT: [1, 2, 2, 3, 5, 6]
```

### What happened each round

**Setup.** `write` starts **3 columns right of `p1`** — that gap *is* your 3 free slots, and it's what makes the whole thing safe.

**ITER 1 — `3` vs `6`.** Both arrays are sorted, so the largest value in the merged result must be the last value of one of them. It's `6`, so `6` belongs at index 5. We consumed a nums2 value, so **only `p2` moves**; `p1` stays parked on the `3` because the `3` hasn't been used yet.

**ITER 2 — `3` vs `5`.** Same `3` compared again, now against `5`. `5` wins, lands at index 4.

**ITER 3 — `3` vs `2`.** First nums1 win. `3` goes to index 3 and **`p1` moves** this time. Watch index 2 become `.` — it still physically contains a `3`, but `p1` has moved past it so nobody will read it again. It's now free space. **This is the mechanism that keeps the algorithm from running out of room:** every value consumed from nums1 hands back its slot.

**ITER 4 — `2` vs `2`.** Tie → `else` branch → take nums2's `2`, writing into index 2, the slot ITER 3 just freed. `p2` drops to `-1`.

**STOP.** Loop condition fails. Four iterations, not six.

---

## 6. Why the loop only checks `p2`

Look at the final state: indices 0 and 1 hold `1` and `2`, and we **never touched them**. They were already in their correct final positions from the start, because nums1's smallest values belong at nums1's front.

- **`nums2` empties first** → every remaining nums1 value is already correctly placed. Nothing to do. ✅
- **`nums1` empties first** → remaining nums2 values still must be copied in. Must keep looping.

So the loop watches `p2` only. Adding `|| p1 >= 0` isn't *wrong*, just wasted work copying values onto themselves.

---

## 7. Why `write` can never clobber an unread value

This is the correctness guarantee. Track the gap between `write` and `p1` in the trace: **3 → 2 → 1 → 0**.

At every moment, `write = p1 + p2 + 1`:

- At the start: `(m-1) + (n-1) + 1 = m + n - 1` ✅
- Each round decrements `write` and exactly one of `p1` / `p2`, so the identity holds forever.

Since `p2 >= -1` always, it follows that **`write >= p1`**, with equality only when `p2 == -1` — the exact moment the loop exits. In the trace they met at `^p1+w` on the final iteration and never crossed.

Put plainly: *the gap between the write finger and the read finger equals how many nums2 values are left.* It can't go negative, so the write finger can never overtake data you still need.

---

## 8. Ruby-specific gotchas

### `p1 >= 0` is load-bearing, not defensive

In most languages `nums1[-1]` crashes or returns garbage, so you'd notice. **Ruby silently wraps negative indexes to the end of the array:**

```ruby
[1, 2, 3][-1]   # => 3   (not nil, not an error!)
```

Drop the guard and when `nums1` runs out, `nums1[-1]` returns whatever you last wrote to the tail — no crash, just a quietly wrong answer that's miserable to debug.

### Use `&&`, not `and`

`and` binds looser than assignment and can silently regroup your expression. Reserve `and` / `or` for control flow (`do_thing or raise`); use `&&` / `||` inside conditions.

### Don't submit the one-liner

```ruby
nums1[m, n] = nums2   # replace padding with nums2
nums1.sort!           # and sort
```

This passes on LeetCode. But it's **O((m+n) log(m+n))** and discards the fact that both inputs were already sorted — which is the entire point of the exercise. Know it exists; submit the pointer version.

### `while`, not `each` / `times`

Two pointers advancing at independent rates don't fit an iterator: only one of `p1`/`p2` moves per round while `write` moves every round. A plain `while` is idiomatic here, not a cop-out.

---

## 9. Edge cases (handled for free)

| Input | What happens |
|-------|--------------|
| `nums1=[1], m=1, nums2=[], n=0` | `p2` starts at `-1` → loop never runs → `[1]` ✅ |
| `nums1=[0], m=0, nums2=[1], n=1` | `p1` starts at `-1` → `p1 >= 0` false → `else` → writes `1` at index 0 → `[1]` ✅ |
| `nums1=[0,0,0], m=0, nums2=[1,2,3], n=3` | `p1 = -1` throughout, dumps all of nums2 in reverse → `[1,2,3]` ✅ |
| All values equal | Every tie takes the `else` branch; result still correct |
| Negative values | Nothing assumes positivity; only `>` is used |

Notice you wrote **no special cases** for any of these. That's a good sign the core logic is right.

---

## 10. Complexity

| | |
|---|---|
| **Time** | **O(m + n)** — each iteration permanently places one value, and there are `m + n` values. Answers the follow-up. |
| **Space** | **O(1)** — three integer variables, no auxiliary array. |

---

## 11. The transferable pattern

> **When you must write in place into a buffer that is also your input, pick the traversal direction where the write cursor *chases* the read cursor instead of running into it.**

Two questions to ask on any in-place array problem:

1. **Where is the free space?** At the tail → iterate backwards. At the head → iterate forwards.
2. **Does the write cursor stay behind every read cursor?** Yes → in-place with O(1) space. No → you need a buffer.

The second signal is **sorted input**. Two sorted sequences plus "combine them" almost always means two pointers advancing monotonically — never nested loops, never a re-sort.

### Same trick, other problems

| Problem | Direction / free space |
|---------|------------------------|
| 88. Merge Sorted Array | free space at tail → fill backwards |
| 977. Squares of a Sorted Array | largest squares at both *ends* → pointers inward, fill result backwards |
| 26. Remove Duplicates from Sorted Array | slow write pointer trails fast read pointer, forwards |
| 27. Remove Element | same forward slow/fast shape |
| 283. Move Zeroes | same forward slow/fast shape |
| 21. Merge Two Sorted Lists | new list, forward two pointers |
| 986. Interval List Intersections | forward two pointers over sorted intervals |
| 4. Median of Two Sorted Arrays | this merge idea, then binary-searched |
| Merge step of Merge Sort | the general form of all of the above |

**Backward fill** (88, 977) and **forward slow/fast** (26, 27, 283) are the two shapes of one idea. Once you spot "in-place + sorted," reach for a pointer pair and spend ten seconds choosing the direction — *the direction is the problem.*

---

## 12. Appendix: other languages

<details>
<summary>Python</summary>

```python
class Solution:
    def merge(self, nums1: List[int], m: int, nums2: List[int], n: int) -> None:
        p1, p2, write = m - 1, n - 1, m + n - 1
        while p2 >= 0:
            if p1 >= 0 and nums1[p1] > nums2[p2]:
                nums1[write] = nums1[p1]
                p1 -= 1
            else:
                nums1[write] = nums2[p2]
                p2 -= 1
            write -= 1
```

Python also wraps negative indexes, so the `p1 >= 0` guard matters here too.
</details>

<details>
<summary>Java</summary>

```java
class Solution {
    public void merge(int[] nums1, int m, int[] nums2, int n) {
        int p1 = m - 1, p2 = n - 1, write = m + n - 1;
        while (p2 >= 0) {
            if (p1 >= 0 && nums1[p1] > nums2[p2]) nums1[write--] = nums1[p1--];
            else                                  nums1[write--] = nums2[p2--];
        }
    }
}
```
</details>

---

## Files in this folder

| File | Purpose |
|------|---------|
| `merge.rb` | Clean solution + 8 test cases (`ruby merge.rb`) |
| `merge_traced.rb` | Prints the pointer state every iteration (`ruby merge_traced.rb`) |
| `merge-sorted-array.md` | This document |

To trace your own input, edit the **last line** of `merge_traced.rb`:

```ruby
merge([1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3)
```

Try `merge([4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3)` — nums1 wins every round there and `write` never catches up to `p1` at all.

## One-line takeaway

**The empty space is at the end, so build the answer from the end. Biggest number goes last.**
