feature "Authentication process for all users.", js: true do

  context "Users " do

    scenario "Required to sign in when page is secured." do
      visit '/profiles/resources'
      expect(current_path).to eq '/sessions/unauthenticated'
      # expect(page).to have_alert_message("You must sign in before accessing")
    end

    scenario "Not required to sign in when page is unsecured." do
      visit '/about'
      expect(current_path).to eq '/about'
      expect(page).to have_title("About")
    end
  end

end