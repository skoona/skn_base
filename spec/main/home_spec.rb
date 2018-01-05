
# Ref: http://testing-for-beginners.rubymonstas.org/rack_test/rack.html
# Ref: http://tutorials.jumpstartlab.com/topics/capybara/capybara_with_rack_test.html


describe "#Home pages Respond Correctly. " do
  it "returns http success" do

    # env = { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/" }
    # response = app.call(env)
    #
    # expect(response).to be_success
    # expect(response).to render_template 'homepage'

    get "/"
    expect(last_response.status).to eq 200

    get "/about"
    expect(last_response.status).to eq 200

    get "/contact"
    expect(last_response.status).to eq 200
  end
end
