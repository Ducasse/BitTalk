"
A BtRequestPacket is xxxxxxxxx.

"
Class {
	#name : #BtUDPConnectRequest,
	#superclass : #BtUDPPacket,
	#instVars : [
		'connectionID'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #'converting-arrays' }
BtUDPConnectRequest >> asByteArray [
	^ (connectionID asByteArrayOfSize: 8) , (super asByteArray)
]

{ #category : #accessing }
BtUDPConnectRequest >> connectionID [
	^ connectionID
]

{ #category : #accessing }
BtUDPConnectRequest >> connectionID: anObject [
	connectionID := anObject
]

{ #category : #'initialize-release' }
BtUDPConnectRequest >> initialize [
	super initialize.
	connectionID := 0.
	transaction actionCode: BtUDPTransaction connectActionCode .
]

{ #category : #printing }
BtUDPConnectRequest >> printOn: aStream [
	aStream
		nextPutAll: 'UDP Packet: ';
		nextPutAll: transaction asString;
		nextPutAll: '. ConnectionID: ';
		nextPutAll: connectionID asString
]
