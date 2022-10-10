#lang dssl2

# HW1: DSSL2 Warmup
#
# ** You must work on your own for this assignment. **

###
### ACCOUNTS
###

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

# an Account is either a checking or a saving account
let account_type? = OrC("checking", "savings")

class Account:
    let id
    let type
    let balance

    # Account(nat?, account_type?, num?) -> Account?
    # Constructs an account with the given ID number, account type, and
    # balance. The balance cannot be negative.
    def __init__(self, id, type, balance):
        if balance < 0: error('Account: negative balance')
        if not account_type?(type): error('Account: unknown type')
        self.id = id
        self.type = type
        self.balance = balance

    # .get_balance() -> num?
    def get_balance(self): return self.balance

    # .get_id() -> nat?
    def get_id(self): return self.id

    # .get_type() -> account_type?
    def get_type(self): return self.type

    # .deposit(num?) -> NoneC
    # Deposits `amount` in the account. `amount` must be non-negative.
    def deposit(self, amount):
        if amount >= 0:
            self.balance = amount + self.balance 
        else: 
            error("error")
#   ^ FILL IN YOUR CODE HERE

    # .withdraw(num?) -> NoneC
    # Withdraws `amount` from the account. `amount` must be non-negative
    # and must not exceed the balance.
    def withdraw(self, amount):
        if amount <= self.balance and amount >= 0:
                self.balance = self.balance - amount
        else: 
            error("error")
#   ^ FILL IN YOUR CODE HERE

    # .__eq__(Account?) -> bool?
    # Determines whether `self` and `other` are equal.
    def __eq__(self, other):
        if self.id == other.get_id() and self.type == other.get_type() and self.balance == other.get_balance():
            return True
        else: 
            return False

#   ^ FILL IN YOUR CODE HERE

test 'Account#withdraw and deposit':
    let account = Account(2, "checking", 32)
    assert account.get_balance() == 32
    account.withdraw(10)
    assert account.get_balance() == 22
    account.withdraw(0)
    assert account.get_balance() == 22
    assert_error account.withdraw(-10)
    assert_error account.deposit(-10)
    account.deposit(10)
    assert account.get_balance() == 32
    account.withdraw(32)
    assert account.get_balance() == 0
    assert_error account.withdraw(1)
    
test 'Account#__eq__':
    assert Account(5, "checking", 500) == Account(5, "checking", 500)


# account_transfer(num?, Account?, Account?) -> NoneC
# Transfers the specified amount from the first account to the second.
# That is, it subtracts `amount` from the `from` account’s balance and
# adds `amount` to the `to` account’s balance. `amount` must be non-
# negative.
def account_transfer(amount, from, to):
    to.deposit(amount)
    from.withdraw(amount)
    

#   ^ FILL IN YOUR CODE HERE
test 'Account transfer':
    let account1 = Account(1, "checking", 900) 
    let account2 = Account(2, "savings", 20)
    account_transfer(100, account1, account2)
    assert account1 == Account(1, "checking", 800)
    assert account2 == Account(2, "savings", 120)
    assert_error account_transfer(-2, account1, account2)

###
### CUSTOMERS
### customers = [customer1, customer2, customer3] customers[0]

# Customers have names and bank accounts.
struct customer:
    let name
    let bank_account

# max_account_id(VecC[customer?]) -> nat?
# Find the largest account id used by any of the given customers' accounts.
# Raise an error if no customers are provided.
def max_account_id(customers):
    let maxid = 0 
    if len(customers) > 0:
        for i in customers:
            if i.bank_account.get_id() > maxid:
                maxid = i.bank_account.get_id()
        return maxid
    else: 
        error("No customers given")
#   ^ FILL IN YOUR CODE HERE
test 'Customer maxid':
    let account1 = Account(1, "checking", 900) 
    let account2 = Account(2, "savings", 20)
    let customer1 = customer("custom1", account1)
    let customer2 = customer("custom2", account2)
    let customers = [customer1, customer2]
    assert max_account_id(customers) == 2
    let customersv2 = []
    assert_error max_account_id(customersv2)
# open_account(str?, account_type?, VecC[customer?]) -> VecC[customer?]
# Produce a new vector of customers, with a new customer added. That new
# customer has the provided name, and their new account has the given type and
# a balance of 0. The id of the new account should be one more than the current
# maximum, or 1 for the first account created.
def open_account(name, type, customers):
    let new_customers = [0; len(customers) + 1]
    if len(customers) > 0:
        let newcustomer = customer(name, Account(1 + max_account_id(customers), type, 0))
        for i in range(len(customers)):
            new_customers[i] = customers[i]
        new_customers[len(customers)] = newcustomer
    else:
        let newcustomer = customer(name, Account(1, type, 0))
        new_customers = [newcustomer]
    return new_customers
        
         
test 'Customer open account':
    let account1 = Account(1, "checking", 900) 
    let account2 = Account(2, "savings", 20)
    let customer1 = customer("custom1", account1)
    let customer2 = customer("custom2", account2)
    let customers = [customer1, customer2]  
    customers = open_account("custom3", "checking", customers)
    assert customers == [customer1, customer2, customer("custom3", Account(3, "checking", 0))]
    customers = []
    customers = open_account("custom3", "checking", customers)
    assert customers == [customer("custom3", Account(1, "checking", 0))]
#   ^ FILL IN YOUR CODE HERE

# check_sharing(VecC[customer?]) -> bool?
# Checks whether any of the given customers share an account.
def check_sharing(customers): 
    for i in range(len(customers)-1):
        for j in range(i + 1, len(customers)):
            if customers[i].bank_account.get_id() == customers[j].bank_account.get_id():
                return True
    return False
test 'Customer sharing':
    let customers = []
    let customers2 = []
    let customers3 = []
    assert check_sharing(customers) == False
    let account1 = Account(2, "checking", 900) 
    let account2 = Account(2, "savings", 20)
    let account3 = Account(3, "checking", 90)
    let customer1 = customer("custom1", account1)
    let customer2 = customer("custom2", account2)
    let customer3 = customer("custom3", account3)
    customers = [customer1, customer2]  
    customers2= [customer1, customer2, customer3]
    customers3= [customer2, customer3]
    assert check_sharing(customers) == True
    assert check_sharing(customers2) == True
    assert check_sharing(customers3) == False
#   ^ FILL IN YOUR CODE HERE
