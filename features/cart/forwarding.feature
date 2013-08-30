Feature: Cart Forwarding

  In order to have a smooth transfer experience to the real store
  A customer
  Wants to the forward operation to be explicit and straightforward

  Background:

    We have a cart ready to be transfered to another store.

    Given the "www.dummy-store.com" store
    And I have items in my cart

  Scenario: A customer is accompanied through a transfer

    The transfer remains a long, tricky and unfamiliar process.
    It is important to be clear about what is happening and
    to make sure it is as straightforward as possible.

    Opening a standard POST form in a new tab fails (it it transformed as
    a GET ...) Because it is usefull to be able to check what was not transfered while
    searching substitutes on auchan, the final button to log into the store
    should always open a new tab.

    When I start to transfer my cart to the store "www.dummy-store.com"

    When no items have yet actually been transfered to the store "www.dummy-store.com"
    Then I should see that between 1% and 15% of the cart have been transfered to the store

    When items are actually being transfered to the store "www.dummy-store.com"
    Then I should see that between 15% and 90% of the cart have been transfered to the store

    When all items have actually been transfered to the store "www.dummy-store.com"
    Then I should see that between 90% and 100% of the cart have been transfered to the store
    And the client should be automaticaly logged out from the store "www.dummy-store.com"

    When the transfer is completely finished
    Then there should be a button to log into the store "www.dummy-store.com" in a new tab
