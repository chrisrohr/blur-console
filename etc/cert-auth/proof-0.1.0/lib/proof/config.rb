require 'ostruct'

module Proof
  class Config < OpenStruct

    def initialize(config={})
      super({
        :ldap_connection => {},
        :user_certificate_attribute => 'usercertificate;binary',
        :attributes => [],
        :attribute_map => {},
        :include_groups => true,
        :include_nested_groups => false,
        :x509_cn_header => 'HTTP_X_FORWARDED_CLIENT_CN',
        :x509_cert_header => 'HTTP_X_FORWARDED_CLIENT_CERT',
        :user_search_base => nil,
        :group_search_base => nil,
        :group_membership_attribute => 'uniquemember',
        :group_objectclass => 'groupofuniquenames'
      }.merge(config))
    end

  end
end
