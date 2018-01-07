feature "Authentication process for all users." do

  context "Public Pages can be accessed. " do

    scenario "#/ not required to sign in when page is unsecured." do
      visit '/'
      expect(current_path).to eq '/'
      expect(page).to have_title("Home")
    end

    scenario "#/about not required to sign in when page is unsecured." do
      visit '/about'
      expect(current_path).to eq '/about'
      expect(page).to have_title("About")
    end

    scenario "#/contact not required to sign in when page is unsecured." do
      visit '/contact'
      expect(current_path).to eq '/contact'
      expect(page).to have_title("Contact")
    end
  end

  context "Secured Pages cannot be accessed. " do

    scenario "#/profiles/resources Required to sign in when page is secured." do
      visit '/profiles/resources'
      expect(current_path).to eq '/sessions/unauthenticated'
      expect(page).to have_title("Not Authenticated")
      expect(page).to have_content('You must be signed In to view resources!')
    end

    scenario "#/profiles/users Required to sign in when page is secured." do
      visit '/profiles/users'
      expect(current_path).to eq '/sessions/unauthenticated'
      expect(page).to have_title("Not Authenticated")
      expect(page).to have_content('You must be signed In to view users!')
    end
  end

  context "Using good credentials. " do
    given(:user) { user_estester }

    scenario "Sign in with username and password credentials." do
      visit '/sessions/signin'
      fill_in 'Username', :with =>  user.username
      fill_in 'Password', :with =>  "demos"
      click_button 'Sign in'
      expect(current_path).to eq '/profiles/resources'
      expect(page).to have_title("Secured Resources")
    end

    scenario "Returned to originally requested page after signing in." do
      user = page_user_eptester
      visit '/profiles/users'
      expect(current_path).to eq '/sessions/unauthenticated'
      expect(page).to have_content('You must be signed In to view users!')
      visit '/sessions/signin'
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => "demos"
      click_button 'Sign in'

      expect(current_path).to eq '/profiles/users'
      click_link 'Sign out'
    end

    scenario "Returned to Home page after sign out." do 
      user = page_user_eptester
      visit '/profiles/users'
      expect(current_path).to eq '/sessions/unauthenticated'
      expect(page).to have_content('You must be signed In to view users!')
      visit '/sessions/signin'
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => "demos"
      click_button 'Sign in'

      expect(current_path).to eq '/profiles/users'
      click_link 'Sign out'
      expect(current_path).to eq '/'
      expect(page).to have_content("You have been signed out")
    end
  end


  context "Using bad credentials. " do
    let(:user) { page_user_estester }

    scenario "Cannot sign in with incorrect username." do
      visit '/sessions/signin'
      fill_in 'Username', :with => "LastNameInitial"
      fill_in 'Password', :with => "demos"
      click_button 'Sign in'
      expect(current_path).to eq '/sessions/signin'
      expect(page).to have_alert_message("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
    end

    scenario "Cannot sign in with incorrect password." do
      visit '/sessions/signin'
      fill_in 'Username', :with => user.username
      fill_in 'Password', :with => "somebody"
      click_button 'Sign in'
      expect(current_path).to eq '/sessions/unauthenticated'
      expect(page).to have_alert_message("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
    end

    scenario "Cannot sign in when no credentials are offered." do
      visit '/sessions/signin'
      click_button 'Sign in'
      expect(current_path).to eq '/sessions/signin'
      expect(page).to have_content('InvalidCsrfToken')
      # expect(page).to have_content("Fill out this field")
    end

  end

end