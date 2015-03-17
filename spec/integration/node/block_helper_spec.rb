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

  it "renders a block helper with a different context, chosen by the block_helper implementation" do
    template = Curlybars.compile(<<-HBS)
      {{!--
        `this` is referring to a context
        that will yield the block using
        another context.
      --}}

      {{#print_user_name this}}
        {{first_name}}
      {{/print_user_name}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      Libo
    HTML
  end

  it "renders a block helper with custom variables" do
    template = Curlybars.compile(<<-HBS)
      {{#yield_custom_variable this}}
        {{!--
          `@custom1` and `@custom2` are variables yielded
          by the block helper implementation.
        --}}

        {{@custom1}} {{@custom2}}
      {{/yield_custom_variable}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      custom variable1
      custom variable2
    HTML
  end

  it "renders a block helper with custom variables that can be used in conditionals" do
    template = Curlybars.compile(<<-HBS)
      {{#yield_custom_variable this}}
        {{!--
          `@cond` is a boolean variable yielded
          by the block helper implementation.
        --}}

        {{#if @cond}}
          Cond is true
        {{/if}}
      {{/yield_custom_variable}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      Cond is true
    HTML
  end

  it "renders a block helper with custom variables that can be seen by nested contexts" do
    template = Curlybars.compile(<<-HBS)
      {{#yield_custom_variable this}}
        {{!--
          `@custom1` and `@custom2` are variables yielded
          by the block helper implementation.
        --}}
        {{#with this}}
          {{@custom1}} {{@custom2}}
        {{/with}}
      {{/yield_custom_variable}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      custom variable1
      custom variable2
    HTML
  end

  it "renders a block helper with a different context and a custom variable" do
    template = Curlybars.compile(<<-HBS)
      {{!--
        `this` is referring to a context
        that will yield the block using
        another context.
      --}}

      {{#yield_custom_variable_and_custom_presenter this}}
        {{first_name}}

        {{!--
          `@custom` is a variable yielded
          by the block helper implementation.
        --}}
        {{@custom}}
      {{/yield_custom_variable_and_custom_presenter}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      Libo
      custom variable
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

  it "accepts a nil context" do
    template = Curlybars.compile(<<-HBS)
      {{#this_method_yields return_nil}}
      {{/this_method_yields}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "yield produces an empty string in case the context is nil" do
    template = Curlybars.compile(<<-HBS)
      {{#this_method_yields return_nil}}
        text
      {{/this_method_yields}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
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
