brainhoney = require('./brainhoney')
lazy = require('lazy.js')
should = require('should')

describe('brainhoney', ->
	describe('Http', ->
		describe('get()', ->
			it('should work', (done) ->
				http = new brainhoney.Http(
					process.env.BRAINHONEYJS_HOST,
					process.env.BRAINHONEYJS_PORT,
					process.env.BRAINHONEYJS_PATH
				)
				login =
					cmd: 'login',
					username: process.env.BRAINHONEYJS_USERNAME,
					password: process.env.BRAINHONEYJS_PASSWORD

				http.post(null, login)
					.then((_) ->
						new brainhoney.Http(
							process.env.BRAINHONEYJS_HOST,
							process.env.BRAINHONEYJS_PORT,
							process.env.BRAINHONEYJS_PATH,
							_.fold(((j) -> j.token), null)
						)
					)
					.then((http) ->
						http.get('getcookie')
							.then((_) -> _.fold(((j) -> j.token), '').length.should.be.above(0))
							.finally(-> http.get('logout'))
							.done(-> done())
					)
			)
		)
		describe('post()', ->
			it('should work', (done) ->
				http = new brainhoney.Http(
					process.env.BRAINHONEYJS_HOST,
					process.env.BRAINHONEYJS_PORT,
					process.env.BRAINHONEYJS_PATH
				)

				http.post('putrandomdata', test: 'test')
					.then((_) -> _.isNone.should.be.true)
					.done(-> done())
			)
		)
		describe('querystring()', ->
			it('should work', ->
				http = new brainhoney.Http()

				http.querystring().getOrElse('')
					.should.be.equal('')
				http.querystring('cmd').getOrElse('')
					.should.be.equal('?cmd=cmd')
				http.querystring('cmd', {key1: 'value1', key2: 'value2'}).getOrElse('')
					.should.be.equal('?cmd=cmd&key1=value1&key2=value2')
			)
		)
	)
	describe('Client', ->
		describe('withSession()', ->
			it('should work', (done) ->
				client = new brainhoney.Client(
					process.env.BRAINHONEYJS_HOST,
					process.env.BRAINHONEYJS_PORT,
					process.env.BRAINHONEYJS_PATH,
					process.env.BRAINHONEYJS_USERNAME,
					process.env.BRAINHONEYJS_PASSWORD
				)
				user = requests: user: [
					username: lazy.generate((-> Math.floor(Math.random() * 10))).take(16).toString('')
					password: 'password'
					firstname: 'firstname'
					lastname: 'lastname'
					email: 'email@example.com'
					domainid: process.env.BRAINHONEYJS_DOMAINID
				]

				client.withSession((session) ->
					session.createUsers2(user)
						.then((response) -> response.fold(((r) -> r.response[0].user.userid), -1))
						.then((userId) -> session.updateUsers(requests: user: [userid: userId, firstname: 'updated']); userId)
						.then((userId) -> session.deleteUsers(requests: user: [userid: userId]))
						.finally(-> session.logout())
						.done(-> done())
				)
			)
		)
	)
)
