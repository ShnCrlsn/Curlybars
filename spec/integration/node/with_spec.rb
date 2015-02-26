describe "{{#with presenter}}...{{/with}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "works scopes one level" do
    template = Curlybars.compile(<<-HBS)
      {{#with user}}
        {{avatar.url}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      http://example.com/foo.png
    HTML
  end

  it "scopes two levels" do
    template = Curlybars.compile(<<-HBS)
      {{#with user}}
        {{#with avatar}}
          {{url}}
        {{/with}}
      {{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      http://example.com/foo.png
    HTML
  end

  it "allows empty with_template" do

    template = Curlybars.compile(<<-HBS)
      {{#with user}}{{/with}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "raises an exception if the parameter is not a context type object" do
    template = Curlybars.compile(<<-HBS)
      {{#with return_true}}{{/with}}
    HBS

    expect do 
      eval(template)
    end.to raise_error(Curlybars::Error::Render)
  end
end
