require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
    # Set up a cart with items for the order tests
    @cart = carts(:one)
    # Ensure the cart has items by visiting store and adding one
    # For rack_test, we'll set up the session directly
  end

  test "visiting the index" do
    visit orders_url
    assert_selector "h1", text: "Orders"
  end

  test "should create order" do
    # Set up cart with items in session
    # Visit store to initialize session
    visit store_index_url
    
    # Use rack_test's session to set cart_id directly
    # The cart fixture has line items, so we just need to set it in session
    cart = carts(:one)
    page.driver.browser.set_cookie("_depot_session", { cart_id: cart.id }.to_json)
    
    # Now visit the new order page
    visit new_order_url
    assert_selector "h1", text: "Please Enter Your Details"

    fill_in "Address", with: @order.address
    fill_in "Email", with: @order.email
    fill_in "Name", with: @order.name
    select @order.pay_type, from: "Pay type"
    click_on "Place Order"

    assert_text "Thank you for your order"
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit this order", match: :first

    fill_in "Address", with: @order.address
    fill_in "Email", with: @order.email
    fill_in "Name", with: @order.name
    select @order.pay_type, from: "Pay type"
    click_on "Place Order"

    assert_text "Order was successfully updated"
  end

  test "should destroy Order" do
    visit order_url(@order)
    click_on "Destroy this order", match: :first

    assert_text "Order was successfully destroyed"
  end
end
