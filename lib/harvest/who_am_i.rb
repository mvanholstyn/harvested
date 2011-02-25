module Harvest

  # The model that contains the information about the user
  #
  # == Fields

  # [+email+] Email address of the user
  # [+timestamp-timers+] Does the user have timers running?
  # [+admin+] Is this user an admin?
  # [+timezone+] What timezone the user is located
  # [+id+]

  class WhoAmI < BaseModel
    include HappyMapper
    tag 'user'

    element :timezone, String
    element :email, String
    element :timestamp_timers, Boolean, :tag => 'timestamp-timers'
    element :admin, Boolean
    element :id, Integer
  end
end