"
A BtUDPConnectResponsePacket is xxxxxxxxx.

Instance Variables
	connectionID:		<Object>

connectionID
	- xxxxx

"
Class {
	#name : #BtUDPConnectResponse,
	#superclass : #BtUDPPacket,
	#instVars : [
		'connectionID'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #comparing }
BtUDPConnectResponse >> = anotherPacket [
	^ super = anotherPacket
		ifTrue: [ true ]
		ifFalse: [ connectionID = anotherPacket connectionID ]
]

{ #category : #'converting-arrays' }
BtUDPConnectResponse >> asByteArray [
	^ super asByteArray, ( connectionID asByteArrayOfSize: 8)
	
]

{ #category : #accessing }
BtUDPConnectResponse >> connectionID [
	^ connectionID
]

{ #category : #accessing }
BtUDPConnectResponse >> connectionID: anObject [
	connectionID := anObject
]

{ #category : #comparing }
BtUDPConnectResponse >> hash [
	| stream |
	stream := WriteStream with: (super hash asByteArray).
	stream nextPutAll: connectionID hash asByteArray .
	^ stream contents hash
]

{ #category : #'initialize-release' }
BtUDPConnectResponse >> initialize [
	super initialize.
	connectionID := 0.
	transaction actionCode: BtUDPTransaction connectActionCode .
]

{ #category : #printing }
BtUDPConnectResponse >> printOn: aStream [
	aStream
		nextPutAll: 'UDP Packet: ';
		nextPutAll: transaction asString;
		nextPutAll: '. ConnectionID: ';
		nextPutAll: connectionID asString
]
