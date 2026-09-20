# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Language server for VS Code. Keeping it in the bundle means the Ruby LSP
# extension uses this Gemfile directly instead of generating .ruby-lsp/Gemfile.
gem "ruby-lsp", require: false

# Step debugger behind the "ruby_lsp" launch configs (F5 in VS Code).
gem "debug", require: false

# Linting.
gem "rubocop", require: false

# For writing real test files alongside the inline test harnesses.
gem "minitest", require: false
