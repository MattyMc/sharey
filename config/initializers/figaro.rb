# Will throw an error if environment variables are not set
Figaro.require_keys("CLIENT_ID", "CLIENT_SECRET", "secret_key_base")