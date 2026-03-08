require "test_helper"

class GistTest < ActiveSupport::TestCase
  def valid_attrs
    { title: "Valid Gist", code: "puts 'hello world'", language: "ruby" }
  end

  # ── Presence validations ───────────────────────────────────

  test "is valid with required fields" do
    gist = Gist.new(valid_attrs)
    assert gist.valid?
  end

  test "is invalid without a title" do
    gist = Gist.new(valid_attrs.merge(title: ""))
    assert_not gist.valid?
    assert_includes gist.errors[:title], "can't be blank"
  end

  test "is invalid without code" do
    gist = Gist.new(valid_attrs.merge(code: ""))
    assert_not gist.valid?
    assert_includes gist.errors[:code], "can't be blank"
  end

  # ── Length validations ────────────────────────────────────

  test "is invalid when title is too short" do
    gist = Gist.new(valid_attrs.merge(title: "Hi"))
    assert_not gist.valid?
  end

  test "is invalid when title is too long" do
    gist = Gist.new(valid_attrs.merge(title: "A" * 101))
    assert_not gist.valid?
  end

  test "is invalid when code is too short" do
    gist = Gist.new(valid_attrs.merge(code: "p 1"))
    assert_not gist.valid?
  end

  test "is invalid when description is too long" do
    gist = Gist.new(valid_attrs.merge(description: "D" * 501))
    assert_not gist.valid?
  end

  test "description is optional" do
    gist = Gist.new(valid_attrs.merge(description: ""))
    assert gist.valid?
  end

  # ── Language validation ───────────────────────────────────

  test "is invalid with an unsupported language" do
    gist = Gist.new(valid_attrs.merge(language: "python"))
    assert_not gist.valid?
    assert_includes gist.errors[:language], "is not included in the list"
  end

  # ── Scopes ────────────────────────────────────────────────

  test "published scope returns only published gists" do
    assert_includes Gist.published, gists(:hello)
    assert_not_includes Gist.published, gists(:fibonacci)
  end

  test "unpublished scope returns only draft gists" do
    assert_includes Gist.unpublished, gists(:fibonacci)
    assert_not_includes Gist.unpublished, gists(:hello)
  end

  test "recent scope orders by created_at descending" do
    result = Gist.recent.to_a
    assert result.first.created_at >= result.last.created_at
  end

  # ── Instance methods ──────────────────────────────────────

  test "published_status returns Published for published gist" do
    assert_equal "Published", gists(:hello).published_status
  end

  test "published_status returns Draft for unpublished gist" do
    assert_equal "Draft", gists(:fibonacci).published_status
  end

  test "ran? returns false when output_at is nil" do
    gist = Gist.new(valid_attrs)
    assert_not gist.ran?
  end

  test "ran? returns true when output_at is set" do
    gist = gists(:hello)
    gist.output_at = Time.current
    assert gist.ran?
  end

  # ── Association ───────────────────────────────────────────

  test "belongs_to article is optional" do
    gist = Gist.new(valid_attrs)
    assert gist.valid?
    assert_nil gist.article
  end
end
