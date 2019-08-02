"
A BtPacket is xxxxxxxxx.

Instance Variables
	action:		<Object>
	transactionID:		<Object>

action
	- xxxxx

transactionID
	- xxxxx

"
Class {
	#name : #BtUDPPacket,
	#superclass : #Object,
	#instVars : [
		'transaction'
	],
	#classVars : [
		'FirstConnectionID'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #accessing }
BtUDPPacket class >> firstConnectionID [
	^ FirstConnectionID
]

{ #category : #'initialize-release' }
BtUDPPacket class >> initialize [
	super initialize.
	FirstConnectionID := (ByteArray readHexFrom: '041727101980') asInteger.
]

{ #category : #comparing }
BtUDPPacket >> = anotherPacket [
	^ self == anotherPacket
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPacket species
				ifTrue: [ transaction = anotherPacket transaction ]
				ifFalse: [ false ] 
		]
]

{ #category : #'converting-arrays' }
BtUDPPacket >> asByteArray [
	^transaction asByteArray
]

{ #category : #comparing }
BtUDPPacket >> hash [
	^ transaction hash
]

{ #category : #'initialize-release' }
BtUDPPacket >> initialize [
	super initialize.
	transaction := BtUDPTransaction new.
]

{ #category : #printing }
BtUDPPacket >> printOn: aStream [
	aStream
		nextPutAll: 'UDP Packet: ';
		nextPutAll: transaction asString
]

{ #category : #accessing }
BtUDPPacket >> transaction [
	^ transaction
]

{ #category : #accessing }
BtUDPPacket >> transaction: anObject [
	transaction := anObject
]
