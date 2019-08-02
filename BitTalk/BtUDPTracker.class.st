"
A BtUDPTrackerConnection is xxxxxxxxx.

"
Class {
	#name : #BtUDPTracker,
	#superclass : #BtTracker,
	#instVars : [
		'socket',
		'errorResponse',
		'establishmentTime',
		'lastScrapeResponseTime',
		'lastErrorResponseTime',
		'lastAnnounceRequestTime',
		'lastScrapeRequestTime',
		'lastConnectRequestTime',
		'isLastAnnounceAnswered',
		'attempts',
		'connectionStatusLock',
		'sending',
		'receiving',
		'connectionID',
		'transactionQueue'
	],
	#classVars : [
		'DefaultNumWant',
		'MaxTorrentsScraped',
		'MaximumRetries',
		'MaximumSecondsAlive'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #'initialize-release' }
BtUDPTracker class >> initialize [
	super initialize.
	DefaultNumWant := -1.
	MaxTorrentsScraped := 74.
	MaximumSecondsAlive := 60.
	MaximumRetries := 8.
]

{ #category : #accessing }
BtUDPTracker class >> maxTorrentsScraped [
	^ MaxTorrentsScraped
]

{ #category : #'instance creation' }
BtUDPTracker class >> on: aSocketUDP [
	^self new socket: aSocketUDP.
]

{ #category : #operations }
BtUDPTracker >> announce [
	self resume.
	transactionQueue nextPut: BtUDPTransaction newAnnounce
]

{ #category : #testing }
BtUDPTracker >> announceHasFailed [
	^ self isLastAnnounceAnswered not
]

{ #category : #'private - operations' }
BtUDPTracker >> connectRequest: transaction [
	^ BtUDPConnectRequest new
		transaction: transaction;
		connectionID: self connectionID
]

{ #category : #accessing }
BtUDPTracker >> connectionID [
	^connectionStatusLock critical: [ connectionID ]
]

{ #category : #'private - operations' }
BtUDPTracker >> dequeueAndSendNextPacket [
	| packet |
	self isConnectionAlive
		ifFalse: [ self reestablishConnection ].
	packet := self dequeueNextRequest.
	packet ifNotNil: [ self sendPacket: packet ]
]

{ #category : #'private - operations' }
BtUDPTracker >> dequeueNextRequest [
	^ connectionStatusLock
		critical: [ 
			| transaction |
			transaction := transactionQueue peek.
			transaction
				ifNil: [ nil ]
				ifNotNil: [ 
					transaction actionCode = BtUDPTransaction connectActionCode
						ifTrue: [ self connectRequest: transaction ]
						ifFalse: [ 
							transaction actionCode = BtUDPTransaction announceActionCode
								ifTrue: [ self updateAnnounceRequest: transaction ]
								ifFalse: [ 
									transaction actionCode = BtUDPTransaction scrapeActionCode
										ifTrue: [ self updateScrapeRequest: transaction ] ] ] ] ]
]

{ #category : #accessing }
BtUDPTracker >> domain: aDomain [
	super domain: aDomain.
	self updateProcessesNames .
]

{ #category : #accessing }
BtUDPTracker >> errorResponse [
	^ errorResponse
]

{ #category : #accessing }
BtUDPTracker >> errorResponse: anObject [
	errorResponse := anObject
]

{ #category : #accessing }
BtUDPTracker >> establishmentTime [
	^connectionStatusLock critical: [ establishmentTime ]
]

{ #category : #'handle received actions' }
BtUDPTracker >> handleReceivedAnnounce: aPacket [
	lastAnnounceResponseTime := Time millisecondClockValue.
	announceResponse := aPacket.
	connectionStatusLock critical: [ isLastAnnounceAnswered := true ]
]

{ #category : #'handle received actions' }
BtUDPTracker >> handleReceivedConnect: packet [
	connectionStatusLock
		critical: [ 
			establishmentTime := Time millisecondClockValue.
			connectionID := packet connectionID ]
]

{ #category : #'handle received actions' }
BtUDPTracker >> handleReceivedError: aPacket [
	lastErrorResponseTime := Time millisecondClockValue.
	errorResponse := aPacket
]

{ #category : #'handle received actions' }
BtUDPTracker >> handleReceivedPacket: aPacket [
	| responseTime transaction |
	responseTime := Time millisecondClockValue.
	transaction := aPacket transaction.
	(transactionQueue findFirst: [ :elem | elem = transaction ])
		ifNotNil: [ 
			self resetAttempts.
			transaction actionCode = BtUDPTransaction connectActionCode
				ifTrue: [ self handleReceivedConnect: aPacket ]
				ifFalse: [ 
					transaction actionCode = BtUDPTransaction announceActionCode
						ifTrue: [ self handleReceivedAnnounce: aPacket ]
						ifFalse: [ 
							transaction actionCode = BtUDPTransaction scrapeActionCode
								ifTrue: [ self handleReceivedScrape: aPacket ] ] ] ]
		ifNil: [ 
			transaction actionCode = BtUDPTransaction errorActionCode
				ifTrue: [ self handleReceivedError: aPacket ] ]
]

{ #category : #'handle received actions' }
BtUDPTracker >> handleReceivedScrape: aPacket [
	lastScrapeResponseTime := Time millisecondClockValue.
	scrapeResponse := aPacket
]

{ #category : #'private - operations' }
BtUDPTracker >> incrementAttempts [
	connectionStatusLock critical:[
		attempts := attempts + 1.
		attempts > MaximumRetries 
			ifTrue:[
				attempts := -1.
				self terminate.
			].		
	]
]

{ #category : #'initialize-release' }
BtUDPTracker >> initialize [
	super initialize.
	socket := Socket newUDP.
	connectionID := nil.
	announceRequest := BtUDPAnnounceRequest new.
	scrapeRequest := BtUDPScrapeRequest new.
	transactionQueue := BtUDPTransactionQueue new.
	announceResponse := BtUDPAnnounceResponse new.
	scrapeResponse := BtUDPScrapeResponse new.
	errorResponse := BtUDPErrorResponse new.
	establishmentTime := nil.
	lastConnectRequestTime := nil.
	lastScrapeRequestTime := nil.
	lastAnnounceRequestTime := nil.
	lastScrapeResponseTime := nil.
	lastErrorResponseTime := nil.
	isLastAnnounceAnswered := false.
	attempts := -1.
	self initializeProcesses.
	connectionStatusLock := Monitor new.
]

{ #category : #'initialize-release' }
BtUDPTracker >> initializeProcesses [
	self initializeSending .
	self initializeReceiving .
	self updateProcessesNames .
]

{ #category : #'initialize-release' }
BtUDPTracker >> initializeReceiving [
	receiving ifNotNil: [ receiving terminate ].
	receiving := BtExecutableBlock new
		block: [ 
			[ 
			self receiveAndHandleNextPacket.
			Processor yield ] repeat ]
]

{ #category : #'initialize-release' }
BtUDPTracker >> initializeSending [
	sending ifNotNil: [ sending terminate ].
	sending := BtExecutableBlock new
		block: [ 
			[ 
			self secondsToNextAttempt <= 0
				ifTrue: [ 
					self dequeueAndSendNextPacket.
					Processor yield ]
				ifFalse: [ self waitForNextAttempt ] ] repeat ]
]

{ #category : #accessing }
BtUDPTracker >> interval [
	^announceResponse interval
]

{ #category : #testing }
BtUDPTracker >> isConnectionAlive [
	^connectionStatusLock
		critical: [ 
			establishmentTime
				ifNil: [ false ]
				ifNotNil: [ (Time millisecondsSince: establishmentTime) <= (MaximumSecondsAlive * 1000) ] 
		]
]

{ #category : #testing }
BtUDPTracker >> isHTTP [
	^false
]

{ #category : #accessing }
BtUDPTracker >> isLastAnnounceAnswered [
	^connectionStatusLock critical: [ isLastAnnounceAnswered]
]

{ #category : #testing }
BtUDPTracker >> isUDP [
	^true
]

{ #category : #accessing }
BtUDPTracker >> lastAnnounceRequestTime [
	^connectionStatusLock critical: [ lastAnnounceRequestTime ]
]

{ #category : #accessing }
BtUDPTracker >> lastAnnounceResponseTime [
	^ lastAnnounceResponseTime
]

{ #category : #accessing }
BtUDPTracker >> lastConnectRequestTime [
	^ lastConnectRequestTime
]

{ #category : #accessing }
BtUDPTracker >> lastErrorResponseTime [
	^ lastErrorResponseTime
]

{ #category : #accessing }
BtUDPTracker >> lastRequestTime [
	| times |
	times:={ self lastAnnounceRequestTime . lastScrapeRequestTime . lastConnectRequestTime }.
	times:=times reject: [ :v| v isNil ].
	times isEmpty 
		ifTrue: [ ^nil ]
		ifFalse:[^times detectMax: [ :v | v ]]
]

{ #category : #accessing }
BtUDPTracker >> lastScrapeRequestTime [
	^ lastScrapeRequestTime
]

{ #category : #accessing }
BtUDPTracker >> lastScrapeResponseTime [
	^ lastScrapeResponseTime
]

{ #category : #printing }
BtUDPTracker >> log: aString [
	debug
		ifFalse: [ ^ self ].
	self crLog.
	(DateAndTime now asString , String space , aString) crLog
]

{ #category : #accessing }
BtUDPTracker >> path: aString [
	super path: aString.
	self updateProcessesNames .
]

{ #category : #accessing }
BtUDPTracker >> port: anInteger [
	super port: anInteger .
	self updateProcessesNames.
]

{ #category : #printing }
BtUDPTracker >> printOn: aStream [
	aStream
		nextPutAll: #udp;
		nextPutAll: '://';
		nextPutAll: domain name;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: '/';
		nextPutAll: path
]

{ #category : #'private - operations' }
BtUDPTracker >> receiveAndHandleNextPacket [
	self handleReceivedPacket: self receivePacket
]

{ #category : #'private - operations' }
BtUDPTracker >> receivePacket [
	| packetSize bufferIn packet |  
	packetSize := 0.
	bufferIn := ByteArray new: 2000.
	[ packetSize = 0 ]
		whileTrue: [ 
			packetSize := socket receiveDataInto: bufferIn fromHost: domain address asIPv4 port: port.
			Processor yield ].
	packet := (bufferIn copyFrom: 1 to: packetSize) decodeUDPResponse.
	self log: 'RECEIVED: ' , packet asString , ' from: ' , domain address asIPv4 dotted , ':' , port asString.
	^ packet
]

{ #category : #'private - operations' }
BtUDPTracker >> reestablishConnection [
	connectionStatusLock
		critical: [ 
			transactionQueue nextPut: BtUDPTransaction newConnect.
			connectionID := BtUDPPacket firstConnectionID ]
]

{ #category : #'private - operations' }
BtUDPTracker >> resetAttempts [
	connectionStatusLock critical:[attempts := -1]
]

{ #category : #operations }
BtUDPTracker >> resume [
	sending resume .
	receiving resume .
]

{ #category : #operations }
BtUDPTracker >> scrape [
	self resume.
	transactionQueue nextPutScrapeAction: BtUDPTransaction newScrape
]

{ #category : #'private - operations' }
BtUDPTracker >> secondsToNextAttempt [
	^ connectionStatusLock
		critical: [ 
			attempts < 0
				ifTrue: [ 0 ]
				ifFalse: [ 
					| lastRequestTime |
					(lastRequestTime := self lastRequestTime)
						ifNil: [ 0 ]
						ifNotNil: [ 
							| t1 t2 |
							t1 := 15 * (2 raisedTo: attempts).
							t2 := ((Time millisecondsSince: lastRequestTime) / 1000) ceiling.
							t1 - t2 ] ] ]
]

{ #category : #'private - operations' }
BtUDPTracker >> sendPacket: aPacket [
	socket sendData: aPacket asByteArray toHost: domain address asIPv4 port: port.
	aPacket transaction actionCode = BtUDPTransaction announceActionCode
		ifTrue: [ 
			connectionStatusLock
				critical: [ 
					isLastAnnounceAnswered := false.
					lastAnnounceRequestTime := Time millisecondClockValue ] ]
		ifFalse: [ 
			aPacket transaction actionCode = BtUDPTransaction scrapeActionCode
				ifTrue: [ lastScrapeRequestTime := Time millisecondClockValue ]
				ifFalse: [ 
					aPacket transaction actionCode = BtUDPTransaction connectActionCode
						ifTrue: [ lastConnectRequestTime := Time millisecondClockValue ] ] ].
	self incrementAttempts.
	self
		log:
			'SENT: ' , aPacket asString , ' to: ' , domain address asIPv4 dotted , ':' , port asString , ' -> Seconds to retry: '
				, self secondsToNextAttempt asString
]

{ #category : #accessing }
BtUDPTracker >> socket [
	^ socket
]

{ #category : #accessing }
BtUDPTracker >> socket: aSocketUDP [
	socket := aSocketUDP
]

{ #category : #operations }
BtUDPTracker >> terminate [
	receiving terminate .
	sending terminate .
]

{ #category : #'private - operations' }
BtUDPTracker >> updateAnnounceRequest: transaction [
	^announceRequest
		transaction: transaction;
		connectionID: self connectionID
]

{ #category : #'initialize-release' }
BtUDPTracker >> updateProcessesNames [
	receiving name: self asString , ' Receiving'.
	sending name: self asString , ' Sending'.
]

{ #category : #'private - operations' }
BtUDPTracker >> updateScrapeRequest: transaction [
	^scrapeRequest
		transaction: transaction;
		connectionID: self connectionID
]

{ #category : #'private - operations' }
BtUDPTracker >> waitForNextAttempt [
	[ Processor yield. self secondsToNextAttempt > 0] whileTrue
]
