require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  should have_many :items
  should belong_to(:originator).class_name('User')

  should validate_presence_of :url
  should validate_uniqueness_of :url
  should validate_presence_of :originator_id

  
  # -------------------------------------------------------------------------------------------
  # first_or_initialize_with_url_title_and_originator ---------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should create a new record" do
    doc_count = Document.count

    doc = Document.first_or_initialize_with_url_title_and_originator "http://something.ca", "Some Title", users(:matt)

    assert_equal doc_count+1, Document.count
    assert_equal ["http://something.ca", "Some Title", users(:matt)], [doc.url, doc.title, doc.originator]
    refute doc.new_record?, "should have saved the document"
  end

  test "should update an existing record with a new title if the title was blank" do
    Document.create! url:"http://something.ca", title:"", originator:users(:matt)

    doc_count = Document.count

    doc = Document.first_or_initialize_with_url_title_and_originator "http://something.ca", "Some Title", users(:matt)

    assert_equal doc_count, Document.count
    assert_equal "Some Title", Document.last.title
  end

  test "should update an existing record with a new title if the title was nil" do
    Document.create! url:"http://something.ca", title:nil, originator:users(:matt)

    doc_count = Document.count

    doc = Document.first_or_initialize_with_url_title_and_originator "http://something.ca", "Some Title", users(:matt)

    assert_equal doc_count, Document.count
    assert_equal "Some Title", Document.last.title
  end

  test "should not update an existing record with a new title if the title exists" do
    Document.create! url:"http://something.ca", title:"Some Title", originator:users(:matt)

    doc_count = Document.count

    doc = Document.first_or_initialize_with_url_title_and_originator "http://something.ca", "Some New Title", users(:matt)

    assert_equal doc_count, Document.count
    assert_equal "Some Title", Document.last.title
  end

  test "should not change the originator of an existing document" do
    doc_count = Document.count
    # assert_equal documents(:some_video).originator, "matt"
    doc = Document.first_or_initialize_with_url_title_and_originator documents(:some_video).url, "Some New Title", users(:pam)

    assert_equal doc_count, Document.count
    assert_equal users(:matt), doc.originator
  end

  test "should return a Document object when creating" do
    doc_count = Document.count
    doc = Document.first_or_initialize_with_url_title_and_originator "http://someurl.com", "Some New Title", users(:pam)

    assert_equal doc_count+1, Document.count
    assert_equal Document, doc.class
    assert_equal users(:pam), doc.originator
  end

  test "should return a Document object when updating" do
    doc = Document.first_or_initialize_with_url_title_and_originator documents(:some_video).url, "Some New Title", users(:pam)

    assert_equal Document, doc.class
    assert_equal users(:matt), doc.originator
  end
end
