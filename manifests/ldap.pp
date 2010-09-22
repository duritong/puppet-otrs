# manifests/ldap.pp

class otrs::ldap inherits otrs {
  include perl::extensions::ldap
}
