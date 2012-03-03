require_relative "test_helper"

class ActsAsArchivalTest < ActiveSupport::TestCase
  test "archive archives 'has_' associated archival objects that are dependent destroy" do
    archival = Archival.create!
    child = archival.kids.create!
    archival.archive

    assert archival.reload.archived?
    assert child.reload.archived?
  end

  test "archive does not archive 'has_' associated archival objects that are not dependent destroy" do
    archival = Archival.create!
    non_dependent_child = archival.independent_kids.create!
    archival.archive

    assert archival.reload.archived?
    assert_not non_dependent_child.reload.archived?
  end

  test "archive doesn't do anything to associated dependent destroy models that are non-archival" do
    archival = Archival.create!
    plain = archival.plains.create!
    archival.archive

    assert archival.archived?
    assert plain.reload
  end

  test "archive_number for associations uses the head object" do
    archival = Archival.create!
    child = archival.kids.create!
    archival.archive

    expected_digest = Digest::MD5.hexdigest("Archival#{archival.id}")
    assert_equal expected_digest, archival.archive_number
    # TODO apparently it doesn't archive properly if records exist
    assert_equal archival.archive_number, child.reload.archive_number
  end
end