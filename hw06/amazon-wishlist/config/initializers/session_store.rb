# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_amazon-wishlist_session',
  :secret      => '521b93fb062463dab800b0873b21f092b90dc50bf8105d389b8001b2b7cd2f97a844792f729c97c08cf39b6cc36235b3207b63ff0b72e6567b99320f88d4a1a5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
