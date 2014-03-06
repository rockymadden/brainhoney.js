bilby = require('bilby')
lazy = require('lazy.js')
q = require('q')
truthy = require('truthy.js')

brainhoney =
	Http: class Http
		constructor: (@host, @port, @path, @token) ->
			@httplib = if @port is 443 then require('https') else require('http')

		get: (command, parameters) ->
			self = @
			deferred = q.defer()
			options =
				headers:
					'Accept': 'application/json'
					'Cookie': truthy.opt.existy(self.token).map((_) -> 'AZT=' + _).getOrElse('')
					'Host': self.host
				host: self.host
				method: 'GET'
				path: self.path + self.querystring(command, parameters).getOrElse('')
				port: self.port
			request = self.httplib.request(options, (response) ->
				data = ''

				response.on('data', (_) -> data += _)
				response.on('end', ->
					try
						json = JSON.parse(data)
					catch
						deferred.reject(data)

					self.response(json).fold(
						((_) -> deferred.reject(_)),
						((_) -> deferred.resolve(_))
					)
				)
				response.on('error', (_) -> deferred.reject(_))
			)

			request.end()
			deferred.promise

		response: (json) ->
			if truthy.bool.objecty(json) and
			truthy.bool.objecty(json.response) and
			truthy.bool.lengthy(json.response.code) and
			json.response.code is 'OK'
				bilby.right(truthy.opt.lengthy(
					lazy(json.response)
						.filter((_) -> truthy.bool.objecty(_))
						.toArray()
				).map((_) -> _[0]))
			else bilby.left(json)

		post: (command, payload, parameters) ->
			self = @
			deferred = q.defer()
			pl = JSON.stringify(request: payload)
			options =
				headers:
					'Accept': 'application/json'
					'Content-Type': 'application/json'
					'Content-Length': pl.length
					'Cookie': truthy.opt.existy(self.token).map((_) -> 'AZT=' + _).getOrElse('')
					'Host': self.host
				host: self.host
				method: 'POST'
				path: self.path + self.querystring(command, parameters).getOrElse('')
				port: self.port
			request = self.httplib.request(options, (response) ->
				data = ''

				response.on('data', (_) -> data += _)
				response.on('end', ->
					try
						json = JSON.parse(data)
					catch
						deferred.reject(data)

					self.response(json).fold(
						((_) -> deferred.reject(_)),
						((_) -> deferred.resolve(_))
					)
				)
				response.on('error', (_) -> deferred.reject(_))
			)

			request.write(pl)
			request.end()
			deferred.promise

		querystring: (command, parameters) ->
			truthy.opt.existy(command)
				.map(->
					p = truthy.opt.objecty(parameters)
						.map((_) -> lazy(_).assign(cmd: command).toObject())
						.getOrElse(cmd: command)

					'?' + lazy(p)
						.reduce(((a, b, c) -> a += ('&' + c + '=' + b.toString())), '')
						.toString()
						.substring(1)
				)

	Client: class Client
		constructor: (@host, @port, @path, @username, @password) ->

		withSession: (f) ->
			self = @

			new Http(@host, @port, @path).post(null, cmd: 'login', username: @username, password: @password)
				.then((_) ->
					token = _.map((_) -> _.token).getOrElse(null)
					new Http(self.host, self.port, self.path, token)
				)
				.then((http) -> f(Object.freeze(
					# Annoucements.
					deleteAnnoucements: bilby.bind(http.post)(http, 'deleteannouncements')
					getAnnoucement: bilby.bind(http.get)(http, 'getannouncement')
					getAnnoucementInfo: bilby.bind(http.get)(http, 'getannouncementinfo')
					getAnnoucementList: bilby.bind(http.get)(http, 'getannouncementlist')
					getUserAnnoucementList: bilby.bind(http.get)(http, 'getuserannouncementlist')
					listRestorableAnnouncements: bilby.bind(http.get)(http, 'listrestorableannouncements')
					putAnnouncement: bilby.bind(http.post)(http, 'putannouncement')
					restoreAnnouncements: bilby.bind(http.post)(http, 'restoreannouncements')
					updateAnnouncementViewed: bilby.bind(http.post)(http, 'updateannouncementviewed')
					# Authentication.
					getCookie: bilby.bind(http.get)(http, 'getcookie')
					getKey: bilby.bind(http.get)(http, 'getkey')
					getPasswordQuestion: bilby.bind(http.get)(http, 'getpasswordquestion')
					login: bilby.bind(http.post)(http, 'login')
					logout: bilby.bind(http.get)(http, 'logout')
					proxy: bilby.bind(http.get)(http, 'proxy')
					putKey: bilby.bind(http.get)(http, 'putkey')
					resetPassword: bilby.bind(http.post)(http, 'resetpassword')
					unproxy: bilby.bind(http.get)(http, 'unproxy')
					updatePassword: bilby.bind(http.post)(http, 'updatepassword')
					updatePasswordQuestionAnswer: bilby.bind(http.post)(http, 'updatepasswordquestionanswer')
					# Conversion.
					exportData: bilby.bind(http.post)(http, 'exportdata')
					getConvertedData: bilby.bind(http.get)(http, 'getconverteddata')
					importData: bilby.bind(http.post)(http, 'importdata')
					# Courses.
					copyCourses: bilby.bind(http.post)(http, 'copycourses')
					createCourses: bilby.bind(http.post)(http, 'createcourses')
					createDemoCourse: bilby.bind(http.post)(http, 'createdemocourse')
					deleteCourses: bilby.bind(http.post)(http, 'deletecourses')
					getCourse2: bilby.bind(http.get)(http, 'getcourse2')
					getCourseHistory: bilby.bind(http.get)(http, 'getcoursehistory')
					listCourses: bilby.bind(http.get)(http, 'listcourses')
					mergeCourses: bilby.bind(http.post)(http, 'mergecourses')
					restoreCourse: bilby.bind(http.get)(http, 'restorecourse')
					updateCourses: bilby.bind(http.post)(http, 'updatecourses')
					# Domains.
					createdomains: bilby.bind(http.post)(http, 'createdomains')
					deletedomain: bilby.bind(http.post)(http, 'deletedomain')
					getdomain2: bilby.bind(http.get)(http, 'getdomain2')
					getdomaincontent: bilby.bind(http.get)(http, 'getdomaincontent')
					getdomainparentlist: bilby.bind(http.get)(http, 'getdomainparentlist')
					getdomainstats: bilby.bind(http.get)(http, 'getdomainstats')
					listdomains: bilby.bind(http.get)(http, 'listdomains')
					restoredomain: bilby.bind(http.get)(http, 'restoredomain')
					updatedomains: bilby.bind(http.post)(http, 'updatedomains')
					# Enrollments.
					createEnrollments: bilby.bind(http.post)(http, 'createenrollments')
					deleteEnrollments: bilby.bind(http.post)(http, 'deleteenrollments')
					getEnrollment3: bilby.bind(http.get)(http, 'getenrollment3')
					getEnrollmentActivity: bilby.bind(http.get)(http, 'getenrollmentactivity')
					getEnrollmentGradebook2: bilby.bind(http.get)(http, 'getenrollmentgradebook2')
					getEnrollmentGroupList: bilby.bind(http.get)(http, 'getenrollmentgrouplist')
					getEntityenrollmentList2: bilby.bind(http.get)(http, 'getentityenrollmentlist2')
					getUserenrollmentList2: bilby.bind(http.get)(http, 'getuserenrollmentlist2')
					listEnrollments: bilby.bind(http.get)(http, 'listenrollments')
					restoreEnrollment: bilby.bind(http.get)(http, 'restoreenrollment')
					updateEnrollments: bilby.bind(http.post)(http, 'updateenrollments')
					# General.
					getCommandList: bilby.bind(http.get)(http, 'getcommandlist')
					getEntityType: bilby.bind(http.get)(http, 'getentitytype')
					getStatus: bilby.bind(http.get)(http, 'getstatus')
					sendMail: bilby.bind(http.post)(http, 'sendmail')
					# Groups.
					addGroupMembers: bilby.bind(http.post)(http, 'addgroupmembers')
					createGroups: bilby.bind(http.post)(http, 'creategroups')
					deleteGroups: bilby.bind(http.post)(http, 'deletegroups')
					getGroup: bilby.bind(http.get)(http, 'getgroup')
					getGroupEnrollmentList: bilby.bind(http.get)(http, 'getgroupenrollmentlist')
					getGroupList: bilby.bind(http.get)(http, 'getgrouplist')
					removeGroupMembers: bilby.bind(http.post)(http, 'removegroupmembers')
					updateGroups: bilby.bind(http.post)(http, 'updategroups')
					# Manifests and items.
					copyItems: bilby.bind(http.post)(http, 'copyitems')
					deleteItems: bilby.bind(http.post)(http, 'deleteitems')
					getCourseContent: bilby.bind(http.get)(http, 'getcoursecontent')
					getItem: bilby.bind(http.get)(http, 'getitem')
					getItemInfo: bilby.bind(http.get)(http, 'getiteminfo')
					getItemLinks: bilby.bind(http.get)(http, 'getitemlinks')
					getItemList: bilby.bind(http.get)(http, 'getitemlist')
					getManifest: bilby.bind(http.get)(http, 'getmanifest')
					getManifestData: bilby.bind(http.get)(http, 'getmanifestdata')
					getManifestInfo: bilby.bind(http.post)(http, 'getmanifestinfo')
					getManifestItem: bilby.bind(http.get)(http, 'getmanifestitem')
					listRestorableItems: bilby.bind(http.get)(http, 'listrestorableitems')
					ltil: bilby.bind(http.get)(http, 'ltil')
					putItems: bilby.bind(http.post)(http, 'putitems')
					restoreItems: bilby.bind(http.post)(http, 'restoreitems')
					search: bilby.bind(http.get)(http, 'search')
					updateManifestData: bilby.bind(http.post)(http, 'updatemanifestdata')
					# Peer grading.
					getPeerResponse: bilby.bind(http.get)(http, 'getpeerresponse')
					getPeerResponseInfo: bilby.bind(http.post)(http, 'getpeerresponseinfo')
					getPeerResponseList: bilby.bind(http.post)(http, 'getpeerresponselist')
					getPeerReviewList: bilby.bind(http.get)(http, 'getpeerreviewlist')
					putPeerResponse: bilby.bind(http.post)(http, 'putpeerresponse')
					# Ratings.
					getItemRating: bilby.bind(http.get)(http, 'getitemrating')
					getItemRatingSummary: bilby.bind(http.get)(http, 'getitemratingsummary')
					putItemRating: bilby.bind(http.get)(http, 'putitemrating')
					# Reports.
					createReports: bilby.bind(http.post)(http, 'createreports')
					deleteReports: bilby.bind(http.post)(http, 'deletereports')
					getReportDefinitionList: bilby.bind(http.get)(http, 'getreportdefinitionlist')
					getReportInfo: bilby.bind(http.get)(http, 'getreportinfo')
					getReportList: bilby.bind(http.get)(http, 'getreportlist')
					getRunnableReportList: bilby.bind(http.get)(http, 'getrunnablereportlist')
					runReport: bilby.bind(http.get)(http, 'runreport')
					updateReports: bilby.bind(http.post)(http, 'updatereports')
					# Rights.
					getActorRights: bilby.bind(http.get)(http, 'getactorrights')
					deleteSubscriptions: bilby.bind(http.post)(http, 'deletesubscriptions')
					getEffectiveRights: bilby.bind(http.get)(http, 'geteffectiverights')
					getEffectiveSubscriptionList: bilby.bind(http.get)(http, 'geteffectivesubscriptionlist')
					getEntityRights: bilby.bind(http.get)(http, 'getentityrights')
					getEntitySubscriptionList: bilby.bind(http.get)(http, 'getentitysubscriptionlist')
					getRecord: bilby.bind(http.get)(http, 'getrecord')
					getRecordList: bilby.bind(http.get)(http, 'getrecordlist')
					getRights: bilby.bind(http.get)(http, 'getrights')
					getRightsList: bilby.bind(http.get)(http, 'getrightslist')
					getSubscriptionList: bilby.bind(http.get)(http, 'getsubscriptionlist')
					updateRights: bilby.bind(http.post)(http, 'updaterights')
					updateSubscriptions: bilby.bind(http.post)(http, 'updatesubscriptions')
					# Signals.
					createSignal: bilby.bind(http.post)(http, 'createsignal')
					getSignalList: bilby.bind(http.get)(http, 'getsignallist')
					# Users.
					createUsers2: bilby.bind(http.post)(http, 'createusers2')
					deleteUsers: bilby.bind(http.post)(http, 'deleteusers')
					getActiveUserCount: bilby.bind(http.get)(http, 'getactiveusercount')
					getProfilePicture: bilby.bind(http.get)(http, 'getprofilepicture')
					getUser2: bilby.bind(http.get)(http, 'getuser2')
					getUserActivity: bilby.bind(http.get)(http, 'getuseractivity')
					listUsers: bilby.bind(http.get)(http, 'listusers')
					restoreUser: bilby.bind(http.get)(http, 'restoreuser')
					updateUsers: bilby.bind(http.post)(http, 'updateusers')
					# Wikis.
					copyWikiPages: bilby.bind(http.post)(http, 'copywikipages')
					deleteWikiPages: bilby.bind(http.post)(http, 'deletewikipages')
					getWikiPage: bilby.bind(http.get)(http, 'getwikipage')
					getWikiPageList: bilby.bind(http.get)(http, 'getwikipagelist')
					listRestorableWikiPages: bilby.bind(http.get)(http, 'listrestorablewikipages')
					putWikiPage: bilby.bind(http.post)(http, 'putwikipage')
					restoreWikiPages: bilby.bind(http.post)(http, 'restorewikipages')
					updateWikiPageViewed: bilby.bind(http.post)(http, 'updatewikipageviewed')
				))).done(->)

module.exports = Object.freeze(brainhoney)
