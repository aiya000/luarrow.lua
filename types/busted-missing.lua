---@meta

---Describes a test suite
---@param description string The description of the test suite
---@param fn fun() The function containing the tests
describe = describe

---Defines a test case
---@param description string The description of the test
---@param fn fun() The test function
it = it

---Defines a pending test case
---@param description string The description of the test
---@param fn? fun() The test function (optional)
pending = pending

---Runs before each test in a describe block
---@param fn fun() The setup function
before_each = before_each

---Runs after each test in a describe block
---@param fn fun() The teardown function
after_each = after_each

---Runs once before all tests in a describe block
---@param fn fun() The setup function
setup = setup

---Runs once after all tests in a describe block
---@param fn fun() The teardown function
teardown = teardown
