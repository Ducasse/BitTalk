"
A BtTrackerRequest is xxxxxxxxx.

"
Class {
	#name : #BtHTTPAnnounceQuery,
	#superclass : #Object,
	#instVars : [
		'compact',
		'downloaded',
		'event',
		'infoHash',
		'node',
		'key',
		'left',
		'noPeerID',
		'peerID',
		'trackerID',
		'uploaded',
		'numWant'
	],
	#classVars : [
		'CompletedEvent',
		'StartedEvent',
		'StoppedEvent'
	],
	#category : #'BitTalk-HTTPTrackerProtocol'
}

{ #category : #accessing }
BtHTTPAnnounceQuery class >> completedEvent [
	^ CompletedEvent
]

{ #category : #'initialize-release' }
BtHTTPAnnounceQuery class >> initialize [
	super initialize.
	StartedEvent := #started.
	StoppedEvent := #stopped.
	CompletedEvent := #completed.
]

{ #category : #accessing }
BtHTTPAnnounceQuery class >> startedEvent [
	^ StartedEvent
]

{ #category : #accessing }
BtHTTPAnnounceQuery class >> stoppedEvent [
	^ StoppedEvent
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> compact [
	^ compact
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> compact: anObject [
	compact := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> downloaded [
	^ downloaded
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> downloaded: anObject [
	downloaded := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> event [
	^ event
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> event: anObject [
	event := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> infoHash [
	^ infoHash
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> infoHash: anObject [
	infoHash := anObject
]

{ #category : #'initialize-release' }
BtHTTPAnnounceQuery >> initialize [
	super initialize.
	compact := 1.
	downloaded := 0.
	event := nil.
	infoHash := 0.
	node := BtNode new domain: (BtDomain new address: 0); port: 0.
	key := 0.
	left := 0.
	noPeerID := 0.
	numWant := 50.
	peerID := 0.
	trackerID := nil.
	uploaded := 0
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> key [
	^ key
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> key: anObject [
	key := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> left [
	^ left
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> left: anObject [
	left := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> noPeerID [
	^ noPeerID
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> noPeerID: anObject [
	noPeerID := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> node [
	^ node
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> node: anObject [
	node := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> numWant [
	^ numWant
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> numWant: anObject [
	numWant := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> peerID [
	^ peerID
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> peerID: anObject [
	peerID := anObject
]

{ #category : #printing }
BtHTTPAnnounceQuery >> printOn: aStream [
	| queryString percentEncoder |
	percentEncoder := ZnPercentEncoder new.
	percentEncoder characterEncoder: ZnNullEncoder new.
	queryString := WriteStream with: String new.
	trackerID
		ifNotNil: [ 
			queryString
				nextPutAll: 'trackerid=';
				nextPutAll: (percentEncoder encode: trackerID asByteArray asString);
				nextPutAll: '&' ].
	event
		ifNotNil: [ 
			queryString
				nextPutAll: 'event=';
				nextPutAll: event;
				nextPutAll: '&' ].
	node domain address = 0
		ifFalse: [ 
			queryString
				nextPutAll: 'ip=';
				nextPutAll: node domain address asIPv4 dotted;
				nextPutAll: '&' ].
	queryString
		nextPutAll: 'key=';
		nextPutAll: (percentEncoder encode: key asByteArray asString);
		nextPutAll: '&';
		nextPutAll: 'numwant=';
		nextPutAll: numWant asString;
		nextPutAll: '&';
		nextPutAll: 'info_hash=';
		nextPutAll: (percentEncoder encode: infoHash asByteArray asString);
		nextPutAll: '&';
		nextPutAll: 'peer_id=';
		nextPutAll: (percentEncoder encode: peerID asByteArray asString);
		nextPutAll: '&';
		nextPutAll: 'port=';
		nextPutAll: node port asString;
		nextPutAll: '&';
		nextPutAll: 'uploaded=';
		nextPutAll: uploaded asString;
		nextPutAll: '&';
		nextPutAll: 'downloaded=';
		nextPutAll: downloaded asString;
		nextPutAll: '&';
		nextPutAll: 'left=';
		nextPutAll: left asString;
		nextPutAll: '&';
		nextPutAll: 'compact=';
		nextPutAll: compact asString;
		nextPutAll: '&';
		nextPutAll: 'no_peer_id=';
		nextPutAll: noPeerID asString.
	aStream nextPutAll: queryString contents.
]

{ #category : #operations }
BtHTTPAnnounceQuery >> setCompleted [
	event:= CompletedEvent 
]

{ #category : #operations }
BtHTTPAnnounceQuery >> setNone [
	event:= nil 
]

{ #category : #operations }
BtHTTPAnnounceQuery >> setStarted [
	event:= StartedEvent 
]

{ #category : #operations }
BtHTTPAnnounceQuery >> setStopped [
	event:= StoppedEvent 
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> trackerID [
	^ trackerID
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> trackerID: anObject [
	trackerID := anObject
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> uploaded [
	^ uploaded
]

{ #category : #accessing }
BtHTTPAnnounceQuery >> uploaded: anObject [
	uploaded := anObject
]
