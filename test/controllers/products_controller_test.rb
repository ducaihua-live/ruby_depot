require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    login_as users(:one)
  end

  test "should destroy product" do
    product = products(:two)
    assert_difference("Product.count", -1) do
      delete product_url(product)
    end
    assert_not Product.exists?(product.id)
  end

  test "should not destroy product with line items" do
    product = products(:one)  # This product has line items
    assert_no_difference("Product.count") do
      delete product_url(product)
    end
    assert Product.exists?(product.id)
    assert_redirected_to products_path
    # The controller redirects with an alert message when destroy fails
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { description: @product.description, price: @product.price, title: "Unique Product Title" } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { description: "Updated description", price: 19.99, title: "Updated Title" } }
    assert_redirected_to product_url(@product)
  end

  # test "should destroy product" do
  #  assert_difference("Product.count", -1) do
  #    delete product_url(@product)
  #  end

  #  assert_redirected_to products_url
  # end

  # Validation failure tests
  test "should not create product with invalid data" do
    assert_no_difference("Product.count") do
      post products_url, params: { product: { title: "", description: "", price: nil } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create product with duplicate title" do
    assert_no_difference("Product.count") do
      post products_url, params: { product: { title: @product.title, description: "Some description", price: 10.99 } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create product with negative price" do
    assert_no_difference("Product.count") do
      post products_url, params: { product: { title: "New Product", description: "Description", price: -1 } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create product with zero price" do
    assert_no_difference("Product.count") do
      post products_url, params: { product: { title: "New Product", description: "Description", price: 0 } }
    end

    assert_response :unprocessable_entity
  end

  test "should not update product with invalid data" do
    patch product_url(@product), params: { product: { title: "", description: "", price: nil } }
    assert_response :unprocessable_entity
  end

  test "should not update product with duplicate title" do
    other_product = products(:two)
    patch product_url(@product), params: { product: { title: other_product.title, description: @product.description, price: @product.price } }
    assert_response :unprocessable_entity
  end

  test "should not update product with invalid price" do
    patch product_url(@product), params: { product: { title: @product.title, description: @product.description, price: -5 } }
    assert_response :unprocessable_entity
  end

  # Error handling tests
  test "should show 404 for non-existent product" do
    get product_url(id: 99999)
    assert_response :not_found
  end

  test "should not update non-existent product" do
    patch product_url(id: 99999), params: { product: { title: "Test", description: "Test", price: 10 } }
    assert_response :not_found
  end

  test "should not destroy non-existent product" do
    delete product_url(id: 99999)
    assert_response :not_found
  end

  # JSON API tests
  test "should create product via JSON" do
    assert_difference("Product.count") do
      post products_url, params: { product: { title: "JSON Product", description: "JSON Description", price: 25.99 } }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "JSON Product", json_response["title"]
    assert_equal "JSON Description", json_response["description"]
  end

  test "should show product via JSON" do
    get product_url(@product), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @product.title, json_response["title"]
    assert_equal @product.description, json_response["description"]
  end

  test "should update product via JSON" do
    patch product_url(@product), params: { product: { title: "Updated JSON Title", description: @product.description, price: 29.99 } }, as: :json
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Updated JSON Title", json_response["title"]
  end

  test "should return errors via JSON on invalid create" do
    post products_url, params: { product: { title: "", description: "", price: nil } }, as: :json
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    # Rails returns errors in different formats, check if response contains error information
    assert json_response.is_a?(Hash)
    # Errors might be in "errors" key or directly in the hash
    assert json_response.key?("errors") || json_response.any? { |k, v| k.to_s.include?("error") || (v.is_a?(Array) && v.any?) }
  end

  # Image validation tests
  test "should create product with valid image" do
    image = fixture_file_upload("lorem.jpg", "image/jpeg")
    assert_difference("Product.count") do
      post products_url, params: { product: { title: "Product With Image", description: "Description", price: 15.99, image: image } }
    end
    assert_redirected_to product_url(Product.last)
  end

  test "should not create product with invalid image type" do
    image = fixture_file_upload("logo.svg", "image/svg+xml")
    assert_no_difference("Product.count") do
      post products_url, params: { product: { title: "Product With Bad Image", description: "Description", price: 15.99, image: image } }
    end
    assert_response :unprocessable_entity
  end

  # Edge cases
  test "should handle empty products list" do
    Product.destroy_all
    get products_url
    assert_response :success
  end

  test "should update product with same valid data" do
    # Use a product with a unique title to avoid uniqueness validation issues
    unique_product = products(:pragprog)
    patch product_url(unique_product), params: { product: { title: unique_product.title, description: unique_product.description, price: unique_product.price } }
    assert_redirected_to product_url(unique_product)
  end

  test "should create product with minimum valid price" do
    assert_difference("Product.count") do
      post products_url, params: { product: { title: "Minimum Price Product", description: "Description", price: 0.01 } }
    end
    assert_redirected_to product_url(Product.last)
  end
end
