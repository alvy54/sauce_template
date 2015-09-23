feature 'Sign In', :sauce => ENV['RUN_ON_SAUCE'] do
  scenario 'valid credentials' do
    current_window.resize_to(1280, 1024)
    visit 'http://test.product.com'
    fill_in "username", with: 'user@user.com'
    fill_in "password", with: 'Password'
    click_on 'Sign In'
    expect(page).to have_content 'WELCOME'
  end
end
