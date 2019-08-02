"
A BtTracker is xxxxxxxxx.

"
Class {
	#name : #BtTracker,
	#superclass : #BtNode,
	#instVars : [
		'path',
		'announceRequest',
		'announceResponse',
		'scrapeRequest',
		'scrapeResponse',
		'lastAnnounceResponseTime'
	],
	#classVars : [
		'ValidSchemes'
	],
	#category : #BitTalk
}

{ #category : #'initialize-release' }
BtTracker class >> initialize [
	super initialize.
	ValidSchemes := #(#http #udp)
]

{ #category : #'instance creation' }
BtTracker class >> on: aZnUrl [
	| tracker |
	(ValidSchemes includes: aZnUrl scheme)
		ifFalse: [ BtBadScheme signal: 'invalid scheme' ].
	tracker := aZnUrl scheme = #http
		ifTrue: [ BtHTTPTracker new ]
		ifFalse: [ BtUDPTracker new ].
	^ tracker
		domain: (BtNamedDomain new name: aZnUrl host);
		port: aZnUrl port;
		path: aZnUrl path;
		yourself
]

{ #category : #comparing }
BtTracker >> = anotherTracker [
	^ self == anotherTracker
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherTracker species
				ifTrue: [ domain = anotherTracker domain and: [ port = anotherTracker port and: [ path = anotherTracker path  ] ] ]
				ifFalse: [ false ] 
		]
]

{ #category : #operations }
BtTracker >> announce [
	self subclassResponsibility 
]

{ #category : #testing }
BtTracker >> announceHasFailed [
	self subclassResponsibility 
]

{ #category : #accessing }
BtTracker >> announceRequest [
	^announceRequest 
]

{ #category : #accessing }
BtTracker >> announceRequest: anObject [
	announceRequest := anObject
]

{ #category : #accessing }
BtTracker >> announceResponse [
	^ announceResponse
]

{ #category : #accessing }
BtTracker >> announceResponse: anObject [
	announceResponse := anObject
]

{ #category : #comparing }
BtTracker >> hash [
"Hash is reimplemented because = is implemented."
	| collection |
	collection := WriteStream with: ByteArray new.
	collection nextPutAll: domain hash asByteArray .
	collection nextPutAll: port hash asByteArray .
	collection nextPutAll: path hash asByteArray .
	^collection contents hash
]

{ #category : #'initialize-release' }
BtTracker >> initialize [
	super initialize.
	path:= ByteString new.
	lastAnnounceResponseTime := nil.
]

{ #category : #accessing }
BtTracker >> interval [
	self subclassResponsibility 
]

{ #category : #testing }
BtTracker >> isHTTP [
	self subclassResponsibility 
]

{ #category : #testing }
BtTracker >> isUDP [
	self subclassResponsibility 
]

{ #category : #accessing }
BtTracker >> path [
	^ path
]

{ #category : #accessing }
BtTracker >> path: anObject [
	path := anObject
]

{ #category : #printing }
BtTracker >> printOn: aStream [
	aStream nextPutAll: self asString
]

{ #category : #operations }
BtTracker >> scrape [
	self subclassResponsibility 
]

{ #category : #accessing }
BtTracker >> scrapeRequest [
	^ scrapeRequest
]

{ #category : #accessing }
BtTracker >> scrapeRequest: anObject [
	scrapeRequest := anObject
]

{ #category : #accessing }
BtTracker >> scrapeResponse [
	^ scrapeResponse
]

{ #category : #accessing }
BtTracker >> scrapeResponse: anObject [
	scrapeResponse := anObject 
]

{ #category : #accessing }
BtTracker >> secondsSinceLastAnnounce [
	^lastAnnounceResponseTime 
		ifNil: [ nil ]
		ifNotNil: [ (Time millisecondsSince: lastAnnounceResponseTime) / 1000 ] 
]
