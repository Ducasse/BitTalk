"
A Peer is xxxxxxxxx.

"
Class {
	#name : #BtPeer,
	#superclass : #BtNode,
	#instVars : [
		'id',
		'dhtPort'
	],
	#category : #BitTalk
}

{ #category : #comparing }
BtPeer >> = anotherPeer [
	^ self == anotherPeer
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPeer species
				ifTrue: [ domain = anotherPeer domain and: [ port = anotherPeer port and: [ id = anotherPeer id ] ] ]
				ifFalse: [ false ] 
		]
]

{ #category : #accessing }
BtPeer >> dhtPort [
	^ dhtPort
]

{ #category : #accessing }
BtPeer >> dhtPort: anObject [
	dhtPort := anObject
]

{ #category : #comparing }
BtPeer >> hash [
"Hash is reimplemented because = is implemented."
	| collection |
	collection := WriteStream with: ByteArray new.
	collection nextPutAll: domain hash asByteArray .
	collection nextPutAll: port hash asByteArray .
	collection nextPutAll: id hash asByteArray . 
	^collection contents hash
]

{ #category : #accessing }
BtPeer >> id [
	^ id
]

{ #category : #accessing }
BtPeer >> id: anObject [
	id := anObject
]

{ #category : #'initialize-release' }
BtPeer >> initialize [
	super initialize.
	id := 0.
	dhtPort := 0
]

{ #category : #printing }
BtPeer >> printOn: aStream [
	self subclassResponsibility 
]
