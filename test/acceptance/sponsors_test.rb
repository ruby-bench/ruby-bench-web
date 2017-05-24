require 'acceptance/test_helper'

class SponsorsTest < AcceptanceTest
  test "should display same number of sponsors" do
    visit root_path
    click_link "Sponsors", match: :first

    assert page.has_content?(I18n.t("static_pages.sponsors.title"))
    assert page.has_css?(".row .sponsor-row", count: SponsorsData.count)
  end

  test "should have all sponsor names" do
    if SponsorsData.count > 0
      visit root_path
      click_link "Sponsors", match: :first
      SponsorsData.values.each do |sponsor|
        assert page.has_content?(sponsor[:name])
      end
    end
  end
end
