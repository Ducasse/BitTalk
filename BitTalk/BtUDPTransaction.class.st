"
A BtUDPTransaction is xxxxxxxxx.

"
Class {
	#name : #BtUDPTransaction,
	#superclass : #Object,
	#instVars : [
		'id',
		'actionCode'
	],
	#classVars : [
		'ActionCodes',
		'AnnounceActionCode',
		'ConnectActionCode',
		'ErrorActionCode',
		'ScrapeActionCode'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #accessing }
BtUDPTransaction class >> actionCodes [
	^ ActionCodes
]

{ #category : #accessing }
BtUDPTransaction class >> announceActionCode [
	^ AnnounceActionCode
]

{ #category : #accessing }
BtUDPTransaction class >> connectActionCode [
	^ ConnectActionCode
]

{ #category : #accessing }
BtUDPTransaction class >> errorActionCode [
	^ ErrorActionCode
]

{ #category : #'initialize-release' }
BtUDPTransaction class >> initialize [
	super initialize.
	ConnectActionCode := 0.
	AnnounceActionCode := 1.
	ScrapeActionCode := 2.
	ErrorActionCode := 3.
	ActionCodes := { ConnectActionCode . AnnounceActionCode . ScrapeActionCode . ErrorActionCode  }.	
]

{ #category : #'instance-creation' }
BtUDPTransaction class >> newAnnounce [
	^ self new
		actionCode: AnnounceActionCode;
		id: self newID
]

{ #category : #'instance-creation' }
BtUDPTransaction class >> newConnect [
	^ self new
		actionCode: ConnectActionCode;
		id: self newID
]

{ #category : #'instance-creation' }
BtUDPTransaction class >> newID [
	^Random new nextInt: (2 raisedTo: 32) - 1 
]

{ #category : #'instance-creation' }
BtUDPTransaction class >> newScrape [
	^ self new
		actionCode: ScrapeActionCode;
		id: self newID
]

{ #category : #accessing }
BtUDPTransaction class >> scrapeActionCode [
	^ ScrapeActionCode
]

{ #category : #comparing }
BtUDPTransaction >> = anotherTransaction [
	^ self == anotherTransaction
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherTransaction species
				ifTrue: [ actionCode = anotherTransaction actionCode and: [ id = anotherTransaction id ] ]
				ifFalse: [ false ] 
		]
]

{ #category : #accessing }
BtUDPTransaction >> actionCode [
	^ actionCode
]

{ #category : #accessing }
BtUDPTransaction >> actionCode: newCode [
	(ActionCodes includes: newCode)
		ifFalse: [ BtWrongActionCode signal: 'newCode has to be any of ', (ActionCodes asString) ].
	actionCode := newCode
]

{ #category : #'converting-arrays' }
BtUDPTransaction >> asByteArray [
	^(actionCode asByteArrayOfSize: 4) , (id asByteArrayOfSize: 4)
]

{ #category : #comparing }
BtUDPTransaction >> hash [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: actionCode hash asByteArray;
		nextPutAll: id hash asByteArray.
	^ stream contents hash
]

{ #category : #accessing }
BtUDPTransaction >> id [
	^ id
]

{ #category : #accessing }
BtUDPTransaction >> id: anObject [
	id := anObject
]

{ #category : #'initialize-release' }
BtUDPTransaction >> initialize [
	super initialize.
	actionCode := 0.
	id := 0.
]

{ #category : #printing }
BtUDPTransaction >> printOn: aStream [
	| type |
	type := 'Null'.
	actionCode = ConnectActionCode
		ifTrue: [ type := 'connect' ].
	actionCode = AnnounceActionCode
		ifTrue: [ type := 'announce' ].
	actionCode = ScrapeActionCode
		ifTrue: [ type := 'scrape' ].
	actionCode = ErrorActionCode
		ifTrue: [ type := 'error' ].
	aStream
		nextPutAll: 'Transaction: ';
		nextPutAll: type;
		nextPutAll: ', ';
		nextPutAll: id asString
]

{ #category : #comparing }
BtUDPTransaction >> priorOrEqualTo: anotherTransaction [
	^actionCode = ConnectActionCode or:["actionCode ~= ConnectActionCode and" anotherTransaction actionCode ~= ConnectActionCode] 
]
