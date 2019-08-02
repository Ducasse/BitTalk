"
A BtUDPErrorResponsePacket is xxxxxxxxx.

Instance Variables
	message:		<Object>

message
	- xxxxx

"
Class {
	#name : #BtUDPErrorResponse,
	#superclass : #BtUDPPacket,
	#instVars : [
		'message'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #comparing }
BtUDPErrorResponse >> = anotherPacket [
	^ super = anotherPacket
		ifTrue: [ true ]
		ifFalse: [ message = anotherPacket message ]
]

{ #category : #'converting-arrays' }
BtUDPErrorResponse >> asByteArray [
	^ super asByteArray, (message asByteArray)
]

{ #category : #comparing }
BtUDPErrorResponse >> hash [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: super hash asByteArray;
		nextPutAll: message hash asByteArray.
	^ stream contents hash
]

{ #category : #'initialize-release' }
BtUDPErrorResponse >> initialize [
	super initialize.
	message := ByteString new.
	transaction actionCode: BtUDPTransaction errorActionCode .
]

{ #category : #accessing }
BtUDPErrorResponse >> message [
	^ message
]

{ #category : #accessing }
BtUDPErrorResponse >> message: anObject [
	message := anObject
]

{ #category : #printing }
BtUDPErrorResponse >> printOn: aStream [
	aStream
		nextPutAll: 'UDP Packet: ';
		nextPutAll: transaction asString;
		nextPutAll: '. Message: ';
		nextPutAll: message
]
