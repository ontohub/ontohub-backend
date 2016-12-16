# OrganizationalUnits

An OrganizatinoalUnit is either a [User](users.md) or an [Organization](organizations.md).

## Actions
### Read
###### Route
    GET /:user_or_organization_id
###### Example Command
    $ http -j :3000/ada
###### Description
Lists all information on the user or organization with the ID `ada`.

#### Response Data
* 200/OK: Contains
  * the [User Resource Object](users.md#resource-object) if `ada` is a user or
  * the [Organization Resource Object](organizations.md#resource-object) if `ada` is an organization.
