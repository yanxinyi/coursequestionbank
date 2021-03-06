# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file was generated by Cucumber-Rails and is only here to get you a head start
# These step definitions are thin wrappers around the Capybara/Webrat API that lets you
# visit pages, interact with widgets and make assertions about page content.
#
# If you use these step definitions as basis for your features you will quickly end up
# with features that are:
#
# * Hard to maintain
# * Verbose to read
#
# A much better approach is to write your own higher level step definitions, following
# the advice in the following blog posts:
#
# * http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html
# * http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/
# * http://elabs.se/blog/15-you-re-cuking-it-wrong
#


require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)


Then /^I should see the image "(.+)"$/ do |image|
    page.should have_xpath("//img[@src=\"#{image}\"]")
end

# Single-line step scoper
When /^(.*) within (.*[^:])$/ do |step, parent|
  with_scope(parent) { When step }
end

# Multi-line step scoper
When /^(.*) within (.*[^:]):$/ do |step, parent, table_or_string|
  with_scope(parent) { When "#{step}:", table_or_string }
end

Given /^the whitelist is (enabled|disabled)$/ do |option|
  Whitelist.is_enabled = option == 'enabled'
end

Then /^(?:|I )should see (.*) '(.*)' in the database$/ do |datatype, name_value|
  data_class = Object.const_get(datatype)
  assert data_class.find_by_name(name_value) #check this exists in database and is not nil
end

When /^(?:|I )update '(.*)' to '(.*)'$/ do |former, new|


  collection = Collection.find_by_name(former)
  collection.access_level = 1
  collection.save

  visit edit_collection_path(:id => collection.id)
  steps %Q{
      And I fill in "name" with "#{new}"
      And I press "Update"
    }


  # visit edit_collection_path(:id => collection_id)
  # if new != ""
  #   collection_id.name = new
  #   collection_id.save
  #
  # #   steps %Q{
  # #   And I fill in "name" with "#{new}"
  # #   And I press "Update"
  # # }
  # else
  #
  #     visit edit_collection_path(:id => collection_id)
  #     steps %Q{
  #     And I fill in "name" with "#{new}"
  #     And I press "Update"
  #   }
  # end
end

Given /^(?:|I )have uploaded '(.*)'$/ do |file|
  steps %Q{
    Given I am on the upload page
    And I attach the file "features/test_files/#{file}" to "file_upload"
    And I press "Upload File"
    Then I should see "Upload successful!"
  }
end

When /^(?:|I )create a new collection '(.*)'(.*)/ do |name, optional|
  steps %Q{
    Given I am on the dashboard
    And I follow "New collection"
    And I fill in "name" with "#{name}"
    And I press "Create"
  }
  # if optional.strip == 'and mark it as current'
  #   visit mark_as_current_path(:id => Collection.find_by_name(name).id)
  # end
end

When /^(?:|I )authorize '(.*)'/ do |user|
  #you thought I would actually use user? nope
  # click_link('authorize')
  visit "admin/authorize/#{Instructor.find_by_name(user).id}"
end

When /^(?:|I )deny '(.*)'/ do |user|
  visit "admin/deny/#{Instructor.find_by_name(user).id}"
end

def problems_with_text(text, collection=nil)
  probs = Problem.all.select{|problem| problem.json and problem.json.include? text}
  probs.select!{|problem| problem.collections.map(&:name).include? collection} if collection
  probs
end

When /^(?:|I )add problem containing '(.*)' to collection '(.*)'/ do |problem_text, collection|
  problem = problems_with_text(problem_text)[0]
  collection = Collection.find_by_name(collection)
  collection.problems << problem if not collection.problems.include? problem
end

When /^(?:|I )remove problem containing '(.*)' to collection '(.*)'/ do |problem_text, collection|
  problem = problems_with_text(problem_text)[0]
  collection = Collection.find_by_name(collection)
  collection.problems.delete(problem)
  collection.save
end

When /^I check problem containing "(.*)"/ do |problem_text|
  problems_with_text(problem_text).each do |problem|
    check("checked_problems_#{problem.id}")
  end
end

