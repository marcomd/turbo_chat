shared_examples 'a not logged user' do
  it 'redirects to the login page' do
    action.call
    expect(response).to redirect_to(new_user_session_path)
  end
end
