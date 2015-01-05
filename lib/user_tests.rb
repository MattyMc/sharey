# Helper methods to aid with testing
module UserTests
  def to_request
    request = {
      :provider => "google_oauth2",
      :uid => self.uid,
      :info => {
        :name => self.name,
        :email => self.email,
        :first_name => self.first_name,
        :last_name => self.last_name,
        :image => self.image
      },
      :credentials => {
        :token => self.token,
        :refresh_token => self.refresh_token,
        :expires_at => Time.at(1419290669).to_datetime,
        :expires => true
      },
      :extra => {
        :raw_info => {
          :sub => "123456789",
          :email => self.email,
          :email_verified => true,
          :name => self.name,
          :given_name => self.first_name,
          :family_name => self.last_name,
          :profile => "https://plus.google.com/123456789",
          :picture => self.image,
          :gender => "male",
          :birthday => "0000-06-25",
          :locale => "en",
          :hd => "company_name.com"
        }
      }
    }.with_indifferent_access
  end
end