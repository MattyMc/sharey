require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :document
  should belong_to :category
  should have_one :usage_datum
  should belong_to(:from_user).class_name('User').with_foreign_key('from_user_id')
  
  should validate_presence_of :document_id
  should validate_presence_of :user_id
  should validate_presence_of :description
  should validate_presence_of :original_request

  # -------------------------------------------------------------------------------------------
  # Attributes --------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should have attribute notes" do
    item = Item.new
    assert_equal Hash, item.notes.class
  end  
  
  test "should raise an exception if user_id and document_id are not unique" do
    Item.create!(
      document_id:documents(:some_video).id, 
      user_id:users(:pam).id, 
      description:"y", 
      original_request:"y")

    assert_raises(ActiveRecord::RecordInvalid) {
      Item.create!(
        document_id:documents(:some_video).id, 
        user_id:users(:pam).id, 
        description:"y", 
        original_request:"y")
    }
  end


  # -------------------------------------------------------------------------------------------
  # modal  ------------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should return a properly formatted object" do
    item = Item.first
    item.notes = {
      "tagged_users" => ["@one", "@two"], 
      "missing_tags" => ["@three", "@four"], 
      "already_saved" => ["@five"],
      "already_shared_with" => ["@six", "@seven", "@eight"], 
      "new_item" => false}

    modal = item.modal_response

    refute modal["modal"].blank?
    refute modal["modal"]["headline"].blank?
    refute modal["modal"]["messages"].empty?
    
    assert_equal String, modal["modal"]["headline"].class
    assert_equal Array, modal["modal"]["messages"].class
    assert_equal String, modal["modal"]["messages"][0].class
  end  

  # -------------------------------------------------------------------------------------------
  # validate_item_params ----------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should return an array of elements" do
    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    assert_equal([
      "http://www.somethingspecial.com/hamburger",
      "Hamburgers!",
      "Delicious treats!",
      "Food"], 
      Item.send(:validate_item_params, item_params))
  end

  test "should trim white space from all elements" do
    item_params = {
      "url" => "  http://www.somethingspecial.com/hamburger ",
      "title" => " Hamburgers!   ", 
      "description" => "    Delicious treats! ",
      "category" => " Food    "
    }
    
    assert_equal([
      "http://www.somethingspecial.com/hamburger",
      "Hamburgers!",
      "Delicious treats!",
      "Food"], 
      Item.send(:validate_item_params, item_params))
  end

  test "should raise an exception if url or description is an empty string" do
    item_params = {
      "url" => "  http://www.somethingspecial.com/hamburger ",
      "title" => " Hamburgers!   ", 
      "description" => "",
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}

    item_params = {
      "url" => "   ",
      "title" => " Hamburgers!   ", 
      "description" => "something",
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}
  end

  test "should raise an exception if url or description is nil" do
    item_params = {
      "url" => "  http://www.somethingspecial.com/hamburger ",
      "title" => " Hamburgers!   ", 
      "description" => nil,
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}

    item_params = {
      "url" => nil,
      "title" => " Hamburgers!   ", 
      "description" => "something",
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}
  end

  # -------------------------------------------------------------------------------------------
  # create_or_update_from_item_params_and_user ------------------------------------------------
  # -------------------------------------------------------------------------------------------

  test "should create a new item for an existing Document with a new User" do
    doc_count = Document.count
    item_count = Item.count

    item_params = {
      "url" => documents(:some_video).url, # belongs to :matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:pam)
    item = Item.create_or_update_from_item_params_and_user item_params, user
    category = Category.find_by(downcase_name: "food")

    assert category, "category should exist"
    assert_equal item_count+1, Item.count
    assert_equal doc_count, Document.count, "should not create a new document"
    assert_equal(
      [users(:pam), "Delicious treats!", documents(:some_video), "Delicious treats!"],
      [item.user, item.description, item.document, item.original_request])
    assert_equal category, item.category, "item should have category"
  end

  test "should not create a UsageDatum object with an existing item" do
    item_count = Item.count
    usage_datum_count = UsageDatum.count

    item_params = {
      "url" => documents(:some_video).url, # belongs to :matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal item_count, Item.count
    assert_equal usage_datum_count, UsageDatum.count
  end

  test "should create a UsageDatum object with a new item" do
    item_count = Item.count
    usage_datum_count = UsageDatum.count

    item_params = {
      "url" => "http://somethinghere.ca", # belongs to :matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal item_count+1, Item.count
    assert_equal usage_datum_count+1, UsageDatum.count
  end

  test "should create a new item and a new document" do
    doc_count = Document.count
    item_count = Item.count

    item_params = {
      "url" => "http://www.aintneverseenthisurl.com/", 
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user
    last_doc = Document.last

    assert Category.find_by(downcase_name: "food"), "category should exist"    
    assert_equal item_count+1, Item.count
    assert_equal doc_count+1, Document.count
    assert_equal(
      [users(:matt), "Delicious treats!", last_doc, "Delicious treats!"],
      [item.user, item.description, item.document, item.original_request])
    
    assert_equal(
      ["http://www.aintneverseenthisurl.com/", users(:matt), "Hamburgers!"],
      [last_doc.url, last_doc.originator, last_doc.title])
  end

  test "should create a new category, item and document" do
    doc_count = Document.count
    item_count = Item.count
    cat_count = Category.count

    item_params = {
      "url" => "http://www.aintneverseenthisurl.com/", 
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user
    last_doc = Document.last
    category = Category.find_by(downcase_name: "food")

    assert category, "category should exist"
    assert_equal item_count+1, Item.count
    assert_equal doc_count+1, Document.count
    assert_equal cat_count+1, Category.count
    assert_equal(
      ["Food", "food", users(:matt)],
      [category.name, category.downcase_name, category.user])
    assert_equal category, item.category
  end


  test "should update the description and category of an item if it exists" do
    doc_count = Document.count
    item_count = Item.count
    cat_count = Category.count

    item_params = {
      "url" => documents(:some_video).url, # belogs to matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal item_count, Item.count, "should not be creating a new item"
    assert_equal doc_count, Document.count
    assert_equal cat_count+1, Category.count
    assert_equal(
      [users(:matt).id, "Delicious treats!", documents(:some_video)],
      [item.user.id, item.description, item.document])
    
    assert_equal Category.find_by(downcase_name: "food"), item.category
  end

  test "should not update from_user of an item if it exists" do
    item_params = {
      "url" => documents(:insightful_story).url, # belogs to matt, from Pam
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal users(:pam), item.from_user
  end
    
  test "should update original_request, description and category of an item if it exists" do
    item_params = {
      "url" => documents(:insightful_story).url, # belogs to matt, from Pam
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal "Delicious treats!", item.original_request
    assert_equal "Delicious treats!", item.description
    assert_equal users(:pam), item.from_user
    assert_equal Category.find_by(name: "Food"), item.category
  end

  test "should raise an exception if no user is defined" do
    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = User.find_by sharey_session_cookie:"fakecookie"
    assert_raises(Item::UserNotFound) {Item.create_or_update_from_item_params_and_user item_params, user}
  end

  test "should create a document for a new url" do
    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:pam)
    document = Document.find_by url:"http://www.somethingspecial.com/hamburger"

    assert document, "should find the new document"
    assert_equal(
      ["http://www.somethingspecial.com/hamburger","Hamburgers!",users(:pam)],
      [document.url, document.title, document.originator])
  end

  test "should create and share a new item with one user" do
    item_count = Item.count
    pams_items = users(:pam).items.count
    matts_items = users(:matt).items.count
    doc_count = Document.count
    data_usage_count = UsageDatum.count

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam",
      "category" => "Food"
    }

    Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal item_count+2, Item.count
    assert_equal pams_items+1, users(:pam).items.count
    assert_equal matts_items+1, users(:matt).items.count
    assert_equal doc_count+1, Document.count
    assert_equal data_usage_count+2, UsageDatum.count
  end

  test "should create and share a new item with one user with proper attributes" do
    pam = users(:pam)
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam",
      "category" => "Food"
    }

    Item.create_or_update_from_item_params_and_user item_params, matt

    doc = Document.find_by url:"http://www.somethingspecial.com/hamburger"
    m_i = Item.find_by document:doc, user:matt
    p_i = Item.find_by document:doc, user:pam

    assert_equal(
      [doc.id, matt.id, nil, "Food", "Delicious treats!", "Delicious treats! @pam"],
      [m_i.document_id, m_i.user_id, m_i.from_user_id, m_i.category.name, m_i.description, m_i.original_request])
    
    assert_equal(
      [doc.id, pam.id, matt.id, nil, "Delicious treats!", "Delicious treats! @pam"],
      [p_i.document_id, p_i.user_id, p_i.from_user_id, p_i.category_id, p_i.description, p_i.original_request])
  end

  test "should create and share a new item with two users with proper attributes" do
    jay = users(:jay)
    mau = users(:mau)
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @mau @Jay",
      "category" => "Food"
    }

    Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    doc = Document.find_by url:"http://www.somethingspecial.com/hamburger"
    m_i = Item.find_by document:doc, user:matt
    ma_i = Item.find_by document:doc, user:mau
    ja_i = Item.find_by document:doc, user:jay

    assert_equal(
      [doc.id, matt.id, nil, "Food", "Delicious treats!", "Delicious treats! @mau @Jay"],
      [m_i.document_id, m_i.user_id, m_i.from_user_id, m_i.category.name, m_i.description, m_i.original_request])
    
    assert_equal(
      [doc.id, jay.id, matt.id, nil, "Delicious treats!", "Delicious treats! @mau @Jay"],
      [ja_i.document_id, ja_i.user_id, ja_i.from_user_id, ja_i.category_id, ja_i.description, ja_i.original_request])
    
    assert_equal(
      [doc.id, mau.id, matt.id, nil, "Delicious treats!", "Delicious treats! @mau @Jay"],
      [ma_i.document_id, ma_i.user_id, ma_i.from_user_id, ma_i.category_id, ma_i.description, ma_i.original_request])
  end

  test "should not create item for a user that already has that item" do
    item_count = Item.count
    pams_items = users(:pam).items.count
    matts_items = users(:matt).items.count
    doc_count = Document.count
    data_usage_count = UsageDatum.count

    item_params = {
      "url" => documents(:insightful_story).url, # pam and matt already have this item
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam",
      "category" => "Food"
    }

    Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal item_count, Item.count
    assert_equal pams_items, users(:pam).items.count
    assert_equal matts_items, users(:matt).items.count
    assert_equal doc_count, Document.count
    assert_equal data_usage_count, UsageDatum.count
  end

  test "should not create item for multiple users that already have that item" do
    item_params = {
      "url" => documents(:insightful_story).url, # pam already has this item
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }    

    Item.create_or_update_from_item_params_and_user item_params, users(:mau)

    item_count = Item.count
    pams_items = users(:pam).items.count
    maus_items = users(:mau).items.count
    doc_count = Document.count
    data_usage_count = UsageDatum.count

    item_params = {
      "url" => documents(:insightful_story).url, # pam and matt already has this item
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @mau",
      "category" => "Food"
    }

    Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal item_count, Item.count
    assert_equal pams_items, users(:pam).items.count
    assert_equal maus_items, users(:mau).items.count
    assert_equal doc_count, Document.count
    assert_equal data_usage_count, UsageDatum.count
  end

  test "should not create any items if all users already have that item" do
    item_params = {
      "url" => documents(:insightful_story).url, # pam already has this item
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }    

    doc_count = Document.count

    Item.create_or_update_from_item_params_and_user item_params, users(:mau)
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    item_count = Item.count
    pams_items = users(:pam).items.count
    maus_items = users(:mau).items.count
    data_usage_count = UsageDatum.count

    item_params = {
      "url" => documents(:insightful_story).url, # pam already has this item
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @mau",
      "category" => "Food"
    }

    Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal item_count, Item.count
    assert_equal pams_items, users(:pam).items.count
    assert_equal maus_items, users(:mau).items.count
    assert_equal doc_count, Document.count
    assert_equal data_usage_count, UsageDatum.count
  end

  # Testing item.notes[] ----------------------------------------------------------------

  test "should create and share a new item with two users and add two users to notes['tagged_users']" do
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @mau @jay",
      "category" => "Food"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    # assert_equal "Saved and Shared!", item.headline
    assert_equal ["@Mau", "@Jay"].sort, item.notes["tagged_users"].sort, "should add user(s) to notes['tagged_users']"
    assert_equal true, item.notes["new_item"]
    # assert("Sharey'd this with @Mau and @Jay!".in? item.messages)
  end

  test "should create a new item and add one user to notes['missing_tags'], one to notes['tagged_users']" do
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @Jay @john",
      "category" => "Food"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    # assert_equal "Saved and Shared!", item.headline
    assert_equal ["@Jay"], item.notes["tagged_users"], "should add user(s) to notes['tagged_users']"
    # assert("Sharey'd this with @Jay!".in? item.messages)
    assert_equal ["@john"], item.notes["missing_tags"], "should add user(s) to notes['missing_tags']"
    # assert("WARNING: Sharey couldn't find any tags named @john!".in? item.messages)
    assert_equal true, item.notes["new_item"]
  end

  test "should create a new item and add one user to notes['tagged_users'], two users to notes['missing_tags']" do
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @Jay @john @peter",
      "category" => "Food"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    # assert_equal "Saved and Shared!", item.headline
    assert_equal ["@Jay"], item.notes["tagged_users"], "should add user(s) to notes['tagged_users']"
    assert_equal ["@john", "@peter"].sort, item.notes["missing_tags"].sort, "should add user(s) to notes['missing_tags']"
    assert_equal true, item.notes["new_item"]
  end

  test "should create a new item and three users to notes['missing_tags']" do
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @sam @Jay @john @peter",
      "category" => "Food"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    # assert_equal "Saved and Shared!", item.headline
    assert_equal ["@Jay"], item.notes["tagged_users"], "should add user(s) to notes['tagged_users']"
    assert_equal ["@sam", "@john", "@peter"].sort, item.notes["missing_tags"].sort, "should add user(s) to notes['missing_tags']"
    assert_equal true, item.notes["new_item"]
  end

  test "should create a new item and five users to notes['missing_tags']" do
    matt = users(:matt)

    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @sam @Jay @john @peter @rob @carl",
      "category" => "Food"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@Jay"], item.notes["tagged_users"], "should add user(s) to notes['tagged_users']"
    assert_equal ["@sam", "@john", "@peter", "@rob", "@carl"].sort, item.notes["missing_tags"].sort, "should add user(s) to notes['missing_tags']"
    assert_equal true, item.notes["new_item"]
  end

  test "should create a new item and add one user to notes['already_saved']" do
    item_params = {
      "url" => documents(:some_video).url,  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @sam @matt",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:jay)

    assert_equal ["@Matt"], item.notes["already_saved"], "should add user(s) to items['already_saved']"
    assert_equal true, item.notes["new_item"]
  end

  test "should update an item and add two users to notes['already_saved']" do
    Item.create! user:users(:pam), document:documents(:some_video), from_user:nil, category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:jay), document:documents(:some_video), from_user:nil, category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => documents(:some_video).url,  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam", "@Jay"].sort, item.notes["already_saved"].sort, "should add user(s) to items['already_saved']"
    assert_equal false, item.notes["new_item"]
  end

  test "should update an item and add three users to notes['already_saved']" do
    Item.create! user:users(:pam), document:documents(:some_video), from_user:nil, category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:jay), document:documents(:some_video), from_user:nil, category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:mau), document:documents(:some_video), from_user:nil, category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => documents(:some_video).url,  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam", "@Jay", "@Mau"].sort, item.notes["already_saved"].sort, "should add user(s) to items['already_saved']"
    assert_equal false, item.notes["new_item"]
  end

  test "should add users to notes['missing_tags', 'tagged_users' and 'already_saved']" do
    Item.create! user:users(:pam), document:documents(:some_video), from_user:nil, category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => documents(:some_video).url,  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @rob @peter @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam"], item.notes["already_saved"], "should add user(s) to items['already_saved']"
    assert_equal ["@Jay", "@Mau"].sort, item.notes["tagged_users"].sort, "should add user(s) to notes['tagged_users']"
    assert_equal ["@rob", "@peter"].sort, item.notes["missing_tags"].sort
    assert_equal false, item.notes["new_item"]
  end

  test "should add one user to notes['already_shared_with'] when updating a new item" do
    Item.create! user:users(:pam), document:documents(:some_video), from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => documents(:some_video).url,  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @rob @peter @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam"], item.notes["already_shared_with"], "should add user(s) to items['already_shared_with']"
    assert_equal ["@Jay", "@Mau"].sort, item.notes["tagged_users"].sort, "should add user(s) to notes['tagged_users']"
    assert_equal ["@rob", "@peter"].sort, item.notes["missing_tags"].sort
    assert_equal false, item.notes["new_item"]
  end

  test "should add multiple users to notes['already_shared_with'] when updating a new item" do
    Item.create! user:users(:pam), document:documents(:some_video), from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:jay), document:documents(:some_video), from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:mau), document:documents(:some_video), from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => documents(:some_video).url,  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @rob @peter @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam","@Jay", "@Mau"].sort, item.notes["already_shared_with"].sort, "should add user(s) to items['already_shared_with']"
    assert_equal [], item.notes["tagged_users"], "should add user(s) to notes['tagged_users']"
    assert_equal ["@rob", "@peter"].sort, item.notes["missing_tags"].sort
    assert_equal false, item.notes["new_item"]
  end

  test "should add one user to notes['already_shared_with'] when creating a new item" do
    doc = Document.create! url:"http://www.pizzadelivery.com", originator:users(:matt)

    Item.create! user:users(:pam), document:doc, from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => "http://www.pizzadelivery.com",  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @rob @peter @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam"], item.notes["already_shared_with"], "should add user(s) to items['already_shared_with']"
    assert_equal ["@Jay", "@Mau"].sort, item.notes["tagged_users"].sort, "should add user(s) to notes['tagged_users']"
    assert_equal ["@rob", "@peter"].sort, item.notes["missing_tags"].sort
    assert_equal true, item.notes["new_item"]
  end

  test "should add multiple users to notes['already_shared_with'] when creating a new item" do
    doc = Document.create! url:"http://www.pizzadelivery.com", originator:users(:matt)
    
    Item.create! user:users(:pam), document:doc, from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:jay), document:doc, from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"
    Item.create! user:users(:mau), document:doc, from_user:users(:matt), category:nil, description:"what evs", original_request:"what evs"

    item_params = {
      "url" => "http://www.pizzadelivery.com",  # Note: Matt already has this url saved
      "title" => "Hamburgers!", 
      "description" => "Delicious treats! @pam @Jay @rob @peter @Mau",
      "category" => "Videos"
    }

    item = Item.create_or_update_from_item_params_and_user item_params, users(:matt)

    assert_equal ["@pam","@Jay", "@Mau"].sort, item.notes["already_shared_with"].sort, "should add user(s) to items['already_shared_with']"
    assert_equal [], item.notes["tagged_users"], "should add user(s) to notes['tagged_users']"
    assert_equal ["@rob", "@peter"].sort, item.notes["missing_tags"].sort
    assert_equal true, item.notes["new_item"]
  end

  # -------------------------------------------------------------------------------------------
  # create_usage_datum ------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should create a UsageDatum model along with an item" do
    usage_datum_count = UsageDatum.count

    item = Item.new(document:documents(:some_video), 
      user:users(:pam), 
      from_user_id: nil,
      description: "Some description",
      category: nil,
      original_request: "Some description")

    assert item.save!, "should save item"
    assert_equal usage_datum_count+1, UsageDatum.count

    assert_equal false, item.usage_datum.shared?
    assert_equal true, item.usage_datum.viewed?
  end

  test "should set correctly set UsageDatum attributes if creating an item to be shared" do
    usage_datum_count = UsageDatum.count

    # This item is from Matt to Pam
    item = Item.new(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some description",
      category: nil,
      original_request: "Some description")

    assert item.save!, "should save item"
    assert_equal usage_datum_count+1, UsageDatum.count

    assert_equal true, item.usage_datum.shared?
    assert_equal false, item.usage_datum.viewed?
  end

  test "should not create a new UsageDatum if item already exists" do
    # This item is from Matt to Pam
    item = Item.create!(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some description",
      category: nil,
      original_request: "Some description")

    usage_datum_count = UsageDatum.count
    item_count = Item.count

    # This item is from Matt to Pam
    item = Item.new(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some new description",
      category: nil,
      original_request: "Some new description")

    assert_equal item_count, Item.count
    assert_equal usage_datum_count, UsageDatum.count
  end

  test "should not create a new UsageDatum if updating record" do
    # This item is from Matt to Pam
    item = Item.create!(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some description",
      category: nil,
      original_request: "Some description")

    usage_datum_count = UsageDatum.count

    item.update_attributes! description:"Some new description..."

    assert_equal "Some new description...", item.description
    assert_equal usage_datum_count, UsageDatum.count
  end
end
