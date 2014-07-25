#brainhoney.js [![Build Status](http://img.shields.io/travis-ci/rockymadden/brainhoney.js.png)](http://travis-ci.org/rockymadden/brainhoney.js)

Functional wrapper around the BrainHoney DLAP API. All publicly available BrainHoney DLAP API functions are supported.

## Dependency
The project is available on the [Node Packaged Modules registry](https://npmjs.org/package/brainhoney.js). Add the
dependency in your package.json file:

```javascript
"dependencies": {
	"brainhoney.js": "0.0.x"
}
```

## Usage
Create client:
```coffeescript
client = new brainhoney.Client('ct.agilix.com', 443, '/dlap/dlap.ashx', 'username', 'password')
```

Create a user, update user, delete user, and then logout:
```coffeescript
user = requests: user: [
	username: 'username'
	password: 'password'
	firstname: 'firstname'
	lastname: 'lastname'
	email: 'email@example.com'
	domainid: 123456
]

client.withSession((session) ->
	session.createUsers2(user)
		.then((response) -> response.fold(((r) -> r.response[0].user.userid), -1))
		.then((userId) -> session.updateUsers(requests: user: [userid: userId, firstname: 'updated']); userId)
		.then((userId) -> session.deleteUsers(requests: user: [userid: userId]))
		.finally(-> session.logout())
		.done(->)
)
```

## License
```
The MIT License (MIT)

Copyright (c) 2014 Rocky Madden (http://rockymadden.com/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
