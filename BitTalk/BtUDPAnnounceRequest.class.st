"
A BtUDPAnnounceRequestPacket is xxxxxxxxx.

Instance Variables
	address:		<Object>
	downloaded:		<Object>
	event:		<Object>
	infoHash:		<Object>
	key:		<Object>
	left:		<Object>
	numWant:		<Object>
	peerID:		<Object>
	port:		<Object>
	uploaded:		<Object>

address
	- xxxxx

downloaded
	- xxxxx

event
	- xxxxx

infoHash
	- xxxxx

key
	- xxxxx

left
	- xxxxx

numWant
	- xxxxx

peerID
	- xxxxx

port
	- xxxxx

uploaded
	- xxxxx

"
Class {
	#name : #BtUDPAnnounceRequest,
	#superclass : #BtUDPConnectRequest,
	#instVars : [
		'downloaded',
		'event',
		'infoHash',
		'key',
		'left',
		'node',
		'numWant',
		'peerID',
		'uploaded'
	],
	#classVars : [
		'CompletedEvent',
		'NoneEvent',
		'StartedEvent',
		'StoppedEvent'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #accessing }
BtUDPAnnounceRequest class >> completedEvent [
	^ CompletedEvent
]

{ #category : #'initialize-release' }
BtUDPAnnounceRequest class >> initialize [
	super initialize.
	NoneEvent := 0.
	CompletedEvent := 1.
	StartedEvent := 2.
	StoppedEvent := 3.	

]

{ #category : #accessing }
BtUDPAnnounceRequest class >> noneEvent [
	^ NoneEvent
]

{ #category : #accessing }
BtUDPAnnounceRequest class >> startedEvent [
	^ StartedEvent
]

{ #category : #accessing }
BtUDPAnnounceRequest class >> stoppedEvent [
	^ StoppedEvent
]

{ #category : #'converting-arrays' }
BtUDPAnnounceRequest >> asByteArray [
	^ super asByteArray ,
	( infoHash asByteArrayOfSize: 20) ,
	( peerID asByteArrayOfSize: 20) ,
	( downloaded asByteArrayOfSize: 8) , 
	( left asByteArrayOfSize: 8) ,
	( uploaded asByteArrayOfSize: 8) ,
	( event asByteArrayOfSize: 4) ,
	( node domain address asIPv4 ) ,
	( key asByteArrayOfSize: 4) ,
	( numWant asByteArrayOfSize: 4) ,
	( node port asPortNumber ) .
]

{ #category : #accessing }
BtUDPAnnounceRequest >> downloaded [
	^ downloaded
]

{ #category : #accessing }
BtUDPAnnounceRequest >> downloaded: anObject [
	downloaded := anObject
]

{ #category : #accessing }
BtUDPAnnounceRequest >> event [
	^ event
]

{ #category : #accessing }
BtUDPAnnounceRequest >> event: anObject [
	event := anObject
]

{ #category : #accessing }
BtUDPAnnounceRequest >> infoHash [
	^ infoHash
]

{ #category : #accessing }
BtUDPAnnounceRequest >> infoHash: anObject [
	infoHash := anObject
]

{ #category : #'initialize-release' }
BtUDPAnnounceRequest >> initialize [
	super initialize.
	downloaded := 0.
	event := 0.
	infoHash := 0.
	key := 0.
	left := 0.
	node := BtNode new.
	numWant := 0.
	peerID := 0.
	uploaded := 0.
	transaction actionCode: BtUDPTransaction announceActionCode .
]

{ #category : #accessing }
BtUDPAnnounceRequest >> key [
	^ key
]

{ #category : #accessing }
BtUDPAnnounceRequest >> key: anObject [
	key := anObject
]

{ #category : #accessing }
BtUDPAnnounceRequest >> left [
	^ left
]

{ #category : #accessing }
BtUDPAnnounceRequest >> left: anObject [
	left := anObject
]

{ #category : #accessing }
BtUDPAnnounceRequest >> node [
	^ node
]

{ #category : #accessing }
BtUDPAnnounceRequest >> node: anObject [
	node := anObject
]

{ #category : #accessing }
BtUDPAnnounceRequest >> numWant [
	^ numWant
]

{ #category : #accessing }
BtUDPAnnounceRequest >> numWant: anObject [
	numWant := anObject
]

{ #category : #accessing }
BtUDPAnnounceRequest >> peerID [
	^ peerID
]

{ #category : #accessing }
BtUDPAnnounceRequest >> peerID: anObject [
	peerID := anObject
]

{ #category : #operations }
BtUDPAnnounceRequest >> setCompleted [
	event:= CompletedEvent 
]

{ #category : #operations }
BtUDPAnnounceRequest >> setNone [
	event:= NoneEvent 
]

{ #category : #operations }
BtUDPAnnounceRequest >> setStarted [
	event:= StartedEvent 
]

{ #category : #operations }
BtUDPAnnounceRequest >> setStopped [
	event:= StoppedEvent 
]

{ #category : #accessing }
BtUDPAnnounceRequest >> uploaded [
	^ uploaded
]

{ #category : #accessing }
BtUDPAnnounceRequest >> uploaded: anObject [
	uploaded := anObject
]
