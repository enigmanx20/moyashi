require 'test_helper'

class MatlabControllerTest < ActionController::TestCase
  test "should get pca_lda" do
    get :pca_lda
    assert_response :success
  end

end
