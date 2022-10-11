# frozen_string_literal: true

# --------------------------------------------------------------------------------------------------------------------
# Has any changes happened inside the actual library code?
# --------------------------------------------------------------------------------------------------------------------
has_app_changes = !git.modified_files.grep(/lib/).empty?
has_spec_changes = !git.modified_files.grep(/spec/).empty?

# --------------------------------------------------------------------------------------------------------------------
# You've made changes to lib, but didn't write any tests?
# --------------------------------------------------------------------------------------------------------------------
warn("There're library changes, but not tests. That's OK as long as you're refactoring existing code.", sticky: false) if has_app_changes && !has_spec_changes

# --------------------------------------------------------------------------------------------------------------------
# You've made changes to specs, but no library code has changed?
# --------------------------------------------------------------------------------------------------------------------
if !has_app_changes && has_spec_changes
  message('We really appreciate pull requests that demonstrate issues, even without a fix. That said, the next step is to try and fix the failing tests!', sticky: false)
end

# --------------------------------------------------------------------------------------------------------------------
# Have you updated CHANGELOG.md?
# --------------------------------------------------------------------------------------------------------------------
changelog.check!
