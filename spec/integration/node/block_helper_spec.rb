describe "{{#helper context key=value}}...{{/helper}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "renders a block helper without options" do
    template = Curlybars.compile(<<-HBS)
      {{#beautify new_comment_form}}
        template
      {{/beautify}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      bold template italic
    HTML
  end

  it "renders a block helper with options and presenter" do
    template = Curlybars.compile(<<-HBS)
      {{#form new_comment_form class="red" foo="bar"}}
        {{button_label}}
      {{/form}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      beauty class:red foo:bar submit
    HTML
  end

  it "allow empty template" do
    template = Curlybars.compile(<<-HBS)
      {{#form new_comment_form class="red" foo="bar"}}{{/form}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      beauty class:red foo:bar
    HTML
  end

  it "renders correctly a return type of integer" do
    template = Curlybars.compile(<<-HBS)
      {{#integer new_comment_form}} text {{/integer}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      0
    HTML
  end

  it "renders correctly a return type of boolean" do
    template = Curlybars.compile(<<-HBS)
      {{#boolean new_comment_form}} text {{/boolean}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      true
    HTML
  end

  it "raises an exception if the context is not a presenter-like object" do
    template = Curlybars.compile(<<-HBS)
      {{#boolean post}} text {{/boolean}}
    HBS

    expect do
      eval(template)
    end.to raise_error(Curlybars::Error::Render)
  end
end
