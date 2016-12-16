# Version

## Actions
### Show
##### Route
    GET /version
###### Example Command
    $ http -j :3000/version
###### Description
Returns the version of the running backend

#### Request Data
No request data is used.

#### Response Data
* 200/OK: Contains the [Resource Object](#resource-object).

-

## Response Objects
### Resource Object
##### Fields
* `id` [String]: *Always* `"version"`.
* `type` [String]: *Always* `"versions"`.
* `attributes` [Object]: See [Attributes](#attributes).

###### Attributes
* `full` [String]: The full version string as reported by `git describe --long --tags`.
* `commit` [String]: The commit id shortened to 7 characters.
* `tag` [String]: The latest tag that the version is based on.
* `commits_since_tag` [non-negative Integer]: The number of commits since the tag.
