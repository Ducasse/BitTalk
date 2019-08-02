"
A BtDHTNode is xxxxxxxxx.

"
Class {
	#name : #BtDHTNode,
	#superclass : #BtNode,
	#instVars : [
		'id'
	],
	#category : #'BitTalk-DHT'
}

{ #category : #comparing }
BtDHTNode >> = anotherNode [
	^ self == anotherNode
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherNode species
				ifTrue: [ id = anotherNode id ]
				ifFalse: [ false ] 
		]
]

{ #category : #comparing }
BtDHTNode >> hash [
	^ id hash
]

{ #category : #accessing }
BtDHTNode >> id [
	^ id
]

{ #category : #accessing }
BtDHTNode >> id: anObject [
	id := anObject
]

{ #category : #'initialize-release' }
BtDHTNode >> initialize [
	super initialize.
	id := 0
]

{ #category : #printing }
BtDHTNode >> printOn: aStream [
	aStream
		nextPutAll: 'DHTNode[';
		nextPutAll: (id asByteArrayOfSize:20) asString;
		nextPutAll: '/';
		nextPutAll: domain address asIPv4 dotted;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: ']'
]

{ #category : #testing }
BtDHTNode >> within: aBtBucketTree [
	^ id between: aBtBucketTree firstID and: aBtBucketTree lastID 
]
