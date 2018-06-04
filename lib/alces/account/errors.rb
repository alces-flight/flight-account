module Alces
  module Account
    AccountError = Class.new(RuntimeError)
    AccountUsernameError = Class.new(AccountError)
    AccountEmailError = Class.new(AccountError)
    RetryAgreement = Class.new(RuntimeError)
  end
end
