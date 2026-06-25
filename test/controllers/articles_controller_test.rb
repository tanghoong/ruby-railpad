require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new" do
    get new_article_url
    assert_response :success
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: { article: { author: @article.author, content: @article.content, published: @article.published, title: @article.title } }
    end

    assert_redirected_to article_url(Article.last)
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should update article" do
    patch article_url(@article), params: { article: { author: @article.author, content: @article.content, published: @article.published, title: @article.title } }
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end

  test "should filter articles by search term" do
    get articles_url, params: { search: "First" }
    assert_response :success
    assert_select ".article-row", minimum: 1
  end

  test "should filter articles by published status" do
    get articles_url, params: { status: "published" }
    assert_response :success
  end

  test "should filter articles by draft status" do
    get articles_url, params: { status: "draft" }
    assert_response :success
  end

  test "should combine search and status filter" do
    get articles_url, params: { search: "Article", status: "published" }
    assert_response :success
  end

  test "should handle empty search term" do
    get articles_url, params: { search: "" }
    assert_response :success
  end

  test "should handle search with special SQL characters" do
    get articles_url, params: { search: "%_" }
    assert_response :success
  end
end
