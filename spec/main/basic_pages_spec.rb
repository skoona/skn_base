
# Ref: http://testing-for-beginners.rubymonstas.org/rack_test/rack.html
# Ref: http://tutorials.jumpstartlab.com/topics/capybara/capybara_with_rack_test.html


describe "Application pages Respond Correctly. " do

  it "returns http success" do
    get "/"
    expect(last_response.status).to eq 200

    get "/about"
    expect(last_response.status).to eq 200

    get "/contact"
    expect(last_response.status).to eq 200

    get "/sessions/signin"
    expect(last_response.status).to eq 200
  end

  it "returns http Unauthorized" do
    get "/profiles/users"
    expect(last_response.status).to eq 401

    get "/profiles/resources"
    expect(last_response.status).to eq 401
  end
end
