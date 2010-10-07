# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_youtube-storage-for-paperclip_session',
  :secret      => 'c1449877ee5c342066430aeefce852f30c3bbbfe364d6cbec9f52062ff88b6e81ea48ff2e95f47b622fe21bc8712945774419a79503ab17b725be77340ee431f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
