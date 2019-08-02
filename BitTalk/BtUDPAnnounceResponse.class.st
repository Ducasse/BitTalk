"
A BtUDPAnnounceResponsePacket is xxxxxxxxx.

Instance Variables
	connectionID:		<Object>

connectionID
	- xxxxx

"
Class {
	#name : #BtUDPAnnounceResponse,
	#superclass : #BtUDPPacket,
	#instVars : [
		'interval',
		'leechers',
		'nodeCollection',
		'seeders'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #comparing }
BtUDPAnnounceResponse >> = anotherPacket [
	^ super = anotherPacket
		ifTrue: [ true ]
		ifFalse: [ 
			interval = anotherPacket interval
				and: [ 
					leechers = anotherPacket leechers
						and: [ seeders = anotherPacket seeders and: [ nodeCollection = anotherPacket nodeCollection ] ] ] ]
]

{ #category : #'converting-arrays' }
BtUDPAnnounceResponse >> asByteArray [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: super asByteArray;
		nextPutAll: (interval asByteArrayOfSize: 4);
		nextPutAll: (leechers asByteArrayOfSize: 4);
		nextPutAll: (seeders asByteArrayOfSize: 4).
	nodeCollection
		do: [ :node | 
			stream
				nextPutAll: node domain address asIPv4;
				nextPutAll: node port asPortNumber ].
	^ stream contents
]

{ #category : #comparing }
BtUDPAnnounceResponse >> hash [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: super hash asByteArray;
		nextPutAll: seeders hash asByteArray;
		nextPutAll: leechers hash asByteArray;
		nextPutAll: interval hash asByteArray;
		nextPutAll: nodeCollection hash asByteArray.
	^ stream contents hash
]

{ #category : #'initialize-release' }
BtUDPAnnounceResponse >> initialize [
	super initialize.
	interval := 0.
	leechers := 0.
	nodeCollection := Set new.
	seeders := 0.
	transaction actionCode: BtUDPTransaction announceActionCode .
]

{ #category : #accessing }
BtUDPAnnounceResponse >> interval [
	^ interval
]

{ #category : #accessing }
BtUDPAnnounceResponse >> interval: anObject [
	interval := anObject
]

{ #category : #accessing }
BtUDPAnnounceResponse >> leechers [
	^ leechers
]

{ #category : #accessing }
BtUDPAnnounceResponse >> leechers: anObject [
	leechers := anObject
]

{ #category : #accessing }
BtUDPAnnounceResponse >> nodeCollection [
	^ nodeCollection
]

{ #category : #accessing }
BtUDPAnnounceResponse >> seeders [
	^ seeders
]

{ #category : #accessing }
BtUDPAnnounceResponse >> seeders: anObject [
	seeders := anObject
]
