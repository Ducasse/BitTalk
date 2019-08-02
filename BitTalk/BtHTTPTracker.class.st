"
A BtHTTPTracker is xxxxxxxxx.

"
Class {
	#name : #BtHTTPTracker,
	#superclass : #BtTracker,
	#classVars : [
		'Announce',
		'Scrape'
	],
	#category : #'BitTalk-HTTPTrackerProtocol'
}

{ #category : #accessing }
BtHTTPTracker class >> announce [
	^ Announce 
]

{ #category : #'initialize-release' }
BtHTTPTracker class >> initialize [
	super initialize.
	Announce := #announce .
	Scrape := #scrape .
]

{ #category : #accessing }
BtHTTPTracker class >> scrape [
	^Scrape 
]

{ #category : #operations }
BtHTTPTracker >> announce [
	| httpGET  response |
	httpGET := self newGET: path query: announceRequest asString .
	response:= self sendGET: httpGET .
	self updateAnnounceResponse: response.
]

{ #category : #testing }
BtHTTPTracker >> announceHasFailed [
	^announceResponse isFailure 
]

{ #category : #accessing }
BtHTTPTracker >> announceRequest: newAnnounceRequest [
	| oldTrackerID |
	oldTrackerID:=announceRequest trackerID.
	announceRequest := newAnnounceRequest . 
	oldTrackerID ifNotNil: [ announceRequest trackerID: oldTrackerID ] 
]

{ #category : #'initialize-release' }
BtHTTPTracker >> initialize [
	super initialize.
	announceRequest:= BtHTTPAnnounceQuery new.
	announceResponse:= BtHTTPAnnounceResponseBody new.
	announceResponse failureReason: 'initialized'.
	scrapeRequest:= BtHTTPScrapeQuery new.
	scrapeResponse:= BtHTTPScrapeResponseBody new.
]

{ #category : #accessing }
BtHTTPTracker >> interval [
	^announceResponse at:'interval'
]

{ #category : #testing }
BtHTTPTracker >> isHTTP [
	^true
]

{ #category : #testing }
BtHTTPTracker >> isUDP [
	^false
]

{ #category : #operations }
BtHTTPTracker >> newGET: getPath query: query [
	| httpGET |
	httpGET := WriteStream with: String new.
	httpGET
		nextPutAll: 'GET ';
		nextPutAll: getPath;
		nextPutAll: '?';
		nextPutAll: query.
	httpGET
		nextPutAll: ' HTTP/1.1';
		nextPutAll: String crlf;
		nextPutAll: 'User-Agent: BitTalk';
		nextPutAll: String crlf;
		nextPutAll: 'Accept-Encoding: gzip';
		nextPutAll: String crlf;
		nextPutAll: 'Connection: close';
		nextPutAll: String crlf;
		nextPutAll: 'Host: ';
		nextPutAll: domain name;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: String crlf;
		nextPutAll: 'Accept: text/plain;charset=utf-8';
		nextPutAll: String crlf;
		nextPutAll: String crlf.
	^ httpGET contents
]

{ #category : #printing }
BtHTTPTracker >> printOn: aStream [
	aStream
		nextPutAll: #http;
		nextPutAll: '://';
		nextPutAll: domain name;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: '/';
		nextPutAll: path
]

{ #category : #operations }
BtHTTPTracker >> scrape [
	| response httpGET |
	httpGET := self newGET: self asString asZnUrl asZnUrlScrape pathPrintString query: scrapeRequest asString.
	response := self sendGET: httpGET.
	self updateScrapeResponse: response
]

{ #category : #operations }
BtHTTPTracker >> sendGET: httpGET [
	^[ 
		| clientSocket  |
		[		
			clientSocket := SocketStream openConnectionToHost: domain address asIPv4 port: (port ifNil: [80] ifNotNil: [port]) timeout: 3.
			clientSocket binary.
			clientSocket nextPutAllFlush: httpGET asByteArray .
			clientSocket upToEnd 
		] ensure: [ clientSocket ifNotNil: [ clientSocket close ] ]
	] on: NameLookupFailure , ConnectionClosed , ConnectionTimedOut do: [ :ex |  ex return ] .
]

{ #category : #operations }
BtHTTPTracker >> updateAnnounceResponse: responseBytes [
	responseBytes
		ifNil: [ 
			self log: 'announce: response = nil'.
			announceResponse := BtHTTPAnnounceResponseBody new
				failureReason: 'no response';
				yourself ]
		ifNotNil: [ 
			| index headers |
			index := responseBytes asString findString: String crlfcrlf.
			headers := responseBytes copyFrom: 1 to: index - 1.
			(#('HTTP/1.0 404 Not Found' 'HTTP/1.1 404 Not Found') anySatisfy: [ :v | (headers asString findString: v) > 0 ])
				ifTrue: [ 
					self log: 'announce: ' , headers asString.
					announceResponse := BtHTTPAnnounceResponseBody new
						failureReason: 'status error';
						yourself ]
				ifFalse: [ 
					lastAnnounceResponseTime := Time millisecondClockValue.
					announceResponse := BtHTTPAnnounceResponseBody
						from: (responseBytes copyFrom: index + 4 to: responseBytes size) bedecoded.
					announceResponse atTrackerIDIfPresent: [ :v | announceRequest trackerID: v asByteArray asInteger ] ] ]
]

{ #category : #operations }
BtHTTPTracker >> updateScrapeResponse: responseBytes [
	responseBytes
		ifNil: [ 
			self log: 'scrape: response = nil'.
			scrapeResponse := BtHTTPScrapeResponseBody new
				failureReason: 'no response';
				yourself ]
		ifNotNil: [ 
			| index headers |
			index := responseBytes asString findString: String crlfcrlf.
			headers := responseBytes copyFrom: 1 to: index - 1.
			(#('HTTP/1.0 404 Not Found' 'HTTP/1.1 404 Not Found') anySatisfy: [ :v | (headers asString findString: v) > 0 ])
				ifTrue: [ 
					self log: 'scrape: ' , headers asString.
					scrapeResponse := BtHTTPScrapeResponseBody new
						failureReason: 'status error';
						yourself ]
				ifFalse: [ scrapeResponse := BtHTTPScrapeResponseBody from: (responseBytes copyFrom: index + 4 to: responseBytes size) bedecoded ] ]
]
