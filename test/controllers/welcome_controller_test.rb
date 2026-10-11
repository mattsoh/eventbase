require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "root renders the placeholder welcome page" do
    get root_path

    assert_response :success
    assert_select "h1#hero-title", "Placeholder text"
    assert_select "header.site-header .placeholder-image.logo__mark"
    assert_select "#featured article.event", 3
    assert_select "#featured .event__media .placeholder-image", 3
    assert_select "footer.site-footer"
  end
end