Given(/^I have added problem containing "(.*?)" to "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I follow "(.*)" for problem containing "(.*)"/ do |link_id, problem_text|
  problem = problems_with_text(problem_text)[0].id
  click_link("#{link_id}_#{problem}")
end

When /^I press button "(.*)" for problem containing "(.*)"/ do |link_id, problem_text|
  problem = problems_with_text(problem_text)[0].id
  click_on("copy_source_button_#{problem}")
end

When /^I toggle collection "(.*)" for problem containing "(.*)"/ do |collection_name, problem_text|
  problem = problems_with_text(problem_text)[0].id
  collection = Collection.find_by_name(collection_name).id
  click_on("toggle_collection_#{collection}_#{problem}")
end

When /^I choose sort by "(.*)"/ do |option|
  choose("sort_by_#{option}")
end


Then /^(?:|I )should not see '(.*)' in collection '(.*)'/ do |problem_text, collection|
  collection = Collection.find_by_name(collection)
  problem = problems_with_text(problem_text)[0]
  assert !(collection.problems.include? problem)
end

Then /^(?:|I )should see '(.*)' with in the collection '(.*)'/ do |problem_text, collection|
  collection = Collection.find_by_name(collection).id
  visit edit_collection_path(:id => collection)
  steps %Q{
    Then I should see "#{problem_text}"
  }
end

Then /^(?:|I )should not see (.*) '(.*)' in the database$/ do |datatype, name_value|
  data_class = Object.const_get(datatype)
  assert data_class.find_by_name(name_value).nil?
end

Given /^(?:|I )am looking at edit page regarding collection '(.*)'/ do |collection|
  collection = Collection.find_by_name(collection).id
  visit edit_collection_path(:id => collection)
end

When /^I press the trash icon at '(.*)'/ do |collection|
  collection = Collection.find_by_name(collection)
  visit edit_collection_path(:id => collection)
  click_button('Delete Collection')
end

When /^I fill in "(.*)" with text of "(.*)"/ do |field, file|
  fill_in(field, :with => IO.read("features/test_files/" + file))
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  click_button(button)
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
end

When /^(?:|I )fill in "([^"]*)" with "([^"]*)"$/ do |field, value|
  fill_in(field, :with => value)
end

When /^(?:|I )fill in "([^"]*)" for "([^"]*)"$/ do |value, field|
  fill_in(field, :with => value)
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select or option
# based on naming conventions.
#
When /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end
end

When /^(?:|I )select "([^\"]*)" from "([^\"]*)"$/ do |value, field|
  select(value, :from => field)
end

When /^(?:|I )check "([^\"]*)"$/ do |field|
  check(field)
end

When /^(?:|I )uncheck "([^\"]*)"$/ do |field|
  uncheck(field)
end

When /^(?:|I )choose "([^\"]*)"$/ do |field|
  choose(field)
end

When /^(?:|I )attach the file "([^\"]*)" to "([^\"]*)"$/ do |path, field|
  attach_file(field, File.expand_path(path))
end

Then /^(?:|I )should see "([^\"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_xpath('//*', :text => regexp)
  else
    assert page.has_xpath?('//*', :text => regexp)
  end
end

Then /^(?:|I )should not see "([^\"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_no_xpath('//*', :text => regexp)
  else
    assert page.has_no_xpath?('//*', :text => regexp)
  end
end

Then /^the "([^"]*)" field(?: within (.*))? should contain "([^\"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field(?: within (.*))? should not contain "([^\"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field should have the error "([^\"]*)"$/ do |field, error_message|
  element = find_field(field)
  classes = element.find(:xpath, '..')[:class].split(' ')

  form_for_input = element.find(:xpath, 'ancestor::form[1]')
  using_formtastic = form_for_input[:class].include?('formtastic')
  error_class = using_formtastic ? 'error' : 'field_with_errors'

  if classes.respond_to? :should
    classes.should include(error_class)
  else
    assert classes.include?(error_class)
  end

  if page.respond_to?(:should)
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      error_paragraph.should have_content(error_message)
    else
      page.should have_content("#{field.titlecase} #{error_message}")
    end
  else
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      assert error_paragraph.has_content?(error_message)
    else
      assert page.has_content?("#{field.titlecase} #{error_message}")
    end
  end
end

Then /^the "([^\"]*)" field should have no error$/ do |field|
  element = find_field(field)
  classes = element.find(:xpath, '..')[:class].split(' ')
  if classes.respond_to? :should
    classes.should_not include('field_with_errors')
    classes.should_not include('error')
  else
    assert !classes.include?('field_with_errors')
    assert !classes.include?('error')
  end
end

Then /^the "([^\"]*)" checkbox(?: within (.*))? should be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then /^the "([^\"]*)" checkbox(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')}

  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^show me the page$/ do
  save_and_open_page
end

When(/^fill in 'update' with '.*.txt'$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see 'Question has been updated'$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see the text from '.*.txt'$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^(?:|I )should see a button "([^\"]*)"$/ do |text|
  should have_button text
end


Then(/^the problem containing "(.*?)" should have the tag "(.*?)"$/) do |problem_text, tag|
  problem = problems_with_text(problem_text)[0]
  problem.tags[0].name.should =~ /#{tag}/
end

When(/^I mark problem with uid "(.*?)" as obsolete$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the problem containing "(.*?)" should not have the tag "(.*?)"$/) do |problem_text, tag|
  problem = problems_with_text(problem_text)[0] || ""
  problem.tags[0].name.should_not == /#{tag}/
end

Given(/^I have created an empty collection named "(.*?)"$/) do |arg1|
  visit 'collections/new'
  fill_in 'name', :with => arg1
  click_button 'Create'
end

Then(/^when I click "(.*?)" I should see "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see "(.*?)" under "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end


Then(/^I should not see "(.*?)" checkbox$/) do |text|
  checkboxName = find(:css, "#collections_#{collection.id}").should_not be_visible
end

Given(/^there exist a user with username "(.*?)" and uid "(.*?)"$/) do |username, uid|
  Instructor.find_by_username_and_uid(username, uid).should_not be nil
end

Then /^the "([^"*])" checkbox should be checked$/ do |id|
  find("#{id}").should be_checked
end

And(/^I check "([^"]*)" checkbox$/) do |id|
  check(id)
end

Then(/^the plain text "([^"]*)" is hidden$/) do |id|
  find_field(id).should_not be_visible
end

And(/^the plain text "([^"]*)" is shown$/) do |id|
  find_field([".fillin-correct"], {:name => id}).should be_visible
end


Then(/^I should see soltuion "([^"]*)" highlighted$/) do |arg|
  page.should have_css("div.entrybox")
end

Then(/^I should see "([^"]*)" notice$/) do |arg|
  if Collection.find_by_name(arg) ==nil and Collection.find_by_description(arg) ==nil
      "No collection matches"
  end
end


And(/^I should see "([^"]*)" is checked in "([^"]*)"$/) do |str, element|
  expect(page).to have_select(element, selected: str)
end

Then(/^I select "([^"]*)" in "([^"]*)"$/) do |str, element|
  select str, from: element
end

And (/^I should see a correct message$/) do
  page.should have_css('.fillin-correct', :visible => true)
end


When(/^I checked "([^"]*)"$/) do |arg|
  page.check(arg)
end

When(/^I unchecked "([^"]*)"$/) do |arg|
  page.uncheck(arg)
end
