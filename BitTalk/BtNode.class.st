"
A BtNode is xxxxxxxxx.

"
Class {
	#name : #BtNode,
	#superclass : #Object,
	#instVars : [
		'domain',
		'port',
		'debug'
	],
	#category : #BitTalk
}

{ #category : #comparing }
BtNode >> = anotherNode [
	^ self == anotherNode
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherNode species
				ifTrue: [ domain = anotherNode domain and: [ port = anotherNode port ] ]
				ifFalse: [ false ] 
		]
]

{ #category : #accessing }
BtNode >> debug: aBoolean [
	debug := aBoolean
]

{ #category : #accessing }
BtNode >> domain [
	^ domain
]

{ #category : #accessing }
BtNode >> domain: anObject [
	domain := anObject
]

{ #category : #comparing }
BtNode >> hash [
	"Hash is reimplemented because = is implemented."

	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: domain hash asByteArray;
		nextPutAll: port hash asByteArray.
	^ stream contents hash
]

{ #category : #'initialize-release' }
BtNode >> initialize [
	super initialize.
	domain := BtDomain new.
	port := 0.
	debug := false.
]

{ #category : #printing }
BtNode >> log: aString [
	debug
		ifFalse: [ ^ self ].
	self crLog.
	aString crLog
]

{ #category : #accessing }
BtNode >> port [
	^ port
]

{ #category : #accessing }
BtNode >> port: anObject [
	port := anObject
]

{ #category : #printing }
BtNode >> printOn: aStream [
	aStream
		nextPutAll: 'Node[';
		nextPutAll: domain address asIPv4 dotted;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: ']'
]
