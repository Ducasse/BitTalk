"
A BtPortPayload is xxxxxxxxx.

"
Class {
	#name : #BtPortPayload,
	#superclass : #BtMessagePayload,
	#instVars : [
		'port'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #comparing }
BtPortPayload >> = anotherPayload [
	^ self == anotherPayload 
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPayload species
				ifTrue: [ port = anotherPayload port ]
				ifFalse: [ false ] 
		]
]

{ #category : #'converting-arrays' }
BtPortPayload >> asByteArray [
	^port asByteArrayOfSize: 2
]

{ #category : #'initialize-release' }
BtPortPayload >> initialize [
	super initialize.
	port := 0.
]

{ #category : #accessing }
BtPortPayload >> port [
	^ port
]

{ #category : #accessing }
BtPortPayload >> port: anObject [
	port := anObject
]

{ #category : #printing }
BtPortPayload >> printOn: aStream [
	aStream nextPutAll: port asString
]
