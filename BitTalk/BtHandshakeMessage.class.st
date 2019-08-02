"
A BtHandshakeMessage is xxxxxxxxx.

Instance Variables
	infoHash:		<Object>
	peerID:		<Object>
	protocolIdentifier:		<Object>
	reserved:		<Object>

infoHash
	- xxxxx

peerID
	- xxxxx

protocolIdentifier
	- xxxxx

reserved
	- xxxxx

"
Class {
	#name : #BtHandshakeMessage,
	#superclass : #Object,
	#instVars : [
		'protocolIdentifier',
		'infoHash',
		'peerID',
		'protocolBehaviour'
	],
	#classVars : [
		'ProtocolIdentifier'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #'as yet unclassified' }
BtHandshakeMessage class >> infoHash: infoHash id: peerID [
	| handshake |
	handshake := self new.
	handshake
		protocolIdentifier: ProtocolIdentifier;
		protocolBehaviour: BtProtocolBehaviour new;
		infoHash: infoHash;
		peerID: peerID.
	^ handshake
]

{ #category : #'initialize-release' }
BtHandshakeMessage class >> initialize [
	super initialize.
	ProtocolIdentifier := 'BitTorrent protocol'.
]

{ #category : #accessing }
BtHandshakeMessage class >> protocolIdentifier [
	^ ProtocolIdentifier
]

{ #category : #comparing }
BtHandshakeMessage >> = anotherHandshake [
	^ self == anotherHandshake
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherHandshake species
				ifTrue: [ 
					protocolIdentifier = anotherHandshake protocolIdentifier
						and: [ 
							infoHash = anotherHandshake infoHash
								and: [ peerID = anotherHandshake peerID and: [ protocolBehaviour = anotherHandshake protocolBehaviour ] ] ] ]
				ifFalse: [ false ] ]
]

{ #category : #'converting-arrays' }
BtHandshakeMessage >> asByteArray [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: protocolIdentifier size asByteArray;
		nextPutAll: protocolIdentifier asByteArray;
		nextPutAll: protocolBehaviour asByteArray;
		nextPutAll: (infoHash asByteArrayOfSize: 20);
		nextPutAll: (peerID asByteArrayOfSize: 20).
	^ stream contents
]

{ #category : #accessing }
BtHandshakeMessage >> infoHash [
	^ infoHash
]

{ #category : #accessing }
BtHandshakeMessage >> infoHash: anObject [
	infoHash := anObject
]

{ #category : #'initialize-release' }
BtHandshakeMessage >> initialize [
	super initialize.
	protocolIdentifier:= '' .
	protocolBehaviour:= BtProtocolBehaviour new.
	infoHash:= (ByteArray new:20).
	peerID:= (ByteArray new:20).
]

{ #category : #accessing }
BtHandshakeMessage >> peerID [
	^ peerID
]

{ #category : #accessing }
BtHandshakeMessage >> peerID: anObject [
	peerID := anObject
]

{ #category : #accessing }
BtHandshakeMessage >> protocolBehaviour [
	^ protocolBehaviour
]

{ #category : #accessing }
BtHandshakeMessage >> protocolBehaviour: anObject [
	protocolBehaviour := anObject
]

{ #category : #accessing }
BtHandshakeMessage >> protocolIdentifier [
	^ protocolIdentifier
]

{ #category : #accessing }
BtHandshakeMessage >> protocolIdentifier: anObject [
	protocolIdentifier := anObject
]
