RBENV_RUBY_VERSION=${1:-"ruby-2.0.0"}
GEMS_VERSION=${2:-"2.0.0"}
GHERKIN_VERSION=${3:-"2.12.0"}
SDIR=$(pwd)
echo Setting up ragle for $RBENV_RUBY_VERSION $GEMS_VERSION $GHERKIN_VERSION
load_rbenv \
&& rbenv shell $RBENV_RUBY_VERSION \
&& gem install gherkin -v ${GHERKIN_VERSION} \
&& cd ~/.rbenv/versions/$RBENV_RUBY_VERSION/lib/ruby/gems/${GEMS_VERSION}/gems/gherkin-${GHERKIN_VERSION}/  \
&& bundle install \
&& rbenv rehash \
&& bundle exec rake compile:gherkin_lexer_en \
&& cd "${SDIR}"
