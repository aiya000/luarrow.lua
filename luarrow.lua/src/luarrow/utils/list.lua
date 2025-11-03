local M = {}

---Apply a function to each element, producing a new list.
---@generic A, B
---@param list A[]
---@param f fun(x: A): B
---@return B[]
function M.map(list, f)
  local result = {}
  for i, v in ipairs(list) do
    result[i] = f(v)
  end
  return result
end

---Keep elements that satisfy a predicate.
---@generic A
---@param list A[]
---@param pred fun(x: A): boolean
---@return A[]
function M.filter(list, pred)
  local result = {}
  for _, v in ipairs(list) do
    if pred(v) then
      table.insert(result, v)
    end
  end
  return result
end

---Map then flatten one level.
---@generic A, B
---@param list A[]
---@param f fun(x: A): B[]
---@return B[]
function M.flat_map(list, f)
  local result = {}
  for _, v in ipairs(list) do
    local mapped = f(v)
    for _, item in ipairs(mapped) do
      table.insert(result, item)
    end
  end
  return result
end

---Alias for flat_map
M.concat_map = M.flat_map

---Left fold.
---@generic A, B
---@param list A[]
---@param f fun(acc: B, x: A): B
---@param init B
---@return B
function M.foldl(list, f, init)
  local acc = init
  for _, v in ipairs(list) do
    acc = f(acc, v)
  end
  return acc
end

---Alias for foldl
M.reduce = M.foldl

---Right fold.
---@generic A, B
---@param list A[]
---@param f fun(x: A, acc: B): B
---@param init B
---@return B
function M.foldr(list, f, init)
  local acc = init
  for i = #list, 1, -1 do
    acc = f(list[i], acc)
  end
  return acc
end

---Left fold without initial value.
---@generic A
---@param list A[]
---@param f fun(acc: A, x: A): A
---@return A
function M.foldl1(list, f)
  if #list == 0 then
    error('foldl1: empty list')
  end
  local acc = list[1]
  for i = 2, #list do
    acc = f(acc, list[i])
  end
  return acc
end

---Right fold without initial value.
---@generic A
---@param list A[]
---@param f fun(x: A, acc: A): A
---@return A
function M.foldr1(list, f)
  if #list == 0 then
    error('foldr1: empty list')
  end
  local acc = list[#list]
  for i = #list - 1, 1, -1 do
    acc = f(list[i], acc)
  end
  return acc
end

---Flatten one level of nesting.
---@generic A
---@param list A[][]
---@return A[]
function M.flatten(list)
  local result = {}
  for _, sublist in ipairs(list) do
    for _, item in ipairs(sublist) do
      table.insert(result, item)
    end
  end
  return result
end

---Join list of strings with delimiter.
---@param list string[]
---@param sep string
---@return string
function M.join(list, sep)
  return table.concat(list, sep)
end

---Sum numeric elements.
---@param list number[]
---@return number
function M.sum(list)
  local total = 0
  for _, v in ipairs(list) do
    total = total + v
  end
  return total
end

---Product of numeric elements.
---@param list number[]
---@return number
function M.product(list)
  if #list == 0 then
    return 1
  end
  local result = 1
  for _, v in ipairs(list) do
    result = result * v
  end
  return result
end

---Return number of elements.
---@generic A
---@param list A[]
---@return integer
function M.length(list)
  return #list
end

---True if list is empty.
---@generic A
---@param list A[]
---@return boolean
function M.is_empty(list)
  return #list == 0
end

---First element (or nil).
---@generic A
---@param list A[]
---@return A | nil
function M.head(list)
  return list[1]
end

---List without the first element.
---@generic A
---@param list A[]
---@return A[]
function M.tail(list)
  local result = {}
  for i = 2, #list do
    table.insert(result, list[i])
  end
  return result
end

---Last element (or nil).
---@generic A
---@param list A[]
---@return A | nil
function M.last(list)
  return list[#list]
end

---All elements except the last.
---@generic A
---@param list A[]
---@return A[]
function M.init(list)
  local result = {}
  for i = 1, #list - 1 do
    table.insert(result, list[i])
  end
  return result
end

---Reverse the list.
---@generic A
---@param list A[]
---@return A[]
function M.reverse(list)
  local result = {}
  for i = #list, 1, -1 do
    table.insert(result, list[i])
  end
  return result
end

---Largest element.
---@param list number[]
---@return number
function M.maximum(list)
  if #list == 0 then
    error('maximum: empty list')
  end
  local max = list[1]
  for i = 2, #list do
    if list[i] > max then
      max = list[i]
    end
  end
  return max
end

---Smallest element.
---@param list number[]
---@return number
function M.minimum(list)
  if #list == 0 then
    error('minimum: empty list')
  end
  local min = list[1]
  for i = 2, #list do
    if list[i] < min then
      min = list[i]
    end
  end
  return min
end

---Sort with default comparator.
---@generic A
---@param list A[]
---@return A[]
function M.sort(list)
  local result = {}
  for i, v in ipairs(list) do
    result[i] = v
  end
  table.sort(result)
  return result
end

---Sort by key function or comparator.
---When key is a function that returns a value, it sorts by that value.
---When key is a comparator function, it uses it directly.
---
---Note: If a key function accepts two arguments and returns a boolean,
---it will be treated as a comparator. In such cases, use a wrapper:
---  `sort_by(list, function(x) return key_fn(x) end)`
---@generic A, K
---@param list A[]
---@param key fun(x: A): K | fun(a: A, b: A): boolean
---@return A[]
function M.sort_by(list, key)
  local result = {}
  for i, v in ipairs(list) do
    result[i] = v
  end

  -- Safely detect if key is a comparator or key function
  -- Try calling with two arguments in a protected call
  local is_comparator = false
  if #list >= 2 then
    local success, test_result = pcall(key, list[1], list[2])
    if success and type(test_result) == 'boolean' then
      is_comparator = true
    end
  end

  if is_comparator then
    -- It's a comparator function
    table.sort(result, key)
  else
    -- It's a key function
    table.sort(result, function(a, b)
      return key(a) < key(b)
    end)
  end

  return result
end

---Alias for sort_by
M.sort_with = M.sort_by

---Remove duplicates (first occurrence kept).
---@generic A
---@param list A[]
---@return A[]
function M.unique(list)
  local result = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    end
  end
  return result
end

---Group by key function.
---@generic A, K
---@param list A[]
---@param f fun(x: A): K
---@return table<K, A[]>
function M.group_by(list, f)
  local result = {}
  for _, v in ipairs(list) do
    local key = f(v)
    if not result[key] then
      result[key] = {}
    end
    table.insert(result[key], v)
  end
  return result
end

---Find first element that satisfies predicate.
---@generic A
---@param list A[]
---@param pred fun(x: A): boolean
---@return A | nil
function M.find(list, pred)
  for _, v in ipairs(list) do
    if pred(v) then
      return v
    end
  end
  return nil
end

return M
