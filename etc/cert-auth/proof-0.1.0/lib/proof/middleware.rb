require 'net/ldap'

module Proof
  class Middleware
    CERTIFICATE_FORMAT_EXPRESSION = /\s(?!CERTIFICATE-{5})/

    def initialize(app, config)
      @app, @config = app, config
    end

    def call(env)
      authenticate(env)
      @app.call(env)
    end

    private

      def authenticate(env)
        request = Rack::Request.new(env)
        return if request.session[:proof]

        cn = env[@config.x509_cn_header]
        pem = env[@config.x509_cert_header]
        return if cn.nil? || pem.nil?

        pem = pem.gsub(CERTIFICATE_FORMAT_EXPRESSION, "\n")
        cert = OpenSSL::X509::Certificate.new(pem).to_der
        attributes = {}

        Net::LDAP.open(@config.ldap_connection) do |conn|
          search_for_user(conn, cn, cert, attributes)
          search_for_groups(conn, attributes) if (!attributes.nil? && !attributes.empty?) && @config.include_groups
        end

        request.session[:proof] = attributes if (!attributes.nil? && !attributes.empty?)
      end

      def search_for_user(conn, cn, cert, attributes)
        params = {
          :base => @config.user_search_base,
          :attributes => @config.attributes.concat([@config.user_certificate_attribute]),
          :filter => Net::LDAP::Filter.eq('cn', cn)
        }

        conn.search(params) do |entry|
          if cert_match?(entry, cert)
            attributes[:dn] = entry.dn.dup
            entry.each do |attr_name, values|
              attributes[mapped_attribute_name(attr_name)] = values.map(&:dup) if return_attribute?(attr_name)
            end
          end
        end
      end

      def search_for_groups(conn, attributes)
        params = {
          :base => @config.group_search_base,
          :attributes => ['cn'],
          :filter => Net::LDAP::Filter.eq(@config.group_membership_attribute, attributes[:dn]) & Net::LDAP::Filter.eq('objectclass', @config.group_objectclass)
        }

        groups = conn.search(params)
        append_nested_groups(conn, groups, groups) if @config.include_nested_groups
        attributes[:groups] = groups.map(&:cn).flatten.map(&:dup)
      end

      def append_nested_groups(conn, groups, groups_to_search)
        objectclass = Net::LDAP::Filter.eq('objectclass', @config.group_objectclass)
        filter = groups_to_search.inject(objectclass) do |f, group|
          f & Net::LDAP::Filter.eq(@config.group_membership_attribute, group.dn)
        end
        params = { :base => @config.group_search_base, :attributes => ['cn'], :filter => filter }
        groups_to_search = conn.search(params) - groups
        groups.concat(groups_to_search)
        append_nested_groups(conn, groups, groups_to_search) if (!groups_to_search.nil? && !groups_to_search.empty?)
      end

      def cert_match?(ldap_entry, cert)
        ldap_entry[@config.user_certificate_attribute].include?(cert)
      end

      def mapped_attribute_name(attr_name)
        (@config.attribute_map[attr_name] || attr_name).to_sym
      end

      def return_attribute?(attr_name)
        @config.attributes.include?(attr_name.to_sym)
      end

  end
end
