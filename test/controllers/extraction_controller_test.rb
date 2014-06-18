require 'test_helper'

class ExtractionControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get extract" do
    get :extract
    assert_response :success
  end

end
