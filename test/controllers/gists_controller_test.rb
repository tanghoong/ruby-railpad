require "test_helper"

class GistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gist = gists(:hello)
  end

  # ── Index ─────────────────────────────────────────────────

  test "should get index" do
    get gists_url
    assert_response :success
  end

  test "should filter gists by search term" do
    get gists_url, params: { search: "Hello" }
    assert_response :success
    assert_select ".article-row", minimum: 1
  end

  test "should filter gists by published status" do
    get gists_url, params: { status: "published" }
    assert_response :success
  end

  test "should filter gists by draft status" do
    get gists_url, params: { status: "draft" }
    assert_response :success
  end

  # ── New / Show / Edit ─────────────────────────────────────

  test "should get new" do
    get new_gist_url
    assert_response :success
  end

  test "should show gist" do
    get gist_url(@gist)
    assert_response :success
  end

  test "should get edit" do
    get edit_gist_url(@gist)
    assert_response :success
  end

  # ── Create ────────────────────────────────────────────────

  test "should create gist" do
    assert_difference("Gist.count") do
      post gists_url, params: {
        gist: { title: "New Test Gist", code: "puts 'created from test'", language: "ruby" }
      }
    end
    assert_redirected_to gist_url(Gist.last)
  end

  test "should not create gist with invalid data" do
    assert_no_difference("Gist.count") do
      post gists_url, params: { gist: { title: "", code: "" } }
    end
    assert_response :unprocessable_entity
  end

  # ── Update ────────────────────────────────────────────────

  test "should update gist" do
    patch gist_url(@gist), params: {
      gist: { title: "Updated Title" }
    }
    assert_redirected_to gist_url(@gist)
  end

  test "should not update gist with invalid data" do
    patch gist_url(@gist), params: { gist: { title: "" } }
    assert_response :unprocessable_entity
  end

  # ── Destroy ───────────────────────────────────────────────

  test "should destroy gist" do
    assert_difference("Gist.count", -1) do
      delete gist_url(@gist)
    end
    assert_redirected_to gists_url
  end

  # ── Run ───────────────────────────────────────────────────

  test "should run gist and store output" do
    post run_gist_url(@gist)
    assert_redirected_to gist_url(@gist)
    @gist.reload
    assert @gist.ran?
    assert @gist.output.present?
  end

  # ── JSON API ──────────────────────────────────────────────

  test "should return gists as JSON" do
    get gists_url(format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "should return single gist as JSON" do
    get gist_url(@gist, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @gist.title, json["title"]
  end
end
